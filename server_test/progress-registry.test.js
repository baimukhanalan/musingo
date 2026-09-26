import assert from 'node:assert/strict';
import test from 'node:test';

// progress-complete.js exports the lesson registry as pure data plus the
// errors-clamp helper. Importing it pulls in db.js, but db.js is lazy (no throw
// at import) so these run without a DATABASE_URL and without a real database.
import {
  ayatRewards, clampErrors, completionDays, completionStudyTime, completionUpdate,
  distinctStudiedAyahs, lessons, lessonXp, previousLessonId,
  quranCurriculumManifest, quranLessonMetadata, requiredRecordedSteps,
} from '../server/routes/progress-complete.js';
import { defaultProgress, lessonAttemptEligibility, mergeLearningState } from '../server/lib/progress.js';

// Ground truth captured from the client via:
//   grep -rn "id: '" lib/services/lessons/
// Any drift here (a new .dart lesson missing from the server Set) makes
// POST /api/progress/complete return 400 unknown_lesson for that lesson.
const arabicIds = [
  'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8',
  'a9', 'a10', 'a11', 'a12', 'a13', 'a14', 'a15', 'a16',
  'a17', 'a18', 'a19', 'a20', 'a21', 'a22',
  ...Array.from({ length: 78 }, (_, index) => `a${index + 23}`),
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
  'q_naba_1', 'q_naba_2', 'q_naziat_1', 'q_naziat_2',
  'q_abasa_1', 'q_abasa_2', 'q_takwir_1', 'q_infitar_1',
  'q_mutaffifin_1', 'q_mutaffifin_2', 'q_inshiqaq_1',
  'q_balad_1', 'q_bayyina_1',
  'q_mulk_1', 'q_qalam_1', 'q_haqqah_1', 'q_maarij_1', 'q_nuh_1',
  'q_jinn_1', 'q_muzzammil_1', 'q_muddaththir_1', 'q_qiyamah_1',
  'q_insan_1', 'q_mursalat_1',
  'q_mujadila_1', 'q_hashr_1', 'q_mumtahanah_1', 'q_saff_1',
  'q_jumuah_1', 'q_munafiqun_1', 'q_taghabun_1', 'q_talaq_1',
  'q_tahrim_1',
  ...Array.from({ length: 32 }, (_, index) => `q_mastery_${index + 69}`),
];
const rulesIds = [
  'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7', 'r8', 'r9', 'r10',
];
const tajwidIds = Array.from({ length: 36 }, (_, index) =>
  `tj${String(index + 1).padStart(2, '0')}`);
const fullQuranIds = quranCurriculumManifest.lessons.map((lesson) => lesson.id);
const allIds = [...arabicIds, ...quranIds, ...rulesIds, ...tajwidIds, ...fullQuranIds];

// Review metadata now retains exact source addresses. Union-based progress
// prevents these repeated addresses from being credited a second time.
const reviewQuranIds = [
  'q_review_5_surahs',
  'q_review_short_surahs',
  'q_mastery_76',
  'q_mastery_86',
];
const ayatQuranIds = quranIds.filter((id) => !reviewQuranIds.includes(id));

// --- lessons Set covers every client lesson id ---------------------------

