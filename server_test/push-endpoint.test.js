import assert from 'node:assert/strict';
import test from 'node:test';

// db.js падает при импорте без DATABASE_URL, а маршрут его тянет.
// Значение фиктивное: neon() не подключается до первого запроса.
process.env.DATABASE_URL ??= 'postgres://user:pass@localhost/db';

const { assertAllowedEndpoint } = await import('../server/routes/push-subscribe.js');

/// Возвращает пойманную ошибку, чтобы можно было проверить её код и статус.
function rejects(endpoint) {
  try {
    assertAllowedEndpoint(endpoint);
  } catch (error) {
    return error;
  }
  assert.fail(`endpoint должен был быть отклонён: ${endpoint}`);
}

test('принимает endpoint известных push-сервисов', () => {
  assertAllowedEndpoint('https://fcm.googleapis.com/fcm/send/abc123');
  assertAllowedEndpoint('https://web.push.apple.com/QWERTY');
  assertAllowedEndpoint('https://updates.push.services.mozilla.com/wpush/v2/abc');
  assertAllowedEndpoint('https://xyz.notify.windows.com/w/?token=abc');
});

test('отклоняет произвольный хост — иначе сервер шлёт POST куда укажут', () => {
  const error = rejects('https://attacker.example.com/collect');
  assert.equal(error.status, 400);
  assert.equal(error.code, 'invalid_endpoint');
});

test('отклоняет внутренние адреса', () => {
  rejects('https://localhost/push');
  rejects('https://127.0.0.1/push');
  rejects('https://169.254.169.254/latest/meta-data');
});

test('отклоняет http и мусор', () => {
  const insecure = rejects('http://fcm.googleapis.com/fcm/send/abc');
  assert.equal(insecure.code, 'invalid_endpoint');
  rejects('не-ссылка');
  rejects('');
});

test('не обманывается похожим доменом', () => {
  // Суффикс должен совпадать по границе точки, а не по подстроке.
  rejects('https://evilgoogleapis.com/fcm/send/abc');
  rejects('https://fcm.googleapis.com.attacker.net/fcm/send/abc');
});

test('список расширяется переменной окружения', () => {
  process.env.MUSLINGO_PUSH_ALLOWED_HOSTS = 'push.example.dev';
  try {
    assertAllowedEndpoint('https://push.example.dev/send/1');
    assertAllowedEndpoint('https://eu.push.example.dev/send/1');
  } finally {
    delete process.env.MUSLINGO_PUSH_ALLOWED_HOSTS;
  }
  rejects('https://push.example.dev/send/1');
});
