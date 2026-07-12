import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/quran.dart';

class QuranRepositoryException implements Exception {
  final String message;
  const QuranRepositoryException(this.message);

  @override
  String toString() => message;
}

class QuranRepository {
  static const _primaryBaseUrl = 'https://api.alquran.cloud/v1';
  static const _regionalBaseUrl = 'https://alquran.api.alislam.ru/v1';
  static const _chaptersCacheKey = 'quran_chapters_v1';
  static const _chapterCachePrefix = 'quran_chapter_v1_';
  static const _chapterCacheLruKey = 'quran_chapter_lru_v1';
  static const _fullChapterAudioBaseUrl = 'https://server8.mp3quran.net/afs';
  static const _maxCachedChapters = 114;

  final http.Client _client;
  Future<Map<int, List<String>>>? _canonicalArabicFuture;

  QuranRepository({
    http.Client? client,
    Future<Map<int, List<String>>>? canonicalArabic,
  })  : _client = client ?? http.Client(),
        _canonicalArabicFuture = canonicalArabic;

  Future<List<QuranChapterSummary>> fetchChapters({
    bool forceRefresh = false,
  }) async {
    final preferences = await SharedPreferences.getInstance();
    if (!forceRefresh) {
      final cached = preferences.getString(_chaptersCacheKey);
      if (cached != null) {
        try {
          return _decodeChapterSummaries(cached);
        } catch (_) {
          await preferences.remove(_chaptersCacheKey);
        }
      }
    }

    try {
      final body = await _get('/surah');
      final chapters = _decodeChapterSummaries(body);
      await preferences.setString(_chaptersCacheKey, body);
      return chapters;
    } catch (error) {
      final cached = preferences.getString(_chaptersCacheKey);
      if (cached != null) return _decodeChapterSummaries(cached);
      if (error is QuranRepositoryException) rethrow;
      throw const QuranRepositoryException(
        'Не удалось загрузить список сур.',
      );
    }
  }

  Future<QuranChapter> fetchChapter(QuranChapterSummary summary) async {
    final preferences = await SharedPreferences.getInstance();
    final cacheKey = '$_chapterCachePrefix${summary.number}';
    final canonicalArabic = await _loadCanonicalArabic();

    try {
      final body = await _get(
        '/surah/${summary.number}/editions/'
        'quran-uthmani,ru.kuliev,ru.transliteration,ar.alafasy',
      );
      final chapter = _decodeChapter(summary, body, canonicalArabic);
      await preferences.setString(cacheKey, _encodeCachedChapter(chapter));
      await _touchChapterCache(preferences, summary.number);
      return chapter;
    } catch (error) {
      final cached = preferences.getString(cacheKey);
      if (cached != null) {
        return _decodeCachedChapter(summary, cached, canonicalArabic);
      }
      if (error is QuranRepositoryException) rethrow;
      throw const QuranRepositoryException(
        'Сура не загрузилась. Проверьте интернет и повторите.',
      );
    }
  }

  Future<String> _get(String path) async {
    Object? lastError;
    for (final baseUrl in [_primaryBaseUrl, _regionalBaseUrl]) {
      try {
        final response = await _client.get(
          Uri.parse('$baseUrl$path'),
          headers: const {
            'Accept': 'application/json',
            'Accept-Encoding': 'gzip',
          },
        ).timeout(const Duration(seconds: 15));
        if (response.statusCode == 200) return response.body;
        lastError = 'HTTP ${response.statusCode}';
      } catch (error) {
        lastError = error;
      }
    }
    throw QuranRepositoryException(
      'Источник Корана временно недоступен: $lastError',
    );
  }

  List<QuranChapterSummary> _decodeChapterSummaries(String body) {
    final root = jsonDecode(body) as Map<String, dynamic>;
    if (root['code'] != 200 || root['data'] is! List) {
      throw const QuranRepositoryException('Источник вернул неверные данные.');
    }
    final chapters = (root['data'] as List)
        .cast<Map<String, dynamic>>()
        .map(QuranChapterSummary.fromJson)
        .toList(growable: false);
    if (chapters.length != 114) {
      throw QuranRepositoryException(
        'Ожидалось 114 сур, получено ${chapters.length}.',
      );
    }
    return chapters;
  }

