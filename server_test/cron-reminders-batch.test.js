import assert from 'node:assert/strict';
import test from 'node:test';

// cron-reminders.js тянет db.js по цепочке импортов. Значение фиктивное: neon()
// не подключается до первого запроса, а тестируем мы только чистые функции
// (chunk / isDue / selectCandidates / collectCandidates / constantTimeEqual)
// без реальной БД и без web-push round-trip.
process.env.DATABASE_URL ??= 'postgres://user:pass@localhost/db';

const {
  BATCH_SIZE,
  PAGE_SIZE,
  chunk,
  isDue,
  selectCandidates,
  collectCandidates,
  constantTimeEqual,
} = await import('../server/routes/cron-reminders.js');

// Момент, на который «сейчас» = 2026-08-09 19:30 UTC. Строки с reminder_hour=19,
// reminder_minute=30 и timezone='UTC' попадают в окно напоминания.
const NOW = new Date('2026-08-09T19:30:00Z');

function utcRow(hash, overrides = {}) {
  return {
    endpoint_hash: hash,
    endpoint: `https://fcm.googleapis.com/fcm/send/${hash}`,
    p256dh: 'p',
    auth_secret: 'a',
    installation_id: hash,
    timezone: 'UTC',
    reminder_hour: 19,
    reminder_minute: 30,
    due_count: 3,
    learning_goal: null,
    last_sent_date: null,
    ...overrides,
  };
}

// Имитация SQL-выборки `WHERE endpoint_hash > $cursor ORDER BY endpoint_hash
// LIMIT $size`. endpoint_hash с фиксированной шириной => лексикографический
// порядок совпадает с числовым.
function makeFetchPage(rows) {
  const sorted = [...rows].sort((left, right) => (left.endpoint_hash < right.endpoint_hash ? -1 : 1));
  const calls = [];
  const fetchPage = async (cursor, size) => {
    calls.push({ cursor, size });
    return sorted.filter((row) => row.endpoint_hash > cursor).slice(0, size);
  };
  return { fetchPage, calls };
}

// --- chunk: корректное разбиение на пачки ---------------------------------

test('chunk бьёт массив на пачки заданного размера с остатком', () => {
  assert.deepEqual(chunk([1, 2, 3, 4, 5], 2), [[1, 2], [3, 4], [5]]);
  assert.deepEqual(chunk([1, 2, 3, 4], 2), [[1, 2], [3, 4]]);
});

test('chunk на пустом входе даёт пустой список', () => {
  assert.deepEqual(chunk([], 50), []);
});

test('chunk не зацикливается при некорректном размере (0/NaN → шаг 1)', () => {
  assert.deepEqual(chunk([1, 2], 0), [[1], [2]]);
  assert.deepEqual(chunk([1, 2], Number.NaN), [[1], [2]]);
});

test('BATCH_SIZE сохранён положительным (идемпотентность рассылки не тронута)', () => {
  assert.ok(Number.isInteger(BATCH_SIZE) && BATCH_SIZE > 0);
});

// --- isDue: фильтр окна напоминания ----------------------------------------

test('isDue: точное совпадение часа и 15-минутной корзины', () => {
  const local = { date: '2026-08-09', hour: 19, minute: 30 };
  assert.equal(isDue(utcRow('h'), local), true);
  // 19:31 и 19:30 — одна корзина [30..44].
  assert.equal(isDue(utcRow('h'), { ...local, minute: 31 }), true);
});

test('isDue: другой час или другая корзина минут — не пора', () => {
  assert.equal(isDue(utcRow('h'), { date: '2026-08-09', hour: 18, minute: 30 }), false);
  // 19:29 — корзина [15..29], а reminder_minute=30 → корзина [30..44].
  assert.equal(isDue(utcRow('h'), { date: '2026-08-09', hour: 19, minute: 29 }), false);
});

test('isDue: уже отправлено сегодня по локальной дате — не пора', () => {
  const local = { date: '2026-08-09', hour: 19, minute: 30 };
  assert.equal(isDue(utcRow('h', { last_sent_date: '2026-08-09' }), local), false);
  // Вчерашняя отметка не блокирует сегодняшнюю отправку.
  assert.equal(isDue(utcRow('h', { last_sent_date: '2026-08-08' }), local), true);
  // last_sent_date может прийти как timestamp/Date-строка — сравниваем префикс.
  assert.equal(isDue(utcRow('h', { last_sent_date: '2026-08-09T00:00:00.000Z' }), local), false);
});

// --- selectCandidates: отбор по снимку + запасной UTC ----------------------

