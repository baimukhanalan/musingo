import { requireUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { method, withApi } from '../lib/http.js';

export default withApi(async (request, response) => {
  method(request, ['GET']);
  const currentUser = await requireUser(request);
  const rows = await sql`
    SELECT u.id AS user, u.display_name, p.weekly_xp AS xp
    FROM muslingo_progress p
    JOIN muslingo_users u ON u.id = p.user_id
    WHERE p.week_start = date_trunc('week', now())::date
    ORDER BY p.weekly_xp DESC, p.updated_at ASC
    LIMIT 50
  `;
  return response.status(200).json(rows.map((row, index) => ({
    user: row.user,
    displayName: row.display_name,
    xp: Number(row.xp),
    position: index + 1,
    isCurrentUser: row.user === currentUser.id,
  })));
});
