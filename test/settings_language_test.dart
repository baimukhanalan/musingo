import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/settings_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('App language changes UI locale, not explanation language',
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
    expect(state.nativeLanguage, isNull);
    expect(find.text('Settings'), findsOneWidget);
    expect(find.text('Explanation language'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
