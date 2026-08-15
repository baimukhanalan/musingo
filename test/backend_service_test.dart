import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/backend_service.dart';

void main() {
  test('web never hides API failures behind a local-only account', () {
    expect(
      BackendService.shouldUseLocalAccountFallback(
        isWeb: true,
        configuredApiUrl: '',
      ),
      isFalse,
    );
  });

  test('local account fallback is limited to unconfigured native builds', () {
    expect(
      BackendService.shouldUseLocalAccountFallback(
        isWeb: false,
        configuredApiUrl: '',
      ),
      isTrue,
    );
    expect(
      BackendService.shouldUseLocalAccountFallback(
        isWeb: false,
        configuredApiUrl: 'https://api.example.test',
      ),
      isFalse,
    );
  });

  test('maps duplicate account errors to a readable login hint', () {
    const error = BackendException(
      409,
      'already_exists',
      'Account already exists.',
    );

    expect(
      readableBackendError(error),
      'Аккаунт с таким email уже есть. Войди через email и пароль.',
    );
  });

  test('maps failed password auth to a readable message', () {
    const error = BackendException(
      401,
      'invalid_credentials',
      'Invalid email or password.',
    );

    expect(readableBackendError(error), 'Неверный email или пароль.');
  });

  test('maps unavailable API to an offline-friendly message', () {
    const error = BackendException(0, 'network_error', 'Server unavailable.');

    expect(
      readableBackendError(error),
      'Сервер недоступен. Проверь подключение и повтори.',
    );
  });
}
