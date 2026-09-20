import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/models/speech_evaluation.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/widgets/cat_character.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppState> mountLesson(
    WidgetTester tester,
    Lesson lesson, {
    Future<SpeechEvaluationResult> Function(LessonStep)? simulator,
  }) async {
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
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        home: LessonScreen(lesson: lesson, speechSimulator: simulator),
      ),
    ));
    await tester.pump();
    return state;
  }

  Future<void> tap(WidgetTester tester, String key) async {
    final control = find.byKey(ValueKey(key));
    await tester.ensureVisible(control);
    await tester.pump();
    await tester.tap(control);
    await tester.pump();
    // Allow the old mood to leave the outer lesson AnimatedSwitcher.
    await tester.pump(const Duration(milliseconds: 450));
  }

  CatCharacter mascot(WidgetTester tester) =>
      tester.widget<CatCharacter>(find.byType(CatCharacter));

  Future<void> disposeLesson(WidgetTester tester, AppState state) async {
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
    expect(tester.takeException(), isNull);
    state.dispose();
  }

  testWidgets('each matching mistake emits a fresh error reaction',
      (tester) async {
    const lesson = Lesson(
      id: 'matching_mascot_reactions',
      title: 'Matching reactions',
      subtitle: 'Repeated attempts',
      course: CourseType.arabic,
      order: 1,
      steps: [
        LessonStep(
          type: LessonStepType.matching,
          question: 'Match each pair',
          matchPairs: [
            LessonMatchPair(prompt: 'أ', answer: 'Alif'),
            LessonMatchPair(prompt: 'ب', answer: 'Ba'),
          ],
        ),
      ],
    );
    final state = await mountLesson(tester, lesson);
    await tap(tester, 'lesson_match_prompt_0');
    await tap(tester, 'lesson_match_answer_1');
    final first = mascot(tester);
    expect(first.mood, CatMood.error);
    expect(first.reactionId, isNotNull);
    await tester.pump(const Duration(seconds: 4));

    await tap(tester, 'lesson_match_prompt_0');
    await tap(tester, 'lesson_match_answer_1');
    final second = mascot(tester);
    expect(second.mood, CatMood.error);
    expect(second.reactionId, isNot(first.reactionId),
        reason: 'A second mistake must remain a distinct learner event');
    expect(state.user!.hearts, 3);

    for (var index = 0; index < 2; index++) {
      await tap(tester, 'lesson_match_prompt_$index');
      await tap(tester, 'lesson_match_answer_$index');
    }
    expect(mascot(tester).mood, CatMood.success);
    expect(mascot(tester).reactionId, isNot(second.reactionId));
    await disposeLesson(tester, state);
  });

  for (final passed in [true, false]) {
    testWidgets(
        'speech ${passed ? 'success' : 'failure'} triggers a new reaction on each attempt',
        (tester) async {
      const target = 'بِسْمِ اللَّهِ';
      const lesson = Lesson(
        id: 'speech_mascot_reactions',
        title: 'Speech reactions',
        subtitle: 'Repeated recordings',
        course: CourseType.quran,
        order: 1,
        steps: [
          LessonStep(
            type: LessonStepType.speak,
            arabicText: target,
            transliteration: 'Bismillah',
          ),
        ],
      );
      var attempts = 0;
      final state = await mountLesson(tester, lesson, simulator: (_) async {
        attempts++;
        return SpeechEvaluationResult(
          transcript: target,
          normalizedTranscript: target,
          target: target,
          score: passed ? 100 : 40,
          passed: passed,
          weakParts: passed ? [] : [target],
          feedbackText: passed ? 'Принято.' : 'Попробуй ещё раз.',
          engine: SpeechEvaluationEngine.ai,
          fallbackUsed: false,
        );
      });
      final initialReaction = mascot(tester).reactionId;
      await tap(tester, 'lesson_speech_sample');
      await tap(tester, 'lesson_speech_record');
      final first = mascot(tester);
      expect(first.mood, passed ? CatMood.success : CatMood.error);
      expect(first.reactionId, isNotNull);
      expect(first.reactionId, isNot(initialReaction));

      await tester.pump(const Duration(seconds: 4));
      await tap(tester, 'lesson_speech_retry');
      final second = mascot(tester);
      expect(attempts, 2);
      expect(second.mood, passed ? CatMood.success : CatMood.error);
      expect(second.reactionId, isNot(first.reactionId));
      await disposeLesson(tester, state);
    });
  }
}
