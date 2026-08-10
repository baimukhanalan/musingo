import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppState> _guestState() async {
  SharedPreferences.setMockInitialValues({});
  final state = AppState();
  await _waitUntilInitialized(state);
  await state.loginAsGuest();
  return state;
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('Восстановление жизней по времени', () {
    test('через интервал начисляется одна жизнь', () {
      final anchor = DateTime(2026, 1, 1, 10, 0);
      final result = AppState.computeHeartRegen(
        hearts: 2,
        anchor: anchor,
        now: anchor.add(const Duration(minutes: 31)),
        isPremium: false,
      );
      expect(result.hearts, 3);
      // Якорь сдвигается ровно на один интервал, а не на «сейчас».
      expect(result.anchor, anchor.add(const Duration(minutes: 30)));
    });

    test('за длинный простой жизни не переполняются и таймер гаснет', () {
      final anchor = DateTime(2026, 1, 1, 10, 0);
      final result = AppState.computeHeartRegen(
        hearts: 0,
        anchor: anchor,
        now: anchor.add(const Duration(hours: 10)),
        isPremium: false,
      );
      expect(result.hearts, 5);
      expect(result.clearAnchor, isTrue);
      expect(result.anchor, isNull);
    });

    test('до истечения интервала ничего не меняется', () {
      final anchor = DateTime(2026, 1, 1, 10, 0);
      final result = AppState.computeHeartRegen(
        hearts: 1,
        anchor: anchor,
        now: anchor.add(const Duration(minutes: 5)),
        isPremium: false,
      );
      expect(result.hearts, 1);
      expect(result.anchor, anchor);
    });

    test('при неполных жизнях без таймера он запускается', () {
      final now = DateTime(2026, 1, 1, 10, 0);
      final result = AppState.computeHeartRegen(
        hearts: 3,
        anchor: null,
        now: now,
        isPremium: false,
      );
      expect(result.anchor, now);
    });

    test('премиум не трогаем', () {
      final result = AppState.computeHeartRegen(
        hearts: 2,
        anchor: DateTime(2026, 1, 1),
        now: DateTime(2027, 1, 1),
        isPremium: true,
      );
      expect(result.hearts, 2);
    });

    test('гость с потерянными жизнями восстанавливает их со временем', () async {
      final state = await _guestState();
      // Тратим все три жизни — запускается таймер.
      state.loseHeart();
      state.loseHeart();
      state.loseHeart();
      expect(state.user!.hearts, 0);
      expect(state.user!.heartsUpdatedAt, isNotNull);
      // Двигаем якорь на 2 часа назад и просим пересчитать.
      final prefs = await SharedPreferences.getInstance();
      final stored = jsonDecode(prefs.getString('user')!) as Map<String, dynamic>;
      stored['heartsUpdatedAt'] =
          DateTime.now().subtract(const Duration(hours: 2)).toIso8601String();
      await prefs.setString('user', jsonEncode(stored));
      final restarted = AppState();
      await _waitUntilInitialized(restarted);
      // На старте _loadUser применяет регенерацию.
      expect(restarted.user!.hearts, greaterThanOrEqualTo(4));
    });
  });

  group('Стрик по календарным дням (локальный путь)', () {
    test('занятие вчера вечером и сегодня утром наращивает стрик', () async {
      final state = await _guestState();
      final quran = state.getCourse(CourseType.quran)!;
      final l1 = quran.lessons[0].id;
      final l2 = quran.lessons[1].id;

      final yesterdayEvening =
          DateTime.now().subtract(const Duration(days: 1)).copyWith(hour: 23);
      final todayMorning = DateTime.now().copyWith(hour: 8);

      await state.completeLesson(l1, 0, completedAt: yesterdayEvening);
      expect(state.user!.streak, 1);

      // Меньше 24 часов, но другой календарный день → стрик растёт.
      expect(todayMorning.difference(yesterdayEvening).inHours, lessThan(24));
      final result = await state.completeLesson(l2, 0, completedAt: todayMorning);
      expect(result['newStreak'], 2);
    });

    test('второй урок в тот же день стрик не увеличивает', () async {
      final state = await _guestState();
      final quran = state.getCourse(CourseType.quran)!;
      final today = DateTime.now().copyWith(hour: 9);

      await state.completeLesson(quran.lessons[0].id, 0, completedAt: today);
      final result = await state.completeLesson(
        quran.lessons[1].id,
        0,
        completedAt: today.copyWith(hour: 21),
      );
      expect(result['newStreak'], 1);
    });
  });

  group('Локальные пароли не хранятся открытым текстом', () {
    test('регистрация кладёт хеш, а не пароль', () async {
      final state = await _guestState();
      final ok = await state.registerWithEmail('Алан', 'a@b.dev', 'Secret123!');
      expect(ok, isTrue);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('local_email_accounts')!;
      expect(raw, contains('pbkdf2\$'));
      expect(raw, isNot(contains('Secret123!')));
    });

    test('вход проходит с верным паролем и отклоняет неверный', () async {
      final state = await _guestState();
      await state.registerWithEmail('Алан', 'a@b.dev', 'Secret123!');
      await state.logout();

      expect(await state.loginWithPassword('a@b.dev', 'wrong'), isFalse);
      expect(await state.loginWithPassword('a@b.dev', 'Secret123!'), isTrue);
    });

    test('легаси-аккаунт с открытым паролем мигрирует на хеш при входе',
        () async {
      // Готовим хранилище со старым форматом (пароль открытым текстом).
      final legacyUser = {
        'id': 'local_legacy',
        'name': 'Старый',
        'email': 'old@b.dev',
        'hearts': 5,
      };
      SharedPreferences.setMockInitialValues({
        'local_email_accounts': jsonEncode({
          'old@b.dev': {'password': 'PlainPass1', 'user': legacyUser},
        }),
      });
      final state = AppState();
      await _waitUntilInitialized(state);

      expect(await state.loginWithPassword('old@b.dev', 'PlainPass1'), isTrue);

      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('local_email_accounts')!;
      expect(raw, contains('pbkdf2\$'));
      expect(raw, isNot(contains('PlainPass1')));
    });
  });
}

Future<void> _waitUntilInitialized(AppState state) async {
  final deadline = DateTime.now().add(const Duration(seconds: 5));
  while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(state.isInitialized, isTrue);
}
