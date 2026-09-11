import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/progress_portability_screen.dart';
import 'package:muslingo/screens/settings_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('exports JSON and offers checked local import', (tester) async {
    final clipboardWrites = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, (call) async {
      if (call.method == 'Clipboard.setData') clipboardWrites.add(call);
      return null;
    });

    final state = AppState();
    await tester.runAsync(() async {
      await _waitUntilInitialized(state);
      await state.loginAsGuest();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: ProgressPortabilityScreen()),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(find.text('Перенос прогресса'), findsOneWidget);
    expect(find.text('Импортировать прогресс'), findsOneWidget);

    await tester.tap(find.byKey(const Key('progress-export-button')));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byKey(const Key('progress-export-preview')), findsOneWidget);
    expect(clipboardWrites, hasLength(1));
    expect(
      (clipboardWrites.single.arguments as Map)['text'],
      contains('"format": "muslingo-progress"'),
    );
    expect(find.textContaining('JSON скопирован'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(SystemChannels.platform, null);
  });

  testWidgets('settings opens progress portability screen', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState();
    await tester.runAsync(() async {
      await _waitUntilInitialized(state);
      await state.loginAsGuest();
    });

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: const SettingsScreen(),
          routes: {
            '/progress-portability': (_) => const ProgressPortabilityScreen(),
          },
        ),
      ),
    );
    await tester.pump();

    final link = find.text('Перенос прогресса');
    await tester.scrollUntilVisible(link, 300);
    await tester.tap(link);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));

    expect(find.byType(ProgressPortabilityScreen), findsOneWidget);
    expect(find.text('Экспортировать прогресс'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}

Future<void> _waitUntilInitialized(AppState state) async {
  for (var i = 0; i < 200 && !state.isInitialized; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(state.isInitialized, isTrue);
}
