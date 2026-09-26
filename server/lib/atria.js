import { ApiError } from './http.js';

// Official Chat Completions contract: https://api.atria-asi.ai/docs
// Provider selection is intentionally handled in coach-ai.js, never inferred
// from the presence of a key. No endpoint override can redirect learner data.
const ATRIA_URL = 'https://api.atria-asi.ai/v1/chat/completions';
const ATRIA_MODEL = 'Atria-Dawn-Preview';
const REQUEST_TIMEOUT_MS = 18_000;
const MAX_RESPONSE_CHARS = 65_536;

export function hasAtriaKey() {
  return Boolean(process.env.ATRIA_API_KEY?.trim());
}

function unavailable(message) {
  return new ApiError(503, 'coach_unavailable', message);
}

function boundedTokens(value) {
  const number = Number(value);
  return Number.isFinite(number)
    ? Math.min(4096, Math.max(1, Math.floor(number)))
    : 700;
}

export async function callAtria({ system, user, maxTokens = 700 }) {
  const apiKey = process.env.ATRIA_API_KEY?.trim();
  if (!apiKey) {
    throw unavailable('AI coach is not configured.');
  }

  const controller = new AbortController();
  let timer;
  const deadline = new Promise((_, reject) => {
    timer = setTimeout(() => {
      controller.abort();
      reject(unavailable('AI coach request timed out.'));
    }, REQUEST_TIMEOUT_MS);
  });

  const complete = async () => {
    let response;
    try {
      response = await fetch(ATRIA_URL, {
        method: 'POST',
        headers: {
          Authorization: `Bearer ${apiKey}`,
          'Content-Type': 'application/json',
        },
        // Keep to documented fields; JSON structure is requested by the existing
        // system prompt and validated by the coach route, not assumed here.
        body: JSON.stringify({
          model: ATRIA_MODEL,
          messages: [
            { role: 'system', content: String(system ?? '') },
            { role: 'user', content: String(user ?? '') },
          ],
          max_completion_tokens: boundedTokens(maxTokens),
          stream: false,
        }),
        signal: controller.signal,
        redirect: 'error',
      });
    } catch {
      // Never reflect exception messages, upstream bodies, prompts or API keys.
      throw unavailable('AI coach request failed.');
    }
    if (!response?.ok) {
      throw unavailable('AI coach upstream error.');
    }
    let data;
    try {
      data = await response.json();
    } catch {
      throw unavailable('AI coach returned invalid response.');
    }
    const content = data?.choices?.[0]?.message?.content;
    if (typeof content !== 'string' || content.trim().length === 0 ||
        content.length > MAX_RESPONSE_CHARS) {
      throw unavailable('AI coach returned no usable content.');
    }
    return content.trim();
  };

  try {
    // The deadline includes response-body reading, not only arrival of headers.
    // Promise.race also bounds non-cooperative mocked/stalled response readers.
    return await Promise.race([complete(), deadline]);
  } finally {
    clearTimeout(timer);
  }
}
