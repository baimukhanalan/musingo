// Shared by the single Vercel API router.
//
// POST /api/coach — серверный AI-наставник поверх Groq. Работает и для гостей
// (optionalUser). У залогиненных пользователей контекст обогащается данными из
// muslingo_progress поверх присланного тела. Ключ Groq берётся только из env
// (см. server/lib/groq.js); при его отсутствии роут отдаёт 503 coach_unavailable,
// и клиент откатывается на локальный движок.
import { optionalUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { method, readJson, withApi } from '../lib/http.js';
import { profile } from '../lib/progress.js';
import { callGroq, hasGroqKey } from '../lib/groq.js';

const MAX_QUESTION = 1000;
const MAX_STRING = 200;
const MAX_LIST = 50;
const MAX_CATALOG = 200;
const LOCALES = new Set(['ru', 'kk', 'en']);

function clampString(value, max = MAX_STRING) {
  return String(value ?? '').trim().slice(0, Math.max(0, max));
}

function clampLocale(value) {
  const locale = String(value ?? '').trim().toLowerCase();
  return LOCALES.has(locale) ? locale : 'ru';
}

function clampInt(value, min, max) {
  const number = Number(value);
  if (!Number.isFinite(number)) return min;
  return Math.min(max, Math.max(min, Math.floor(number)));
}

function clampStringList(value, { maxItems = MAX_LIST, maxLen = MAX_STRING } = {}) {
  if (!Array.isArray(value)) return [];
  return value
    .filter((item) => typeof item === 'string')
    .map((item) => clampString(item, maxLen))
    .filter(Boolean)
    .slice(0, maxItems);
}

// Каталог уроков от клиента: список {id,title,course}. Чистим и клампим, чтобы
// не раздувать промпт и не пропускать мусор в модель.
function clampCatalog(value) {
  if (!Array.isArray(value)) return [];
  const seen = new Set();
  const out = [];
  for (const raw of value) {
    if (!raw || typeof raw !== 'object') continue;
    const id = clampString(raw.id, 100);
    if (!id || seen.has(id)) continue;
    seen.add(id);
    out.push({
      id,
      title: clampString(raw.title, MAX_STRING),
      course: clampString(raw.course, 80),
    });
    if (out.length >= MAX_CATALOG) break;
  }
  return out;
}

// Чистая тестируемая функция: строит рабочий контекст ученика из присланного
// тела и (опционально) документа прогресса из БД. Значения из документа имеют
// приоритет над клиентскими, так как это авторитетный серверный источник.
export function buildCoachContext(bodyContext = {}, progressDocument = null) {
  const ctx = bodyContext && typeof bodyContext === 'object' ? bodyContext : {};
  const context = {
    xp: clampInt(ctx.xp, 0, 10_000_000),
    level: clampInt(ctx.level, 1, 1000),
    streak: clampInt(ctx.streak, 0, 100_000),
    accuracy: clampInt(ctx.accuracy, 0, 100),
    totalLessons: clampInt(ctx.totalLessons, 0, 100_000),
    completedLessonIds: clampStringList(ctx.completedLessonIds, { maxItems: MAX_LIST, maxLen: 100 }),
    weakAreas: clampStringList(ctx.weakAreas, { maxItems: MAX_LIST, maxLen: 120 }),
    recommendedLessonId: clampString(ctx.recommendedLessonId, 100) || null,
    recommendedLessonTitle: clampString(ctx.recommendedLessonTitle, MAX_STRING) || null,
    dueReviewCount: clampInt(ctx.dueReviewCount, 0, 100_000),
  };

  if (progressDocument && typeof progressDocument === 'object') {
    // Авторитетные значения из БД перекрывают присланные клиентом.
    if (Number.isFinite(Number(progressDocument.xp))) {
      context.xp = clampInt(progressDocument.xp, 0, 10_000_000);
      context.level = Math.floor(context.xp / 500) + 1;
    }
    if (Number.isFinite(Number(progressDocument.streak))) {
      context.streak = clampInt(progressDocument.streak, 0, 100_000);
    }
    if (Number.isFinite(Number(progressDocument.totalLessons))) {
      context.totalLessons = clampInt(progressDocument.totalLessons, 0, 100_000);
    }
    if (Array.isArray(progressDocument.completedLessons)) {
      context.completedLessonIds = clampStringList(progressDocument.completedLessons, {
        maxItems: MAX_LIST,
        maxLen: 100,
      });
    }
    // knowledgeStates -> число «слабых»/просроченных карточек как ориентир.
    if (Array.isArray(progressDocument.knowledgeStates)) {
      const now = Date.now();
      const due = progressDocument.knowledgeStates.filter((state) => {
        if (!state || typeof state !== 'object') return false;
        const dueAt = Date.parse(String(state.dueAt ?? state.nextReviewAt ?? ''));
        return Number.isFinite(dueAt) ? dueAt <= now : false;
      }).length;
      if (due > 0) context.dueReviewCount = clampInt(due, 0, 100_000);
    }
    if (progressDocument.learningRecommendation && !context.recommendedLessonId) {
      context.recommendedLessonTitle = clampString(progressDocument.learningRecommendation, MAX_STRING);
    }
  }

  return context;
}

// Чистая тестируемая функция: собирает SYSTEM-промпт наставника.
export function buildSystemPrompt(locale) {
  const lang = clampLocale(locale);
  const langName = lang === 'kk' ? 'казахском (kk)' : lang === 'en' ? 'английском (en)' : 'русском (ru)';
  return [
    'Ты — тёплый знающий наставник в приложении Muslingo по изучению Корана, арабского и основ ислама.',
    'Тебе дают данные ученика (context) — используй их, чтобы отвечать персонально.',
    'Помогай: подсказывай что учить дальше (рекомендуй урок по id из catalog или recommendedLessonId),',
    'объясняй суры, таджвид и арабский, мотивируй ученика.',
    'Правила:',
    `- отвечай на языке locale — на ${langName};`,
    '- по Корану опирайся на общепризнанные смыслы;',
    '- сложные вопросы фикха, фетвы и спорные темы НЕ решай сам — мягко направь к квалифицированному специалисту',
    '  (в приложении есть кнопка «спросить специалиста», используй action contactSpecialist);',
    '- без сектантских утверждений;',
    '- отвечай кратко и по делу.',
    'Верни СТРОГО JSON-объект такого вида:',
    '{"reply": string, "action"?: {"type": "startLesson"|"openQuran"|"contactSpecialist", "lessonId"?: string, "label"?: string}, "sources"?: string[]}.',
    'Поле reply обязательно. lessonId в action бери из catalog/recommendedLessonId. Ничего кроме JSON не пиши.',
  ].join('\n');
}

// Чистая тестируемая функция: собирает USER-сообщение (JSON контекста + вопрос).
export function buildUserMessage({ question, locale, context, catalog }) {
  return JSON.stringify({
    locale: clampLocale(locale),
    student: context,
    catalog: Array.isArray(catalog) ? catalog : [],
    question: clampString(question, MAX_QUESTION),
    instruction: 'Ответь строго JSON-объектом {reply, action?, sources?} на языке locale.',
  });
}

// Разбор ответа Groq (он приходит JSON-строкой). При сбое парсинга — дефолт с
// сырым текстом в reply.
export function parseCoachReply(raw) {
  const fallback = { text: String(raw ?? '').trim() };
  let parsed;
  try {
    parsed = JSON.parse(raw);
  } catch {
    return fallback;
  }
  if (!parsed || typeof parsed !== 'object') return fallback;

  const text = clampString(parsed.reply, 4000) || fallback.text;
  const result = { text };

  const action = parsed.action;
  const allowedActions = new Set(['startLesson', 'openQuran', 'contactSpecialist']);
  if (action && typeof action === 'object' && allowedActions.has(action.type)) {
    const clean = { type: action.type };
    const lessonId = clampString(action.lessonId, 100);
    if (lessonId) clean.lessonId = lessonId;
    const label = clampString(action.label, MAX_STRING);
    if (label) clean.label = label;
    result.action = clean;
  }

  if (Array.isArray(parsed.sources)) {
    const sources = clampStringList(parsed.sources, { maxItems: 10, maxLen: 300 });
    if (sources.length > 0) result.sources = sources;
  }

  return result;
}

export default withApi(async (request, response) => {
  method(request, ['POST']);

  // Быстрый выход без ключа: коуч не настроен — клиент откатится на локальный
  // движок. Проверяем до любых обращений к БД/сети.
  if (!hasGroqKey()) {
    return response.status(503).json({ error: 'coach_unavailable', message: 'AI coach is not configured.' });
  }

  // Гостю тоже отвечаем. Токен опционален.
  const user = await optionalUser(request);
  const body = readJson(request);

  const question = clampString(body.question, MAX_QUESTION);
  const locale = clampLocale(body.locale);
  const catalog = clampCatalog(body.catalog);

  let progressDocument = null;
  if (user) {
    try {
      const rows = await sql`
        SELECT document
        FROM muslingo_progress
        WHERE user_id = ${user.id}::uuid
        LIMIT 1
      `;
      if (rows.length > 0) {
        progressDocument = profile(rows[0].document, user);
      }
    } catch {
      // Обогащение из БД — «best effort»; при сбое работаем на клиентском контексте.
      progressDocument = null;
    }
  }

  const context = buildCoachContext(body.context, progressDocument);
  const system = buildSystemPrompt(locale);
  const userMessage = buildUserMessage({ question, locale, context, catalog });

  // callGroq бросит ApiError 503 coach_unavailable при сбое/таймауте — withApi
  // отдаст его как чистый HTTP 503.
  const raw = await callGroq({ system, user: userMessage, temperature: 0.4, maxTokens: 700 });
  const reply = parseCoachReply(raw);

  return response.status(200).json({
    text: reply.text,
    action: reply.action ?? null,
    sources: reply.sources ?? [],
  });
});
