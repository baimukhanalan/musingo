import { createHash } from 'node:crypto';

import { issueToken, passwordMatches } from '../lib/auth.js';
import { sql, ensureSchema } from '../lib/db.js';
import { ApiError, clientIp, method, readJson, text, withApi } from '../lib/http.js';
import { assertLoginAllowed, clearLoginFailures, recordLoginFailure } from '../lib/login-rate-limit.js';
import { profile } from '../lib/progress.js';

export default withApi(async (request, response) => {
  method(request, ['POST']);
  await ensureSchema();
  const body = readJson(request);
  const email = text(body.email, { min: 5, max: 254, field: 'email' }).toLowerCase();
  const password = text(body.password, { min: 1, max: 128, field: 'password' });
  const rateKey = createHash('sha256').update(`${email}|${clientIp(request)}`).digest('hex');
  await assertLoginAllowed(rateKey);

  const rows = await sql`
    SELECT u.id, u.email, u.display_name, u.password_salt, u.password_hash, p.document
    FROM muslingo_users u
    JOIN muslingo_progress p ON p.user_id = u.id
    WHERE u.email = ${email}
    LIMIT 1
  `;
  const user = rows[0];
  if (!user || !(await passwordMatches(password, user.password_salt ?? '', user.password_hash ?? ''))) {
    await recordLoginFailure(rateKey);
    throw new ApiError(401, 'invalid_credentials', 'Invalid email or password.');
  }
  await clearLoginFailures(rateKey);
  return response.status(200).json({
    token: issueToken(user.id),
    profile: profile(user.document, user),
  });
});
