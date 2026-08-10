import { timingSafeEqual } from 'node:crypto';

import webPush from 'web-push';
import { createRemoteJWKSet, jwtVerify } from 'jose';

import { sql, ensureSchema } from '../lib/db.js';
import { method, withApi } from '../lib/http.js';
import { reminderMessage } from '../lib/reminder-copy.js';

const githubKeys = createRemoteJWKSet(
  new URL('https://token.actions.githubusercontent.com/.well-known/jwks'),
);
// Доверенный GitHub-репозиторий/workflow для OIDC-авторизации крона —
// конфигурируемо через env, чтобы не зависеть от захардкоженного имени
// (когда подключат GitHub с реальным именем репо, задают GITHUB_CRON_REPO).
// Базовый путь активации — Bearer CRON_SECRET (работает и с GitHub Actions, и
// с любым внешним cron-сервисом, и с Vercel Cron), OIDC — опционально.
const trustedRepo = process.env.GITHUB_CRON_REPO || 'baimukhanalan/musingo';
const trustedRef = process.env.GITHUB_CRON_REF || 'refs/heads/main';
const trustedWorkflowRef =
  process.env.GITHUB_CRON_WORKFLOW_REF ||
  `${trustedRepo}/.github/workflows/push-reminders.yml@${trustedRef}`;
const trustedEvents = new Set(['schedule', 'workflow_dispatch', 'push']);

// Сравнение секрета за постоянное время: наивное `a === b` даёт таймсайд-канал,
// по которому длину/префикс верного токена можно восстановить побитно. Разные
// длины — безопасный ранний false БЕЗ throw (timingSafeEqual бросает на разной
// длине буферов, поэтому сначала сверяем длину). Пустой expected никогда не
// матчится (проверяется у вызывающего).
export function constantTimeEqual(a, b) {
  const bufA = Buffer.from(String(a), 'utf8');
  const bufB = Buffer.from(String(b), 'utf8');
  if (bufA.length !== bufB.length) return false;
  return timingSafeEqual(bufA, bufB);
}

