import assert from 'node:assert/strict';
import test from 'node:test';
import { defaultProgress, mergeLearningState } from '../server/lib/progress.js';

test('curriculum sync updates learning map but cannot mint activity or rewards', () => {
  const before = {
    ...defaultProgress({ id: 'a', display_name: 'A', email: 'a@example.test' }),
    xp: 25,
    streak: 2,
    bestStreak: 7,
    lastStudyDay: '2026-09-18',
    dailyProgress: 1,
    totalLessons: 1,
  };
  const forged = {
    curriculumProgress: {
      completedModuleIds: ['QUR-001'],
      stepByModuleId: { 'QUR-001': 4 },
      masteryByModuleId: { 'QUR-001': 100 },
      lastModuleId: 'QUR-001',
      lastActivityAt: '2026-09-20T08:00:00.000Z',
    },
    xp: 10000,
    streak: 100,
    bestStreak: 100,
    lastStudyDay: '2026-09-20',
    dailyProgress: 20,
    totalLessons: 570,
  };
  const after = mergeLearningState(before, forged);
  assert.deepEqual(after.curriculumProgress.completedModuleIds, ['QUR-001']);
  for (const field of ['xp', 'streak', 'bestStreak', 'lastStudyDay', 'dailyProgress', 'totalLessons']) {
    assert.equal(after[field], before[field], field);
  }
  const replay = mergeLearningState(after, forged);
  for (const field of ['xp', 'streak', 'bestStreak', 'lastStudyDay', 'dailyProgress', 'totalLessons']) {
    assert.equal(replay[field], before[field], `replay ${field}`);
  }
});
