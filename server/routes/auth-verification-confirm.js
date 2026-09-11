import { hashEmailToken, emailActionRateKey } from '../lib/email.js';
import { sql, ensureSchema } from '../lib/db.js';
import { ApiError, clientIp, method, readJson, text, withApi } from '../lib/http.js';
import { consumeLoginAttempt } from '../lib/login-rate-limit.js';

const MAX_ATTEMPTS = 12;

export default withApi(async (request, response) => {
  method(request, ['POST']);
  await ensureSchema();
  const body = readJson(request);
  const token = text(body.token, { min: 40, max: 100, field: 'token' });
  const tokenHash = hashEmailToken(token);
  await consumeLoginAttempt(
    emailActionRateKey('verify-confirm', clientIp(request)),
    MAX_ATTEMPTS,
  );

  const rows = await sql`
    WITH claimed AS (
      UPDATE muslingo_email_tokens
      SET consumed_at = now()
      WHERE token_hash = ${tokenHash}
        AND purpose = 'verify_email'
        AND consumed_at IS NULL
        AND expires_at > now()
      RETURNING user_id
    )
    UPDATE muslingo_users u
    SET email_verified_at = COALESCE(u.email_verified_at, now()),
        updated_at = now()
    FROM claimed
    WHERE u.id = claimed.user_id
    RETURNING u.id
  `;
  if (rows.length === 0) {
    throw new ApiError(400, 'invalid_or_expired_token', 'The verification link is invalid or expired.');
  }
  return response.status(200).json({ verified: true });
});
