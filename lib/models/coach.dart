import 'knowledge_state.dart';
import 'learning_profile.dart';

enum CoachRole { user, coach }

enum CoachActionType { startLesson, openQuran, contactSpecialist }

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

  const CoachContext({
    required this.goal,
    required this.placementLevel,
    required this.recommendation,
    required this.recommendedLessonId,
    required this.recommendedLessonTitle,
    required this.dueReviewCount,
    required this.weakKnowledge,
  });
}
