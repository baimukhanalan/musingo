import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/settings_screen.dart';
import 'package:muslingo/screens/coach_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('mentor switches language without mixing saved conversations',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      while (!state.isInitialized) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
    });
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: state,
      child: const MaterialApp(home: CoachScreen()),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Айн · наставник'), findsOneWidget);

    await tester.runAsync(() => state.setLocale(AppLocale.kk));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Айн · тәлімгер'), findsOneWidget);
    expect(find.textContaining('Сегодня подходящий'), findsNothing);
    expect(find.textContaining('Бүгінгі қолайлы'), findsOneWidget);

    await tester.runAsync(() => state.setLocale(AppLocale.en));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.text('Ayn · mentor'), findsOneWidget);
    expect(find.textContaining('Бүгінгі қолайлы'), findsNothing);
    expect(find.textContaining('A good next step today'), findsOneWidget);
    final prefs = await SharedPreferences.getInstance();
    final keys = prefs
        .getKeys()
        .where((key) => key.startsWith('coach_conversation_v1_'));
    expect(keys.any((key) => key.endsWith('_ru')), isTrue);
    expect(keys.any((key) => key.endsWith('_kk')), isTrue);
    expect(keys.any((key) => key.endsWith('_en')), isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('App language changes interface and learning language together',
      (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});

    final state = AppState();
    await tester.runAsync(() async {
      while (!state.isInitialized) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: SettingsScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('settings-app-language')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    final english = find.byKey(const ValueKey('settings-app-locale-en'));
    await tester.ensureVisible(english);
    await tester.pump();
    await tester.tap(english);
    await tester.pump(const Duration(milliseconds: 500));

    expect(state.locale.code, 'en');
    expect(state.nativeLanguage, NativeLanguage.english);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Interface, all lessons and mentor'), findsOneWidget);
    expect(find.byKey(const ValueKey('settings-hint-language')), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
