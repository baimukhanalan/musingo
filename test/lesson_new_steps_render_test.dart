import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/lesson_data.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Новые типы шагов (wordOrder и listenChoice) проверяются именно РЕНДЕРОМ
/// экрана урока: анализатор и юнит-тесты не поймают залоченную кнопку
/// «Проверить» или шаг, который невозможно пройти.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppState> guestState(WidgetTester tester) async {
    SharedPreferences.resetStatic();
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
      WidgetTester tester, AppState state, Lesson lesson) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: LessonScreen(lesson: lesson),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  const wordOrderStep = LessonStep(
    id: 'test_word_order',
    type: LessonStepType.wordOrder,
    question: 'Собери аят',
    russianText: 'Разве Мы не сделали землю ложем',
    orderTokens: ['أَلَمْ', 'نَجْعَلِ', 'الْأَرْضَ', 'مِهَٰدًۭا'],
    extraTokens: ['أَوْتَادًۭا'],
  );

  const listenStep = LessonStep(
    id: 'test_listen',
    type: LessonStepType.listenChoice,
    quranGlobalAyahNumber: 5673,
    arabicText: 'عَمَّ يَتَسَآءَلُونَ',
    question: 'Прослушай аят и выбери его перевод',
    answers: [
      'О чём они расспрашивают друг друга?',
      'Клянусь небом и ночным путником',
      'Разве Мы не сделали землю ложем?',
    ],
    correctAnswerIndex: 0,
  );

  Lesson lessonWith(LessonStep step) => Lesson(
        id: 'test_lesson',
        title: 'Тестовый урок',
        subtitle: 'Только для проверки шага',
        course: CourseType.quran,
        order: 999,
        steps: [step],
      );

  testWidgets(
      'wordOrder: банк слов рендерится, «Проверить» открывается только после сборки',
      (tester) async {
    final state = await guestState(tester);
    await pumpLesson(tester, state, lessonWith(wordOrderStep));

    expect(tester.takeException(), isNull);
    expect(find.text('Собери аят'), findsOneWidget);
    // Пять слов банка: четыре из ответа + дистрактор.
    for (final token in wordOrderStep.wordBank) {
      expect(find.text(token), findsWidgets, reason: 'нет слова банка $token');
    }

    final checkButton = find.widgetWithText(GestureDetector, 'Проверить');
    expect(checkButton, findsWidgets);

    // Пока фраза не собрана — кнопка залочена (onTap == null).
    GestureDetector button = tester.widget<GestureDetector>(checkButton.first);
    expect(button.onTap, isNull, reason: 'гейт должен быть закрыт до сборки');

    // Собираем ответ в правильном порядке.
    final bank = wordOrderBank(wordOrderStep);
    for (final token in wordOrderStep.orderTokens) {
      final bankIndex = bank.indexOf(token);
      final chip = find.byKey(ValueKey('lesson_order_bank_$bankIndex'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pump();
    }

    button = tester.widget<GestureDetector>(
        find.widgetWithText(GestureDetector, 'Проверить').first);
    expect(button.onTap, isNotNull,
        reason: 'после сборки гейт должен открыться');

    // Проверяем правильный ответ — экран даёт короткую понятную обратную связь.
    await tester.tap(find.widgetWithText(GestureDetector, 'Проверить').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Верно!'), findsOneWidget);
    expect(find.text('Задача шага'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets(
      'wordOrder: неверный порядок засчитывается ошибкой и показывает эталон',
      (tester) async {
    final state = await guestState(tester);
    await pumpLesson(tester, state, lessonWith(wordOrderStep));

    // Собираем задом наперёд — порядок заведомо неверный.
    final bank = wordOrderBank(wordOrderStep);
    for (final token in wordOrderStep.orderTokens.reversed) {
      final bankIndex = bank.indexOf(token);
      final chip = find.byKey(ValueKey('lesson_order_bank_$bankIndex'));
      await tester.ensureVisible(chip);
      await tester.tap(chip);
      await tester.pump();
    }
    await tester.tap(find.widgetWithText(GestureDetector, 'Проверить').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Разберём ответ'), findsOneWidget);
    expect(find.textContaining('Верный порядок'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('listenChoice: кнопка воспроизведения и варианты, гейт по выбору',
      (tester) async {
    final state = await guestState(tester);
    await pumpLesson(tester, state, lessonWith(listenStep));

    expect(tester.takeException(), isNull);
    expect(find.text('Прослушай аят и выбери его перевод'), findsOneWidget);
    expect(find.text('Нажми, чтобы прослушать'), findsOneWidget);
    expect(find.byIcon(Icons.volume_up_rounded), findsOneWidget);
    // Арабский текст аята не показан — иначе аудирование теряет смысл.
    expect(find.text(listenStep.arabicText!), findsNothing);
    for (final answer in listenStep.answers!) {
      expect(find.text(answer), findsOneWidget);
    }
    expect(
      find.text('Варианты откроются после прослушивания.'),
      findsOneWidget,
    );

    GestureDetector button = tester.widget<GestureDetector>(
        find.widgetWithText(GestureDetector, 'Проверить').first);
    expect(button.onTap, isNull, reason: 'без выбора варианта гейт закрыт');

    // До прослушивания выбор заблокирован.
    await tester.ensureVisible(find.text(listenStep.answers!.first));
    await tester.pump();
    await tester.tap(find.text(listenStep.answers!.first));
    await tester.pump();

    button = tester.widget<GestureDetector>(
        find.widgetWithText(GestureDetector, 'Проверить').first);
    expect(button.onTap, isNull);

    await tester.ensureVisible(
      find.byKey(const ValueKey('lesson_listen_play')),
    );
    await tester.tap(find.byKey(const ValueKey('lesson_listen_play')));
    await tester.pump();
    expect(
      find.text('Варианты откроются после прослушивания.'),
      findsNothing,
    );

    await tester.ensureVisible(find.text(listenStep.answers!.first));
    await tester.tap(find.text(listenStep.answers!.first));
    await tester.pump();

    button = tester.widget<GestureDetector>(
        find.widgetWithText(GestureDetector, 'Проверить').first);
    expect(button.onTap, isNotNull);

    await tester.tap(find.widgetWithText(GestureDetector, 'Проверить').first);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Верно!'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('logic challenge: four close options fit a mobile lesson flow',
      (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = await guestState(tester);
    final challenge = LessonData.rulesCourse.lessons.first.steps.firstWhere(
      (step) => step.id == 'r1_logic_challenge',
    );
    await pumpLesson(tester, state, lessonWith(challenge));

    expect(tester.takeException(), isNull);
    expect(find.textContaining('Два вывода одновременно'), findsOneWidget);
    expect(challenge.answers, hasLength(4));

    final correct = find.text(challenge.answers!.first);
    await tester.ensureVisible(correct);
    await tester.tap(correct);
    await tester.pump();
    await tester.tap(find.widgetWithText(GestureDetector, 'Проверить').first);
    await tester.pump(const Duration(milliseconds: 300));

    expect(tester.takeException(), isNull);
    expect(find.text('Верно!'), findsOneWidget);
    await teardown(tester);
  });
}
