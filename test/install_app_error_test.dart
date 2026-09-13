import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/app_install_result.dart';
import 'package:muslingo/screens/install_app_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/widgets/premium_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('install rejection restores the button and explains the error',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      while (!state.isInitialized) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });

    Future<AppInstallResult> rejectInstall() async =>
        throw StateError('prompt rejected');
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: InstallAppScreen(
            installAction: rejectInstall,
            installedOverride: false,
          ),
        ),
      ),
    );
    await tester.pump();

    final action = find.byKey(const ValueKey('install-app-action'));
    await tester.scrollUntilVisible(action, 300);
    await tester.tap(action);
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.textContaining('Не удалось открыть установку'), findsOneWidget);
    expect(tester.widget<PremiumButton>(action).onPressed, isNotNull);
    expect(find.text('Подготовка...'), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
