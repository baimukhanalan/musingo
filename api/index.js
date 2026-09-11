import account from '../server/routes/account.js';
import authLogin from '../server/routes/auth-login.js';
import authLogout from '../server/routes/auth-logout.js';
import authMe from '../server/routes/auth-me.js';
import authPassword from '../server/routes/auth-password.js';
import authPasswordForgot from '../server/routes/auth-password-forgot.js';
import authPasswordReset from '../server/routes/auth-password-reset.js';
import authRegister from '../server/routes/auth-register.js';
import authVerificationConfirm from '../server/routes/auth-verification-confirm.js';
import authVerificationRequest from '../server/routes/auth-verification-request.js';
import coach from '../server/routes/coach.js';
import cronReminders from '../server/routes/cron-reminders.js';
import friends from '../server/routes/friends.js';
import health from '../server/routes/health.js';
import leaderboard from '../server/routes/leaderboard.js';
import progressAttempt from '../server/routes/progress-attempt.js';
import progressComplete from '../server/routes/progress-complete.js';
import progressRestoreHeart from '../server/routes/progress-restore-heart.js';
import progressStep from '../server/routes/progress-step.js';
import progressSync from '../server/routes/progress-sync.js';
import pushPublicKey from '../server/routes/push-public-key.js';
import pushSubscribe from '../server/routes/push-subscribe.js';
import pushUnsubscribe from '../server/routes/push-unsubscribe.js';
import speechEvaluate from '../server/routes/speech-evaluate.js';
import speechCapabilities from '../server/routes/speech-capabilities.js';

const COACH_STRING_LIMIT = 200;
const COACH_LIST_LIMIT = 20;
const COACH_CATALOG_LIMIT = 600;
const COACH_SKILLS = ['letters', 'reading', 'surahRecall', 'meaning', 'tajwid'];
const COACH_LOCALES = new Set(['ru', 'kk', 'en']);
const COACH_CONTEXT_FIELDS = [
  'xp', 'level', 'streak', 'accuracy', 'totalLessons', 'totalCatalogLessons',
  'placementLevel', 'goal', 'goalTitle', 'skillProfile', 'recommendation',
  'todayProgress', 'dailyGoal', 'memorizedVerseCount', 'hafizDueCount',
  'quranCompleted', 'arabicCompleted', 'basicsCompleted', 'tajwidCompleted',
  'completedLessonIds', 'completedLessonTitles', 'weakAreas',
  'recommendedLessonId', 'recommendedLessonTitle', 'dueReviewCount',
];

function coachString(value, max = COACH_STRING_LIMIT) {
  return String(value ?? '').trim().slice(0, Math.max(0, max));
}

function coachInt(value, min, max, fallback = min) {
  const number = Number(value);
  if (!Number.isFinite(number)) return fallback;
  return Math.min(max, Math.max(min, Math.floor(number)));
}

function coachStringList(value, maxItems = COACH_LIST_LIMIT) {
  if (!Array.isArray(value)) return [];
  return [...new Set(value
    .filter((item) => typeof item === 'string')
    .map((item) => coachString(item, 120))
    .filter(Boolean))].slice(0, maxItems);
}

function coachCatalog(value) {
  if (!Array.isArray(value)) return [];
  const seen = new Set();
  const catalog = [];
  for (const raw of value) {
    if (!raw || typeof raw !== 'object') continue;
    const id = coachString(raw.id, 100);
    if (!id || seen.has(id)) continue;
    seen.add(id);
    catalog.push({
      id,
      title: coachString(raw.title),
      subtitle: coachString(raw.subtitle),
      course: coachString(raw.course, 80),
      order: coachInt(raw.order, 0, 1000),
      completed: raw.completed === true,
    });
    if (catalog.length >= COACH_CATALOG_LIMIT) break;
  }
  return catalog;
}

function coachLocale(value) {
  const locale = coachString(value, 8).toLowerCase();
  return COACH_LOCALES.has(locale) ? locale : 'ru';
}

function coachSkills(value) {
  if (!value || typeof value !== 'object') return null;
  return Object.fromEntries(COACH_SKILLS.map((skill) => [
    skill,
    coachInt(value[skill], 0, 100),
  ]));
}

