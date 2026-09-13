import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/quran.dart';
import 'package:muslingo/screens/quran_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/quran_repository.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('a Juz route opens at its exact starting ayah', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
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
    final repository = _FakeQuranRepository();
    addTearDown(repository.dispose);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: QuranChapterScreen(
            chapter: repository.summary,
            repository: repository,
            initialAyahNumber: 142,
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Начало джуза 2'), findsOneWidget);
    expect(find.text('1'), findsNothing);
    expect(tester.takeException(), isNull);
  });
}

class _FakeQuranRepository extends QuranRepository {
  final summary = const QuranChapterSummary(
    number: 2,
    arabicName: 'البقرة',
    latinName: 'Al-Baqarah',
    ayahCount: 286,
    revelationType: 'Medinan',
  );

  @override
  Future<QuranChapter> fetchChapter(
    QuranChapterSummary summary, {
    String localeCode = 'ru',
  }) async {
    return QuranChapter(
      summary: summary,
      verses: List.generate(
        286,
        (index) => QuranVerse(
          globalNumber: index + 1,
          numberInChapter: index + 1,
          arabicText: index == 141 ? 'Начало джуза 2' : 'Аят ${index + 1}',
          translation: 'Перевод ${index + 1}',
          transliteration: 'Транслитерация ${index + 1}',
          audioUrl: 'https://example.com/${index + 1}.mp3',
          juz: index < 141 ? 1 : 2,
          page: 1,
        ),
      ),
      fullAudioUrl: 'https://example.com/chapter.mp3',
    );
  }
}
