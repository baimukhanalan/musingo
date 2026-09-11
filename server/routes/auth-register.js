import { randomUUID } from 'node:crypto';

import { hashPassword } from '../lib/auth.js';
import { sql, ensureSchema } from '../lib/db.js';
import {
  genericEmailActionResponse,
  issueAndSendAccountEmail,
} from '../lib/email.js';
import { ApiError, clientIp, method, readJson, text, withApi } from '../lib/http.js';
import { consumeRegisterAttempt, registerKey } from '../lib/login-rate-limit.js';
import { defaultProgress } from '../lib/progress.js';

export default withApi(async (request, response) => {
  method(request, ['POST']);
  await ensureSchema();
  // Every registration runs scrypt (in hashPassword below), so throttle per-IP
  // before doing any work — this blocks mass sign-ups / CPU exhaustion from a
  // single address. The bucket is a hashed, "register:"-namespaced key that is
  // independent of the login limiter; assert the cap, then count this attempt.
  const rateKey = registerKey(clientIp(request));
  await consumeRegisterAttempt(rateKey);

  const body = readJson(request);
  const name = text(body.name, { min: 2, max: 60, field: 'name' });
  const email = text(body.email, { min: 5, max: 254, field: 'email' }).toLowerCase();
  const password = text(body.password, { min: 8, max: 128, field: 'password' });
  if (!/^[^\s@]+@[^\s@]+\.[^\s@]+$/.test(email)) {
    throw new ApiError(400, 'invalid_email', 'Invalid email address.');
  }

  const id = randomUUID();
  const credentials = await hashPassword(password);
  const initial = defaultProgress({ id, email, display_name: name });
  const created = await sql`
    WITH new_user AS (
      INSERT INTO muslingo_users (id, email, display_name, password_salt, password_hash)
      VALUES (${id}::uuid, ${email}, ${name}, ${credentials.salt}, ${credentials.hash})
      ON CONFLICT (email) DO NOTHING
      RETURNING id
    ), new_progress AS (
      INSERT INTO muslingo_progress (user_id, document)
      SELECT id, ${JSON.stringify(initial)}::jsonb FROM new_user
      RETURNING user_id
    )
    SELECT user_id FROM new_progress
  `;
  if (created[0]?.user_id) {
    const delivery = await issueAndSendAccountEmail({
      userId: created[0].user_id,
      email,
      purpose: 'verify_email',
    });
    if (delivery.status === 'failed') {
      console.error('Muslingo account email delivery failed', {
        purpose: 'verify_email',
        providerStatus: delivery.providerStatus,
      });
    }
  }
  // Identical status and body for new and existing addresses. The app follows
  // with the ordinary login endpoint, whose failure is already generic.
  return response.status(202).json({
    ...genericEmailActionResponse(),
  });
});
