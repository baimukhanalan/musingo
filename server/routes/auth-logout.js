import { requireSession } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { method, withApi } from '../lib/http.js';

export default withApi(async (request, response) => {
  method(request, ['POST']);
  const { user, payload } = await requireSession(request);
  const expiresAt = new Date(Number(payload.exp) * 1000);
  await sql.transaction([
    sql`
      INSERT INTO muslingo_revoked_sessions (jti, user_id, expires_at)
      VALUES (${payload.jti}, ${user.id}::uuid, ${expiresAt.toISOString()}::timestamptz)
      ON CONFLICT (jti) DO NOTHING
    `,
    sql`DELETE FROM muslingo_revoked_sessions WHERE expires_at <= now()`,
  ]);
  return response.status(204).end();
});
