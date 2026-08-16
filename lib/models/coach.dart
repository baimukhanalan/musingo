import 'knowledge_state.dart';
import 'learning_profile.dart';

enum CoachRole { user, coach }

enum CoachActionType { startLesson, openQuran, openHafiz, contactSpecialist }

class CoachSource {
  final String title;
  final String category;
  final String verification;
  final String? url;

  const CoachSource({
    required this.title,
    required this.category,
    required this.verification,
    this.url,
  });
}

class CoachResponse {
  final String text;
  final List<CoachSource> sources;
  final CoachActionType? actionType;
  final String? actionLabel;
  final String? lessonId;

  const CoachResponse({
    required this.text,
    this.sources = const [],
    this.actionType,
    this.actionLabel,
    this.lessonId,
  });
}

class CoachMessage {
  final String id;
  final CoachRole role;
  final String text;
  final DateTime createdAt;
  final List<CoachSource> sources;
  final CoachActionType? actionType;
  final String? actionLabel;
  final String? lessonId;

  const CoachMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.sources = const [],
    this.actionType,
    this.actionLabel,
    this.lessonId,
  });
}

class CoachContext {
  final LearningGoal? goal;
  final int placementLevel;
  final String? recommendation;
  final String? recommendedLessonId;
  final String? recommendedLessonTitle;
  final int dueReviewCount;
  final List<KnowledgeState> weakKnowledge;
  final int xp;
  final int streak;
  final int totalLessons;
  final int totalCatalogLessons;
  final int todayProgress;
  final int dailyGoal;
  final int memorizedVerseCount;
  final int hafizDueCount;
  final int quranCompleted;
  final int arabicCompleted;
  final int basicsCompleted;
  final double memoryAccuracy;
  final List<String> completedLessonTitles;

  const CoachContext({
    required this.goal,
    required this.placementLevel,
    required this.recommendation,
    required this.recommendedLessonId,
    required this.recommendedLessonTitle,
    required this.dueReviewCount,
    required this.weakKnowledge,
    this.xp = 0,
    this.streak = 0,
    this.totalLessons = 0,
    this.totalCatalogLessons = 0,
    this.todayProgress = 0,
    this.dailyGoal = 3,
    this.memorizedVerseCount = 0,
    this.hafizDueCount = 0,
    this.quranCompleted = 0,
    this.arabicCompleted = 0,
    this.basicsCompleted = 0,
    this.memoryAccuracy = 0,
    this.completedLessonTitles = const [],
  });
}
