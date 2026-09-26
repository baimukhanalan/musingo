import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('rapid final taps complete and reward a lesson only once',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
    });

    const lesson = Lesson(
      // Exercise the UI with a minimal fixture using a registered lesson ID;
      // unknown IDs are now deliberately rejected by AppState.
      id: 'r1',
      title: 'Completion guard',
      subtitle: 'One step',
      course: CourseType.rules,
      order: 999,
      xpReward: 25,
      steps: [LessonStep(type: LessonStepType.text, russianText: 'Готово')],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: const LessonScreen(lesson: lesson),
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

    final action = find.byKey(const ValueKey('lesson_primary_action'));
    await tester.tap(action);
    await tester.tap(action);
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey('lesson_review_route')), findsOneWidget);
    expect(state.user?.totalLessons, 1);
    expect(state.user?.xp, 25);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    state.dispose();
  });

  testWidgets('rapid check taps deduct only one heart', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await _readyGuest(tester, state);
    await tester.pumpWidget(_questionLessonApp(state));
    await tester.pump();

    await tester.tap(find.byKey(const ValueKey('lesson_answer_0')));
    await tester.pump();
    final action = find.byKey(const ValueKey('lesson_primary_action'));
    await tester.tap(action);
    await tester.tap(action);
    await tester.pump();

    expect(state.user?.hearts, 4);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    state.dispose();
  });

  testWidgets('a wrong review answer repeats review before completion',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await _readyGuest(tester, state);
    await tester.pumpWidget(_questionLessonApp(state));
    await tester.pump();

    Future<void> answer(int index) async {
      await tester.tap(find.byKey(ValueKey('lesson_answer_$index')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('lesson_primary_action')));
      await tester.pump();
      await tester.tap(find.byKey(const ValueKey('lesson_primary_action')));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 500));
    }

    await answer(0);
    expect(find.byKey(const ValueKey('lesson_review_route')), findsNothing);
    await answer(0);
    expect(find.byKey(const ValueKey('lesson_review_route')), findsNothing);
    await answer(1);
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 2));
      while ((state.user?.totalLessons ?? 0) == 0 &&
          DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 20));
      }
    });
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('lesson_review_route')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    await tester.pump(const Duration(seconds: 2));
    state.dispose();
  });

  testWidgets('system back asks before abandoning a lesson', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await _readyGuest(tester, state);
    await tester.pumpWidget(_questionLessonApp(state));
    await tester.pump();

    await tester.binding.handlePopRoute();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Выйти из урока?'), findsOneWidget);
    expect(find.text('Остаться'), findsOneWidget);
    await tester.tap(find.text('Остаться'));
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.byKey(const ValueKey('lesson_primary_action')), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}

Future<void> _readyGuest(WidgetTester tester, AppState state) async {
  await tester.runAsync(() async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await state.loginAsGuest();
  });
}

Widget _questionLessonApp(AppState state) {
  const lesson = Lesson(
    id: 'r1',
    title: 'Question guard',
    subtitle: 'One step',
    course: CourseType.rules,
    order: 998,
    xpReward: 25,
    steps: [
      LessonStep(
        type: LessonStepType.question,
        russianText: 'Выбери правильный ответ',
        answers: ['Неверно', 'Верно'],
        correctAnswerIndex: 1,
      ),
    ],
  );
  return ChangeNotifierProvider<AppState>.value(
    value: state,
    child: MaterialApp(
      home: const LessonScreen(lesson: lesson),
      onGenerateRoute: (settings) => MaterialPageRoute<void>(
        settings: settings,
        builder: (_) => const Scaffold(key: ValueKey('lesson_review_route')),
      ),
    ),
  );
}
