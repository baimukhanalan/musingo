import assert from 'node:assert/strict';
import test from 'node:test';

// db.js должен корректно работать при статическом/локальном деплое без БД:
// импорт модуля не обращается к DATABASE_URL, а реальное использование sql без
// заданной переменной даёт чистый 503 (database_unavailable), а не падение при
// импорте, которое роняло любой роут в 500.
delete process.env.DATABASE_URL;

const { sql, ensureSchema } = await import('../server/lib/db.js');

test('импорт db.js без DATABASE_URL не бросает и отдаёт sql/ensureSchema', () => {
  assert.ok(sql, 'sql должен экспортироваться');
  assert.equal(typeof ensureSchema, 'function');
});

test('tagged-template sql`...` без DATABASE_URL бросает 503 database_unavailable', async () => {
  await assert.rejects(
    async () => sql`SELECT 1`,
    (error) => {
      assert.equal(error.status, 503);
      assert.equal(error.code, 'database_unavailable');
      return true;
    },
  );
});

test('sql.transaction без DATABASE_URL тоже бросает 503 database_unavailable', () => {
  assert.throws(
    () => sql.transaction([]),
    (error) => {
      assert.equal(error.status, 503);
      assert.equal(error.code, 'database_unavailable');
      return true;
    },
  );
});

test('ensureSchema без DATABASE_URL отклоняется с 503, а не падает при импорте', async () => {
  await assert.rejects(ensureSchema(), (error) => {
    assert.equal(error.status, 503);
    assert.equal(error.code, 'database_unavailable');
    return true;
  });
});
