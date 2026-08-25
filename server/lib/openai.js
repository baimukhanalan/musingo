import { ApiError } from './http.js';

const OPENAI_TRANSCRIPTION_URL = 'https://api.openai.com/v1/audio/transcriptions';
const OPENAI_TRANSCRIPTION_MODEL = 'gpt-4o-mini-transcribe';
const REQUEST_TIMEOUT_MS = 20_000;

export function hasOpenAIKey() {
  return Boolean(process.env.OPENAI_API_KEY);
}

export async function callOpenAITranscription({ audio, mimeType, prompt = '' }) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new ApiError(
      503,
      'speech_transcription_unavailable',
      'Speech transcription is not configured.',
    );
  }

  const extension = mimeType.includes('mp4')
    ? 'm4a'
    : mimeType.includes('ogg')
      ? 'ogg'
      : mimeType.includes('wav')
        ? 'wav'
        : 'webm';
  const form = new FormData();
  form.append('file', new Blob([audio], { type: mimeType }), `speech.${extension}`);
  form.append('model', OPENAI_TRANSCRIPTION_MODEL);
  form.append('response_format', 'json');
  form.append('language', 'ar');
  if (prompt) form.append('prompt', String(prompt).slice(0, 400));

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
  let httpResponse;
  try {
    httpResponse = await fetch(OPENAI_TRANSCRIPTION_URL, {
      method: 'POST',
      headers: { Authorization: `Bearer ${apiKey}` },
      body: form,
      signal: controller.signal,
    });
  } catch (_) {
    throw new ApiError(
      503,
      'speech_transcription_unavailable',
      'Speech transcription failed.',
    );
  } finally {
    clearTimeout(timer);
  }

  if (!httpResponse.ok) {
    throw new ApiError(
      503,
      'speech_transcription_unavailable',
      'Speech transcription failed.',
    );
  }
  let data;
  try {
    data = await httpResponse.json();
  } catch (_) {
    throw new ApiError(
      503,
      'speech_transcription_unavailable',
      'Speech transcription returned invalid data.',
    );
  }
  const transcript = data?.text;
  if (typeof transcript !== 'string' || transcript.trim().length === 0) {
    throw new ApiError(422, 'speech_not_recognized', 'No speech was recognized.');
  }
  return transcript.trim();
}
