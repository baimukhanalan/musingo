import { readdir, readFile, writeFile } from 'node:fs/promises';
import { dirname, extname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const researchDir = resolve(root, 'docs/research');
const agentsDir = resolve(researchDir, 'agents');

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
      } else if (char === '"') {
        quoted = false;
      } else {
        field += char;
      }
    } else if (char === '"') {
      quoted = true;
    } else if (char === ',') {
      row.push(field);
      field = '';
    } else if (char === '\n') {
      row.push(field.replace(/\r$/, ''));
      if (row.some((value) => value.trim())) rows.push(row);
      row = [];
      field = '';
    } else {
      field += char;
    }
  }
  if (field || row.length) {
    row.push(field);
    rows.push(row);
  }
  return rows;
};

const normalizeUrl = (raw) => {
  try {
    const url = new URL(raw.trim());
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

const registry = new Map();
const add = ({ url, title = '', category = '', reuse = '', sourceFile }) => {
  const normalized = normalizeUrl(url);
  if (!normalized) return;
  const current = registry.get(normalized) ?? {
    url: normalized,
    title: '',
    categories: new Set(),
    reuseNotes: new Set(),
    sourceFiles: new Set(),
  };
  if (!current.title && title.trim()) current.title = title.trim();
  if (category.trim()) current.categories.add(category.trim());
  if (reuse.trim()) current.reuseNotes.add(reuse.trim());
  current.sourceFiles.add(sourceFile);
  registry.set(normalized, current);
};

const metadataPath = resolve(
  researchDir,
  'islamic-source-metadata-2026-09-10.json',
);
const metadata = JSON.parse(await readFile(metadataPath, 'utf8'));
for (const row of metadata.rows) {
  add({
    url: row.finalUrl || row.url,
    title: row.title || row.name,
    category: row.category,
    reuse: row.reuse,
    sourceFile: 'islamic-source-metadata-2026-09-10.json',
  });
}

const agentFiles = (await readdir(agentsDir)).sort();
for (const filename of agentFiles) {
  const path = resolve(agentsDir, filename);
  const extension = extname(filename).toLowerCase();
  const text = extension === '.xlsx' ? '' : await readFile(path, 'utf8');
  if (extension === '.md') {
    const links = text.matchAll(/\[([^\]]+)]\((https?:\/\/[^)\s]+)\)/g);
    for (const match of links) {
      add({
        url: match[2],
        title: match[1],
        category: 'research-reference',
        sourceFile: `agents/${filename}`,
      });
    }
  }
  if (extension === '.csv') {
    const rows = parseCsv(text);
    if (rows.length < 2) continue;
    const headers = rows[0].map((header) => header.trim());
    const urlColumns = headers
      .map((header, index) => ({ header, index }))
      .filter(({ header }) => /url|link/i.test(header));
    const titleIndex = headers.findIndex((header) =>
      /provider|publisher|name|title|offering|page/i.test(header),
    );
    const categoryIndex = headers.findIndex((header) => /category/i.test(header));
    const reuseIndex = headers.findIndex((header) => /reuse|license/i.test(header));
    for (const row of rows.slice(1)) {
      for (const { index } of urlColumns) {
        if (!row[index]?.startsWith('http')) continue;
        add({
          url: row[index],
          title: titleIndex >= 0 ? row[titleIndex] : '',
          category: categoryIndex >= 0 ? row[categoryIndex] : '',
          reuse: reuseIndex >= 0 ? row[reuseIndex] : '',
          sourceFile: `agents/${filename}`,
        });
      }
    }
  }
}

const rows = [...registry.values()]
  .map((row) => ({
    ...row,
    categories: [...row.categories].sort(),
    reuseNotes: [...row.reuseNotes].sort(),
    sourceFiles: [...row.sourceFiles].sort(),
  }))
  .sort((left, right) => left.url.localeCompare(right.url));

const jsonPath = resolve(researchDir, 'unified-source-registry-2026-09-10.json');
await writeFile(
  jsonPath,
  `${JSON.stringify({ generatedAt: new Date().toISOString(), rows }, null, 2)}\n`,
);

const csvEscape = (value) =>
  `"${String(value ?? '').replaceAll('"', '""')}"`;
const csvRows = [
  ['url', 'title', 'categories', 'reuse_notes', 'source_files'],
  ...rows.map((row) => [
    row.url,
    row.title,
    row.categories.join('; '),
    row.reuseNotes.join('; '),
    row.sourceFiles.join('; '),
  ]),
];
const csvPath = resolve(researchDir, 'unified-source-registry-2026-09-10.csv');
await writeFile(
  csvPath,
  `${csvRows.map((row) => row.map(csvEscape).join(',')).join('\n')}\n`,
);

console.log(`Merged ${rows.length} unique URLs into ${jsonPath}`);
