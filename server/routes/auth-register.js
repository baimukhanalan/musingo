import { randomUUID } from 'node:crypto';

import { hashPassword, issueToken } from '../lib/auth.js';
import { sql, ensureSchema } from '../lib/db.js';
import { ApiError, clientIp, method, readJson, text, withApi } from '../lib/http.js';
import { consumeRegisterAttempt, registerKey } from '../lib/login-rate-limit.js';
import { defaultProgress, profile } from '../lib/progress.js';

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
  // A duplicate email surfaces as Postgres 23505 -> 409 already_exists (mapped
  // in withApi). That does confirm existence, which the client relies on to show
  // a "sign in instead" hint; hashPassword already ran above so timing does not
  // additionally leak. Fully removing this oracle needs an email-verification
  // flow (out of scope — it would change the client contract).
  const rows = await sql`
    WITH new_user AS (
      INSERT INTO muslingo_users (id, email, display_name, password_salt, password_hash)
      VALUES (${id}::uuid, ${email}, ${name}, ${credentials.salt}, ${credentials.hash})
      RETURNING id, email, display_name
    ), new_progress AS (
      INSERT INTO muslingo_progress (user_id, document)
      SELECT id, ${JSON.stringify(initial)}::jsonb FROM new_user
      RETURNING user_id, document
    )
    SELECT new_user.id, new_user.email, new_user.display_name, new_progress.document
    FROM new_user JOIN new_progress ON new_progress.user_id = new_user.id
  `;
  const user = rows[0];
  return response.status(201).json({
    token: await issueToken(user.id),
    profile: profile(user.document, user),
  });
});
