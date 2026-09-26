import { readFileSync } from 'node:fs';

import { requireUser, verifyLessonAttempt } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { ApiError, integer, method, readJson, text, withApi } from '../lib/http.js';
import {
  bestKnownStreak,
  isRewardReplay,
  leaderboardContribution,
  lessonAttemptEligibility,
  nextDailyProgress,
  profile,
} from '../lib/progress.js';

// Full lesson registry mirrored from the client (lib/services/lessons/
// {arabic,quran,rules,tajwid}_lessons.dart). Every lesson id the app can complete MUST
// be present, or POST /api/progress/complete rejects it with 400 unknown_lesson
// and a signed-in user's progress for that lesson is silently dropped.
export const lessons = new Set([
  // arabic_lessons.dart (a1–a22)
  'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8',
  'a9', 'a10', 'a11', 'a12', 'a13', 'a14', 'a15', 'a16',
  'a17', 'a18', 'a19', 'a20', 'a21', 'a22',
  // quran_lessons.dart
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
  // juz_tabarak_lessons.dart (surahs 67-77)
  'q_mulk_1', 'q_qalam_1', 'q_haqqah_1', 'q_maarij_1', 'q_nuh_1',
  'q_jinn_1', 'q_muzzammil_1', 'q_muddaththir_1', 'q_qiyamah_1',
  'q_insan_1', 'q_mursalat_1',
  // juz_mujadila_lessons.dart (surahs 58-66)
  'q_mujadila_1', 'q_hashr_1', 'q_mumtahanah_1', 'q_saff_1',
  'q_jumuah_1', 'q_munafiqun_1', 'q_taghabun_1', 'q_talaq_1',
  'q_tahrim_1',
  // rules_lessons.dart (r1–r10)
  'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7', 'r8', 'r9', 'r10',
  // tajwid_lessons.dart (tj01–tj36)
  'tj01', 'tj02', 'tj03', 'tj04', 'tj05', 'tj06', 'tj07', 'tj08', 'tj09',
  'tj10', 'tj11', 'tj12', 'tj13', 'tj14', 'tj15', 'tj16', 'tj17', 'tj18',
  'tj19', 'tj20', 'tj21', 'tj22', 'tj23', 'tj24', 'tj25', 'tj26', 'tj27',
  'tj28', 'tj29', 'tj30', 'tj31', 'tj32', 'tj33', 'tj34', 'tj35', 'tj36',
]);
for (let order = 23; order <= 100; order += 1) lessons.add(`a${order}`);
for (let order = 69; order <= 100; order += 1) lessons.add(`q_mastery_${order}`);

// Source-derived addresses are shared with the canonical reading path. Counts
// are useful metadata, but progress is the UNION of addresses, never their sum.
export const quranCurriculumManifest = JSON.parse(readFileSync(
  new URL('../../docs/content/quran-full-curriculum-v1.json', import.meta.url),
  'utf8',
));
export const quranLessonMetadata = new Map([
  ...quranCurriculumManifest.legacyLessons.map((lesson) => [lesson.id, lesson]),
  ...quranCurriculumManifest.lessons.map((lesson) => [lesson.id, {
    ...lesson,
    globalAyahNumbers: Array.from(
      { length: lesson.globalEnd - lesson.globalStart + 1 },
      (_, index) => lesson.globalStart + index,
    ),
  }]),
]);
for (const lesson of quranCurriculumManifest.lessons) lessons.add(lesson.id);
export const ayatRewards = Object.fromEntries([...quranLessonMetadata]
  .filter(([, lesson]) => lesson.globalAyahNumbers.length > 0).map(
  ([id, lesson]) => [id, lesson.globalAyahNumbers.length],
));

export function distinctStudiedAyahs(completedLessons) {
  const addresses = new Set();
  for (const id of completedLessons ?? []) {
    for (const ayah of quranLessonMetadata.get(id)?.globalAyahNumbers ?? []) {
      addresses.add(ayah);
    }
  }
  return addresses.size;
}