function weakSignals(context) {
  const signals = [];
  const append = (raw, fallbackKind = 'skill') => {
    if (typeof raw === 'string') {
      const label = coachString(raw, 120);
      if (label) signals.push({ label, kind: fallbackKind, lessonId: null, strength: null, lapses: 0 });
      return;
    }
    if (!raw || typeof raw !== 'object') return;
    const label = coachString(raw.label ?? raw.title ?? raw.id, 120);
    if (!label) return;
    signals.push({
      id: coachString(raw.id, 100) || null,
      label,
      kind: coachString(raw.kind ?? fallbackKind, 40) || fallbackKind,
      lessonId: coachString(raw.lessonId, 100) || null,
      strength: Number.isFinite(Number(raw.strength))
        ? Math.min(1, Math.max(0, Number(raw.strength) > 1
          ? Number(raw.strength) / 100
          : Number(raw.strength)))
        : null,
      lapses: coachInt(raw.lapses, 0, 1000),
    });
  };
  for (const raw of Array.isArray(context.weakKnowledge) ? context.weakKnowledge : []) append(raw);
  for (const raw of Array.isArray(context.weakSteps) ? context.weakSteps : []) append(raw, 'step');
  for (const raw of Array.isArray(context.weakAreas) ? context.weakAreas : []) append(raw);
  for (const lessonId of coachStringList(context.weakLessonIds)) {
    append({ label: lessonId, lessonId }, 'lesson');
  }
  const deduped = new Map();
  for (const signal of signals) {
    const key = `${signal.lessonId ?? ''}:${signal.kind}:${signal.label}`;
    const previous = deduped.get(key);
    if (!previous || signal.lapses > previous.lapses ||
        (signal.strength ?? 101) < (previous.strength ?? 101)) {
      deduped.set(key, signal);
    }
  }
  return [...deduped.values()]
    .sort((a, b) => b.lapses - a.lapses || (a.strength ?? 101) - (b.strength ?? 101))
    .slice(0, COACH_LIST_LIMIT);
}

function dueSignals(context, now) {
  const rawItems = [
    ...(Array.isArray(context.dueItems) ? context.dueItems : []),
    ...(Array.isArray(context.spacedRepetitionDueItems) ? context.spacedRepetitionDueItems : []),
  ];
  const items = [];
  for (const raw of rawItems) {
    if (!raw || typeof raw !== 'object') continue;
    const dueAt = Date.parse(String(raw.dueAt ?? raw.nextReviewAt ?? ''));
    if (Number.isFinite(dueAt) && dueAt > now) continue;
    const label = coachString(raw.label ?? raw.title ?? raw.id, 120);
    if (!label) continue;
    items.push({
      label,
      lessonId: coachString(raw.lessonId, 100) || null,
      dueAt: Number.isFinite(dueAt) ? new Date(dueAt).toISOString() : null,
    });
    if (items.length >= COACH_LIST_LIMIT) break;
  }
  return items;
}

function localizedReason(locale, kind, detail) {
  const text = {
    ru: {
      due: `Сначала повторение: ${detail} уже подошли по интервальному расписанию.`,
      weak: `Следующим выбран слабый элемент «${detail}», чтобы ошибка не закрепилась.`,
      skill: `Следующим выбран урок для навыка «${detail}», где сейчас самый низкий результат.`,
      goal: `Следующий урок напрямую поддерживает цель «${detail}».`,
      continue: 'Следующий незавершённый урок сохраняет последовательность курса.',
    },
    kk: {
      due: `Алдымен қайталау: ${detail} аралық кесте бойынша пісіп жетілді.`,
      weak: `Қате бекіп қалмауы үшін «${detail}» әлсіз элементі таңдалды.`,
      skill: `Қазір нәтижесі ең төмен «${detail}» дағдысына арналған сабақ таңдалды.`,
      goal: `Келесі сабақ «${detail}» мақсатын тікелей қолдайды.`,
      continue: 'Келесі аяқталмаған сабақ курс ретін сақтайды.',
    },
    en: {
      due: `Review comes first: ${detail} are due in the spaced-repetition schedule.`,
      weak: `The weak item “${detail}” is next so the error does not become habitual.`,
      skill: `The next lesson targets “${detail}”, currently the lowest-scoring skill.`,
      goal: `The next lesson directly supports the goal “${detail}”.`,
      continue: 'The next incomplete lesson preserves the course sequence.',
    },
  };
  return text[locale][kind];
}

