// Shared by the single Vercel API router.
export class ApiError extends Error {
  constructor(status, code, message) {
    super(message);
    this.status = status;
    this.code = code;
  }
}

const maxBodyBytes = 1_000_000;

export function readJson(request) {
  const body = request.body;
  if (body == null) return {};
  if (typeof body === 'string') {
    if (Buffer.byteLength(body, 'utf8') > maxBodyBytes) {
      throw new ApiError(413, 'payload_too_large', 'Request is too large.');
    }
    try {
      return JSON.parse(body);
    } catch {
      throw new ApiError(400, 'invalid_json', 'Invalid JSON body.');
    }
  }
  if (Buffer.isBuffer(body)) {
    if (body.length > maxBodyBytes) {
      throw new ApiError(413, 'payload_too_large', 'Request is too large.');
    }
    try {
      return JSON.parse(body.toString('utf8'));
    } catch {
      throw new ApiError(400, 'invalid_json', 'Invalid JSON body.');
    }
  }
  if (typeof body === 'object') {
    // On Vercel the platform parses the JSON body before the function runs, so
    // request.body arrives as an object and neither branch above executes — the
    // original size guard was dead code and unbounded payloads slipped through.
    // Re-estimate the serialized size here so oversized bodies still get a 413.
    let serialized;
    try {
      serialized = JSON.stringify(body);
    } catch {
      throw new ApiError(400, 'invalid_json', 'Invalid JSON body.');
    }
    if (Buffer.byteLength(serialized ?? '', 'utf8') > maxBodyBytes) {
      throw new ApiError(413, 'payload_too_large', 'Request is too large.');
    }
    return body;
  }
  throw new ApiError(400, 'invalid_json', 'Invalid JSON body.');
}

function setHeaders(request, response) {
  const allowedOrigin = process.env.MUSLINGO_APP_ORIGIN;
  const origin = request.headers.origin;
  if (origin && allowedOrigin && origin === allowedOrigin) {
    response.setHeader('Access-Control-Allow-Origin', origin);
    response.setHeader('Vary', 'Origin');
  }
  response.setHeader('Access-Control-Allow-Headers', 'Authorization, Content-Type');
  response.setHeader('Access-Control-Allow-Methods', 'GET, POST, DELETE, OPTIONS');
  response.setHeader('Cache-Control', 'no-store');
  response.setHeader('Content-Type', 'application/json; charset=utf-8');
  response.setHeader('X-Content-Type-Options', 'nosniff');
}

export function method(request, allowed) {
  if (!allowed.includes(request.method)) {
    throw new ApiError(405, 'method_not_allowed', 'Method not allowed.');
  }
}

export function text(value, { min = 0, max = 200, field = 'value' } = {}) {
  const normalized = String(value ?? '').trim();
  if (normalized.length < min || normalized.length > max) {
    throw new ApiError(400, `invalid_${field}`, `Invalid ${field}.`);
  }
  return normalized;
}

export function integer(value, { min = 0, max = Number.MAX_SAFE_INTEGER } = {}) {
  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < min || parsed > max) {
    throw new ApiError(400, 'invalid_number', 'Invalid numeric value.');
  }
  return parsed;
}

// Pure and header-only so it can be unit-tested against spoofed values.
export function trustedClientIp(headers = {}) {
  // Vercel overwrites X-Forwarded-For with the chain it observes and places the
  // real peer as the RIGHTMOST entry, so a client-supplied leftmost value must
  // not be trusted (that is what let an attacker mint unlimited rate-limit
  // buckets). Take the rightmost hop; fall back to x-real-ip only when XFF is
  // absent. Docs: https://vercel.com/docs/headers/request-headers
  const rawForwarded = headers['x-forwarded-for'];
  const forwarded = Array.isArray(rawForwarded) ? rawForwarded.join(',') : rawForwarded ?? '';
  const chain = String(forwarded)
    .split(',')
    .map((part) => part.trim())
    .filter(Boolean);
  if (chain.length > 0) return chain[chain.length - 1].slice(0, 64);
  const rawReal = headers['x-real-ip'];
  const real = Array.isArray(rawReal) ? rawReal[0] : rawReal ?? '';
  return String(real).trim().slice(0, 64);
}

export function clientIp(request) {
  return trustedClientIp(request.headers ?? {});
}

export function withApi(handler) {
  return async (request, response) => {
    setHeaders(request, response);
    if (request.method === 'OPTIONS') return response.status(204).end();
    const allowedOrigin = process.env.MUSLINGO_APP_ORIGIN;
    const origin = request.headers.origin;
    if (origin && allowedOrigin && origin !== allowedOrigin) {
      return response.status(403).json({ error: 'origin_not_allowed', message: 'Origin not allowed.' });
    }
    try {
      return await handler(request, response);
    } catch (error) {
      if (error instanceof ApiError) {
        return response.status(error.status).json({ error: error.code, message: error.message });
      }
      if (error?.code === '23505') {
        return response.status(409).json({ error: 'already_exists', message: 'Account already exists.' });
      }
      console.error('Muslingo API error', error);
      return response.status(500).json({ error: 'internal_error', message: 'Internal server error.' });
    }
  };
}
