import assert from 'node:assert/strict';
import test from 'node:test';

import { defaultProgress, mergeLearningState } from '../server/lib/progress.js';

test('guest import merges learning data and clamps counters', () => {
  const server = defaultProgress({ id: 'u1', email: 'a@b.co', display_name: 'Alan' });
  const merged = mergeLearningState(server, {
    xp: 725,
    completedLessons: ['r1'],
    knowledgeStates: [{ id: 'r1:1', lastReviewedAt: '2026-08-03T10:00:00Z' }],
    placementLevel: 4,
  }, { importGuest: true });
  assert.equal(merged.xp, 725);
  assert.equal(merged.level, 2);
  assert.deepEqual(merged.completedLessons, ['r1']);
  assert.equal(merged.knowledgeStates.length, 1);
  assert.equal(merged.placementLevel, 4);
});

test('normal sync cannot overwrite authoritative xp or completed lessons', () => {
  const server = {
    ...defaultProgress({ id: 'u1', email: 'a@b.co', display_name: 'Alan' }),
    xp: 100,
    completedLessons: ['r1'],
  };
  const merged = mergeLearningState(server, { xp: 999999, completedLessons: ['r2'] });
  assert.equal(merged.xp, 100);
  assert.deepEqual(merged.completedLessons, ['r1']);
});
