import assert from 'node:assert/strict';
import fs from 'node:fs';
import test from 'node:test';
import {
  buildLedger,
  extractDeclaredUrls,
  extractQuranLocators,
  loadLedgerInputs,
} from '../tool/build_lecture_source_ledger.mjs';

test('ledger covers every module exactly once with provenance and rights gates', () => {
  const { plan, batch } = loadLedgerInputs();
  const ledger = buildLedger(plan, batch);
  assert.equal(ledger.module_count, 570);
  assert.equal(new Set(ledger.modules.map((module) => module.module_id)).size, 570);
  for (const module of ledger.modules) {
    assert.ok(module.declared_locator);
    assert.ok(module.source_provenance);
    if (!module.declared_urls.length && !module.declared_quran_locators.length) {
      assert.ok(module.open_gates.includes('source_url_or_exact_verse_locator_missing'));
    }
    assert.equal(module.rights.external_text_audio_translation_cleared_for_new_lecture, false);
    assert.equal(module.lecture_status, 'no_human_approved_lecture');
  }
  const byId = Object.fromEntries(ledger.modules.map((module) => [module.module_id, module]));
  assert.deepEqual(byId['QUR-001'].declared_quran_locators.map((item) => item.locator), ['1:1-7']);
  assert.ok(byId['QUR-001'].open_gates.includes('translation_and_tafsir_edition_not_selected'));
  assert.ok(byId['ARB-001'].open_gates.includes('quran_examples_not_yet_selected_or_checked'));
  assert.ok(byId['TAJ-001'].open_gates.includes('exact_tajwid_chapter_page_and_example_mapping_missing'));
  assert.deepEqual(byId['FND-001'].declared_quran_locators.map((item) => item.locator), ['16:43', '49:6']);
  assert.ok(byId['ARB-169'].open_gates.includes('source_url_or_exact_verse_locator_missing'));
  assert.ok(byId['ARB-170'].open_gates.includes('source_url_or_exact_verse_locator_missing'));
  assert.equal(ledger.modules.filter((module) => module.open_gates.includes('source_url_or_exact_verse_locator_missing')).length, 2);
  assert.equal(ledger.modules.filter((module) => module.curated_next_batch).length, 4);
});

test('source parsing does not silently turn publisher URLs into Quran verses', () => {
  assert.deepEqual(extractQuranLocators('Tanzil v1.1 1:1-7 (https://tanzil.net/docs/download)'), [
    { locator: '1:1-7', url: 'https://quran.com/1/1', verification: 'declared_in_plan_not_verse_checked' },
  ]);
  assert.deepEqual(extractDeclaredUrls('A (https://example.org/a); B (https://example.org/a)'), ['https://example.org/a']);
});

test('checked-in ledger stays deterministic and matches source inputs', () => {
  const { plan, batch } = loadLedgerInputs();
  const expected = `${JSON.stringify(buildLedger(plan, batch), null, 2)}\n`;
  const actual = fs.readFileSync(new URL('../docs/content/lecture-source-ledger-570.json', import.meta.url), 'utf8');
  assert.equal(actual, expected);
});