test('selectCandidates отбирает только строки в окне, считая локальное время', () => {
  const rows = [
    utcRow('a'), // в окне
    utcRow('b', { reminder_hour: 8 }), // не в окне
    utcRow('c', { last_sent_date: '2026-08-09' }), // уже отправлено
    utcRow('d'), // в окне
  ];
  const candidates = selectCandidates(rows, NOW);
  assert.deepEqual(candidates.map((candidate) => candidate.row.endpoint_hash), ['a', 'd']);
  // local прикреплён к кандидату для идемпотентного UPDATE в deliver().
  assert.equal(candidates[0].local.date, '2026-08-09');
  assert.equal(candidates[0].local.hour, 19);
});

test('selectCandidates не падает на битой таймзоне — откат на UTC', () => {
  const candidates = selectCandidates([utcRow('z', { timezone: 'Not/AZone' })], NOW);
  assert.equal(candidates.length, 1);
  assert.equal(candidates[0].local.hour, 19);
});

// --- collectCandidates: курсорная пагинация покрывает ВЕСЬ хвост -----------

test('PAGE_SIZE — вменяемый положительный размер страницы', () => {
  assert.ok(Number.isInteger(PAGE_SIZE) && PAGE_SIZE > 0);
});

test('порог 2000 больше НЕ отсекает хвост: видны все 2500 строк', async () => {
  // Прежняя выборка (ORDER BY updated_at DESC LIMIT 2000) навсегда теряла
  // строки за пределами топ-2000. Курсор по endpoint_hash обходит их все.
  const total = 2500;
  const rows = [];
  for (let index = 0; index < total; index += 1) {
    rows.push(utcRow(`h${String(index).padStart(4, '0')}`));
  }
  const { fetchPage } = makeFetchPage(rows);

  const { checked, candidates } = await collectCandidates(fetchPage, NOW, PAGE_SIZE);

  assert.equal(checked, total, 'проверены все строки, а не первые 2000');
  assert.equal(candidates.length, total, 'все попадают в окно → все кандидаты');
  // Хвост, который LIMIT 2000 отбрасывал, теперь присутствует.
  const hashes = new Set(candidates.map((candidate) => candidate.row.endpoint_hash));
  assert.ok(hashes.has('h2000'), 'строка на границе прежнего лимита включена');
  assert.ok(hashes.has('h2499'), 'самый хвост включён');
});

test('collectCandidates идёт страницами пока пачка полная и корректно двигает курсор', async () => {
  const rows = [];
  for (let index = 0; index < 25; index += 1) {
    rows.push(utcRow(`h${String(index).padStart(2, '0')}`));
  }
  const { fetchPage, calls } = makeFetchPage(rows);

  const { checked, candidates } = await collectCandidates(fetchPage, NOW, 10);

  assert.equal(checked, 25);
  assert.equal(candidates.length, 25);
  // 10 + 10 + 5 => на неполной пачке цикл останавливается: 3 запроса.
  assert.equal(calls.length, 3);
  assert.equal(calls[0].cursor, '');
  assert.equal(calls[1].cursor, 'h09');
  assert.equal(calls[2].cursor, 'h19');
});

test('collectCandidates фильтрует окно на лету: checked считает всё, кандидаты — только due', async () => {
  const rows = [
    utcRow('h00'),
    utcRow('h01', { reminder_hour: 7 }), // не в окне
    utcRow('h02'),
    utcRow('h03', { last_sent_date: '2026-08-09' }), // уже отправлено
  ];
  const { fetchPage } = makeFetchPage(rows);

  const { checked, candidates } = await collectCandidates(fetchPage, NOW, 10);

  assert.equal(checked, 4);
  assert.deepEqual(candidates.map((candidate) => candidate.row.endpoint_hash), ['h00', 'h02']);
});

test('collectCandidates на пустой базе не зацикливается', async () => {
  const { fetchPage, calls } = makeFetchPage([]);
  const { checked, candidates } = await collectCandidates(fetchPage, NOW, 10);
  assert.equal(checked, 0);
  assert.equal(candidates.length, 0);
  assert.equal(calls.length, 1); // один пустой запрос и выход
});

// --- constantTimeEqual (L10a): сравнение секрета за постоянное время --------

test('constantTimeEqual: равные строки → true', () => {
  assert.equal(constantTimeEqual('Bearer s3cret', 'Bearer s3cret'), true);
});

test('constantTimeEqual: разные строки одинаковой длины → false', () => {
  assert.equal(constantTimeEqual('Bearer aaaaaa', 'Bearer bbbbbb'), false);
});

test('constantTimeEqual: разная длина → безопасный false без исключения', () => {
  assert.doesNotThrow(() => constantTimeEqual('Bearer short', 'Bearer a-much-longer-secret'));
  assert.equal(constantTimeEqual('Bearer short', 'Bearer a-much-longer-secret'), false);
  assert.equal(constantTimeEqual('', 'Bearer x'), false);
});