// The full path is an independent course entry, not gated by 100 older units.
export function previousLessonId(lessonId) {
  const prefix = lessonId.startsWith('q_full_') ? 'q_full_'
    : lessonId.startsWith('tj') ? 'tj'
      : lessonId.startsWith('q') ? 'q'
        : lessonId.slice(0, 1);
  const path = [...lessons].filter((id) => id.startsWith(prefix) &&
    (prefix !== 'q' || !id.startsWith('q_full_')));
  const index = path.indexOf(lessonId);
  return index > 0 ? path[index - 1] : null;
}

export function requiredRecordedSteps(lessonId) {
  return lessonId.startsWith('q_full_')
    ? (quranLessonMetadata.get(lessonId)?.stepCount ?? 5)
    : 5;
}

// M2: first-completion xp must equal the lesson's own xpReward (lib/services/
// lessons/*.dart) so a signed-in user earns exactly what a guest sees. Field
// omitted in the .dart lesson => client default of 25. Repeats stay flat at 5
// (handled at the call site), matching the client's replay economy.
export const lessonXp = {
  a1: 20, a2: 20, a3: 25, a4: 20, a5: 25, a6: 25, a7: 20, a8: 20,
  a9: 25, a10: 25, a11: 20, a12: 20, a13: 25, a14: 25, a15: 25, a16: 25,
  a17: 30, a18: 30, a19: 30, a20: 30, a21: 30, a22: 30,
  q_fatiha_1: 25, q_fatiha_2: 25, q_fatiha_3: 25, q_fatiha_4: 25,
  q_ikhlas_1: 25, q_falaq_1: 25, q_nas_1: 25, q_review_5_surahs: 45,
  q_baqara_1: 25, q_asr_1: 25, q_fil_1: 25, q_quraysh_1: 25, q_maun_1: 25,
  q_kawthar_1: 25, q_kafirun_1: 25, q_nasr_1: 25, q_masad_1: 25, q_review_short_surahs: 45,
  q_humaza_1: 25, q_takathur_1: 25, q_qaria_1: 25, q_adiyat_1: 25, q_zalzala_1: 25,
  q_qadr_1: 25, q_tin_1: 25, q_sharh_1: 25, q_duha_1: 25, q_ala_1: 25,
  q_alaq_1: 25, q_shams_1: 25, q_layl_1: 25, q_fajr_1: 25, q_ghashiya_1: 25,
  q_tariq_1: 25, q_buruj_1: 25,
  q_naba_1: 25, q_naba_2: 25, q_naziat_1: 25, q_naziat_2: 25,
  q_abasa_1: 25, q_abasa_2: 25, q_takwir_1: 25, q_infitar_1: 25,
  q_mutaffifin_1: 25, q_mutaffifin_2: 25, q_inshiqaq_1: 25,
  q_balad_1: 25, q_bayyina_1: 25,
  q_mulk_1: 25, q_qalam_1: 25, q_haqqah_1: 25, q_maarij_1: 25, q_nuh_1: 25,
  q_jinn_1: 25, q_muzzammil_1: 25, q_muddaththir_1: 25, q_qiyamah_1: 25,
  q_insan_1: 25, q_mursalat_1: 25,
  q_mujadila_1: 25, q_hashr_1: 25, q_mumtahanah_1: 25, q_saff_1: 25,
  q_jumuah_1: 25, q_munafiqun_1: 25, q_taghabun_1: 25, q_talaq_1: 25,
  q_tahrim_1: 25,
  r1: 25, r2: 25, r3: 25, r4: 25, r5: 25, r6: 25, r7: 25, r8: 25, r9: 25, r10: 25,
  tj01: 30, tj02: 30, tj03: 30, tj04: 30, tj05: 30, tj06: 30,
  tj07: 30, tj08: 30, tj09: 30, tj10: 30, tj11: 30, tj12: 30,
  tj13: 30, tj14: 30, tj15: 30, tj16: 40, tj17: 30, tj18: 30,
  tj19: 30, tj20: 30, tj21: 30, tj22: 30, tj23: 30, tj24: 40,
  tj25: 30, tj26: 30, tj27: 30, tj28: 30, tj29: 30, tj30: 30,
  tj31: 30, tj32: 30, tj33: 30, tj34: 30, tj35: 30, tj36: 40,
};
for (let order = 23; order <= 100; order += 1) {
  lessonXp[`a${order}`] = order % 3 === 1 ? 35 : 30;
}
for (let order = 69; order <= 100; order += 1) {
  lessonXp[`q_mastery_${order}`] = 40;
}
for (const [id, metadata] of quranLessonMetadata) lessonXp[id] = metadata.xpReward;

