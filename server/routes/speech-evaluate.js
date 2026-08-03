import { method, readJson, withApi } from '../lib/http.js';

function normalize(value) {
  return String(value ?? '')
    .toLowerCase()
    .normalize('NFKD')
    .replace(/[\u064B-\u065F\u0670]/g, '')
    .replace(/ё/g, 'е')
    .replace(/[^\u0600-\u06ffa-zа-яе0-9]+/gu, '');
}

function distance(a, b) {
  if (!a.length) return b.length;
  if (!b.length) return a.length;
  let previous = Array.from({ length: b.length + 1 }, (_, index) => index);
  for (let i = 0; i < a.length; i += 1) {
    const current = [i + 1];
    for (let j = 0; j < b.length; j += 1) {
      current[j + 1] = Math.min(previous[j + 1] + 1, current[j] + 1, previous[j] + (a[i] === b[j] ? 0 : 1));
    }
    previous = current;
  }
  return previous.at(-1);
}

function score(spoken, target) {
  if (!spoken || !target) return 0;
  if (spoken.includes(target) || target.includes(spoken)) return 100;
  return Math.max(0, Math.round((1 - distance(spoken, target) / Math.max(spoken.length, target.length)) * 100));
}

export default withApi(async (request, response) => {
  method(request, ['POST']);
  const body = readJson(request);
  const transcript = String(body.transcript ?? '').slice(0, 2000);
  const target = String(body.target ?? '').slice(0, 2000);
  const phoneticTarget = String(body.phoneticTarget ?? '').slice(0, 2000);
  const normalizedTranscript = normalize(transcript);
  const targetScore = score(normalizedTranscript, normalize(target));
  const phoneticScore = score(normalizedTranscript, normalize(phoneticTarget));
  const finalScore = Math.max(targetScore, phoneticScore);
  const passScore = Math.min(100, Math.max(0, Number(body.passScore ?? 60)));
  const passed = normalizedTranscript.length > 0 && finalScore >= passScore;
  return response.status(200).json({
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
    engine: 'serverTextComparison',
    fallbackUsed: true,
  });
});
