import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/curriculum_module.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/screens/continuous_audio_screen.dart';
import 'package:muslingo/screens/curriculum_library_screen.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
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
}
