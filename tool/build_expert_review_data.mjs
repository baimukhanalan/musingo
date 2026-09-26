import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const planPath = path.join(root, 'docs/content/approved-570-curriculum-plan.json');
const ledgerPath = path.join(root, 'docs/content/lecture-source-ledger-570.json');
const lectureDir = path.join(root, 'docs/content/lectures');
const outputPath = path.join(root, 'web/expert-review-data.json');

export function buildExpertReviewData(plan, ledger, lectures) {
  const modules = plan.modules ?? [];
  const sourceRecords = new Map((ledger.modules ?? []).map((item) => [item.module_id, item]));
  const draftRecords = new Map();
  for (const lecture of lectures) {
    if (lecture.status !== 'editorial_draft_not_for_publication') {
      throw new Error(`Unexpected lecture status for ${lecture.module_id}`);
    }
    if (!modules.some((module) => module.module_id === lecture.module_id)) {
      throw new Error(`Draft has no planned module: ${lecture.module_id}`);
    }
    const drafts = draftRecords.get(lecture.module_id) ?? [];
    drafts.push(lecture);
    draftRecords.set(lecture.module_id, drafts);
  }
  if (modules.length !== 570 || sourceRecords.size !== 570) {
    throw new Error('Expert review must cover all 570 unique modules');
  }
  return {
    schema_version: 1,
    notice: 'Research and editorial review only. Published interactive modules are not the same as approved lecture manuscripts.',
    module_count: 570,
    modules: modules.map((module) => {
      const source = sourceRecords.get(module.module_id);
      if (!source) throw new Error(`Missing source record: ${module.module_id}`);
      return {
        id: module.module_id,
        track: module.track,
        strand: module.strand,
        sequence: module.sequence,
        title: module.module_title,
        objective: module.learning_objective,
        prerequisite: module.prerequisite,
        source_locator: module.source_locator,
        locator_precision: source.locator_precision,
        locator_reused_by_modules_in_same_track: source.locator_reused_by_modules_in_same_track,
        rights_status: module.rights_status,
        review_status: module.review_status,
        editorial_review: source.editorial_review,
        declared_urls: source.declared_urls,
        declared_quran_locators: source.declared_quran_locators,
        open_gates: source.open_gates,
        curated_next_batch: source.curated_next_batch,
        lecture_drafts: draftRecords.get(module.module_id) ?? [],
      };
    }),
  };
}

export function loadExpertReviewInputs() {
  return {
    plan: JSON.parse(fs.readFileSync(planPath, 'utf8')),
    ledger: JSON.parse(fs.readFileSync(ledgerPath, 'utf8')),
    lectures: fs.readdirSync(lectureDir)
      .filter((name) => name.endsWith('.json'))
      .map((name) => JSON.parse(fs.readFileSync(path.join(lectureDir, name), 'utf8'))),
  };
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const output = `${JSON.stringify(buildExpertReviewData(...Object.values(loadExpertReviewInputs())))}\n`;
  if (process.argv.includes('--check')) {
    if (!fs.existsSync(outputPath) || fs.readFileSync(outputPath, 'utf8') !== output) {
      throw new Error('Expert review data is stale. Run node tool/build_expert_review_data.mjs');
    }
  } else {
    fs.writeFileSync(outputPath, output);
    process.stdout.write(`Prepared review data for 570 modules: ${outputPath}\n`);
  }
}
