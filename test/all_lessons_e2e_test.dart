import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/models/speech_evaluation.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/lesson_data.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/utils/app_locale.dart';

import 'support/exhaustive_audit.dart';
import 'support/localization_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(LessonContentLocalization.load);

  for (final locale in AppLocale.values) {
    for (final course in LessonData.getCourses()) {
      testWidgets(
        '${locale.code}/${course.id}: ${locale == AppLocale.ru || exhaustiveAudit ? 'every' : 'representative'} lesson reaches review with replay controls',
        (tester) async {
          final oldHandler = FlutterError.onError;
          FlutterError.onError = (details) {
            debugPrint(details.toString());
            oldHandler?.call(details);
          };
          addTearDown(() => FlutterError.onError = oldHandler);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.resetPhysicalSize);
          addTearDown(tester.view.resetDevicePixelRatio);

          final state = await _guestState(tester);
          await state.setLocale(locale);
          final lessons = LessonContentLocalization.localizeCourses(
            // AppState has now loaded the canonical full-Quran asset. Do not
            // retain the smaller pre-initialization registry from test setup.
            [state.getCourse(course.type)!],
            locale.code,
          ).single.lessons;
          for (final lessonIndex in lessonAuditIndices(lessons, locale.code)) {
            final lesson = lessons[lessonIndex];
            tester.view.physicalSize = const [
              Size(320, 568),
              Size(390, 844),
              Size(430, 932),
            ][(lessonIndex + locale.index) % 3];
            await _pumpLesson(
              tester,
              state,
              lesson,
              textScale: lessonIndex % 7 == 0 ? 1.3 : 1,
            );

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
          state.dispose();
        },
        timeout: const Timeout(Duration(minutes: 12)),
      );
    }
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
  Lesson lesson, {
  double textScale = 1,
}) async {
  await tester.pumpWidget(
    ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        locale: state.locale.toLocale(),
        supportedLocales: testSupportedLocales,
        localizationsDelegates: testLocalizationDelegates,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
          ),
          child: child!,
        ),
        home: LessonScreen(
          lesson: lesson,
          speechSimulator: _simulatePerfectPronunciation,
          // This proves UI sequencing only, not remote media availability.
          audioPlaybackSimulator: (_) async {},
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
  expect(Directionality.of(tester.element(find.byType(LessonScreen))),
      state.locale.isRtl ? TextDirection.rtl : TextDirection.ltr);
}

Future<void> _completeStep(WidgetTester tester, LessonStep step) async {
  switch (step.type) {
    case LessonStepType.audio:
      await _tap(tester, const ValueKey('lesson_audio_play'));
      await _tap(tester, const ValueKey('lesson_audio_play'));
      await _tap(tester, const ValueKey('lesson_primary_action'));
      return;
    case LessonStepType.text:
      await _tap(tester, const ValueKey('lesson_primary_action'));
      return;
    case LessonStepType.question:
      await _tap(
        tester,
        ValueKey('lesson_answer_${step.correctAnswerIndex}'),
      );
      await _tap(tester, const ValueKey('lesson_primary_action'));
      await _tap(tester, const ValueKey('lesson_primary_action'));
      return;
    case LessonStepType.listenChoice:
      await _tap(tester, const ValueKey('lesson_listen_play'));
      await _tap(tester, const ValueKey('lesson_listen_play'));
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
  await Scrollable.ensureVisible(
    finder.evaluate().single,
    alignment: 0.5,
    duration: Duration.zero,
  );
  await tester.pump();
  for (var attempt = 0;
      attempt < 8 && finder.hitTestable().evaluate().isEmpty;
      attempt++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
  final hitTarget = finder.hitTestable();
  expect(hitTarget, findsOneWidget,
      reason: 'Элемент $key перекрыт интерфейсом');
  await tester.tap(hitTarget);
  // Первый кадр создаёт контроллеры перехода, второй доводит анимацию до
  // стабильного состояния. Иначе AnimatedSwitcher ещё держит старый шаг и
  // finder видит два одинаковых ключа из исходящего и входящего экранов.
  await tester.pump();
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
