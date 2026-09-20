import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/main_tab_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('all five navigation icons stay tappable at phone widths',
      (tester) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    expect(state.isInitialized, isTrue);
    await state.loginAsGuest();
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    for (final width in [320.0, 360.0, 390.0, 430.0]) {
      tester.view.physicalSize = Size(width, 844);
      tester.view.devicePixelRatio = 1;
      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(width == 390 ? 1.5 : 1),
            ),
            child: child!,
          ),
          home: const MainTabScreen(),
        ),
      ));
      await tester.pump();
      for (var index = 0; index < 5; index++) {
        final control = find.byKey(ValueKey('bottom-nav-$index'));
        expect(control.hitTestable(), findsOneWidget,
            reason: 'tab $index at width $width');
        final rect = tester.getRect(control);
        expect(rect.width, greaterThanOrEqualTo(48));
        expect(rect.height, greaterThanOrEqualTo(48));
        await tester.tap(control);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 300));
        final icon = tester.widget<Icon>(find.descendant(
          of: control,
          matching: find.byType(Icon),
        ));
        expect(icon.icon, isNotNull);
        expect(icon.icon!.fontFamily, 'MaterialIcons');
        expect(tester.takeException(), isNull,
            reason: 'tab $index at width $width');
      }
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
    state.dispose();
  });
}
