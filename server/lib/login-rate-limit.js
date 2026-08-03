// Shared by the single Vercel API router.
import { sql } from './db.js';
import { ApiError } from './http.js';

const windowMinutes = 15;
const maxAttempts = 8;

export async function assertLoginAllowed(key) {
  const rows = await sql`
    SELECT attempts, window_started_at
    FROM muslingo_login_attempts
    WHERE key = ${key}
  `;
  if (rows.length === 0) return;
  const age = Date.now() - new Date(rows[0].window_started_at).getTime();
  if (age <= windowMinutes * 60_000 && rows[0].attempts >= maxAttempts) {
    throw new ApiError(429, 'too_many_attempts', 'Too many login attempts. Try again later.');
  }
}

export async function recordLoginFailure(key) {
  await sql`
    INSERT INTO muslingo_login_attempts (key, attempts, window_started_at)
    VALUES (${key}, 1, now())
    ON CONFLICT (key) DO UPDATE SET
      attempts = CASE
        WHEN muslingo_login_attempts.window_started_at < now() - interval '15 minutes' THEN 1
        ELSE muslingo_login_attempts.attempts + 1
      END,
      window_started_at = CASE
        WHEN muslingo_login_attempts.window_started_at < now() - interval '15 minutes' THEN now()
        ELSE muslingo_login_attempts.window_started_at
      END
  `;
}

export async function clearLoginFailures(key) {
  await sql`DELETE FROM muslingo_login_attempts WHERE key = ${key}`;
}
