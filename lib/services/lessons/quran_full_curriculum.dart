import 'dart:convert';

import '../../models/lesson.dart';

/// A complete, source-preserving reading/listening path, not a tafsir course.
/// Arabic is loaded once from the unchanged, attributed Tanzil asset; it is not
/// generated, translated, rewritten, or copied into the server manifest.
class QuranFullCurriculum {
  static const assetPath = 'assets/data/quran-uthmani-tanzil.txt';
  static const manifestPath = 'docs/content/quran-full-curriculum-v1.json';
  static const schemaVersion = 1;
  static const targetSeconds = 360;
  static const maximumEstimatedSeconds = 420;
  static const maximumAyahsPerUnit = 12;
  static const firstLessonOrder = 101;
  static const sourceUrl = 'https://tanzil.net';

  final List<QuranReadingUnit> units;

  const QuranFullCurriculum._(this.units);

  factory QuranFullCurriculum.fromCanonicalText(String text) {
    final chapters = <List<QuranReadingAyah>>[
      for (var index = 0; index < quranCanonicalAyahCounts.length; index++) [],
    ];
    var globalNumber = 0;
    var previousSurah = 1;
    for (final line in const LineSplitter().convert(text)) {
      if (line.trim().isEmpty || line.startsWith('#')) continue;
      final match = RegExp(r'^(\d+)\|(\d+)\|(.+)$').firstMatch(line);
      if (match == null) {
        throw const FormatException('Invalid Quran asset row.');
      }
      final surah = int.parse(match[1]!);
      final ayah = int.parse(match[2]!);
      if (surah < 1 || surah > chapters.length || surah < previousSurah) {
        throw const FormatException('Invalid Quran chapter order.');
      }
      if (ayah != chapters[surah - 1].length + 1) {
        throw const FormatException('Missing or duplicate Quran ayah.');
      }
      previousSurah = surah;
      chapters[surah - 1].add(QuranReadingAyah(
        surah: surah,
        number: ayah,
        globalNumber: ++globalNumber,
        arabic: match[3]!,
      ));
    }
    for (var index = 0; index < chapters.length; index++) {
      if (chapters[index].length != quranCanonicalAyahCounts[index]) {
        throw FormatException('Incomplete Quran chapter ${index + 1}.');
      }
    }
    final units = <QuranReadingUnit>[];
    for (final chapter in chapters) {
      var pending = <QuranReadingAyah>[];
      void finish() {
        if (pending.isEmpty) return;
        final unit = QuranReadingUnit(
          order: firstLessonOrder + units.length,
          ayahs: List.unmodifiable(pending),
        );
        if (unit.estimatedSeconds > maximumEstimatedSeconds) {
          // Never conceal an overlong ayah by clamping the estimate or cutting
          // canonical text. A changed source/timing model must be reviewed.
          throw StateError('Reading unit ${unit.id} exceeds seven minutes.');
        }
        units.add(unit);
        pending = [];
      }

      for (final ayah in chapter) {
        final candidate = [...pending, ayah];
        if (pending.isNotEmpty &&
            (candidate.length > maximumAyahsPerUnit ||
                QuranReadingUnit.estimateSeconds(candidate) > targetSeconds)) {
          finish();
        }
        pending.add(ayah);
      }
      finish();
    }
    return QuranFullCurriculum._(List.unmodifiable(units));
  }

  List<Lesson> lessons() => List.unmodifiable(
        units.map((unit) => unit.toLesson(
              // This is an independent entry point. The earlier 100 guided
              // lessons retain their IDs, positions and completion records.
              available: unit == units.first,
            )),
      );

