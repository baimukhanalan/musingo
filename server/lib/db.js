// Shared by the single Vercel API router.
import { neon } from '@neondatabase/serverless';

if (!process.env.DATABASE_URL) {
  throw new Error('DATABASE_URL is not configured.');
}

export const sql = neon(process.env.DATABASE_URL);

let schemaPromise;

export function ensureSchema() {
  schemaPromise ??= (async () => {
    await sql`CREATE TABLE IF NOT EXISTS muslingo_users (
      id uuid PRIMARY KEY,
      email text NOT NULL UNIQUE CHECK (email = lower(email)),
      display_name text NOT NULL CHECK (char_length(display_name) BETWEEN 2 AND 60),
      password_salt text NOT NULL,
      password_hash text NOT NULL,
      guest_imported boolean NOT NULL DEFAULT false,
      created_at timestamptz NOT NULL DEFAULT now(),
      updated_at timestamptz NOT NULL DEFAULT now()
    )`;
    await sql`CREATE TABLE IF NOT EXISTS muslingo_progress (
      user_id uuid PRIMARY KEY REFERENCES muslingo_users(id) ON DELETE CASCADE,
      document jsonb NOT NULL DEFAULT '{}'::jsonb,
      version bigint NOT NULL DEFAULT 1,
      weekly_xp integer NOT NULL DEFAULT 0 CHECK (weekly_xp >= 0),
      week_start date NOT NULL DEFAULT date_trunc('week', now())::date,
      updated_at timestamptz NOT NULL DEFAULT now()
    )`;
    await sql`CREATE INDEX IF NOT EXISTS muslingo_progress_weekly_rank
      ON muslingo_progress (week_start, weekly_xp DESC)`;
    await sql`CREATE TABLE IF NOT EXISTS muslingo_login_attempts (
      key text PRIMARY KEY,
      attempts integer NOT NULL DEFAULT 0,
      window_started_at timestamptz NOT NULL DEFAULT now()
    )`;
    await sql`CREATE TABLE IF NOT EXISTS muslingo_push_subscriptions (
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
    )`;
    await sql`CREATE INDEX IF NOT EXISTS muslingo_push_enabled
      ON muslingo_push_subscriptions (enabled, updated_at)`;
  })();
  return schemaPromise;
}
