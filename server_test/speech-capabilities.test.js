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
  const previousOpenAI = process.env.OPENAI_API_KEY;
  const previousGroq = process.env.GROQ_API_KEY;
  process.env.OPENAI_API_KEY = 'test-only-key';
  delete process.env.GROQ_API_KEY;
  try {
    const response = mockResponse();
    await speechCapabilities({ method: 'GET', headers: {} }, response);
    assert.equal(response.statusCode, 200);
    assert.deepEqual(response.body, {
      textEvaluation: true,
      audioTranscription: true,
    });
  } finally {
    if (previousOpenAI === undefined) delete process.env.OPENAI_API_KEY;
    else process.env.OPENAI_API_KEY = previousOpenAI;
    if (previousGroq === undefined) delete process.env.GROQ_API_KEY;
    else process.env.GROQ_API_KEY = previousGroq;
  }
});
