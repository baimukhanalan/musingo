import assert from 'node:assert/strict';
import test from 'node:test';

import { SignJWT } from 'jose';

// db.js throws at import without DATABASE_URL, and auth.js pulls it in. The
// value is fake: neon() does not connect until a query runs, and none of the
// functions under test touch the DB. JWT_SECRET must be >= 32 chars.
process.env.DATABASE_URL ??= 'postgres://user:pass@localhost/db';
process.env.JWT_SECRET ??= 'unit-test-secret-unit-test-secret-0123456789';

const {
  issueToken,
  issueLessonAttempt,
  verifyLessonAttempt,
  verifyToken,
  isUuid,
  hashPassword,
  passwordMatches,
  verifyLoginPassword,
} = await import('../server/lib/auth.js');
const { trustedClientIp, readJson, ApiError } = await import('../server/lib/http.js');

const SECRET = new TextEncoder().encode(process.env.JWT_SECRET);
const ISS = 'muslingo';
const AUD = 'muslingo-app';
const UUID = '3f2504e0-4f89-11d3-9a0c-0305e82c3301';

async function caught(promise) {
  try {
    await promise;
  } catch (error) {
    return error;
  }
  assert.fail('expected the promise to reject');
}

function caughtSync(fn) {
  try {
    fn();
  } catch (error) {
    return error;
  }
  assert.fail('expected the call to throw');
}

// Signs a token with arbitrary claims/secret for the negative cases.
function sign({ sub = UUID, secret = SECRET, iss = ISS, aud = AUD, exp = '1h', nbf } = {}) {
  let builder = new SignJWT({})
    .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
    .setSubject(sub)
    .setIssuedAt();
  if (iss !== null) builder = builder.setIssuer(iss);
  if (aud !== null) builder = builder.setAudience(aud);
  if (nbf !== undefined) builder = builder.setNotBefore(nbf);
  builder = builder.setExpirationTime(exp);
  return builder.sign(secret);
}

// --- token issue / verify (jose) ----------------------------------------

test('issued token verifies and round-trips the UUID subject', async () => {
  const token = await issueToken(UUID);
  const payload = await verifyToken(token);
  assert.equal(payload.sub, UUID);
  assert.equal(payload.iss, ISS);
  assert.equal(payload.aud, AUD);
  assert.equal(typeof payload.jti, 'string');
  assert.ok(payload.exp > Math.floor(Date.now() / 1000));
  assert.ok(payload.nbf <= Math.floor(Date.now() / 1000));
});

test('a tampered token is rejected as invalid_session', async () => {
  const token = await issueToken(UUID);
  const error = await caught(verifyToken(`${token}tamper`));
  assert.ok(error instanceof ApiError);
  assert.equal(error.status, 401);
  assert.equal(error.code, 'invalid_session');
});

test('a token signed with a different secret is rejected (no forgery)', async () => {
  const forged = await sign({ secret: new TextEncoder().encode('another-secret-another-secret-abcdefgh') });
  const error = await caught(verifyToken(forged));
  assert.equal(error.code, 'invalid_session');
});

test('an expired token is rejected as expired_session', async () => {
  const expired = await sign({ exp: Math.floor(Date.now() / 1000) - 30 });
  const error = await caught(verifyToken(expired));
  assert.equal(error.status, 401);
  assert.equal(error.code, 'expired_session');
});

test('a token from a foreign issuer is rejected', async () => {
  const foreign = await sign({ iss: 'evil-issuer' });
  assert.equal((await caught(verifyToken(foreign))).code, 'invalid_session');
});

test('a token for a foreign audience is rejected', async () => {
  const foreign = await sign({ aud: 'someone-else' });
  assert.equal((await caught(verifyToken(foreign))).code, 'invalid_session');
});

test('a not-yet-valid (future nbf) token is rejected', async () => {
  const future = await sign({ nbf: Math.floor(Date.now() / 1000) + 3600 });
  assert.equal((await caught(verifyToken(future))).code, 'invalid_session');
});

test('garbage and empty tokens are rejected, not crashed on', async () => {
  assert.equal((await caught(verifyToken('a.b.c'))).code, 'invalid_session');
  assert.equal((await caught(verifyToken(''))).code, 'invalid_session');
  assert.equal((await caught(verifyToken(null))).code, 'invalid_session');
});

