import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/progress_portability_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('exports portable learning data without identity or secrets', () async {
    final state = AppState();
    await _waitUntilInitialized(state);
    await state.loginAsGuest();
    await state.completeLesson('r1', 0);
    await state.recordHafizAttempt(
      surahNumber: 1,
      surahName: 'Al-Fatihah',
      verseNumber: 1,
      globalVerseNumber: 1,
      score: 95,
      repetitions: 6,
      reviewedAt: DateTime.utc(2026, 9, 10),
    );

    final snapshot = const ProgressPortabilityService().buildSnapshot(
      state,
      exportedAt: DateTime.utc(2026, 9, 11, 8, 30),
    );
    final encoded = jsonEncode(snapshot);

    expect(snapshot['format'], ProgressPortabilityService.format);
    expect(snapshot['schemaVersion'], 1);
    expect(snapshot['exportedAt'], '2026-09-11T08:30:00.000Z');
    expect(
      (snapshot['progress'] as Map)['completedLessonIds'],
      contains('r1'),
    );
    expect(
      (snapshot['progress'] as Map)['surahsWithMemorizedVerses'],
      [1],
    );
    expect((snapshot['progress'] as Map)['knowledgeStates'], isNotEmpty);
    expect((snapshot['progress'] as Map)['hafizProgress'], isNotEmpty);
    expect((snapshot['privacy'] as Map)['containsIdentity'], isFalse);
    expect(encoded, isNot(contains('email')));
    expect(encoded, isNot(contains('password')));
    expect(encoded, isNot(contains('authToken')));
    expect(encoded, isNot(contains('rewardHistory')));

    state.dispose();
  });

  test('encoded snapshot is valid readable JSON for a signed-out user',
      () async {
    final state = AppState();
    await _waitUntilInitialized(state);

    final encoded = const ProgressPortabilityService().encodeSnapshot(
      state,
      exportedAt: DateTime.utc(2026, 9, 11),
    );
    final decoded = jsonDecode(encoded) as Map<String, dynamic>;

    expect(encoded, contains('\n  "format"'));
    expect((decoded['studyStats'] as Map)['xp'], 0);
    expect((decoded['progress'] as Map)['completedLessonIds'], isEmpty);

    state.dispose();
  });

  test('previews and merges a valid local snapshot without importing rewards',
      () async {
    final source = AppState();
    await _waitUntilInitialized(source);
    await source.loginAsGuest();
    await source.completeLesson('r1', 0);
    final json = const ProgressPortabilityService().encodeSnapshot(source);

    SharedPreferences.setMockInitialValues({});
    final target = AppState();
    await _waitUntilInitialized(target);
    await target.loginAsGuest();
    final preview =
        const ProgressPortabilityService().decodeAndPreview(json, target);
    expect(preview.completedLessons, 1);

    final result = await target.importPortableProgress(preview.snapshot);
    expect(result.completedLessons, 1);
    expect(
      target.getCourse(CourseType.rules)!.lessons.first.status,
      LessonStatus.completed,
    );
    expect(target.user!.xp, 0);
    expect(target.user!.streak, 0);

    source.dispose();
    target.dispose();
  });

  test('rejects files that are not Muslingo progress snapshots', () async {
    final state = AppState();
    await _waitUntilInitialized(state);
    expect(
      () => const ProgressPortabilityService()
          .decodeAndPreview('{"format":"other"}', state),
      throwsFormatException,
    );
    state.dispose();
  });

  test('rejects malformed skill scores before changing lesson progress',
      () async {
    final state = AppState();
    await _waitUntilInitialized(state);
    await state.loginAsGuest();
    final snapshot = <String, dynamic>{
      'format': ProgressPortabilityService.format,
      'schemaVersion': ProgressPortabilityService.schemaVersion,
      'learningProfile': <String, dynamic>{
        'skillScores': <String, dynamic>{'letters': 'not-a-number'},
      },
      'progress': <String, dynamic>{
        'completedLessonIds': <String>['r1'],
        'knowledgeStates': <dynamic>[],
        'hafizProgress': <dynamic>[],
      },
    };

    expect(
      () => const ProgressPortabilityService()
          .decodeAndPreview(jsonEncode(snapshot), state),
      throwsFormatException,
    );
    await expectLater(
      state.importPortableProgress(snapshot),
      throwsFormatException,
    );
    expect(
      state.getCourse(CourseType.rules)!.lessons.first.status,
      LessonStatus.available,
    );
    expect(state.learningSkillProfile, isNull);

    state.dispose();
  });

  test('rejects invalid Hafiz records atomically', () async {
    final state = AppState();
    await _waitUntilInitialized(state);
    await state.loginAsGuest();
    final snapshot = <String, dynamic>{
      'format': ProgressPortabilityService.format,
      'schemaVersion': ProgressPortabilityService.schemaVersion,
      'progress': <String, dynamic>{
        'completedLessonIds': <String>['r1'],
        'knowledgeStates': <dynamic>[],
        'hafizProgress': <dynamic>[
          <String, dynamic>{
            'surahNumber': 999,
            'surahName': 'Invalid',
            'verseNumber': -1,
            'globalVerseNumber': 1,
            'attempts': 1,
            'repetitions': 0,
            'bestScore': 90,
            'mastery': 0.9,
            'lastReviewedAt': '2026-09-10T00:00:00.000Z',
            'nextReviewAt': '2026-09-11T00:00:00.000Z',
          },
        ],
      },
    };

    expect(
      () => const ProgressPortabilityService()
          .decodeAndPreview(jsonEncode(snapshot), state),
      throwsFormatException,
    );
    await expectLater(
      state.importPortableProgress(snapshot),
      throwsFormatException,
    );
    expect(
      state.getCourse(CourseType.rules)!.lessons.first.status,
      LessonStatus.available,
    );
    expect(state.hafizProgress, isEmpty);

    state.dispose();
  });
}

Future<void> _waitUntilInitialized(AppState state) async {
  for (var i = 0; i < 200 && !state.isInitialized; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(state.isInitialized, isTrue);
}
