import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/lesson_video_catalog.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/lesson_video_fixture.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('lesson screen renders only an approved catalog video',
      (tester) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
    });

    const lesson = Lesson(
      id: 'lesson-1',
      title: 'Video lesson fixture',
      subtitle: 'Safe catalog integration',
      course: CourseType.arabic,
      order: 1,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          arabicText: 'بِسْمِ اللَّهِ',
          russianText: 'Учебный текст',
        ),
      ],
    );
    final catalog = LessonVideoCatalog(entries: [
      testLessonVideo(),
      testLessonVideo(
        id: 'unsafe',
        embedUrl: 'https://untrusted.example/video/abc123XYZ00',
      ),
    ]);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: LessonScreen(lesson: lesson, videoCatalog: catalog),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.byKey(const Key('lesson-video-play')), findsOneWidget);
    expect(find.text('How the lesson works'), findsOneWidget);
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    state.dispose();
  });

  testWidgets('production catalog follows the selected explanation language',
      (tester) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
    });

    const lesson = Lesson(
      id: 'a1',
      title: 'Первые буквы',
      subtitle: 'Алиф, Ба, Та',
      course: CourseType.arabic,
      order: 1,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          arabicText: 'ا ب ت',
          russianText: 'Учебный текст',
        ),
      ],
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: LessonScreen(lesson: lesson)),
      ),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Арабский алфавит'), findsOneWidget);
    expect(find.text('Құран әліппесі — 1-дәріс'), findsNothing);

    await tester.runAsync(
      () => state.setNativeLanguage(NativeLanguage.kazakh),
    );
    await tester.pump(const Duration(milliseconds: 500));
    expect(find.text('Арабский алфавит'), findsNothing);
    expect(find.text('Құран әліппесі — 1-дәріс'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
    state.dispose();
  });
}
