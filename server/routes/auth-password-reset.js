import { hashPassword } from '../lib/auth.js';
import { sql, ensureSchema } from '../lib/db.js';
import { emailActionRateKey, hashEmailToken } from '../lib/email.js';
import { ApiError, clientIp, method, readJson, text, withApi } from '../lib/http.js';
import { consumeLoginAttempt } from '../lib/login-rate-limit.js';

const MAX_ATTEMPTS = 10;

export default withApi(async (request, response) => {
  method(request, ['POST']);
  await ensureSchema();
  const body = readJson(request);
  const token = text(body.token, { min: 40, max: 100, field: 'token' });
  const newPassword = text(body.newPassword, { min: 8, max: 128, field: 'newPassword' });
  const tokenHash = hashEmailToken(token);
  await consumeLoginAttempt(
    emailActionRateKey('reset-confirm', clientIp(request)),
    MAX_ATTEMPTS,
  );
  const credentials = await hashPassword(newPassword);
  const rows = await sql`
    WITH claimed AS (
      UPDATE muslingo_email_tokens
      SET consumed_at = now()
      WHERE token_hash = ${tokenHash}
        AND purpose = 'password_reset'
        AND consumed_at IS NULL
        AND expires_at > now()
      RETURNING user_id
    )
    UPDATE muslingo_users u
    SET password_salt = ${credentials.salt},
        password_hash = ${credentials.hash},
        session_version = u.session_version + 1,
        updated_at = now()
    FROM claimed
    WHERE u.id = claimed.user_id
      AND u.email_verified_at IS NOT NULL
    RETURNING u.id
  `;
  if (rows.length === 0) {
    throw new ApiError(400, 'invalid_or_expired_token', 'The reset link is invalid or expired.');
  }
  return response.status(200).json({ passwordReset: true });
});
