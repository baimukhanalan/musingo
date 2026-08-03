import { requireUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { ApiError, integer, method, readJson, text, withApi } from '../lib/http.js';
import { profile } from '../lib/progress.js';

const lessons = new Set([
  'a1', 'a2', 'a3',
  'q_baqara_1', 'q_falaq_1', 'q_fatiha_1', 'q_fatiha_2', 'q_fatiha_3',
  'q_fatiha_4', 'q_ikhlas_1', 'q_nas_1', 'q_review_5_surahs',
  'r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7',
]);

const ayatRewards = {
  q_baqara_1: 1, q_falaq_1: 5, q_fatiha_1: 2, q_fatiha_2: 2,
  q_fatiha_3: 2, q_fatiha_4: 1, q_ikhlas_1: 4, q_nas_1: 6,
};

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
  const errors = integer(body.errors ?? 0, { min: 0, max: 5 });
  const speechAttempts = integer(body.speechAttempts ?? 0, { min: 0, max: 50 });
  const rewardToken = text(body.rewardToken ?? `${lessonId}:${Date.now()}`, { min: 1, max: 160, field: 'reward' });
  const today = validLocalDay(body.localDate);

  for (let attempt = 0; attempt < 3; attempt += 1) {
    const rows = await sql`SELECT document, version FROM muslingo_progress WHERE user_id = ${user.id}::uuid`;
    if (rows.length === 0) throw new ApiError(404, 'progress_not_found', 'Progress not found.');
    const current = profile(rows[0].document, user);
    const completed = new Set(Array.isArray(current.completedLessons) ? current.completedLessons : []);
    const firstCompletion = !completed.has(lessonId);
    completed.add(lessonId);
    const xpEarned = firstCompletion ? 25 : 5;
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
      dailyProgress: Math.min(Number(current.dailyGoal ?? 3), Number(current.dailyProgress ?? 0) + 1),
      lessonAttempts: Number(current.lessonAttempts ?? 0) + 1,
      speechAttempts: Number(current.speechAttempts ?? 0) + speechAttempts,
      rewardChestsOpened: Number(current.rewardChestsOpened ?? 0) + 3,
      rewardHistory: [...(Array.isArray(current.rewardHistory) ? current.rewardHistory : []), rewardToken].slice(-500),
      completedLessons: [...completed],
      updatedAt: new Date().toISOString(),
    };
    const updated = await sql`
      UPDATE muslingo_progress
      SET document = ${JSON.stringify(next)}::jsonb,
          version = version + 1,
          weekly_xp = CASE
            WHEN week_start = date_trunc('week', now())::date THEN weekly_xp + ${xpEarned + streakBonus}
            ELSE ${xpEarned + streakBonus}
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
