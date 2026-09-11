import { ApiError } from './http.js';

const OPENAI_TRANSCRIPTION_URL = 'https://api.openai.com/v1/audio/transcriptions';
const OPENAI_RESPONSES_URL = 'https://api.openai.com/v1/responses';
const OPENAI_TRANSCRIPTION_MODEL = 'gpt-4o-mini-transcribe';
const OPENAI_COACH_MODEL = process.env.OPENAI_COACH_MODEL || 'gpt-5.6-luna';
const REQUEST_TIMEOUT_MS = 20_000;

export function hasOpenAIKey() {
  return Boolean(process.env.OPENAI_API_KEY);
}

export async function callOpenAIText({ system, user, maxTokens = 700 }) {
  const apiKey = process.env.OPENAI_API_KEY;
  if (!apiKey) {
    throw new ApiError(503, 'coach_unavailable', 'AI coach is not configured.');
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
  let httpResponse;
  try {
    httpResponse = await fetch(OPENAI_RESPONSES_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        model: OPENAI_COACH_MODEL,
        instructions: String(system ?? ''),
        input: String(user ?? ''),
        max_output_tokens: Math.min(
          4096,
          Math.max(1, Math.floor(Number(maxTokens) || 700)),
        ),
        store: false,
      }),
      signal: controller.signal,
    });
  } catch (_) {
    throw new ApiError(503, 'coach_unavailable', 'AI coach request failed.');
  } finally {
    clearTimeout(timer);
  }

  if (!httpResponse.ok) {
    throw new ApiError(503, 'coach_unavailable', 'AI coach upstream error.');
  }
  let data;
  try {
    data = await httpResponse.json();
  } catch (_) {
    throw new ApiError(503, 'coach_unavailable', 'AI coach returned invalid response.');
  }
  const content = data?.output
    ?.flatMap((item) => Array.isArray(item?.content) ? item.content : [])
    .find((item) => item?.type === 'output_text')
    ?.text;
  if (typeof content !== 'string' || content.trim().length === 0) {
    throw new ApiError(503, 'coach_unavailable', 'AI coach returned no content.');
  }
  return content.trim();
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
