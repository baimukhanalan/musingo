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
    leaderboardXpToday: 0,
    leaderboardXpDay: '',
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
    // Everything below is fully client-controlled guest data. We keep the
    // larger of the server value and the incoming value (so a real prior sync
    // is never lost) but clamp each to what an honest player could plausibly
    // reach, and keep the numbers consistent with each other. The previous
    // 1_000_000 cap let a guest import land straight at the top of the
    // leaderboard.
    const pick = (field, cap) =>
      Math.max(safeInt(server[field], 0, cap), safeInt(incoming[field], 0, cap));

    const HARD_XP_CAP = 50_000;      // absolute XP ceiling for an import — a very dedicated long-term player.
    const PER_LESSON_XP = 1_000;     // XP head-room per distinct completed lesson: 25 XP first pass + ~195 replays * 5 XP.
    const STREAK_CAP = 400;          // days — beyond ~13 months of unbroken daily study it is not credible.
    const TOTAL_LESSONS_CAP = 1_000; // total lesson completions, repeats included.
    const ENERGY_CAP = 999;          // mirrors the energy ceiling used in progress-complete.js.
    const MINUTES_PER_LESSON = 10;   // each completion books 5 min; 10 leaves honest head-room.

    next.streak = pick('streak', STREAK_CAP);
    // Streak milestone bonuses an honest player could have banked, mirroring
    // progress-complete.js (7 -> +10, 30 -> +50, 100 -> +200).
    const streakBonus =
      (next.streak >= 7 ? 10 : 0) + (next.streak >= 30 ? 50 : 0) + (next.streak >= 100 ? 200 : 0);
    // XP head-room is derived from the lessons the user actually completed, so
    // an import can never claim more XP than their lesson history could yield.
    const xpCap = Math.min(HARD_XP_CAP, next.completedLessons.length * PER_LESSON_XP + streakBonus);
    next.xp = pick('xp', xpCap);
    // Level is always recomputed from the clamped XP so a guest can never
    // self-declare a level out of line with it.
    next.level = Math.floor(next.xp / 500) + 1;

    next.totalLessons = pick('totalLessons', TOTAL_LESSONS_CAP);
    next.totalMinutes = pick('totalMinutes', next.totalLessons * MINUTES_PER_LESSON);
    next.energy = pick('energy', ENERGY_CAP);
    next.hearts = safeInt(incoming.hearts ?? server.hearts, 0, 5);

    // Remaining counters do not feed the leaderboard, but are still bounded to
    // app-plausible ranges and kept consistent with the lesson totals above.
    next.learnedAyats = pick('learnedAyats', 300);              // a few short surahs' worth of ayats.
    next.learnedDuas = pick('learnedDuas', 100);
    next.dailyProgress = pick('dailyProgress', next.dailyGoal); // can never exceed the daily goal.
    next.lessonAttempts = pick('lessonAttempts', next.totalLessons * 3);         // <= ~3 tries per completion.
    next.speechAttempts = pick('speechAttempts', next.totalLessons * 50);        // <= 50 speech tries per completion.
    next.rewardChestsOpened = pick('rewardChestsOpened', next.totalLessons * 3); // +3 chests per completion.

    next.rewardHistory = safeList(incoming.rewardHistory)
      .filter((value) => typeof value === 'string')
      .slice(-500);
    const incomingStudy = safeString(incoming.lastStudyDay, 10);
    if (incomingStudy && /^\d{4}-\d{2}-\d{2}$/.test(incomingStudy)) next.lastStudyDay = incomingStudy;
  }

  next.updatedAt = new Date().toISOString();
  return next;
}

// A rewardToken uniquely identifies one lesson-completion reward. The client
// (app_state.dart `_rewardTokenFor`) builds it as
// `${course}:${accuracy}:${epochMillis}`, and the server keeps the last 500 in
// rewardHistory. If this exact token is already stored, the completion request
// is a replay of a reward we already granted and must not earn XP / energy /
// weekly_xp again. Exact-string matching is correct: the client sends back the
// very token it generated, so equality is the right (and only needed) check.
export function isRewardReplay(rewardHistory, rewardToken) {
  if (!rewardToken) return false;
  const history = Array.isArray(rewardHistory) ? rewardHistory : [];
  return history.includes(rewardToken);
}

// Per-local-day ceiling on how much XP a single user can push into the weekly
// leaderboard column (weekly_xp). Personal xp/level are NOT limited by this —
// only the leaderboard contribution is. Without a daily cap, a script could
// repeat a lesson (each replay earns 5 XP with a fresh rewardToken) hundreds of
// times in a day and ride weekly_xp into the top 50.
export const LEADERBOARD_DAILY_XP_CAP = 200;

// Compute how much of an already-earned XP amount (first pass 25, replay 5, plus
// any streak bonus) is allowed to reach weekly_xp today, given the per-day cap,
// and return the day-scoped counter to persist in the progress document.
//
// - `current`  : the profile read from the row (holds the running counter).
// - `today`    : the validated local day (YYYY-MM-DD) for this completion.
// - `earned`   : the XP this completion earned (personal), before clipping.
//
// On a new local day the counter resets to 0 before this completion is counted,
// so yesterday's usage never restricts today. The returned `contribution` is the
// clipped amount to add to weekly_xp; `leaderboardXpToday`/`leaderboardXpDay` are
// the counter values to write back under the same optimistic-lock version so a
// retry recomputes them from the freshly re-read row.
export function leaderboardContribution({ current, today, earned }) {
  const cap = LEADERBOARD_DAILY_XP_CAP;
  const sameDay = Boolean(current) && current.leaderboardXpDay === today;
  const usedToday = sameDay ? Math.max(0, Math.floor(Number(current.leaderboardXpToday) || 0)) : 0;
  const remaining = Math.max(0, cap - usedToday);
  const want = Math.max(0, Math.floor(Number(earned) || 0));
  const contribution = Math.min(want, remaining);
  return {
    contribution,
    leaderboardXpToday: usedToday + contribution,
    leaderboardXpDay: today,
  };
}

// dailyProgress must reflect TODAY only. On a new local day it restarts at 1;
// on the same day it increments, capped at the user's dailyGoal. The previous
// `dailyProgress + 1` grew monotonically forever and never reset at midnight.
export function nextDailyProgress({ current, today }) {
  const goal = Math.max(1, Math.floor(Number(current?.dailyGoal) || 3));
  const newDay = String(current?.lastStudyDay ?? '') !== today;
  const base = newDay ? 0 : Math.max(0, Math.floor(Number(current?.dailyProgress) || 0));
  return Math.min(goal, base + 1);
}
