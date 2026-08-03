import { createHash } from 'node:crypto';

import { optionalUser } from '../lib/auth.js';
import { sql, ensureSchema } from '../lib/db.js';
import { integer, method, readJson, text, withApi } from '../lib/http.js';

export default withApi(async (request, response) => {
  method(request, ['POST']);
  await ensureSchema();
  const user = await optionalUser(request);
  const body = readJson(request);
  const subscription = body.subscription && typeof body.subscription === 'object' ? body.subscription : {};
  const endpoint = text(subscription.endpoint, { min: 20, max: 2048, field: 'endpoint' });
  const endpointUrl = new URL(endpoint);
  if (endpointUrl.protocol !== 'https:') throw new Error('Push endpoint must use HTTPS.');
  const keys = subscription.keys && typeof subscription.keys === 'object' ? subscription.keys : {};
  const p256dh = text(keys.p256dh, { min: 20, max: 512, field: 'p256dh' });
  const authSecret = text(keys.auth, { min: 8, max: 256, field: 'auth' });
  const installationId = text(body.installationId, { min: 8, max: 128, field: 'installation' });
  const timezone = text(body.timezone ?? 'UTC', { min: 1, max: 80, field: 'timezone' });
  try {
    new Intl.DateTimeFormat('en-US', { timeZone: timezone }).format(new Date());
  } catch {
    throw new Error('Invalid timezone.');
  }
  const hour = integer(body.hour ?? 19, { min: 0, max: 23 });
  const minute = integer(body.minute ?? 30, { min: 0, max: 59 });
  const dueCount = integer(body.dueCount ?? 0, { min: 0, max: 10_000 });
  const learningGoal = body.learningGoal ? text(body.learningGoal, { min: 1, max: 40, field: 'goal' }) : null;
  const endpointHash = createHash('sha256').update(endpoint).digest('hex');

  await sql`
    INSERT INTO muslingo_push_subscriptions (
      endpoint_hash, endpoint, p256dh, auth_secret, installation_id, user_id,
      timezone, reminder_hour, reminder_minute, enabled, learning_goal, due_count, updated_at
    ) VALUES (
      ${endpointHash}, ${endpoint}, ${p256dh}, ${authSecret}, ${installationId},
      ${user?.id ?? null}::uuid, ${timezone}, ${hour}, ${minute}, true,
      ${learningGoal}, ${dueCount}, now()
    )
    ON CONFLICT (endpoint_hash) DO UPDATE SET
      p256dh = excluded.p256dh,
      auth_secret = excluded.auth_secret,
      installation_id = excluded.installation_id,
      user_id = COALESCE(excluded.user_id, muslingo_push_subscriptions.user_id),
      timezone = excluded.timezone,
      reminder_hour = excluded.reminder_hour,
      reminder_minute = excluded.reminder_minute,
      enabled = true,
      learning_goal = excluded.learning_goal,
      due_count = excluded.due_count,
      updated_at = now()
  `;
  return response.status(200).json({ subscribed: true });
});
