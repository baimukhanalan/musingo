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
    List<String> completedTitles = const [],
    int hafizDue = 0,
    int memorized = 0,
  }) =>
      CoachContext(
        goal: LearningGoal.shortSurahs,
        placementLevel: 3,
        recommendation: 'Закрепи чтение коротких аятов.',
        recommendedLessonId: 'q1',
        recommendedLessonTitle: 'Аль-Фатиха: начало',
        dueReviewCount: due,
        weakKnowledge: weak,
        totalLessons: 12,
        totalCatalogLessons: 136,
        todayProgress: 1,
        dailyGoal: 3,
        quranCompleted: 7,
        arabicCompleted: 3,
        basicsCompleted: 2,
        tajwidCompleted: 1,
        memoryAccuracy: 0.82,
        hafizDueCount: hafizDue,
        memorizedVerseCount: memorized,
        completedLessonTitles: completedTitles,
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

  test('recommends the next short surah from completed material', () {
    final response = service.answer(
      'Какую суру мне учить следующей?',
      context(completedTitles: const ['Аль-Фатиха: начало']),
    );

    expect(response.text, contains('Аль-Ихлас'));
    expect(
        response.sources.any((source) => source.url?.contains('/112') == true),
        isTrue);
    expect(response.actionType, CoachActionType.openQuran);
  });

  test('opens Hafiz with the real repetition context', () {
    final response = service.answer(
      'Помоги запомнить суру наизусть',
      context(hafizDue: 2, memorized: 5),
    );

    expect(response.text, contains('2 назначенных аятов'));
    expect(response.text, contains('5 аятов'));
    expect(response.actionType, CoachActionType.openHafiz);
  });

  test('mini test starts a real recommended lesson', () {
    final response = service.answer('Дай мне небольшой тест', context());

    expect(response.text, contains('короткую проверку'));
    expect(response.lessonId, 'q1');
    expect(response.actionType, CoachActionType.startLesson);
  });

  test('Tajwid question opens pronunciation practice', () {
    final response = service.answer(
      'Какое правило таджвида и мадда мне повторить?',
      context(),
    );

    expect(response.text, contains('Сначала обязательно прослушай'));
    expect(response.text, contains('не заменяет учителя таджвида'));
    expect(response.actionType, CoachActionType.startLesson);
  });

  test('known Quran vocabulary stays source grounded', () {
    final response = service.answer('Что означает слово альхамду?', context());

    expect(response.text, contains('всеобъемлющую хвалу'));
    expect(response.sources.single.url, 'https://quran.com/ru/1');
    expect(response.actionType, CoachActionType.openQuran);
  });
}