// C1-hardening: clamp the reported mistake count into [0, 5] instead of
// rejecting >5 with a 400. A stale or third-party client that reports more
// mistakes must still have its completion recorded — dropping the request would
// wipe the user's progress for that lesson. Non-numeric / negative values still
// fail validation via integer() as before.
export function clampErrors(value) {
  return Math.min(5, integer(value ?? 0, { min: 0, max: Number.MAX_SAFE_INTEGER }));
}

export function completionDays(utcOffsetMinutes = 0, now = Date.now()) {
  const offset = integer(utcOffsetMinutes ?? 0, { min: -840, max: 840 });
  return {
    localDay: new Date(now + offset * 60_000).toISOString().slice(0, 10),
    utcDay: new Date(now).toISOString().slice(0, 10),
  };
}

export function completionStudyTime(current, receipt, elapsedSeconds) {
  const reported = elapsedSeconds == null ? null
    : integer(elapsedSeconds, { min: 0, max: 7200 });
  const serverSeconds = Math.min(7200, Math.max(0, Math.floor(receipt.elapsedMs / 1000)));
  const studySecondsEarned = Math.min(reported ?? serverSeconds, serverSeconds);
  const oldMinutes = Math.max(0, Math.floor(Number(current.totalMinutes) || 0));
  const oldSeconds = Number.isSafeInteger(current.totalStudySeconds) && current.totalStudySeconds >= 0
    ? Math.max(current.totalStudySeconds, oldMinutes * 60)
    : oldMinutes * 60;
  const totalStudySeconds = oldSeconds + studySecondsEarned;
  return {
    studySecondsEarned,
    minutesEarned: Math.floor(studySecondsEarned / 60),
    totalStudySeconds,
    totalMinutes: Math.floor(totalStudySeconds / 60),
  };
}

