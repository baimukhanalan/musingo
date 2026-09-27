import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/academy_modes_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Academy switches between learning and listening catalogues',
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
      child: const MaterialApp(home: AcademyModesScreen()),
    ));
    await tester.pump();
    expect(find.byKey(const ValueKey('academy-learn-mode')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('academy-mode-1')));
    await tester.pump();
    expect(find.byKey(const ValueKey('academy-listen-mode')), findsOneWidget);
    expect(
        find.byKey(const ValueKey('continuous-audio-scroll')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('academy-mode-2')));
    await tester.pump();
    expect(find.byKey(const ValueKey('academy-lectures-mode')), findsOneWidget);
    expect(find.byKey(const ValueKey('academy-lecture-list')), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('academy-mode-0')));
    await tester.pump();
    expect(find.byKey(const ValueKey('academy-learn-mode')), findsOneWidget);
  });

  for (final locale in AppLocale.values) {
    testWidgets('lecture shelf fits compact phone in ${locale.code}',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await tester.runAsync(() async {
        while (!state.isInitialized) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        await state.loginAsGuest();
        await state.setLocale(locale);
      });
      tester.view.devicePixelRatio = 1;
      tester.view.physicalSize = const Size(320, 568);
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(
          home: MediaQuery(
            data: MediaQueryData(
              size: Size(320, 568),
              textScaler: TextScaler.linear(1.3),
            ),
            child: AcademyModesScreen(),
          ),
        ),
      ));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('academy-mode-2')));
      await tester.pump();
      expect(
          find.byKey(const ValueKey('academy-lecture-list')), findsOneWidget);
      expect(tester.takeException(), isNull);
      state.dispose();
    });
  }
}
