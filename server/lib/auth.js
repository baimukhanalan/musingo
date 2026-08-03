// Shared by the single Vercel API router.
import { createHmac, randomBytes, scrypt as scryptCallback, timingSafeEqual } from 'node:crypto';
import { promisify } from 'node:util';

import { sql, ensureSchema } from './db.js';
import { ApiError } from './http.js';

const scrypt = promisify(scryptCallback);
const tokenLifetimeSeconds = 60 * 60 * 24 * 30;

function secret() {
  const value = process.env.JWT_SECRET;
  if (!value || value.length < 32) throw new Error('JWT_SECRET must be at least 32 characters.');
  return value;
}

function encode(value) {
  return Buffer.from(JSON.stringify(value)).toString('base64url');
}

export function issueToken(userId) {
  const now = Math.floor(Date.now() / 1000);
  const header = encode({ alg: 'HS256', typ: 'JWT' });
  const payload = encode({ sub: userId, iat: now, exp: now + tokenLifetimeSeconds });
  const unsigned = `${header}.${payload}`;
  const signature = createHmac('sha256', secret()).update(unsigned).digest('base64url');
  return `${unsigned}.${signature}`;
}

export function verifyToken(token) {
  const parts = String(token ?? '').split('.');
  if (parts.length !== 3) throw new ApiError(401, 'invalid_session', 'Session is invalid.');
  const unsigned = `${parts[0]}.${parts[1]}`;
  const actual = Buffer.from(parts[2], 'base64url');
  const expected = createHmac('sha256', secret()).update(unsigned).digest();
  if (actual.length !== expected.length || !timingSafeEqual(actual, expected)) {
    throw new ApiError(401, 'invalid_session', 'Session is invalid.');
  }
  let payload;
  try {
    payload = JSON.parse(Buffer.from(parts[1], 'base64url').toString('utf8'));
  } catch {
    throw new ApiError(401, 'invalid_session', 'Session is invalid.');
  }
  if (!payload.sub || !payload.exp || payload.exp <= Math.floor(Date.now() / 1000)) {
    throw new ApiError(401, 'expired_session', 'Session has expired.');
  }
  return payload;
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

export function bearerToken(request) {
  const header = String(request.headers.authorization ?? '');
  if (!header.startsWith('Bearer ')) throw new ApiError(401, 'authentication_required', 'Authentication required.');
  return header.slice(7).trim();
}

export async function requireUser(request) {
  await ensureSchema();
  const payload = verifyToken(bearerToken(request));
  const rows = await sql`
    SELECT id, email, display_name
    FROM muslingo_users
    WHERE id = ${payload.sub}::uuid
    LIMIT 1
  `;
  if (rows.length === 0) throw new ApiError(401, 'invalid_session', 'Session is invalid.');
  return rows[0];
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
