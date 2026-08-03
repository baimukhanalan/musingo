import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/coach.dart';
import 'package:muslingo/models/knowledge_state.dart';
import 'package:muslingo/models/learning_profile.dart';
import 'package:muslingo/services/coach_service.dart';

void main() {
  final service = CoachService();

  CoachContext context({
    int due = 0,
    List<KnowledgeState> weak = const [],
  }) => CoachContext(
        goal: LearningGoal.shortSurahs,
        placementLevel: 3,
        recommendation: 'Закрепи чтение коротких аятов.',
        recommendedLessonId: 'q1',
        recommendedLessonTitle: 'Аль-Фатиха: начало',
        dueReviewCount: due,
        weakKnowledge: weak,
      );

  test('uses personal memory state for todays review', () {
    final response = service.answer(
      'Что повторить сегодня?',
      context(due: 3),
    );

    expect(response.text, contains('3 элемента'));
    expect(response.lessonId, 'q1');
    expect(response.actionType, CoachActionType.startLesson);
    expect(response.sources.single.category, 'Персональные данные');
  });

  test('religious explanation always includes a verified source', () {
    final response = service.answer(
      'Объясни Аль-Фатиху просто',
      context(),
    );

    expect(response.sources, isNotEmpty);
    expect(response.sources.single.category, 'Коран');
    expect(response.sources.single.url, startsWith('https://quran.com/'));
    expect(response.text, contains('не тафсир от AI'));
  });

  test('routes fatwa and health questions to a specialist', () {
    final response = service.answer(
      'Это лекарство халяль и можно ли мне его принимать?',
      context(),
    );

    expect(response.actionType, CoachActionType.contactSpecialist);
    expect(response.actionLabel, 'Обратиться к специалисту');
    expect(response.sources.single.url, CoachService.specialistUrl);
    expect(response.text, isNot(contains('можно принимать')));
  });

  test('does not invent an answer outside the curated knowledge base', () {
    final response = service.answer(
      'Расскажи подробно о неизвестной спорной книге',
      context(),
    );

    expect(response.actionType, isNull);
    expect(response.sources, isEmpty);
    expect(response.text, contains('нет достаточно точного ответа'));
  });
}
