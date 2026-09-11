import assert from 'node:assert/strict';
import test from 'node:test';

import {
  buildCoachContext,
  buildDailyPlan,
  buildUserMessage,
  selectModelCatalog,
  validateCoachAction,
} from '../server/routes/coach.js';

const catalog = [
  { id: 'review-1', title: 'Letter review', subtitle: '', course: 'arabic', order: 1, completed: false },
  { id: 'weak-1', title: 'Makharij practice', subtitle: '', course: 'tajwid', order: 2, completed: false },
  { id: 'known-1', title: 'Сура Аль-Ихлас', subtitle: '', course: 'quran', order: 3, completed: false },
  { id: 'next-1', title: 'Сура Аль-Фалак', subtitle: '', course: 'quran', order: 4, completed: false },
];

test('route context sanitizes extended personalization fields', () => {
  const context = buildCoachContext({
    availableMinutes: 500,
    language: 'en',
    knownSurahs: ['Al-Ikhlas', 112],
    recentAccuracy: -20,
    weakKnowledge: [{
      id: 'step-1', lessonId: 'weak-1', label: 'x'.repeat(500),
      kind: 'pronunciation', strength: -3, lapses: 4, privateNote: 'secret',
    }],
  });
  assert.equal(context.availableMinutes, 60);
  assert.equal(context.language, 'en');
  assert.deepEqual(context.knownSurahs, ['Al-Ikhlas']);
  assert.equal(context.recentAccuracy, 0);
  assert.equal(context.weakKnowledge[0].label.length, 120);
  assert.equal(context.weakKnowledge[0].privateNote, undefined);
});

test('authenticated route context derives authoritative due, weak, accuracy, surah and language data', () => {
  const context = buildCoachContext(
    { streak: 999, knownSurahs: ['client'], recentAccuracy: 100 },
    {
      streak: 9,
      nativeLanguage: 'kk',
      knownSurahs: ['Ан-Нас'],
      hafizProgress: [{ surahName: 'Аль-Ихлас', mastery: 0.82 }],
      knowledgeStates: [
        {
          id: 'due', lessonId: 'review-1', label: 'Буква ع', kind: 'letter',
          strength: 0.3, repetitions: 1, lapses: 2,
          lastReviewedAt: '2026-09-10T12:00:00Z', nextReviewAt: '2026-09-11T10:00:00Z',
        },
        {
          id: 'fresh', lessonId: 'next-1', label: 'Аль-Фалак', kind: 'ayah',
          strength: 0.9, repetitions: 3, lapses: 0,
          lastReviewedAt: '2026-09-11T11:00:00Z', nextReviewAt: '2026-09-14T10:00:00Z',
        },
      ],
    },
    { now: Date.parse('2026-09-11T12:00:00Z'), locale: 'ru' },
  );
  assert.equal(context.streak, 9);
  assert.equal(context.language, 'kk');
  assert.deepEqual(context.knownSurahs, ['Ан-Нас', 'Аль-Ихлас']);
  assert.equal(context.dueItems[0].lessonId, 'review-1');
  assert.deepEqual(context.weakLessonIds, ['review-1']);
  assert.equal(context.recentAccuracy, 60);
});

test('authoritative plan orders due, weakness and new goal material inside available time', () => {
  const context = buildCoachContext({
    goal: 'shortSurahs', streak: 12, availableMinutes: 8,
    recentAccuracy: 64, knownSurahs: ['Аль-Ихлас'],
    skillProfile: { letters: 80, reading: 75, surahRecall: 65, meaning: 70, tajwid: 30 },
    dueReviewCount: 1,
    dueItems: [{ id: 'd1', lessonId: 'review-1', label: 'Буква ع', strength: 0.3 }],
    weakKnowledge: [{ id: 'w1', lessonId: 'weak-1', label: 'Махрадж ح', strength: 0.4 }],
  });
  const plan = buildDailyPlan(context, catalog);
  assert.deepEqual(plan.tasks.map((task) => task.type), ['review', 'weakPractice', 'newLesson']);
  assert.deepEqual(plan.tasks.map((task) => task.lessonId), ['review-1', 'weak-1', 'next-1']);
  assert.equal(plan.minutesPlanned, 8);
  assert.match(plan.whyNext, /12/);
  assert.equal(plan.basis.weakestSkill, 'tajwid');
});

test('model prompt receives the server plan and a bounded catalog with its priority lesson', () => {
  const lessons = Array.from({ length: 120 }, (_, index) => ({
    id: `lesson-${index}`, title: `Lesson ${index}`, subtitle: '',
    course: index % 2 === 0 ? 'arabic' : 'quran', order: index, completed: false,
  }));
  const context = buildCoachContext({ goal: 'arabicReading', recommendedLessonId: 'lesson-119' });
  const plan = buildDailyPlan(context, lessons);
  const selected = selectModelCatalog(lessons, context, plan);
  const message = JSON.parse(buildUserMessage({
    question: 'What next?', locale: 'en', context, catalog: selected, dailyPlan: plan,
  }));
  assert.equal(selected.length, 80);
  assert.equal(selected[0].id, 'lesson-119');
  assert.equal(message.serverDailyPlan.nextLessonId, 'lesson-119');
});

test('model cannot emit a startLesson action outside the validated catalog', () => {
  assert.deepEqual(
    validateCoachAction(
      { type: 'startLesson', lessonId: 'invented', label: 'Start' },
      catalog,
      { nextLessonId: 'next-1' },
    ),
    { type: 'startLesson', lessonId: 'next-1', label: 'Start' },
  );
  assert.equal(
    validateCoachAction({ type: 'startLesson', lessonId: 'invented' }, catalog, null),
    null,
  );
});
