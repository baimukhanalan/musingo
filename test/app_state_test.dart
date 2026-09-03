import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/models/user.dart';
import 'package:muslingo/models/learning_profile.dart';
import 'package:muslingo/models/knowledge_state.dart';
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
    expect(state.user?.hearts, 4);

    await state.completeLesson('r1', 1);
    expect(state.user?.hearts, 4);

    final rules = state.getCourse(CourseType.rules)!;
    expect(rules.lessons.first.status, LessonStatus.completed);
    expect(rules.lessons[1].status, LessonStatus.available);

    final restored = AppState();
    await _waitUntilInitialized(restored);
    expect(restored.user?.id, 'guest');
    expect(
      restored.getCourse(CourseType.rules)?.lessons.first.status,
      LessonStatus.completed,
    );
  });

  test('placement creates local profile and personal recommendation', () async {
    final state = AppState();
    await _waitUntilInitialized(state);

    await state.completePlacement(
      goal: LearningGoal.arabicReading,
      level: 2,
      recommendation: 'Начни с букв.',
    );

    expect(state.isGuest, isTrue);
    expect(state.learningGoal, LearningGoal.arabicReading);
    expect(state.placementLevel, 2);
    expect(state.recommendedLesson?.course, CourseType.arabic);

    final restored = AppState();
    await _waitUntilInitialized(restored);
    expect(restored.isGuest, isTrue);
    expect(restored.learningGoal, LearningGoal.arabicReading);
    expect(restored.learningRecommendation, 'Начни с букв.');
  });

  test('pronunciation goal starts the Tajwid learning path', () async {
    final state = AppState();
    await _waitUntilInitialized(state);

    await state.completePlacement(
      goal: LearningGoal.pronunciation,
      level: 2,
      recommendation: 'Начни с махраджей.',
    );

    expect(state.recommendedLesson?.course, CourseType.tajwid);
    expect(state.recommendedLesson?.id, 'tj01');
  });

  test('strong Arabic placement starts after already demonstrated lessons',
      () async {
    final state = AppState();
    await _waitUntilInitialized(state);

    await state.completePlacement(
      goal: LearningGoal.arabicReading,
      level: 5,
      recommendation: 'Продолжи со сложных букв.',
    );

    expect(state.recommendedLesson?.id, 'a7');
    expect(
      state.getCourse(CourseType.arabic)!.lessons.take(6).every(
            (lesson) => lesson.status == LessonStatus.completed,
          ),
      isTrue,
    );

    final restored = AppState();
    await _waitUntilInitialized(restored);
    expect(restored.recommendedLesson?.id, 'a7');
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

  test('memory engine persists weak steps and prioritizes due review',
      () async {
    final state = AppState();
    await _waitUntilInitialized(state);
    await state.loginAsGuest();
    final reviewedAt = DateTime.now().subtract(const Duration(days: 2));

    // memory engine заводит по одному KnowledgeState на КАЖДЫЙ шаг урока,
    // поэтому ожидаемое число выводим из фактической структуры r1, а не из
    // магической константы (число шагов урока меняется при обогащении контента).
    final r1StepCount = state
        .getCourse(CourseType.rules)!
        .lessons
        .firstWhere((lesson) => lesson.id == 'r1')
        .steps
        .length;

    await state.completeLesson(
      'r1',
      1,
      weakStepIds: {'r1:1'},
      completedAt: reviewedAt,
    );

    expect(state.knowledgeStates, hasLength(r1StepCount));
    expect(state.weakKnowledgeCount, 1);
    expect(state.dueReviewCount, r1StepCount);
    expect(state.recommendedLesson?.id, 'r1');

    final restored = AppState();
    await _waitUntilInitialized(restored);
    expect(restored.knowledgeStates, hasLength(r1StepCount));
    expect(restored.recommendedLesson?.id, 'r1');
  });

  test('knowledge scheduling expands intervals after successful reviews', () {
    final firstReview = DateTime(2026, 8, 1, 10);
    final initial = KnowledgeState.initial(
      id: 'r1:1',
      lessonId: 'r1',
      label: 'Намерение',
      kind: KnowledgeKind.rule,
      reviewedAt: firstReview,
      wasWeak: false,
    );
    final secondReview = firstReview.add(const Duration(days: 1));
    final reviewed = initial.reviewed(
      wasWeak: false,
      reviewedAt: secondReview,
    );

    expect(initial.nextReviewAt, firstReview.add(const Duration(days: 1)));
    expect(reviewed.repetitions, 2);
    expect(reviewed.nextReviewAt, secondReview.add(const Duration(days: 3)));
    expect(reviewed.strength, greaterThan(initial.strength));
  });

  test('hafiz progress is persisted per verse and schedules repetition',
      () async {
    final state = AppState();
    await _waitUntilInitialized(state);
    await state.loginAsGuest();
    final reviewedAt = DateTime(2026, 8, 3, 12);

    final progress = await state.recordHafizAttempt(
      surahNumber: 1,
      surahName: 'Al-Fatihah',
      verseNumber: 1,
      globalVerseNumber: 1,
      score: 92,
      repetitions: 6,
      reviewedAt: reviewedAt,
    );

    expect(progress, isNotNull);
    expect(progress?.nextReviewAt, reviewedAt.add(const Duration(days: 7)));
    expect(state.hafizProgressFor(1, 1)?.bestScore, 92);
    expect(state.memorizedVerseCount, 1);

    final restored = AppState();
    await _waitUntilInitialized(restored);
    expect(restored.hafizProgressFor(1, 1)?.bestScore, 92);
  });

  test('repeating a completed lesson grants reduced xp like the backend',
      () async {
    final state = AppState();
    await _waitUntilInitialized(state);
    await state.loginAsGuest();

    final first = await state.completeLesson('r1', 0);
    final repeat = await state.completeLesson('r1', 0);

    // Первое прохождение — полный lesson.xpReward (для r1 это дефолтные 25),
    // повтор — фиксированные 5 XP, как на сервере
    // (server/routes/progress-complete.js: firstCompletion ? 25 : 5).
    expect(first['xpEarned'], 25);
    expect(repeat['xpEarned'], 5);
  });

  test('deleting a local account removes saved email login', () async {
    final state = AppState();
    await _waitUntilInitialized(state);

    final registered = await state.registerWithEmail(
      'Alan',
      'alan@example.com',
      'password123',
    );
    expect(registered, isTrue);

    final deleted = await state.deleteAccount();
    expect(deleted, isTrue);

    final restored = AppState();
    await _waitUntilInitialized(restored);
    final loggedIn = await restored.loginWithPassword(
      'alan@example.com',
      'password123',
    );

    expect(loggedIn, isFalse);
    expect(restored.error, contains('Аккаунт не найден'));
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
    expect(state.user?.hearts, 5);
  });
}

Future<void> _waitUntilInitialized(AppState state) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(state.isInitialized, isTrue);
}