test('lessons Set contains every id from the four lesson sources', () => {
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

test('review metadata keeps exact source counts and non-quran lessons have none', () => {
  for (const id of reviewQuranIds) {
    assert.equal(ayatRewards[id], quranLessonMetadata.get(id).globalAyahNumbers.length);
  }
  for (const id of [...arabicIds, ...rulesIds, ...tajwidIds]) {
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
    q_naba_1: 20, q_naba_2: 20, q_naziat_1: 26, q_naziat_2: 20,
    q_abasa_1: 23, q_abasa_2: 19, q_takwir_1: 29, q_infitar_1: 19,
    q_mutaffifin_1: 20, q_mutaffifin_2: 16, q_inshiqaq_1: 25,
    q_balad_1: 20, q_bayyina_1: 8,
    q_mulk_1: 2, q_qalam_1: 2, q_haqqah_1: 2, q_maarij_1: 2, q_nuh_1: 2,
    q_jinn_1: 2, q_muzzammil_1: 2, q_muddaththir_1: 2, q_qiyamah_1: 2,
    q_insan_1: 2, q_mursalat_1: 2,
    q_mujadila_1: 2, q_hashr_1: 2, q_mumtahanah_1: 2, q_saff_1: 2,
    q_jumuah_1: 2, q_munafiqun_1: 2, q_taghabun_1: 2, q_talaq_1: 2,
    q_tahrim_1: 2,
    q_review_5_surahs: 4, q_review_short_surahs: 2,
  };
  const sourceIds = quranIds.slice(0, 32);
  for (let index = 0; index < sourceIds.length; index += 1) {
    const sourceReward = expected[sourceIds[index]] ?? 0;
    const masteryId = `q_mastery_${69 + index}`;
    if (sourceReward > 0) expected[masteryId] = sourceReward;
  }
  for (const lesson of quranCurriculumManifest.lessons) {
    expected[lesson.id] = lesson.globalEnd - lesson.globalStart + 1;
  }
  assert.deepEqual(
    Object.fromEntries(Object.entries(ayatRewards).filter(([, value]) => value > 0)),
    expected,
  );
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
  assert.equal(lessonXp.a17, 30);
  assert.equal(lessonXp.a22, 30);
  assert.equal(lessonXp.q_review_5_surahs, 45);
  assert.equal(lessonXp.q_review_short_surahs, 45);
  assert.equal(lessonXp.q_asr_1, 25);
  assert.equal(lessonXp.q_ala_1, 25);
  assert.equal(lessonXp.r8, 25);
  assert.equal(lessonXp.tj01, 30);
  assert.equal(lessonXp.tj16, 40);
  assert.equal(lessonXp.tj24, 40);
  assert.equal(lessonXp.tj36, 40);
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

test('canonical registry contains 902 full units with all 6236 addresses exactly once', () => {
  assert.equal(lessons.size, 1148);
  assert.equal(fullQuranIds.length, 902);
  assert.equal(quranLessonMetadata.size, 1002);
  assert.deepEqual(fullQuranIds.flatMap((id) => quranLessonMetadata.get(id).globalAyahNumbers),
    Array.from({ length: 6236 }, (_, index) => index + 1));
  assert.equal(new Set(quranCurriculumManifest.lessons.map((lesson) => lesson.surah)).size, 114);
  for (const lesson of quranCurriculumManifest.lessons) {
    assert.equal(lessonXp[lesson.id], lesson.xpReward);
    assert.equal(requiredRecordedSteps(lesson.id), lesson.stepCount);
    assert.ok(lesson.estimatedSeconds <= 420);
  }
});

test('Quran progress counts unique practiced ayahs, not repeated lesson references', () => {
  assert.equal(distinctStudiedAyahs(['q_fatiha_1', 'q_mastery_69']), 1);
  assert.equal(distinctStudiedAyahs(['q_fatiha_1', 'q_mastery_69', 'q_full_1_1_7']), 7);
  assert.equal(distinctStudiedAyahs(['q_full_1_1_7', 'q_full_1_1_7', 'a1', 'unknown']), 7);
  assert.equal(distinctStudiedAyahs(allIds), 6236);
  assert.equal(distinctStudiedAyahs(quranIds), 602);
});

test('full Quran entry is independent and subsequent units retain prerequisites', () => {
  assert.equal(previousLessonId('q_full_1_1_7'), null);
  assert.equal(previousLessonId(fullQuranIds[1]), fullQuranIds[0]);
  assert.equal(previousLessonId('q_fatiha_1'), null);
  assert.equal(previousLessonId('q_fatiha_2'), 'q_fatiha_1');
  assert.equal(previousLessonId('q_mastery_100'), 'q_mastery_99');
  assert.equal(previousLessonId('a1'), null);
  assert.equal(previousLessonId('tj01'), null);
  assert.equal(previousLessonId('r1'), null);
});

test('a long full-path lesson requires all recorded steps, not just five', () => {
  const now = Date.parse('2026-09-26T12:00:00Z');
  const attempt = { completed_steps: 5, started_at: '2026-09-26T11:55:00Z', consumed_at: null };
  assert.equal(requiredRecordedSteps('q_full_1_1_7'), 11);
  assert.equal(lessonAttemptEligibility(attempt, {
    now, minimumSteps: requiredRecordedSteps('q_full_1_1_7'),
  }).eligible, false);
  assert.equal(lessonAttemptEligibility({ ...attempt, completed_steps: 11 }, {
    now, minimumSteps: requiredRecordedSteps('q_full_1_1_7'),
  }).eligible, true);
  assert.equal(requiredRecordedSteps('q_fatiha_1'), 5);
});

test('ordinary state sync retains all 1148 legitimate lesson IDs', () => {
  const user = { id: 'u1', email: 'test@example.com', display_name: 'Learner' };
  const source = { ...defaultProgress(user), completedLessons: allIds };
  assert.deepEqual(mergeLearningState(source, {}).completedLessons, allIds);
});

test('study time uses seconds, keeps the remainder and migrates historical minutes', () => {
  const first = completionStudyTime({ totalMinutes: 2 }, { elapsedMs: 59_999 }, 59);
  assert.deepEqual(first, { studySecondsEarned: 59, minutesEarned: 0, totalStudySeconds: 179, totalMinutes: 2 });
  const second = completionStudyTime(first, { elapsedMs: 10_000 }, 1);
  assert.equal(second.studySecondsEarned, 1);
  assert.equal(second.minutesEarned, 0);
  assert.equal(second.totalStudySeconds, 180);
  assert.equal(second.totalMinutes, 3);
  assert.equal(completionStudyTime({}, { elapsedMs: 90_500 }).studySecondsEarned, 90);
  assert.equal(completionStudyTime({}, { elapsedMs: 10_000 }, 100).studySecondsEarned, 10);
  assert.equal(completionStudyTime({}, { elapsedMs: 20_000 }, 0).studySecondsEarned, 0);
  assert.equal(completionStudyTime({}, { elapsedMs: 50_000_000 }).studySecondsEarned, 7200);
  for (const invalid of [-1, 1.5, 7201, 'invalid']) {
    assert.throws(() => completionStudyTime({}, { elapsedMs: 100_000 }, invalid));
  }
});

test('local study days come from the validated offset, league days remain UTC', () => {
  const now = Date.parse('2026-09-26T20:00:00Z');
  assert.deepEqual(completionDays(300, now), { localDay: '2026-09-27', utcDay: '2026-09-26' });
  assert.deepEqual(completionDays(-840, now), { localDay: '2026-09-26', utcDay: '2026-09-26' });
  assert.deepEqual(completionDays(840, now), { localDay: '2026-09-27', utcDay: '2026-09-26' });
  for (const invalid of [-841, 841, 1.5, 'invalid']) assert.throws(() => completionDays(invalid, now));
});

test('completion distinguishes unique lessons, attempts, exact ayahs and elapsed study', () => {
  const user = { id: 'u1', email: 'test@example.com', display_name: 'Learner' };
  const now = Date.parse('2026-09-26T20:00:00Z');
  const original = {
    ...defaultProgress(user), completedLessons: ['q_fatiha_1', 'q_mastery_69'],
    totalLessons: 200, learnedAyats: 9000, totalMinutes: 5,
    lessonAttempts: 8, streak: 6, lastStudyDay: '2026-09-26',
    leaderboardXpToday: 200, leaderboardXpDay: '2026-09-26',
  };
  const input = {
    current: original, lessonId: 'q_full_1_1_7', rewardToken: 'attempt-1',
    receipt: { elapsedMs: 185_000 }, elapsedSeconds: 184, utcOffsetMinutes: 300, now,
  };
  const first = completionUpdate(input);
  assert.equal(first.next.totalLessons, 3);
  assert.equal(first.next.lessonAttempts, 9);
  assert.equal(first.next.learnedAyats, 7);
  assert.equal(first.studySecondsEarned, 184);
  assert.equal(first.minutesEarned, 3);
  assert.equal(first.next.totalStudySeconds, 484);
  assert.equal(first.next.totalMinutes, 8);
  assert.equal(first.next.streak, 7);
  assert.equal(first.streakBonus, 10);
  assert.equal(first.energyEarned, 8);
  assert.equal(first.next.lastStudyDay, '2026-09-27');
  assert.equal(first.leaderboard.contribution, 0);
  assert.equal(first.next.leaderboardXpDay, '2026-09-26');

  const repeat = completionUpdate({ ...input, current: first.next, rewardToken: 'attempt-2' });
  assert.equal(repeat.next.totalLessons, 3);
  assert.equal(repeat.next.lessonAttempts, 10);
  assert.equal(repeat.next.learnedAyats, 7);
  assert.equal(repeat.xpEarned, 5);
  assert.equal(repeat.firstCompletion, false);
  assert.equal(repeat.leaderboard.contribution, 0);
  const travel = completionUpdate({ ...input, current: first.next, utcOffsetMinutes: -300, rewardToken: 'attempt-3' });
  assert.equal(travel.next.streak, 7);
  assert.equal(travel.streakBonus, 0);
  assert.equal(travel.next.lastStudyDay, '2026-09-27');
  const nearCap = completionUpdate({ ...input, current: { ...first.next, energy: 995 } });
  assert.equal(nearCap.energyEarned, 4);
  assert.equal(nearCap.next.energy, 999);
  const atCap = completionUpdate({ ...input, current: { ...first.next, energy: 999 } });
  assert.equal(atCap.energyEarned, 0);
  assert.equal(atCap.next.energy, 999);
});
