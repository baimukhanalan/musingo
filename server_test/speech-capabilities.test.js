import assert from 'node:assert/strict';
import test from 'node:test';

import speechCapabilities from '../server/routes/speech-capabilities.js';

function mockResponse() {
  return {
    statusCode: null,
    body: null,
    setHeader() {},
    status(code) { this.statusCode = code; return this; },
    json(payload) { this.body = payload; return this; },
    end() { return this; },
  };
}

test('speech capabilities reflect server transcription configuration', async () => {
  const previous = process.env.GROQ_API_KEY;
  process.env.GROQ_API_KEY = 'test-only-key';
  try {
    const response = mockResponse();
    await speechCapabilities({ method: 'GET', headers: {} }, response);
    assert.equal(response.statusCode, 200);
    assert.deepEqual(response.body, {
      textEvaluation: true,
      audioTranscription: true,
    });
  } finally {
    if (previous === undefined) delete process.env.GROQ_API_KEY;
    else process.env.GROQ_API_KEY = previous;
  }
});
