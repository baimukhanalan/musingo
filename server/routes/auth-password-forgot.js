import { sql, ensureSchema } from '../lib/db.js';
import {
  emailActionRateKey,
  genericEmailActionResponse,
  issueAndSendAccountEmail,
} from '../lib/email.js';
import { clientIp, method, readJson, text, withApi } from '../lib/http.js';
import { consumeLoginAttempt } from '../lib/login-rate-limit.js';

const MAX_ATTEMPTS = 5;

export default withApi(async (request, response) => {
  method(request, ['POST']);
  await ensureSchema();
  const body = readJson(request);
  const email = text(body.email, { min: 5, max: 254, field: 'email' }).toLowerCase();
  const ip = clientIp(request);
  await consumeLoginAttempt(emailActionRateKey('reset-ip', ip), MAX_ATTEMPTS);
  await consumeLoginAttempt(emailActionRateKey('reset-address', `${email}|${ip}`), MAX_ATTEMPTS);

  const rows = await sql`
    SELECT id, email
    FROM muslingo_users
    WHERE email = ${email} AND email_verified_at IS NOT NULL
    LIMIT 1
  `;
  if (rows[0]) {
    const delivery = await issueAndSendAccountEmail({
      userId: rows[0].id,
      email: rows[0].email,
      purpose: 'password_reset',
    });
    if (delivery.status === 'failed') {
      console.error('Muslingo account email delivery failed', {
        purpose: 'password_reset',
        providerStatus: delivery.providerStatus,
      });
    }
  }
  return response.status(202).json(genericEmailActionResponse());
});
