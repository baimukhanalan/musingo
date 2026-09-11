import { createHash } from 'node:crypto';

import { issueToken, verifyLoginPassword } from '../lib/auth.js';
import { sql, ensureSchema } from '../lib/db.js';
import { ApiError, clientIp, method, readJson, text, withApi } from '../lib/http.js';
import { clearLoginFailures, consumeLoginAttempt } from '../lib/login-rate-limit.js';
import { profile } from '../lib/progress.js';
import { emailProviderStatus } from '../lib/email.js';

// Per-ip cap catches password spraying across many emails from one address
// while still tolerating a shared NAT. Overridable for busy egress IPs.
const ipAttemptLimit = (() => {
  const parsed = Number(process.env.MUSLINGO_LOGIN_IP_MAX);
  return Number.isFinite(parsed) && parsed > 0 ? parsed : 50;
})();

function rateKey(...parts) {
  return createHash('sha256').update(parts.join('|')).digest('hex');
}

export default withApi(async (request, response) => {
  method(request, ['POST']);
  await ensureSchema();
  const body = readJson(request);
  const email = text(body.email, { min: 5, max: 254, field: 'email' }).toLowerCase();
  const password = text(body.password, { min: 1, max: 128, field: 'password' });
  const ip = clientIp(request);
  // Two independent limits: per (email, ip) blocks targeted brute force, per ip
  // blocks password spraying across many emails from a single address.
  const pairKey = rateKey('pair', email, ip);
  const ipKey = rateKey('ip', ip);
  // Consume both buckets atomically before password work. A separate
  // read-then-increment let concurrent requests all pass the same cap.
  await consumeLoginAttempt(ipKey, ipAttemptLimit);
  await consumeLoginAttempt(pairKey);

  const rows = await sql`
    SELECT u.id, u.email, u.display_name, u.password_salt, u.password_hash,
           u.email_verified_at, u.session_version, p.document
    FROM muslingo_users u
    JOIN muslingo_progress p ON p.user_id = u.id
    WHERE u.email = ${email}
    LIMIT 1
  `;
  const user = rows[0];
  // verifyLoginPassword runs scrypt whether or not the account exists, so an
  // unknown email and a wrong password are indistinguishable: same timing and
  // the same 401 invalid_credentials response.
  if (!(await verifyLoginPassword(user, password))) {
    throw new ApiError(401, 'invalid_credentials', 'Invalid email or password.');
  }
  if (!user.email_verified_at && emailProviderStatus() === 'provider_configured') {
    throw new ApiError(403, 'email_not_verified', 'Email verification is required.');
  }
  // Only the pair key is cleared on success; the ip counter is left to expire so
  // spray protection cannot be reset by an attacker who owns one valid account.
  await clearLoginFailures(pairKey);
  return response.status(200).json({
    token: await issueToken(user.id, user.session_version),
    profile: {
      ...profile(user.document, user),
      emailVerified: Boolean(user.email_verified_at),
    },
    emailVerified: Boolean(user.email_verified_at),
    verificationRequired: !user.email_verified_at,
  });
});
