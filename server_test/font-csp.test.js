import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const config = JSON.parse(await readFile(new URL('../vercel.json', import.meta.url), 'utf8'));
const policy = config.headers
  .find((group) => group.source === '/(.*)')?.headers
  .find((header) => header.key.toLowerCase() === 'content-security-policy')?.value;
assert.ok(policy, 'The global response must carry an enforced CSP');
const directives = new Map(policy.split(';').map((part) => {
  const [name, ...sources] = part.trim().split(/\s+/);
  return [name, sources];
}));

test('Flutter fallback fonts are allowed for both fetch and font loading', () => {
  // CanvasKit fetches fallback font bytes; DOM font loading uses font-src.
  // www.gstatic.com (the engine CDN) does not allow fonts.gstatic.com.
  assert.deepEqual(directives.get('font-src'), [
    "'self'", 'data:', 'https://fonts.gstatic.com',
  ]);
  assert.deepEqual(directives.get('connect-src'), [
    "'self'",
    'https://api.alquran.cloud',
    'https://alquran.api.alislam.ru',
    'https://server8.mp3quran.net',
    'https://cdn.islamic.network',
    'https://everyayah.com',
    'https://www.gstatic.com',
    'https://fonts.gstatic.com',
  ]);
});

test('font fallback permission does not broaden other CSP directives', () => {
  const remaining = new Map(directives);
  remaining.delete('font-src');
  remaining.delete('connect-src');
  assert.deepEqual(Object.fromEntries(remaining), {
    'default-src': ["'self'"],
    'base-uri': ["'self'"],
    'object-src': ["'none'"],
    'frame-ancestors': ["'none'"],
    'form-action': ["'self'"],
    'script-src': ["'self'", "'wasm-unsafe-eval'", "'unsafe-inline'", 'https://www.gstatic.com'],
    'style-src': ["'self'", "'unsafe-inline'"],
    'img-src': ["'self'", 'data:', 'blob:', 'https://cdn.islamic.network', 'https://everyayah.com'],
    'media-src': ["'self'", 'blob:', 'https://cdn.islamic.network', 'https://everyayah.com', 'https://server8.mp3quran.net'],
    'worker-src': ["'self'", 'blob:'],
    'manifest-src': ["'self'"],
  });
});