  QuranChapter _decodeChapter(
    QuranChapterSummary summary,
    String body,
    Map<int, List<String>> canonicalArabic,
  ) {
    final root = jsonDecode(body) as Map<String, dynamic>;
    final editions = (root['data'] as List).cast<Map<String, dynamic>>();
    Map<String, dynamic> edition(String identifier) => editions.firstWhere(
          (item) =>
              (item['edition'] as Map<String, dynamic>)['identifier'] ==
              identifier,
        );

    final arabic = edition('quran-uthmani');
    final translation = edition('ru.kuliev');
    final transliteration = edition('ru.transliteration');
    final audio = edition('ar.alafasy');
    final arabicAyahs = (arabic['ayahs'] as List).cast<Map<String, dynamic>>();
    final translatedAyahs =
        (translation['ayahs'] as List).cast<Map<String, dynamic>>();
    final transliteratedAyahs =
        (transliteration['ayahs'] as List).cast<Map<String, dynamic>>();
    final audioAyahs = (audio['ayahs'] as List).cast<Map<String, dynamic>>();
    final canonicalVerses = canonicalArabic[summary.number];

    final lengths = {
      arabicAyahs.length,
      translatedAyahs.length,
      transliteratedAyahs.length,
      audioAyahs.length,
    };
    if (lengths.length != 1 ||
        arabicAyahs.length != summary.ayahCount ||
        canonicalVerses == null ||
        canonicalVerses.length != summary.ayahCount) {
      throw const QuranRepositoryException(
        'Источники аятов вернули несогласованные данные.',
      );
    }

    final verses = List<QuranVerse>.generate(arabicAyahs.length, (index) {
      final arabicAyah = arabicAyahs[index];
      final translatedAyah = translatedAyahs[index];
      final transliteratedAyah = transliteratedAyahs[index];
      final audioAyah = audioAyahs[index];
      final verseNumber = arabicAyah['numberInSurah'] as int;
      if (translatedAyah['numberInSurah'] != verseNumber ||
          transliteratedAyah['numberInSurah'] != verseNumber ||
          audioAyah['numberInSurah'] != verseNumber) {
        throw const QuranRepositoryException(
          'Нумерация аятов в источниках не совпадает.',
        );
      }
      return QuranVerse(
        globalNumber: arabicAyah['number'] as int,
        numberInChapter: verseNumber,
        arabicText: canonicalVerses[index],
        translation: translatedAyah['text'] as String,
        transliteration: transliteratedAyah['text'] as String,
        audioUrl: _proxiedAudioUrl(arabicAyah['number'] as int),
        audioFallbackUrl:
            (audioAyah['audio'] as String?)?.trim().isNotEmpty == true
                ? (audioAyah['audio'] as String).trim()
                : null,
        juz: arabicAyah['juz'] as int,
        page: arabicAyah['page'] as int,
      );
    }, growable: false);

    return QuranChapter(
      summary: summary,
      verses: verses,
      fullAudioUrl: _fullChapterAudioUrl(summary.number),
    );
  }

  String _encodeCachedChapter(QuranChapter chapter) {
    return jsonEncode({
      'cacheVersion': 2,
      'summary': chapter.summary.toJson(),
      'fullAudioUrl': chapter.fullAudioUrl,
      'verses': chapter.verses
          .map(
            (verse) => {
              'globalNumber': verse.globalNumber,
              'numberInChapter': verse.numberInChapter,
              'arabicText': verse.arabicText,
              'translation': verse.translation,
              'transliteration': verse.transliteration,
              'audioUrl': verse.audioUrl,
              'audioFallbackUrl': verse.audioFallbackUrl,
              'juz': verse.juz,
              'page': verse.page,
            },
          )
          .toList(growable: false),
    });
  }

