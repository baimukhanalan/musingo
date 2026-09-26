import assert from 'node:assert/strict';
import test from 'node:test';
import {
  auditLectureReadiness,
  lectureWordCount,
  loadReadinessInputs,
  validateLectureDraft,
} from '../tool/audit_lecture_readiness.mjs';

test('570-module plan and substantive drafts remain distinct', () => {
  const inputs = loadReadinessInputs();
  const result = auditLectureReadiness(inputs);
  assert.equal(result.plan_modules, 570);
  assert.equal(result.owner_verified_plan_rows, 570);
  assert.equal(result.substantive_lecture_drafts, 3);
  assert.equal(result.human_approved_lectures, 0);
  assert.equal(result.modules_without_lecture_draft, 567);
  assert.equal(result.source_gaps.exact_mapping_pending, 70);
  assert.equal(result.source_gaps.translation_or_tafsir_not_selected, 150);
  assert.deepEqual(result.errors, []);
});

test('three lectures are real-length drafts with precise sources, not publication claims', () => {
  const { plan, lectures } = loadReadinessInputs();
  for (const id of ['FND-001', 'QUR-001', 'ARB-001']) {
    const draft = lectures.find((lecture) => lecture.module_id === id);
    assert.ok(draft);
    assert.ok(lectureWordCount(draft) >= 650);
    assert.equal(draft.status, 'editorial_draft_not_for_publication');
    assert.deepEqual(validateLectureDraft(draft, plan.modules), []);
  }
  const draft = lectures.find((lecture) => lecture.module_id === 'FND-001');
  const corrupted = structuredClone(draft);
  corrupted.sections[0].paragraphs[0].source_ids.push('unknown-source');
  assert.ok(validateLectureDraft(corrupted, plan.modules).some((error) => error.includes('unknown source')));
});
