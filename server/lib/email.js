import { createHash, randomBytes } from 'node:crypto';

import { sql } from './db.js';

const RESEND_ENDPOINT = 'https://api.resend.com/emails';
const PURPOSES = new Set(['verify_email', 'password_reset']);

function boundedMinutes(value, fallback, maximum) {
  const parsed = Number(value);
  if (!Number.isFinite(parsed) || parsed <= 0) return fallback;
  return Math.min(maximum, Math.floor(parsed));
}

export function emailTokenTtlMinutes(purpose) {
  if (purpose === 'verify_email') {
    return boundedMinutes(process.env.MUSLINGO_EMAIL_VERIFY_TTL_MINUTES, 24 * 60, 7 * 24 * 60);
  }
  if (purpose === 'password_reset') {
    return boundedMinutes(process.env.MUSLINGO_PASSWORD_RESET_TTL_MINUTES, 30, 120);
  }
  throw new TypeError('Unsupported email token purpose.');
}

export function createEmailToken() {
  return randomBytes(32).toString('base64url');
}

export function hashEmailToken(token) {
  return createHash('sha256').update(String(token ?? '')).digest('hex');
}

export function emailActionRateKey(action, value) {
  return `email-${String(action)}:${hashEmailToken(value)}`;
}

export function emailProviderStatus() {
  return process.env.RESEND_API_KEY && process.env.MUSLINGO_EMAIL_FROM
    ? 'provider_configured'
    : 'not_configured';
}

export function genericEmailActionResponse() {
  return {
    accepted: true,
    delivery: emailProviderStatus(),
  };
}

function actionUrl(purpose, token) {
  if (!PURPOSES.has(purpose)) throw new TypeError('Unsupported email token purpose.');
  const explicit = purpose === 'verify_email'
    ? process.env.MUSLINGO_EMAIL_VERIFY_URL
    : process.env.MUSLINGO_PASSWORD_RESET_URL;
  const fallbackPath = purpose === 'verify_email' ? '/#/verify-email' : '/#/reset-password';
  const base = explicit || `${process.env.MUSLINGO_APP_ORIGIN || 'https://muslingo-mobile.vercel.app'}${fallbackPath}`;
  const url = new URL(base);
  // Flutter Web uses hash routing. Query parameters for a hash route must live
  // inside the fragment (`#/verify-email?token=...`), not before `#`, or the
  // in-app router cannot read them. Conventional non-hash URLs still use the
  // normal search parameters.
  if (url.hash) {
    const separator = url.hash.includes('?') ? '&' : '?';
    url.hash = `${url.hash}${separator}token=${encodeURIComponent(token)}`;
  } else {
    url.searchParams.set('token', token);
  }
  return url.toString();
}

function escapeHtml(value) {
  return String(value)
    .replaceAll('&', '&amp;')
    .replaceAll('<', '&lt;')
    .replaceAll('>', '&gt;')
    .replaceAll('"', '&quot;')
    .replaceAll("'", '&#39;');
}

function messageFor(purpose, token) {
  const verify = purpose === 'verify_email';
  const url = actionUrl(purpose, token);
  const safeUrl = escapeHtml(url);
  const ttl = emailTokenTtlMinutes(purpose);
  const title = verify ? 'Подтвердите почту Muslingo' : 'Восстановление пароля Muslingo';
  const instruction = verify
    ? 'Подтвердите адрес электронной почты, чтобы защитить аккаунт.'
    : 'Откройте ссылку, чтобы задать новый пароль.';
  return {
    subject: title,
    text: `${instruction}\n\n${url}\n\nСсылка действует ${ttl} минут. Если вы не запрашивали это действие, проигнорируйте письмо.`,
    html: `<h1>${title}</h1><p>${instruction}</p><p><a href="${safeUrl}">Продолжить в Muslingo</a></p><p>Ссылка действует ${ttl} минут. Если вы не запрашивали это действие, проигнорируйте письмо.</p>`,
  };
}

export async function issueAndSendAccountEmail({ userId, email, purpose }) {
  if (emailProviderStatus() !== 'provider_configured') return { status: 'not_configured' };
  const token = createEmailToken();
  const tokenHash = hashEmailToken(token);
  const ttlMinutes = emailTokenTtlMinutes(purpose);
  await sql.transaction([
    sql`
      UPDATE muslingo_email_tokens
      SET consumed_at = now()
      WHERE user_id = ${userId}::uuid
        AND purpose = ${purpose}
        AND consumed_at IS NULL
    `,
    sql`
      INSERT INTO muslingo_email_tokens (token_hash, user_id, purpose, expires_at)
      VALUES (
        ${tokenHash},
        ${userId}::uuid,
        ${purpose},
        now() + make_interval(mins => ${ttlMinutes}::int)
      )
    `,
  ]);
  const result = await sendAccountEmail({ to: email, purpose, token });
  if (result.status === 'failed') {
    await sql`
      DELETE FROM muslingo_email_tokens
      WHERE token_hash = ${tokenHash} AND consumed_at IS NULL
    `;
  }
  return result;
}

export async function sendAccountEmail({ to, purpose, token, fetchImpl = globalThis.fetch }) {
  if (!PURPOSES.has(purpose)) throw new TypeError('Unsupported email token purpose.');
  if (emailProviderStatus() !== 'provider_configured') return { status: 'not_configured' };
  const message = messageFor(purpose, token);
  try {
    const response = await fetchImpl(RESEND_ENDPOINT, {
      method: 'POST',
      headers: {
        Authorization: `Bearer ${process.env.RESEND_API_KEY}`,
        'Content-Type': 'application/json',
      },
      body: JSON.stringify({
        from: process.env.MUSLINGO_EMAIL_FROM,
        to: [to],
        subject: message.subject,
        html: message.html,
        text: message.text,
      }),
      signal: AbortSignal.timeout(8_000),
    });
    if (!response.ok) return { status: 'failed', providerStatus: response.status };
    return { status: 'sent' };
  } catch {
    return { status: 'failed' };
  }
}
