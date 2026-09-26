import { callGroq, hasGroqKey } from './groq.js';
import { callOpenAIText, hasOpenAIKey } from './openai.js';
import { callAtria, hasAtriaKey } from './atria.js';
import { ApiError } from './http.js';

function selectedProvider() {
  return String(process.env.COACH_AI_PROVIDER ?? '').trim().toLowerCase();
}

export function hasCoachAIKey() {
  switch (selectedProvider()) {
    case 'atria': return hasAtriaKey();
    case 'openai': return hasOpenAIKey();
    case 'groq': return hasGroqKey();
    case '':
    case 'auto': return hasOpenAIKey() || hasGroqKey();
    default: return false;
  }
}

export async function callCoachAI(request) {
  // Explicit choices never silently disclose a conversation to another vendor.
  switch (selectedProvider()) {
    case 'atria': return callAtria(request);
    case 'openai': return callOpenAIText(request);
    case 'groq': return callGroq(request);
    case '':
    case 'auto': break;
    default:
      throw new ApiError(503, 'coach_unavailable', 'AI coach provider is not configured.');
  }
  // Preserve the existing OpenAI -> Groq fallback only in the default mode.
  // An ATRIA_API_KEY by itself never opts a conversation into Atria.
  if (hasOpenAIKey()) {
    try {
      return await callOpenAIText(request);
    } catch (error) {
      if (!hasGroqKey()) throw error;
    }
  }
  return callGroq(request);
}
