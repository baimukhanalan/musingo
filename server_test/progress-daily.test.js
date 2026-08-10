import assert from 'node:assert/strict';
import test from 'node:test';

// progress.js has no side-effect imports (no db.js), so these run without a
// DATABASE_URL. These cover the M1 (weekly-leaderboard daily cap) and M2
// (dailyProgress reflects today) anti-cheat logic as pure functions.
import {
  LEADERBOARD_DAILY_XP_CAP,
  leaderboardContribution,
  nextDailyProgress,
} from '../server/lib/progress.js';

const TODAY = '2026-08-09';
const YESTERDAY = '2026-08-08';

// --- M1: per-day weekly_xp contribution cap ------------------------------

test('cap is a sane positive ceiling (200 by default)', () => {
  assert.equal(LEADERBOARD_DAILY_XP_CAP, 200);
});

test('a fresh day counts the full earned amount toward weekly_xp', () => {
  const result = leaderboardContribution({ current: {}, today: TODAY, earned: 25 });
  assert.equal(result.contribution, 25);
  assert.equal(result.leaderboardXpToday, 25);
  assert.equal(result.leaderboardXpDay, TODAY);
});

test('within a day the running counter accumulates and is written back', () => {
  const current = { leaderboardXpDay: TODAY, leaderboardXpToday: 25 };
  const result = leaderboardContribution({ current, today: TODAY, earned: 5 });
  assert.equal(result.contribution, 5);
  assert.equal(result.leaderboardXpToday, 30);
  assert.equal(result.leaderboardXpDay, TODAY);
});

test('contribution is clipped to the remaining budget near the cap', () => {
  const current = { leaderboardXpDay: TODAY, leaderboardXpToday: 198 };
  const result = leaderboardContribution({ current, today: TODAY, earned: 5 });
  assert.equal(result.contribution, 2); // only 2 XP of headroom left today
  assert.equal(result.leaderboardXpToday, 200);
});

test('once the cap is reached, further completions add zero to weekly_xp', () => {
  const current = { leaderboardXpDay: TODAY, leaderboardXpToday: 200 };
  const result = leaderboardContribution({ current, today: TODAY, earned: 5 });
  assert.equal(result.contribution, 0);
  assert.equal(result.leaderboardXpToday, 200); // stays pinned at the cap
});

test('a full day of scripted replays never pushes more than the cap into weekly_xp', () => {
  // Simulate 100 repeated lesson completions (5 XP each) in one local day and
  // add up only what actually reaches weekly_xp.
  let current = { leaderboardXpDay: TODAY, leaderboardXpToday: 0 };
  let banked = 0;
  for (let i = 0; i < 100; i += 1) {
    const result = leaderboardContribution({ current, today: TODAY, earned: 5 });
    banked += result.contribution;
    current = { leaderboardXpDay: result.leaderboardXpDay, leaderboardXpToday: result.leaderboardXpToday };
  }
  assert.equal(banked, LEADERBOARD_DAILY_XP_CAP); // 500 XP earned, only 200 counted
  assert.equal(current.leaderboardXpToday, LEADERBOARD_DAILY_XP_CAP);
});

test('a new local day resets the counter so yesterday never restricts today', () => {
  const current = { leaderboardXpDay: YESTERDAY, leaderboardXpToday: 200 };
  const result = leaderboardContribution({ current, today: TODAY, earned: 25 });
  assert.equal(result.contribution, 25); // full amount, fresh budget
  assert.equal(result.leaderboardXpToday, 25);
  assert.equal(result.leaderboardXpDay, TODAY);
});

test('a missing/legacy counter is treated as a fresh day', () => {
  const result = leaderboardContribution({ current: { xp: 500 }, today: TODAY, earned: 5 });
  assert.equal(result.contribution, 5);
  assert.equal(result.leaderboardXpToday, 5);
});

test('negative or garbage earned/counter values never produce a negative contribution', () => {
  const result = leaderboardContribution({
    current: { leaderboardXpDay: TODAY, leaderboardXpToday: -50 },
    today: TODAY,
    earned: -10,
  });
  assert.equal(result.contribution, 0);
  assert.equal(result.leaderboardXpToday, 0);
});

// --- M2: dailyProgress reflects today ------------------------------------

test('dailyProgress restarts at 1 when the local day changes', () => {
  const current = { lastStudyDay: YESTERDAY, dailyProgress: 3, dailyGoal: 3 };
  assert.equal(nextDailyProgress({ current, today: TODAY }), 1);
});

test('dailyProgress increments within the same day', () => {
  const current = { lastStudyDay: TODAY, dailyProgress: 1, dailyGoal: 3 };
  assert.equal(nextDailyProgress({ current, today: TODAY }), 2);
});

test('dailyProgress is capped at the daily goal', () => {
  const current = { lastStudyDay: TODAY, dailyProgress: 3, dailyGoal: 3 };
  assert.equal(nextDailyProgress({ current, today: TODAY }), 3);
});

test('dailyProgress starts at 1 for a first-ever completion (empty lastStudyDay)', () => {
  const current = { lastStudyDay: '', dailyProgress: 0 };
  assert.equal(nextDailyProgress({ current, today: TODAY }), 1);
});

test('dailyProgress falls back to a goal of 3 when dailyGoal is missing', () => {
  const current = { lastStudyDay: TODAY, dailyProgress: 3 };
  assert.equal(nextDailyProgress({ current, today: TODAY }), 3);
});
