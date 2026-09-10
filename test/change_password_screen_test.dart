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
}
