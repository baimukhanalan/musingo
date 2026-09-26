import assert from 'node:assert/strict';
import test from 'node:test';

// progress.js reads the bundled registry but does not import db.js, so these run without a
// DATABASE_URL. Both anti-cheat holes live here: the guest-import caps in
// mergeLearningState and the reward-replay dedup in isRewardReplay.
import {
  defaultProgress,
  isRewardReplay,
  lessonAttemptEligibility,
  mergeLearningState,
  MIN_RECORDED_LESSON_STEPS,
} from '../server/lib/progress.js';

const user = { id: 'u1', email: 'a@b.co', display_name: 'Alan' };

// --- guest import: xp/streak caps and level recompute --------------------

test('guest import clamps inflated xp to the completedLessons-derived cap', () => {
  const merged = mergeLearningState(defaultProgress(user), {
    xp: 1_000_000,               // a would-be instant leaderboard top
    completedLessons: ['r1', 'r2'], // 2 lessons -> cap 2 * 1000 = 2000
  }, { importGuest: true });
  assert.equal(merged.xp, 2000);
  assert.equal(merged.level, 5); // floor(2000/500)+1, recomputed from the clamped xp
});

test('guest import xp can never exceed the hard 50k ceiling', () => {
  const many = Array.from({ length: 100 }, (_, i) => `a${i + 1}`); // real registry IDs; 100 * 1000 > hard cap
  const merged = mergeLearningState(defaultProgress(user), {
    xp: 999_999,
    completedLessons: many,
  }, { importGuest: true });
  assert.equal(merged.xp, 50_000);
  assert.equal(merged.level, 101); // floor(50000/500)+1
});

test('guest import recomputes level even when a matching xp is claimed', () => {
  // Client claims a level inconsistent with its xp; server must recompute it.
  const merged = mergeLearningState(defaultProgress(user), {
    xp: 725,
    level: 99,
    completedLessons: ['r1'], // cap 1000, so 725 survives
  }, { importGuest: true });
  assert.equal(merged.xp, 725);
  assert.equal(merged.level, 2); // not 99
});

test('guest import clamps an impossible streak to the cap', () => {
  const merged = mergeLearningState(defaultProgress(user), {
    streak: 99_999,
    completedLessons: ['r1'],
  }, { importGuest: true });
  assert.equal(merged.streak, 400);
});

// --- guest import: hearts clamp 0..5 -------------------------------------

test('guest import clamps hearts into 0..5', () => {
  const overflow = mergeLearningState(defaultProgress(user), { hearts: 99 }, { importGuest: true });
  assert.equal(overflow.hearts, 5);
  const negative = mergeLearningState(defaultProgress(user), { hearts: -3 }, { importGuest: true });
  assert.equal(negative.hearts, 0);
});

// --- guest import: consistency between counters --------------------------

test('guest helper bounds study seconds by known lessons and attempt budget', () => {
  const merged = mergeLearningState(defaultProgress(user), {
    completedLessons: Array.from({ length: 10 }, (_, i) => `a${i + 1}`),
    totalLessons: 10,
    lessonAttempts: 10,
    totalMinutes: 100_000, // capped at ten declared attempts, at most two hours each
  }, { importGuest: true });
  assert.equal(merged.totalLessons, 10);
  assert.equal(merged.totalMinutes, 1200);
  assert.equal(merged.totalStudySeconds, 72_000);
});

test('guest import clamps totalLessons and energy to their ceilings', () => {
  const merged = mergeLearningState(defaultProgress(user), {
    totalLessons: 10_000,
    energy: 9_999,
  }, { importGuest: true });
  assert.equal(merged.totalLessons, 0); // no registered completed IDs, no count
  assert.equal(merged.energy, 999);
});

test('non-import sync leaves self-reported xp untouched', () => {
  const server = { ...defaultProgress(user), xp: 100 };
  const merged = mergeLearningState(server, { xp: 999_999, completedLessons: ['r2'] });
  assert.equal(merged.xp, 100);
});

// --- reward-replay dedup -------------------------------------------------

test('isRewardReplay flags a token already present in history', () => {
  const history = ['revision:perfect:111', 'quran:practice:222'];
  assert.equal(isRewardReplay(history, 'quran:practice:222'), true);
});

test('isRewardReplay allows a fresh token', () => {
  assert.equal(isRewardReplay(['revision:perfect:111'], 'revision:perfect:999'), false);
});

test('isRewardReplay matches the exact string only (no prefix/substring)', () => {
  assert.equal(isRewardReplay(['revision:perfect:111'], 'revision:perfect:11'), false);
  assert.equal(isRewardReplay(['revision:perfect:111'], 'revision:perfect'), false);
});

test('isRewardReplay tolerates missing/empty history or token', () => {
  assert.equal(isRewardReplay(undefined, 'a:b:1'), false);
  assert.equal(isRewardReplay(null, 'a:b:1'), false);
  assert.equal(isRewardReplay(['a:b:1'], ''), false);
});

// --- authoritative lesson-attempt receipts ------------------------------

test('lesson reward requires enough sequentially recorded server steps', () => {
  const now = Date.parse('2026-09-11T12:00:00Z');
  const short = lessonAttemptEligibility({
    completed_steps: MIN_RECORDED_LESSON_STEPS - 1,
    started_at: '2026-09-11T11:59:00Z',
    consumed_at: null,
  }, { now });
  assert.equal(short.eligible, false);

  const complete = lessonAttemptEligibility({
    completed_steps: MIN_RECORDED_LESSON_STEPS,
    started_at: '2026-09-11T11:59:00Z',
    consumed_at: null,
  }, { now });
  assert.equal(complete.eligible, true);
  assert.equal(complete.completedSteps, MIN_RECORDED_LESSON_STEPS);
});

test('lesson reward refuses a consumed or implausibly fast receipt', () => {
  const now = Date.parse('2026-09-11T12:00:00Z');
  const fast = lessonAttemptEligibility({
    completed_steps: 20,
    started_at: '2026-09-11T11:59:50Z',
    consumed_at: null,
  }, { now });
  assert.equal(fast.minimumElapsedMs, 15_000);
  assert.equal(fast.eligible, false);

  const consumed = lessonAttemptEligibility({
    completed_steps: 20,
    started_at: '2026-09-11T11:58:00Z',
    consumed_at: '2026-09-11T11:59:00Z',
  }, { now });
  assert.equal(consumed.eligible, false);
});

test('lesson reward refuses missing or malformed attempt timestamps', () => {
  assert.equal(lessonAttemptEligibility(null).eligible, false);
  assert.equal(lessonAttemptEligibility({
    completed_steps: 99,
    started_at: 'not-a-date',
    consumed_at: null,
  }).eligible, false);
});
