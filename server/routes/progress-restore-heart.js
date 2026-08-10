import { requireUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { ApiError, method, withApi } from '../lib/http.js';
import { profile } from '../lib/progress.js';

// Mirrors progress-complete.js:45. Without this guard an empty result set falls
// through to profile(undefined) — whose hearts:5 default trips the hearts_full
// branch below — so a user with no progress row gets a misleading 400 instead
// of a 404. Exported so the branch is unit-testable without a DB.
export function requireProgressRows(rows) {
  if (rows.length === 0) throw new ApiError(404, 'progress_not_found', 'Progress not found.');
}

export default withApi(async (request, response) => {
  method(request, ['POST']);
  const user = await requireUser(request);
  for (let attempt = 0; attempt < 3; attempt += 1) {
    const rows = await sql`SELECT document, version FROM muslingo_progress WHERE user_id = ${user.id}::uuid`;
    requireProgressRows(rows);
    const current = profile(rows[0].document, user);
    if (current.isPremium || Number(current.hearts) >= 5) {
      throw new ApiError(400, 'hearts_full', 'Hearts are already full.');
    }
    if (Number(current.energy) < 20) throw new ApiError(400, 'not_enough_energy', 'Not enough energy.');
    const next = { ...current, hearts: Number(current.hearts) + 1, energy: Number(current.energy) - 20, updatedAt: new Date().toISOString() };
    const updated = await sql`
      UPDATE muslingo_progress
      SET document = ${JSON.stringify(next)}::jsonb, version = version + 1, updated_at = now()
      WHERE user_id = ${user.id}::uuid AND version = ${rows[0].version}
      RETURNING document
    `;
    if (updated.length > 0) return response.status(200).json(profile(updated[0].document, user));
  }
  throw new ApiError(409, 'progress_conflict', 'Progress changed. Try again.');
});
