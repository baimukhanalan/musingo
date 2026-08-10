import assert from 'node:assert/strict';
import test from 'node:test';

// friends.js тянет db.js/auth.js, которые падают при импорте без DATABASE_URL.
// Значение фиктивное: neon() не подключается до первого запроса, а тестируются
// только чистые функции кода — без обращения к БД.
process.env.DATABASE_URL ??= 'postgres://user:pass@localhost/db';

const { friendCode, normalizeFriendCode, friendCodePrefixHex } = await import(
  '../server/routes/friends.js'
);

const ALPHABET = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
const idA = 'a1b2c3d4-e5f6-7890-1234-567890abcdef';
const idB = '11111111-2222-3333-4444-555555555555';

// --- код: детерминизм и формат -------------------------------------------

test('friendCode детерминирован для одного id', () => {
  assert.equal(friendCode(idA), friendCode(idA));
});

test('friendCode — 8 символов из алфавита Crockford base32', () => {
  const code = friendCode(idA);
  assert.equal(code.length, 8);
  assert.ok([...code].every((ch) => ALPHABET.includes(ch)), `не base32: ${code}`);
});

test('разные id дают разные коды', () => {
  assert.notEqual(friendCode(idA), friendCode(idB));
});

test('код зависит только от первых 40 бит id', () => {
  // Одинаковый префикс (первые 10 hex) → одинаковый код, хвост не влияет.
  const samePrefix1 = 'a1b2c3d4-e500-0000-0000-000000000000';
  const samePrefix2 = 'a1b2c3d4-e5ff-ffff-ffff-ffffffffffff';
  assert.equal(friendCode(samePrefix1), friendCode(samePrefix2));
  // Отличие в пределах первых 40 бит меняет код.
  const otherPrefix = 'a1b2c3d4-e600-0000-0000-000000000000';
  assert.notEqual(friendCode(samePrefix1), friendCode(otherPrefix));
});

// --- нормализация ввода ---------------------------------------------------

test('normalizeFriendCode приводит к каноничному виду', () => {
  const code = friendCode(idA);
  // Нижний регистр, пробелы и дефисы, вставленные при вводе, не мешают.
  const messy = `  ${code.slice(0, 4).toLowerCase()}-${code.slice(4).toLowerCase()} `;
  assert.equal(normalizeFriendCode(messy), code);
});

test('normalizeFriendCode схлопывает Crockford-неоднозначности O/I/L', () => {
  assert.equal(normalizeFriendCode('OIL00000'), '01100000');
});

test('normalizeFriendCode отклоняет неверную длину и символы', () => {
  for (const bad of ['', 'ABC', 'ABCDEFGHIJ', 'ABCDEF!@']) {
    assert.throws(
      () => normalizeFriendCode(bad),
      (error) => {
        assert.equal(error.status, 400);
        assert.equal(error.code, 'invalid_code');
        return true;
      },
      `должен был отклонить: ${JSON.stringify(bad)}`,
    );
  }
});

test('свой код нормализуется в самого себя (основа запрета добавить себя)', () => {
  const code = friendCode(idA);
  assert.equal(normalizeFriendCode(code), code);
});

// --- обратимость префикса -------------------------------------------------

test('friendCodePrefixHex восстанавливает первые 10 hex id', () => {
  const expected = idA.replace(/-/g, '').slice(0, 10).toLowerCase();
  assert.equal(friendCodePrefixHex(friendCode(idA)), expected);
});

test('round-trip кода сохраняет префикс для id с ведущими нулями', () => {
  const id = '00000abc-de00-0000-0000-000000000000';
  const expected = id.replace(/-/g, '').slice(0, 10).toLowerCase();
  assert.equal(friendCodePrefixHex(friendCode(id)), expected);
});