  Map<String, dynamic> get manifest => {
        'schemaVersion': schemaVersion,
        'sourceAsset': assetPath,
        'sourceUrl': sourceUrl,
        'kind': 'canonical_reading_and_listening_not_tafsir',
        'totalSurahs': quranCanonicalAyahCounts.length,
        'totalAyahs':
            units.fold<int>(0, (sum, unit) => sum + unit.ayahs.length),
        'totalLessons': units.length,
        'durationModel': {
          'kind': 'estimate_not_measured_audio_duration',
          'recitationWordsPerMinute': 50,
          'readingRepetitionWordsPerMinute': 60,
          'introPracticeReviewSeconds': 78,
          'transitionSecondsPerAyah': 6,
          'targetSeconds': targetSeconds,
          'maximumEstimatedSeconds': maximumEstimatedSeconds,
          'note': 'Extra replays, slow reading and network latency add time.',
        },
        'lessons': [for (final unit in units) unit.metadata],
      };
}

class QuranReadingAyah {
  final int surah;
  final int number;
  final int globalNumber;
  final String arabic;

  const QuranReadingAyah({
    required this.surah,
    required this.number,
    required this.globalNumber,
    required this.arabic,
  });

  // Standalone pause/section signs are not words. The canonical Arabic string
  // itself remains untouched, including diacritics and all recitation marks.
  List<String> get words => arabic
      .split(RegExp(r'\s+'))
      .where((token) => RegExp(r'[\u0621-\u064a\u0671]').hasMatch(token))
      .toList(growable: false);
  String get reference => '$surah:$number';
}

class QuranReadingUnit {
  final int order;
  final List<QuranReadingAyah> ayahs;

  const QuranReadingUnit({required this.order, required this.ayahs});

  int get surah => ayahs.first.surah;
  String get id => 'q_full_${surah}_${ayahs.first.number}_${ayahs.last.number}';
  String get reference => ayahs.length == 1
      ? '$surah:${ayahs.first.number}'
      : '$surah:${ayahs.first.number}–${ayahs.last.number}';
  int get wordCount => ayahs.fold(0, (sum, ayah) => sum + ayah.words.length);
  int get estimatedSeconds => estimateSeconds(ayahs);
  int get estimatedMinutes => (estimatedSeconds / 60).ceil();
  int get stepCount => ayahs.length + 4;
  int get xpReward => 25;

  /// Planning estimate for one human-recitation pass, a deliberate read/repeat
  /// pass, two short text-recall exercises, intro/review and step transitions.
  /// 50/60 wpm are explicit pacing assumptions, not measured reciter timings.
  static int estimateSeconds(List<QuranReadingAyah> ayahs) {
    final words = ayahs.fold<int>(0, (sum, ayah) => sum + ayah.words.length);
    return 78 + (words * (60 / 50 + 60 / 60)).ceil() + ayahs.length * 6;
  }

  Map<String, dynamic> get metadata => {
        'id': id,
        'order': order,
        'courseId': 'quran',
        'surah': surah,
        'firstAyah': ayahs.first.number,
        'lastAyah': ayahs.last.number,
        'globalStart': ayahs.first.globalNumber,
        'globalEnd': ayahs.last.globalNumber,
        'wordCount': wordCount,
        'stepCount': stepCount,
        'xpReward': xpReward,
        'estimatedSeconds': estimatedSeconds,
      };

