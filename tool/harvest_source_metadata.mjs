import { readFile, writeFile } from 'node:fs/promises';
import { dirname, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const inputPath = resolve(root, 'docs/research/islamic-source-seeds.json');
const outputPath = resolve(
  root,
  'docs/research/islamic-source-metadata-2026-09-10.json',
);
const seeds = JSON.parse(await readFile(inputPath, 'utf8'));

const decodeEntities = (value = '') => value
  .replaceAll('&amp;', '&')
  .replaceAll('&quot;', '"')
  .replaceAll('&#39;', "'")
  .replaceAll('&lt;', '<')
  .replaceAll('&gt;', '>')
  .replace(/\s+/g, ' ')
  .trim();

const meta = (html, key) => {
  const escaped = key.replace(/[.*+?^${}()|[\]\\]/g, '\\$&');
  const patterns = [
    new RegExp(`<meta[^>]+(?:name|property)=["']${escaped}["'][^>]+content=["']([^"']*)["'][^>]*>`, 'i'),
    new RegExp(`<meta[^>]+content=["']([^"']*)["'][^>]+(?:name|property)=["']${escaped}["'][^>]*>`, 'i'),
  ];
  for (const pattern of patterns) {
    const match = html.match(pattern);
    if (match) return decodeEntities(match[1]);
  }
  return '';
};

const harvest = async (seed) => {
  const controller = new AbortController();
  const timeout = setTimeout(() => controller.abort(), 15000);
  try {
    const response = await fetch(seed.url, {
      redirect: 'follow',
      signal: controller.signal,
      headers: {
        'accept': 'text/html,application/xhtml+xml',
        'user-agent': 'MuslingoContentResearch/1.0 (+https://muslingo-mobile.vercel.app)',
      },
    });
    const contentType = response.headers.get('content-type') ?? '';
    const html = contentType.includes('text/html') ? await response.text() : '';
    const title = decodeEntities(
      meta(html, 'og:title') || html.match(/<title[^>]*>([^<]*)<\/title>/i)?.[1] || seed.name,
    );
    const description = decodeEntities(
      meta(html, 'description') || meta(html, 'og:description'),
    ).slice(0, 800);
    return {
      ...seed,
      fetchedAt: new Date().toISOString(),
      status: response.status,
      finalUrl: response.url,
      title,
      description,
      contentType,
    };
  } catch (error) {
    return {
      ...seed,
      fetchedAt: new Date().toISOString(),
      status: null,
      finalUrl: seed.url,
      title: seed.name,
      description: '',
      contentType: '',
      fetchError: error instanceof Error ? error.message : String(error),
    };
  } finally {
    clearTimeout(timeout);
  }
};

const rows = [];
for (const seed of seeds) {
  rows.push(await harvest(seed));
}

await writeFile(
  outputPath,
  `${JSON.stringify({ generatedAt: new Date().toISOString(), rows }, null, 2)}\n`,
);
console.log(`Harvested ${rows.length} sources into ${outputPath}`);
