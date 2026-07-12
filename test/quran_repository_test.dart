import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muslingo/services/quran_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    SharedPreferences.setMockInitialValues({});
  });

  test('loads all 114 chapter summaries and aligned verse sources', () async {
    final repository = QuranRepository(
      client: MockClient(_successfulApi),
      canonicalArabic: Future.value({
        1: ['بِسْمِ ٱللَّهِ']
      }),
    );

    final chapters = await repository.fetchChapters();
    final chapter = await repository.fetchChapter(chapters.first);

    expect(chapters, hasLength(114));
    expect(chapters.first.number, 1);
    expect(chapter.verses, hasLength(1));
    expect(chapter.verses.single.arabicText, 'بِسْمِ ٱللَّهِ');
    expect(chapter.verses.single.translation, 'Во имя Аллаха');
    expect(chapter.verses.single.transliteration, 'Бисмиллях');
    expect(chapter.verses.single.audioUrl, endsWith('/quran/audio/1'));
    expect(chapter.verses.single.audioFallbackUrl, contains('islamic.network'));
    expect(chapter.fullAudioUrl, 'https://server8.mp3quran.net/afs/001.mp3');

    repository.dispose();
  });

  test('uses the cached chapter when both API hosts are unavailable', () async {
    final online = QuranRepository(
      client: MockClient(_successfulApi),
      canonicalArabic: Future.value({
        1: ['بِسْمِ ٱللَّهِ']
      }),
    );
    final chapters = await online.fetchChapters();
    await online.fetchChapter(chapters.first);
    online.dispose();

    final offline = QuranRepository(
      client: MockClient((_) async => http.Response('unavailable', 503)),
      canonicalArabic: Future.value({
        1: ['بِسْمِ ٱللَّهِ']
      }),
    );
    final chapter = await offline.fetchChapter(chapters.first);

    expect(chapter.verses.single.numberInChapter, 1);
    expect(chapter.verses.single.audioUrl, isNotEmpty);
    expect(chapter.fullAudioUrl, endsWith('/001.mp3'));
    offline.dispose();
  });

}

Future<http.Response> _successfulApi(http.Request request) async {
  if (request.url.path.endsWith('/surah')) {
    final data = List.generate(
      114,
      (index) => {
        'number': index + 1,
        'name': 'سورة ${index + 1}',
        'englishName': 'Surah-${index + 1}',
        'englishNameTranslation': 'Chapter ${index + 1}',
        'numberOfAyahs': 1,
        'revelationType': index.isEven ? 'Meccan' : 'Medinan',
      },
    );
    return _jsonResponse({'code': 200, 'status': 'OK', 'data': data});
  }

  if (request.url.path.contains('/surah/1/editions/')) {
    return _jsonResponse({
      'code': 200,
      'status': 'OK',
      'data': [
        _edition('quran-uthmani', 'بِسْمِ ٱللَّهِ'),
        _edition('ru.kuliev', 'Во имя Аллаха'),
        _edition('ru.transliteration', 'Бисмиллях'),
        _edition(
          'ar.alafasy',
          'بِسْمِ ٱللَّهِ',
          audio: 'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
        ),
      ],
    });
  }

  return http.Response('not found', 404);
}

Map<String, dynamic> _edition(
  String identifier,
  String text, {
  String? audio,
}) {
  return {
    'number': 1,
    'name': 'سُورَةُ ٱلْفَاتِحَةِ',
    'englishName': 'Al-Faatiha',
    'englishNameTranslation': 'The Opening',
    'revelationType': 'Meccan',
    'numberOfAyahs': 1,
    'ayahs': [
      {
        'number': 1,
        'numberInSurah': 1,
        'text': text,
        'juz': 1,
        'manzil': 1,
        'page': 1,
        'ruku': 1,
        'hizbQuarter': 1,
        'sajda': false,
        if (audio != null) 'audio': audio,
      },
    ],
    'edition': {
      'identifier': identifier,
      'language': identifier.startsWith('ru.') ? 'ru' : 'ar',
      'name': identifier,
      'englishName': identifier,
      'format': audio == null ? 'text' : 'audio',
      'type': audio == null ? 'translation' : 'versebyverse',
      'direction': audio == null ? 'ltr' : null,
    },
  };
}

http.Response _jsonResponse(Map<String, dynamic> value) {
  return http.Response(
    jsonEncode(value),
    200,
    headers: const {'content-type': 'application/json; charset=utf-8'},
  );
}
