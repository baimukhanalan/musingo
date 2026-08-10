// Shared by the single Vercel API router.
import { neon } from '@neondatabase/serverless';
import { ApiError } from './http.js';

// Клиент Neon инициализируется лениво. Раньше отсутствие DATABASE_URL роняло
// импорт модуля (throw на верхнем уровне): любой роут, тянущий db.js, падал ещё
// до запуска обработчика, и serverless-функция отдавала 500 без БД. Теперь
// клиент создаётся при первом реальном обращении к sql, а без DATABASE_URL
// бросается ApiError 503, который withApi (server/lib/http.js) распознаёт по
// instanceof и отдаёт чистым HTTP 503 (database_unavailable). http.js не
// импортирует db.js, поэтому цикла зависимостей нет.
let client;

function getClient() {
  if (client) return client;
  if (!process.env.DATABASE_URL) {
    throw new ApiError(503, 'database_unavailable', 'Database is not configured.');
  }
  client = neon(process.env.DATABASE_URL);
  return client;
}

// sql поддерживает два контракта из роутов:
//   - tagged-template:  sql`SELECT ...`
//   - методы клиента:   sql.transaction([...]) и прочие свойства neon().
// Proxy лениво форвардит и вызов (apply), и доступ к свойствам (get) в настоящий
// клиент, поэтому обращение к БД не происходит до первого использования.
export const sql = new Proxy(function () {}, {
  apply(_target, _thisArg, args) {
    return getClient()(...args);
  },
  get(_target, prop) {
    const active = getClient();
    const value = active[prop];
    return typeof value === 'function' ? value.bind(active) : value;
  },
});

// SQLSTATE-коды «объект уже существует». При холодном старте несколько
// serverless-инстансов параллельно гоняют createSchema; CREATE ... IF NOT
// EXISTS / ADD COLUMN IF NOT EXISTS НЕ защищают от гонки в системном каталоге —
// конкурентные DDL падают с одним из этих кодов. neon-http держит каждый запрос
// в отдельной сессии, поэтому pg_advisory_lock между запросами не сохраняется и
// как барьер не годится. Вместо этого глотаем именно duplicate-ошибки: объект
// уже создан параллельным инстансом — это не ошибка. Иначе 23505 доходит до
// withApi и маппится в неверный 409 (already_exists). Прочие ошибки — наружу.
const DUPLICATE_OBJECT_CODES = new Set([
  '23505', // unique_violation (гонка в pg_catalog при конкурентном CREATE)
  '42P07', // duplicate_table
  '42P06', // duplicate_schema
  '42710', // duplicate_object (индекс/констрейнт)
  '42701', // duplicate_column (гонка ADD COLUMN IF NOT EXISTS)
]);

export async function ignoreDuplicate(promise) {
  try {
    return await promise;
  } catch (error) {
    if (DUPLICATE_OBJECT_CODES.has(error?.code)) return undefined;
    throw error;
  }
}

let schemaPromise;

export function ensureSchema() {
  // Промис кешируется только при успехе. Раньше отклонённый промис оставался
  // в кеше навсегда, и одна транзиентная ошибка Neon при холодном старте
  // роняла в 500 все последующие запросы инстанса, включая вход.
  schemaPromise ??= createSchema().catch((error) => {
    schemaPromise = undefined;
    throw error;
  });
  return schemaPromise;
}

