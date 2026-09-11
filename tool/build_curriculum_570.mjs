import fs from 'node:fs';
import path from 'node:path';

const input = path.resolve('docs/content/approved-570-curriculum-plan.csv');
const output = path.resolve('docs/content/approved-570-curriculum-plan.json');

function parseCsv(text) {
  const rows = [];
  let row = [];
  let value = '';
  let quoted = false;
  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    if (quoted) {
      if (char === '"' && text[index + 1] === '"') {
        value += '"';
        index += 1;
      } else if (char === '"') {
        quoted = false;
      } else {
        value += char;
      }
    } else if (char === '"') {
      quoted = true;
    } else if (char === ',') {
      row.push(value);
      value = '';
    } else if (char === '\n') {
      row.push(value.replace(/\r$/, ''));
      rows.push(row);
      row = [];
      value = '';
    } else {
      value += char;
    }
  }
  if (quoted) throw new Error('Unterminated quoted CSV field.');
  if (value || row.length) {
    row.push(value.replace(/\r$/, ''));
    rows.push(row);
  }
  return rows;
}

const rows = parseCsv(fs.readFileSync(input, 'utf8'));
const headers = rows.shift();
const requiredHeaders = [
  'module_id', 'track', 'strand', 'sequence', 'module_title',
  'learning_objective', 'difficulty', 'prerequisite', 'source_locator',
  'rights_status', 'review_status', 'video_need', 'speaker_domain',
];
if (JSON.stringify(headers) !== JSON.stringify(requiredHeaders)) {
  throw new Error('Unexpected curriculum CSV schema.');
}

const modules = rows.map((row, rowIndex) => {
  if (row.length !== headers.length) {
    throw new Error(`Row ${rowIndex + 2} has ${row.length} fields.`);
  }
  const record = Object.fromEntries(
    headers.map((header, index) => [header, row[index].trim()]),
  );
  if (Object.values(record).some((value) => !value)) {
    throw new Error(`Row ${rowIndex + 2} contains an empty required field.`);
  }
  return {
    ...record,
    sequence: Number(record.sequence),
    publication_status: 'blocked_until_review',
  };
});

const counts = Object.fromEntries(
  ['Quran', 'Arabic', 'Tajwid', 'Foundations/Academy'].map((track) => [
    track,
    modules.filter((module) => module.track === track).length,
  ]),
);
if (modules.length !== 570 || counts.Quran !== 150 || counts.Arabic !== 170 ||
    counts.Tajwid !== 70 || counts['Foundations/Academy'] !== 180) {
  throw new Error(`Unexpected curriculum counts: ${JSON.stringify(counts)}`);
}
if (new Set(modules.map((module) => module.module_id)).size !== 570) {
  throw new Error('Curriculum module ids must be unique.');
}
if (new Set(modules.map((module) => module.module_title)).size !== 570) {
  throw new Error('Curriculum module titles must be unique.');
}

const payload = {
  schema_version: 1,
  generated_from: path.relative(process.cwd(), input),
  total_modules: modules.length,
  target_counts: counts,
  publication_policy: {
    default_status: 'blocked_until_review',
    ai_boundary: 'AI may draft structure but cannot approve or publish religious content.',
    required_evidence: [
      'named author', 'resolvable source locators', 'verified rights scope',
      'track-specific expert review', 'language review', 'content hash',
      'media provenance and captions when media is used',
    ],
  },
  modules,
};

fs.writeFileSync(output, `${JSON.stringify(payload)}\n`);
console.log(`Validated and wrote ${modules.length} curriculum modules to ${output}`);
