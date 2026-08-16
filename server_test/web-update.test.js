import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

const root = new URL('../', import.meta.url);

test('web startup updates only the legacy root worker', async () => {
  const index = await readFile(new URL('web/index.html', root), 'utf8');
  assert.match(index, /registration\.scope === rootScope/);
  assert.match(index, /flutter_service_worker\.js/);
  assert.match(index, /muslingo-root-worker-retired/);
  assert.match(index, /scope: pushScope/);
});

test('Vercel never caches Flutter bootstrap and retirement worker', async () => {
  const config = JSON.parse(await readFile(new URL('vercel.json', root), 'utf8'));
  const headerGroups = new Map(config.headers.map((group) => [group.source, group.headers]));
  for (const source of ['/', '/index.html', '/flutter_bootstrap.js', '/flutter_service_worker.js']) {
    const headers = headerGroups.get(source) ?? [];
    const cacheControl = headers.find((header) => header.key === 'Cache-Control');
    assert.equal(cacheControl?.value, 'no-cache, no-store, must-revalidate');
  }
});

test('successful web install is persisted and announced to Flutter', async () => {
  const index = await readFile(new URL('web/index.html', root), 'utf8');
  assert.match(index, /muslingo_app_installed/);
  assert.match(index, /localStorage\.setItem\(installStateKey, 'true'\)/);
  assert.match(index, /runsStandalone\(\) \|\| storedAsInstalled\(\)/);
  assert.match(index, /choice\.outcome === 'accepted'/);
  assert.match(index, /CustomEvent\('muslingo-installed'\)/);
  assert.match(index, /beforeinstallprompt[\s\S]*markInstallAvailable\(\)/);
  assert.match(index, /localStorage\.removeItem\(installStateKey\)/);
});
