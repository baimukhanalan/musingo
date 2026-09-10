import { requireUser, verifyLessonAttempt } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { integer, method, readJson, text, withApi } from '../lib/http.js';

export default withApi(async (request, response) => {
  method(request, ['POST']);
  const user = await requireUser(request);
  const body = readJson(request);
  const lessonId = text(body.lessonId, { min: 2, max: 40, field: 'lesson' });
  const attemptToken = text(body.attemptToken, { min: 40, max: 4096, field: 'attempt' });
  const stepIndex = integer(body.stepIndex, { min: 0, max: 200 });
  const attempt = await verifyLessonAttempt(attemptToken, {
    userId: user.id,
    lessonId,
    minAgeSeconds: 0,
  });
  const updated = await sql`
    UPDATE muslingo_lesson_attempts
    SET completed_steps = completed_steps + 1
    WHERE jti = ${String(attempt.jti)}
      AND user_id = ${user.id}::uuid
      AND lesson_id = ${lessonId}
      AND consumed_at IS NULL
      AND expires_at > now()
      AND completed_steps = ${stepIndex}
    RETURNING completed_steps
  `;
  if (updated.length === 0) {
    return response.status(409).json({
      error: 'invalid_step_sequence',
      message: 'Lesson steps must be completed in order.',
    });
  }
  return response.status(200).json({ completedSteps: Number(updated[0].completed_steps) });
});