async function authorized(request) {
  const authorization = String(request.headers.authorization ?? '');
  const expected = process.env.CRON_SECRET;
  if (expected && constantTimeEqual(authorization, `Bearer ${expected}`)) return true;
  if (!authorization.startsWith('Bearer ')) return false;
  try {
    const { payload } = await jwtVerify(authorization.slice(7), githubKeys, {
      issuer: 'https://token.actions.githubusercontent.com',
      audience: 'muslingo-cron',
    });
    return payload.repository === trustedRepo
      && payload.ref === trustedRef
      && payload.workflow_ref === trustedWorkflowRef
      && trustedEvents.has(payload.event_name);
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
  // seed детерминированный: сумма кодов символов installation_id и локальной даты.
  // Один и тот же человек в один день получает стабильный текст, но день ото дня
  // видит разные варианты. Копирайт вынесен в чистые функции reminder-copy.js.
  const seed = [...`${row.installation_id}:${localDate}`].reduce((sum, char) => sum + char.charCodeAt(0), 0);
  const { title, body } = reminderMessage({
    dueCount: Number(row.due_count),
    learningGoal: row.learning_goal,
    seed,
  });
  return { title, body, url: '/#/home', tag: 'muslingo-daily-learning' };
}

// Ограниченная конкуренция рассылки. 2000 подписок отправлялись строго
// последовательно и не укладывались в maxDuration=60с. Теперь шлём пачками
// по BATCH_SIZE с Promise.all внутри пачки: ~40 пачек вместо 2000 round-trip.
export const BATCH_SIZE = 50;

export function chunk(items, size) {
  const step = Math.max(1, Math.floor(size) || 1);
  const chunks = [];
  for (let index = 0; index < items.length; index += step) {
    chunks.push(items.slice(index, index + step));
  }
  return chunks;
}

// Размер страницы курсорной выборки. Раньше выбирались ТОП-2000 по updated_at
// (LIMIT 2000 ORDER BY updated_at DESC) — «хвост» с более старым updated_at при
// >2000 активных подписок никогда не оценивался на своё окно и тихо переставал
// получать напоминания. Теперь идём курсором по всему enabled-множеству.
export const PAGE_SIZE = 1000;

// Чистый предфильтр по снимку строки. Попадает ли подписка в текущее окно
// напоминания (час совпал, минута — в той же 15-минутной корзине) и не
// отправлено ли ей уже сегодня по её локальной дате. Авторитетную защиту от
// дублей всё равно даёт условный UPDATE в deliver(); это лишь экономит round-trip.
export function isDue(row, local) {
  const inReminderBucket = local.hour === Number(row.reminder_hour)
    && Math.floor(local.minute / 15) === Math.floor(Number(row.reminder_minute) / 15);
  const alreadySent = row.last_sent_date && String(row.last_sent_date).slice(0, 10) === local.date;
  return Boolean(inReminderBucket && !alreadySent);
}

// Отбор кандидатов из произвольной пачки строк. Таймзона в строке, «сегодня»
// зависит от неё — поэтому окно считаем в JS по каждой строке, а не в SQL.
export function selectCandidates(rows, now) {
  const candidates = [];
  for (const row of rows) {
    let local;
    try {
      local = localParts(now, row.timezone);
    } catch {
      local = localParts(now, 'UTC');
    }
    if (!isDue(row, local)) continue;
    candidates.push({ row, local });
  }
  return candidates;
}

// Курсорная пагинация по ВСЕЙ enabled-базе. fetchPage(cursor, size) обязан
// вернуть строки, отсортированные по endpoint_hash ASC, с endpoint_hash >
// cursor и LIMIT size. Идём, пока пачка полная; курсор строго растёт
// (endpoint_hash — первичный ключ, уникален), поэтому цикл конечен и охватывает
// весь «хвост», который LIMIT 2000 раньше отсекал. Кандидатов фильтруем на лету,
// чтобы в память попадали только строки текущего окна, а не вся таблица.
export async function collectCandidates(fetchPage, now, pageSize = PAGE_SIZE) {
  const size = Math.max(1, Math.floor(pageSize) || 1);
  let checked = 0;
  const candidates = [];
  let cursor = '';
  for (;;) {
    const page = await fetchPage(cursor, size);
    if (!page || page.length === 0) break;
    checked += page.length;
    for (const candidate of selectCandidates(page, now)) candidates.push(candidate);
    if (page.length < size) break;
    cursor = page[page.length - 1].endpoint_hash;
  }
  return { checked, candidates };
}

async function deliver(row, local) {
  // Атомарный «захват» строки ДО отправки. Условие last_sent_date IS DISTINCT
  // FROM today делает UPDATE идемпотентным: параллельный запуск (schedule +
  // workflow_dispatch) не заберёт ту же строку и не отправит второй пуш.
  // Если строка уже помечена — RETURNING пуст, значит её взял другой запуск.
  const claimed = await sql`
    UPDATE muslingo_push_subscriptions
    SET last_sent_date = ${local.date}::date
    WHERE endpoint_hash = ${row.endpoint_hash}
      AND last_sent_date IS DISTINCT FROM ${local.date}::date
    RETURNING endpoint_hash
  `;
  if (claimed.length === 0) return 'skipped';
  try {
    await webPush.sendNotification(
      { endpoint: row.endpoint, keys: { p256dh: row.p256dh, auth: row.auth_secret } },
      JSON.stringify(messageFor(row, local.date)),
      { TTL: 60 * 60 * 8, urgency: 'normal', topic: 'muslingo-daily-learning' },
    );
    return 'sent';
  } catch (error) {
    // Ошибка одной подписки не должна ронять всю пачку (Promise.all): ловим её
    // здесь. 404/410 — endpoint мёртв, отключаем подписку, чтобы не слать снова.
    if (error?.statusCode === 404 || error?.statusCode === 410) {
      await sql`UPDATE muslingo_push_subscriptions SET enabled = false WHERE endpoint_hash = ${row.endpoint_hash}`;
      return 'removed';
    }
    console.error('Push delivery failed', row.endpoint_hash, error?.statusCode ?? error?.message);
    return 'failed';
  }
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

  // M8/приватность: мёртвые подписки (404/410 → enabled=false) больше не хранятся
  // вечно с ПДн (endpoint, p256dh, auth_secret, timezone, learning_goal,
  // installation_id). Раз в проход удаляем те, что отключены и не обновлялись
  // 30 дней. Одним запросом; число удалённых возвращаем как `purged`.
  const purgedRows = await sql`
    DELETE FROM muslingo_push_subscriptions
    WHERE enabled = false
      AND updated_at < now() - interval '30 days'
    RETURNING endpoint_hash
  `;
  const purged = purgedRows.length;

  const now = new Date();
  // Курсорная выборка по всему enabled-множеству (см. collectCandidates). Окно
  // свежести сохраняем, но порядок — по endpoint_hash, а не по updated_at, чтобы
  // «хвост» больше не выпадал из-за прежнего LIMIT 2000. Предфильтр окна и
  // «уже отправлено сегодня» считается на лету внутри collectCandidates.
  const { checked, candidates } = await collectCandidates(
    (cursor, size) => sql`
      SELECT endpoint_hash, endpoint, p256dh, auth_secret, installation_id,
             timezone, reminder_hour, reminder_minute, due_count, learning_goal, last_sent_date
      FROM muslingo_push_subscriptions
      WHERE enabled = true
        AND updated_at > now() - interval '120 days'
        AND endpoint_hash > ${cursor}
      ORDER BY endpoint_hash
      LIMIT ${size}
    `,
    now,
  );

  let sent = 0;
  let removed = 0;
  let failed = 0;
  let skipped = 0;
  for (const batch of chunk(candidates, BATCH_SIZE)) {
    const outcomes = await Promise.all(batch.map(({ row, local }) => deliver(row, local)));
    for (const outcome of outcomes) {
      if (outcome === 'sent') sent += 1;
      else if (outcome === 'removed') removed += 1;
      else if (outcome === 'failed') failed += 1;
      else skipped += 1;
    }
  }
  return response.status(200).json({ checked, due: candidates.length, sent, removed, failed, skipped, purged });
});
