import assert from 'node:assert/strict';
import test from 'node:test';

process.env.DATABASE_URL ??= 'postgres://user:pass@localhost/db';
process.env.JWT_SECRET ??= 'unit-test-secret-unit-test-secret-0123456789';

const { sanitizeGuestImport } = await import('../server/routes/progress-sync.js');

test('guest import keeps personalization but never imports rewards or unlocks', () => {
  const value = sanitizeGuestImport({
    completedLessons: ['a1', 'a1', 'not-a-real-lesson', 'q_fatiha_1'],
    xp: 999999,
    level: 999,
    streak: 999,
    bestStreak: 999,
    totalLessons: 999,
    totalMinutes: 999999,
    totalStudySeconds: 9999999,
    rewardHistory: ['forged'],
  });

  assert.deepEqual(value.completedLessons, []);
  assert.equal(value.xp, 0);
  assert.equal(value.level, 1);
  assert.equal(value.streak, 0);
  assert.equal(value.bestStreak, 0);
  assert.equal(value.totalLessons, 0);
  assert.equal(value.totalMinutes, 0);
  assert.equal(value.totalStudySeconds, 0);
  assert.deepEqual(value.rewardHistory, []);
});
