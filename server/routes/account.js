import { requireUser } from '../lib/auth.js';
import { sql } from '../lib/db.js';
import { method, withApi } from '../lib/http.js';

export default withApi(async (request, response) => {
  method(request, ['DELETE']);
  const user = await requireUser(request);
  // Push-подписки удаляем в той же транзакции, что и аккаунт. FK объявлен как
  // ON DELETE SET NULL (см. db.js), поэтому без явного удаления подписка
  // осталась бы enabled=true с персональными данными (endpoint, ключи p256dh/
  // auth, timezone, learning_goal) и продолжала бы получать пуши после удаления
  // аккаунта. Подписки удаляются первыми — пока user_id ещё указывает на юзера.
  await sql.transaction([
    sql`DELETE FROM muslingo_push_subscriptions WHERE user_id = ${user.id}::uuid`,
    sql`DELETE FROM muslingo_users WHERE id = ${user.id}::uuid`,
  ]);
  return response.status(204).end();
});
