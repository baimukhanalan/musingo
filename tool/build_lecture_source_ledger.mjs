import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const planPath = path.join(root, 'docs/content/approved-570-curriculum-plan.json');
const batchPath = path.join(root, 'docs/content/lecture-next-batch-2026-09-26.json');
const outputPath = path.join(root, 'docs/content/lecture-source-ledger-570.json');

export function extractDeclaredUrls(locator) {
  return [...new Set((locator.match(/https:\/\/[^\s)]+/gu) ?? []))];
}

export function extractQuranLocators(locator) {
  // The plan uses both "Quran 16:43; 49:6" and "Tanzil ... 1:1-7".
  // These are claimed locators, not a verification of the verse text or meaning.
  const result = [];
  const pattern = /(?<![\d.])(\d{1,3}):(\d{1,3})(?:-(\d{1,3}))?(?!\d)/gu;
  for (const match of locator.matchAll(pattern)) {
    const chapter = Number(match[1]);
    const start = Number(match[2]);
    const end = Number(match[3] ?? match[2]);
    if (chapter < 1 || chapter > 114 || start < 1 || end < start || end > 286) continue;
    const key = `${chapter}:${start}${end > start ? `-${end}` : ''}`;
    if (!result.some((item) => item.locator === key)) {
      result.push({ locator: key, url: `https://quran.com/${chapter}/${start}`, verification: 'declared_in_plan_not_verse_checked' });
    }
  }
  return result;
}

function sourceGaps(module) {
  const locator = module.source_locator ?? '';
  const gaps = ['full_lecture_manuscript_missing', 'module_claims_not_individually_verified', 'human_religious_and_language_review_required'];
  if (!extractDeclaredUrls(locator).length && !extractQuranLocators(locator).length) {
    gaps.push('source_url_or_exact_verse_locator_missing');
  }
  if (/exact chapter\/page mapping pending|examples and locators pending/i.test(locator)) {
    gaps.push('exact_tajwid_chapter_page_and_example_mapping_missing');
  }
  if (/перевод\/тафсир не выбран/i.test(locator)) {
    gaps.push('translation_and_tafsir_edition_not_selected');
  }
  if (/selected verbatim from Tanzil after review/i.test(locator)) {
    gaps.push('quran_examples_not_yet_selected_or_checked');
  }
  if (/not yet selected|to be fixed|locator pending/i.test(locator)) {
    gaps.push('additional_named_edition_or_locator_pending');
  }
  if (module.track === 'Tajwid') gaps.push('qualified_tajwid_teacher_and_audio_review_required');
  if (module.track === 'Quran') gaps.push('canonical_text_checksum_and_recitation_rights_required');
  return gaps;
}

export function buildLedger(plan, batch) {
  const modules = plan.modules ?? [];
  const byId = new Map((batch.modules ?? []).map((item) => [item.module_id, item]));
  if (modules.length !== 570 || new Set(modules.map((item) => item.module_id)).size !== 570) {
    throw new Error('Expected exactly 570 unique module IDs');
  }
  for (const item of batch.modules ?? []) {
    if (!modules.some((module) => module.module_id === item.module_id)) {
      throw new Error(`Batch module absent from plan: ${item.module_id}`);
    }
  }
  return {
    schema_version: 1,
    meaning: 'Editorial source-readiness ledger, not approval or proof of 570 lectures',
    module_count: modules.length,
    modules: modules.map((module) => {
      const batchItem = byId.get(module.module_id);
      return {
        module_id: module.module_id,
        track: module.track,
        strand: module.strand,
        title: module.module_title,
        source_provenance: 'approved-570-curriculum-plan.json source_locator field',
        declared_locator: module.source_locator,
        declared_urls: extractDeclaredUrls(module.source_locator ?? '').map((url) => ({
          url,
          verification: 'declared_in_plan_not_page_checked_for_this_module',
        })),
        declared_quran_locators: extractQuranLocators(module.source_locator ?? ''),
        rights: {
          plan_note: module.rights_status,
          external_text_audio_translation_cleared_for_new_lecture: false,
          original_manuscript_only_until_review: true,
        },
        open_gates: sourceGaps(module),
        curated_next_batch: batchItem ?? null,
        lecture_status: 'no_human_approved_lecture',
      };
    }),
  };
}

export function loadLedgerInputs() {
  return {
    plan: JSON.parse(fs.readFileSync(planPath, 'utf8')),
    batch: JSON.parse(fs.readFileSync(batchPath, 'utf8')),
  };
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const ledger = buildLedger(...Object.values(loadLedgerInputs()));
  const output = `${JSON.stringify(ledger, null, 2)}\n`;
  if (process.argv.includes('--check')) {
    if (!fs.existsSync(outputPath) || fs.readFileSync(outputPath, 'utf8') !== output) {
      process.stderr.write('Lecture source ledger is missing or stale. Regenerate it.\n');
      process.exitCode = 1;
    }
  } else {
    fs.writeFileSync(outputPath, output);
    process.stdout.write(`Wrote ${ledger.module_count} source-readiness records to ${outputPath}\n`);
  }
}
