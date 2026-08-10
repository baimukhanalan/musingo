// Shared by the single Vercel API router.
//
// Тонкая обёртка над Groq (OpenAI-совместимый chat/completions). Ключ берётся
// ИСКЛЮЧИТЕЛЬНО из process.env.GROQ_API_KEY и НИКОГДА не хардкодится и не
// логируется. Без внешних npm-пакетов — только нативный fetch (Node 20+).
import { ApiError } from './http.js';

const GROQ_URL = 'https://api.groq.com/openai/v1/chat/completions';
const GROQ_MODEL = 'llama-3.3-70b-versatile';
const REQUEST_TIMEOUT_MS = 20_000;

export function hasGroqKey() {
  return Boolean(process.env.GROQ_API_KEY);
}

// Возвращает распарсенный текстовый ответ ассистента (строку content первого
// choice). При отсутствии ключа/сетевой ошибке/таймауте/плохом статусе бросает
// ApiError 503 coach_unavailable — так роут единообразно откатывает клиента на
// локальный движок. jsonResponse=true просит модель вернуть строгий JSON-объект.
export async function callGroq({ system, user, temperature = 0.4, maxTokens = 700, jsonResponse = true }) {
  const apiKey = process.env.GROQ_API_KEY;
  if (!apiKey) {
    throw new ApiError(503, 'coach_unavailable', 'AI coach is not configured.');
  }

  const payload = {
    model: GROQ_MODEL,
    temperature: Math.min(2, Math.max(0, Number(temperature) || 0)),
    max_tokens: Math.min(4096, Math.max(1, Math.floor(Number(maxTokens) || 700))),
    messages: [
      { role: 'system', content: String(system ?? '') },
      { role: 'user', content: String(user ?? '') },
    ],
  };
  if (jsonResponse) {
    payload.response_format = { type: 'json_object' };
  }

  const controller = new AbortController();
  const timer = setTimeout(() => controller.abort(), REQUEST_TIMEOUT_MS);
  let httpResponse;
  try {
    httpResponse = await fetch(GROQ_URL, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${apiKey}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify(payload),
      signal: controller.signal,
    });
  } catch (error) {
    // Таймаут (AbortError) или сетевой сбой — коуч недоступен, клиент откатится.
    throw new ApiError(503, 'coach_unavailable', 'AI coach request failed.');
  } finally {
    clearTimeout(timer);
  }

  if (!httpResponse.ok) {
    // Тело ошибки Groq может содержать чувствительные детали — не пробрасываем.
    throw new ApiError(503, 'coach_unavailable', 'AI coach upstream error.');
  }

  let data;
  try {
    data = await httpResponse.json();
  } catch {
    throw new ApiError(503, 'coach_unavailable', 'AI coach returned invalid response.');
  }

  const content = data?.choices?.[0]?.message?.content;
  if (typeof content !== 'string' || content.length === 0) {
    throw new ApiError(503, 'coach_unavailable', 'AI coach returned no content.');
  }
  return content;
}
