import assert from 'node:assert/strict';
import test from 'node:test';

// Чистый модуль копирайта — без БД и сети, импортируется напрямую.
const { reminderMessage } = await import('../server/lib/reminder-copy.js');

// --- базовый контракт -----------------------------------------------------

test('reminderMessage всегда возвращает непустые title и body', () => {
  const inputs = [
    { dueCount: 0, learningGoal: null, seed: 0 },
    { dueCount: 3, learningGoal: null, seed: 7 },
    { dueCount: 0, learningGoal: 'shortSurahs', seed: 42 },
    { dueCount: 0, learningGoal: 'unknownGoal', seed: 99 },
    {},
  ];
  for (const input of inputs) {
    const { title, body } = reminderMessage(input);
    assert.equal(typeof title, 'string');
    assert.equal(typeof body, 'string');
    assert.ok(title.trim().length > 0, 'title непустой');
    assert.ok(body.trim().length > 0, 'body непустой');
  }
});

// --- детерминизм по seed --------------------------------------------------

test('одинаковый seed даёт одинаковый текст (детерминизм)', () => {
  const a = reminderMessage({ dueCount: 0, learningGoal: null, seed: 123 });
  const b = reminderMessage({ dueCount: 0, learningGoal: null, seed: 123 });
  assert.deepEqual(a, b);
});

test('разный seed перебирает варианты дневного набора', () => {
  const bodies = new Set();
  for (let seed = 0; seed < 12; seed += 1) {
    bodies.add(reminderMessage({ dueCount: 0, learningGoal: null, seed }).body);
  }
  // Набор дневных вариантов больше одного — перебор seed даёт разнообразие.
  assert.ok(bodies.size > 1, 'seed выбирает разные варианты');
});

// --- контекст повторений (dueCount > 0) -----------------------------------

test('при dueCount > 0 body содержит число повторений', () => {
  for (const dueCount of [1, 2, 5, 21, 137]) {
    const { body } = reminderMessage({ dueCount, learningGoal: null, seed: 3 });
    assert.ok(/\d/.test(body), 'в body есть цифра');
    assert.ok(body.includes(String(dueCount)), `body содержит ${dueCount}`);
  }
});

test('контекст повторений выигрывает у цели при dueCount > 0', () => {
  const withGoal = reminderMessage({ dueCount: 4, learningGoal: 'pronunciation', seed: 5 });
  const noGoal = reminderMessage({ dueCount: 4, learningGoal: null, seed: 5 });
  // Цель игнорируется, пока есть повторения: тот же seed — тот же текст.
  assert.deepEqual(withGoal, noGoal);
  assert.ok(withGoal.body.includes('4'));
});

test('склонение слова «аят» согласовано с числом', () => {
  assert.ok(reminderMessage({ dueCount: 1, seed: 0 }).body.includes('1 аят'));
  assert.ok(reminderMessage({ dueCount: 3, seed: 0 }).body.includes('3 аята'));
  assert.ok(reminderMessage({ dueCount: 5, seed: 0 }).body.includes('5 аятов'));
  assert.ok(reminderMessage({ dueCount: 11, seed: 0 }).body.includes('11 аятов'));
});

// --- контекст учебной цели ------------------------------------------------

test('разные learning_goal дают разный акцент', () => {
  const goals = ['arabicReading', 'shortSurahs', 'pronunciation', 'quranMeaning', 'islamBasics'];
  const bodies = goals.map((goal) => reminderMessage({ dueCount: 0, learningGoal: goal, seed: 0 }).body);
  // Каждая цель — со своим текстом, дубликатов между целями нет.
  assert.equal(new Set(bodies).size, goals.length);
});

test('цель даёт текст, отличный от дневного набора без цели', () => {
  const goal = reminderMessage({ dueCount: 0, learningGoal: 'quranMeaning', seed: 1 });
  const daily = reminderMessage({ dueCount: 0, learningGoal: null, seed: 1 });
  assert.notDeepEqual(goal, daily);
});

test('неизвестная цель откатывается к дневному набору', () => {
  const unknown = reminderMessage({ dueCount: 0, learningGoal: 'totallyUnknown', seed: 2 });
  const daily = reminderMessage({ dueCount: 0, learningGoal: null, seed: 2 });
  assert.deepEqual(unknown, daily);
});

// --- устойчивость входа ----------------------------------------------------

test('нечисловой/пустой seed не ломает выбор', () => {
  for (const seed of [undefined, null, Number.NaN, 'abc']) {
    const { title, body } = reminderMessage({ dueCount: 0, learningGoal: null, seed });
    assert.ok(title.length > 0 && body.length > 0);
  }
});