  QuranChapter _decodeCachedChapter(
    QuranChapterSummary summary,
    String cached,
    Map<int, List<String>> canonicalArabic,
  ) {
    final root = jsonDecode(cached) as Map<String, dynamic>;
    if (root['cacheVersion'] != 2) {
      return _decodeChapter(summary, cached, canonicalArabic);
    }

    final verses = (root['verses'] as List)
        .cast<Map<String, dynamic>>()
        .map(
          (verse) => QuranVerse(
            globalNumber: verse['globalNumber'] as int,
            numberInChapter: verse['numberInChapter'] as int,
            arabicText: verse['arabicText'] as String,
            translation: verse['translation'] as String,
            transliteration: verse['transliteration'] as String,
            audioUrl: verse['audioUrl'] as String,
            audioFallbackUrl: verse['audioFallbackUrl'] as String?,
            juz: verse['juz'] as int,
            page: verse['page'] as int,
          ),
        )
        .toList(growable: false);

    if (verses.length != summary.ayahCount) {
      throw const QuranRepositoryException('Офлайн-кэш суры повреждён.');
    }

    return QuranChapter(
      summary: summary,
      verses: verses,
      fullAudioUrl: root['fullAudioUrl'] as String? ??
          _fullChapterAudioUrl(summary.number),
    );
  }

  String _fullChapterAudioUrl(int chapterNumber) {
    final padded = chapterNumber.toString().padLeft(3, '0');
    return '$_fullChapterAudioBaseUrl/$padded.mp3';
  }

  String fullChapterAudioUrl(int chapterNumber) =>
      _fullChapterAudioUrl(chapterNumber);

  String _proxiedAudioUrl(int globalAyahNumber) {
    const configured = String.fromEnvironment('MUSLINGO_API_URL');
    final baseUrl = configured.isNotEmpty
        ? configured
        : (!kIsWeb && defaultTargetPlatform == TargetPlatform.android)
            ? 'http://10.0.2.2:8090'
            : 'http://127.0.0.1:8090';
    return '$baseUrl/api/muslingo/quran/audio/$globalAyahNumber';
  }

  Future<Map<int, List<String>>> _loadCanonicalArabic() {
    return _canonicalArabicFuture ??= _readCanonicalArabic();
  }

  Future<Map<int, List<String>>> _readCanonicalArabic() async {
    final content = await rootBundle.loadString(
      'assets/data/quran-uthmani-tanzil.txt',
    );
    final chapters = <int, List<String>>{};
    var verseCount = 0;
    for (final line in const LineSplitter().convert(content)) {
      if (line.isEmpty || line.codeUnitAt(0) < 48 || line.codeUnitAt(0) > 57) {
        continue;
      }
      final firstSeparator = line.indexOf('|');
      final secondSeparator = line.indexOf('|', firstSeparator + 1);
      if (firstSeparator <= 0 || secondSeparator <= firstSeparator + 1) {
        throw const QuranRepositoryException(
          'Локальный текст Корана повреждён.',
        );
      }
      final chapter = int.parse(line.substring(0, firstSeparator));
      final verse = int.parse(
        line.substring(firstSeparator + 1, secondSeparator),
      );
      final text = line.substring(secondSeparator + 1);
      final verses = chapters.putIfAbsent(chapter, () => <String>[]);
      if (verse != verses.length + 1 || text.isEmpty) {
        throw const QuranRepositoryException(
          'Нумерация локального текста Корана нарушена.',
        );
      }
      verses.add(text);
      verseCount++;
    }
    if (chapters.length != 114 || verseCount != 6236) {
      throw QuranRepositoryException(
        'Ожидалось 114 сур и 6236 аятов, получено '
        '${chapters.length} и $verseCount.',
      );
    }
    return chapters;
  }

  Future<void> _touchChapterCache(
    SharedPreferences preferences,
    int chapterNumber,
  ) async {
    final lru = preferences.getStringList(_chapterCacheLruKey) ?? <String>[];
    final value = '$chapterNumber';
    lru.remove(value);
    lru.insert(0, value);
    while (lru.length > _maxCachedChapters) {
      final removed = lru.removeLast();
      await preferences.remove('$_chapterCachePrefix$removed');
    }
    await preferences.setStringList(_chapterCacheLruKey, lru);
  }

  void dispose() => _client.close();
}
