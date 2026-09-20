import assert from 'node:assert/strict';
import test from 'node:test';
import { bestKnownStreak, defaultProgress, mergeLearningState, profile } from '../server/lib/progress.js';

const user = { id: 'a', display_name: 'A', email: 'a@example.test' };

test('legacy server streak proves only its known milestone', () => {
  assert.equal(profile({ streak: 30 }, user).bestStreak, 30);
  assert.equal(profile({ streak: 0 }, user).bestStreak, 0);
  assert.equal(profile(null, user).bestStreak, 0);
});

test('broken and newly started streaks preserve the server-owned best', () => {
  const current = { ...defaultProgress(user), streak: 30 };
  const next = { ...current, streak: 1, bestStreak: bestKnownStreak(current, 1) };
  assert.equal(next.bestStreak, 30);
  assert.equal(profile(next, user).bestStreak, 30);
  assert.equal(bestKnownStreak(next, 100), 100);
});

test('sync does not erase or mint best streak from client claims', () => {
  const current = { ...defaultProgress(user), streak: 1, bestStreak: 30 };
  assert.equal(mergeLearningState(current, { bestStreak: 0 }).bestStreak, 30);
  assert.equal(mergeLearningState(current, { bestStreak: 100000 }).bestStreak, 30);
  assert.equal(mergeLearningState(defaultProgress(user), { bestStreak: 100000 }).bestStreak, 0);
  assert.equal(mergeLearningState(defaultProgress(user), { bestStreak: 100000 }, { importGuest: true }).bestStreak, 0);
});

test('different server users do not inherit another profile best streak', () => {
  const a = profile({ streak: 1, bestStreak: 30 }, user);
  const b = profile({}, { ...user, id: 'b' });
  assert.equal(a.bestStreak, 30);
  assert.equal(b.bestStreak, 0);
});
