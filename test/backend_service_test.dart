import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/backend_service.dart';
import 'package:pocketbase/pocketbase.dart';

void main() {
  test('maps duplicate account errors to a readable login hint', () {
    final error = ClientException(
      statusCode: 400,
      response: {
        'message': 'Failed to create record.',
        'data': {
          'email': {'message': 'Value must be unique.'},
        },
      },
    );

    expect(
      readableBackendError(error),
      'Аккаунт с таким email уже есть. Войди через email и пароль.',
    );
  });

  test('maps failed password auth to a readable message', () {
    final error = ClientException(
      statusCode: 400,
      response: {'message': 'Failed to authenticate.'},
    );

    expect(readableBackendError(error), 'Неверный email или пароль.');
  });
}
