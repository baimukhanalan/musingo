import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/academy_modes_screen.dart';
import 'package:muslingo/services/app_state.dart';
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
    await tester.tap(find.byKey(const ValueKey('academy-mode-0')));
    await tester.pump();
    expect(find.byKey(const ValueKey('academy-learn-mode')), findsOneWidget);
  });
}
