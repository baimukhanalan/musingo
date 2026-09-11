import fs from 'node:fs';
import path from 'node:path';

const sourcePath = path.join(
  process.cwd(),
  'docs/research/competitors/muslingo-competitive-sources-2026-09-11.csv',
);
const summaryPath = path.join(
  process.cwd(),
  'docs/research/competitors/muslingo-competitive-source-verification-2026-09-11.json',
);

function parseCsv(text) {
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
      row.push(field);
      rows.push(row);
      row = [];
      field = '';
    } else if (char !== '\r') field += char;
  }
  if (field || row.length) rows.push([...row, field]);
  const [headers, ...values] = rows;
  return {
    headers,
    rows: values.filter((cells) => cells.some(Boolean)).map((cells) =>
      Object.fromEntries(headers.map((header, index) => [header, cells[index] ?? '']))),
  };
}

function csvCell(value) {
  const text = String(value ?? '');
  return /[",\n\r]/.test(text) ? `"${text.replaceAll('"', '""')}"` : text;
}

async function statusFor(url) {
  const options = {
    redirect: 'follow',
    headers: { 'user-agent': 'Mozilla/5.0 MuslingoResearch/1.0' },
    signal: AbortSignal.timeout(15000),
  };
  try {
    let response = await fetch(url, { ...options, method: 'HEAD' });
    if (response.status === 405) {
      response = await fetch(url, { ...options, method: 'GET' });
    }
    return String(response.status);
  } catch (error) {
    return error?.name === 'TimeoutError' ? 'timeout' : 'network_error';
  }
}

const { headers, rows } = parseCsv(fs.readFileSync(sourcePath, 'utf8'));
const stableStatus = (status) => /^(?:2\d\d|3\d\d|400|401|402|403|404|405|410)$/.test(status);
const statusByUrl = new Map(rows
  .filter((row) => stableStatus(row.http_status))
  .map((row) => [row.canonical_url, row.http_status]));
const pendingUrls = [...new Set(rows
  .filter((row) => !stableStatus(row.http_status))
  .map((row) => row.canonical_url))];
let cursor = 0;
const workers = Array.from({ length: 8 }, async () => {
  while (cursor < pendingUrls.length) {
    const url = pendingUrls[cursor];
    cursor += 1;
    statusByUrl.set(url, await statusFor(url));
  }
});
await Promise.all(workers);
for (const row of rows) row.http_status = statusByUrl.get(row.canonical_url);
fs.writeFileSync(
  sourcePath,
  `${headers.join(',')}\n${rows.map((row) => headers.map((key) => csvCell(row[key])).join(',')).join('\n')}\n`,
);

const counts = {};
for (const status of statusByUrl.values()) counts[status] = (counts[status] ?? 0) + 1;
const summary = {
  verificationDate: '2026-09-11',
  checked: statusByUrl.size,
  method: 'HTTP HEAD with redirect following; GET fallback when HEAD returns 405; stable prior same-day results are preserved on rerun.',
  counts,
};
fs.writeFileSync(summaryPath, `${JSON.stringify(summary, null, 2)}\n`);
console.log(JSON.stringify(summary));
