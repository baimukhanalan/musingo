import { createHash } from 'node:crypto';

import { optionalUser } from '../lib/auth.js';
import { sql, ensureSchema } from '../lib/db.js';
import { ApiError, method, readJson, text, withApi } from '../lib/http.js';

export default withApi(async (request, response) => {
  method(request, ['POST', 'DELETE']);
  await ensureSchema();
  const user = await optionalUser(request);
  const body = readJson(request);
  const endpoint = text(body.endpoint, { min: 20, max: 2048, field: 'endpoint' });
  const endpointHash = createHash('sha256').update(endpoint).digest('hex');

  // Раньше здесь удаляли строку по одному лишь endpoint_hash без всякой
  // проверки: кто угодно, узнав endpoint, отключал уведомления чужому
  // устройству. Теперь нужно доказать владение — либо тем же
  // installationId, что был при подписке, либо токеном владельца записи.
  const installationId = body.installationId == null
    ? null
    : text(body.installationId, { min: 8, max: 128, field: 'installation' });
  const userId = user?.id ?? null;

  if (installationId == null && userId == null) {
    throw new ApiError(
      401,
      'authentication_required',
      'Provide the installation id used to subscribe, or authenticate.',
    );
  }

  const deleted = await sql`
    DELETE FROM muslingo_push_subscriptions
    WHERE endpoint_hash = ${endpointHash}
      AND (
        installation_id = ${installationId}
        OR user_id = ${userId}::uuid
      )
    RETURNING endpoint_hash
  `;

  // Ответ одинаковый независимо от того, нашлась строка или нет: иначе
  // эндпоинт превращается в оракул «существует ли такая подписка».
  return response.status(200).json({ subscribed: false, removed: deleted.length > 0 });
});
