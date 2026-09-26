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
    // Primary audio now points at the public CDN on every platform (the old
    // localhost proxy route returned 404 in production).
    expect(
      chapter.verses.single.audioUrl,
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/1.mp3',
    );
    expect(chapter.verses.single.audioFallbackUrl,
        'https://everyayah.com/data/Alafasy_128kbps/001001.mp3');
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

  test('searches verse text in the locale-specific edition', () async {
    final repository = QuranRepository(client: MockClient(_successfulApi));

    final matches = await repository.searchAyahs(
      'милость',
      localeCode: 'ru',
    );

    expect(matches, hasLength(1));
    expect(matches.single.surahNumber, 2);
    expect(matches.single.ayahNumber, 40);
    expect(matches.single.text, contains('милость'));
    repository.dispose();
  });

  test('loads Kazakh translation for the Kazakh UI locale', () async {
    final repository = QuranRepository(
      client: MockClient(_successfulApi),
      canonicalArabic: Future.value({
        1: ['بِسْمِ ٱللَّهِ']
      }),
    );
    final chapters = await repository.fetchChapters();

    final chapter = await repository.fetchChapter(
      chapters.first,
      localeCode: 'kk',
    );

    expect(chapter.verses.single.translation, 'Аса қамқор Алланың атымен');
    expect(chapter.verses.single.transliteration, 'Bismillah');
    repository.dispose();
  });

  test('Arabic reader requests only canonical text and recitation', () async {
    final paths = <String>[];
    final repository = QuranRepository(
      client: MockClient((request) {
        paths.add(request.url.path);
        return _successfulApi(request);
      }),
      canonicalArabic: Future.value({
        1: ['بِسْمِ ٱللَّهِ']
      }),
    );
    final chapters = await repository.fetchChapters();
    final chapter =
        await repository.fetchChapter(chapters.first, localeCode: 'ar');
    expect(paths.last, endsWith('/editions/quran-uthmani,ar.alafasy'));
    expect(chapter.verses.single.arabicText, 'بِسْمِ ٱللَّهِ');
    expect(chapter.verses.single.translation, isEmpty);
    expect(chapter.verses.single.transliteration, isEmpty);
    repository.dispose();

    final offline = QuranRepository(
      client: MockClient((_) async => http.Response('unavailable', 503)),
      canonicalArabic: Future.value({
        1: ['بِسْمِ ٱللَّهِ']
      }),
    );
    final cached = await offline.fetchChapter(chapters.first, localeCode: 'ar');
    expect(cached.verses.single.arabicText, 'بِسْمِ ٱللَّهِ');
    expect(cached.verses.single.translation, isEmpty);
    expect(cached.verses.single.transliteration, isEmpty);
    offline.dispose();
  });

  test('Arabic search never falls back to a Russian edition', () async {
    final paths = <String>[];
    final repository = QuranRepository(client: MockClient((request) async {
      paths.add(request.url.path);
      return _jsonResponse({
        'code': 200,
        'data': {'matches': []}
      });
    }));
    await repository.searchAyahs('رحمة', localeCode: 'ar');
    await repository.searchAyahs('rahma', localeCode: 'ar');
    expect(paths, hasLength(2));
    expect(paths.every((path) => path.endsWith('/all/quran-uthmani')), isTrue);
    repository.dispose();
  });

  test('rejects a 114-item chapter list with the wrong order', () async {
    final repository = QuranRepository(
      client: MockClient((request) async {
        final response = await _successfulApi(request);
        final root = jsonDecode(response.body) as Map<String, dynamic>;
        if (request.url.path.endsWith('/surah')) {
          root['data'] = (root['data'] as List).reversed.toList();
        }
        return _jsonResponse(root);
      }),
    );

    await expectLater(
      repository.fetchChapters(),
      throwsA(isA<QuranRepositoryException>()),
    );
    repository.dispose();
  });
}

Future<http.Response> _successfulApi(http.Request request) async {
  if (request.url.path.contains('/search/')) {
    expect(request.url.path, contains('/all/ru.kuliev'));
    return _jsonResponse({
      'code': 200,
      'status': 'OK',
      'data': {
        'count': 1,
        'matches': [
          {
            'number': 47,
            'text': 'Помните милость, которую Я оказал вам.',
            'numberInSurah': 40,
            'surah': {
              'number': 2,
              'name': 'سُورَةُ البَقَرَةِ',
              'englishName': 'Al-Baqara',
              'englishNameTranslation': 'The Cow',
              'numberOfAyahs': 286,
              'revelationType': 'Medinan',
            },
          },
        ],
      },
    });
  }
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
    final kazakh = request.url.path.contains('kk.khalifahaltai');
    return _jsonResponse({
      'code': 200,
      'status': 'OK',
      'data': [
        _edition('quran-uthmani', 'بِسْمِ ٱللَّهِ'),
        _edition(
          kazakh ? 'kk.khalifahaltai' : 'ru.kuliev',
          kazakh ? 'Аса қамқор Алланың атымен' : 'Во имя Аллаха',
        ),
        _edition(
          kazakh ? 'en.transliteration' : 'ru.transliteration',
          kazakh ? 'Bismillah' : 'Бисмиллях',
        ),
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
