import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:muslingo/main.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/backend_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  // ------------------------------------------------------------------ M2
  group('Дневной прогресс считает СЕГОДНЯ (локальный путь)', () {
    test('в новый календарный день dailyProgress начинается заново', () async {
      final state = await _guestState();
      final quran = state.getCourse(CourseType.quran)!;
      final l1 = quran.lessons[0].id;
      final l2 = quran.lessons[1].id;
      final l3 = quran.lessons[2].id;

      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final today = DateTime.now();

      // Два урока вчера — прогресс за вчера накапливается.
      await state.completeLesson(l1, 0, completedAt: yesterday);
      expect(state.user?.dailyProgress, 1);
      await state.completeLesson(l2, 0, completedAt: yesterday);
      expect(state.user?.dailyProgress, 2);

      // Первый урок нового дня — прогресс за день обнуляется до 1, а не 3.
      await state.completeLesson(l3, 0, completedAt: today);
      expect(state.user?.dailyProgress, 1);
      // Согласовано с геттером todayProgress (последнее занятие — сегодня).
      expect(state.todayProgress, 1);
    });

    test('внутри одного дня dailyProgress растёт с потолком dailyGoal',
        () async {
      final state = await _guestState();
      final quran = state.getCourse(CourseType.quran)!;
      final today = DateTime.now();
      final goal = state.dailyGoal;

      // Проходим уроков больше дневной цели — прогресс упирается в потолок.
      for (var i = 0; i < goal + 2; i++) {
        await state.completeLesson(
          quran.lessons[i].id,
          0,
          completedAt: today.copyWith(hour: 8 + i),
        );
      }
      expect(state.user?.dailyProgress, goal);
      expect(state.todayProgress, goal);
    });
  });

  // ------------------------------------------------------------------ M3
  group('Стрик-бонус начисляется один раз в день', () {
    test('повторный урок в день-milestone даёт streakBonus 0', () async {
      final state = await _guestState();
      final quran = state.getCourse(CourseType.quran)!;
      final ids = quran.lessons.map((lesson) => lesson.id).toList();
      final base = DateTime(2026, 8, 1, 10);

      // Семь дней подряд — на седьмой стрик достигает 7 и даёт бонус +10 один раз.
      Map<String, dynamic> milestone = const {};
      for (var day = 0; day < 7; day++) {
        milestone = await state.completeLesson(
          ids[day % ids.length],
          0,
          completedAt: base.add(Duration(days: day)),
        );
      }
      expect(milestone['newStreak'], 7);
      expect(milestone['streakBonus'], 10);

      // Второй урок в тот же седьмой день: стрик не вырос — бонуса больше нет.
      final repeat = await state.completeLesson(
        ids[0],
        0,
        completedAt: base.add(const Duration(days: 6, hours: 6)),
      );
      expect(repeat['newStreak'], 7);
      expect(repeat['streakBonus'], 0);
    });
  });

  // ------------------------------------------------------------------ C1
  group('errors клампится 0..5 перед отправкой на сервер', () {
    test('completeLesson с errors=9 шлёт errors=5 (не ловит 400)', () async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({
        'muslingo_auth_token': 'test-token',
      });

      Map<String, dynamic>? sentBody;
      final client = MockClient((request) async {
        sentBody = jsonDecode(request.body) as Map<String, dynamic>;
        return http.Response(
          jsonEncode({
            'progress': <String, dynamic>{},
            'xpEarned': 25,
            'streakBonus': 0,
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      });

      final backend = await BackendService.create(client: client);
      await backend.completeLesson('q_ikhlas_1', 9, 0, 'q:practice:1');

      // Сервер валидирует {min:0,max:5} и бросил бы 400 на 9 — клиент клампит.
      expect(sentBody?['errors'], 5);
    });
  });

  // ------------------------------------------------------------------ M3b
  group('learnedAyats не растёт на повторе урока (гостевой путь)', () {
    test('первый проход даёт аяты, повтор — +0', () async {
      final state = await _guestState();
      final quran = state.getCourse(CourseType.quran)!;
      final lessonId = quran.lessons[0].id;

      final before = state.user!.learnedAyats;
      await state.completeLesson(lessonId, 0);
      final afterFirst = state.user!.learnedAyats;
      // Первый проход quran-урока начисляет аяты (число различных аятов урока).
      expect(afterFirst, greaterThan(before));

      // Повтор того же урока не должен растить learnedAyats.
      await state.completeLesson(lessonId, 0);
      expect(state.user!.learnedAyats, afterFirst);
    });
  });

  // ------------------------------------------------------------------ M4
  group('Мягкий лок жизней при возврате в приложение', () {
    testWidgets('resumed дергает пересчёт жизней и не падает',
        (WidgetTester tester) async {
      await tester.pumpWidget(const MuslingoApp());

      // Возврат приложения на передний план должен пройти без исключений и
      // дернуть регенерацию жизней (наблюдатель жизненного цикла в MuslingoApp).
      tester.binding
          .handleAppLifecycleStateChanged(AppLifecycleState.inactive);
      tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
      await tester.pump();

      expect(tester.takeException(), isNull);

      await _teardown(tester);
    });
  });
}

Future<AppState> _guestState() async {
  final state = AppState();
  await _waitUntilInitialized(state);
  await state.loginAsGuest();
  return state;
}

Future<void> _waitUntilInitialized(AppState state) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(state.isInitialized, isTrue);
}

/// Гасит сплэш-анимацию и снимает дерево, иначе pending Timer/AnimationController
/// уронит тест на проверке «A Timer is still pending».
Future<void> _teardown(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 50));
}
