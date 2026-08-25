import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/quran.dart';
import 'package:muslingo/utils/quran_search.dart';

void main() {
  const fatiha = QuranChapterSummary(
    number: 1,
    arabicName: 'سُورَةُ ٱلْفَاتِحَةِ',
    latinName: 'Al-Faatiha',
    ayahCount: 7,
    revelationType: 'Meccan',
  );
  const ikhlas = QuranChapterSummary(
    number: 112,
    arabicName: 'سُورَةُ الإِخْلَاصِ',
    latinName: 'Al-Ikhlaas',
    ayahCount: 4,
    revelationType: 'Meccan',
  );

  test('contains a localized search name for every surah', () {
    expect(quranRussianNames, hasLength(114));
  });

  test('matches surahs by Russian, Latin, Arabic, and number', () {
    expect(quranChapterMatches(fatiha, 'Фатиха'), isTrue);
    expect(quranChapterMatches(fatiha, 'faatiha'), isTrue);
    expect(quranChapterMatches(fatiha, 'الفاتحة'), isTrue);
    expect(quranChapterMatches(fatiha, '1'), isTrue);
    expect(quranChapterMatches(ikhlas, 'Ихлас'), isTrue);
    expect(quranChapterMatches(ikhlas, '112'), isTrue);
    expect(quranChapterMatches(fatiha, 'Бакара'), isFalse);
  });
}
