import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/models/speech_evaluation.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/utils/theme.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppState> guestState(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    expect(state.isInitialized, isTrue);
    await state.loginAsGuest();
    return state;
  }

  Future<void> pumpLesson(
    WidgetTester tester,
    AppState state,
    Lesson lesson, {
    Future<SpeechEvaluationResult> Function(LessonStep step)? simulator,
  }) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          theme: AppTheme.light,
          home: LessonScreen(lesson: lesson, speechSimulator: simulator),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('mixed Russian and Arabic lesson text inherits Amiri fallback',
      (tester) async {
    const question =
        'Как переводится «بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ»?';
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.light,
        home: const Scaffold(
          body: Text(
            question,
            style: TextStyle(fontFamily: 'Nunito'),
          ),
        ),
      ),
    );

    final finder = find.text(question);
    expect(finder, findsOneWidget);
    final text = tester.widget<Text>(finder);
    final inherited = DefaultTextStyle.of(tester.element(finder)).style;
    final effectiveStyle = inherited.merge(text.style);
    expect(effectiveStyle.fontFamily, 'Nunito');
    expect(effectiveStyle.fontFamilyFallback, contains('Amiri'));
  });

  testWidgets('successful pronunciation can be recorded again', (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = await guestState(tester);
    var attempts = 0;
    const arabic = 'بِسْمِ اللَّهِ';
    const lesson = Lesson(
      id: 'speech_retry_test',
      title: 'Произношение',
      subtitle: 'Проверка повторной записи',
      course: CourseType.quran,
      order: 1,
      steps: [
        LessonStep(
          id: 'speech_retry',
          type: LessonStepType.speak,
          arabicText: arabic,
          transliteration: 'Bismillah',
        ),
      ],
    );

    Future<SpeechEvaluationResult> simulator(LessonStep step) async {
      attempts++;
      return const SpeechEvaluationResult(
        transcript: arabic,
        normalizedTranscript: arabic,
        target: arabic,
        score: 100,
        passed: true,
        weakParts: [],
        feedbackText: 'Произношение принято.',
        engine: SpeechEvaluationEngine.ai,
        fallbackUsed: false,
      );
    }

    await pumpLesson(tester, state, lesson, simulator: simulator);
    final sample = find.byKey(const ValueKey('lesson_speech_sample'));
    await tester.ensureVisible(sample);
    await tester.tap(sample);
    await tester.pump();
    final record = find.byKey(const ValueKey('lesson_speech_record'));
    await tester.ensureVisible(record);
    await tester.pump();
    await tester.tap(record);
    await tester.pump();

    expect(attempts, 1);
    expect(find.text('Распознано: $arabic'), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson_speech_retry')), findsOneWidget);

    final retry = find.byKey(const ValueKey('lesson_speech_retry'));
    await tester.ensureVisible(retry);
    await tester.pump();
    await tester.tap(retry);
    await tester.pump();

    expect(attempts, 2);
    expect(find.text('Распознано: $arabic'), findsOneWidget);
    expect(find.byKey(const ValueKey('lesson_speech_retry')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
