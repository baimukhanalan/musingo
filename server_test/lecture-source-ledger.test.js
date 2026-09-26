import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import {
  buildLedger,
  declaredSourceRole,
  extractDeclaredUrls,
  extractQuranLocators,
  loadLedgerInputs,
} from '../tool/build_lecture_source_ledger.mjs';

test('ledger covers every module exactly once with provenance and rights gates', () => {
  const { plan, batch, lectures, urlChecks } = loadLedgerInputs();
  const ledger = buildLedger(plan, batch, lectures, urlChecks);
  assert.equal(ledger.module_count, 570);
  assert.equal(ledger.schema_version, 2);
  assert.equal(new Set(ledger.modules.map((module) => module.module_id)).size, 570);
  for (const module of ledger.modules) {
    assert.ok(module.declared_locator);
    assert.ok(module.source_provenance);
    assert.ok(module.locator_reused_by_modules_in_same_track >= 1);
    assert.ok(module.locator_precision);
    assert.equal(module.editorial_review.source_to_objective_alignment, 'not_human_verified');
    assert.equal(module.editorial_review.lecture_religious_expert, 'not_completed_for_new_manuscript');
    if (!module.declared_urls.length && !module.declared_quran_locators.length) {
      assert.ok(module.open_gates.includes('source_url_or_exact_verse_locator_missing'));
    }
    assert.equal(module.rights.external_text_audio_translation_cleared_for_new_lecture, false);
    assert.equal(module.lecture_status, 'no_human_approved_lecture');
  }
  const byId = Object.fromEntries(ledger.modules.map((module) => [module.module_id, module]));
  assert.deepEqual(byId['QUR-001'].declared_quran_locators.map((item) => item.locator), ['1:1-7']);
  assert.equal(byId['QUR-001'].locator_reused_by_modules_in_same_track, 6);
  assert.equal(byId['QUR-001'].declared_urls[1].role, 'api_or_rights_documentation_not_verse_evidence');
  assert.equal(byId['TAJ-001'].declared_urls[0].page_availability, 'timeout_unverified_not_confirmed_broken');
  assert.equal(byId['QUR-001'].declared_urls[0].source_to_claim_approval, 'not_human_verified_for_this_module');
  assert.ok(byId['QUR-001'].open_gates.includes('translation_and_tafsir_edition_not_selected'));
  assert.ok(byId['ARB-001'].open_gates.includes('quran_examples_not_yet_selected_or_checked'));
  assert.equal(ledger.modules.filter((module) => module.open_gates.includes('module_specific_quran_word_or_example_locators_not_recorded')).length, 170);
  assert.ok(byId['TAJ-001'].open_gates.includes('exact_tajwid_chapter_page_and_example_mapping_missing'));
  assert.equal(byId['TAJ-001'].locator_reused_by_modules_in_same_track, 70);
  assert.deepEqual(byId['FND-001'].declared_quran_locators.map((item) => item.locator), ['16:43', '49:6']);
  assert.ok(byId['ARB-169'].open_gates.includes('source_url_or_exact_verse_locator_missing'));
  assert.ok(byId['ARB-170'].open_gates.includes('source_url_or_exact_verse_locator_missing'));
  assert.equal(ledger.modules.filter((module) => module.open_gates.includes('source_url_or_exact_verse_locator_missing')).length, 2);
  assert.equal(ledger.modules.filter((module) => module.curated_next_batch).length, 4);
  assert.equal(byId['FND-001'].manuscript.status, 'editorial_draft_not_for_publication');
  assert.ok(byId['FND-001'].manuscript.word_count >= 650);
  assert.ok(byId['FND-001'].open_gates.includes('draft_manuscript_not_expert_reviewed'));
  assert.equal(byId['QUR-001'].manuscript.status, 'editorial_draft_not_for_publication');
  assert.equal(byId['ARB-001'].manuscript.status, 'editorial_draft_not_for_publication');
  assert.equal(ledger.modules.filter((module) => module.manuscript).length, 3);
  assert.equal(new Set(ledger.modules.flatMap((module) => module.declared_urls.map((source) => source.url))).size, 12);
});

test('source parsing does not silently turn publisher URLs into Quran verses', () => {
  assert.deepEqual(extractQuranLocators('Tanzil v1.1 1:1-7 (https://tanzil.net/docs/download)'), [
    { locator: '1:1-7', url: 'https://quran.com/1/1', verification: 'declared_in_plan_not_verse_checked' },
  ]);
  assert.deepEqual(extractDeclaredUrls('A (https://example.org/a); B (https://example.org/a)'), ['https://example.org/a']);
  assert.deepEqual(extractDeclaredUrls('A (https://corpus.quran.com/documentation/grammar.jsp; https://corpus.quran.com/treebank.jsp)'), [
    'https://corpus.quran.com/documentation/grammar.jsp',
    'https://corpus.quran.com/treebank.jsp',
  ]);
  assert.equal(declaredSourceRole('https://www.cambridgeinternational.org/0493'), 'pedagogical_benchmark_not_a_primary_religious_source');
});

test('checked-in ledger stays deterministic and matches source inputs', () => {
  const { plan, batch, lectures, urlChecks } = loadLedgerInputs();
  const expected = `${JSON.stringify(buildLedger(plan, batch, lectures, urlChecks), null, 2)}\n`;
  const actual = fs.readFileSync(new URL('../docs/content/lecture-source-ledger-570.json', import.meta.url), 'utf8');
  assert.equal(actual, expected);
});
