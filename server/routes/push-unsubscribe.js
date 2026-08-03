import { createHash } from 'node:crypto';

import { sql, ensureSchema } from '../lib/db.js';
import { method, readJson, text, withApi } from '../lib/http.js';

export default withApi(async (request, response) => {
  method(request, ['POST', 'DELETE']);
  await ensureSchema();
  const body = readJson(request);
  const endpoint = text(body.endpoint, { min: 20, max: 2048, field: 'endpoint' });
  const endpointHash = createHash('sha256').update(endpoint).digest('hex');
  await sql`DELETE FROM muslingo_push_subscriptions WHERE endpoint_hash = ${endpointHash}`;
  return response.status(200).json({ subscribed: false });
});
