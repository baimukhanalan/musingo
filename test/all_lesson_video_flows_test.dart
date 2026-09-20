import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/services/lesson_video_catalog.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:muslingo/widgets/lesson_video_card.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(LessonContentLocalization.load);
  for (final locale in AppLocale.values) {
    testWidgets(
        '${locale.code}: all catalog video controls, notes, and quiz retries',
        (tester) async {
      SharedPreferences.setMockInitialValues({});
      final state = AppState();
      await tester.runAsync(() async {
        while (!state.isInitialized) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        await state.loginAsGuest();
        await state.setLocale(locale);
      });
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      var videoIndex = 0;
      for (final video in LessonVideoCatalog.curated.entries) {
        tester.view.physicalSize = const [
          Size(320, 568),
          Size(390, 844),
          Size(430, 932),
        ][videoIndex++ % 3];
        final opened = <Uri>[];
        await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
          value: state,
          child: MaterialApp(
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(context)
                  .copyWith(textScaler: const TextScaler.linear(1.3)),
              child: child!,
            ),
            home: Scaffold(
                body: SingleChildScrollView(
                    child: LessonVideoCard(
              video: video,
              opener: (uri) async {
                opened.add(uri);
                if (opened.length == 1) {
                  throw StateError('Launcher unavailable');
                }
                return true;
              },
            ))),
          ),
        ));
        await tester.pumpAndSettle();
        expect(tester.takeException(), isNull, reason: video.id);
        expect(opened, isEmpty, reason: 'Videos must not autoplay');
        await _tap(tester, 'lesson-video-play');
        expect(find.byType(SnackBar), findsOneWidget);
        // A failed external launcher must not leave an endless busy button.
        await tester.pump(const Duration(seconds: 5));
        await _tap(tester, 'lesson-video-play');
        await _tap(tester, 'lesson-video-source');
        expect(opened, List.filled(3, Uri.parse(video.source.url)));
        await _tap(tester, 'lesson-video-transcript-toggle');
        expect(
            tester
                .widget<SelectableText>(
                    find.byKey(const Key('lesson-video-transcript')))
                .maxLines,
            isNull);
        await _tap(tester, 'lesson-video-transcript-toggle');
        expect(
            tester
                .widget<SelectableText>(
                    find.byKey(const Key('lesson-video-transcript')))
                .maxLines,
            5);
        await _tap(tester, 'lesson-video-check-start');
        final challenges =
            buildLessonVideoChallenges(video, locale: locale.code);
        final submit = find.byKey(const Key('lesson-video-check-submit'));
        for (final challenge in challenges) {
          expect(tester.widget<FilledButton>(submit).onPressed, isNull);
          await _tap(tester,
              'lesson-video-check-answer-${(challenge.correctIndex + 1) % 4}');
          await _tap(tester, 'lesson-video-check-submit');
          await _tap(tester, 'lesson-video-check-submit');
          expect(tester.widget<FilledButton>(submit).onPressed, isNull);
          await _tap(
              tester, 'lesson-video-check-answer-${challenge.correctIndex}');
          await _tap(tester, 'lesson-video-check-submit');
          await _tap(tester, 'lesson-video-check-submit');
        }
        expect(find.byKey(const Key('lesson-video-check-mastered')),
            findsOneWidget);
        expect(tester.takeException(), isNull, reason: video.id);
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump();
      }
      state.dispose();
    });
  }
}

Future<void> _tap(WidgetTester tester, String key) async {
  final finder = find.byKey(Key(key));
  expect(finder, findsOneWidget);
  await Scrollable.ensureVisible(finder.evaluate().single, alignment: 0.5);
  await tester.pumpAndSettle();
  expect(finder.hitTestable(), findsOneWidget, reason: key);
  await tester.tap(finder.hitTestable());
  await tester.pumpAndSettle();
  expect(tester.takeException(), isNull, reason: key);
}
