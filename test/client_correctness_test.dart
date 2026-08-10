import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/models/learning_profile.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    // SharedPreferences кэширует синглтон между тестами — сбрасываем перед
    // каждым, иначе мок-значения из прошлого теста протекают в следующий.
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  group('Дневная цель считается за сегодня', () {
    test('прогресс за вчера не показывается сегодня, dailyProgress копится',
        () async {
      final state = await _guestState();
      final quran = state.getCourse(CourseType.quran)!;

      // Занимались ВЧЕРА: счётчик dailyProgress вырос...
      await state.completeLesson(
        quran.lessons[0].id,
        0,
        completedAt: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(state.user!.dailyProgress, 1);
      // ...но это не сегодняшний прогресс — новый день начинается с нуля.
      expect(state.todayProgress, 0,
          reason: 'вчерашний прогресс не должен засчитываться в сегодняшнюю цель');

      // Занялись СЕГОДНЯ: цель дня учитывает сегодняшний урок.
      await state.completeLesson(
        quran.lessons[1].id,
        0,
        completedAt: DateTime.now(),
      );
      expect(state.todayProgress, greaterThan(0));
      expect(state.todayProgress, state.user!.dailyProgress,
          reason: 'сегодня показываем реальный dailyProgress');
    });

    test('без занятий todayProgress = 0', () async {
      final state = await _guestState();
      expect(state.user!.dailyProgress, 0);
      expect(state.todayProgress, 0);
    });
  });

  group('logout сбрасывает учебный профиль и guest-ключи', () {
    test('очищает общий профиль и данные гостя, начиная заново', () async {
      final state = await _guestState();
      final quran = state.getCourse(CourseType.quran)!;

      await state.completePlacement(
        goal: LearningGoal.arabicReading,
        level: 3,
        recommendation: 'Личный план гостя',
      );
      await state.completeLesson(quran.lessons[0].id, 0);
      await state.recordHafizAttempt(
        surahNumber: 1,
        surahName: 'Al-Fatihah',
        verseNumber: 1,
        globalVerseNumber: 1,
        score: 90,
        repetitions: 5,
      );

      final prefs = await SharedPreferences.getInstance();
      final before = prefs.getKeys();
      // До выхода — данные на месте.
      expect(before, contains('learning_goal'));
      expect(before, contains('placement_level'));
      expect(before, contains('learning_recommendation'));
      expect(before, contains('completed_lessons_guest'));
      expect(before, contains('memory_engine_guest'));
      expect(before, contains('hafiz_progress_guest'));
      expect(before, contains('local_league_xp_guest'));
      expect(state.learningRecommendation, 'Личный план гостя');

      await state.logout();

      // Профиль обнулён в памяти.
      expect(state.learningGoal, isNull);
      expect(state.learningRecommendation, isNull);
      expect(state.placementLevel, 1);

      // ...и в prefs: и общий учебный профиль, и guest-ключи прогресса.
      final after = prefs.getKeys();
      expect(after, isNot(contains('learning_goal')));
      expect(after, isNot(contains('placement_level')));
      expect(after, isNot(contains('learning_recommendation')));
      expect(after, isNot(contains('completed_lessons_guest')));
      expect(after, isNot(contains('memory_engine_guest')));
      expect(after, isNot(contains('hafiz_progress_guest')));
      expect(after, isNot(contains('local_league_xp_guest')));
    });

    test('данные другого локального аккаунта не затрагиваются', () async {
      // Готовим прогресс постороннего локального аккаунта в хранилище.
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({
        'completed_lessons_local_other': <String>['r1'],
        'memory_engine_local_other': '[]',
      });

      final state = AppState();
      await _waitUntilInitialized(state);
      await state.loginAsGuest();
      final quran = state.getCourse(CourseType.quran)!;
      await state.completeLesson(quran.lessons[0].id, 0);

      await state.logout();

      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys();
      // Guest-ключи ушли, а чужой аккаунт нетронут.
      expect(keys, isNot(contains('completed_lessons_guest')));
      expect(keys, contains('completed_lessons_local_other'));
      expect(keys, contains('memory_engine_local_other'));
    });
  });

  group('Matching перемешивается по-настоящему', () {
    test('нет тривиальных совпадений — ответ не стоит напротив своего prompt',
        () {
      for (final count in [2, 3, 4, 5, 6, 8]) {
        final order = matchingAnswerOrder(count, 12345);
        // Это полноценная перестановка индексов.
        expect(order.toSet(), List.generate(count, (i) => i).toSet(),
            reason: 'count=$count должен быть перестановкой');
        // Ни один ответ не выровнен со своей строкой-подсказкой.
        for (var i = 0; i < count; i++) {
          expect(order[i], isNot(i),
              reason: 'ответ $i не должен стоять в строке $i (count=$count)');
        }
      }
    });

    test('старая предсказуемая перестановка (сдвиг первого) больше не даётся',
        () {
      // Раньше для 4 пар выходило [1, 2, 0, 3]: строки 1 и 3 совпадали.
      final order = matchingAnswerOrder(4, 999);
      expect(order, isNot([1, 2, 0, 3]));
      expect(order[1], isNot(1));
      expect(order[3], isNot(3));
    });

    test('детерминирован в пределах показа: одинаковый seed → одинаковый порядок',
        () {
      final a = matchingAnswerOrder(5, 42);
      final b = matchingAnswerOrder(5, 42);
      expect(a, b, reason: 'порядок не должен «прыгать» на каждый rebuild');
    });

    test('перестановка зависит от seed (разные шаги мешаются по-разному)', () {
      // Не требуем, чтобы каждая пара seed'ов различалась (это в принципе не
      // гарантировано), но по набору seed'ов должно быть больше одного порядка —
      // значит перемешивание реально управляется содержимым шага.
      final orders = {
        for (final seed in [1, 2, 3, 4, 5, 6, 7])
          matchingAnswerOrder(6, seed).join(',')
      };
      expect(orders.length, greaterThan(1));
    });

    test('одна пара остаётся как есть', () {
      expect(matchingAnswerOrder(1, 7), [0]);
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
