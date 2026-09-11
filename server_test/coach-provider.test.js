import assert from 'node:assert/strict';
import test from 'node:test';

import { callOpenAIText } from '../server/lib/openai.js';

test('OpenAI Coach uses Responses API without server-side storage', async () => {
  const previousKey = process.env.OPENAI_API_KEY;
  const previousFetch = globalThis.fetch;
  process.env.OPENAI_API_KEY = 'test-key';
  let request;
  globalThis.fetch = async (url, options) => {
    request = { url, options };
    return {
      ok: true,
      async json() {
        return {
          output: [{
            content: [{ type: 'output_text', text: '{"reply":"Ready"}' }],
          }],
        };
      },
    };
  };
  try {
    const result = await callOpenAIText({
      system: 'Grounded system prompt',
      user: 'Sanitized learner context',
      maxTokens: 500,
    });
    assert.equal(result, '{"reply":"Ready"}');
    assert.equal(request.url, 'https://api.openai.com/v1/responses');
    const body = JSON.parse(request.options.body);
    assert.equal(body.store, false);
    assert.equal(body.instructions, 'Grounded system prompt');
    assert.equal(body.input, 'Sanitized learner context');
    assert.equal(body.max_output_tokens, 500);
    assert.ok(!request.options.body.includes('test-key'));
    assert.equal(request.options.headers.Authorization, 'Bearer test-key');
  } finally {
    globalThis.fetch = previousFetch;
    if (previousKey === undefined) delete process.env.OPENAI_API_KEY;
    else process.env.OPENAI_API_KEY = previousKey;
  }
});
