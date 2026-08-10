import { requireUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { ApiError, integer, method, readJson, text, withApi } from '../lib/http.js';
import { isRewardReplay, leaderboardContribution, nextDailyProgress, profile } from '../lib/progress.js';

// Full lesson registry mirrored from the client (lib/services/lessons/
// {arabic,quran,rules}_lessons.dart). Every lesson id the app can complete MUST
// be present, or POST /api/progress/complete rejects it with 400 unknown_lesson
// and a signed-in user's progress for that lesson is silently dropped.
export const lessons = new Set([
  // arabic_lessons.dart (a1–a16)
  'a1', 'a2', 'a3', 'a4', 'a5', 'a6', 'a7', 'a8',
  'a9', 'a10', 'a11', 'a12', 'a13', 'a14', 'a15', 'a16',
  // quran_lessons.dart
  'q_fatiha_1', 'q_fatiha_2', 'q_fatiha_3', 'q_fatiha_4',
  'q_ikhlas_1', 'q_falaq_1', 'q_nas_1', 'q_review_5_surahs',
  'q_baqara_1', 'q_asr_1', 'q_fil_1', 'q_quraysh_1', 'q_maun_1',
  'q_kawthar_1', 'q_kafirun_1', 'q_nasr_1', 'q_masad_1', 'q_review_short_surahs',
  'q_humaza_1', 'q_takathur_1', 'q_qaria_1', 'q_adiyat_1', 'q_zalzala_1',
  'q_qadr_1', 'q_tin_1', 'q_sharh_1', 'q_duha_1', 'q_ala_1',
  'q_alaq_1', 'q_shams_1', 'q_layl_1', 'q_fajr_1', 'q_ghashiya_1',
  'q_tariq_1', 'q_buruj_1',
  // rules_lessons.dart (r1–r10)
  'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7', 'r8', 'r9', 'r10',
]);

// learnedAyats credited on first completion = number of DISTINCT
// quranGlobalAyahNumber values across a quran lesson's steps (counted from
// quran_lessons.dart). Review lessons (q_review_*) carry no ayat reward and are
// intentionally omitted (treated as 0).
export const ayatRewards = {
  q_fatiha_1: 1, q_fatiha_2: 2, q_fatiha_3: 2, q_fatiha_4: 2,
  q_ikhlas_1: 2, q_falaq_1: 1, q_nas_1: 1,
  q_baqara_1: 2, q_asr_1: 3, q_fil_1: 5, q_quraysh_1: 4, q_maun_1: 7,
  q_kawthar_1: 3, q_kafirun_1: 6, q_nasr_1: 3, q_masad_1: 5,
  q_humaza_1: 9, q_takathur_1: 8, q_qaria_1: 11, q_adiyat_1: 11, q_zalzala_1: 8,
  q_qadr_1: 5, q_tin_1: 8, q_sharh_1: 8, q_duha_1: 11, q_ala_1: 19,
  q_alaq_1: 19, q_shams_1: 15, q_layl_1: 21, q_fajr_1: 30, q_ghashiya_1: 26,
  q_tariq_1: 17, q_buruj_1: 22,
};

// M2: first-completion xp must equal the lesson's own xpReward (lib/services/
// lessons/*.dart) so a signed-in user earns exactly what a guest sees. Field
// omitted in the .dart lesson => client default of 25. Repeats stay flat at 5
// (handled at the call site), matching the client's replay economy.
export const lessonXp = {
  a1: 20, a2: 20, a3: 25, a4: 20, a5: 25, a6: 25, a7: 20, a8: 20,
  a9: 25, a10: 25, a11: 20, a12: 20, a13: 25, a14: 25, a15: 25, a16: 25,
  q_fatiha_1: 25, q_fatiha_2: 25, q_fatiha_3: 25, q_fatiha_4: 25,
  q_ikhlas_1: 25, q_falaq_1: 25, q_nas_1: 25, q_review_5_surahs: 45,
  q_baqara_1: 25, q_asr_1: 25, q_fil_1: 25, q_quraysh_1: 25, q_maun_1: 25,
  q_kawthar_1: 25, q_kafirun_1: 25, q_nasr_1: 25, q_masad_1: 25, q_review_short_surahs: 45,
  q_humaza_1: 25, q_takathur_1: 25, q_qaria_1: 25, q_adiyat_1: 25, q_zalzala_1: 25,
  q_qadr_1: 25, q_tin_1: 25, q_sharh_1: 25, q_duha_1: 25, q_ala_1: 25,
  q_alaq_1: 25, q_shams_1: 25, q_layl_1: 25, q_fajr_1: 25, q_ghashiya_1: 25,
  q_tariq_1: 25, q_buruj_1: 25,
  r1: 25, r2: 25, r3: 25, r4: 25, r5: 25, r6: 25, r7: 25, r8: 25, r9: 25, r10: 25,
};

// C1-hardening: clamp the reported mistake count into [0, 5] instead of
// rejecting >5 with a 400. A stale or third-party client that reports more
// mistakes must still have its completion recorded — dropping the request would
// wipe the user's progress for that lesson. Non-numeric / negative values still
// fail validation via integer() as before.
export function clampErrors(value) {
  return Math.min(5, integer(value ?? 0, { min: 0, max: Number.MAX_SAFE_INTEGER }));
}

function validLocalDay(value) {
  const day = String(value ?? '');
  if (!/^\d{4}-\d{2}-\d{2}$/.test(day)) return new Date().toISOString().slice(0, 10);
  const timestamp = Date.parse(`${day}T12:00:00Z`);
  if (Math.abs(timestamp - Date.now()) > 36 * 60 * 60 * 1000) {
    return new Date().toISOString().slice(0, 10);
  }
  return day;
}

export default withApi(async (request, response) => {
  method(request, ['POST']);
  const user = await requireUser(request);
  const body = readJson(request);
  const lessonId = text(body.lessonId, { min: 2, max: 40, field: 'lesson' });
  if (!lessons.has(lessonId)) throw new ApiError(400, 'unknown_lesson', 'Unknown lesson.');
  const errors = clampErrors(body.errors);
  const speechAttempts = integer(body.speechAttempts ?? 0, { min: 0, max: 50 });
  const rewardToken = text(body.rewardToken ?? `${lessonId}:${Date.now()}`, { min: 1, max: 160, field: 'reward' });
  const today = validLocalDay(body.localDate);

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
        firstCompletion: false,
        progress: current,
      });
    }
    const completed = new Set(Array.isArray(current.completedLessons) ? current.completedLessons : []);
    const firstCompletion = !completed.has(lessonId);
    completed.add(lessonId);
    const xpEarned = firstCompletion ? (lessonXp[lessonId] ?? 25) : 5;
    const yesterday = new Date(`${today}T12:00:00Z`);
    yesterday.setUTCDate(yesterday.getUTCDate() - 1);
    const yesterdayText = yesterday.toISOString().slice(0, 10);
    const newDay = current.lastStudyDay !== today;
    const streak = newDay
      ? (current.lastStudyDay === yesterdayText ? Number(current.streak ?? 0) + 1 : 1)
      : Number(current.streak ?? 0);
    const streakBonus = newDay && streak === 7 ? 10 : newDay && streak === 30 ? 50 : newDay && streak === 100 ? 200 : 0;
    const xp = Number(current.xp ?? 0) + xpEarned + streakBonus;
    const energyEarned = Math.max(4, 12 - errors * 2);
    // Personal xp above is credited in full. Only the slice that reaches the
    // weekly leaderboard is clipped to the per-day cap (remaining budget for
    // `today`); the day-scoped counter is written back under the same version.
    const leaderboard = leaderboardContribution({ current, today, earned: xpEarned + streakBonus });
    const next = {
      ...current,
      xp,
      level: Math.floor(xp / 500) + 1,
      streak,
      hearts: current.isPremium ? 5 : Math.max(0, Number(current.hearts ?? 5) - errors),
      energy: Math.min(999, Number(current.energy ?? 0) + energyEarned),
      lastStudyDay: today,
      totalLessons: Number(current.totalLessons ?? 0) + 1,
      totalMinutes: Number(current.totalMinutes ?? 0) + 5,
      learnedAyats: Number(current.learnedAyats ?? 0) + (firstCompletion ? (ayatRewards[lessonId] ?? 0) : 0),
      learnedDuas: Number(current.learnedDuas ?? 0) + (firstCompletion && lessonId === 'r4' ? 2 : 0),
      dailyProgress: nextDailyProgress({ current, today }),
      lessonAttempts: Number(current.lessonAttempts ?? 0) + 1,
      speechAttempts: Number(current.speechAttempts ?? 0) + speechAttempts,
      rewardChestsOpened: Number(current.rewardChestsOpened ?? 0) + 3,
      leaderboardXpToday: leaderboard.leaderboardXpToday,
      leaderboardXpDay: leaderboard.leaderboardXpDay,
      rewardHistory: [...(Array.isArray(current.rewardHistory) ? current.rewardHistory : []), rewardToken].slice(-500),
      completedLessons: [...completed],
      updatedAt: new Date().toISOString(),
    };
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
      return response.status(200).json({
        xpEarned,
        streakBonus,
        firstCompletion,
        progress: profile(updated[0].document, user),
      });
    }
  }
  throw new ApiError(409, 'progress_conflict', 'Progress changed. Retry the lesson completion.');
});
