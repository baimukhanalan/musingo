import { hashPassword, issueToken, passwordMatches, requireSession } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { ApiError, method, readJson, text, withApi } from '../lib/http.js';
import {
  clearLoginFailures,
  consumeLoginAttempt,
  PASSWORD_CHANGE_MAX_ATTEMPTS,
  passwordChangeKey,
} from '../lib/login-rate-limit.js';

export default withApi(async (request, response) => {
  method(request, ['POST']);
  const { user } = await requireSession(request);
  const body = readJson(request);
  const currentPassword = text(body.currentPassword, {
    min: 1,
    max: 128,
    field: 'currentPassword',
  });
  const newPassword = text(body.newPassword, {
    min: 8,
    max: 128,
    field: 'newPassword',
  });
  const rateKey = passwordChangeKey(user.id);
  await consumeLoginAttempt(rateKey, PASSWORD_CHANGE_MAX_ATTEMPTS);

  const rows = await sql`
    SELECT password_salt, password_hash, session_version
    FROM muslingo_users
    WHERE id = ${user.id}::uuid
    LIMIT 1
  `;
  const credentials = rows[0];
  if (!credentials || !(await passwordMatches(
    currentPassword,
    credentials.password_salt,
    credentials.password_hash,
  ))) {
    throw new ApiError(401, 'invalid_current_password', 'Current password is incorrect.');
  }
  if (await passwordMatches(
    newPassword,
    credentials.password_salt,
    credentials.password_hash,
  )) {
    throw new ApiError(400, 'password_reuse', 'New password must be different.');
  }

  const next = await hashPassword(newPassword);
  const updated = await sql`
    UPDATE muslingo_users
    SET password_salt = ${next.salt},
        password_hash = ${next.hash},
        session_version = session_version + 1,
        updated_at = now()
    WHERE id = ${user.id}::uuid
      AND password_hash = ${credentials.password_hash}
    RETURNING session_version
  `;
  if (updated.length === 0) {
    throw new ApiError(409, 'password_changed', 'Password was changed in another session.');
  }
  await clearLoginFailures(rateKey);
  return response.status(200).json({
    token: await issueToken(user.id, updated[0].session_version),
  });
});
