import { requireUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { ApiError, method, withApi } from '../lib/http.js';
import { profile } from '../lib/progress.js';

export default withApi(async (request, response) => {
  method(request, ['POST']);
  const user = await requireUser(request);
  for (let attempt = 0; attempt < 3; attempt += 1) {
    const rows = await sql`SELECT document, version FROM muslingo_progress WHERE user_id = ${user.id}::uuid`;
    const current = profile(rows[0]?.document, user);
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
