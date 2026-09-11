import account from '../server/routes/account.js';
import authLogin from '../server/routes/auth-login.js';
import authLogout from '../server/routes/auth-logout.js';
import authMe from '../server/routes/auth-me.js';
import authPassword from '../server/routes/auth-password.js';
import authPasswordForgot from '../server/routes/auth-password-forgot.js';
import authPasswordReset from '../server/routes/auth-password-reset.js';
import authRegister from '../server/routes/auth-register.js';
import authVerificationConfirm from '../server/routes/auth-verification-confirm.js';
import authVerificationRequest from '../server/routes/auth-verification-request.js';
import coach from '../server/routes/coach.js';
import cronReminders from '../server/routes/cron-reminders.js';
import friends from '../server/routes/friends.js';
import health from '../server/routes/health.js';
import leaderboard from '../server/routes/leaderboard.js';
import progressAttempt from '../server/routes/progress-attempt.js';
import progressComplete from '../server/routes/progress-complete.js';
import progressRestoreHeart from '../server/routes/progress-restore-heart.js';
import progressStep from '../server/routes/progress-step.js';
import progressSync from '../server/routes/progress-sync.js';
import pushPublicKey from '../server/routes/push-public-key.js';
import pushSubscribe from '../server/routes/push-subscribe.js';
import pushUnsubscribe from '../server/routes/push-unsubscribe.js';
import speechEvaluate from '../server/routes/speech-evaluate.js';
import speechCapabilities from '../server/routes/speech-capabilities.js';

const routes = new Map([
  ['account', account],
  ['auth/login', authLogin],
  ['auth/logout', authLogout],
  ['auth/me', authMe],
  ['auth/password', authPassword],
  ['auth/password/forgot', authPasswordForgot],
  ['auth/password/reset', authPasswordReset],
  ['auth/register', authRegister],
  ['auth/verification/confirm', authVerificationConfirm],
  ['auth/verification/request', authVerificationRequest],
  ['coach', coach],
  ['cron/reminders', cronReminders],
  ['friends', friends],
  ['health', health],
  ['leaderboard', leaderboard],
  ['progress/attempt', progressAttempt],
  ['progress/complete', progressComplete],
  ['progress/restore-heart', progressRestoreHeart],
  ['progress/step', progressStep],
  ['progress/sync', progressSync],
  ['push/public-key', pushPublicKey],
  ['push/subscribe', pushSubscribe],
  ['push/unsubscribe', pushUnsubscribe],
  ['speech/evaluate', speechEvaluate],
  ['speech/capabilities', speechCapabilities],
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
