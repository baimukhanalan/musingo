import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/change_password_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('password screen validates all fields before submission',
      (tester) async {
    final state = AppState();
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: ChangePasswordScreen()),
      ),
    );

    await tester.tap(find.text('Сохранить пароль'));
    await tester.pump();
    expect(find.text('Введи текущий пароль'), findsOneWidget);
    expect(find.text('Минимум 8 символов'), findsOneWidget);

    await tester.enterText(find.byType(TextFormField).at(0), 'Current123!');
    await tester.enterText(find.byType(TextFormField).at(1), 'Changed456!');
    await tester.enterText(find.byType(TextFormField).at(2), 'Different789!');
    await tester.tap(find.text('Сохранить пароль'));
    await tester.pump();
    expect(find.text('Пароли не совпадают'), findsOneWidget);
  });

  testWidgets('wrong current password stays visible next to the form',
      (tester) async {
    final state = AppState();
    await tester.runAsync(() async {
      while (!state.isInitialized) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
      await state.registerWithEmail(
        'Alan',
        'password-ui@example.test',
        'Current123!',
      );
    });
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: ChangePasswordScreen()),
      ),
    );

    await tester.enterText(find.byType(TextFormField).at(0), 'Wrong123!');
    await tester.enterText(find.byType(TextFormField).at(1), 'Changed456!');
    await tester.enterText(find.byType(TextFormField).at(2), 'Changed456!');
    await tester.tap(find.text('Сохранить пароль'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.byKey(const ValueKey('password-submit-error')), findsOneWidget);
    expect(find.text('Текущий пароль указан неверно.'), findsWidgets);
  });

  testWidgets('keyboard done submits a valid password change', (tester) async {
    final state = AppState();
    await tester.runAsync(() async {
      while (!state.isInitialized) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
      await state.registerWithEmail(
        'Alan',
        'password-done@example.test',
        'Current123!',
      );
    });
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const ChangePasswordScreen(),
                  ),
                ),
                child: const Text('open-password'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open-password'));
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(0), 'Current123!');
    await tester.enterText(find.byType(TextFormField).at(1), 'Changed456!');
    await tester.enterText(find.byType(TextFormField).at(2), 'Changed456!');
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 150));

    expect(find.text('open-password'), findsOneWidget);
    expect(
      await state.loginWithPassword(
        'password-done@example.test',
        'Changed456!',
      ),
      isTrue,
    );
  });
}
