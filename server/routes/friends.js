import { requireUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { ApiError, method, readJson, text, withApi } from '../lib/http.js';

// Код-приглашение выводится ДЕТЕРМИНИРОВАННО из первых 40 бит (5 байт) UUID
// пользователя и кодируется в base32 по алфавиту Crockford (без похожих букв
// I/L/O/U) — 8 читаемых символов. Сырой UUID наружу не отдаём: код служит
// стабильным публичным идентификатором друга. 40 бит достаточно, чтобы
// коллизии на масштабе приложения были практически невероятны (~1% при ~150k
// пользователей), а при добавлении по коду мы требуем ровно одно совпадение.
const ALPHABET = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';

// id (UUID) → 8-символьный код. Чистая функция для юнит-тестов.
export function friendCode(userId) {
  const hex = String(userId ?? '').replace(/-/g, '').slice(0, 10).toLowerCase();
  if (hex.length < 10 || /[^0-9a-f]/.test(hex)) {
    throw new ApiError(500, 'invalid_user_id', 'User id is not a UUID.');
  }
  let value = BigInt(`0x${hex}`);
  let out = '';
  for (let i = 0; i < 8; i += 1) {
    out = ALPHABET[Number(value & 31n)] + out;
    value >>= 5n;
  }
  return out;
}

// Нормализует введённый пользователем код: верхний регистр, срезает пробелы и
// дефисы, схлопывает Crockford-неоднозначности (O→0, I/L→1). Чистая функция.
export function normalizeFriendCode(input) {
  const raw = String(input ?? '')
    .toUpperCase()
    .replace(/[\s-]/g, '')
    .replace(/O/g, '0')
    .replace(/[IL]/g, '1');
  if (raw.length !== 8 || [...raw].some((ch) => !ALPHABET.includes(ch))) {
    throw new ApiError(400, 'invalid_code', 'Invalid friend code.');
  }
  return raw;
}

// Обратная операция: код → 10 hex-символов (первые 40 бит UUID). Чистая
// функция — round-trip с friendCode проверяется тестом.
export function friendCodePrefixHex(code) {
  const normalized = normalizeFriendCode(code);
  let value = 0n;
  for (const ch of normalized) {
    value = value * 32n + BigInt(ALPHABET.indexOf(ch));
  }
  return value.toString(16).padStart(10, '0');
}

// Границы диапазона UUID, у которых первые 40 бит равны префиксу кода. Запрос по
// диапазону использует btree-индекс первичного ключа muslingo_users(id).
function idBounds(prefixHex) {
  const head = `${prefixHex.slice(0, 8)}-${prefixHex.slice(8, 10)}`;
  return {
    lo: `${head}00-0000-0000-000000000000`,
    hi: `${head}ff-ffff-ffff-ffffffffffff`,
  };
}

// Находит пользователя по коду друга. Возвращает публичную запись (без email и
// без сырого UUID снаружи; сам id нужен только для внутренних вставок).
async function findByCode(code) {
  const { lo, hi } = idBounds(friendCodePrefixHex(code));
  const rows = await sql`
    SELECT u.id, u.display_name,
           COALESCE((p.document->>'xp')::int, 0) AS xp,
           COALESCE((p.document->>'streak')::int, 0) AS streak
    FROM muslingo_users u
    LEFT JOIN muslingo_progress p ON p.user_id = u.id
    WHERE u.id >= ${lo}::uuid AND u.id <= ${hi}::uuid
  `;
  // Ровно одно совпадение = однозначный друг. Ноль — кода нет; больше одного —
  // редчайшая коллизия префикса, которую безопаснее трактовать как «не найден»,
  // чем добавить случайного человека.
  if (rows.length !== 1) {
    throw new ApiError(404, 'friend_not_found', 'No user with this friend code.');
  }
  return rows[0];
}

function publicFriend(row) {
  return {
    code: friendCode(row.id),
    displayName: row.display_name,
    xp: Number(row.xp) || 0,
    streak: Number(row.streak) || 0,
  };
}

export default withApi(async (request, response) => {
  method(request, ['GET', 'POST']);
  const user = await requireUser(request);

  if (request.method === 'GET') {
    // Собственный код + display_name и список друзей одним запросом.
    const rows = await sql`
      SELECT u.id, u.display_name,
             COALESCE((p.document->>'xp')::int, 0) AS xp,
             COALESCE((p.document->>'streak')::int, 0) AS streak
      FROM muslingo_friendships f
      JOIN muslingo_users u ON u.id = f.friend_id
      LEFT JOIN muslingo_progress p ON p.user_id = u.id
      WHERE f.user_id = ${user.id}::uuid
      ORDER BY xp DESC, u.display_name ASC
    `;
    return response.status(200).json({
      code: friendCode(user.id),
      displayName: user.display_name,
      friends: rows.map(publicFriend),
    });
  }

  const body = readJson(request);
  const action = text(body.action, { min: 1, max: 20, field: 'action' });
  const code = normalizeFriendCode(body.code);

  // Свой собственный код сравниваем ПО КОДУ, не по id: так себя не добавить,
  // даже если пользователь ввёл код в другом регистре или с дефисами.
  if (code === friendCode(user.id)) {
    throw new ApiError(400, 'cannot_add_self', 'You cannot add yourself.');
  }

  if (action === 'add') {
    const friend = await findByCode(code);
    // Две направленные строки в одной транзакции; дубликаты гасит первичный ключ.
    await sql.transaction([
      sql`INSERT INTO muslingo_friendships (user_id, friend_id)
          VALUES (${user.id}::uuid, ${friend.id}::uuid)
          ON CONFLICT DO NOTHING`,
      sql`INSERT INTO muslingo_friendships (user_id, friend_id)
          VALUES (${friend.id}::uuid, ${user.id}::uuid)
          ON CONFLICT DO NOTHING`,
    ]);
    return response.status(200).json({ added: true, friend: publicFriend(friend) });
  }

  if (action === 'remove') {
    const friend = await findByCode(code);
    await sql.transaction([
      sql`DELETE FROM muslingo_friendships
          WHERE user_id = ${user.id}::uuid AND friend_id = ${friend.id}::uuid`,
      sql`DELETE FROM muslingo_friendships
          WHERE user_id = ${friend.id}::uuid AND friend_id = ${user.id}::uuid`,
    ]);
    return response.status(200).json({ removed: true });
  }

  throw new ApiError(400, 'invalid_action', 'Unknown friends action.');
});
