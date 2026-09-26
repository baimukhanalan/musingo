import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import {
  buildExpertReviewData,
  loadExpertReviewInputs,
} from '../tool/build_expert_review_data.mjs';

test('expert review package includes every topic without inventing lecture approval', () => {
  const data = buildExpertReviewData(...Object.values(loadExpertReviewInputs()));
  assert.equal(data.module_count, 570);
  assert.equal(data.modules.length, 570);
  assert.equal(new Set(data.modules.map((module) => module.id)).size, 570);
  assert.ok(data.modules.every((module) => module.source_locator && Array.isArray(module.open_gates)));
  assert.ok(data.modules.every((module) => module.lecture_drafts.every(
    (draft) => draft.status === 'editorial_draft_not_for_publication' && !draft.review?.approved_at,
  )));
  assert.deepEqual(
    data.modules.filter((module) => module.lecture_drafts.length).map((module) => module.id).sort(),
    ['ARB-001', 'FND-001', 'QUR-001'],
  );
});

test('public review data is deterministic and current', () => {
  const expected = `${JSON.stringify(buildExpertReviewData(...Object.values(loadExpertReviewInputs())))}\n`;
  const actual = fs.readFileSync(new URL('../web/expert-review-data.json', import.meta.url), 'utf8');
  assert.equal(actual, expected);
  const html = fs.readFileSync(new URL('../web/expert-review.html', import.meta.url), 'utf8');
  assert.match(html, /expert-review-data\.json/);
  assert.match(html, /автоматической отправки нет/);
});
