import { issueLessonAttempt, requireUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { ApiError, method, readJson, text, withApi } from '../lib/http.js';
import { lessons, previousLessonId, requiredRecordedSteps } from './progress-complete.js';

export default withApi(async (request, response) => {
  method(request, ['POST']);
  const user = await requireUser(request);
  const body = readJson(request);
  const lessonId = text(body.lessonId, { min: 2, max: 40, field: 'lesson' });
  if (!lessons.has(lessonId)) throw new ApiError(400, 'unknown_lesson', 'Unknown lesson.');
  const currentRows = await sql`
    SELECT document FROM muslingo_progress WHERE user_id = ${user.id}::uuid
  `;
  const completed = new Set(currentRows[0]?.document?.completedLessons ?? []);
  const previous = previousLessonId(lessonId);
  if (previous && !completed.has(previous)) {
    throw new ApiError(409, 'lesson_locked', 'Complete the previous lesson first.');
  }
  const attempt = await issueLessonAttempt(user.id, lessonId);
  await sql`
    DELETE FROM muslingo_lesson_attempts
    WHERE user_id = ${user.id}::uuid AND (expires_at <= now() OR consumed_at IS NOT NULL)
  `;
  // Only one live receipt may exist for a user/lesson. Starting over invalidates
  // an abandoned tab or device so steps from separate attempts cannot be mixed.
  await sql`
    UPDATE muslingo_lesson_attempts
    SET consumed_at = now()
    WHERE user_id = ${user.id}::uuid
      AND lesson_id = ${lessonId}
      AND consumed_at IS NULL
      AND expires_at > now()
  `;
  await sql`
    INSERT INTO muslingo_lesson_attempts (jti, user_id, lesson_id, expires_at)
    VALUES (${attempt.jti}, ${user.id}::uuid, ${lessonId}, now() + interval '2 hours')
  `;
  return response.status(201).json({
    attemptToken: attempt.token,
    minimumRecordedSteps: requiredRecordedSteps(lessonId),
    expiresInSeconds: 2 * 60 * 60,
  });
});
