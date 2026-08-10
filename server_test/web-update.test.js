import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const root = new URL('../', import.meta.url);

test('legacy Flutter worker retires stale app caches and reloads clients', async () => {
  const worker = await readFile(new URL('web/flutter_service_worker.js', root), 'utf8');
  assert.match(worker, /flutter-app-cache/);
  assert.match(worker, /skipWaiting/);
  assert.match(worker, /registration\.unregister/);
  assert.match(worker, /client\.navigate\(client\.url\)/);
  assert.doesNotMatch(worker, /addEventListener\('fetch'/);
});

test('web startup updates only the legacy root worker', async () => {
  const index = await readFile(new URL('web/index.html', root), 'utf8');
  assert.match(index, /registration\.scope === rootScope/);
  assert.match(index, /flutter_service_worker\.js/);
  assert.match(index, /muslingo-root-worker-retired/);
  assert.match(index, /scope: pushScope/);
});
