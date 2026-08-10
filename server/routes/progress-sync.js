import { requireUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { ApiError, method, readJson, withApi } from '../lib/http.js';
import { mergeLearningState, profile } from '../lib/progress.js';

export default withApi(async (request, response) => {
  method(request, ['POST']);
  const user = await requireUser(request);
  const body = readJson(request);
  const incoming = body.state && typeof body.state === 'object' ? body.state : {};
  const wantsImport = body.importGuest === true;

  for (let attempt = 0; attempt < 3; attempt += 1) {
    const rows = await sql`
      SELECT p.document, p.version, u.guest_imported
      FROM muslingo_progress p
      JOIN muslingo_users u ON u.id = p.user_id
      WHERE p.user_id = ${user.id}::uuid
    `;
    if (rows.length === 0) throw new ApiError(404, 'progress_not_found', 'Progress not found.');
    const canImport = wantsImport && rows[0].guest_imported === false;
    const merged = mergeLearningState(
      profile(rows[0].document, user),
      incoming,
      { importGuest: canImport },
    );
    const updated = await sql`
      UPDATE muslingo_progress
      SET document = ${JSON.stringify(merged)}::jsonb,
          version = version + 1,
          updated_at = now()
      WHERE user_id = ${user.id}::uuid AND version = ${rows[0].version}
      RETURNING document, version
    `;
    if (updated.length > 0) {
      // Флаг расходуется только после успешного слияния. Раньше он ставился
      // до цикла, и при конфликте версий (две вкладки) или ошибке весь
      // гостевой прогресс терялся навсегда — импорт больше не срабатывал.
      if (canImport) {
        await sql`
          UPDATE muslingo_users
          SET guest_imported = true, updated_at = now()
          WHERE id = ${user.id}::uuid AND guest_imported = false
        `;
      }
      return response.status(200).json({
        profile: profile(updated[0].document, user),
        version: Number(updated[0].version),
        guestImported: canImport,
      });
    }
  }
  throw new ApiError(409, 'sync_conflict', 'Progress changed. Retry synchronization.');
});
