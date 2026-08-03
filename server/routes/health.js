import { sql, ensureSchema } from '../lib/db.js';
import { method, withApi } from '../lib/http.js';

export default withApi(async (request, response) => {
  method(request, ['GET']);
  await ensureSchema();
  const rows = await sql`SELECT 1 AS healthy`;
  return response.status(200).json({ status: rows[0]?.healthy === 1 ? 'ok' : 'degraded' });
});
