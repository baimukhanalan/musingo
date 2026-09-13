import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/quran.dart';
import 'package:muslingo/screens/hafiz_mode_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const chapter = QuranChapterSummary(
    number: 2,
    arabicName: 'سُورَةُ الْبَقَرَةِ',
    latinName: 'Al-Baqara',
    ayahCount: 286,
    revelationType: 'Medinan',
  );

  const verse = QuranVerse(
    globalNumber: 149,
    numberInChapter: 142,
    arabicText:
        'سَيَقُولُ السُّفَهَاءُ مِنَ النَّاسِ مَا وَلَّاهُمْ عَنْ قِبْلَتِهِمُ الَّتِي كَانُوا عَلَيْهَا',
    translation: 'Перевод аята',
    transliteration: 'Sayaqulu as-sufahau mina an-nasi',
    audioUrl: 'https://example.com/verse.mp3',
    juz: 2,
    page: 22,
  );

  for (final size in [
    const Size(320, 568),
    const Size(844, 390),
  ]) {
    testWidgets(
      'Hafiz content scrolls while the primary action stays reachable at '
      '${size.width}x${size.height}',
      (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        SharedPreferences.setMockInitialValues({});

        final state = AppState();
        await tester.runAsync(() async {
          while (!state.isInitialized) {
            await Future<void>.delayed(const Duration(milliseconds: 10));
          }
          await state.loginAsGuest();
        });

        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: state,
            child: const MaterialApp(
              home: HafizModeScreen(chapter: chapter, verse: verse),
            ),
          ),
        );
        await tester.pump();

        final action = find.text('Продолжить');
        expect(action, findsOneWidget);
        expect(action.hitTestable(), findsOneWidget);
        expect(
          find.text('Прослушать правильный образец').hitTestable(),
          findsOneWidget,
        );

        final scrollable = find.byType(ListView);
        expect(scrollable, findsOneWidget);
        final reviewSchedule = find.text('РАСПИСАНИЕ ПОВТОРЕНИЙ');
        for (var i = 0;
            i < 6 && reviewSchedule.hitTestable().evaluate().isEmpty;
            i++) {
          await tester.drag(scrollable, const Offset(0, -140));
          await tester.pump(const Duration(milliseconds: 120));
        }

        expect(reviewSchedule.hitTestable(), findsOneWidget);
        expect(action.hitTestable(), findsOneWidget);
        expect(tester.takeException(), isNull, reason: 'layout at $size');

        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pump(const Duration(seconds: 1));
      },
    );
  }
}
