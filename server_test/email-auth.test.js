import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import test from 'node:test';

process.env.DATABASE_URL ??= 'postgres://user:pass@localhost/db';

const {
  createEmailToken,
  emailActionRateKey,
  emailProviderStatus,
  emailTokenTtlMinutes,
  genericEmailActionResponse,
  hashEmailToken,
  sendAccountEmail,
} = await import('../server/lib/email.js');

function withEmailEnv(values, callback) {
  const keys = [
    'RESEND_API_KEY',
    'MUSLINGO_EMAIL_FROM',
    'MUSLINGO_APP_ORIGIN',
    'MUSLINGO_EMAIL_VERIFY_URL',
    'MUSLINGO_PASSWORD_RESET_URL',
    'MUSLINGO_EMAIL_VERIFY_TTL_MINUTES',
    'MUSLINGO_PASSWORD_RESET_TTL_MINUTES',
  ];
  const previous = Object.fromEntries(keys.map((key) => [key, process.env[key]]));
  for (const key of keys) delete process.env[key];
  Object.assign(process.env, values);
  return Promise.resolve(callback()).finally(() => {
    for (const key of keys) {
      if (previous[key] === undefined) delete process.env[key];
      else process.env[key] = previous[key];
    }
  });
}

test('email action tokens carry 256 bits of entropy and only hashes are stable', () => {
  const first = createEmailToken();
  const second = createEmailToken();
  assert.match(first, /^[A-Za-z0-9_-]{43}$/);
  assert.notEqual(first, second);
  assert.match(hashEmailToken(first), /^[a-f0-9]{64}$/);
  assert.equal(hashEmailToken(first), hashEmailToken(first));
  assert.notEqual(hashEmailToken(first), hashEmailToken(second));
});

test('rate-limit keys are namespaced, deterministic, and hide addresses and IPs', () => {
  const value = 'person@example.com|203.0.113.7';
  const key = emailActionRateKey('reset-address', value);
  assert.match(key, /^email-reset-address:[a-f0-9]{64}$/);
  assert.equal(key.includes('person@example.com'), false);
  assert.equal(key.includes('203.0.113.7'), false);
  assert.equal(key, emailActionRateKey('reset-address', value));
  assert.notEqual(key, emailActionRateKey('verify-address', value));
});

test('token lifetimes use safe defaults and clamp unsafe configuration', async () => {
  await withEmailEnv({}, () => {
    assert.equal(emailTokenTtlMinutes('verify_email'), 1440);
    assert.equal(emailTokenTtlMinutes('password_reset'), 30);
  });
  await withEmailEnv({
    MUSLINGO_EMAIL_VERIFY_TTL_MINUTES: '999999',
    MUSLINGO_PASSWORD_RESET_TTL_MINUTES: '999999',
  }, () => {
    assert.equal(emailTokenTtlMinutes('verify_email'), 10080);
    assert.equal(emailTokenTtlMinutes('password_reset'), 120);
  });
  await assert.rejects(async () => emailTokenTtlMinutes('other'), TypeError);
});

test('public response is generic and does not claim an email was sent', async () => {
  await withEmailEnv({}, () => {
    assert.equal(emailProviderStatus(), 'not_configured');
    assert.deepEqual(genericEmailActionResponse(), {
      accepted: true,
      delivery: 'not_configured',
    });
  });
  await withEmailEnv({
    RESEND_API_KEY: 're_test_key',
    MUSLINGO_EMAIL_FROM: 'Muslingo <account@example.com>',
  }, () => {
    assert.equal(emailProviderStatus(), 'provider_configured');
    assert.deepEqual(genericEmailActionResponse(), {
      accepted: true,
      delivery: 'provider_configured',
    });
  });
});

test('unconfigured delivery performs no network call and reports not_configured', async () => {
  await withEmailEnv({}, async () => {
    let called = false;
    const result = await sendAccountEmail({
      to: 'person@example.com',
      purpose: 'password_reset',
      token: createEmailToken(),
      fetchImpl: async () => {
        called = true;
        throw new Error('must not run');
      },
    });
    assert.deepEqual(result, { status: 'not_configured' });
    assert.equal(called, false);
  });
});

