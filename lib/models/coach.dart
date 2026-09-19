import 'knowledge_state.dart';
import 'learning_profile.dart';
import 'mentor_profile.dart';

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

class CoachPlanItem {
  final String title;
  final String detail;
  final String? lessonId;
  final bool isReview;

  const CoachPlanItem({
    required this.title,
    this.detail = '',
    this.lessonId,
    this.isReview = false,
  });
}

class CoachResponse {
  final String text;
  final String? memorySuggestion;
  final List<CoachSource> sources;
  final String? reasoning;
  final List<CoachPlanItem> dailyPlan;
  final String? nextAction;
  final CoachActionType? actionType;
  final String? actionLabel;
  final String? lessonId;

  const CoachResponse({
    required this.text,
    this.memorySuggestion,
    this.sources = const [],
    this.reasoning,
    this.dailyPlan = const [],
    this.nextAction,
    this.actionType,
    this.actionLabel,
    this.lessonId,
  });
}

class CoachMessage {
  final String id;
  final CoachRole role;
  final String text;
  final String? memorySuggestion;
  final DateTime createdAt;
  final List<CoachSource> sources;
  final String? reasoning;
  final List<CoachPlanItem> dailyPlan;
  final String? nextAction;
  final CoachActionType? actionType;
  final String? actionLabel;
  final String? lessonId;

  const CoachMessage({
    required this.id,
    required this.role,
    required this.text,
    this.memorySuggestion,
    required this.createdAt,
    this.sources = const [],
    this.reasoning,
    this.dailyPlan = const [],
    this.nextAction,
    this.actionType,
    this.actionLabel,
    this.lessonId,
  });
}

class CoachContext {
  final LearningGoal? goal;
  final LearningSkillProfile? skillProfile;
  final int placementLevel;
  final String? recommendation;
  final String? recommendedLessonId;
  final String? recommendedLessonTitle;
  final int dueReviewCount;
  final List<KnowledgeState> dueKnowledge;
  final List<KnowledgeState> weakKnowledge;
  final DateTime? nextReviewAt;
  final String? recommendedCourse;
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
  final int tajwidCompleted;
  final double memoryAccuracy;
  final List<String> completedLessonTitles;
  final List<String> knownSurahs;
  final int availableMinutes;
  final int hearts;
  final int energy;
  final int lessonAttempts;
  final int speechAttempts;
  final int learnedAyats;
  final int learnedDuas;
  final DateTime? lastStudyAt;
  final MentorProfile mentorProfile;
  final List<Map<String, String>> conversationHistory;

  const CoachContext({
    required this.goal,
    this.skillProfile,
    required this.placementLevel,
    required this.recommendation,
    required this.recommendedLessonId,
    required this.recommendedLessonTitle,
    required this.dueReviewCount,
    this.dueKnowledge = const [],
    required this.weakKnowledge,
    this.nextReviewAt,
    this.recommendedCourse,
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
    this.tajwidCompleted = 0,
    this.memoryAccuracy = 0,
    this.completedLessonTitles = const [],
    this.knownSurahs = const [],
    this.availableMinutes = 6,
    this.hearts = 5,
    this.energy = 0,
    this.lessonAttempts = 0,
    this.speechAttempts = 0,
    this.learnedAyats = 0,
    this.learnedDuas = 0,
    this.lastStudyAt,
    this.mentorProfile = const MentorProfile(),
    this.conversationHistory = const [],
  });
}
