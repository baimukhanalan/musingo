import { requireUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { method, withApi } from '../lib/http.js';
import { profile } from '../lib/progress.js';

export default withApi(async (request, response) => {
  method(request, ['GET']);
  const user = await requireUser(request);
  const rows = await sql`
    SELECT p.document, u.email_verified_at
    FROM muslingo_progress p
    JOIN muslingo_users u ON u.id = p.user_id
    WHERE p.user_id = ${user.id}::uuid
  `;
  return response.status(200).json({
    ...profile(rows[0]?.document, user),
    emailVerified: Boolean(rows[0]?.email_verified_at),
  });
});
