class HafizProgress {
  final int surahNumber;
  final String surahName;
  final int verseNumber;
  final int globalVerseNumber;
  final int attempts;
  final int repetitions;
  final int bestScore;
  final double mastery;
  final DateTime lastReviewedAt;
  final DateTime nextReviewAt;

  const HafizProgress({
    required this.surahNumber,
    required this.surahName,
    required this.verseNumber,
    required this.globalVerseNumber,
    required this.attempts,
    required this.repetitions,
    required this.bestScore,
    required this.mastery,
    required this.lastReviewedAt,
    required this.nextReviewAt,
  });

  String get id => '$surahNumber:$verseNumber';

  bool isDue([DateTime? now]) => !nextReviewAt.isAfter(now ?? DateTime.now());

  String get masteryLabel {
    if (mastery >= 0.9) return 'Закреплено';
    if (mastery >= 0.7) return 'Уверенно';
    if (mastery >= 0.45) return 'В процессе';
    return 'Начато';
  }

  factory HafizProgress.initial({
    required int surahNumber,
    required String surahName,
    required int verseNumber,
    required int globalVerseNumber,
    required int score,
    required int repetitions,
    required DateTime reviewedAt,
  }) {
    final normalizedScore = score.clamp(0, 100).toInt();
    return HafizProgress(
      surahNumber: surahNumber,
      surahName: surahName,
      verseNumber: verseNumber,
      globalVerseNumber: globalVerseNumber,
      attempts: 1,
      repetitions: repetitions,
      bestScore: normalizedScore,
      mastery: _mastery(normalizedScore, repetitions, 1),
      lastReviewedAt: reviewedAt,
      nextReviewAt: reviewedAt.add(
        Duration(days: _intervalDays(normalizedScore, repetitions)),
      ),
    );
  }

  HafizProgress reviewed({
    required int score,
    required int addedRepetitions,
    required DateTime reviewedAt,
  }) {
    final normalizedScore = score.clamp(0, 100).toInt();
    final nextRepetitions = repetitions + addedRepetitions;
    final nextAttempts = attempts + 1;
    return HafizProgress(
      surahNumber: surahNumber,
      surahName: surahName,
      verseNumber: verseNumber,
      globalVerseNumber: globalVerseNumber,
      attempts: nextAttempts,
      repetitions: nextRepetitions,
      bestScore: normalizedScore > bestScore ? normalizedScore : bestScore,
      mastery: _mastery(
        normalizedScore > bestScore ? normalizedScore : bestScore,
        nextRepetitions,
        nextAttempts,
      ),
      lastReviewedAt: reviewedAt,
      nextReviewAt: reviewedAt.add(
        Duration(days: _intervalDays(normalizedScore, nextRepetitions)),
      ),
    );
  }

  factory HafizProgress.fromJson(Map<String, dynamic> json) {
    int integer(String key,
        {required int min, required int max, int? fallback}) {
      final raw = json[key];
      if (raw == null && fallback != null) return fallback;
      if (raw is! num || !raw.isFinite || raw % 1 != 0) {
        throw FormatException('Некорректное поле Hafiz: $key.');
      }
      final value = raw.toInt();
      if (value < min || value > max) {
        throw FormatException('Поле Hafiz $key вне допустимого диапазона.');
      }
      return value;
    }

    final rawName = json['surahName'];
    if (rawName != null && rawName is! String) {
      throw const FormatException('Некорректное название суры.');
    }
    final surahName = (rawName as String? ?? 'Сура').trim();
    if (surahName.isEmpty || surahName.length > 200) {
      throw const FormatException('Некорректное название суры.');
    }
    final rawMastery = json['mastery'] ?? 0;
    if (rawMastery is! num ||
        !rawMastery.isFinite ||
        rawMastery < 0 ||
        rawMastery > 1) {
      throw const FormatException('Некорректный уровень освоения Hafiz.');
    }
    final rawLastReviewedAt = json['lastReviewedAt'];
    final rawNextReviewAt = json['nextReviewAt'];
    if (rawLastReviewedAt is! String || rawNextReviewAt is! String) {
      throw const FormatException('Некорректные даты Hafiz.');
    }
    final lastReviewedAt = DateTime.tryParse(rawLastReviewedAt);
    final nextReviewAt = DateTime.tryParse(rawNextReviewAt);
    if (lastReviewedAt == null ||
        nextReviewAt == null ||
        nextReviewAt.isBefore(lastReviewedAt)) {
      throw const FormatException('Некорректные даты Hafiz.');
    }

    return HafizProgress(
      surahNumber: integer('surahNumber', min: 1, max: 114),
      surahName: surahName,
      // 286 — максимальное число аятов в одной суре.
      verseNumber: integer('verseNumber', min: 1, max: 286),
      globalVerseNumber: integer('globalVerseNumber', min: 1, max: 6236),
      attempts: integer('attempts', min: 1, max: 1000000, fallback: 1),
      repetitions: integer('repetitions', min: 0, max: 1000000, fallback: 0),
      bestScore: integer('bestScore', min: 0, max: 100, fallback: 0),
      mastery: rawMastery.toDouble(),
      lastReviewedAt: lastReviewedAt,
      nextReviewAt: nextReviewAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'surahNumber': surahNumber,
        'surahName': surahName,
        'verseNumber': verseNumber,
        'globalVerseNumber': globalVerseNumber,
        'attempts': attempts,
        'repetitions': repetitions,
        'bestScore': bestScore,
        'mastery': mastery,
        'lastReviewedAt': lastReviewedAt.toIso8601String(),
        'nextReviewAt': nextReviewAt.toIso8601String(),
      };

  static double _mastery(int score, int repetitions, int attempts) {
    final scorePart = score / 100 * 0.72;
    final repetitionPart = (repetitions / 12).clamp(0.0, 1.0) * 0.2;
    final consistencyPart = (attempts / 5).clamp(0.0, 1.0) * 0.08;
    return (scorePart + repetitionPart + consistencyPart)
        .clamp(0.0, 1.0)
        .toDouble();
  }

  static int _intervalDays(int score, int repetitions) {
    if (score < 60) return 1;
    if (score < 75) return 2;
    if (score < 90) return repetitions >= 6 ? 5 : 3;
    if (repetitions >= 12) return 14;
    if (repetitions >= 6) return 7;
    return 3;
  }
}
