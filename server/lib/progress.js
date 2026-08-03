// Shared by the single Vercel API router.
const maxListItems = 2000;

export function defaultProgress(user) {
  return {
    user: user.id,
    displayName: user.display_name,
    email: user.email,
    xp: 0,
    level: 1,
    streak: 0,
    hearts: 5,
    energy: 0,
    isPremium: false,
    lastStudyDay: '',
    totalLessons: 0,
    totalMinutes: 0,
    learnedAyats: 0,
    learnedDuas: 0,
    dailyGoal: 3,
    dailyProgress: 0,
    lessonAttempts: 0,
    speechAttempts: 0,
    rewardChestsOpened: 0,
    rewardHistory: [],
    completedLessons: [],
    knowledgeStates: [],
    hafizProgress: [],
    learningGoal: null,
    placementLevel: 1,
    learningRecommendation: null,
    nativeLanguage: null,
    soundEnabled: true,
    updatedAt: new Date().toISOString(),
  };
}

export function profile(document, user) {
  return {
    ...defaultProgress(user),
    ...(document && typeof document === 'object' ? document : {}),
    user: user.id,
    displayName: user.display_name,
    email: user.email,
  };
}

function safeList(value) {
  return Array.isArray(value) ? value.slice(0, maxListItems) : [];
}

function safeString(value, max = 500) {
  if (value == null) return null;
  return String(value).trim().slice(0, max);
}

function safeInt(value, min, max) {
  const number = Number(value);
  if (!Number.isFinite(number)) return min;
  return Math.min(max, Math.max(min, Math.floor(number)));
}

function validDate(value) {
  const timestamp = Date.parse(String(value ?? ''));
  return Number.isFinite(timestamp) ? timestamp : 0;
}

function mergeObjectsById(serverItems, clientItems) {
  const merged = new Map();
  for (const item of [...safeList(serverItems), ...safeList(clientItems)]) {
    if (!item || typeof item !== 'object') continue;
    const id = safeString(item.id ?? `${item.surahNumber}:${item.verseNumber}`, 100);
    if (!id) continue;
    const previous = merged.get(id);
    if (!previous || validDate(item.lastReviewedAt) >= validDate(previous.lastReviewedAt)) {
      merged.set(id, item);
    }
  }
  return [...merged.values()].slice(0, maxListItems);
}

export function mergeLearningState(server, incoming, { importGuest = false } = {}) {
  const next = { ...server };
  const completed = new Set([
    ...safeList(server.completedLessons).filter((value) => typeof value === 'string'),
    ...safeList(incoming.completedLessons).filter((value) => typeof value === 'string'),
  ]);
  next.completedLessons = [...completed].slice(0, 500);
  next.knowledgeStates = mergeObjectsById(server.knowledgeStates, incoming.knowledgeStates);
  next.hafizProgress = mergeObjectsById(server.hafizProgress, incoming.hafizProgress);
  next.learningGoal = safeString(incoming.learningGoal, 40) ?? server.learningGoal ?? null;
  next.placementLevel = safeInt(incoming.placementLevel ?? server.placementLevel, 1, 8);
  next.learningRecommendation = safeString(incoming.learningRecommendation, 500) ?? server.learningRecommendation ?? null;
  next.nativeLanguage = safeString(incoming.nativeLanguage, 8) ?? server.nativeLanguage ?? null;
  if (typeof incoming.soundEnabled === 'boolean') next.soundEnabled = incoming.soundEnabled;
  next.dailyGoal = safeInt(incoming.dailyGoal ?? server.dailyGoal, 1, 20);

  if (importGuest) {
    for (const field of ['xp', 'streak', 'energy', 'totalLessons', 'totalMinutes', 'learnedAyats', 'learnedDuas', 'dailyProgress', 'lessonAttempts', 'speechAttempts', 'rewardChestsOpened']) {
      next[field] = Math.max(safeInt(server[field], 0, 1_000_000), safeInt(incoming[field], 0, 1_000_000));
    }
    next.level = Math.floor(next.xp / 500) + 1;
    next.hearts = safeInt(incoming.hearts ?? server.hearts, 0, 5);
    next.rewardHistory = safeList(incoming.rewardHistory)
      .filter((value) => typeof value === 'string')
      .slice(-500);
    const incomingStudy = safeString(incoming.lastStudyDay, 10);
    if (incomingStudy && /^\d{4}-\d{2}-\d{2}$/.test(incomingStudy)) next.lastStudyDay = incomingStudy;
  }

  next.updatedAt = new Date().toISOString();
  return next;
}