test('lesson attempt is bound to the user and lesson', async () => {
  const token = await issueLessonAttempt(UUID, 'q_fatiha_1');
  const payload = await verifyLessonAttempt(token, {
    userId: UUID,
    lessonId: 'q_fatiha_1',
    minAgeSeconds: 0,
  });
  assert.equal(payload.sub, UUID);
  assert.equal(payload.lessonId, 'q_fatiha_1');
  assert.equal(typeof payload.jti, 'string');

  const error = await caught(verifyLessonAttempt(token, {
    userId: UUID,
    lessonId: 'q_ikhlas_1',
    minAgeSeconds: 0,
  }));
  assert.equal(error.code, 'invalid_lesson_attempt');
});

// --- UUID validation (pre-DB guard) -------------------------------------

test('isUuid accepts canonical UUIDs (any case)', () => {
  assert.equal(isUuid(UUID), true);
  assert.equal(isUuid('550E8400-E29B-41D4-A716-446655440000'), true);
});

test('isUuid rejects non-UUID subjects that would break the ::uuid cast', () => {
  assert.equal(isUuid('not-a-uuid'), false);
  assert.equal(isUuid("1'; DROP TABLE muslingo_users; --"), false);
  assert.equal(isUuid('3f2504e0-4f89-11d3-9a0c-0305e82c330'), false); // too short
  assert.equal(isUuid(''), false);
  assert.equal(isUuid(null), false);
  assert.equal(isUuid(123), false);
});

// --- password verification (timing-safe, existence-agnostic) ------------

test('passwordMatches is true only for the right password', async () => {
  const { salt, hash } = await hashPassword('correct horse battery staple');
  assert.equal(await passwordMatches('correct horse battery staple', salt, hash), true);
  assert.equal(await passwordMatches('wrong password', salt, hash), false);
});

test('passwordMatches returns false (not throw) on a length mismatch', async () => {
  assert.equal(await passwordMatches('whatever', '', ''), false);
});

test('verifyLoginPassword ignores unknown accounts but still returns a boolean', async () => {
  const { salt, hash } = await hashPassword('s3cret-pass');
  const user = { password_salt: salt, password_hash: hash };
  assert.equal(await verifyLoginPassword(user, 's3cret-pass'), true);
  assert.equal(await verifyLoginPassword(user, 'nope'), false);
  // Unknown email / missing hash -> false, but scrypt still ran (no throw).
  assert.equal(await verifyLoginPassword(null, 'anything'), false);
  assert.equal(await verifyLoginPassword({}, 'anything'), false);
});

// --- trusted client IP (X-Forwarded-For spoofing) -----------------------

test('trustedClientIp takes the rightmost hop Vercel appends', () => {
  assert.equal(trustedClientIp({ 'x-forwarded-for': 'spoofed-client, 203.0.113.7' }), '203.0.113.7');
});

test('trustedClientIp is idempotent to a spoofed leftmost value', () => {
  const a = trustedClientIp({ 'x-forwarded-for': '1.1.1.1, 203.0.113.7' });
  const b = trustedClientIp({ 'x-forwarded-for': '9.9.9.9, 203.0.113.7' });
  const c = trustedClientIp({ 'x-forwarded-for': 'evil, more-evil, 203.0.113.7' });
  assert.equal(a, '203.0.113.7');
  assert.equal(b, '203.0.113.7');
  assert.equal(c, '203.0.113.7');
});

test('trustedClientIp handles array headers and the x-real-ip fallback', () => {
  assert.equal(trustedClientIp({ 'x-forwarded-for': ['1.1.1.1', '203.0.113.7'] }), '203.0.113.7');
  assert.equal(trustedClientIp({ 'x-real-ip': '198.51.100.5' }), '198.51.100.5');
  assert.equal(trustedClientIp({ 'x-forwarded-for': 'a, 203.0.113.7', 'x-real-ip': '1.1.1.1' }), '203.0.113.7');
  assert.equal(trustedClientIp({}), '');
});

// --- body size guard (parsed-object path) -------------------------------

test('readJson rejects an oversized already-parsed object with 413', () => {
  const huge = { blob: 'x'.repeat(1_000_001) };
  const error = caughtSync(() => readJson({ body: huge }));
  assert.equal(error.status, 413);
  assert.equal(error.code, 'payload_too_large');
});

test('readJson passes through a normal parsed object', () => {
  const body = { email: 'a@b.co', password: 'x' };
  assert.equal(readJson({ body }), body);
});

test('readJson rejects an oversized string body before parsing', () => {
  assert.equal(caughtSync(() => readJson({ body: 'x'.repeat(1_000_001) })).status, 413);
});

test('readJson maps invalid JSON strings to 400 and null bodies to {}', () => {
  assert.equal(caughtSync(() => readJson({ body: '{not json' })).code, 'invalid_json');
  assert.deepEqual(readJson({ body: null }), {});
});
