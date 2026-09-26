import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslingo/models/curriculum_module.dart';
import 'package:muslingo/models/curriculum_progress.dart';
import 'package:muslingo/screens/curriculum_module_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/curriculum_progress_service.dart';
import 'package:muslingo/services/curriculum_repository.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:muslingo/widgets/premium_button.dart';

import 'support/exhaustive_audit.dart';
import 'support/localization_host.dart';

const _action = ValueKey('curriculum-primary-action');
const _sizes = [Size(320, 568), Size(390, 844), Size(430, 932)];

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<CurriculumModule> modules;
  setUpAll(() async {
    await LessonContentLocalization.load();
    modules = await CurriculumRepository.load();
  });

  for (final locale in AppLocale.values) {
    testWidgets(
        '${locale.code}: ${exhaustiveAudit ? 'all 570' : 'representative'} modules complete every stage and save',
        (tester) async {
      final state = await _guest(tester, locale);
      final localized = modules
          .map((module) =>
              LessonContentLocalization.localizeModule(module, locale.code))
          .toList();
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetDevicePixelRatio);
      addTearDown(tester.view.resetPhysicalSize);

      final selectedIndices = moduleAuditIndices(localized);
      for (var selectedIndex = 0;
          selectedIndex < selectedIndices.length;
          selectedIndex++) {
        final index = selectedIndices[selectedIndex];
        tester.view.physicalSize = _sizes[(index + locale.index) % 3];
        final module = modules[index];
        await _open(tester, state, module, modules,
            textScale: index % 11 == 0 ? 1.3 : 1);
        final challenges = buildCurriculumChallenges(
          module: localized[index],
          allModules: localized,
          locale: locale.code,
        );
        await _completeModule(tester, challenges, module.id);
        final saved = await CurriculumProgressService.load(state.user!.id);
        expect(saved.completedModuleIds, contains(module.id),
            reason: module.id);
        expect(saved.masteryByModuleId[module.id], 100, reason: module.id);
        expect(saved.completedCount, selectedIndex + 1, reason: module.id);
        final next = find.byKey(const ValueKey('curriculum-next-module'));
        expect(
            next, index == modules.length - 1 ? findsNothing : findsOneWidget);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
      state.dispose();
    }, timeout: const Timeout(Duration(minutes: 20)));

    testWidgets(
        '${locale.code}: close and back-to-library return saved progress',
        (tester) async {
      final state = await _guest(tester, locale);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      CurriculumProgress? returned;
      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
            locale: state.locale.toLocale(),
            supportedLocales: testSupportedLocales,
            localizationsDelegates: testLocalizationDelegates,
            home: Builder(
                builder: (context) => Scaffold(
                      body: Center(
                          child: ElevatedButton(
                        key: const ValueKey('test-library-open'),
                        onPressed: () async {
                          returned = await Navigator.of(context)
                              .push<CurriculumProgress>(MaterialPageRoute(
                                  builder: (_) => CurriculumModuleScreen(
                                      module: modules.first,
                                      modulesFuture: Future.value(modules))));
                        },
                        child: const Text('Library'),
                      )),
                    ))),
      ));
      await _tap(tester, const ValueKey('test-library-open'));
      await tester.pumpAndSettle();
      await _tap(tester, _action);
      await _tap(tester, _action);
      await _tap(tester, const ValueKey('curriculum-close'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('test-library-open')), findsOneWidget);
      expect(returned?.stepByModuleId[modules.first.id], 2);
      expect(returned?.completedCount, 0);
      await _tap(tester, const ValueKey('test-library-open'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('curriculum-stage-2')), findsOneWidget);
      final localized = modules
          .map((module) =>
              LessonContentLocalization.localizeModule(module, locale.code))
          .toList();
      final challenges = buildCurriculumChallenges(
          module: localized.first, allModules: localized, locale: locale.code);
      for (final challenge in challenges.take(2)) {
        await _solve(tester, challenge);
      }
      for (var index = 0; index < 3; index++) {
        await _tap(tester, ValueKey('curriculum-practice-$index'));
      }
      await _tap(tester, _action);
      for (final challenge in challenges.skip(2)) {
        await _solve(tester, challenge);
      }
      await _tap(tester, const ValueKey('curriculum-back-to-library'));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('test-library-open')), findsOneWidget);
      expect(returned?.completedModuleIds, contains(modules.first.id));
      expect(returned?.masteryByModuleId[modules.first.id], 100);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });

    for (final size in _sizes) {
      testWidgets(
          '${locale.code}: module retries and navigation at ${size.width} large text',
          (tester) async {
        final oldHandler = FlutterError.onError;
        FlutterError.onError = (details) {
          debugPrint(details.toString());
          oldHandler?.call(details);
        };
        addTearDown(() => FlutterError.onError = oldHandler);
        final state = await _guest(tester, locale);
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        final module = modules.first;
        final localized = modules
            .map((item) =>
                LessonContentLocalization.localizeModule(item, locale.code))
            .toList();
        final challenges = buildCurriculumChallenges(
          module: localized.first,
          allModules: localized,
          locale: locale.code,
        );
        await _open(tester, state, module, modules, textScale: 1.5);
        await _tap(tester, _action);
        await _tap(tester, _action);
        _assertActionEnabled(tester, false);

        // Incorrect answer cannot advance; correction is required.
        await _answer(tester, (challenges.first.correctIndex + 1) % 4);
        await _tap(tester, _action);
        await _tap(tester, _action);
        _assertActionEnabled(tester, false);
        await _solve(tester, challenges.first);
        await _solve(tester, challenges[1]);
        _assertActionEnabled(tester, false);

        // Wrong ordering, then explicit reset, then a correct chain.
        for (final index in [2, 0, 1]) {
          await _tap(tester, ValueKey('curriculum-practice-$index'));
        }
        _assertActionEnabled(tester, false);
        await _tap(tester, const ValueKey('curriculum-practice-reset'));
        for (var index = 0; index < 3; index++) {
          await _tap(tester, ValueKey('curriculum-practice-$index'));
        }
        await _tap(tester, _action);

        // Two failed final answers reduce the score below the pass mark.
        for (var attempt = 0; attempt < 2; attempt++) {
          await _answer(tester, (challenges[2].correctIndex + 1) % 4);
          await _tap(tester, _action);
          await _tap(tester, _action);
        }
        for (final challenge in challenges.skip(2)) {
          await _solve(tester, challenge);
        }
        expect(find.byKey(const ValueKey('curriculum-complete')), findsNothing);
        expect(find.byKey(const ValueKey('curriculum-assessment-retry')),
            findsOneWidget);
        expect(
            (await CurriculumProgressService.load(state.user!.id))
                .completedCount,
            0);
        await _tap(tester, const ValueKey('curriculum-assessment-retry'));
        for (final challenge in challenges.skip(2)) {
          await _solve(tester, challenge);
        }
        expect(
            find.byKey(const ValueKey('curriculum-complete')), findsOneWidget);
        await _tap(tester, const ValueKey('curriculum-repeat-module'));
        expect(
            find.byKey(const ValueKey('curriculum-stage-0')), findsOneWidget);
        expect(
            (await CurriculumProgressService.load(state.user!.id))
                .completedCount,
            1);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();

        // Returning to a completed module shows completion without adding progress.
        await _open(tester, state, module, modules, textScale: 1.5);
        expect(
            find.byKey(const ValueKey('curriculum-complete')), findsOneWidget);
        await _tap(tester, const ValueKey('curriculum-next-module'));
        expect(
            find.byKey(const ValueKey('curriculum-stage-0')), findsOneWidget);
        expect(find.text(modules[1].id),
            findsNothing); // header includes strand too
        expect(find.textContaining('${modules[1].id} ·'), findsOneWidget);
        expect(tester.takeException(), isNull);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
        state.dispose();
      });
    }
  }

  testWidgets('changing language resets choices but keeps the current stage',
      (tester) async {
    final state = await _guest(tester, AppLocale.ru);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _open(tester, state, modules.first, modules);
    await _tap(tester, _action);
    await _tap(tester, _action);
    await _answer(tester, 0);
    _assertActionEnabled(tester, true);
    await state.setLocale(AppLocale.en);
    await tester.pump();
    expect(find.byKey(const ValueKey('curriculum-stage-2')), findsOneWidget);
    _assertActionEnabled(tester, false);
    final englishModules = modules
        .map((module) => LessonContentLocalization.localizeModule(module, 'en'))
        .toList();
    final challenges = buildCurriculumChallenges(
      module: englishModules.first,
      allModules: englishModules,
      locale: 'en',
    );
    for (final challenge in challenges.take(2)) {
      await _solve(tester, challenge);
    }
    expect(find.byKey(const ValueKey('curriculum-stage-3')), findsOneWidget);
    await _tap(tester, const ValueKey('curriculum-practice-0'));
    await state.setLocale(AppLocale.kk);
    await tester.pump();
    for (var index = 0; index < 3; index++) {
      await _tap(tester, ValueKey('curriculum-practice-$index'));
    }
    _assertActionEnabled(tester, true);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets(
      'incomplete modules resume at the saved stage after exit/re-entry',
      (tester) async {
    final state = await _guest(tester, AppLocale.ru);
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _open(tester, state, modules.first, modules);
    await _tap(tester, _action);
    await _tap(tester, _action);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await _open(tester, state, modules.first, modules);
    expect(find.byKey(const ValueKey('curriculum-stage-2')), findsOneWidget);
    _assertActionEnabled(tester, false);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}

Future<AppState> _guest(WidgetTester tester, AppLocale locale) async {
  SharedPreferences.setMockInitialValues({});
  final state = AppState();
  await tester.runAsync(() async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    expect(state.isInitialized, isTrue);
    await state.loginAsGuest();
    await state.setLocale(locale);
  });
  return state;
}

Future<void> _open(WidgetTester tester, AppState state, CurriculumModule module,
    List<CurriculumModule> modules,
    {double textScale = 1}) async {
  await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
    value: state,
    child: MaterialApp(
      locale: state.locale.toLocale(),
      supportedLocales: testSupportedLocales,
      localizationsDelegates: testLocalizationDelegates,
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(textScale)),
        child: child!,
      ),
      home: CurriculumModuleScreen(
          module: module, modulesFuture: Future.value(modules)),
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => CurriculumModuleScreen(
          module: settings.arguments! as CurriculumModule,
          modulesFuture: Future.value(modules),
        ),
      ),
    ),
  ));
  await tester.pumpAndSettle();
  expect(Directionality.of(tester.element(find.byType(CurriculumModuleScreen))),
      state.locale.isRtl ? TextDirection.rtl : TextDirection.ltr);
  expect(tester.takeException(), isNull, reason: '${module.id} opening');
}