// All inputs except the optional timezone/active-duration reports are already
// server-owned. Reports cannot increase rewards or the receipt's elapsed time.
export function completionUpdate({
  current, lessonId, errors = 0, rewardToken, receipt,
  elapsedSeconds, utcOffsetMinutes = 0, now = Date.now(),
}) {
  if (!lessons.has(lessonId)) throw new ApiError(400, 'unknown_lesson', 'Unknown lesson.');
  const completed = new Set((Array.isArray(current.completedLessons) ? current.completedLessons : [])
    .filter((id) => lessons.has(id)));
  const firstCompletion = !completed.has(lessonId);
  completed.add(lessonId);
  const xpEarned = firstCompletion ? lessonXp[lessonId] : 5;
  const days = completionDays(utcOffsetMinutes, now);
  // A timezone change may move the clock backwards. Do not reset a valid
  // streak or count another day when travelling back across midnight.
  const nextLocalDay = new Date(`${days.localDay}T12:00:00Z`);
  nextLocalDay.setUTCDate(nextLocalDay.getUTCDate() + 1);
  const today = current.lastStudyDay === nextLocalDay.toISOString().slice(0, 10)
    ? current.lastStudyDay : days.localDay;
  const yesterday = new Date(`${today}T12:00:00Z`);
  yesterday.setUTCDate(yesterday.getUTCDate() - 1);
  const newDay = current.lastStudyDay !== today;
  const streak = newDay
    ? (current.lastStudyDay === yesterday.toISOString().slice(0, 10) ? Number(current.streak ?? 0) + 1 : 1)
    : Number(current.streak ?? 0);
  const streakBonus = newDay && streak === 7 ? 10
    : newDay && streak === 30 ? 50 : newDay && streak === 100 ? 200 : 0;
  const xp = Number(current.xp ?? 0) + xpEarned + streakBonus;
  const energyBefore = Math.min(999, Math.max(0, Math.floor(Number(current.energy) || 0)));
  const energyEarned = Math.min(8, 999 - energyBefore);
  // Public league caps always use UTC, even while learner-facing streaks and
  // goals use the device's validated UTC offset.
  const leaderboard = leaderboardContribution({
    current, today: days.utcDay, earned: firstCompletion ? xpEarned + streakBonus : 0,
  });
  const time = completionStudyTime(current, receipt, elapsedSeconds);
  const next = {
    ...current,
    xp,
    level: Math.floor(xp / 500) + 1,
    streak,
    bestStreak: bestKnownStreak(current, streak),
    hearts: current.isPremium ? 5 : Math.max(0, Number(current.hearts ?? 5) - clampErrors(errors)),
    energy: energyBefore + energyEarned,
    lastStudyDay: today,
    totalLessons: completed.size,
    totalMinutes: time.totalMinutes,
    totalStudySeconds: time.totalStudySeconds,
    // This means source text practised, not certification of memorization.
    learnedAyats: distinctStudiedAyahs(completed),
    learnedDuas: Number(current.learnedDuas ?? 0) + (firstCompletion && lessonId === 'r4' ? 2 : 0),
    dailyProgress: nextDailyProgress({ current, today }),
    lessonAttempts: Number(current.lessonAttempts ?? 0) + 1,
    speechAttempts: Number(current.speechAttempts ?? 0),
    rewardChestsOpened: Number(current.rewardChestsOpened ?? 0) + 3,
    leaderboardXpToday: leaderboard.leaderboardXpToday,
    leaderboardXpDay: leaderboard.leaderboardXpDay,
    rewardHistory: [...(Array.isArray(current.rewardHistory) ? current.rewardHistory : []), rewardToken].slice(-500),
    completedLessons: [...completed],
    updatedAt: new Date(now).toISOString(),
  };
  return { next, xpEarned, streakBonus, energyEarned, firstCompletion, leaderboard, ...time };
}

