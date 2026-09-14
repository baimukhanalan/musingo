class CurriculumProgress {
  final Set<String> completedModuleIds;
  final Map<String, int> stepByModuleId;
  final Map<String, int> masteryByModuleId;
  final String? lastModuleId;
  final DateTime? lastActivityAt;

  const CurriculumProgress({
    this.completedModuleIds = const {},
    this.stepByModuleId = const {},
    this.masteryByModuleId = const {},
    this.lastModuleId,
    this.lastActivityAt,
  });

  double completionFor(String moduleId, {int totalSteps = 5}) {
    if (completedModuleIds.contains(moduleId)) return 1;
    return ((stepByModuleId[moduleId] ?? 0) / totalSteps).clamp(0, 1);
  }

  int get completedCount => completedModuleIds.length;

  CurriculumProgress mergedWith(CurriculumProgress other) {
    final completed = <String>{
      ...completedModuleIds,
      ...other.completedModuleIds,
    };
    final steps = Map<String, int>.from(stepByModuleId);
    for (final entry in other.stepByModuleId.entries) {
      final current = steps[entry.key] ?? 0;
      if (entry.value > current) steps[entry.key] = entry.value;
    }
    final mastery = Map<String, int>.from(masteryByModuleId);
    for (final entry in other.masteryByModuleId.entries) {
      final current = mastery[entry.key] ?? 0;
      if (entry.value > current) mastery[entry.key] = entry.value;
    }
    final otherIsNewer = other.lastActivityAt != null &&
        (lastActivityAt == null ||
            other.lastActivityAt!.isAfter(lastActivityAt!));
    return CurriculumProgress(
      completedModuleIds: completed,
      stepByModuleId: steps,
      masteryByModuleId: mastery,
      lastModuleId: otherIsNewer ? other.lastModuleId : lastModuleId,
      lastActivityAt: otherIsNewer ? other.lastActivityAt : lastActivityAt,
    );
  }

  Map<String, dynamic> toJson() => {
        'completedModuleIds': completedModuleIds.toList(growable: false),
        'stepByModuleId': stepByModuleId,
        'masteryByModuleId': masteryByModuleId,
        'lastModuleId': lastModuleId,
        'lastActivityAt': lastActivityAt?.toIso8601String(),
      };

  factory CurriculumProgress.fromJson(Map<String, dynamic> json) {
    final completed = (json['completedModuleIds'] as List<dynamic>? ?? const [])
        .whereType<String>()
        .toSet();
    final steps = Map<String, dynamic>.from(
      json['stepByModuleId'] as Map? ?? const {},
    ).map((key, value) => MapEntry(key, (value as num?)?.round() ?? 0));
    final mastery = Map<String, dynamic>.from(
      json['masteryByModuleId'] as Map? ?? const {},
    ).map((key, value) => MapEntry(key, (value as num?)?.round() ?? 0));
    return CurriculumProgress(
      completedModuleIds: completed,
      stepByModuleId: steps,
      masteryByModuleId: mastery,
      lastModuleId: json['lastModuleId'] as String?,
      lastActivityAt: DateTime.tryParse(
        json['lastActivityAt'] as String? ?? '',
      ),
    );
  }
}
