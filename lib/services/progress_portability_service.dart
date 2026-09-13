import 'dart:convert';

import '../models/hafiz_progress.dart';
import '../models/learning_profile.dart';
import '../models/lesson.dart';
import 'app_state.dart';

/// Builds a portable, privacy-safe snapshot from AppState's public surface.
///
/// Account identifiers, contact details, authentication data, subscriptions,
/// notification preferences, and voice recordings are deliberately excluded.
class ProgressPortabilityService {
  static const String format = 'muslingo-progress';
  static const int schemaVersion = 1;

  const ProgressPortabilityService();

  Map<String, dynamic> buildSnapshot(
    AppState state, {
    DateTime? exportedAt,
  }) {
    final completedLessons = state.courses
        .expand((course) => course.lessons)
        .where((lesson) => lesson.status == LessonStatus.completed)
        .map((lesson) => lesson.id)
        .toList(growable: false)
      ..sort();

    final completedByCourse = <String, int>{
      for (final course in state.courses)
        course.type.name: course.completedLessons,
    };

    final hafizProgress = state.hafizProgress
        .map((progress) => progress.toJson())
        .toList(growable: false);
    final surahsWithMemorizedVerses = state.hafizProgress
        .where((progress) => progress.mastery >= 0.7)
        .map((progress) => progress.surahNumber)
        .toSet()
        .toList(growable: false)
      ..sort();

    final user = state.user;
    return <String, dynamic>{
      'format': format,
      'schemaVersion': schemaVersion,
      'exportedAt': (exportedAt ?? DateTime.now()).toUtc().toIso8601String(),
      'learningProfile': <String, dynamic>{
        'goal': state.learningGoal?.name,
        'placementLevel': state.placementLevel,
        'recommendation': state.learningRecommendation,
        'skillScores': state.learningSkillProfile?.toJson(),
        'appLocale': state.locale.code,
        'nativeLanguage': state.nativeLanguage?.code,
      },
      'progress': <String, dynamic>{
        'completedLessonIds': completedLessons,
        'completedLessonsByCourse': completedByCourse,
        'knowledgeStates': state.knowledgeStates
            .map((knowledge) => knowledge.toJson())
            .toList(growable: false),
        'hafizProgress': hafizProgress,
        'surahsWithMemorizedVerses': surahsWithMemorizedVerses,
      },
      'studyStats': <String, dynamic>{
        'xp': user?.xp ?? 0,
        'level': user?.level ?? 1,
        'streak': user?.streak ?? 0,
        'totalLessons': user?.totalLessons ?? 0,
        'totalMinutes': user?.totalMinutes ?? 0,
        'learnedAyats': user?.learnedAyats ?? 0,
        'learnedDuas': user?.learnedDuas ?? 0,
        'lessonAttempts': user?.lessonAttempts ?? 0,
        'speechAttempts': user?.speechAttempts ?? 0,
        'lastStudyDate': user?.lastStudyDate?.toUtc().toIso8601String(),
      },
      'privacy': <String, dynamic>{
        'containsIdentity': false,
        'containsAuthentication': false,
        'containsVoiceRecordings': false,
        'containsNotificationSettings': false,
      },
    };
  }

  String encodeSnapshot(
    AppState state, {
    DateTime? exportedAt,
  }) {
    return const JsonEncoder.withIndent('  ').convert(
      buildSnapshot(state, exportedAt: exportedAt),
    );
  }

  PortableProgressPreview decodeAndPreview(String source, AppState state) {
    final decoded = jsonDecode(source);
    if (decoded is! Map) {
      throw const FormatException('Корень файла должен быть JSON-объектом.');
    }
    final snapshot = Map<String, dynamic>.from(decoded);
    if (snapshot['format'] != format ||
        snapshot['schemaVersion'] != schemaVersion) {
      throw const FormatException(
          'Это не поддерживаемый файл прогресса Muslingo.');
    }
    final progress = snapshot['progress'];
    if (progress is! Map) {
      throw const FormatException('В файле отсутствует раздел прогресса.');
    }
    _validateLearningProfile(snapshot['learningProfile']);
    final hafizItems = _list(progress, 'hafizProgress');
    for (final raw in hafizItems) {
      if (raw is! Map) {
        throw const FormatException('Некорректная запись Hafiz.');
      }
      HafizProgress.fromJson(Map<String, dynamic>.from(raw));
    }
    final knownLessonIds = state.courses
        .expand((course) => course.lessons)
        .map((lesson) => lesson.id)
        .toSet();
    final completed = _list(progress, 'completedLessonIds')
        .whereType<String>()
        .where(knownLessonIds.contains)
        .toSet();
    final knowledge = _list(progress, 'knowledgeStates')
        .whereType<Map>()
        .where((item) => knownLessonIds.contains(item['lessonId']))
        .length;
    final hafiz = hafizItems.length;
    if (completed.isEmpty && knowledge == 0 && hafiz == 0) {
      throw const FormatException(
          'В файле нет совместимого учебного прогресса.');
    }
    return PortableProgressPreview(
      snapshot: snapshot,
      completedLessons: completed.length,
      knowledgeItems: knowledge,
      hafizItems: hafiz,
    );
  }

  static List<dynamic> _list(Map progress, String key) {
    final value = progress[key];
    if (value == null) return const [];
    if (value is! List) {
      throw FormatException('Поле $key должно быть списком.');
    }
    return value;
  }

  static void _validateLearningProfile(Object? raw) {
    if (raw == null) return;
    if (raw is! Map) {
      throw const FormatException('Некорректный учебный профиль.');
    }
    final goal = raw['goal'];
    final recommendation = raw['recommendation'];
    final placement = raw['placementLevel'];
    if (goal != null && goal is! String ||
        recommendation != null && recommendation is! String ||
        placement != null &&
            (placement is! num ||
                !placement.isFinite ||
                placement % 1 != 0 ||
                placement < 1 ||
                placement > 8)) {
      throw const FormatException('Некорректный учебный профиль.');
    }
    final scores = raw['skillScores'];
    if (scores == null) return;
    if (scores is! Map) {
      throw const FormatException('Некорректные оценки навыков.');
    }
    LearningSkillProfile.fromJson(Map<String, dynamic>.from(scores));
  }
}

class PortableProgressPreview {
  final Map<String, dynamic> snapshot;
  final int completedLessons;
  final int knowledgeItems;
  final int hafizItems;

  const PortableProgressPreview({
    required this.snapshot,
    required this.completedLessons,
    required this.knowledgeItems,
    required this.hafizItems,
  });
}
