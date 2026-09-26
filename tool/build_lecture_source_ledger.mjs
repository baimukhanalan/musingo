import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';
import { lectureWordCount } from './audit_lecture_readiness.mjs';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const planPath = path.join(root, 'docs/content/approved-570-curriculum-plan.json');
const batchPath = path.join(root, 'docs/content/lecture-next-batch-2026-09-26.json');
const urlChecksPath = path.join(root, 'docs/content/lecture-source-url-checks-2026-09-27.json');
const lectureDir = path.join(root, 'docs/content/lectures');
const outputPath = path.join(root, 'docs/content/lecture-source-ledger-570.json');

export function extractDeclaredUrls(locator) {
  // A few plan fields separate parenthesized URLs with semicolons. The
  // semicolon is prose punctuation, not part of a `.jsp` address.
  return [...new Set((locator.match(/https:\/\/[^\s)]+/gu) ?? [])
    .map((raw) => raw.replace(/[;,]+$/u, '')))];
}

export function declaredSourceRole(url) {
  const host = new URL(url).hostname;
  if (host === 'tanzil.net') return 'canonical_text_project_or_license_not_a_verified_verse_extract';
  if (host === 'api-docs.quran.com') return 'api_or_rights_documentation_not_verse_evidence';
  if (host === 'corpus.quran.com') return 'linguistic_reference_not_independent_religious_ruling';
  if (host === 'qurancomplex.gov.sa') return 'tajwid_book_landing_page_not_a_chapter_page_locator';
  if (host === 'www.cambridgeinternational.org' || host === 'yaqeeninstitute.org') {
    return 'pedagogical_benchmark_not_a_primary_religious_source';
  }
  return 'role_unclassified_requires_editorial_check';
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

function sourceGaps(module, manuscript) {
  const locator = module.source_locator ?? '';
  const gaps = ['module_claims_not_individually_verified', 'human_religious_and_language_review_required'];
  if (!manuscript) gaps.unshift('full_lecture_manuscript_missing');
  else gaps.unshift('draft_manuscript_not_expert_reviewed');
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
  if (module.track === 'Arabic' && !extractQuranLocators(locator).length) {
    gaps.push('module_specific_quran_word_or_example_locators_not_recorded');
  }
  if (/not yet selected|to be fixed|locator pending/i.test(locator)) {
    gaps.push('additional_named_edition_or_locator_pending');
  }
  if (module.track === 'Tajwid') gaps.push('qualified_tajwid_teacher_and_audio_review_required');
  if (module.track === 'Quran') gaps.push('canonical_text_checksum_and_recitation_rights_required');
  return gaps;
}

export function buildLedger(plan, batch, lectures = [], urlChecks = { urls: [] }) {
  const modules = plan.modules ?? [];
  const byId = new Map((batch.modules ?? []).map((item) => [item.module_id, item]));
  const manuscripts = new Map(lectures.map((lecture) => [lecture.module_id, lecture]));
  const byUrl = new Map((urlChecks.urls ?? []).map((item) => [item.url, item]));
  if (modules.length !== 570 || new Set(modules.map((item) => item.module_id)).size !== 570) {
    throw new Error('Expected exactly 570 unique module IDs');
  }
  for (const item of batch.modules ?? []) {
    if (!modules.some((module) => module.module_id === item.module_id)) {
      throw new Error(`Batch module absent from plan: ${item.module_id}`);
    }
  }
  for (const lecture of lectures) {
    if (!modules.some((module) => module.module_id === lecture.module_id)) {
      throw new Error(`Lecture draft absent from plan: ${lecture.module_id}`);
    }
  }
  const declaredUrls = new Set(modules.flatMap((module) => extractDeclaredUrls(module.source_locator ?? '')));
  for (const url of declaredUrls) {
    if (!byUrl.has(url)) throw new Error(`Declared source URL lacks an availability check: ${url}`);
  }
  for (const url of byUrl.keys()) {
    if (!declaredUrls.has(url)) throw new Error(`Availability check URL is not in plan: ${url}`);
  }
  const reuseCount = new Map();
  for (const module of modules) {
    const key = `${module.track}\0${module.source_locator}`;
    reuseCount.set(key, (reuseCount.get(key) ?? 0) + 1);
  }
  return {
    schema_version: 2,
    meaning: 'Editorial source-readiness ledger, not approval or proof of 570 lectures',
    module_count: modules.length,
    modules: modules.map((module) => {
      const batchItem = byId.get(module.module_id);
      const manuscript = manuscripts.get(module.module_id);
      const declaredQuranLocators = extractQuranLocators(module.source_locator ?? '');
      return {
        module_id: module.module_id,
        track: module.track,
        strand: module.strand,
        title: module.module_title,
        source_provenance: 'approved-570-curriculum-plan.json source_locator field',
        declared_locator: module.source_locator,
        locator_reused_by_modules_in_same_track: reuseCount.get(`${module.track}\0${module.source_locator}`),
        locator_precision: module.track === 'Tajwid'
          ? 'book_landing_page_only_exact_chapter_page_missing'
          : module.track === 'Quran'
            ? 'exact_verse_range_declared_meaning_source_not_selected'
            : module.track === 'Foundations/Academy'
              ? 'strand_shared_verse_locator_not_module_claim_mapping'
              : 'linguistic_documentation_or_example_locator_pending',
        declared_urls: extractDeclaredUrls(module.source_locator ?? '').map((url) => ({
          url,
          role: declaredSourceRole(url),
          page_availability: byUrl.get(url).status,
          page_checked_at: byUrl.get(url).checked_at,
          source_to_claim_approval: 'not_human_verified_for_this_module',
        })),
        declared_quran_locators: declaredQuranLocators,
        rights: {
          plan_note: module.rights_status,
          external_text_audio_translation_cleared_for_new_lecture: false,
          original_manuscript_only_until_review: true,
        },
        editorial_review: {
          prior_plan_owner_note: module.review_status,
          lecture_religious_expert: 'not_completed_for_new_manuscript',
          lecture_language: 'not_completed_for_new_manuscript',
          lecture_rights: 'not_completed_for_new_manuscript',
          source_to_objective_alignment: 'not_human_verified',
        },
        manuscript: manuscript ? {
          status: manuscript.status,
          locale: manuscript.locale,
          word_count: lectureWordCount(manuscript),
        } : null,
        open_gates: sourceGaps(module, manuscript),
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
    urlChecks: JSON.parse(fs.readFileSync(urlChecksPath, 'utf8')),
    lectures: fs.readdirSync(lectureDir)
      .filter((name) => name.endsWith('.json'))
      .map((name) => JSON.parse(fs.readFileSync(path.join(lectureDir, name), 'utf8'))),
  };
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const { plan, batch, lectures, urlChecks } = loadLedgerInputs();
  const ledger = buildLedger(plan, batch, lectures, urlChecks);
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
