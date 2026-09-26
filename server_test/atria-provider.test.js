import assert from 'node:assert/strict';
import test from 'node:test';

import { callAtria, hasAtriaKey } from '../server/lib/atria.js';
import { callCoachAI, hasCoachAIKey } from '../server/lib/coach-ai.js';

const envNames = ['ATRIA_API_KEY', 'OPENAI_API_KEY', 'GROQ_API_KEY', 'COACH_AI_PROVIDER'];
const request = { system: 'Return grounded JSON.', user: 'Synthetic QA question.', maxTokens: 500 };
const atriaResponse = (content = '{"reply":"Ready"}') => ({
  ok: true,
  async json() { return { choices: [{ message: { content } }] }; },
});

// Tests cannot send traffic even if developer credentials exist in the shell.
function isolate(t, environment = {}) {
  const previous = Object.fromEntries(envNames.map((name) => [name, process.env[name]]));
  for (const name of envNames) delete process.env[name];
  Object.assign(process.env, environment);
  t.after(() => {
    for (const name of envNames) {
      if (previous[name] === undefined) delete process.env[name];
      else process.env[name] = previous[name];
    }
  });
  t.mock.method(globalThis, 'fetch', async () => {
    throw new Error('Unexpected mocked network request.');
  });
}

function isSanitizedUnavailable(error) {
  assert.equal(error.status, 503);
  assert.equal(error.code, 'coach_unavailable');
  assert.doesNotMatch(String(error), /private-token|private-upstream|Synthetic QA/);
  return true;
}

test('Atria uses the documented endpoint, Bearer key, model and token field', async (t) => {
  isolate(t, { ATRIA_API_KEY: '  private-token  ' });
  let observed;
  globalThis.fetch.mock.mockImplementation(async (url, options) => {
    observed = { url, options };
    return atriaResponse('  {"reply":"Ready"}  ');
  });
  assert.equal(await callAtria(request), '{"reply":"Ready"}');
  assert.equal(observed.url, 'https://api.atria-asi.ai/v1/chat/completions');
  assert.equal(observed.options.method, 'POST');
  assert.equal(observed.options.headers.Authorization, 'Bearer private-token');
  assert.equal(observed.options.headers['Content-Type'], 'application/json');
  assert.equal(observed.options.redirect, 'error');
  assert.ok(observed.options.signal instanceof AbortSignal);
  const body = JSON.parse(observed.options.body);
  assert.deepEqual(body, {
    model: 'Atria-Dawn-Preview',
    messages: [
      { role: 'system', content: request.system },
      { role: 'user', content: request.user },
    ],
    max_completion_tokens: 500,
    stream: false,
  });
  assert.doesNotMatch(observed.options.body, /private-token/);
});

test('Atria token budgets are finite bounded integers', async (t) => {
  isolate(t, { ATRIA_API_KEY: 'private-token' });
  const cases = [[-10, 1], [0, 1], [2.9, 2], ['256', 256], [999999, 4096],
    [NaN, 700], [Infinity, 700], ['bad', 700], [undefined, 700]];
  for (const [input, expected] of cases) {
    globalThis.fetch.mock.mockImplementation(async (_, options) => {
      assert.equal(JSON.parse(options.body).max_completion_tokens, expected);
      return atriaResponse();
    });
    await callAtria({ ...request, maxTokens: input });
  }
});

test('missing or whitespace-only Atria key fails without a network call', async (t) => {
  isolate(t);
  assert.equal(hasAtriaKey(), false);
  await assert.rejects(callAtria(request), isSanitizedUnavailable);
  process.env.ATRIA_API_KEY = '  ';
  assert.equal(hasAtriaKey(), false);
  await assert.rejects(callAtria(request), isSanitizedUnavailable);
  assert.equal(globalThis.fetch.mock.callCount(), 0);
});

test('upstream statuses and network exceptions never disclose upstream details', async (t) => {
  isolate(t, { ATRIA_API_KEY: 'private-token' });
  for (const status of [401, 429, 500, 503]) {
    globalThis.fetch.mock.mockImplementation(async () => ({
      ok: false,
      status,
      json() { assert.fail('An upstream error body must not be read.'); },
    }));
    await assert.rejects(callAtria(request), isSanitizedUnavailable);
  }
  globalThis.fetch.mock.mockImplementation(async () => {
    throw new Error('private-upstream private-token');
  });
  await assert.rejects(callAtria(request), isSanitizedUnavailable);
});

test('malformed, empty, non-text and oversized Atria replies fail closed', async (t) => {
  isolate(t, { ATRIA_API_KEY: 'private-token' });
  for (const content of ['', '  ', null, undefined, [], { text: 'not a string' }, 'x'.repeat(65537)]) {
    globalThis.fetch.mock.mockImplementation(async () => atriaResponse(content));
    // Supplying undefined to the helper would otherwise select its default.
    if (content === undefined) {
      globalThis.fetch.mock.mockImplementation(async () => ({ ok: true, json: async () => ({}) }));
    }
    await assert.rejects(callAtria(request), isSanitizedUnavailable);
  }
  globalThis.fetch.mock.mockImplementation(async () => ({
    ok: true,
    json: async () => { throw new Error('private-upstream'); },
  }));
  await assert.rejects(callAtria(request), isSanitizedUnavailable);
});

