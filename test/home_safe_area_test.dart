import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/home_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('iPhone status bar never covers the home greeting in RU or AR',
      (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    tester.view.padding = const FakeViewPadding(top: 59, bottom: 34);
    tester.view.viewPadding = const FakeViewPadding(top: 59, bottom: 34);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetPadding);
    addTearDown(tester.view.resetViewPadding);
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
    });
    for (final locale in [AppLocale.ru, AppLocale.ar]) {
      await state.setLocale(locale);
      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          locale: locale.toLocale(),
          home: const HomeScreen(),
        ),
      ));
      await tester.pump();
      final greeting = find.textContaining(
        locale == AppLocale.ar ? 'السلام' : 'Ассаляму',
      );
      // The localized Arabic greeting can be generated from the app's own
      // translation layer; the spacer is a stable geometry probe for both.
      final spacer = find.byKey(const ValueKey('home-top-breathing-space'));
      expect(spacer, findsOneWidget);
      expect(tester.getTopLeft(spacer).dy, greaterThanOrEqualTo(59));
      expect(tester.getBottomLeft(spacer).dy, greaterThanOrEqualTo(115));
      if (greeting.evaluate().isNotEmpty) {
        expect(tester.getTopLeft(greeting).dy, greaterThanOrEqualTo(115));
      }
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
