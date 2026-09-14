import { optionalUser } from '../lib/auth.js';
import { clientIp, method, readJson, withApi } from '../lib/http.js';
import { consumeSpeechAttempt, speechRateLimitPlan } from '../lib/login-rate-limit.js';
import {
  hasSpeechTranscriptionProvider,
  transcribeSpeech,
} from '../lib/speech-transcription.js';

// Жёсткий предел длины входа ДО вычислений. distance() — O(n·m) и вызывается
// дважды; при 2000 символах это до 8 млн операций на запрос без авторизации.
// 400 символов с запасом покрывают самый длинный аят и ответ пользователя, но
// ограничивают стоимость до ~160k операций — дешёвая защита от «сжигания CPU».
export const SPEECH_MAX_INPUT = 400;
export const SPEECH_MAX_AUDIO_BYTES = 650_000;
export const SPEECH_GLOBAL_MAX_ATTEMPTS = 500;
const allowedAudioTypes = new Set([
  'audio/webm',
  'audio/webm;codecs=opus',
  'audio/mp4',
  'audio/ogg',
  'audio/ogg;codecs=opus',
  'audio/wav',
  'audio/x-wav',
]);

export function clampInput(value, max = SPEECH_MAX_INPUT) {
  return String(value ?? '').slice(0, Math.max(0, max));
}

export function normalizeSpeech(value) {
  return String(value ?? '')
    .toLowerCase()
    .normalize('NFC')
    .replace(/[\u064B-\u065F\u0670\u06D6-\u06ED]/g, '')
    .replace(/[یى]/g, 'ي')
    .replace(/ک/g, 'ك')
    .replace(/ё/g, 'е')
    .replace(/[^\u0600-\u06ffa-zа-яёәғқңөұүһі0-9]+/gu, '');
}

export function normalizeArabicVowelHints(value) {
  return String(value ?? '')
    .toLowerCase()
    .normalize('NFKD')
    .replace(/\u064B/g, 'ان')
    .replace(/\u064C/g, 'ون')
    .replace(/\u064D/g, 'ين')
    .replace(/\u064E/g, 'ا')
    .replace(/\u064F/g, 'و')
    .replace(/\u0650/g, 'ي')
    .replace(/[\u0651-\u065F\u0670\u06D6-\u06ED]/g, '')
    .replace(/[یى]/g, 'ي')
    .replace(/ک/g, 'ك')
    .replace(/[^\u0600-\u06ff]+/gu, '');
}

export function normalizePhonetic(value) {
  const cyrillicToLatin = {
    а: 'a', б: 'b', в: 'v', г: 'g', д: 'd', е: 'e', ё: 'yo', ж: 'zh',
    з: 'z', и: 'i', й: 'y', к: 'k', л: 'l', м: 'm', н: 'n', о: 'o',
    п: 'p', р: 'r', с: 's', т: 't', у: 'u', ф: 'f', х: 'kh', ц: 'ts',
    ч: 'ch', ш: 'sh', щ: 'sh', ы: 'y', э: 'e', ю: 'yu', я: 'ya',
    ъ: '', ь: '', ә: 'a', ғ: 'gh', қ: 'q', ң: 'ng', ө: 'o', ұ: 'u',
    ү: 'u', һ: 'h', і: 'i',
  };
  return Array.from(String(value ?? '').toLowerCase().normalize('NFC'))
    .map((character) => cyrillicToLatin[character] ?? character)
    .join('')
    .replace(/[^a-z0-9]+/g, '');
}

export function decodeSpeechAudio(audioBase64, mimeType) {
  const encoded = String(audioBase64 ?? '');
  const normalizedMimeType = String(mimeType ?? '').toLowerCase();
  if (!encoded || !allowedAudioTypes.has(normalizedMimeType)) return null;
  if (!/^[a-z0-9+/]+={0,2}$/i.test(encoded)) return null;
  const audio = Buffer.from(encoded, 'base64');
  if (audio.length === 0 || audio.length > SPEECH_MAX_AUDIO_BYTES) return null;
  return { audio, mimeType: normalizedMimeType };
}