export function buildPersonalizedCoachPlan(rawContext = {}, rawCatalog = [], options = {}) {
  const context = rawContext && typeof rawContext === 'object' && !Array.isArray(rawContext)
    ? rawContext
    : {};
  const catalog = coachCatalog(rawCatalog);
  const catalogById = new Map(catalog.map((lesson) => [lesson.id, lesson]));
  const locale = coachLocale(options.locale ?? context.language ?? context.nativeLanguage);
  const now = Number.isFinite(Number(options.now)) ? Number(options.now) : Date.now();
  const availableMinutes = coachInt(context.availableMinutes, 1, 60, 6);
  const skills = coachSkills(context.skillProfile);
  const weak = weakSignals(context);
  const due = dueSignals(context, now);
  const dueCount = Math.max(
    due.length,
    coachInt(context.dueReviewCount, 0, 10_000) +
      coachInt(context.hafizDueCount, 0, 10_000),
  );
  const knownSurahs = coachStringList(context.knownSurahs, 50);
  const recentAccuracy = coachInt(
    context.recentAccuracy ?? context.accuracy,
    0,
    100,
  );
  const streak = coachInt(context.streak, 0, 100_000);
  const goal = coachString(context.goalTitle ?? context.goal, 120) || null;
  const weakestSkill = skills
    ? Object.entries(skills).sort((a, b) => a[1] - b[1])[0]
    : null;
  const recommendedId = coachString(context.recommendedLessonId, 100);
  const weakCatalogLesson = weak
    .map((item) => item.lessonId && catalogById.get(item.lessonId))
    .find(Boolean);
  const skillCourse = {
    letters: 'arabic',
    reading: 'arabic',
    surahRecall: 'quran',
    meaning: 'quran',
    tajwid: 'tajwid',
  }[weakestSkill?.[0]];
  const normalizedGoal = coachString(context.goal, 80).toLowerCase();
  const goalCourse = /tajwid|pronunciation|махрадж|произнош/.test(normalizedGoal)
    ? 'tajwid'
    : /arabic|reading|letters|араб|чтен/.test(normalizedGoal)
      ? 'arabic'
      : /basics|islam|основ/.test(normalizedGoal)
        ? 'basics'
        : /quran|surah|memor|коран|сур|хафиз/.test(normalizedGoal)
          ? 'quran'
          : null;
  const preferredCourse = skillCourse ?? goalCourse;
  const nextLesson = catalogById.get(recommendedId) ??
    weakCatalogLesson ??
    catalog.find((lesson) => !lesson.completed && (!preferredCourse || lesson.course === preferredCourse)) ??
    catalog.find((lesson) => !lesson.completed) ??
    null;

  const items = [];
  let minutesLeft = availableMinutes;
  const addItem = (item, wantedMinutes) => {
    if (minutesLeft <= 0) return;
    const minutes = Math.max(1, Math.min(minutesLeft, wantedMinutes));
    items.push({ priority: items.length + 1, ...item, minutes });
    minutesLeft -= minutes;
  };
  if (dueCount > 0) {
    const dueLesson = due.map((item) => item.lessonId && catalogById.get(item.lessonId)).find(Boolean);
    addItem({
      type: 'spacedReview',
      label: due[0]?.label || `${dueCount} review items`,
      count: dueCount,
      ...(dueLesson ? { lessonId: dueLesson.id } : {}),
    }, Math.min(3, Math.max(1, Math.ceil(dueCount / 2))));
  }
  if (weak.length > 0) {
    const weakLesson = weak[0].lessonId && catalogById.get(weak[0].lessonId);
    addItem({
      type: 'weaknessPractice',
      label: weak[0].label,
      ...(weakLesson ? { lessonId: weakLesson.id } : {}),
    }, 2);
  }
  if (nextLesson) {
    addItem({
      type: 'lesson',
      label: nextLesson.title || nextLesson.id,
      lessonId: nextLesson.id,
    }, Math.max(1, minutesLeft));
  }
  if (items.length === 0) {
    addItem({ type: 'practice', label: goal || 'Daily practice' }, availableMinutes);
  }

  let reasonKind = 'continue';
  let reasonDetail = '';
  if (dueCount > 0) {
    reasonKind = 'due';
    reasonDetail = String(dueCount);
  } else if (weak.length > 0) {
    reasonKind = 'weak';
    reasonDetail = weak[0].label;
  } else if (weakestSkill) {
    reasonKind = 'skill';
    reasonDetail = weakestSkill[0];
  } else if (goal) {
    reasonKind = 'goal';
    reasonDetail = goal;
  }
  const whyNext = localizedReason(locale, reasonKind, reasonDetail);
  return {
    version: 1,
    locale,
    availableMinutes,
    recentAccuracy,
    streak,
    knownSurahs,
    focusSkill: weakestSkill?.[0] ?? null,
    items,
    whyNext,
    recommendedLessonId: nextLesson?.id ?? null,
    recommendedLessonTitle: nextLesson?.title || nextLesson?.id || null,
    weakLabels: weak.map((item) => item.label),
    dueReviewCount: dueCount,
    catalogLessonIds: catalog.map((lesson) => lesson.id),
  };
}

