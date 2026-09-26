import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';
// The plugin's platform seam rejects an actual write after its cache changed.
// ignore: depend_on_referenced_packages
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));
  tearDown(() => SharedPreferences.setMockInitialValues({}));

  for (final throwsError in [true, false]) {
    for (final key in [
      'user',
      'memory_engine_guest',
      'completed_lessons_guest',
      'local_league_season',
      'local_league_xp_guest',
    ]) {
      test(
          'guest retries ${throwsError ? 'throw' : 'false'} at $key without '
          'another award or review', () async {
        final state = await _initializedState();
        addTearDown(state.dispose);
        await state.loginAsGuest();
        final before = state.user!;
        final lesson = state.getCourse(CourseType.rules)!.lessons.first;
        final store = await _failNextWrite(key, throwsError: throwsError);

        await expectLater(
          state.completeLesson('r1', 0, elapsedSeconds: 47),
          throwsStateError,
        );
        expect(store.failures, 1);
        expect(state.error, isNotNull);
        final awarded = state.user!;
        final memory = state.knowledgeStates.map((k) => k.toJson()).toList();
        expect(awarded.xp, before.xp + lesson.xpReward);
        expect(awarded.totalStudySeconds, before.totalStudySeconds + 47);

        // The user spent additional time on the error screen. A retry must
        // keep the original result, not account for that time a second time.
        final retried = await Future.wait([
          state.completeLesson('r1', 1, elapsedSeconds: 70),
          state.completeLesson('r1', 1, elapsedSeconds: 70),
        ]);
        expect(retried[0], retried[1]);
        expect(retried.first['xpEarned'], lesson.xpReward);
        expect(retried.first['heartsLost'], 0);
        expect(state.user!.toJson(), awarded.toJson());
        expect(state.knowledgeStates.map((k) => k.toJson()).toList(), memory);
        expect(state.error, isNull);

        // Read the platform store, not the SharedPreferences cache: a failed
        // setValue updates the latter even when nothing reaches persistence.
        final durable = await store.getAll();
        expect(
            jsonDecode(durable['flutter.user']! as String), awarded.toJson());
        expect(durable['flutter.completed_lessons_guest'], contains('r1'));
        expect(durable['flutter.local_league_xp_guest'], lesson.xpReward);
        expect(durable['flutter.local_league_season'], isNotNull);
        expect(
          jsonDecode(durable['flutter.memory_engine_guest']! as String),
          memory,
        );

        // After durability a genuinely new replay remains possible.
        final replay = await state.completeLesson('r1', 0, elapsedSeconds: 13);
        expect(replay['xpEarned'], 5);
        expect(state.user!.xp, awarded.xp + 5);
        expect(state.user!.totalStudySeconds, awarded.totalStudySeconds + 13);
        expect(state.user!.totalLessons, 1);
        expect(state.user!.lessonAttempts, awarded.lessonAttempts + 1);
      });
    }
  }

  for (final throwsError in [true, false]) {
    test(
        'backend save ${throwsError ? 'throw' : 'false'} retains awarded receipt '
        'and does not issue another attempt', () async {
      SharedPreferences.setMockInitialValues(
          {'muslingo_auth_token': 'test-token'});
      final server = _CompletionServer();
      await http.runWithClient(() async {
        final state = await _initializedState();
        addTearDown(state.dispose);
        expect(state.isBackendUser, isTrue);
        final store = await _failNextWrite('user', throwsError: throwsError);
        await state.beginLessonAttempt('r1');
        await state.recordLessonStep('r1', 0);
        await expectLater(
          state.completeLesson('r1', 0, elapsedSeconds: 47),
          throwsStateError,
        );
        final awarded = state.user!;
        final memory = state.knowledgeStates.map((k) => k.toJson()).toList();
        expect(server.completions, 1);

        // Reopening the same lesson while local recovery is pending cannot
        // create/record against a new, empty server attempt.
        await state.beginLessonAttempt('r1');
        await state.recordLessonStep('r1', 0);
        final result = await state.completeLesson('r1', 0, elapsedSeconds: 80);
        expect(result['rewardToken'], 'attempt-1');
        expect(result['xpEarned'], 25);
        expect(server.attempts, 1);
        expect(server.steps, 1);
        expect(server.completions, 1);
        expect(state.user!.toJson(), awarded.toJson());
        expect(state.knowledgeStates.map((k) => k.toJson()).toList(), memory);
        expect(state.error, isNull);
        expect(
          jsonDecode((await store.getAll())['flutter.user']! as String),
          awarded.toJson(),
        );

        await state.beginLessonAttempt('r1');
        expect(server.attempts, 2);
      }, () => MockClient(server.respond));
    });
  }

  test('late backend completion cannot restore an account after sign-out',
      () async {
    SharedPreferences.setMockInitialValues(
        {'muslingo_auth_token': 'test-token'});
    final server = _CompletionServer()..holdCompletion = Completer<void>();
    await http.runWithClient(() async {
      final state = await _initializedState();
      addTearDown(state.dispose);
      final completion = state.completeLesson('r1', 0, elapsedSeconds: 47);
      final failure = expectLater(completion, throwsStateError);
      await server.completionRequested.future;
      await state.logout();
      server.holdCompletion!.complete();
      await failure;
      expect(state.user, isNull);
      expect(state.isLoggedIn, isFalse);
      final preferences = await SharedPreferences.getInstance();
      expect(preferences.getString('user'), isNull);
    }, () => MockClient(server.respond));
  });

  for (final transition in ['logout', 'guest', 'direct login']) {
    test('$transition does not reuse a previous account lesson attempt',
        () async {
      SharedPreferences.setMockInitialValues(
          {'muslingo_auth_token': 'test-token'});
      final server = _CompletionServer();
      await http.runWithClient(() async {
        final state = await _initializedState();
        addTearDown(state.dispose);
        await state.beginLessonAttempt('r1');
        await state.recordLessonStep('r1', 0);
        expect(server.lastStepAttemptToken, 'attempt-1');

        if (transition == 'logout') await state.logout();
        if (transition == 'guest') await state.loginAsGuest();
        expect(
          await state.loginWithPassword('second@example.test', 'test-password'),
          isTrue,
        );
        expect(state.user!.id, 'second-user');
        await state.beginLessonAttempt('r1');
        await state.recordLessonStep('r1', 0);

        expect(server.attempts, 2);
        expect(server.lastStepAttemptToken, 'attempt-2');
        expect(server.lastStepAuthorization, 'Bearer second-token');
      }, () => MockClient(server.respond));
    });
  }
}