  Lesson toLesson({bool available = false}) {
    final practiceAyah = ayahs.firstWhere(
      (ayah) => ayah.words.toSet().length >= 3,
      orElse: () => ayahs.reduce(
        (a, b) => a.words.length > b.words.length ? a : b,
      ),
    );
    final tokens = practiceAyah.words;
    final closingWord = tokens.last;
    final options = <String>[
      closingWord,
      ...tokens.where((word) => word != closingWord).toSet().take(2),
    ];
    // Very short terminal ayahs can form a unit alone. Other answer options
    // remain verbatim words from this same studied unit, never invented text.
    for (final word in ayahs.expand((ayah) => ayah.words)) {
      if (options.length >= 3) break;
      if (!options.contains(word)) options.add(word);
    }
    if (tokens.length < 2 || options.length < 3) {
      throw StateError(
          'Reading unit $id needs sufficient source text for recall.');
    }
    final answerIndex = order % options.length;
    options.insert(answerIndex, options.removeAt(0));
    final sources = ['Коран $reference', 'Tanzil Project · https://tanzil.net'];
    return Lesson(
      id: id,
      title: 'Коран $reference',
      subtitle: 'Чтение и слушание · ≈$estimatedMinutes мин',
      course: CourseType.quran,
      order: order,
      status: available ? LessonStatus.available : LessonStatus.locked,
      xpReward: xpReward,
      sourceUrl: QuranFullCurriculum.sourceUrl,
      steps: [
        LessonStep(
          id: '${id}_intro',
          type: LessonStepType.text,
          russianText: 'Аяты $reference. Слушай запись и следи за арабским '
              'текстом, затем повтори в своём темпе. Это практика чтения, '
              'а не перевод или тафсир. Ориентир — $estimatedMinutes мин; '
              'дополнительные повторы займут больше времени.\n\n'
              'Арабский текст: Tanzil Project (CC BY 3.0), https://tanzil.net.',
          sourceRefs: sources,
        ),
        for (final ayah in ayahs)
          LessonStep(
            id: '${id}_audio_${ayah.number}',
            type: LessonStepType.audio,
            quranGlobalAyahNumber: ayah.globalNumber,
            arabicText: ayah.arabic,
            russianText: 'Коран ${ayah.reference} · слушай и следи за текстом',
            sourceRefs: ['Коран ${ayah.reference}', sources.last],
          ),
        LessonStep(
          id: '${id}_order',
          type: LessonStepType.wordOrder,
          question: 'Восстанови начало аята ${practiceAyah.reference}',
          // A short recall excerpt, not an altered or truncated audio ayah.
          orderTokens: tokens.take(6).toList(growable: false),
          explanation: 'Это начальный фрагмент уже прочитанного аята. '
              'Восстанови порядок слов по исходному тексту.',
          sourceRefs: sources,
        ),
        LessonStep(
          id: '${id}_recall',
          type: LessonStepType.question,
          question: 'Каким словом заканчивается аят ${practiceAyah.reference}?',
          answers: options,
          correctAnswerIndex: answerIndex,
          explanation: 'Вспомни окончание только что прочитанного аята. '
              'Все варианты взяты из изученного арабского текста.',
          sourceRefs: sources,
        ),
        LessonStep(
          id: '${id}_review',
          type: LessonStepType.text,
          russianText: 'Вернись к трудным местам и повтори их спокойно. '
              'Этот урок отмечает практику чтения и узнавания текста; '
              'он не подтверждает заучивание, понимание тафсира или '
              'правильность таджвида. Для проверки чтения нужен преподаватель.',
          sourceRefs: sources,
        ),
      ],
    );
  }
}

/// Hafs verse addressing used by the bundled Tanzil Uthmani source and the
/// existing Alafasy audio providers (1-based global addresses 1…6236).
const quranCanonicalAyahCounts = <int>[
  7,
  286,
  200,
  176,
  120,
  165,
  206,
  75,
  129,
  109,
  123,
  111,
  43,
  52,
  99,
  128,
  111,
  110,
  98,
  135,
  112,
  78,
  118,
  64,
  77,
  227,
  93,
  88,
  69,
  60,
  34,
  30,
  73,
  54,
  45,
  83,
  182,
  88,
  75,
  85,
  54,
  53,
  89,
  59,
  37,
  35,
  38,
  29,
  18,
  45,
  60,
  49,
  62,
  55,
  78,
  96,
  29,
  22,
  24,
  13,
  14,
  11,
  11,
  18,
  12,
  12,
  30,
  52,
  52,
  44,
  28,
  28,
  20,
  56,
  40,
  31,
  50,
  40,
  46,
  42,
  29,
  19,
  36,
  25,
  22,
  17,
  19,
  26,
  30,
  20,
  15,
  21,
  11,
  8,
  8,
  19,
  5,
  8,
  8,
  11,
  11,
  8,
  3,
  9,
  5,
  4,
  7,
  3,
  6,
  3,
  5,
  4,
  5,
  6,
];
