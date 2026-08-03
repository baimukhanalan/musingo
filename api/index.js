import account from '../server/routes/account.js';
import authLogin from '../server/routes/auth-login.js';
import authMe from '../server/routes/auth-me.js';
import authRegister from '../server/routes/auth-register.js';
import cronReminders from '../server/routes/cron-reminders.js';
import health from '../server/routes/health.js';
import leaderboard from '../server/routes/leaderboard.js';
import progressComplete from '../server/routes/progress-complete.js';
import progressRestoreHeart from '../server/routes/progress-restore-heart.js';
import progressSync from '../server/routes/progress-sync.js';
import pushPublicKey from '../server/routes/push-public-key.js';
import pushSubscribe from '../server/routes/push-subscribe.js';
import pushUnsubscribe from '../server/routes/push-unsubscribe.js';
import speechEvaluate from '../server/routes/speech-evaluate.js';

const routes = new Map([
  ['account', account],
  ['auth/login', authLogin],
  ['auth/me', authMe],
  ['auth/register', authRegister],
  ['cron/reminders', cronReminders],
  ['health', health],
  ['leaderboard', leaderboard],
  ['progress/complete', progressComplete],
  ['progress/restore-heart', progressRestoreHeart],
  ['progress/sync', progressSync],
  ['push/public-key', pushPublicKey],
  ['push/subscribe', pushSubscribe],
  ['push/unsubscribe', pushUnsubscribe],
  ['speech/evaluate', speechEvaluate],
]);

export default async function handler(request, response) {
  const pathname = new URL(request.url, 'https://muslingo.local').pathname;
  const rewrittenRoute = request.query?.route;
  const route = String(
    Array.isArray(rewrittenRoute) ? rewrittenRoute.join('/') : rewrittenRoute ?? '',
  ) || pathname.replace(/^\/api\/?/, '').replace(/\/$/, '');
  const selected = routes.get(route);
  if (!selected) {
    response.setHeader('Cache-Control', 'no-store');
    return response.status(404).json({ error: 'not_found', message: 'API route not found.' });
  }
  return selected(request, response);
}
