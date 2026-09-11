import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';

const catalog = JSON.parse(
  fs.readFileSync(
    new URL('../docs/content/approved-570-curriculum-plan.json', import.meta.url),
  ),
);

test('curriculum contains the approved target distribution of 570 modules', () => {
  assert.equal(catalog.total_modules, 570);
  assert.deepEqual(catalog.target_counts, {
    Quran: 150,
    Arabic: 170,
    Tajwid: 70,
    'Foundations/Academy': 180,
  });
  assert.equal(
    new Set(catalog.modules.map((item) => item.module_id)).size,
    570,
  );
});

test('draft modules cannot masquerade as published content', () => {
  for (const module of catalog.modules) {
    assert.equal(module.publication_status, 'blocked_until_review');
    assert.match(
      module.review_status,
      /(not publication-approved|blocked for publication)/i,
    );
    assert.ok(module.learning_objective.length > 35);
    assert.ok(module.source_locator.length > 0);
    assert.ok(module.rights_status.length > 0);
    assert.ok(module.speaker_domain.length > 0);
  }
});