test('configured delivery uses the Resend HTTP contract without leaking API key into body', async () => {
  await withEmailEnv({
    RESEND_API_KEY: 're_secret_test',
    MUSLINGO_EMAIL_FROM: 'Muslingo <account@example.com>',
    MUSLINGO_APP_ORIGIN: 'https://app.example.com',
  }, async () => {
    let captured;
    const result = await sendAccountEmail({
      to: 'person@example.com',
      purpose: 'verify_email',
      token: 'a'.repeat(43),
      fetchImpl: async (url, options) => {
        captured = { url, options };
        return { ok: true, status: 200 };
      },
    });
    assert.deepEqual(result, { status: 'sent' });
    assert.equal(captured.url, 'https://api.resend.com/emails');
    assert.equal(captured.options.method, 'POST');
    assert.equal(captured.options.headers.Authorization, 'Bearer re_secret_test');
    const body = JSON.parse(captured.options.body);
    assert.deepEqual(body.to, ['person@example.com']);
    assert.match(body.text, /https:\/\/app\.example\.com\/#\/verify-email\?token=/);
    assert.equal(captured.options.body.includes('re_secret_test'), false);
  });
});

test('provider failure is reported internally as failed rather than sent', async () => {
  await withEmailEnv({
    RESEND_API_KEY: 're_secret_test',
    MUSLINGO_EMAIL_FROM: 'Muslingo <account@example.com>',
  }, async () => {
    assert.deepEqual(
      await sendAccountEmail({
        to: 'person@example.com',
        purpose: 'password_reset',
        token: 'b'.repeat(43),
        fetchImpl: async () => ({ ok: false, status: 422 }),
      }),
      { status: 'failed', providerStatus: 422 },
    );
  });
});

test('schema stores only hashed, expiring, single-use purpose-bound tokens', async () => {
  const source = await readFile(new URL('../server/lib/db.js', import.meta.url), 'utf8');
  assert.match(source, /CREATE TABLE IF NOT EXISTS muslingo_email_tokens/);
  assert.match(source, /token_hash text PRIMARY KEY/);
  assert.match(source, /purpose IN \('verify_email', 'password_reset'\)/);
  assert.match(source, /expires_at timestamptz NOT NULL/);
  assert.match(source, /consumed_at timestamptz/);
  assert.doesNotMatch(source, /\btoken text\b/);
});

test('confirmation and reset atomically claim only live unused tokens', async () => {
  const verify = await readFile(
    new URL('../server/routes/auth-verification-confirm.js', import.meta.url),
    'utf8',
  );
  const reset = await readFile(
    new URL('../server/routes/auth-password-reset.js', import.meta.url),
    'utf8',
  );
  for (const source of [verify, reset]) {
    assert.match(source, /WITH claimed AS/);
    assert.match(source, /SET consumed_at = now\(\)/);
    assert.match(source, /consumed_at IS NULL/);
    assert.match(source, /expires_at > now\(\)/);
    assert.match(source, /invalid_or_expired_token/);
  }
  assert.match(reset, /session_version = u\.session_version \+ 1/);
  assert.match(reset, /u\.email_verified_at IS NOT NULL/);
});

test('request routes use the same generic response and verified reset eligibility', async () => {
  const verification = await readFile(
    new URL('../server/routes/auth-verification-request.js', import.meta.url),
    'utf8',
  );
  const forgot = await readFile(
    new URL('../server/routes/auth-password-forgot.js', import.meta.url),
    'utf8',
  );
  for (const source of [verification, forgot]) {
    assert.match(source, /genericEmailActionResponse\(\)/);
    assert.match(source, /consumeLoginAttempt/);
    assert.doesNotMatch(source, /account.*(exists|not found)/i);
  }
  assert.match(forgot, /email_verified_at IS NOT NULL/);
  assert.match(verification, /email_verified_at IS NULL/);
});

test('API router exposes all verification and recovery endpoints', async () => {
  const source = await readFile(new URL('../api/index.js', import.meta.url), 'utf8');
  assert.match(source, /'auth\/verification\/request'/);
  assert.match(source, /'auth\/verification\/confirm'/);
  assert.match(source, /'auth\/password\/forgot'/);
  assert.match(source, /'auth\/password\/reset'/);
});
