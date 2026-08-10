// Shared by the single Vercel API router.
import { createHash } from 'node:crypto';

import { sql } from './db.js';
import { ApiError } from './http.js';

const loginWindowMinutes = 15;
// Per (email, ip): a legit user needs only a handful of tries.
const loginMaxAttempts = 8;
// Registration runs scrypt on every call, so it is throttled per-IP too. A
// generous 20/hour blunts mass sign-up / CPU-exhaustion without inconveniencing
// a real user who fumbles a form a few times. Exported so tests pin the values.
export const REGISTER_WINDOW_MINUTES = 60;
export const REGISTER_MAX_ATTEMPTS = 20;
// Rows older than this can no longer trip any limiter; delete them so the table
// cannot grow unbounded (previously one row per distinct key was never cleaned).
const retentionHours = 6;

// Pure decision: does a stored bucket still block a fresh attempt? It blocks
// only while the window has not elapsed AND the counter has reached the limit.
// A missing bucket (null attempts / timestamp) never blocks. Kept side-effect
// free so the window/counter/reset semantics are unit-testable without a DB.
export function isRateLimited({ attempts, windowStartedAt, limit, windowMinutes, now = Date.now() }) {
  if (attempts == null || windowStartedAt == null) return false;
  const age = now - new Date(windowStartedAt).getTime();
  return age <= windowMinutes * 60_000 && Number(attempts) >= limit;
}

// Namespaced, hashed bucket key for the register limiter. The "register:" prefix
// keeps it disjoint from the login limiter (whose keys are bare sha256 hex), and
// hashing avoids persisting a raw client IP. `ip` comes from trustedClientIp
// (the rightmost, un-spoofable X-Forwarded-For hop).
export function registerKey(ip) {
  return `register:${createHash('sha256').update(String(ip ?? '')).digest('hex')}`;
}

async function assertAllowed(key, { limit, windowMinutes, message }) {
  const rows = await sql`
    SELECT attempts, window_started_at
    FROM muslingo_login_attempts
    WHERE key = ${key}
  `;
  if (rows.length === 0) return;
  if (
    isRateLimited({
      attempts: rows[0].attempts,
      windowStartedAt: rows[0].window_started_at,
      limit,
      windowMinutes,
    })
  ) {
    throw new ApiError(429, 'too_many_attempts', message);
  }
}

async function recordAttempt(key, { windowMinutes }) {
  await sql`
    INSERT INTO muslingo_login_attempts (key, attempts, window_started_at)
    VALUES (${key}, 1, now())
    ON CONFLICT (key) DO UPDATE SET
      attempts = CASE
        WHEN muslingo_login_attempts.window_started_at < now() - make_interval(mins => ${windowMinutes}::int) THEN 1
        ELSE muslingo_login_attempts.attempts + 1
      END,
      window_started_at = CASE
        WHEN muslingo_login_attempts.window_started_at < now() - make_interval(mins => ${windowMinutes}::int) THEN now()
        ELSE muslingo_login_attempts.window_started_at
      END
  `;
  await purgeStaleLoginAttempts();
}

export async function assertLoginAllowed(key, limit = loginMaxAttempts) {
  return assertAllowed(key, {
    limit,
    windowMinutes: loginWindowMinutes,
    message: 'Too many login attempts. Try again later.',
  });
}

export async function recordLoginFailure(key) {
  return recordAttempt(key, { windowMinutes: loginWindowMinutes });
}

export async function clearLoginFailures(key) {
  await sql`DELETE FROM muslingo_login_attempts WHERE key = ${key}`;
}

// Register limiter counts every attempt (there is no success/failure split — the
// scrypt runs regardless), so callers assert then record on each request.
export async function assertRegisterAllowed(key, limit = REGISTER_MAX_ATTEMPTS) {
  return assertAllowed(key, {
    limit,
    windowMinutes: REGISTER_WINDOW_MINUTES,
    message: 'Too many registration attempts. Try again later.',
  });
}

export async function recordRegisterAttempt(key) {
  return recordAttempt(key, { windowMinutes: REGISTER_WINDOW_MINUTES });
}

// Runs on the write paths (the only paths that insert rows), bounding table
// size without adding a round-trip to the hot success path.
export async function purgeStaleLoginAttempts() {
  await sql`
    DELETE FROM muslingo_login_attempts
    WHERE window_started_at < now() - make_interval(hours => ${retentionHours}::int)
  `;
}
