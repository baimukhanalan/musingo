import { requireUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { method, withApi } from '../lib/http.js';

export default withApi(async (request, response) => {
  method(request, ['DELETE']);
  const user = await requireUser(request);
  await sql`DELETE FROM muslingo_users WHERE id = ${user.id}::uuid`;
  return response.status(204).end();
});
