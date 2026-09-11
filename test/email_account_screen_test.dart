import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/email_account_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('forgot-password screen keeps the entered email', (tester) async {
    final state = AppState();
    await tester.runAsync(() => _waitUntilInitialized(state));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(
          home: ForgotPasswordScreen(initialEmail: 'alan@example.test'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Восстановить пароль'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'alan@example.test'), findsOneWidget);
    state.dispose();
  });

  testWidgets('reset screen rejects a damaged link before a network request',
      (tester) async {
    final state = AppState();
    await tester.runAsync(() => _waitUntilInitialized(state));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: ResetPasswordScreen(token: 'short')),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('reset-password-field')),
      'Password123!',
    );
    await tester.enterText(
      find.byKey(const Key('reset-confirm-field')),
      'Password123!',
    );
    await tester.tap(find.text('Изменить пароль'));
    await tester.pump();
    expect(find.text('Ссылка неполная или повреждена.'), findsOneWidget);
    state.dispose();
  });
}

Future<void> _waitUntilInitialized(AppState state) async {
  for (var i = 0; i < 200 && !state.isInitialized; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(state.isInitialized, isTrue);
}
