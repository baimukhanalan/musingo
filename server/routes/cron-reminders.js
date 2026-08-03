import webPush from 'web-push';
import { createRemoteJWKSet, jwtVerify } from 'jose';

import { sql, ensureSchema } from '../lib/db.js';
import { method, withApi } from '../lib/http.js';

const messages = [
  ['Твой аят ждет продолжения', 'Шесть спокойных минут сегодня сохранят то, что ты уже выучил.'],
  ['Вернемся к Корану?', 'Не начинай заново. Продолжи ровно с того места, где остановился.'],
  ['Маленький шаг, крепкая память', 'Один короткий урок сейчас поможет не потерять знакомые аяты.'],
  ['Сегодня без гонки', 'Прослушай, пойми и повтори один фрагмент в своем темпе.'],
  ['Muslingo подготовил повторение', 'Слабые места уже собраны. Тебе остается открыть ежедневный урок.'],
  ['Твоя серия еще здесь', 'Зайди на несколько минут и сохрани ритм обучения.'],
  ['Сначала знакомое, потом новое', 'Повтори один аят, и следующий шаг станет заметно легче.'],
];

const githubKeys = createRemoteJWKSet(
  new URL('https://token.actions.githubusercontent.com/.well-known/jwks'),
);

async function authorized(request) {
  const authorization = String(request.headers.authorization ?? '');
  const expected = process.env.CRON_SECRET;
  if (expected && authorization === `Bearer ${expected}`) return true;
  if (!authorization.startsWith('Bearer ')) return false;
  try {
    const { payload } = await jwtVerify(authorization.slice(7), githubKeys, {
      issuer: 'https://token.actions.githubusercontent.com',
      audience: 'muslingo-cron',
    });
    return payload.repository === 'baimukhanalan/musingo'
      && payload.ref === 'refs/heads/main'
      && (payload.event_name === 'schedule'
        || payload.event_name === 'workflow_dispatch');
  } catch {
    return false;
  }
}

function localParts(date, timezone) {
  const parts = new Intl.DateTimeFormat('en-CA', {
    timeZone: timezone,
    year: 'numeric', month: '2-digit', day: '2-digit',
    hour: '2-digit', minute: '2-digit', hourCycle: 'h23',
  }).formatToParts(date);
  const values = Object.fromEntries(parts.map((part) => [part.type, part.value]));
  return {
    date: `${values.year}-${values.month}-${values.day}`,
    hour: Number(values.hour),
    minute: Number(values.minute),
  };
}

function messageFor(row, localDate) {
  const seed = [...`${row.installation_id}:${localDate}`].reduce((sum, char) => sum + char.charCodeAt(0), 0);
  const [title, genericBody] = messages[seed % messages.length];
  const body = Number(row.due_count) > 0
    ? `На сегодня готово повторений: ${Number(row.due_count)}. Начни с самого слабого места.`
    : genericBody;
  return { title, body, url: '/#/home', tag: 'muslingo-daily-learning' };
}

export default withApi(async (request, response) => {
  method(request, ['GET']);
  if (!(await authorized(request))) {
    return response.status(401).json({ error: 'unauthorized', message: 'Unauthorized.' });
  }
  await ensureSchema();
  if (!process.env.VAPID_PUBLIC_KEY || !process.env.VAPID_PRIVATE_KEY || !process.env.VAPID_SUBJECT) {
    return response.status(503).json({ error: 'push_unavailable', message: 'Push is not configured.' });
  }
  webPush.setVapidDetails(process.env.VAPID_SUBJECT, process.env.VAPID_PUBLIC_KEY, process.env.VAPID_PRIVATE_KEY);
  const rows = await sql`
    SELECT endpoint_hash, endpoint, p256dh, auth_secret, installation_id,
           timezone, reminder_hour, reminder_minute, due_count, last_sent_date
    FROM muslingo_push_subscriptions
    WHERE enabled = true
      AND updated_at > now() - interval '120 days'
    ORDER BY updated_at DESC
    LIMIT 2000
  `;
  const now = new Date();
  let sent = 0;
  let removed = 0;
  let failed = 0;
  for (const row of rows) {
    let local;
    try {
      local = localParts(now, row.timezone);
    } catch {
      local = localParts(now, 'UTC');
    }
    const inReminderBucket = local.hour === Number(row.reminder_hour)
      && Math.floor(local.minute / 15) === Math.floor(Number(row.reminder_minute) / 15);
    const alreadySent = row.last_sent_date && String(row.last_sent_date).slice(0, 10) === local.date;
    if (!inReminderBucket || alreadySent) continue;
    try {
      await webPush.sendNotification(
        { endpoint: row.endpoint, keys: { p256dh: row.p256dh, auth: row.auth_secret } },
        JSON.stringify(messageFor(row, local.date)),
        { TTL: 60 * 60 * 8, urgency: 'normal', topic: 'muslingo-daily-learning' },
      );
      await sql`UPDATE muslingo_push_subscriptions SET last_sent_date = ${local.date}::date WHERE endpoint_hash = ${row.endpoint_hash}`;
      sent += 1;
    } catch (error) {
      if (error?.statusCode === 404 || error?.statusCode === 410) {
        await sql`DELETE FROM muslingo_push_subscriptions WHERE endpoint_hash = ${row.endpoint_hash}`;
        removed += 1;
      } else {
        console.error('Push delivery failed', row.endpoint_hash, error?.statusCode ?? error?.message);
        failed += 1;
      }
    }
  }
  return response.status(200).json({ checked: rows.length, sent, removed, failed });
});
