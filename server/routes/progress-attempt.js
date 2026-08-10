import { issueLessonAttempt, requireUser } from '../lib/auth.js';
import { ApiError, method, readJson, text, withApi } from '../lib/http.js';
import { lessons } from './progress-complete.js';

export default withApi(async (request, response) => {
  method(request, ['POST']);
  const user = await requireUser(request);
  const body = readJson(request);
  const lessonId = text(body.lessonId, { min: 2, max: 40, field: 'lesson' });
  if (!lessons.has(lessonId)) throw new ApiError(400, 'unknown_lesson', 'Unknown lesson.');
  return response.status(201).json({
    attemptToken: await issueLessonAttempt(user.id, lessonId),
  });
});
