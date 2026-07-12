import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/models/user.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('persists lesson progress and does not charge hearts twice', () async {
    final state = AppState();
    await _waitUntilInitialized(state);
    await state.loginAsGuest();

    state.loseHeart();
    expect(state.user?.hearts, 2);

    await state.completeLesson('r1', 1);
    expect(state.user?.hearts, 2);

    final rules = state.getCourse(CourseType.rules)!;
    expect(rules.lessons.first.status, LessonStatus.completed);
    expect(rules.lessons[1].status, LessonStatus.available);

    final restored = AppState();
    await _waitUntilInitialized(restored);
    expect(restored.user, isNull);
  });

  test('restores old user json with production progress defaults', () {
    final user = UserModel.fromJson({
      'id': 'u1',
      'name': 'Alan',
      'email': 'alan@example.com',
      'xp': 40,
    });

    expect(user.dailyGoal, 3);
    expect(user.dailyProgress, 0);
    expect(user.lessonAttempts, 0);
    expect(user.speechAttempts, 0);
    expect(user.rewardHistory, isEmpty);
    expect(user.downloadedAudioChapters, isEmpty);
  });

  test('lesson completion updates production progress counters', () async {
    final state = AppState();
    await _waitUntilInitialized(state);
    await state.loginAsGuest();

    final result = await state.completeLesson('r1', 0);

    expect(result['energyEarned'], 12);
    expect(result['rewardToken'], isA<String>());
    expect(state.user?.dailyProgress, 1);
    expect(state.user?.lessonAttempts, 1);
    expect(state.user?.rewardChestsOpened, 3);
    expect(state.user?.rewardHistory, hasLength(1));
  });

  test('stores downloaded Quran audio chapters without duplicates', () async {
    final state = AppState();
    await _waitUntilInitialized(state);
    await state.loginAsGuest();

    await state.markAudioChapterDownloaded(2);
    await state.markAudioChapterDownloaded(1);
    await state.markAudioChapterDownloaded(2);

    expect(state.user?.downloadedAudioChapters, [1, 2]);
  });

  test('restoring a heart spends energy', () async {
    final state = AppState();
    await _waitUntilInitialized(state);
    await state.loginAsGuest();

    await state.completeLesson('r1', 0);
    await state.completeLesson('r2', 0);
    state.loseHeart();

    final restored = await state.restoreHeart();

    expect(restored, isTrue);
    expect(state.user?.energy, 4);
    expect(state.user?.hearts, 3);
  });
}

Future<void> _waitUntilInitialized(AppState state) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(state.isInitialized, isTrue);
}
