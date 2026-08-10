import assert from 'node:assert/strict';
import test from 'node:test';

process.env.DATABASE_URL ??= 'postgres://user:pass@localhost/db';
process.env.JWT_SECRET ??= 'unit-test-secret-unit-test-secret-0123456789';

const { sanitizeGuestImport } = await import('../server/routes/progress-sync.js');

test('guest import rejects unknown lessons and derives public progress', () => {
  const value = sanitizeGuestImport({
    completedLessons: ['a1', 'a1', 'not-a-real-lesson', 'q_fatiha_1'],
    xp: 999999,
    level: 999,
    streak: 999,
    totalLessons: 999,
    totalMinutes: 999999,
    rewardHistory: ['forged'],
  });

  assert.deepEqual(value.completedLessons, ['a1', 'q_fatiha_1']);
  assert.equal(value.xp, 45);
  assert.equal(value.level, 1);
  assert.equal(value.streak, 0);
  assert.equal(value.totalLessons, 2);
  assert.equal(value.totalMinutes, 10);
  assert.deepEqual(value.rewardHistory, []);
});
