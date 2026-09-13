import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muslingo/services/backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

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

  test('changes password with the active token and stores the replacement',
      () async {
    var calls = 0;
    final client = MockClient((request) async {
      calls += 1;
      if (request.url.path == '/api/auth/login') {
        return http.Response(
          jsonEncode({
            'token': 'old-token',
            'profile': {
              'user': 'user-1',
              'displayName': 'Alan',
              'email': 'alan@example.test',
            },
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }
      expect(request.url.path, '/api/auth/password');
      expect(request.headers['Authorization'], 'Bearer old-token');
      expect(jsonDecode(request.body), {
        'currentPassword': 'Current123!',
        'newPassword': 'Changed456!',
      });
      return http.Response(
        jsonEncode({'token': 'new-token'}),
        200,
        headers: {'content-type': 'application/json'},
      );
    });
    final service = await BackendService.create(client: client);
    await service.login(
      email: 'alan@example.test',
      password: 'Current123!',
    );
    await service.changePassword(
      currentPassword: 'Current123!',
      newPassword: 'Changed456!',
    );

    expect(calls, 2);
    expect(service.authToken, 'new-token');
    final preferences = await SharedPreferences.getInstance();
    expect(preferences.getString('muslingo_auth_token'), 'new-token');
    service.dispose();
  });

  test('maps password change failures to clear messages', () {
    expect(
      readableBackendError(const BackendException(
        401,
        'invalid_current_password',
        'Wrong current password.',
      )),
      'Текущий пароль указан неверно.',
    );
    expect(
      readableBackendError(const BackendException(
        400,
        'password_reuse',
        'Password reused.',
      )),
      'Новый пароль должен отличаться от текущего.',
    );
  });

  test('requests recovery without authentication and reports delivery state',
      () async {
    final client = MockClient((request) async {
      expect(request.url.path, '/api/auth/password/forgot');
      expect(request.headers.containsKey('Authorization'), isFalse);
      expect(jsonDecode(request.body), {'email': 'alan@example.test'});
      return http.Response(
        jsonEncode({'accepted': true, 'delivery': 'provider_configured'}),
        202,
        headers: {'content-type': 'application/json'},
      );
    });
    final service = await BackendService.create(client: client);
    final result = await service.requestPasswordReset('alan@example.test');
    expect(result.accepted, isTrue);
    expect(result.canDeliver, isTrue);
    service.dispose();
  });

  test('submits one-time reset and verification tokens unauthenticated',
      () async {
    final paths = <String>[];
    final client = MockClient((request) async {
      paths.add(request.url.path);
      expect(request.headers.containsKey('Authorization'), isFalse);
      return http.Response('{}', 200,
          headers: {'content-type': 'application/json'});
    });
    final service = await BackendService.create(client: client);
    final resetToken = List.filled(43, 't').join();
    final verificationToken = List.filled(43, 'v').join();
    await service.resetPassword(
      token: resetToken,
      newPassword: 'Changed456!',
    );
    await service.confirmEmailVerification(verificationToken);
    expect(paths, [
      '/api/auth/password/reset',
      '/api/auth/verification/confirm',
    ]);
    service.dispose();
  });

  test('temporary offline restore keeps the stored session for retry',
      () async {
    SharedPreferences.setMockInitialValues({
      'muslingo_auth_token': 'still-valid-token',
    });
    final service = await BackendService.create(
      client: MockClient((_) async => throw Exception('offline')),
    );

    expect(await service.restoreSession(), isNull);
    expect(service.authToken, 'still-valid-token');
    expect(
      (await SharedPreferences.getInstance()).getString('muslingo_auth_token'),
      'still-valid-token',
    );
    service.dispose();
  });

  test('revoked restore clears the stored session', () async {
    SharedPreferences.setMockInitialValues({
      'muslingo_auth_token': 'revoked-token',
    });
    final service = await BackendService.create(
      client: MockClient((_) async => http.Response(
            jsonEncode({
              'error': 'expired_session',
              'message': 'Session expired.',
            }),
            401,
            headers: {'content-type': 'application/json'},
          )),
    );

    expect(await service.restoreSession(), isNull);
    expect(service.authToken, isNull);
    expect(
      (await SharedPreferences.getInstance()).getString('muslingo_auth_token'),
      isNull,
    );
    service.dispose();
  });
}
