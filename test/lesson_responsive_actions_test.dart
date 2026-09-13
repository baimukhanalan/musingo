import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const lesson = Lesson(
    id: 'responsive_actions',
    title: 'Проверка адаптивности',
    subtitle: 'Все действия доступны',
    course: CourseType.rules,
    order: 999,
    steps: [
      LessonStep(
        id: 'responsive_question',
        type: LessonStepType.question,
        question: 'Какой из четырёх длинных вариантов является правильным?',
        answers: [
          'Первый развёрнутый вариант ответа для проверки высоты карточки',
          'Второй развёрнутый вариант ответа для проверки высоты карточки',
          'Третий развёрнутый вариант ответа для проверки высоты карточки',
          'Четвёртый развёрнутый вариант ответа для проверки высоты карточки',
        ],
        correctAnswerIndex: 3,
      ),
    ],
  );

  for (final size in [
    const Size(320, 568),
    const Size(390, 844),
    const Size(844, 390),
  ]) {
    testWidgets(
        'all lesson actions stay reachable at ${size.width}x${size.height}',
        (tester) async {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      SharedPreferences.setMockInitialValues({});

      final state = AppState();
      await tester.runAsync(() async {
        while (!state.isInitialized) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        await state.loginAsGuest();
      });

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: const MaterialApp(home: LessonScreen(lesson: lesson)),
        ),
      );
      await tester.pump();
      expect(tester.takeException(), isNull, reason: 'initial layout at $size');

      final lastAnswer = find.byKey(const ValueKey('lesson_answer_3'));
      final lessonScroll = find.byType(SingleChildScrollView);
      expect(lessonScroll, findsOneWidget);
      for (var i = 0;
          i < 5 && lastAnswer.hitTestable().evaluate().isEmpty;
          i++) {
        await tester.drag(lessonScroll, const Offset(0, -180));
        await tester.pump(const Duration(milliseconds: 120));
      }
      expect(lastAnswer, findsOneWidget);
      expect(lastAnswer.hitTestable(), findsOneWidget);
      await tester.tap(lastAnswer);
      await tester.pump();
      expect(tester.takeException(), isNull,
          reason: 'selected layout at $size');

      final action = find.byKey(const ValueKey('lesson_primary_action'));
      expect(action.hitTestable(), findsOneWidget);
      await tester.tap(action);
      await tester.pump(const Duration(milliseconds: 300));

      expect(find.text('Верно!'), findsOneWidget);
      expect(tester.takeException(), isNull,
          reason: 'feedback layout at $size');

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump(const Duration(seconds: 1));
    });
  }
}
