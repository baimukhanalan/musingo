import { readdir, readFile, writeFile } from 'node:fs/promises';
import { basename, dirname, extname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const researchDir = resolve(root, 'docs/research');
const agentsDir = resolve(researchDir, 'agents');
const stamp = process.argv.includes('--date')
  ? process.argv[process.argv.indexOf('--date') + 1]
  : new Date().toISOString().slice(0, 10);
const shouldVerify = process.argv.includes('--verify');

const generatedPrefixes = [
  'content-source-registry-',
  'content-source-summary-',
  'source-verification-',
  'unified-source-registry-',
];

const csvEscape = (value) =>
  `"${String(value ?? '').replaceAll('"', '""')}"`;

const parseCsv = (text) => {
  const rows = [];
  let row = [];
  let field = '';
  let quoted = false;
  for (let index = 0; index < text.length; index += 1) {
    const char = text[index];
    if (quoted) {
      if (char === '"' && text[index + 1] === '"') {
        field += '"';
        index += 1;
      } else if (char === '"') quoted = false;
      else field += char;
    } else if (char === '"') quoted = true;
    else if (char === ',') {
      row.push(field);
      field = '';
    } else if (char === '\n') {
      row.push(field.replace(/\r$/, ''));
      if (row.some((value) => value.trim())) rows.push(row);
      row = [];
      field = '';
    } else field += char;
  }
  if (field || row.length) {
    row.push(field);
    rows.push(row);
  }
  return rows;
};

const normalizeUrl = (raw) => {
  try {
    const url = new URL(raw.trim().replace(/[.,;:]+$/, ''));
    if (!['http:', 'https:'].includes(url.protocol)) return null;
    url.hash = '';
    for (const key of [...url.searchParams.keys()]) {
      if (key.startsWith('utm_') || ['fbclid', 'gclid'].includes(key)) {
        url.searchParams.delete(key);
      }
    }
    if (url.pathname !== '/') url.pathname = url.pathname.replace(/\/$/, '');
    return url.toString();
  } catch {
    return null;
  }
};

const firstValue = (record, patterns) => {
  for (const [key, value] of Object.entries(record)) {
    if (patterns.some((pattern) => pattern.test(key)) && String(value).trim()) {
      return String(value).trim();
    }
  }
  return '';
};

const inferLanguages = (text) => {
  const value = text.toLowerCase();
  const languages = [];
  if (/kazakh|қазақ|қаз/.test(value)) languages.push('kk');
  if (/russian|русск|рус/.test(value)) languages.push('ru');
  if (/arabic|العربية|араб/.test(value)) languages.push('ar');
  if (/english|англ/.test(value)) languages.push('en');
  if (/urdu|урду/.test(value)) languages.push('ur');
  if (/turkish|türk|турец/.test(value)) languages.push('tr');
  if (/french|français|француз/.test(value)) languages.push('fr');
  return languages.length ? languages : ['unspecified'];
};

const inferFormat = (url, text) => {
  const value = `${url} ${text}`.toLowerCase();
  if (/youtube|youtu\.be|playlist|video/.test(value)) return 'video';
  if (/podcast|audio|mp3|recitation|qari|кари/.test(value)) return 'audio';
  if (/\.pdf(?:$|\?)/.test(value)) return 'pdf';
  if (/api|dataset|corpus|github/.test(value)) return 'data';
  if (/course|curriculum|academy|lesson|program|курс|урок/.test(value)) {
    return 'course';
  }
  if (/app store|google play|apps\.apple|play\.google/.test(value)) return 'app';
  return 'web';
};

const inferTrack = (text) => {
  const value = text.toLowerCase();
  const tracks = [];
  if (/tajw|тадж|makh|махрадж|recitation/.test(value)) tracks.push('tajwid');
  if (/hifz|hafiz|memor|зауч|жаттау/.test(value)) tracks.push('hifz');
  if (/arabic|араб|morph|grammar|vocab|лекс|грамм/.test(value)) tracks.push('arabic');
  if (/quran|коран|құран|surah|ayah|tafsir/.test(value)) tracks.push('quran');
  if (/islamic|ислам|ақида|aqid|fiqh|фикх|seerah|сира|hadith|хадис|adab|ахлак/.test(value)) {
    tracks.push('foundations');
  }
  if (/pedagog|learning|assessment|spaced|adaptive|product|прилож/.test(value)) {
    tracks.push('pedagogy');
  }
  return tracks.length ? [...new Set(tracks)].sort() : ['uncategorized'];
};

const inferRights = (text) => {
  const value = text.toLowerCase();
  if (/prohibit|no reuse|no republication|permission required|all rights|do not copy|не копир/.test(value)) {
    return 'restricted-or-permission-required';
  }
  if (/cc by|creative commons|public domain|open license|mit\b|gpl\b/.test(value)) {
    return 'open-with-conditions';
  }
  if (/embed|link only|official player|benchmark|reference only|research only/.test(value)) {
    return 'reference-or-link-only';
  }
  if (/terms|license|reuse|permission|rights/.test(value)) return 'terms-review-required';
  return 'unknown-review-required';
};

const registry = new Map();
const add = ({ url, title, publisher, language, format, track, rights, notes, sourceFile }) => {
  const normalized = normalizeUrl(url);
  if (!normalized) return;
  const current = registry.get(normalized) ?? {
    url: normalized,
    title: '',
    publisher: '',
    languages: new Set(),
    formats: new Set(),
    tracks: new Set(),
    rightsStatuses: new Set(),
    notes: new Set(),
    sourceFiles: new Set(),
  };
  const context = [title, publisher, language, format, track, rights, notes, sourceFile]
    .filter(Boolean)
    .join(' ');
  if (!current.title && title) current.title = title;
  if (!current.publisher && publisher) current.publisher = publisher;
  for (const item of inferLanguages(`${language} ${context}`)) current.languages.add(item);
  current.formats.add(inferFormat(normalized, `${format} ${context}`));
  for (const item of inferTrack(`${track} ${context}`)) {
    if (item.trim()) current.tracks.add(item.trim().toLowerCase());
  }
  current.rightsStatuses.add(inferRights(`${rights} ${context}`));
  if (rights) current.notes.add(`Rights/reuse note: ${rights}`);
  if (format) current.notes.add(`Source format: ${format}`);
  if (track) current.notes.add(`Source category: ${track}`);
  if (notes) current.notes.add(notes);
  current.sourceFiles.add(sourceFile);
  registry.set(normalized, current);
};

const files = [
  ...(await readdir(researchDir)).map((name) => resolve(researchDir, name)),
  ...(await readdir(agentsDir)).map((name) => resolve(agentsDir, name)),
].filter((path) => {
  const extension = extname(path).toLowerCase();
  return ['.md', '.csv', '.json'].includes(extension)
    && !generatedPrefixes.some((prefix) => basename(path).startsWith(prefix));
});

for (const path of files.sort()) {
  const sourceFile = path.slice(researchDir.length + 1);
  const extension = extname(path).toLowerCase();
  const text = await readFile(path, 'utf8');
  if (extension === '.csv') {
    const parsed = parseCsv(text);
    if (parsed.length < 2) continue;
    const headers = parsed[0].map((value) => value.trim());
    for (const values of parsed.slice(1)) {
      const record = Object.fromEntries(headers.map((header, index) => [header, values[index] ?? '']));
      const title = firstValue(record, [/title/i, /page/i, /artifact/i, /offering/i, /program/i, /resource/i, /name/i]);
      const publisher = firstValue(record, [/publisher/i, /provider/i, /authority/i, /organization/i, /organisation/i]);
      const language = firstValue(record, [/language/i]);
      const format = firstValue(record, [/format/i, /type/i]);
      const track = firstValue(record, [/track/i, /category/i, /subject/i, /domain/i, /direction/i]);
      const rights = firstValue(record, [/reuse/i, /license/i, /rights/i, /copyright/i]);
      const notes = firstValue(record, [/quality/i, /risk/i, /note/i, /use/i, /applic/i, /claim/i]);
      for (const [header, value] of Object.entries(record)) {
        if (!/url|link/i.test(header) || !/^https?:\/\//i.test(value.trim())) continue;
        add({ url: value, title, publisher, language, format, track, rights, notes, sourceFile });
      }
    }
  } else if (extension === '.json') {
    const urlMatches = text.matchAll(/"(?:url|finalUrl|licenseUrl)"\s*:\s*"(https?:\\?\/\\?\/[^"\\]+(?:\\.[^"\\]*)*)"/g);
    for (const match of urlMatches) {
      add({ url: match[1].replaceAll('\\/', '/'), sourceFile });
    }
  } else {
    for (const match of text.matchAll(/\[([^\]]+)]\((https?:\/\/[^)\s]+)\)/g)) {
      add({ url: match[2], title: match[1], sourceFile });
    }
    for (const match of text.matchAll(/(?<!\()https?:\/\/[^\s<>"')]+/g)) {
      add({ url: match[0], sourceFile });
    }
  }
}

const verify = async (row) => {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 12000);
  try {
    const response = await fetch(row.url, {
      redirect: 'follow',
      signal: controller.signal,
      headers: { 'user-agent': 'MuslingoSourceRegistry/1.0 (+metadata-only research)' },
    });
    return {
      httpStatus: response.status,
      reachable: response.ok,
      availabilityClass: response.ok
        ? 'reachable'
        : response.status === 403 || response.status === 401 || response.status === 429
          ? 'access-controlled-or-bot-protected'
          : response.status === 404 || response.status === 410
            ? 'stale-or-removed'
            : response.status >= 500
              ? 'upstream-error'
              : 'other-http-error',
      finalUrl: response.url,
      contentType: response.headers.get('content-type') ?? '',
      lastModified: response.headers.get('last-modified') ?? '',
    };
  } catch (error) {
    return {
      httpStatus: null,
      reachable: false,
      availabilityClass: error.name === 'AbortError'
        ? 'timeout'
        : 'network-or-tls-error',
      finalUrl: row.url,
      contentType: '',
      lastModified: '',
      verificationError: error.name === 'AbortError' ? 'timeout' : error.message,
    };
  } finally {
    clearTimeout(timeout);
  }
};

const baseRows = [...registry.values()]
  .map((row) => {
    const languages = [...row.languages];
    const tracks = [...row.tracks];
    const rightsStatuses = [...row.rightsStatuses];
    return {
      ...row,
      languages: languages.length > 1
        ? languages.filter((value) => value !== 'unspecified').sort()
        : languages,
      formats: [...row.formats].sort(),
      tracks: tracks.length > 1
        ? tracks.filter((value) => value !== 'uncategorized').sort()
        : tracks,
      rightsStatuses: rightsStatuses.length > 1
        ? rightsStatuses.filter((value) => value !== 'unknown-review-required').sort()
        : rightsStatuses,
      notes: [...row.notes].sort(),
      sourceFiles: [...row.sourceFiles].sort(),
    };
  })
  .sort((left, right) => left.url.localeCompare(right.url));

let rows = baseRows;
if (shouldVerify) {
  rows = new Array(baseRows.length);
  let cursor = 0;
  const workers = Array.from({ length: 8 }, async () => {
    while (cursor < baseRows.length) {
      const index = cursor;
      cursor += 1;
      rows[index] = { ...baseRows[index], ...(await verify(baseRows[index])) };
    }
  });
  await Promise.all(workers);
}

const jsonPath = resolve(researchDir, `content-source-registry-${stamp}.json`);
const csvPath = resolve(researchDir, `content-source-registry-${stamp}.csv`);
const summaryPath = resolve(researchDir, `content-source-summary-${stamp}.md`);
await writeFile(jsonPath, `${JSON.stringify({ generatedAt: new Date().toISOString(), metadataOnly: true, rows }, null, 2)}\n`);

const headers = [
  'url', 'title', 'publisher', 'languages', 'formats', 'tracks', 'rights_statuses',
  'http_status', 'reachable', 'final_url', 'content_type', 'last_modified',
  'availability_class', 'verification_error', 'notes', 'source_files',
];
const csvRows = rows.map((row) => [
  row.url, row.title, row.publisher, row.languages.join('; '), row.formats.join('; '),
  row.tracks.join('; '), row.rightsStatuses.join('; '), row.httpStatus ?? '',
  row.reachable ?? '', row.finalUrl ?? '', row.contentType ?? '', row.lastModified ?? '',
  row.availabilityClass ?? '', row.verificationError ?? '', row.notes.join('; '),
  row.sourceFiles.join('; '),
]);
await writeFile(csvPath, `${[headers, ...csvRows].map((row) => row.map(csvEscape).join(',')).join('\n')}\n`);

const count = (selector) => {
  const result = new Map();
  for (const row of rows) {
    const values = selector(row);
    for (const value of Array.isArray(values) ? values : [values]) {
      result.set(value || 'unspecified', (result.get(value || 'unspecified') ?? 0) + 1);
    }
  }
  return [...result.entries()].sort((left, right) => right[1] - left[1]);
};
const table = (items) => items.map(([name, total]) => `| ${name} | ${total} |`).join('\n');
const reachable = shouldVerify ? rows.filter((row) => row.reachable).length : null;
const protectedTotal = shouldVerify
  ? rows.filter((row) => row.availabilityClass === 'access-controlled-or-bot-protected').length
  : null;
const staleTotal = shouldVerify
  ? rows.filter((row) => row.availabilityClass === 'stale-or-removed').length
  : null;
const summary = `# Muslingo content source registry summary\n\n` +
  `This is a metadata-only research index. Public access does not grant permission to copy, adapt, download, or republish material.\n\n` +
  `- Unique source URLs: **${rows.length}**\n` +
  `- Source files indexed: **${new Set(rows.flatMap((row) => row.sourceFiles)).size}**\n` +
  (shouldVerify ? `- Reachable during this snapshot: **${reachable}/${rows.length}**\n` : '') +
  (shouldVerify ? `- Access-controlled or bot-protected: **${protectedTotal}**\n` : '') +
  (shouldVerify ? `- Stale or removed (404/410): **${staleTotal}**\n` : '') +
  `- Rights status still requiring review: **${rows.filter((row) => row.rightsStatuses.includes('unknown-review-required')).length}**\n\n` +
  `## Tracks\n\n| Track | Sources |\n| --- | ---: |\n${table(count((row) => row.tracks))}\n\n` +
  `## Formats\n\n| Format | Sources |\n| --- | ---: |\n${table(count((row) => row.formats))}\n\n` +
  `## Languages\n\n| Language | Sources |\n| --- | ---: |\n${table(count((row) => row.languages))}\n\n` +
  `## Rights classification\n\n| Status | Sources |\n| --- | ---: |\n${table(count((row) => row.rightsStatuses))}\n`;
await writeFile(summaryPath, summary);

console.log(`Indexed ${rows.length} unique source URLs.`);
console.log(jsonPath);
console.log(csvPath);
console.log(summaryPath);
process.exit(0);
