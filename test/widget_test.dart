import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';

import 'package:muslingo/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Muslingo app starts with splash screen',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(const MuslingoApp());

    expect(find.text('muslingo'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
  });

  test('login screen does not offer guest access', () {
    final source = File('lib/screens/login_screen.dart').readAsStringSync();

    expect(source, isNot(contains('Продолжить как гость')));
    expect(source, isNot(contains('_loginGuest')));
    expect(source, contains('Нет аккаунта? Зарегистрироваться'));
  });
}
