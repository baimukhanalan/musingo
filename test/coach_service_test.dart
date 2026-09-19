import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muslingo/models/coach.dart';
import 'package:muslingo/models/knowledge_state.dart';
import 'package:muslingo/models/learning_profile.dart';
import 'package:muslingo/models/mentor_profile.dart';
import 'package:muslingo/services/backend_service.dart';
import 'package:muslingo/services/coach_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final service = CoachService();

  CoachContext context({
    int due = 0,
    List<KnowledgeState> weak = const [],
    List<String> completedTitles = const [],
    int hafizDue = 0,
    int memorized = 0,
    LearningSkillProfile? skillProfile,
    List<KnowledgeState> dueKnowledge = const [],
    int todayProgress = 1,
    int dailyGoal = 3,
    MentorProfile mentorProfile = const MentorProfile(),
  }) =>
      CoachContext(
        goal: LearningGoal.shortSurahs,
        skillProfile: skillProfile,
        placementLevel: 3,
        recommendation: 'Закрепи чтение коротких аятов.',
        recommendedLessonId: 'q1',
        recommendedLessonTitle: 'Аль-Фатиха: начало',
        dueReviewCount: due,
        dueKnowledge: dueKnowledge,
        weakKnowledge: weak,
        totalLessons: 12,
        totalCatalogLessons: 136,
        todayProgress: todayProgress,
        dailyGoal: dailyGoal,
        quranCompleted: 7,
        arabicCompleted: 3,
        basicsCompleted: 2,
        tajwidCompleted: 1,
        memoryAccuracy: 0.82,
        hafizDueCount: hafizDue,
        memorizedVerseCount: memorized,
        completedLessonTitles: completedTitles,
        hearts: 4,
        energy: 18,
        lessonAttempts: 15,
        speechAttempts: 6,
        learnedAyats: 9,
        learnedDuas: 2,
        lastStudyAt: DateTime(2026, 9, 10, 18, 30),
        mentorProfile: mentorProfile,
        conversationHistory: const [
          {'role': 'user', 'text': 'Хочу заниматься утром'}
        ],
      );

  KnowledgeState knowledge({
    required String id,
    required String label,
    required double strength,
    required int lapses,
    bool due = true,
  }) =>
      KnowledgeState(
        id: id,
        lessonId: 'lesson_$id',
        label: label,
        kind: KnowledgeKind.pronunciation,
        strength: strength,
        repetitions: 2,
        lapses: lapses,
        lastReviewedAt: DateTime(2026, 9, 9),
        nextReviewAt: due ? DateTime(2026, 9, 10) : DateTime(2099, 9, 10),
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
    expect(response.dailyPlan, isNotEmpty);
    expect(response.reasoning, contains('просроченных повторений'));
    expect(response.nextAction, contains('Аль-Фатиха'));
  });

  test('sends confirmed mentor memory and conversation continuity', () {
    final payload = service.contextPayload(
      context(
        mentorProfile: MentorProfile(
          preferredName: 'Алан',
          currentFocus: 'таджвид',
          memories: [
            MentorMemory(
              id: 'm1',
              text: 'Лучше учусь утром',
              createdAt: DateTime(2026, 9, 14),
            ),
          ],
        ),
      ),
      xp: 0,
      streak: 0,
      completedLessonIds: const [],
    );

    expect(payload['mentorProfile']['preferredName'], 'Алан');
    expect(payload['mentorProfile']['memories'], hasLength(1));
    expect(payload['conversationHistory'], hasLength(1));
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

  test('daily plan prioritizes a due item with repeated lapses', () {
    final lowStrength = knowledge(
      id: 'low',
      label: 'долгий звук',
      strength: 0.2,
      lapses: 1,
    );
    final repeated = knowledge(
      id: 'repeat',
      label: 'звук ع',
      strength: 0.4,
      lapses: 4,
    );

    final response = service.answer(
      'Что повторить сегодня?',
      context(
        due: 2,
        weak: [lowStrength, repeated],
        dueKnowledge: [lowStrength, repeated],
      ),
    );

    expect(response.dailyPlan.first.isReview, isTrue);
    expect(response.dailyPlan.first.detail, contains('звук ع'));
    expect(response.reasoning, contains('звук ع'));
    expect(response.sources.single.category, 'Персональные данные');
  });

  test('diagnostic weakest skill drives fallback before memory exists', () {
    const profile = LearningSkillProfile({
      LearningSkill.letters: 80,
      LearningSkill.reading: 65,
      LearningSkill.surahRecall: 70,
      LearningSkill.meaning: 20,
      LearningSkill.tajwid: 55,
    });

    final response = service.answer(
      'Какие у меня слабые места?',
      context(skillProfile: profile),
    );

    expect(response.text, contains('Смысл'));
    expect(response.dailyPlan.first.detail, contains('20%'));
    expect(response.reasoning, contains('диагностики'));
  });

  test('context payload carries actionable learner state', () {
    final dueItem = knowledge(
      id: 'review',
      label: 'мадд',
      strength: 0.35,
      lapses: 3,
    );
    final payload = service.contextPayload(
      context(due: 1, weak: [dueItem], dueKnowledge: [dueItem]),
      xp: 900,
      streak: 4,
      completedLessonIds: const ['q0', 'q1'],
    );

    expect(payload['hearts'], 4);
    expect(payload['speechAttempts'], 6);
    expect(payload['lastStudyAt'], '2026-09-10T18:30:00.000');
    expect((payload['dueKnowledge'] as List).single['label'], 'мадд');
    expect((payload['dueItems'] as List).single['dueAt'], isNotEmpty);
    expect(payload['availableMinutes'], 6);
    expect(payload['recentAccuracy'], isA<int>());
    expect((payload['weakKnowledge'] as List).single['lapses'], 3);
    expect((payload['weakAreas'] as List).single, contains('strength=35%'));
    expect((payload['weakAreas'] as List).single, contains('lapses=3'));
  });

  test('backend response parses structured plan and keeps source metadata',
      () async {
    SharedPreferences.setMockInitialValues({});
    final backend = await BackendService.create(
      client: MockClient((request) async {
        final requestBody = jsonDecode(request.body) as Map<String, dynamic>;
        expect(requestBody['context']['dailyGoal'], 3);
        return http.Response(
          jsonEncode({
            'text': 'Сначала повторение.',
            'memorySuggestion': 'Лучше учусь утром перед работой.',
            'reasoning': 'Аят подошёл по расписанию памяти.',
            'dailyPlan': [
              {
                'title': 'Повтори аят',
                'detail': 'Без подсказки',
                'lessonId': 'q1',
                'isReview': true,
              }
            ],
            'nextAction': {'description': 'Открой урок q1'},
            'action': {
              'type': 'startLesson',
              'lessonId': 'q1',
              'label': 'Начать',
            },
            'sources': [
              {
                'title': 'Твой прогресс Muslingo',
                'category': 'Персональные данные',
                'verification': 'Рассчитано на устройстве',
              }
            ],
          }),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final response = await backend.askCoach(
      question: 'Что сегодня?',
      locale: 'ru',
      context: {'dailyGoal': 3},
    );

    expect(response, isNotNull);
    expect(response!.reasoning, contains('расписанию'));
    expect(response.memorySuggestion, 'Лучше учусь утром перед работой.');
    expect(response.dailyPlan.single.lessonId, 'q1');
    expect(response.dailyPlan.single.isReview, isTrue);
    expect(response.nextAction, 'Открой урок q1');
    expect(response.actionType, CoachActionType.startLesson);
    expect(response.sources.single.verification, isNotEmpty);
    backend.dispose();
  });

  test('old backend response is enriched with the local learner plan',
      () async {
    SharedPreferences.setMockInitialValues({});
    final backend = await BackendService.create(
      client: MockClient((_) async => http.Response(
            jsonEncode({
              'text': 'Начни с повторения.',
              'action': {
                'type': 'startLesson',
                'lessonId': 'q1',
                'label': 'Начать',
              },
              'sources': [],
            }),
            200,
            headers: {'content-type': 'application/json'},
          )),
    );
    final dueItem = knowledge(
      id: 'remote_review',
      label: 'аяты 6-7',
      strength: 0.3,
      lapses: 2,
    );

    final response = await service.answerSmart(
      'Что повторить?',
      context(due: 1, weak: [dueItem], dueKnowledge: [dueItem]),
      backend: backend,
      locale: 'ru',
    );

    expect(response.text, 'Начни с повторения.');
    expect(response.dailyPlan.first.detail, contains('аяты 6-7'));
    expect(response.reasoning, contains('просроченных повторений'));
    expect(response.nextAction, contains('Аль-Фатиха'));
    expect(response.sources.single.category, 'Персональные данные');
    backend.dispose();
  });
}
