const lessons = Object.freeze({
  q_fatiha_1: Object.freeze({ ayats: 1, duas: 0 }),
  q_fatiha_2: Object.freeze({ ayats: 2, duas: 0 }),
  q_fatiha_3: Object.freeze({ ayats: 2, duas: 0 }),
  q_fatiha_4: Object.freeze({ ayats: 2, duas: 0 }),
  q_ikhlas_1: Object.freeze({ ayats: 2, duas: 0 }),
  q_falaq_1: Object.freeze({ ayats: 1, duas: 0 }),
  q_nas_1: Object.freeze({ ayats: 1, duas: 0 }),
  q_baqara_1: Object.freeze({ ayats: 2, duas: 0 }),
  a1: Object.freeze({ ayats: 0, duas: 0 }),
  a2: Object.freeze({ ayats: 0, duas: 0 }),
  a3: Object.freeze({ ayats: 0, duas: 0 }),
  r1: Object.freeze({ ayats: 0, duas: 0 }),
  r2: Object.freeze({ ayats: 1, duas: 0 }),
  r3: Object.freeze({ ayats: 0, duas: 0 }),
  r4: Object.freeze({ ayats: 0, duas: 0 }),
  r5: Object.freeze({ ayats: 0, duas: 0 }),
  r6: Object.freeze({ ayats: 0, duas: 0 }),
  r7: Object.freeze({ ayats: 0, duas: 1 }),
})

function normalizeSpeech(value) {
  return Array.from(String(value || "").toLowerCase())
    .filter((char) => {
      const code = char.codePointAt(0)
      const isArabic = code >= 0x0600 && code <= 0x06ff
      const isArabicMark = (code >= 0x064b && code <= 0x065f) || code === 0x0670
      const isLatin = code >= 0x0061 && code <= 0x007a
      const isCyrillic = code >= 0x0400 && code <= 0x04ff
      const isDigit = code >= 0x0030 && code <= 0x0039
      return !isArabicMark && (isArabic || isLatin || isCyrillic || isDigit)
    })
    .join("")
}

function similarity(spoken, target) {
  if (!spoken || !target) return 0
  if (spoken.indexOf(target) !== -1 || target.indexOf(spoken) !== -1) return 1
  const spokenSet = new Set(Array.from(spoken))
  const targetSet = new Set(Array.from(target))
  let overlap = 0
  spokenSet.forEach((char) => {
    if (targetSet.has(char)) overlap++
  })
  const union = new Set([...spokenSet, ...targetSet]).size
  return union === 0 ? 0 : overlap / union
}

function evaluateSpeech(transcript, target, passScore) {
  const normalizedTranscript = normalizeSpeech(transcript)
  const normalizedTarget = normalizeSpeech(target)
  const score = Math.max(0, Math.min(
    100,
    Math.round(similarity(normalizedTranscript, normalizedTarget) * 100),
  ))
  const passed = String(transcript || "").trim() !== "" && score >= passScore
  const weakParts = passed
    ? []
    : String(target || "")
        .split(/\s+/)
        .filter((part) => part && normalizedTranscript.indexOf(normalizeSpeech(part)) === -1)
        .slice(0, 3)
  return {
    transcript: String(transcript || ""),
    normalizedTranscript: normalizedTranscript,
    target: String(target || ""),
    score: score,
    passed: passed,
    weakParts: weakParts,
    feedbackText: passed
      ? "Произношение принято."
      : String(transcript || "").trim() === ""
        ? "Я не услышал фразу. Нажми микрофон и повтори ещё раз."
        : "Похоже не совпало с заданием. Повтори медленнее.",
    engine: "localFallback",
    fallbackUsed: true,
  }
}

function find(app, userId) {
  return app.findFirstRecordByData("progress", "user", userId)
}

function jsonArray(record, field) {
  const raw = record.get(field)
  if (!raw) return []
  try {
    const parsed = JSON.parse(toString(raw))
    return Array.isArray(parsed) ? parsed : []
  } catch (_) {
    return []
  }
}

function serialize(record) {
  return {
    id: record.id,
    user: record.getString("user"),
    displayName: record.getString("displayName"),
    xp: record.getInt("xp"),
    level: record.getInt("level"),
    streak: record.getInt("streak"),
    hearts: record.getInt("hearts"),
    energy: record.getInt("energy"),
    isPremium: record.getBool("isPremium"),
    totalLessons: record.getInt("totalLessons"),
    totalMinutes: record.getInt("totalMinutes"),
    learnedAyats: record.getInt("learnedAyats"),
    learnedDuas: record.getInt("learnedDuas"),
    dailyGoal: record.getInt("dailyGoal") || 3,
    dailyProgress: record.getInt("dailyProgress"),
    lessonAttempts: record.getInt("lessonAttempts"),
    speechAttempts: record.getInt("speechAttempts"),
    rewardChestsOpened: record.getInt("rewardChestsOpened"),
    rewardHistory: jsonArray(record, "rewardHistory"),
    lastStudyDay: record.getString("lastStudyDay"),
    completedLessons: jsonArray(record, "completedLessons"),
  }
}

module.exports = Object.freeze({
  lessons: lessons,
  evaluateSpeech: evaluateSpeech,
  find: find,
  jsonArray: jsonArray,
  serialize: serialize,
})
