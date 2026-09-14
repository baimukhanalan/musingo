import assert from 'node:assert/strict';
import test from 'node:test';

import {
  defaultProgress,
  mergeCurriculumProgress,
  mergeLearningState,
} from '../server/lib/progress.js';

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

test('mentor profile sync is bounded and excludes unknown fields', () => {
  const server = defaultProgress({ id: 'u1', display_name: 'Alan', email: 'a@example.com' });
  const merged = mergeLearningState(server, {
    mentorProfile: {
      preferredName: 'Алан',
      currentFocus: 'таджвид',
      tone: 'focused',
      preferredSessionMinutes: 99,
      secret: 'must not persist',
      memories: [{ id: 'm1', text: 'Лучше учусь утром', createdAt: '2026-09-14T00:00:00Z' }],
    },
  });
  assert.equal(merged.mentorProfile.preferredName, 'Алан');
  assert.equal(merged.mentorProfile.preferredSessionMinutes, 30);
  assert.equal(merged.mentorProfile.secret, undefined);
  assert.equal(merged.mentorProfile.memories.length, 1);
});

test('curriculum progress merges across devices without minting rewards', () => {
  const merged = mergeCurriculumProgress(
    {
      completedModuleIds: ['QUR-001'],
      stepByModuleId: { 'QUR-001': 4, 'ARB-001': 2 },
      masteryByModuleId: { 'QUR-001': 90 },
      lastModuleId: 'ARB-001',
      lastActivityAt: '2026-09-14T08:00:00.000Z',
    },
    {
      completedModuleIds: ['ARB-001', 'FAKE-999'],
      stepByModuleId: { 'ARB-001': 4, 'TAJ-001': 99 },
      masteryByModuleId: { 'ARB-001': 100, 'QUR-999': 100 },
      lastModuleId: 'ARB-001',
      lastActivityAt: '2026-09-14T09:00:00.000Z',
    },
  );
  assert.deepEqual(merged.completedModuleIds, ['QUR-001', 'ARB-001']);
  assert.equal(merged.stepByModuleId['ARB-001'], 4);
  assert.equal(merged.stepByModuleId['TAJ-001'], 4);
  assert.equal(merged.masteryByModuleId['ARB-001'], 100);
  assert.equal(merged.masteryByModuleId['QUR-999'], undefined);
  assert.equal(merged.lastModuleId, 'ARB-001');
});
