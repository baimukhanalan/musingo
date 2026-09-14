import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/curriculum_module.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/screens/continuous_audio_screen.dart';
import 'package:muslingo/screens/curriculum_library_screen.dart';
import 'package:muslingo/screens/curriculum_module_screen.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/curriculum_progress_service.dart';
import 'package:muslingo/services/curriculum_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('bundled public curriculum contains all 570 modules', () async {
    CurriculumRepository.clearCacheForTesting();
    final modules = await CurriculumRepository.load();
    expect(modules, hasLength(570));
    expect(modules.map((module) => module.id).toSet(), hasLength(570));
    expect(modules.every((module) => module.sourceLocator.isNotEmpty), isTrue);
    expect(modules.every((module) => module.reviewStatus.isNotEmpty), isTrue);
    expect(
      modules.every(
        (module) => module.publicationStatus == 'published_owner_verified',
      ),
      isTrue,
    );
  });

  testWidgets('library and continuous audio mode render on a compact phone',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    CurriculumRepository.clearCacheForTesting();
    final state = AppState();
    late final List<CurriculumModule> modules;
    await tester.runAsync(() async {
      while (!state.isInitialized) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
      modules = await CurriculumRepository.load();
    });
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: CurriculumLibraryScreen(
            modulesFuture: Future.value(modules),
          ),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => ContinuousAudioScreen(
              modulesFuture: Future.value(modules),
            ),
          ),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Библиотека 570'), findsOneWidget);
    await tester.drag(
      find.byKey(const ValueKey('curriculum-scroll')),
      const Offset(0, -360),
    );
    await tester.pump();
    expect(
      find.byKey(const ValueKey('curriculum-module-QUR-001')),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);

    await tester.tap(find.byKey(const ValueKey('open-continuous-audio')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('Непрерывный аудиорежим'), findsOneWidget);
    expect(
        find.byKey(const ValueKey('continuous-audio-toggle')), findsOneWidget);
    expect(tester.takeException(), isNull);

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    state.dispose();
  });

  test('speech routing keeps Quran Arabic and enables Kazakh phrases', () {
    const quran = LessonStep(
      type: LessonStepType.speak,
      speechMode: SpeechMode.quran,
      speechTarget: 'بسم الله',
    );
    const phrase = LessonStep(
      type: LessonStepType.speak,
      speechMode: SpeechMode.phrase,
      speechTarget: 'Қайырлы күн',
    );
    expect(speechRecognitionLanguageCode(quran, 'kk'), 'ar');
    expect(speechRecognitionLanguageCode(phrase, 'kk'), 'kk');
  });

  test('all 570 modules build two unambiguous four-option challenges',
      () async {
    CurriculumRepository.clearCacheForTesting();
    final modules = await CurriculumRepository.load();
    for (final module in modules) {
      final objectiveOptions = curriculumChallengeOptions(
        module: module,
        allModules: modules,
        valueOf: (item) => item.objective,
      );
      final sourceOptions = curriculumChallengeOptions(
        module: module,
        allModules: modules,
        valueOf: (item) => curriculumSourceSummary(item.sourceLocator),
      );
      final correct = curriculumCorrectAnswerIndex(module);
      expect(objectiveOptions, hasLength(4), reason: module.id);
      expect(objectiveOptions.toSet(), hasLength(4), reason: module.id);
      expect(objectiveOptions[correct], module.objective, reason: module.id);
      expect(sourceOptions, hasLength(4), reason: module.id);
      expect(sourceOptions.toSet(), hasLength(4), reason: module.id);
      expect(
        sourceOptions[correct],
        curriculumSourceSummary(module.sourceLocator),
        reason: module.id,
      );
    }
  });

  testWidgets('a learner completes a five-stage curriculum module',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    CurriculumRepository.clearCacheForTesting();
    final state = AppState();
    late final List<CurriculumModule> modules;
    await tester.runAsync(() async {
      while (!state.isInitialized) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
      modules = await CurriculumRepository.load();
    });
    final module = modules.first;
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: CurriculumModuleScreen(
            module: module,
            modulesFuture: Future.value(modules),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Этап 1 из 5'), findsOneWidget);

    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Этап 2 из 5'), findsOneWidget);

    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Этап 3 из 5'), findsOneWidget);

    final correctIndex = module.sequence % 4;
    await tester.tap(
      find.byKey(ValueKey('curriculum-answer-$correctIndex')),
    );
    await tester.pump();
    await tester.tap(find.text('Проверить'));
    await tester.pump();
    expect(find.textContaining('Верно.'), findsOneWidget);
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();

    for (var index = 0; index < 3; index++) {
      await tester.tap(
        find.byKey(ValueKey('curriculum-practice-$index')),
      );
    }
    await tester.pump();
    await tester.tap(find.text('Продолжить'));
    await tester.pumpAndSettle();
    expect(find.text('Этап 5 из 5'), findsOneWidget);

    await tester.tap(
      find.byKey(ValueKey('curriculum-answer-$correctIndex')),
    );
    await tester.pump();
    await tester.tap(find.text('Проверить'));
    await tester.pump();
    await tester.tap(find.text('Завершить модуль'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('curriculum-complete')), findsOneWidget);
    expect(find.text('1/570'), findsOneWidget);

    final saved = await CurriculumProgressService.load(state.user!.id);
    expect(saved.completedModuleIds, contains(module.id));
    expect(saved.masteryByModuleId[module.id], 100);
    expect(tester.takeException(), isNull);

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    state.dispose();
  });
}