Future<void> _completeModule(WidgetTester tester,
    List<CurriculumChallenge> challenges, String id) async {
  await _tap(tester, _action);
  await _tap(tester, _action);
  for (final challenge in challenges.take(2)) {
    await _solve(tester, challenge);
  }
  for (var index = 0; index < 3; index++) {
    await _tap(tester, ValueKey('curriculum-practice-$index'));
  }
  await _tap(tester, _action);
  for (final challenge in challenges.skip(2)) {
    await _solve(tester, challenge);
  }
  expect(find.byKey(const ValueKey('curriculum-complete')), findsOneWidget,
      reason: id);
  expect(tester.takeException(), isNull, reason: '$id completion');
}

void _assertActionEnabled(WidgetTester tester, bool enabled) {
  expect(tester.widget<PremiumButton>(find.byKey(_action)).onPressed != null,
      enabled);
}

Future<void> _answer(WidgetTester tester, int index) =>
    _tap(tester, ValueKey('curriculum-answer-$index'));

Future<void> _solve(WidgetTester tester, CurriculumChallenge challenge) async {
  await _answer(tester, challenge.correctIndex);
  await _tap(tester, _action);
  await _tap(tester, _action);
}

Future<void> _tap(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget, reason: 'Missing $key');
  await Scrollable.ensureVisible(finder.evaluate().single, alignment: 0.5);
  await tester.pump();
  expect(finder.hitTestable(), findsOneWidget,
      reason: '$key must be reachable');
  await tester.tap(finder.hitTestable());
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 400));
  expect(tester.takeException(), isNull, reason: 'After $key');
}
