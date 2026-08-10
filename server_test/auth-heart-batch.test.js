import assert from 'node:assert/strict';
import test from 'node:test';

// The modules under test pull in db.js (throws at import without DATABASE_URL)
// and auth.js (needs a >=32-char JWT_SECRET). The values are fake: neon() does
// not connect until a query runs, and every function exercised here is pure —
// nothing touches the database.
process.env.DATABASE_URL ??= 'postgres://user:pass@localhost/db';
process.env.JWT_SECRET ??= 'unit-test-secret-unit-test-secret-0123456789';

const {
  isRateLimited,
  registerKey,
  REGISTER_MAX_ATTEMPTS,
  REGISTER_WINDOW_MINUTES,
} = await import('../server/lib/login-rate-limit.js');
const { requireProgressRows } = await import('../server/routes/progress-restore-heart.js');
const { ApiError } = await import('../server/lib/http.js');

const NOW = Date.parse('2026-08-09T12:00:00Z');
const MINUTE = 60_000;

function caughtSync(fn) {
  try {
    fn();
  } catch (error) {
    return error;
  }
  assert.fail('expected the call to throw');
}

// Bucket state as the register limiter would use it (limit 20 / 60-min window).
function reg({ attempts, ageMinutes }) {
  return {
    attempts,
    windowStartedAt: new Date(NOW - ageMinutes * MINUTE).toISOString(),
    limit: REGISTER_MAX_ATTEMPTS,
    windowMinutes: REGISTER_WINDOW_MINUTES,
    now: NOW,
  };
}

// --- register rate-limit: pinned configuration ---------------------------

test('register limiter is 20 attempts per 60-minute window', () => {
  assert.equal(REGISTER_MAX_ATTEMPTS, 20);
  assert.equal(REGISTER_WINDOW_MINUTES, 60);
});

// --- register rate-limit: window / counter / reset -----------------------

test('a missing bucket never blocks (first registration from an IP)', () => {
  assert.equal(
    isRateLimited({
      attempts: null,
      windowStartedAt: null,
      limit: REGISTER_MAX_ATTEMPTS,
      windowMinutes: REGISTER_WINDOW_MINUTES,
      now: NOW,
    }),
    false,
  );
});

test('counter: under the cap within the window is allowed', () => {
  assert.equal(isRateLimited(reg({ attempts: 19, ageMinutes: 10 })), false);
});

test('counter: at the cap within the window is blocked (21st attempt)', () => {
  assert.equal(isRateLimited(reg({ attempts: 20, ageMinutes: 10 })), true);
  assert.equal(isRateLimited(reg({ attempts: 25, ageMinutes: 59 })), true);
});

test('reset: once the 60-minute window has elapsed the cap no longer blocks', () => {
  // 61 minutes old — even a counter well past the cap is stale, so a fresh
  // attempt is allowed (the recordAttempt CASE resets it to 1).
  assert.equal(isRateLimited(reg({ attempts: 100, ageMinutes: 61 })), false);
});

test('window boundary: age exactly equal to the window still blocks (age <= window)', () => {
  assert.equal(isRateLimited(reg({ attempts: 20, ageMinutes: 60 })), true);
  // One millisecond past the boundary flips it open.
  assert.equal(
    isRateLimited({
      attempts: 20,
      windowStartedAt: new Date(NOW - (REGISTER_WINDOW_MINUTES * MINUTE + 1)).toISOString(),
      limit: REGISTER_MAX_ATTEMPTS,
      windowMinutes: REGISTER_WINDOW_MINUTES,
      now: NOW,
    }),
    false,
  );
});

test('the shared predicate still honours the tighter login config (15 min / 8)', () => {
  const loginBucket = (attempts, ageMinutes) => ({
    attempts,
    windowStartedAt: new Date(NOW - ageMinutes * MINUTE).toISOString(),
    limit: 8,
    windowMinutes: 15,
    now: NOW,
  });
  assert.equal(isRateLimited(loginBucket(7, 5)), false);
  assert.equal(isRateLimited(loginBucket(8, 5)), true);
  assert.equal(isRateLimited(loginBucket(8, 16)), false); // window expired
});

// --- register key: namespace, determinism, isolation ---------------------

test('registerKey is deterministic and namespaced with the "register:" prefix', () => {
  const key = registerKey('203.0.113.7');
  assert.ok(key.startsWith('register:'));
  assert.equal(registerKey('203.0.113.7'), key); // same IP -> same bucket
});

test('registerKey separates distinct IPs into distinct buckets', () => {
  assert.notEqual(registerKey('203.0.113.7'), registerKey('203.0.113.8'));
});

test('registerKey does not persist the raw IP and cannot collide with login keys', () => {
  const ip = '203.0.113.7';
  const key = registerKey(ip);
  assert.ok(!key.includes(ip)); // IP is hashed, not stored in the clear
  // Login keys are bare sha256 hex (no prefix), so the "register:" namespace is
  // structurally disjoint from them.
  assert.ok(!/^[0-9a-f]{64}$/.test(key));
});

test('registerKey tolerates a missing IP without throwing', () => {
  assert.ok(registerKey('').startsWith('register:'));
  assert.ok(registerKey(null).startsWith('register:'));
  assert.ok(registerKey(undefined).startsWith('register:'));
});

// --- restore-heart: 404 vs 400 distinction (L6) --------------------------

test('restore-heart maps an empty progress result to 404 progress_not_found', () => {
  const error = caughtSync(() => requireProgressRows([]));
  assert.ok(error instanceof ApiError);
  assert.equal(error.status, 404);
  assert.equal(error.code, 'progress_not_found');
});

test('restore-heart lets a real progress row through (no false 404)', () => {
  // A present row must NOT throw here — it flows on to the hearts_full / energy
  // checks. Before the guard this same "no row" case produced a misleading 400
  // hearts_full via profile()'s hearts:5 default.
  assert.doesNotThrow(() => requireProgressRows([{ document: { hearts: 2 }, version: 3 }]));
});
