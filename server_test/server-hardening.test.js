import assert from 'node:assert/strict';
import test from 'node:test';

// Маршруты тянут db.js/auth.js, которые падают при импорте без DATABASE_URL.
// Значение фиктивное: neon() не подключается до первого запроса, а тестируются
// только чистые функции — без обращения к БД.
process.env.DATABASE_URL ??= 'postgres://user:pass@localhost/db';

const { chunk, BATCH_SIZE } = await import('../server/routes/cron-reminders.js');
const { clampInput, SPEECH_MAX_INPUT } = await import('../server/routes/speech-evaluate.js');
const { leaderboardEntry } = await import('../server/routes/leaderboard.js');

// --- cron: чанкование рассылки (ограниченная конкуренция) -----------------

test('chunk разбивает массив на батчи фиксированного размера', () => {
  assert.deepEqual(chunk([1, 2, 3, 4, 5], 2), [[1, 2], [3, 4], [5]]);
});

test('chunk с размером не меньше длины возвращает один батч', () => {
  assert.deepEqual(chunk([1, 2, 3], 50), [[1, 2, 3]]);
});

test('chunk пустого массива — пустой список батчей', () => {
  assert.deepEqual(chunk([], BATCH_SIZE), []);
});

test('chunk с некорректным размером не зацикливается (шаг минимум 1)', () => {
  assert.deepEqual(chunk([1, 2], 0), [[1], [2]]);
  assert.deepEqual(chunk([1, 2], -5), [[1], [2]]);
  assert.deepEqual(chunk([1, 2], Number.NaN), [[1], [2]]);
});

test('2000 подписок укладываются в <=40 батчей по BATCH_SIZE', () => {
  const items = Array.from({ length: 2000 }, (_, index) => index);
  const batches = chunk(items, BATCH_SIZE);
  assert.equal(BATCH_SIZE, 50);
  assert.equal(batches.length, 40);
  assert.ok(batches.every((batch) => batch.length <= BATCH_SIZE));
  // Ни один элемент не потерян и не задублирован.
  assert.equal(batches.flat().length, 2000);
});

// --- speech: обрезка длины входа до квадратичных вычислений ----------------

test('clampInput режет вход до жёсткого предела', () => {
  const long = 'ا'.repeat(5000);
  assert.equal(SPEECH_MAX_INPUT, 400);
  assert.equal(clampInput(long).length, SPEECH_MAX_INPUT);
});

test('clampInput безопасно обрабатывает null/undefined/число', () => {
  assert.equal(clampInput(null), '');
  assert.equal(clampInput(undefined), '');
  assert.equal(clampInput(1234), '1234');
});

test('clampInput не трогает вход короче предела', () => {
  assert.equal(clampInput('салам'), 'салам');
});

test('clampInput принимает собственный предел', () => {
  assert.equal(clampInput('abcdef', 3), 'abc');
});

// --- leaderboard: запись без UUID ----------------------------------------

test('leaderboardEntry не отдаёт сырой UUID наружу', () => {
  const row = { user_id: '11111111-1111-1111-1111-111111111111', display_name: 'Alan', xp: '120' };
  const entry = leaderboardEntry(row, 0, '22222222-2222-2222-2222-222222222222');
  const keys = Object.keys(entry).sort();
  assert.deepEqual(keys, ['displayName', 'isCurrentUser', 'position', 'xp']);
  assert.ok(!keys.includes('user'));
  assert.ok(!keys.includes('user_id'));
  assert.ok(!Object.values(entry).includes(row.user_id));
});

test('leaderboardEntry вычисляет isCurrentUser сравнением на сервере', () => {
  const row = { user_id: 'uuid-me', display_name: 'Me', xp: 50 };
  assert.equal(leaderboardEntry(row, 3, 'uuid-me').isCurrentUser, true);
  assert.equal(leaderboardEntry(row, 3, 'uuid-other').isCurrentUser, false);
});

test('leaderboardEntry: xp приводится к числу, position = index + 1', () => {
  const entry = leaderboardEntry({ user_id: 'u', display_name: 'N', xp: '999' }, 4, 'x');
  assert.strictEqual(entry.xp, 999);
  assert.equal(entry.position, 5);
  assert.equal(entry.displayName, 'N');
});