Future<AppState> _initializedState() async {
  final state = AppState();
  final deadline = DateTime.now().add(const Duration(seconds: 15));
  while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(state.isInitialized, isTrue);
  expect(state.error, isNull);
  return state;
}

Future<_FailingPreferences> _failNextWrite(
  String key, {
  required bool throwsError,
}) async {
  final store = _FailingPreferences(
    await SharedPreferencesStorePlatform.instance.getAll(),
    'flutter.$key',
    throwsError,
  );
  SharedPreferencesStorePlatform.instance = store;
  return store;
}

class _FailingPreferences extends InMemorySharedPreferencesStore {
  final String failingKey;
  final bool throwsError;
  int failures = 0;

  _FailingPreferences(super.data, this.failingKey, this.throwsError)
      : super.withData();

  @override
  Future<bool> setValue(String valueType, String key, Object value) async {
    if (key == failingKey && failures == 0) {
      failures++;
      if (throwsError) throw StateError('Simulated storage failure');
      return false;
    }
    return super.setValue(valueType, key, value);
  }
}

class _CompletionServer {
  int attempts = 0;
  int steps = 0;
  int completions = 0;
  String? lastStepAttemptToken;
  String? lastStepAuthorization;
  final completionRequested = Completer<void>();
  Completer<void>? holdCompletion;
  Map<String, dynamic> profile = {
    'user': 'verified-user',
    'displayName': 'Test',
    'email': 'test@example.test',
    'energy': 0,
    'completedLessons': <String>[],
  };

  Future<http.Response> respond(http.Request request) async {
    Map<String, dynamic> body;
    switch (request.url.path) {
      case '/api/auth/me':
        body = profile;
        break;
      case '/api/auth/login':
        profile = {
          ...profile,
          'user': 'second-user',
          'email': 'second@example.test',
        };
        body = {'token': 'second-token', 'profile': profile};
        break;
      case '/api/progress/attempt':
        attempts++;
        body = {'attemptToken': 'attempt-$attempts'};
        break;
      case '/api/progress/step':
        steps++;
        lastStepAttemptToken =
            (jsonDecode(request.body) as Map)['attemptToken'] as String;
        lastStepAuthorization = request.headers['Authorization'];
        body = {'ok': true};
        break;
      case '/api/progress/complete':
        completions++;
        if (!completionRequested.isCompleted) completionRequested.complete();
        if (holdCompletion != null) await holdCompletion!.future;
        profile = {
          ...profile,
          'xp': 25,
          'energy': 8,
          'streak': 1,
          'totalLessons': 1,
          'lessonAttempts': 1,
          'totalStudySeconds': 47,
          'totalMinutes': 0,
          'completedLessons': ['r1'],
          'rewardHistory': ['attempt-1'],
        };
        body = {
          'progress': profile,
          'xpEarned': 25,
          'energyEarned': 8,
          'streakBonus': 0,
        };
        break;
      case '/api/progress/sync':
        final state = (jsonDecode(request.body) as Map)['state'] as Map;
        profile = {...profile, 'knowledgeStates': state['knowledgeStates']};
        body = {'profile': profile};
        break;
      case '/api/auth/logout':
        body = {'ok': true};
        break;
      default:
        throw StateError('Unexpected request: ${request.url.path}');
    }
    return http.Response(jsonEncode(body), 200,
        headers: {'content-type': 'application/json'});
  }
}
