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

  bool isDue([DateTime? now]) =>
      !nextReviewAt.isAfter(now ?? DateTime.now());

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

  factory HafizProgress.fromJson(Map<String, dynamic> json) => HafizProgress(
        surahNumber: (json['surahNumber'] as num).toInt(),
        surahName: json['surahName'] as String? ?? 'Сура',
        verseNumber: (json['verseNumber'] as num).toInt(),
        globalVerseNumber: (json['globalVerseNumber'] as num).toInt(),
        attempts: (json['attempts'] as num?)?.toInt() ?? 1,
        repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
        bestScore: (json['bestScore'] as num?)?.toInt() ?? 0,
        mastery: (json['mastery'] as num?)?.toDouble() ?? 0,
        lastReviewedAt: DateTime.parse(json['lastReviewedAt'] as String),
        nextReviewAt: DateTime.parse(json['nextReviewAt'] as String),
      );

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