export function personalizeCoachRequest(request) {
  const body = request?.body;
  if (!body || typeof body !== 'object' || Array.isArray(body) || Buffer.isBuffer(body)) {
    return { request, plan: null };
  }
  const context = body.context && typeof body.context === 'object' && !Array.isArray(body.context)
    ? body.context
    : {};
  const plan = buildPersonalizedCoachPlan(context, body.catalog, { locale: body.locale });
  const sanitizedWeak = weakSignals(context);
  const sanitizedDue = dueSignals(context, Date.now());
  const mergedWeakAreas = [...new Set([
    ...coachStringList(context.weakAreas),
    ...plan.weakLabels,
  ])].slice(0, COACH_LIST_LIMIT);
  const planSummary = `${plan.whyNext} Daily plan (${plan.availableMinutes} min): ${plan.items
    .map((item) => `${item.priority}. ${item.label} (${item.minutes} min)`)
    .join('; ')}`;
  const safeContext = Object.fromEntries(COACH_CONTEXT_FIELDS
    .filter((field) => Object.hasOwn(context, field))
    .map((field) => [field, context[field]]));
  const enhancedContext = {
    ...safeContext,
    accuracy: plan.recentAccuracy,
    streak: plan.streak,
    dueReviewCount: plan.dueReviewCount,
    weakAreas: mergedWeakAreas,
    completedLessonTitles: [...new Set([
      ...coachStringList(context.completedLessonTitles),
      ...plan.knownSurahs,
    ])].slice(0, COACH_LIST_LIMIT),
    weakKnowledge: sanitizedWeak,
    weakLessonIds: [...new Set(sanitizedWeak.map((item) => item.lessonId).filter(Boolean))],
    dueItems: sanitizedDue,
    knownSurahs: plan.knownSurahs,
    recentAccuracy: plan.recentAccuracy,
    availableMinutes: plan.availableMinutes,
    language: plan.locale,
    recommendedLessonId: plan.recommendedLessonId ?? context.recommendedLessonId,
    recommendedLessonTitle: plan.recommendedLessonTitle ?? context.recommendedLessonTitle,
    recommendation: coachString(
      [coachString(context.recommendation, 220), planSummary].filter(Boolean).join(' '),
      500,
    ),
  };
  return {
    request: {
      ...request,
      body: {
        question: body.question,
        locale: body.locale,
        catalog: coachCatalog(body.catalog),
        context: enhancedContext,
      },
    },
    plan,
  };
}

const routes = new Map([
  ['account', account],
  ['auth/login', authLogin],
  ['auth/logout', authLogout],
  ['auth/me', authMe],
  ['auth/password', authPassword],
  ['auth/password/forgot', authPasswordForgot],
  ['auth/password/reset', authPasswordReset],
  ['auth/register', authRegister],
  ['auth/verification/confirm', authVerificationConfirm],
  ['auth/verification/request', authVerificationRequest],
  ['coach', coach],
  ['cron/reminders', cronReminders],
  ['friends', friends],
  ['health', health],
  ['leaderboard', leaderboard],
  ['progress/attempt', progressAttempt],
  ['progress/complete', progressComplete],
  ['progress/restore-heart', progressRestoreHeart],
  ['progress/step', progressStep],
  ['progress/sync', progressSync],
  ['push/public-key', pushPublicKey],
  ['push/subscribe', pushSubscribe],
  ['push/unsubscribe', pushUnsubscribe],
  ['speech/evaluate', speechEvaluate],
  ['speech/capabilities', speechCapabilities],
]);

export default async function handler(request, response) {
  const pathname = new URL(request.url, 'https://muslingo.local').pathname;
  const rewrittenRoute = request.query?.route;
  const route = String(
    Array.isArray(rewrittenRoute) ? rewrittenRoute.join('/') : rewrittenRoute ?? '',
  ) || pathname.replace(/^\/api\/?/, '').replace(/\/$/, '');
  const selected = routes.get(route);
  if (!selected) {
    response.setHeader('Cache-Control', 'no-store');
    return response.status(404).json({ error: 'not_found', message: 'API route not found.' });
  }
  if (route === 'coach') {
    // Normalize client signals here, then let the route merge authoritative DB
    // progress and build the final plan. The client-only preview never replaces
    // signed-in progress or the route's source-grounded dailyPlan/whyNext.
    return selected(personalizeCoachRequest(request).request, response);
  }
  return selected(request, response);
}