export async function evaluateSpeechBody(body, { transcribe = transcribeSpeech } = {}) {
  let transcript = clampInput(body.transcript);
  const target = clampInput(body.target);
  const phoneticTarget = clampInput(body.phoneticTarget);
  let transcribedAudio = false;
  if (!transcript) {
    const recording = decodeSpeechAudio(body.audioBase64, body.audioMimeType);
    if (body.audioBase64 && !recording) {
      return {
        status: 400,
        payload: { error: 'invalid_speech_audio', message: 'Invalid speech audio.' },
      };
    }
    if (recording) {
      if (body.audioProcessorConsent !== true) {
        return {
          status: 400,
          payload: {
            error: 'audio_consent_required',
            message: 'Explicit consent is required before audio processing.',
          },
        };
      }
      const language = body.language === 'kk' ? 'kk' : 'ar';
      transcript = clampInput(await transcribe({
        ...recording,
        prompt: target,
        language,
      }));
      transcribedAudio = true;
    }
  }
  const normalizedTranscript = normalizeSpeech(transcript);
  const targetScore = Math.max(
    scoreSpeech(normalizedTranscript, normalizeSpeech(target)),
    scoreSpeech(
      normalizeArabicVowelHints(transcript),
      normalizeArabicVowelHints(target),
    ),
  );
  const phoneticScore = Math.max(
    scoreSpeech(normalizedTranscript, normalizeSpeech(phoneticTarget)),
    scoreSpeech(normalizePhonetic(transcript), normalizePhonetic(phoneticTarget)),
  );
  const finalScore = Math.max(targetScore, phoneticScore);
  const passScore = Math.min(100, Math.max(0, Number(body.passScore ?? 60)));
  const passed = normalizedTranscript.length > 0 && finalScore >= passScore;
  return {
    status: 200,
    payload: {
      transcript,
      normalizedTranscript,
      target,
      score: finalScore,
      passed,
      weakParts: passed ? [] : target.split(/\s+/).filter(Boolean).slice(0, 3),
      feedbackText: passed
        ? 'Произношение принято.'
        : normalizedTranscript.length === 0
          ? 'Я не услышал фразу. Нажми микрофон и повтори еще раз.'
          : 'Есть расхождение с образцом. Прослушай фрагмент и повтори медленнее.',
      engine: transcribedAudio ? 'serverAudioTranscription' : 'serverTextComparison',
      fallbackUsed: !transcribedAudio,
      audioHandling: {
        sentToConfiguredProcessor: transcribedAudio,
        storedByMuslingo: false,
        providerRetentionVerified: false,
      },
    },
  };
}

function distance(a, b) {
  const aRunes = Array.from(a);
  const bRunes = Array.from(b);
  if (!aRunes.length) return bRunes.length;
  if (!bRunes.length) return aRunes.length;
  let previous = Array.from({ length: bRunes.length + 1 }, (_, index) => index);
  for (let i = 0; i < aRunes.length; i += 1) {
    const current = [i + 1];
    for (let j = 0; j < bRunes.length; j += 1) {
      current[j + 1] = Math.min(
        previous[j + 1] + 1,
        current[j] + 1,
        previous[j] + (aRunes[i] === bRunes[j] ? 0 : 1),
      );
    }
    previous = current;
  }
  return previous.at(-1);
}

export function scoreSpeech(spoken, target) {
  if (!spoken || !target) return 0;
  if (Array.from(target).length >= 8 && spoken.includes(target)) return 100;
  const spokenRunes = Array.from(spoken);
  const targetRunes = Array.from(target);
  const longest = Math.max(spokenRunes.length, targetRunes.length);
  const shortest = Math.min(spokenRunes.length, targetRunes.length);
  const editSimilarity = longest === 0 ? 0 : 1 - distance(spoken, target) / longest;
  const spokenSet = new Set(spokenRunes);
  const targetSet = new Set(targetRunes);
  const overlap = [...spokenSet].filter((value) => targetSet.has(value)).length;
  const union = new Set([...spokenSet, ...targetSet]).size;
  const setSimilarity = union === 0 ? 0 : overlap / union;
  const coverage = longest === 0 ? 0 : shortest / longest;
  // A short fragment must never pass a long target just because all of its
  // characters occur in the target. Small recognition omissions retain a
  // little tolerance, while one-letter/one-word transcripts are strongly
  // penalized.
  const coveragePenalty = Math.min(1, coverage * 1.15);
  const similarity = Math.max(editSimilarity, setSimilarity) * coveragePenalty;
  return Math.max(0, Math.min(100, Math.round(similarity * 100)));
}

export default withApi(async (request, response) => {
  method(request, ['POST']);
  // Привязываем запрос к пользователю, если он прислал токен. optionalUser не
  // отклоняет анонимов: клиент шлёт speech-запросы без Authorization и молча
  // откатывается на локальную оценку, поэтому requireUser отключил бы серверную
  // оценку для всех. Защита от перегрузки CPU — жёсткий лимит длины ниже.
  const body = readJson(request);
  const hasTranscript = Boolean(clampInput(body.transcript));
  const hasAudio = !hasTranscript && Boolean(body.audioBase64);
  if (hasAudio) {
    if (body.audioProcessorConsent !== true) {
      return response.status(400).json({
        error: 'audio_consent_required',
        message: 'Explicit consent is required before audio processing.',
      });
    }
    const recording = decodeSpeechAudio(body.audioBase64, body.audioMimeType);
    if (!recording) {
      return response.status(400).json({
        error: 'invalid_speech_audio',
        message: 'Invalid speech audio.',
      });
    }
    if (!hasSpeechTranscriptionProvider()) {
      return response.status(503).json({
        error: 'speech_transcription_unavailable',
        message: 'Speech transcription is not configured.',
      });
    }
  }
  const user = await optionalUser(request);
  for (const bucket of speechRateLimitPlan({
    ip: clientIp(request),
    userId: user?.id,
    audio: hasAudio,
  })) {
    await consumeSpeechAttempt(bucket.key, bucket);
  }
  if (hasAudio) {
    // Apply the provider-wide cap only after caller-specific buckets. A caller
    // already over its own limit cannot consume the shared provider budget.
    await consumeSpeechAttempt('speech:audio:global', {
      authenticated: false,
      limit: SPEECH_GLOBAL_MAX_ATTEMPTS,
    });
  }
  response.setHeader('Cache-Control', 'no-store, private');
  response.setHeader('Pragma', 'no-cache');
  const result = await evaluateSpeechBody(body);
  return response.status(result.status).json(result.payload);
});
