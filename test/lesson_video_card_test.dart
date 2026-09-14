import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/lesson_video_catalog.dart';
import 'package:muslingo/widgets/lesson_video_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/lesson_video_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  test('every curated video has two source-grounded four-option checks', () {
    for (final video in LessonVideoCatalog.curated.entries) {
      final challenges = buildLessonVideoChallenges(video);
      expect(challenges, hasLength(2), reason: video.id);
      for (final challenge in challenges) {
        expect(challenge.options, hasLength(4), reason: video.id);
        expect(challenge.options.toSet(), hasLength(4), reason: video.id);
        expect(challenge.correctIndex, inInclusiveRange(0, 3),
            reason: video.id);
      }
    }
  });

  testWidgets('does not autoplay and opens only after an accessible tap',
      (tester) async {
    final semantics = tester.ensureSemantics();
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final opened = <Uri>[];
    final state = await _state(tester);
    final video = testLessonVideo();

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: LessonVideoCard(
                video: video,
                opener: (uri) async {
                  opened.add(uri);
                  return true;
                },
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(opened, isEmpty);
    expect(find.bySemanticsLabel('Открыть видео'), findsOneWidget);
    expect(find.byKey(const Key('lesson-video-transcript')), findsOneWidget);
    expect(find.text(video.transcript), findsOneWidget);
    expect(find.textContaining(video.speaker.name), findsOneWidget);

    final challenges = buildLessonVideoChallenges(video, catalog: const []);
    expect(challenges, hasLength(2));
    expect(
        challenges.every((item) => item.options.toSet().length == 4), isTrue);

    await tester
        .ensureVisible(find.byKey(const Key('lesson-video-check-start')));
    await tester.tap(find.byKey(const Key('lesson-video-check-start')));
    await tester.pump();
    for (final challenge in challenges) {
      await tester.ensureVisible(
        find.byKey(
            ValueKey('lesson-video-check-answer-${challenge.correctIndex}')),
      );
      await tester.tap(find.byKey(
          ValueKey('lesson-video-check-answer-${challenge.correctIndex}')));
      await tester.pump();
      await tester
          .ensureVisible(find.byKey(const Key('lesson-video-check-submit')));
      await tester.tap(find.byKey(const Key('lesson-video-check-submit')));
      await tester.pump();
      await tester
          .ensureVisible(find.byKey(const Key('lesson-video-check-submit')));
      await tester.tap(find.byKey(const Key('lesson-video-check-submit')));
      await tester.pump();
    }
    expect(
        find.byKey(const Key('lesson-video-check-mastered')), findsOneWidget);

    await tester.tap(find.byKey(const Key('lesson-video-play')));
    await tester.pump();

    expect(opened, [Uri.parse(video.source.url)]);

    semantics.dispose();
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    state.dispose();
  });

  testWidgets('does not render an unsafe record even when called directly',
      (tester) async {
    final state = await _state(tester);
    final unsafe = testLessonVideo(
      embedUrl: 'https://www.youtube-nocookie.com.evil.test/embed/abc123XYZ00',
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(home: LessonVideoCard(video: unsafe)),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('lesson-video-play')), findsNothing);
    expect(find.text(unsafe.title), findsNothing);

    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}

Future<AppState> _state(WidgetTester tester) async {
  final state = AppState();
  await tester.runAsync(() async {
    final deadline = DateTime.now().add(const Duration(seconds: 5));
    while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await state.loginAsGuest();
  });
  expect(state.isInitialized, isTrue);
  return state;
}
