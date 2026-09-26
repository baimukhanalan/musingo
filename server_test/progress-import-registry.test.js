import assert from 'node:assert/strict';
import test from 'node:test';
import {
  defaultProgress, isRewardReplay, learningRegistryLessonIds, mergeLearningState,
} from '../server/lib/progress.js';
import { lessons, completionUpdate } from '../server/routes/progress-complete.js';
import { sanitizeGuestImport } from '../server/routes/progress-sync.js';

const user = { id: 'u-import', display_name: 'Learner', email: 'learner@example.invalid' };
const allIds = [...lessons];

test('import helper registry exactly matches all 1148 completion IDs', () => {
  assert.equal(learningRegistryLessonIds.size, 1148);
  assert.deepEqual([...learningRegistryLessonIds].sort(), allIds.toSorted());
});

test('actual sanitized guest signup preserves full existing server progress and receipts', () => {
  const current = {
    ...defaultProgress(user), completedLessons: allIds,
    totalLessons: 1148, learnedAyats: 6236, totalMinutes: 1148,
    totalStudySeconds: 68_939, xp: 75_000, level: 151,
    rewardHistory: ['server-receipt'], lastStudyDay: '2026-09-26',
  };
  const input = sanitizeGuestImport({
    completedLessons: ['r1'], xp: 999_999, totalLessons: 999999,
    learnedAyats: 99999, totalMinutes: 999999, totalStudySeconds: 99999999,
    lastStudyDay: '2026-09-20', rewardHistory: ['forged'],
  });
  const next = mergeLearningState(current, input, { importGuest: true });
  assert.equal(next.totalLessons, 1148);
  assert.equal(next.learnedAyats, 6236);
  assert.equal(next.totalStudySeconds, 68_939);
  assert.equal(next.totalMinutes, 1148);
  assert.equal(next.xp, 75_000);
  assert.equal(next.lastStudyDay, '2026-09-26');
  assert.equal(isRewardReplay(next.rewardHistory, 'server-receipt'), true);
  assert.equal(next.rewardHistory.includes('forged'), false);
});

test('actual guest signup still cannot import unverifiable completions or study time', () => {
  const next = mergeLearningState(defaultProgress(user), sanitizeGuestImport({
    completedLessons: allIds, totalLessons: 1148, learnedAyats: 6236,
    totalMinutes: 1148, totalStudySeconds: 68_939, xp: 30_000,
  }), { importGuest: true });
  assert.equal(next.totalLessons, 0);
  assert.equal(next.learnedAyats, 0);
  assert.equal(next.totalMinutes, 0);
  assert.equal(next.totalStudySeconds, 0);
  assert.equal(next.xp, 0);
  assert.deepEqual(next.completedLessons, []);
});

test('pure helper uses source-derived counts and exact seconds without repeat import increments', () => {
  const input = { completedLessons: allIds, totalLessons: 1148,
    learnedAyats: 6236, totalMinutes: 1148, totalStudySeconds: 68_939,
    lessonAttempts: 1148 };
  const first = mergeLearningState(defaultProgress(user), input, { importGuest: true });
  assert.equal(first.totalLessons, 1148);
  assert.equal(first.learnedAyats, 6236);
  assert.equal(first.totalStudySeconds, 68_939);
  const repeated = mergeLearningState(first, input, { importGuest: true });
  assert.equal(repeated.totalStudySeconds, first.totalStudySeconds);
  assert.equal(repeated.totalLessons, first.totalLessons);
  assert.equal(repeated.learnedAyats, first.learnedAyats);
  const replay = completionUpdate({ current: repeated,
    lessonId: 'q_full_1_1_7', rewardToken: 'new-replay-receipt',
    receipt: { elapsedMs: 1000 }, elapsedSeconds: 1,
    now: Date.parse('2026-09-26T16:00:00Z') });
  assert.equal(replay.next.totalStudySeconds, 68_940);
  assert.equal(replay.next.totalMinutes, 1149);
  assert.equal(replay.next.totalLessons, 1148);
  assert.equal(replay.next.learnedAyats, 6236);
  assert.equal(replay.firstCompletion, false);
});

test('duplicate or invented IDs cannot mint counts and overlapping ayahs form a union', () => {
  const next = mergeLearningState(defaultProgress(user), {
    completedLessons: ['q_fatiha_1', 'q_fatiha_1', 'q_full_1_1_7', 'unknown', 'q_full_999_1_2'],
    totalLessons: 99999, learnedAyats: 99999,
  }, { importGuest: true });
  assert.equal(next.totalLessons, 2);
  assert.equal(next.learnedAyats, 7);
  assert.deepEqual(next.completedLessons, ['q_fatiha_1', 'q_full_1_1_7']);
});

test('seconds retain server priority, migrate old minutes and bound guest-only time', () => {
  const source = { ...defaultProgress(user), totalMinutes: 2, totalStudySeconds: 179 };
  const older = mergeLearningState(source, { completedLessons: ['r1'], totalStudySeconds: 59 }, { importGuest: true });
  assert.equal(older.totalStudySeconds, 179);
  const legacy = mergeLearningState({ ...defaultProgress(user), totalMinutes: 2 }, {}, { importGuest: true });
  assert.equal(legacy.totalStudySeconds, 120);
  const huge = mergeLearningState(defaultProgress(user), {
    completedLessons: ['r1'], lessonAttempts: 1,
    totalStudySeconds: Number.MAX_SAFE_INTEGER, totalMinutes: Number.MAX_SAFE_INTEGER,
  }, { importGuest: true });
  assert.equal(huge.totalStudySeconds, 7200);
  assert.equal(huge.totalMinutes, 120);
  const tiny = mergeLearningState(defaultProgress(user), {
    completedLessons: ['r1'], totalStudySeconds: 59, totalMinutes: 0,
  }, { importGuest: true });
  assert.equal(tiny.totalStudySeconds, 59);
  assert.equal(tiny.totalMinutes, 0);
});

test('guest reward history cannot evict any of the last 500 server receipt guards', () => {
  const serverTokens = Array.from({ length: 500 }, (_, i) => `server-${i}`);
  const guestTokens = [...serverTokens.slice(0, 100),
    ...Array.from({ length: 500 }, (_, i) => `guest-${i}`)];
  const next = mergeLearningState({ ...defaultProgress(user), rewardHistory: serverTokens }, {
    rewardHistory: guestTokens,
  }, { importGuest: true });
  assert.deepEqual(next.rewardHistory, serverTokens);
  for (const token of serverTokens) assert.equal(isRewardReplay(next.rewardHistory, token), true);
});
