import { callGroqTranscription, hasGroqKey } from './groq.js';
import { callOpenAITranscription, hasOpenAIKey } from './openai.js';

export function hasSpeechTranscriptionProvider() {
  return hasOpenAIKey() || hasGroqKey();
}

export async function transcribeSpeech(recording) {
  if (hasOpenAIKey()) {
    try {
      return await callOpenAITranscription(recording);
    } catch (error) {
      if (!hasGroqKey()) throw error;
    }
  }
  return callGroqTranscription(recording);
}
