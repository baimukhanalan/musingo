import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/user.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> _ready(AppState state) async {
  final deadline = DateTime.now().add(const Duration(seconds: 10));
  while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(state.isInitialized, isTrue);
}

bool _earned(AppState state, String id) =>
    state.achievements.firstWhere((item) => item.id == id).isUnlocked;

Map<String, dynamic> _legacyGuest(int streak) => {
      'id': 'guest',
      'name': 'Guest',
      'email': '',
      'streak': streak,
      'lastStudyDate':
          DateTime.now().subtract(const Duration(days: 4)).toIso8601String(),
    };

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  test('best streak is monotonic through copyWith and JSON round trips', () {
    const earned = UserModel(id: 'a', name: 'A', email: '', streak: 30);
    final broken = earned.copyWith(streak: 0);
    expect(broken.streak, 0);
    expect(broken.bestStreak, 30);
    final restarted = UserModel.fromJson(broken.toJson());
    expect(restarted.copyWith(streak: 1, bestStreak: 7).bestStreak, 30);
    expect(restarted.copyWith(streak: 100).bestStreak, 100);
  });

  test('legacy known milestone survives automatic reset and app restart',
      () async {
    SharedPreferences.setMockInitialValues({
      'user': jsonEncode(_legacyGuest(30)),
    });
    final state = AppState();
    await _ready(state);
    expect(state.user!.streak, 0);
    expect(state.user!.bestStreak, 30);
    expect(_earned(state, 'streak_7'), isTrue);
    expect(_earned(state, 'streak_30'), isTrue);
    expect(_earned(state, 'streak_100'), isFalse);
    final prefs = await SharedPreferences.getInstance();
    expect(jsonDecode(prefs.getString('user')!)['bestStreak'], 30);
    await state.completeLesson('r1', 0);
    expect(state.user!.streak, 1);
    expect(_earned(state, 'streak_30'), isTrue);
    state.dispose();

    final restarted = AppState();
    await _ready(restarted);
    expect(restarted.user!.bestStreak, 30);
    expect(_earned(restarted, 'streak_30'), isTrue);
    restarted.dispose();
  });

  test('migration does not invent milestones without known history', () async {
    SharedPreferences.setMockInitialValues({
      'user': jsonEncode(_legacyGuest(0)),
    });
    final state = AppState();
    await _ready(state);
    expect(state.user!.bestStreak, 0);
    expect(_earned(state, 'streak_7'), isFalse);
    expect(_earned(state, 'streak_30'), isFalse);
    state.dispose();
  });

  test(
      'earned milestones stay with their local account across logout and switch',
      () async {
    SharedPreferences.setMockInitialValues({
      'user': jsonEncode(_legacyGuest(30)),
      'completed_lessons_guest': ['r1', 'r2', 'r3', 'r4', 'r5'],
    });
    var state = AppState();
    await _ready(state);
    expect(
        await state.registerWithEmail(
            'A', 'award-a@example.test', 'Password123!'),
        isTrue);
    final firstId = state.user!.id;
    expect(_earned(state, 'streak_30'), isTrue);
    expect(_earned(state, 'modules_5'), isTrue);
    await state.logout();
    expect(state.achievements.every((a) => !a.isUnlocked), isTrue);
    expect(
        await state.registerWithEmail(
            'B', 'award-b@example.test', 'Password123!'),
        isTrue);
    expect(state.user!.id, isNot(firstId));
    expect(state.user!.bestStreak, 0);
    expect(_earned(state, 'streak_7'), isFalse);
    expect(_earned(state, 'modules_5'), isFalse,
        reason: 'stale guest progress belongs to A');
    await state.logout();
    state.dispose();

    state = AppState();
    await _ready(state);
    expect(
        await state.loginWithPassword('award-a@example.test', 'Password123!'),
        isTrue);
    expect(state.user!.id, firstId);
    expect(state.user!.bestStreak, 30);
    expect(_earned(state, 'streak_30'), isTrue);
    expect(_earned(state, 'modules_5'), isTrue);
    await state.logout();
    expect(
        await state.loginWithPassword('award-b@example.test', 'Password123!'),
        isTrue);
    expect(state.user!.bestStreak, 0);
    expect(_earned(state, 'streak_30'), isFalse);
    state.dispose();
  });
}