export default withApi(async (request, response) => {
  method(request, ['POST']);
  const user = await requireUser(request);
  const body = readJson(request);
  const lessonId = text(body.lessonId, { min: 2, max: 40, field: 'lesson' });
  if (!lessons.has(lessonId)) throw new ApiError(400, 'unknown_lesson', 'Unknown lesson.');
  const errors = clampErrors(body.errors);
  const utcOffsetMinutes = integer(body.utcOffsetMinutes ?? 0, { min: -840, max: 840 });
  const elapsedSeconds = body.elapsedSeconds == null ? undefined
    : integer(body.elapsedSeconds, { min: 0, max: 7200 });
  const speechAttempts = integer(body.speechAttempts ?? 0, { min: 0, max: 50 });
  const attemptToken = text(body.attemptToken, { min: 40, max: 4096, field: 'attempt' });
  const attempt = await verifyLessonAttempt(attemptToken, {
    userId: user.id,
    lessonId,
  });
  const rewardToken = String(attempt.jti);
  const attemptRows = await sql`
    SELECT completed_steps, started_at, consumed_at,
      jti = (
        SELECT active.jti
        FROM muslingo_lesson_attempts active
        WHERE active.user_id = ${user.id}::uuid
          AND active.lesson_id = ${lessonId}
          AND active.consumed_at IS NULL
          AND active.expires_at > now()
        ORDER BY active.started_at DESC, active.jti DESC
        LIMIT 1
      ) AS is_latest
    FROM muslingo_lesson_attempts
    WHERE jti = ${rewardToken}
      AND user_id = ${user.id}::uuid
      AND lesson_id = ${lessonId}
      AND expires_at > now()
    LIMIT 1
  `;
  const attemptState = attemptRows[0];
  if (attemptState?.consumed_at) {
    const rows = await sql`
      SELECT document FROM muslingo_progress WHERE user_id = ${user.id}::uuid
    `;
    if (rows.length > 0) {
      const current = profile(rows[0].document, user);
      if (isRewardReplay(current.rewardHistory, rewardToken)) {
        return response.status(200).json({
          replayed: true,
          xpEarned: 0,
          streakBonus: 0,
          energyEarned: 0,
          studySecondsEarned: 0,
          minutesEarned: 0,
          firstCompletion: false,
          recordedSteps: Number(attemptState.completed_steps ?? 0),
          reportedSpeechAttempts: speechAttempts,
          progress: current,
        });
      }
    }
  }
  const now = Date.now();
  const receipt = lessonAttemptEligibility(attemptState, {
    now, minimumSteps: requiredRecordedSteps(lessonId),
  });
  if (!receipt.eligible || attemptState?.is_latest !== true) {
    throw new ApiError(400, 'incomplete_lesson_attempt', 'Lesson attempt is incomplete.');
  }

  for (let attempt = 0; attempt < 3; attempt += 1) {
    const rows = await sql`SELECT document, version FROM muslingo_progress WHERE user_id = ${user.id}::uuid`;
    if (rows.length === 0) throw new ApiError(404, 'progress_not_found', 'Progress not found.');
    const current = profile(rows[0].document, user);
    if (isRewardReplay(current.rewardHistory, rewardToken)) {
      // Idempotent replay guard: this rewardToken already earned its reward, so
      // return the current profile untouched — no xp/energy/weekly_xp and no
      // counter increments. Without this, replaying the same completion request
      // keeps bumping weekly_xp and climbs the leaderboard.
      return response.status(200).json({
        replayed: true,
        xpEarned: 0,
        streakBonus: 0,
        energyEarned: 0,
        studySecondsEarned: 0,
        minutesEarned: 0,
        firstCompletion: false,
        progress: current,
      });
    }
    const {
      next, xpEarned, streakBonus, energyEarned, firstCompletion,
      leaderboard, studySecondsEarned, minutesEarned,
    } = completionUpdate({
      current, lessonId, errors, rewardToken, receipt,
      elapsedSeconds, utcOffsetMinutes, now,
    });
    const updated = await sql`
      UPDATE muslingo_progress
      SET document = ${JSON.stringify(next)}::jsonb,
          version = version + 1,
          weekly_xp = CASE
            WHEN week_start = date_trunc('week', now())::date THEN weekly_xp + ${leaderboard.contribution}
            ELSE ${leaderboard.contribution}
          END,
          week_start = date_trunc('week', now())::date,
          updated_at = now()
      WHERE user_id = ${user.id}::uuid AND version = ${rows[0].version}
      RETURNING document
    `;
    if (updated.length > 0) {
      await sql`
        UPDATE muslingo_lesson_attempts
        SET consumed_at = now()
        WHERE jti = ${rewardToken}
          AND user_id = ${user.id}::uuid
          AND lesson_id = ${lessonId}
          AND consumed_at IS NULL
      `;
      return response.status(200).json({
        xpEarned,
        streakBonus,
        energyEarned,
        studySecondsEarned,
        minutesEarned,
        firstCompletion,
        recordedSteps: receipt.completedSteps,
        reportedSpeechAttempts: speechAttempts,
        progress: profile(updated[0].document, user),
      });
    }
  }
  throw new ApiError(409, 'progress_conflict', 'Progress changed. Retry the lesson completion.');
});
