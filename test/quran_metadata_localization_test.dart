import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/quran.dart';
import 'package:muslingo/screens/quran_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/quran_repository.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:muslingo/utils/quran_search.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localization_host.dart';

const _fatiha = QuranChapterSummary(
  number: 1,
  arabicName: 'سُورَةُ ٱلْفَاتِحَةِ',
  latinName: 'Al-Faatiha',
  ayahCount: 7,
  revelationType: 'Meccan',
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('revelation labels follow language without changing source metadata',
      () {
    const medinan = QuranChapterSummary(
      number: 2,
      arabicName: 'البقرة',
      latinName: 'Al-Baqara',
      ayahCount: 286,
      revelationType: 'Medinan',
    );
    for (final entry in {
      'ru': ('Мекканская', 'Мединская'),
      'kk': ('Мекке', 'Мәдина'),
      'en': ('Meccan', 'Medinan'),
      'ar': ('مكية', 'مدنية'),
    }.entries) {
      expect(_fatiha.revelationLabelForLocale(entry.key), entry.value.$1);
      expect(medinan.revelationLabelForLocale(entry.key), entry.value.$2);
    }
    expect(_fatiha.toJson()['revelationType'], 'Meccan');
    expect(_fatiha.toJson()['englishName'], 'Al-Faatiha');
    expect(_fatiha.arabicName, 'سُورَةُ ٱلْفَاتِحَةِ');
  });

  test('source-checked Kazakh names are searchable with honest fallback', () {
    expect(quranKazakhNames, hasLength(28));
    expect(quranDisplayName(_fatiha, 'kk'), 'Фатиха');
    expect(quranDisplayName(_fatiha, 'ru'), 'Аль-Фатиха');
    expect(quranDisplayName(_fatiha, 'en'), 'Al-Faatiha');
    const ikhlas = QuranChapterSummary(
      number: 112,
      arabicName: 'الإخلاص',
      latinName: 'Al-Ikhlaas',
      ayahCount: 4,
      revelationType: 'Meccan',
    );
    expect(quranChapterMatches(ikhlas, 'Ықылас'), isTrue);
    expect(quranChapterMatches(ikhlas, 'Әл-Ықылас'), isTrue);
    const unverifiedName = QuranChapterSummary(
      number: 4,
      arabicName: 'النساء',
      latinName: 'An-Nisaa',
      ayahCount: 176,
      revelationType: 'Medinan',
    );
    expect(quranDisplayName(unverifiedName, 'kk'), 'An-Nisaa');
  });

  Future<AppState> guestState(WidgetTester tester) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({
      'quran_chapters_v1': jsonEncode({
        'code': 200,
        'data': List.generate(
            114,
            (index) => {
                  ..._fatiha.toJson(),
                  'number': index + 1,
                  'englishName':
                      index == 0 ? 'Al-Faatiha' : 'Chapter ${index + 1}',
                }),
      }),
    });
    final state = AppState();
    await tester.runAsync(() async {
      while (!state.isInitialized) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await state.loginAsGuest();
    return state;
  }

  Widget host(AppState state, Widget page) =>
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: Consumer<AppState>(
            builder: (_, state, __) => MaterialApp(
                  locale: state.locale.toLocale(),
                  supportedLocales: testSupportedLocales,
                  localizationsDelegates: testLocalizationDelegates,
                  home: page,
                )),
      );

  testWidgets('reader list switches metadata language from cached source',
      (tester) async {
    final state = await guestState(tester);
    addTearDown(state.dispose);
    await tester.pumpWidget(host(state, const QuranScreen()));
    await tester.pumpAndSettle();
    for (final locale in AppLocale.values) {
      await state.setLocale(locale);
      await tester.pumpAndSettle();
      expect(find.text(quranDisplayName(_fatiha, locale.code)), findsOneWidget);
      expect(find.textContaining(_fatiha.revelationLabelForLocale(locale.code)),
          findsWidgets);
      if (locale != AppLocale.ru) {
        expect(find.textContaining('Мекканская'), findsNothing);
      }
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('chapter and full-text labels follow the selected translation',
      (tester) async {
    final state = await guestState(tester);
    addTearDown(state.dispose);
    final repository = _MetadataRepository();
    addTearDown(repository.dispose);
    for (final locale in AppLocale.values) {
      await state.setLocale(locale);
      await tester.pumpWidget(host(
          state,
          QuranChapterScreen(
            chapter: _fatiha,
            repository: repository,
            localeCode: locale.code,
          )));
      await tester.pumpAndSettle();
      expect(find.textContaining(_fatiha.revelationLabelForLocale(locale.code)),
          findsOneWidget);
      final openText = find.text(switch (locale) {
        AppLocale.ru => 'Открыть полный текст',
        AppLocale.kk => 'Толық мәтінді ашу',
        AppLocale.en => 'Open full text',
        AppLocale.ar => 'فتح النص كاملًا',
      });
      await tester.ensureVisible(openText);
      await tester.tap(openText);
      await tester.pumpAndSettle();
      if (locale == AppLocale.ar) {
        expect(find.byType(SegmentedButton<bool>), findsNothing);
        expect(
            find.text('1. بِسْمِ ٱللَّهِ', findRichText: true), findsOneWidget);
        expect(find.textContaining('fixture-ar'), findsNothing);
      } else {
        final language = switch (locale) {
          AppLocale.ru => 'Русский',
          AppLocale.kk => 'Қазақша',
          AppLocale.en => 'English',
          AppLocale.ar => 'العربية',
        };
        expect(find.text(language), findsOneWidget);
        await tester.tap(find.text(language));
        await tester.pumpAndSettle();
        expect(find.text('1. fixture-${locale.code}', findRichText: true),
            findsOneWidget);
      }
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
    }
  });
}

class _MetadataRepository extends QuranRepository {
  @override
  Future<QuranChapter> fetchChapter(QuranChapterSummary summary,
          {String localeCode = 'ru'}) async =>
      QuranChapter(
        summary: summary,
        verses: [
          QuranVerse(
            globalNumber: 1,
            numberInChapter: 1,
            arabicText: 'بِسْمِ ٱللَّهِ',
            translation: 'fixture-$localeCode',
            transliteration: 'Bismillah',
            audioUrl: 'https://example.com/1.mp3',
            juz: 1,
            page: 1,
          )
        ],
        fullAudioUrl: 'https://example.com/chapter.mp3',
      );
}
