import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/widgets/premium_button.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppState> guestState(WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      while (!state.isInitialized) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
    });
    return state;
  }

  Future<void> pumpLesson(
    WidgetTester tester,
    AppState state,
    Lesson lesson,
  ) async {
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: LessonScreen(
            lesson: lesson,
            audioPlaybackSimulator: (_) async => throw StateError('offline'),
          ),
        ),
      ),
    );
    await tester.pump();
  }

  testWidgets('failed audio step playback keeps Next locked', (tester) async {
    final state = await guestState(tester);
    const lesson = Lesson(
      id: 'audio_gate',
      title: 'Audio gate',
      subtitle: 'Failure must not unlock',
      course: CourseType.quran,
      order: 999,
      steps: [
        LessonStep(
          type: LessonStepType.audio,
          arabicText: 'بِسْمِ اللَّهِ',
        ),
      ],
    );
    await pumpLesson(tester, state, lesson);

    // A letter or phonetic sample without an ayah address is not a new verse.
    expect(find.text('ЗВУЧАНИЕ · СЛУШАЙ'), findsOneWidget);
    expect(find.text('НОВЫЙ АЯТ · СЛУШАЙ'), findsNothing);

    await tester.tap(find.byKey(const ValueKey('lesson_audio_play')));
    await tester.pump(const Duration(milliseconds: 300));

    final action = tester.widget<PremiumButton>(
      find.byKey(const ValueKey('lesson_primary_action')),
    );
    expect(action.onPressed, isNull);
    expect(find.textContaining('недоступно'), findsOneWidget);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });

  testWidgets('failed listening playback keeps choices locked', (tester) async {
    final state = await guestState(tester);
    const lesson = Lesson(
      id: 'listen_gate',
      title: 'Listening gate',
      subtitle: 'Failure must not unlock',
      course: CourseType.quran,
      order: 999,
      steps: [
        LessonStep(
          type: LessonStepType.listenChoice,
          arabicText: 'الْحَمْدُ لِلَّهِ',
          answers: ['Первый', 'Второй'],
          correctAnswerIndex: 0,
        ),
      ],
    );
    await pumpLesson(tester, state, lesson);

    await tester.tap(find.byKey(const ValueKey('lesson_listen_play')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(
      find.text('Варианты откроются после прослушивания.'),
      findsOneWidget,
    );
    final firstAnswerTap = find.descendant(
      of: find.byKey(const ValueKey('lesson_answer_0')),
      matching: find.byType(GestureDetector),
    );
    expect(tester.widget<GestureDetector>(firstAnswerTap).onTap, isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(seconds: 1));
  });
}