function createSchema() {
  return (async () => {
    await ignoreDuplicate(sql`CREATE TABLE IF NOT EXISTS muslingo_users (
      id uuid PRIMARY KEY,
      email text NOT NULL UNIQUE CHECK (email = lower(email)),
      display_name text NOT NULL CHECK (char_length(display_name) BETWEEN 2 AND 60),
      password_salt text NOT NULL,
      password_hash text NOT NULL,
      guest_imported boolean NOT NULL DEFAULT false,
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )`);
    await ignoreDuplicate(sql`CREATE TABLE IF NOT EXISTS muslingo_progress (
      user_id uuid PRIMARY KEY REFERENCES muslingo_users(id) ON DELETE CASCADE,
      document jsonb NOT NULL DEFAULT '{}'::jsonb,
      version bigint NOT NULL DEFAULT 1,
      weekly_xp integer NOT NULL DEFAULT 0 CHECK (weekly_xp >= 0),
      week_start date NOT NULL DEFAULT date_trunc('week', now())::date,
      updated_at timestamptz NOT NULL DEFAULT now()
    )`);
    await ignoreDuplicate(sql`CREATE INDEX IF NOT EXISTS muslingo_progress_weekly_rank
      ON muslingo_progress (week_start, weekly_xp DESC)`);
    await ignoreDuplicate(sql`CREATE TABLE IF NOT EXISTS muslingo_login_attempts (
      key text PRIMARY KEY,
      attempts integer NOT NULL DEFAULT 0,
      window_started_at timestamptz NOT NULL DEFAULT now()
    )`);
    await ignoreDuplicate(sql`CREATE TABLE IF NOT EXISTS muslingo_revoked_sessions (
      jti text PRIMARY KEY,
      user_id uuid NOT NULL REFERENCES muslingo_users(id) ON DELETE CASCADE,
      expires_at timestamptz NOT NULL,
      created_at timestamptz NOT NULL DEFAULT now()
    )`);
    await ignoreDuplicate(sql`CREATE INDEX IF NOT EXISTS muslingo_revoked_sessions_expiry
      ON muslingo_revoked_sessions (expires_at)`);
    await ignoreDuplicate(sql`CREATE TABLE IF NOT EXISTS muslingo_push_subscriptions (
      endpoint_hash text PRIMARY KEY,
      endpoint text NOT NULL,
      p256dh text NOT NULL,
      auth_secret text NOT NULL,
      installation_id text NOT NULL,
      user_id uuid REFERENCES muslingo_users(id) ON DELETE SET NULL,
      timezone text NOT NULL DEFAULT 'UTC',
      reminder_hour smallint NOT NULL DEFAULT 19 CHECK (reminder_hour BETWEEN 0 AND 23),
      reminder_minute smallint NOT NULL DEFAULT 30 CHECK (reminder_minute BETWEEN 0 AND 59),
      enabled boolean NOT NULL DEFAULT true,
      learning_goal text,
      due_count integer NOT NULL DEFAULT 0 CHECK (due_count >= 0),
      last_sent_date date,
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )`);
    await ignoreDuplicate(sql`CREATE INDEX IF NOT EXISTS muslingo_push_enabled
      ON muslingo_push_subscriptions (enabled, updated_at)`);
    // Индекс под курсорную рассылку напоминаний (M7): выборка идёт
    // WHERE enabled = true ... AND endpoint_hash > $cursor ORDER BY endpoint_hash.
    // Индекс (enabled, endpoint_hash) обслуживает и фильтр по enabled, и
    // диапазон/порядок по endpoint_hash, чтобы охватить всю базу без seq scan.
    await ignoreDuplicate(sql`CREATE INDEX IF NOT EXISTS muslingo_push_enabled_cursor
      ON muslingo_push_subscriptions (enabled, endpoint_hash)`);
    // Дружеские связи. Дружба симметрична, но храним её ДВУМЯ направленными
    // строками ((A→B) и (B→A)), а не одной упорядоченной парой. Так список
    // друзей любого пользователя — это простой `WHERE user_id = $me` по префиксу
    // первичного ключа, без OR по двум колонкам и без least()/greatest() при
    // каждой вставке; обе строки пишутся/удаляются в одной транзакции (см.
    // routes/friends.js), поэтому пара всегда согласована. Оба внешних ключа
    // каскадно удаляются вместе с аккаунтом, дубликаты гасит первичный ключ,
    // а CHECK запрещает дружбу с самим собой.
    await sql`CREATE TABLE IF NOT EXISTS muslingo_friendships (
      user_id uuid NOT NULL REFERENCES muslingo_users(id) ON DELETE CASCADE,
      friend_id uuid NOT NULL REFERENCES muslingo_users(id) ON DELETE CASCADE,
      created_at timestamptz NOT NULL DEFAULT now(),
      PRIMARY KEY (user_id, friend_id),
      CHECK (user_id <> friend_id)
    )`;

    // --- Аддитивные миграции (H1) ---
    // CREATE TABLE IF NOT EXISTS не добавляет колонки к УЖЕ существующей таблице.
    // Прод-база создана более ранней схемой, поэтому недостающие колонки
    // добавляем идемпотентно (ADD COLUMN IF NOT EXISTS) — иначе INSERT/SELECT к
    // ним падает `column ... does not exist` → 500 в push/cron/progress.
    await ignoreDuplicate(sql`ALTER TABLE muslingo_users
      ADD COLUMN IF NOT EXISTS guest_imported boolean NOT NULL DEFAULT false`);
    await ignoreDuplicate(sql`ALTER TABLE muslingo_progress
      ADD COLUMN IF NOT EXISTS weekly_xp integer NOT NULL DEFAULT 0`);
    await ignoreDuplicate(sql`ALTER TABLE muslingo_progress
      ADD COLUMN IF NOT EXISTS week_start date NOT NULL DEFAULT date_trunc('week', now())::date`);
    await ignoreDuplicate(sql`ALTER TABLE muslingo_push_subscriptions
      ADD COLUMN IF NOT EXISTS installation_id text NOT NULL DEFAULT ''`);
    await ignoreDuplicate(sql`ALTER TABLE muslingo_push_subscriptions
      ADD COLUMN IF NOT EXISTS timezone text NOT NULL DEFAULT 'UTC'`);
    await ignoreDuplicate(sql`ALTER TABLE muslingo_push_subscriptions
      ADD COLUMN IF NOT EXISTS reminder_hour smallint NOT NULL DEFAULT 19`);
    await ignoreDuplicate(sql`ALTER TABLE muslingo_push_subscriptions
      ADD COLUMN IF NOT EXISTS reminder_minute smallint NOT NULL DEFAULT 30`);
    await ignoreDuplicate(sql`ALTER TABLE muslingo_push_subscriptions
      ADD COLUMN IF NOT EXISTS enabled boolean NOT NULL DEFAULT true`);
    await ignoreDuplicate(sql`ALTER TABLE muslingo_push_subscriptions
      ADD COLUMN IF NOT EXISTS learning_goal text`);
    await ignoreDuplicate(sql`ALTER TABLE muslingo_push_subscriptions
      ADD COLUMN IF NOT EXISTS due_count integer NOT NULL DEFAULT 0`);
    await ignoreDuplicate(sql`ALTER TABLE muslingo_push_subscriptions
      ADD COLUMN IF NOT EXISTS last_sent_date date`);
    await ignoreDuplicate(sql`ALTER TABLE muslingo_push_subscriptions
      ADD COLUMN IF NOT EXISTS user_id uuid`);

    // Индексы под FK-колонки (M5/M6): без них каскадное удаление аккаунта идёт
    // seq scan'ом по всей таблице под блокировкой.
    await ignoreDuplicate(sql`CREATE INDEX IF NOT EXISTS muslingo_friendships_friend
      ON muslingo_friendships (friend_id)`);
    await ignoreDuplicate(sql`CREATE INDEX IF NOT EXISTS muslingo_push_user
      ON muslingo_push_subscriptions (user_id)`);
  })();
}
