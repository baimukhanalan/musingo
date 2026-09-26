import assert from 'node:assert/strict';
import test from 'node:test';
import { buildCoachContext, buildDailyPlan, buildSystemPrompt, buildUserMessage, parseCoachReply } from '../server/routes/coach.js';

test('Arabic remains the requested coach language in prompt and context', () => {
  const context = buildCoachContext({}, null, { locale: 'ar' });
  assert.equal(context.language, 'ar');
  const prompt = buildSystemPrompt('ar');
  assert.match(prompt, /арабском \(ar\)/);
  assert.match(prompt, /locale важнее языка старых сообщений/);
  assert.equal(JSON.parse(buildUserMessage({ question: 'ماذا أتعلم؟', locale: 'ar', context, catalog: [] })).locale, 'ar');
});

test('Arabic deterministic plan reasons and empty state do not leak Russian', () => {
  const context = buildCoachContext({ streak: 3, goal: 'shortSurahs' }, null, { locale: 'ar' });
  const plan = buildDailyPlan(context, [{ id: 'q1', title: 'الفاتحة', course: 'quran' }]);
  assert.equal(plan.nextLessonId, 'q1');
  assert.match(plan.whyNext, /يناسب/);
  assert.match(plan.whyNext, /3/);
  assert.doesNotMatch(plan.whyNext, /[А-Яа-я]/u);
  assert.match(buildDailyPlan(context, []).whyNext, /لا يوجد/);
});

test('Arabic sensitive memory suggestions are discarded', () => {
  for (const memorySuggestion of ['كلمة المرور سرية', 'رقم بطاقتي هو 12345', 'لدي تشخيص طبي', 'عنواني في الشارع', 'هذه معلومة عن حياتي الجنسية']) {
    assert.equal(parseCoachReply(JSON.stringify({ reply: 'لن أحفظ هذه المعلومات', memorySuggestion })).memorySuggestion, undefined);
  }
  assert.equal(parseCoachReply(JSON.stringify({ reply: 'حسنًا', memorySuggestion: 'أفضل التعلم في الصباح' })).memorySuggestion, 'أفضل التعلم في الصباح');
});

test('coach context retains all full-Quran completion IDs beyond the old 600 limit', () => {
  const completedLessonIds = Array.from({ length: 1148 }, (_, i) => `lesson-${i}`);
  assert.equal(buildCoachContext({ completedLessonIds }).completedLessonIds.length, 1148);
});
