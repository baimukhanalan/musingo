import assert from 'node:assert/strict';
import test from 'node:test';

import { callGroqTranscription } from '../server/lib/groq.js';
import speechEvaluate, {
  decodeSpeechAudio,
  evaluateSpeechBody,
  normalizeSpeech,
  scoreSpeech,
} from '../server/routes/speech-evaluate.js';

function mockResponse() {
  return {
    statusCode: null,
    body: null,
    headers: {},
    setHeader(name, value) { this.headers[name.toLowerCase()] = value; },
    status(code) { this.statusCode = code; return this; },
    json(payload) { this.body = payload; return this; },
    end() { return this; },
  };
}

test('speech scoring rejects one letter for a full ayah', () => {
  const spoken = normalizeSpeech('ب');
  const target = normalizeSpeech('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
  assert.ok(scoreSpeech(spoken, target) < 50);
});

test('speech scoring accepts a normalized full match', () => {
  const spoken = normalizeSpeech('بسم الله الرحمن الرحيم');
  const target = normalizeSpeech('بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ');
  assert.equal(scoreSpeech(spoken, target), 100);
});

test('speech scoring tolerates a small recognition omission', () => {
  const spoken = normalizeSpeech('بسم الله الرحمن الرحيم');
  const target = normalizeSpeech('بسم الله الرحمن الرحيم');
  assert.ok(scoreSpeech(spoken.slice(0, -1), target) >= 80);
});

test('audio decoder rejects unsupported and oversized recordings', () => {
  assert.equal(decodeSpeechAudio(Buffer.from('voice').toString('base64'), 'audio/aac'), null);
  assert.equal(
    decodeSpeechAudio(Buffer.alloc(650_001).toString('base64'), 'audio/webm'),
    null,
  );
});

test('speech body transcribes uploaded audio before scoring it', async () => {
  const result = await evaluateSpeechBody({
    transcript: '',
    target: 'بِسْمِ اللَّهِ',
    phoneticTarget: 'Бисмиллях',
    passScore: 70,
    audioMimeType: 'audio/webm',
    audioBase64: Buffer.from('recorded voice').toString('base64'),
  }, {
    transcribe: async ({ audio, mimeType }) => {
      assert.equal(audio.toString(), 'recorded voice');
      assert.equal(mimeType, 'audio/webm');
      return 'بسم الله';
    },
  });
  assert.equal(result.status, 200);
  assert.equal(result.payload.transcript, 'بسم الله');
  assert.equal(result.payload.score, 100);
  assert.equal(result.payload.engine, 'serverAudioTranscription');
  assert.equal(result.payload.fallbackUsed, false);
});

test('Groq transcription sends audio as multipart form data', async () => {
  const previousKey = process.env.GROQ_API_KEY;
  const previousFetch = globalThis.fetch;
  process.env.GROQ_API_KEY = 'test-only-key';
  globalThis.fetch = async (url, options) => {
    assert.equal(url, 'https://api.groq.com/openai/v1/audio/transcriptions');
    assert.equal(options.method, 'POST');
    assert.match(options.headers.Authorization, /^Bearer /);
    assert.ok(options.body instanceof FormData);
    assert.equal(options.body.get('model'), 'whisper-large-v3-turbo');
    return new Response(JSON.stringify({ text: 'بسم الله' }), {
      status: 200,
      headers: { 'Content-Type': 'application/json' },
    });
  };
  try {
    const transcript = await callGroqTranscription({
      audio: Buffer.from('recorded voice'),
      mimeType: 'audio/webm',
      prompt: 'بسم الله',
    });
    assert.equal(transcript, 'بسم الله');
  } finally {
    globalThis.fetch = previousFetch;
    if (previousKey === undefined) delete process.env.GROQ_API_KEY;
    else process.env.GROQ_API_KEY = previousKey;
  }
});

test('route returns a clear error when audio transcription is not configured', async () => {
  const previousKey = process.env.GROQ_API_KEY;
  delete process.env.GROQ_API_KEY;
  try {
    const response = mockResponse();
    await speechEvaluate({
      method: 'POST',
      headers: {},
      body: {
        target: 'بسم الله',
        audioMimeType: 'audio/webm',
        audioBase64: Buffer.from('recorded voice').toString('base64'),
      },
    }, response);
    assert.equal(response.statusCode, 503);
    assert.equal(response.body.error, 'speech_transcription_unavailable');
  } finally {
    if (previousKey === undefined) delete process.env.GROQ_API_KEY;
    else process.env.GROQ_API_KEY = previousKey;
  }
});
