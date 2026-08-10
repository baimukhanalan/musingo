import assert from 'node:assert/strict';
import test from 'node:test';

// progress-complete.js exports the lesson registry as pure data plus the
// errors-clamp helper. Importing it pulls in db.js, but db.js is lazy (no throw
// at import) so these run without a DATABASE_URL and without a real database.
import { ayatRewards, clampErrors, lessons, lessonXp } from '../server/routes/progress-complete.js';

// Ground truth captured from the client via:
//   grep -rn "id: '" lib/services/lessons/
// Any drift here (a new .dart lesson missing from the server Set) makes
// POST /api/progress/complete return 400 unknown_lesson for that lesson.
const arabicIds = [
  'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8',
  'a9', 'a10', 'a11', 'a12', 'a13', 'a14', 'a15', 'a16',
];
const quranIds = [
  'q_fatiha_1', 'q_fatiha_2', 'q_fatiha_3', 'q_fatiha_4',
  'q_ikhlas_1', 'q_falaq_1', 'q_nas_1', 'q_review_5_surahs',
  'q_baqara_1', 'q_asr_1', 'q_fil_1', 'q_quraysh_1', 'q_maun_1',
  'q_kawthar_1', 'q_kafirun_1', 'q_nasr_1', 'q_masad_1', 'q_review_short_surahs',
  'q_humaza_1', 'q_takathur_1', 'q_qaria_1', 'q_adiyat_1', 'q_zalzala_1',
  'q_qadr_1', 'q_tin_1', 'q_sharh_1', 'q_duha_1', 'q_ala_1',
  'q_alaq_1', 'q_shams_1', 'q_layl_1', 'q_fajr_1', 'q_ghashiya_1',
  'q_tariq_1', 'q_buruj_1',
];
const rulesIds = [
  'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7', 'r8', 'r9', 'r10',
];
const allIds = [...arabicIds, ...quranIds, ...rulesIds];

// Review lessons carry no ayat reward and are intentionally excluded from
// ayatRewards (credited as 0).
const reviewQuranIds = ['q_review_5_surahs', 'q_review_short_surahs'];
const ayatQuranIds = quranIds.filter((id) => !reviewQuranIds.includes(id));

// --- lessons Set covers every client lesson id ---------------------------

test('lessons Set contains every id from the three .dart lesson files', () => {
  for (const id of allIds) {
    assert.ok(lessons.has(id), `lessons Set is missing "${id}"`);
  }
});

test('lessons Set has no extra ids beyond the client lessons', () => {
  assert.equal(lessons.size, allIds.length);
  for (const id of lessons) {
    assert.ok(allIds.includes(id), `lessons Set has unexpected id "${id}"`);
  }
});

// --- ayatRewards: present for every non-review quran lesson --------------

test('ayatRewards has a positive entry for every non-review quran lesson', () => {
  for (const id of ayatQuranIds) {
    assert.ok(id in ayatRewards, `ayatRewards is missing "${id}"`);
    assert.ok(Number.isInteger(ayatRewards[id]) && ayatRewards[id] > 0,
      `ayatRewards["${id}"] must be a positive integer`);
  }
});

test('ayatRewards excludes review lessons and non-quran lessons', () => {
  for (const id of reviewQuranIds) {
    assert.ok(!(id in ayatRewards), `review lesson "${id}" must not be in ayatRewards`);
  }
  for (const id of [...arabicIds, ...rulesIds]) {
    assert.ok(!(id in ayatRewards), `non-quran lesson "${id}" must not be in ayatRewards`);
  }
});

test('ayatRewards matches the distinct quranGlobalAyahNumber count per lesson', () => {
  // Distinct ayah counts read from lib/services/lessons/quran_lessons.dart.
  const expected = {
    q_fatiha_1: 1, q_fatiha_2: 2, q_fatiha_3: 2, q_fatiha_4: 2,
    q_ikhlas_1: 2, q_falaq_1: 1, q_nas_1: 1,
    q_baqara_1: 2, q_asr_1: 3, q_fil_1: 5, q_quraysh_1: 4, q_maun_1: 7,
    q_kawthar_1: 3, q_kafirun_1: 6, q_nasr_1: 3, q_masad_1: 5,
    q_humaza_1: 9, q_takathur_1: 8, q_qaria_1: 11, q_adiyat_1: 11, q_zalzala_1: 8,
    q_qadr_1: 5, q_tin_1: 8, q_sharh_1: 8, q_duha_1: 11, q_ala_1: 19,
    q_alaq_1: 19, q_shams_1: 15, q_layl_1: 21, q_fajr_1: 30,
    q_ghashiya_1: 26, q_tariq_1: 17, q_buruj_1: 22,
  };
  assert.deepEqual(ayatRewards, expected);
});

// --- lessonXp: covers every lesson id ------------------------------------

test('lessonXp has an entry for every lesson id', () => {
  for (const id of allIds) {
    assert.ok(id in lessonXp, `lessonXp is missing "${id}"`);
    assert.ok(Number.isInteger(lessonXp[id]) && lessonXp[id] > 0,
      `lessonXp["${id}"] must be a positive integer`);
  }
  assert.equal(Object.keys(lessonXp).length, allIds.length);
});

test('lessonXp mirrors the client xpReward values', () => {
  // Non-default (not 25) rewards from the .dart files: arabic 20-xp letters and
  // the two 45-xp review lessons. Everything else defaults to 25.
  assert.equal(lessonXp.a1, 20);
  assert.equal(lessonXp.a7, 20);
  assert.equal(lessonXp.a11, 20);
  assert.equal(lessonXp.a12, 20);
  assert.equal(lessonXp.a3, 25);
  assert.equal(lessonXp.q_review_5_surahs, 45);
  assert.equal(lessonXp.q_review_short_surahs, 45);
  assert.equal(lessonXp.q_asr_1, 25);
  assert.equal(lessonXp.q_ala_1, 25);
  assert.equal(lessonXp.r8, 25);
});

// --- errors clamp (C1-hardening) -----------------------------------------

test('clampErrors clamps values above 5 down to 5 instead of throwing', () => {
  assert.equal(clampErrors(9), 5);
  assert.equal(clampErrors(6), 5);
  assert.equal(clampErrors(1000), 5);
});

test('clampErrors passes through in-range values and defaults missing to 0', () => {
  assert.equal(clampErrors(0), 0);
  assert.equal(clampErrors(3), 3);
  assert.equal(clampErrors(5), 5);
  assert.equal(clampErrors(undefined), 0);
  assert.equal(clampErrors(null), 0);
});

test('clampErrors still rejects malformed (negative / non-integer) values', () => {
  assert.throws(() => clampErrors(-1));
  assert.throws(() => clampErrors(2.5));
  assert.throws(() => clampErrors('abc'));
});
