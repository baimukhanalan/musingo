enum KnowledgeKind {
  letter,
  word,
  ayah,
  meaning,
  rule,
  pronunciation,
  matching,
}

class KnowledgeState {
  final String id;
  final String lessonId;
  final String label;
  final KnowledgeKind kind;
  final double strength;
  final int repetitions;
  final int lapses;
  final DateTime lastReviewedAt;
  final DateTime nextReviewAt;

  const KnowledgeState({
    required this.id,
    required this.lessonId,
    required this.label,
    required this.kind,
    required this.strength,
    required this.repetitions,
    required this.lapses,
    required this.lastReviewedAt,
    required this.nextReviewAt,
  });

  bool isDue([DateTime? now]) =>
      !nextReviewAt.isAfter(now ?? DateTime.now());

  bool get isWeak => strength < 0.6 || lapses > repetitions;

  KnowledgeState reviewed({
    required bool wasWeak,
    required DateTime reviewedAt,
  }) {
    if (wasWeak) {
      return KnowledgeState(
        id: id,
        lessonId: lessonId,
        label: label,
        kind: kind,
        strength: (strength * 0.55).clamp(0.2, 0.55).toDouble(),
        repetitions: repetitions,
        lapses: lapses + 1,
        lastReviewedAt: reviewedAt,
        nextReviewAt: reviewedAt.add(const Duration(days: 1)),
      );
    }

    final nextRepetitions = repetitions + 1;
    const intervals = [1, 3, 7, 14, 30, 60];
    final intervalIndex =
        (nextRepetitions - 1).clamp(0, intervals.length - 1).toInt();
    return KnowledgeState(
      id: id,
      lessonId: lessonId,
      label: label,
      kind: kind,
      strength: (strength + 0.18).clamp(0.0, 1.0).toDouble(),
      repetitions: nextRepetitions,
      lapses: lapses,
      lastReviewedAt: reviewedAt,
      nextReviewAt: reviewedAt.add(Duration(days: intervals[intervalIndex])),
    );
  }

  factory KnowledgeState.initial({
    required String id,
    required String lessonId,
    required String label,
    required KnowledgeKind kind,
    required DateTime reviewedAt,
    required bool wasWeak,
  }) {
    return KnowledgeState(
      id: id,
      lessonId: lessonId,
      label: label,
      kind: kind,
      strength: wasWeak ? 0.35 : 0.7,
      repetitions: wasWeak ? 0 : 1,
      lapses: wasWeak ? 1 : 0,
      lastReviewedAt: reviewedAt,
      nextReviewAt: reviewedAt.add(const Duration(days: 1)),
    );
  }

  factory KnowledgeState.fromJson(Map<String, dynamic> json) {
    return KnowledgeState(
      id: json['id'] as String,
      lessonId: json['lessonId'] as String,
      label: json['label'] as String? ?? 'Учебный элемент',
      kind: KnowledgeKind.values.firstWhere(
        (kind) => kind.name == json['kind'],
        orElse: () => KnowledgeKind.word,
      ),
      strength: (json['strength'] as num?)?.toDouble() ?? 0.5,
      repetitions: (json['repetitions'] as num?)?.toInt() ?? 0,
      lapses: (json['lapses'] as num?)?.toInt() ?? 0,
      lastReviewedAt: DateTime.parse(json['lastReviewedAt'] as String),
      nextReviewAt: DateTime.parse(json['nextReviewAt'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'label': label,
        'kind': kind.name,
        'strength': strength,
        'repetitions': repetitions,
        'lapses': lapses,
        'lastReviewedAt': lastReviewedAt.toIso8601String(),
        'nextReviewAt': nextReviewAt.toIso8601String(),
      };
}
