// Shared by the single Vercel API router.
import { randomBytes, randomUUID, scrypt as scryptCallback, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';

import { SignJWT, jwtVerify } from 'jose';

import { sql, ensureSchema } from './db.js';
import { ApiError } from './http.js';

const scrypt = promisify(scryptCallback);

// Signed sessions via jose. iss/aud are namespaced (overridable via env) and
// the token carries iat/nbf/exp/jti. HS256 is pinned on verify to block
// algorithm-confusion (e.g. a forged alg=none or RS256 token).
const issuer = process.env.MUSLINGO_JWT_ISS ?? 'muslingo';
const audience = process.env.MUSLINGO_JWT_AUD ?? 'muslingo-app';
const tokenTtl = process.env.MUSLINGO_JWT_TTL ?? '30d';
const lessonAudience = `${audience}:lesson-attempt`;

const UUID_RE = /^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$/i;

// Throwaway credential so login can run scrypt with the same cost even when the
// email is unknown, keeping response time (and the response body) identical for
// "no such user" and "wrong password" — closes the enumeration side channel.
const dummySalt = randomBytes(16).toString('base64url');

export function isUuid(value) {
  return typeof value === 'string' && UUID_RE.test(value);
}

function secretKey() {
  const value = process.env.JWT_SECRET;
  if (!value || value.length < 32) throw new Error('JWT_SECRET must be at least 32 characters.');
  return new TextEncoder().encode(value);
}

export async function issueToken(userId) {
  return new SignJWT({})
    .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
    .setSubject(String(userId))
    .setIssuedAt()
    .setNotBefore('0s')
    .setIssuer(issuer)
    .setAudience(audience)
    .setJti(randomUUID())
    .setExpirationTime(tokenTtl)
    .sign(secretKey());
}

export async function verifyToken(token) {
  try {
    const { payload } = await jwtVerify(String(token ?? ''), secretKey(), {
      issuer,
      audience,
      algorithms: ['HS256'],
    });
    if (!payload.sub) throw new ApiError(401, 'invalid_session', 'Session is invalid.');
    return payload;
  } catch (error) {
    if (error instanceof ApiError) throw error;
    if (error?.code === 'ERR_JWT_EXPIRED') {
      throw new ApiError(401, 'expired_session', 'Session has expired.');
    }
    throw new ApiError(401, 'invalid_session', 'Session is invalid.');
  }
}

export async function issueLessonAttempt(userId, lessonId) {
  return new SignJWT({ lessonId: String(lessonId) })
    .setProtectedHeader({ alg: 'HS256', typ: 'JWT' })
    .setSubject(String(userId))
    .setIssuedAt()
    .setNotBefore('0s')
    .setIssuer(issuer)
    .setAudience(lessonAudience)
    .setJti(randomUUID())
    .setExpirationTime('2h')
    .sign(secretKey());
}

export async function verifyLessonAttempt(token, { userId, lessonId, minAgeSeconds = 1 }) {
  try {
    const { payload } = await jwtVerify(String(token ?? ''), secretKey(), {
      issuer,
      audience: lessonAudience,
      algorithms: ['HS256'],
    });
    const issuedAt = Number(payload.iat ?? 0);
    const age = Math.floor(Date.now() / 1000) - issuedAt;
    if (
      payload.sub !== String(userId) ||
      payload.lessonId !== String(lessonId) ||
      !payload.jti ||
      !Number.isFinite(age) ||
      age < minAgeSeconds
    ) {
      throw new ApiError(400, 'invalid_lesson_attempt', 'Lesson attempt is invalid.');
    }
    return payload;
  } catch (error) {
    if (error instanceof ApiError) throw error;
    if (error?.code === 'ERR_JWT_EXPIRED') {
      throw new ApiError(400, 'expired_lesson_attempt', 'Lesson attempt has expired.');
    }
    throw new ApiError(400, 'invalid_lesson_attempt', 'Lesson attempt is invalid.');
  }
}

export async function hashPassword(password) {
  const salt = randomBytes(16).toString('base64url');
  const hash = await scrypt(password, salt, 64);
  return { salt, hash: Buffer.from(hash).toString('base64url') };
}

export async function passwordMatches(password, salt, expectedHash) {
  const candidate = Buffer.from(await scrypt(password, salt, 64));
  const expected = Buffer.from(expectedHash, 'base64url');
  return candidate.length === expected.length && timingSafeEqual(candidate, expected);
}

// Verifies a login password whether or not the account exists. For an unknown
// email (or a row missing its hash) we still run scrypt against a throwaway
// salt and return false, so timing does not reveal account existence.
export async function verifyLoginPassword(user, password) {
  if (user && user.password_salt && user.password_hash) {
    return passwordMatches(password, user.password_salt, user.password_hash);
  }
  await scrypt(password, dummySalt, 64);
  return false;
}

export function bearerToken(request) {
  const header = String(request.headers.authorization ?? '');
  if (!header.startsWith('Bearer ')) throw new ApiError(401, 'authentication_required', 'Authentication required.');
  return header.slice(7).trim();
}

export async function requireSession(request) {
  await ensureSchema();
  const payload = await verifyToken(bearerToken(request));
  // Validate the UUID shape before touching Postgres. A validly-signed token
  // whose sub was not a UUID previously reached `${sub}::uuid` and surfaced as
  // a 500 (invalid_text_representation) instead of a clean 401.
  if (!isUuid(payload.sub)) {
    throw new ApiError(401, 'invalid_session', 'Session is invalid.');
  }
  if (!payload.jti) {
    throw new ApiError(401, 'invalid_session', 'Session is invalid.');
  }
  const rows = await sql`
    SELECT id, email, display_name
    FROM muslingo_users
    WHERE id = ${payload.sub}::uuid
      AND NOT EXISTS (
        SELECT 1 FROM muslingo_revoked_sessions
        WHERE jti = ${payload.jti} AND expires_at > now()
      )
    LIMIT 1
  `;
  if (rows.length === 0) throw new ApiError(401, 'invalid_session', 'Session is invalid.');
  return { user: rows[0], payload };
}

export async function requireUser(request) {
  return (await requireSession(request)).user;
}

export async function optionalUser(request) {
  const header = String(request.headers.authorization ?? '');
  if (!header.startsWith('Bearer ')) return null;
  try {
    return await requireUser(request);
  } catch {
    return null;
  }
}
