import { callGroq, hasGroqKey } from './groq.js';
import { callOpenAIText, hasOpenAIKey } from './openai.js';

export function hasCoachAIKey() {
  return hasOpenAIKey() || hasGroqKey();
}

export async function callCoachAI(request) {
  if (hasOpenAIKey()) {
    try {
      return await callOpenAIText(request);
    } catch (error) {
      if (!hasGroqKey()) throw error;
    }
  }
  return callGroq(request);
}