for (const phase of ['headers', 'body']) {
  test(`Atria deadline includes stalled ${phase} and aborts within 20 seconds`, async (t) => {
    isolate(t, { ATRIA_API_KEY: 'private-token' });
    let deadline;
    let signal;
    const handle = {};
    t.mock.method(globalThis, 'setTimeout', (callback, delay) => {
      assert.ok(delay > 0 && delay <= 20_000);
      deadline = callback;
      return handle;
    });
    const clear = t.mock.method(globalThis, 'clearTimeout', (timer) => assert.equal(timer, handle));
    globalThis.fetch.mock.mockImplementation(async (_, options) => {
      signal = options.signal;
      if (phase === 'headers') return new Promise(() => {});
      return { ok: true, json: () => new Promise(() => {}) };
    });
    const result = callAtria(request);
    const rejection = assert.rejects(result, isSanitizedUnavailable);
    await Promise.resolve();
    deadline();
    await rejection;
    assert.equal(signal.aborted, true);
    assert.equal(clear.mock.callCount(), 1);
  });
}

test('explicit Atria selection uses only Atria even when every key exists', async (t) => {
  isolate(t, { ATRIA_API_KEY: 'private-token', OPENAI_API_KEY: 'unused', GROQ_API_KEY: 'unused', COACH_AI_PROVIDER: 'atria' });
  assert.equal(hasCoachAIKey(), true);
  globalThis.fetch.mock.mockImplementation(async (url) => {
    assert.equal(url, 'https://api.atria-asi.ai/v1/chat/completions');
    return atriaResponse();
  });
  await callCoachAI(request);
  assert.equal(globalThis.fetch.mock.callCount(), 1);
});

test('explicit Atria failure or missing key never falls through to another vendor', async (t) => {
  isolate(t, { OPENAI_API_KEY: 'unused', GROQ_API_KEY: 'unused', COACH_AI_PROVIDER: 'atria' });
  assert.equal(hasCoachAIKey(), false);
  await assert.rejects(callCoachAI(request), isSanitizedUnavailable);
  assert.equal(globalThis.fetch.mock.callCount(), 0);
  process.env.ATRIA_API_KEY = 'private-token';
  globalThis.fetch.mock.mockImplementation(async (url) => {
    assert.equal(url, 'https://api.atria-asi.ai/v1/chat/completions');
    return { ok: false, status: 429 };
  });
  await assert.rejects(callCoachAI(request), isSanitizedUnavailable);
  assert.equal(globalThis.fetch.mock.callCount(), 1);
});

test('an Atria key alone never opts the default coach into Atria', async (t) => {
  isolate(t, { ATRIA_API_KEY: 'private-token' });
  assert.equal(hasCoachAIKey(), false);
  await assert.rejects(callCoachAI(request), isSanitizedUnavailable);
  assert.equal(globalThis.fetch.mock.callCount(), 0);
});

test('default mode preserves OpenAI then Groq without using an available Atria key', async (t) => {
  isolate(t, { ATRIA_API_KEY: 'private-token', OPENAI_API_KEY: 'test-openai', GROQ_API_KEY: 'test-groq' });
  const urls = [];
  globalThis.fetch.mock.mockImplementation(async (url) => {
    urls.push(url);
    return url.includes('openai.com') ? { ok: false, status: 503 } : atriaResponse();
  });
  assert.equal(hasCoachAIKey(), true);
  assert.equal(await callCoachAI(request), '{"reply":"Ready"}');
  assert.deepEqual(urls, [
    'https://api.openai.com/v1/responses',
    'https://api.groq.com/openai/v1/chat/completions',
  ]);
});

test('unknown explicit provider does not fall back or expose its configured value', async (t) => {
  isolate(t, { OPENAI_API_KEY: 'unused', GROQ_API_KEY: 'unused', COACH_AI_PROVIDER: 'private-upstream' });
  assert.equal(hasCoachAIKey(), false);
  await assert.rejects(callCoachAI(request), isSanitizedUnavailable);
  assert.equal(globalThis.fetch.mock.callCount(), 0);
});

test('explicit OpenAI and Groq choices do not cross provider boundaries', async (t) => {
  isolate(t, { OPENAI_API_KEY: 'test-openai', GROQ_API_KEY: 'test-groq' });
  globalThis.fetch.mock.mockImplementation(async () => ({ ok: false, status: 503 }));
  process.env.COACH_AI_PROVIDER = 'openai';
  await assert.rejects(callCoachAI(request), isSanitizedUnavailable);
  assert.equal(globalThis.fetch.mock.callCount(), 1);
  process.env.COACH_AI_PROVIDER = 'groq';
  await assert.rejects(callCoachAI(request), isSanitizedUnavailable);
  assert.equal(globalThis.fetch.mock.callCount(), 2);
});
