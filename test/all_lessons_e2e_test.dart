import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/models/speech_evaluation.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/lesson_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  for (final course in LessonData.getCourses()) {
    testWidgets(
      '${course.title}: каждый шаг каждого урока можно пройти до результата',
      (tester) async {
        tester.view.physicalSize = const Size(402, 874);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        final state = await _guestState(tester);
        for (final lesson in course.lessons) {
          await _pumpLesson(tester, state, lesson);

          for (var stepIndex = 0;
              stepIndex < lesson.steps.length;
              stepIndex++) {
            final step = lesson.steps[stepIndex];
            await _completeStep(tester, step);
            expect(
              tester.takeException(),
              isNull,
              reason:
                  '${course.id}/${lesson.id}, шаг $stepIndex (${step.type.name})',
            );
          }

          await tester.pumpAndSettle(const Duration(milliseconds: 100));
          expect(
            find.byKey(const ValueKey('lesson_review_route')),
            findsOneWidget,
            reason: '${course.id}/${lesson.id} не открыл итог урока',
          );
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        }
      },
    );
  }
}

Future<AppState> _guestState(WidgetTester tester) async {
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

Future<void> _pumpLesson(
  WidgetTester tester,
  AppState state,
  Lesson lesson,
) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        home: LessonScreen(
          lesson: lesson,
          speechSimulator: _simulatePerfectPronunciation,
        ),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          settings: settings,
          builder: (_) => const Scaffold(
            key: ValueKey('lesson_review_route'),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
}

Future<void> _completeStep(WidgetTester tester, LessonStep step) async {
  switch (step.type) {
    case LessonStepType.audio:
    case LessonStepType.text:
      await _tap(tester, const ValueKey('lesson_primary_action'));
      return;
    case LessonStepType.question:
    case LessonStepType.listenChoice:
      await _tap(
        tester,
        ValueKey('lesson_answer_${step.correctAnswerIndex}'),
      );
      await _tap(tester, const ValueKey('lesson_primary_action'));
      await _tap(tester, const ValueKey('lesson_primary_action'));
      return;
    case LessonStepType.matching:
      for (var pairIndex = 0; pairIndex < step.matchPairs.length; pairIndex++) {
        await _tap(
          tester,
          ValueKey('lesson_match_prompt_$pairIndex'),
        );
        await _tap(
          tester,
          ValueKey('lesson_match_answer_$pairIndex'),
        );
      }
      await _tap(tester, const ValueKey('lesson_primary_action'));
      return;
    case LessonStepType.wordOrder:
      final bank = wordOrderBank(step);
      final used = <int>{};
      for (final token in step.orderTokens) {
        final resolvedIndex = _firstUnusedTokenIndex(bank, token, used);
        expect(
          resolvedIndex,
          isNonNegative,
          reason: 'Слово "$token" отсутствует в банке шага ${step.id}',
        );
        used.add(resolvedIndex);
        await _tap(
          tester,
          ValueKey('lesson_order_bank_$resolvedIndex'),
        );
      }
      await _tap(tester, const ValueKey('lesson_primary_action'));
      await _tap(tester, const ValueKey('lesson_primary_action'));
      return;
    case LessonStepType.speak:
      await _tap(tester, const ValueKey('lesson_speech_sample'));
      await _tap(tester, const ValueKey('lesson_speech_record'));
      await _tap(tester, const ValueKey('lesson_primary_action'));
      return;
  }
}

int _firstUnusedTokenIndex(List<String> bank, String token, Set<int> used) {
  for (var index = 0; index < bank.length; index++) {
    if (bank[index] == token && !used.contains(index)) return index;
  }
  return -1;
}

Future<void> _tap(WidgetTester tester, Key key) async {
  final finder = find.byKey(key);
  expect(finder, findsOneWidget, reason: 'Не найден элемент $key');
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
  await tester.pump(const Duration(milliseconds: 450));
}

Future<SpeechEvaluationResult> _simulatePerfectPronunciation(
  LessonStep step,
) async {
  final target = step.effectiveSpeechTarget;
  return SpeechEvaluationResult(
    transcript: target,
    normalizedTranscript: target,
    target: target,
    score: 100,
    passed: true,
    weakParts: const [],
    feedbackText: 'Произношение принято.',
    engine: SpeechEvaluationEngine.ai,
    fallbackUsed: false,
  );
}
