import fs from 'node:fs';
import path from 'node:path';
import { fileURLToPath, pathToFileURL } from 'node:url';

const repoRoot = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const planPath = path.join(repoRoot, 'docs/content/approved-570-curriculum-plan.json');
const lectureDir = path.join(repoRoot, 'docs/content/lectures');

export function lectureWordCount(lecture) {
  const text = (lecture.sections ?? [])
    .flatMap((section) => section.paragraphs ?? [])
    .map((paragraph) => paragraph.text ?? '')
    .join(' ')
    .trim();
  return text ? text.split(/\s+/u).length : 0;
}

export function validateLectureDraft(lecture, modules) {
  const errors = [];
  if (!modules.some((module) => module.module_id === lecture.module_id)) {
    errors.push('module_id is not in the 570-module plan');
  }
  if (!['ru', 'kk', 'en', 'ar'].includes(lecture.locale)) {
    errors.push('locale must be one of ru, kk, en, ar');
  }
  if (lecture.status !== 'editorial_draft_not_for_publication') {
    errors.push('a lecture without completed human review must remain an editorial draft');
  }
  if (lectureWordCount(lecture) < 650) {
    errors.push('lecture draft is below 650 words');
  }
  if ((lecture.sections ?? []).length < 4) {
    errors.push('lecture needs at least four substantive sections');
  }
  const sources = lecture.sources ?? [];
  const sourceIds = new Set(sources.map((source) => source.id));
  if (sources.length < 2 || sourceIds.size !== sources.length) {
    errors.push('lecture needs at least two uniquely identified sources');
  }
  for (const source of sources) {
    try {
      const url = new URL(source.url);
      if (url.protocol !== 'https:') errors.push(`${source.id}: source URL must use HTTPS`);
    } catch {
      errors.push(`${source.id}: source URL is invalid`);
    }
    if (!source.locator || !source.rights_note) {
      errors.push(`${source.id}: exact locator and rights note are required`);
    }
  }
  for (const section of lecture.sections ?? []) {
    if (!section.heading || !(section.paragraphs ?? []).length) {
      errors.push('each section needs a heading and paragraphs');
    }
    for (const paragraph of section.paragraphs ?? []) {
      if (!paragraph.text || !Array.isArray(paragraph.source_ids)) {
        errors.push('each paragraph needs text and a source_ids array');
      }
      for (const id of paragraph.source_ids ?? []) {
        if (!sourceIds.has(id)) errors.push(`unknown source reference: ${id}`);
      }
    }
  }
  const review = lecture.review ?? {};
  if (review.approved_at || review.islamic_reviewer || review.language_reviewer || review.rights_reviewer) {
    errors.push('draft review evidence must not be represented as complete');
  }
  return errors;
}

export function auditLectureReadiness({ plan, lectures }) {
  const modules = plan.modules ?? [];
  const planIds = new Set(modules.map((module) => module.module_id));
  const errors = [];
  if (modules.length !== 570 || planIds.size !== 570) {
    errors.push('curriculum plan must contain 570 unique module IDs');
  }
  const draftIds = new Set();
  for (const lecture of lectures) {
    const key = `${lecture.module_id}:${lecture.locale}`;
    if (draftIds.has(key)) errors.push(`duplicate lecture draft: ${key}`);
    draftIds.add(key);
    for (const error of validateLectureDraft(lecture, modules)) {
      errors.push(`${key}: ${error}`);
    }
  }

  const byTrack = Object.fromEntries(
    [...new Set(modules.map((module) => module.track))].map((track) => {
      const trackModules = modules.filter((module) => module.track === track);
      return [track, {
        module_count: trackModules.length,
        unique_source_locators: new Set(trackModules.map((module) => module.source_locator)).size,
        lecture_drafts: lectures.filter((lecture) => trackModules.some((module) => module.module_id === lecture.module_id)).length,
      }];
    }),
  );
  const exactMappingPending = modules.filter((module) =>
    /exact chapter\/page mapping pending|examples and locators pending/i.test(module.source_locator ?? '')
  ).map((module) => module.module_id);
  const noTranslationSelected = modules.filter((module) =>
    /перевод\/тафсир не выбран/i.test(module.source_locator ?? '')
  ).map((module) => module.module_id);
  return {
    plan_modules: modules.length,
    owner_verified_plan_rows: modules.filter((module) => module.publication_status === 'published_owner_verified').length,
    substantive_lecture_drafts: lectures.length,
    human_approved_lectures: 0,
    modules_without_lecture_draft: modules.length - new Set(lectures.map((lecture) => lecture.module_id)).size,
    source_gaps: {
      exact_mapping_pending: exactMappingPending.length,
      translation_or_tafsir_not_selected: noTranslationSelected.length,
    },
    by_track: byTrack,
    errors,
  };
}

export function loadReadinessInputs() {
  const plan = JSON.parse(fs.readFileSync(planPath, 'utf8'));
  const lectures = fs.readdirSync(lectureDir)
    .filter((name) => name.endsWith('.json'))
    .map((name) => JSON.parse(fs.readFileSync(path.join(lectureDir, name), 'utf8')));
  return { plan, lectures };
}

if (process.argv[1] && import.meta.url === pathToFileURL(path.resolve(process.argv[1])).href) {
  const result = auditLectureReadiness(loadReadinessInputs());
  process.stdout.write(`${JSON.stringify(result, null, 2)}\n`);
  if (result.errors.length) process.exitCode = 1;
}
