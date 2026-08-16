import assert from 'node:assert/strict';
import test from 'node:test';

import coach, {
  buildCoachContext,
  buildSystemPrompt,
  buildUserMessage,
  parseCoachReply,
} from '../server/routes/coach.js';

// Минимальный мок ответа Vercel-стиля: собирает статус/заголовки/тело.
function mockResponse() {
  return {
    statusCode: null,
    body: null,
    headers: {},
    setHeader(name, value) {
      this.headers[name.toLowerCase()] = value;
    },
    status(code) {
      this.statusCode = code;
      return this;
    },
    json(payload) {
      this.body = payload;
      return this;
    },
    end() {
      return this;
    },
  };
}

test('route returns 503 coach_unavailable when GROQ_API_KEY is absent', async () => {
  const previous = process.env.GROQ_API_KEY;
  delete process.env.GROQ_API_KEY;
  try {
    const request = {
      method: 'POST',
      headers: {},
      body: { question: 'Что учить дальше?', locale: 'ru' },
    };
    const response = mockResponse();
    await coach(request, response);
    assert.equal(response.statusCode, 503);
    assert.equal(response.body.error, 'coach_unavailable');
  } finally {
    if (previous === undefined) delete process.env.GROQ_API_KEY;
    else process.env.GROQ_API_KEY = previous;
  }
});

test('buildCoachContext validates and clamps client body', () => {
  const context = buildCoachContext({
    xp: '1250',
    level: 3,
    streak: -5,
    accuracy: 250,
    totalLessons: 12,
    placementLevel: 99,
    dailyGoal: 0,
    hafizDueCount: 3,
    completedLessonIds: ['a', 42, 'b', ''],
    weakAreas: ['таджвид', 123],
    recommendedLessonId: 'lesson-7',
    recommendedLessonTitle: 'Сура Аль-Фатиха',
    dueReviewCount: 4,
  });
  assert.equal(context.xp, 1250);
  assert.equal(context.streak, 0); // negative clamped
  assert.equal(context.accuracy, 100); // clamped to max
  assert.equal(context.placementLevel, 8);
  assert.equal(context.dailyGoal, 1);
  assert.equal(context.hafizDueCount, 3);
  assert.deepEqual(context.completedLessonIds, ['a', 'b']); // non-strings dropped
  assert.deepEqual(context.weakAreas, ['таджвид']);
  assert.equal(context.recommendedLessonId, 'lesson-7');
  assert.equal(context.dueReviewCount, 4);
});

test('buildCoachContext lets DB document override client-supplied values', () => {
  const context = buildCoachContext(
    { xp: 100, streak: 1, totalLessons: 2, completedLessonIds: ['client'] },
    {
      xp: 3000,
      streak: 40,
      totalLessons: 20,
      completedLessons: ['s1', 's2'],
      learningGoal: 'shortSurahs',
      placementLevel: 6,
      knowledgeStates: [
        { id: 'k1', dueAt: '2000-01-01T00:00:00Z' },
        { id: 'k2', dueAt: '2999-01-01T00:00:00Z' },
      ],
    },
  );
  assert.equal(context.xp, 3000);
  assert.equal(context.level, 7); // recomputed from xp (3000/500 + 1)
  assert.equal(context.streak, 40);
  assert.equal(context.totalLessons, 20);
  assert.deepEqual(context.completedLessonIds, ['s1', 's2']);
  assert.equal(context.goal, 'shortSurahs');
  assert.equal(context.placementLevel, 6);
  assert.equal(context.dueReviewCount, 1); // only the past-due card counts
});

test('buildSystemPrompt honors locale and forbids self-issued fatwa', () => {
  const kk = buildSystemPrompt('kk');
  assert.match(kk, /казахском/);
  assert.match(kk, /специалисту/);
  assert.match(kk, /openHafiz/);
  assert.match(kk, /не выдумывай хадисы/);
  assert.match(kk, /JSON/);
  // Unknown locale falls back to ru.
  assert.match(buildSystemPrompt('xx'), /русском/);
});

test('buildUserMessage produces valid JSON with clamped question', () => {
  const long = 'a'.repeat(5000);
  const message = buildUserMessage({
    question: long,
    locale: 'en',
    context: { xp: 10 },
    catalog: [{ id: 'l1', title: 'Intro', course: 'basics' }],
  });
  const parsed = JSON.parse(message);
  assert.equal(parsed.locale, 'en');
  assert.equal(parsed.question.length, 1000); // clamped to MAX_QUESTION
  assert.deepEqual(parsed.student, { xp: 10 });
  assert.equal(parsed.catalog.length, 1);
});

test('parseCoachReply extracts reply, whitelisted action and sources', () => {
  const parsed = parseCoachReply(
    JSON.stringify({
      reply: 'Начни с суры Аль-Фатиха.',
      action: { type: 'openHafiz', label: 'Открыть Hafiz' },
      sources: [{
        title: 'Коран 1:1-7',
        category: 'Коран',
        verification: 'Проверенный текст',
        url: 'https://quran.com/ru/1',
      }],
    }),
  );
  assert.equal(parsed.text, 'Начни с суры Аль-Фатиха.');
  assert.deepEqual(parsed.action, { type: 'openHafiz', label: 'Открыть Hafiz' });
  assert.equal(parsed.sources[0].title, 'Коран 1:1-7');
  assert.equal(parsed.sources[0].url, 'https://quran.com/ru/1');
});

test('parseCoachReply removes unapproved source URLs', () => {
  const parsed = parseCoachReply(JSON.stringify({
    reply: 'Ответ',
    sources: [{ title: 'Источник', category: 'Коран', verification: 'AI', url: 'https://evil.example/a' }],
  }));
  assert.equal(parsed.sources[0].title, 'Источник');
  assert.equal(parsed.sources[0].url, undefined);
});

test('parseCoachReply drops unknown action types', () => {
  const parsed = parseCoachReply(
    JSON.stringify({ reply: 'Ответ', action: { type: 'deleteAccount' } }),
  );
  assert.equal(parsed.text, 'Ответ');
  assert.equal(parsed.action, undefined);
});

test('parseCoachReply falls back to raw text on invalid JSON', () => {
  const parsed = parseCoachReply('не-JSON просто текст');
  assert.equal(parsed.text, 'не-JSON просто текст');
  assert.equal(parsed.action, undefined);
});
