import '../models/coach.dart';
import '../models/knowledge_state.dart';
import '../models/learning_profile.dart';
import 'backend_service.dart';

class CoachService {
  static const suggestions = [
    'Что повторить сегодня?',
    'Какой урок мне подходит?',
    'Какие у меня слабые места?',
    'Какое правило таджвида повторить?',
    'Дай мне небольшой тест',
    'Какую суру учить следующей?',
    'Помоги запомнить суру',
    'Составь план на 7 дней',
  ];

  static const _progressSource = CoachSource(
    title: 'Твой прогресс Muslingo',
    category: 'Персональные данные',
    verification: 'Рассчитано на этом устройстве',
  );

  static const _fatihahSource = CoachSource(
    title: 'Коран, сура Аль-Фатиха 1:1-7',
    category: 'Коран',
    verification: 'Канонический арабский текст и выбранный перевод',
    url: 'https://quran.com/ru/1',
  );

  static const _ikhlasSource = CoachSource(
    title: 'Коран, сура Аль-Ихлас 112:1-4',
    category: 'Коран',
    verification: 'Канонический арабский текст и выбранный перевод',
    url: 'https://quran.com/ru/112',
  );

  static const _falaqSource = CoachSource(
    title: 'Коран, сура Аль-Фалак 113:1-5',
    category: 'Коран',
    verification: 'Канонический арабский текст и выбранный перевод',
    url: 'https://quran.com/ru/113',
  );

  static const _nasSource = CoachSource(
    title: 'Коран, сура Ан-Нас 114:1-6',
    category: 'Коран',
    verification: 'Канонический арабский текст и выбранный перевод',
    url: 'https://quran.com/ru/114',
  );

  static const _patienceSources = [
    CoachSource(
      title: 'Коран 2:153',
      category: 'Коран',
      verification: 'Канонический арабский текст и выбранный перевод',
      url: 'https://quran.com/ru/2/153',
    ),
    CoachSource(
      title: 'Коран 94:5-6',
      category: 'Коран',
      verification: 'Канонический арабский текст и выбранный перевод',
      url: 'https://quran.com/ru/94/5-6',
    ),
  ];

  static const specialistUrl = 'https://www.muftyat.kz/kk/qa/';

  /// Backend-first ответ с откатом на локальный движок.
  ///
  /// Если backend сконфигурирован ([BackendService.hasConfiguredApiUrl]) и
  /// передан, пробуем серверного AI-коуча. При `null` (503 `coach_unavailable`,
  /// сеть, недоступность) или любой ошибке — возвращаем локальный [answer].
  /// Так экран всегда получает валидный [CoachResponse] с сохранённым
  /// маппингом действий (startLesson/openQuran/contactSpecialist + lessonId).
  Future<CoachResponse> answerSmart(
    String question,
    CoachContext context, {
    BackendService? backend,
    required String locale,
    List<Map<String, dynamic>>? catalog,
    int xp = 0,
    int streak = 0,
    List<String> completedLessonIds = const [],
  }) async {
    if (backend != null) {
      try {
        final remote = await backend.askCoach(
          question: question,
          locale: locale,
          context: contextPayload(
            context,
            xp: xp,
            streak: streak,
            completedLessonIds: completedLessonIds,
          ),
          catalog: catalog,
        );
        if (remote != null) return _withPersonalization(remote, context);
      } catch (_) {
        // Любой сбой backend — тихий откат на локальный движок ниже.
      }
    }
    return answer(question, context);
  }

  /// Плоский JSON-снимок прогресса для серверного коуча.
  Map<String, dynamic> contextPayload(
    CoachContext context, {
    required int xp,
    required int streak,
    required List<String> completedLessonIds,
  }) {
    return {
      'placementLevel': context.placementLevel,
      'goal': context.goal?.storageValue,
      'goalTitle': context.goal?.title,
      'skillProfile': context.skillProfile?.toJson(),
      'recommendation': context.recommendation,
      'recommendedLessonId': context.recommendedLessonId,
      'recommendedLessonTitle': context.recommendedLessonTitle,
      'recommendedCourse': context.recommendedCourse,
      'dueReviewCount': context.dueReviewCount,
      'nextReviewAt': context.nextReviewAt?.toIso8601String(),
      'xp': context.xp == 0 ? xp : context.xp,
      'streak': context.streak == 0 ? streak : context.streak,
      'totalLessons': context.totalLessons,
      'totalCatalogLessons': context.totalCatalogLessons,
      'todayProgress': context.todayProgress,
      'dailyGoal': context.dailyGoal,
      'memorizedVerseCount': context.memorizedVerseCount,
      'hafizDueCount': context.hafizDueCount,
      'quranCompleted': context.quranCompleted,
      'arabicCompleted': context.arabicCompleted,
      'basicsCompleted': context.basicsCompleted,
      'tajwidCompleted': context.tajwidCompleted,
      'accuracy': (context.memoryAccuracy * 100).round(),
      'recentAccuracy': (context.memoryAccuracy * 100).round(),
      'availableMinutes': context.availableMinutes,
      'knownSurahs': context.knownSurahs,
      'completedLessonIds': completedLessonIds,
      'completedLessonTitles': context.completedLessonTitles,
      'hearts': context.hearts,
      'energy': context.energy,
      'lessonAttempts': context.lessonAttempts,
      'speechAttempts': context.speechAttempts,
      'learnedAyats': context.learnedAyats,
      'learnedDuas': context.learnedDuas,
      'lastStudyAt': context.lastStudyAt?.toIso8601String(),
      'mentorProfile': context.mentorProfile.memoryEnabled
          ? context.mentorProfile.toJson()
          : {
              'memoryEnabled': false,
              'personalizedRemindersEnabled':
                  context.mentorProfile.personalizedRemindersEnabled,
            },
      'conversationHistory': context.conversationHistory.take(10).toList(),
      'weakAreas': context.weakKnowledge
          .take(8)
          .map((knowledge) => '${knowledge.label} '
              '[${knowledge.kind.name}; '
              'strength=${(knowledge.strength * 100).round()}%; '
              'lapses=${knowledge.lapses}; '
              'due=${knowledge.isDue()}]')
          .toList(growable: false),
      'weakKnowledge': context.weakKnowledge
          .take(8)
          .map((k) => {
                'id': k.id,
                'lessonId': k.lessonId,
                'label': k.label,
                'kind': k.kind.name,
                'strength': k.strength,
                'lapses': k.lapses,
              })
          .toList(growable: false),
      'dueKnowledge': context.dueKnowledge
          .take(8)
          .map((k) => {
                'id': k.id,
                'lessonId': k.lessonId,
                'label': k.label,
                'kind': k.kind.name,
                'strength': k.strength,
                'repetitions': k.repetitions,
                'lapses': k.lapses,
                'nextReviewAt': k.nextReviewAt.toIso8601String(),
              })
          .toList(growable: false),
      'dueItems': context.dueKnowledge
          .take(8)
          .map((k) => {
                'id': k.id,
                'lessonId': k.lessonId,
                'label': k.label,
                'kind': k.kind.name,
                'strength': k.strength,
                'lapses': k.lapses,
                'dueAt': k.nextReviewAt.toIso8601String(),
              })
          .toList(growable: false),
    };
  }

  CoachResponse answer(String question, CoachContext context) {
    return _withPersonalization(_answerCore(question, context), context);
  }

  CoachResponse _answerCore(String question, CoachContext context) {
    final normalized = question.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const CoachResponse(
        text: 'Напиши вопрос об уроке, суре, повторении или своей ошибке.',
      );
    }

    if (RegExp(
      r'^(запомни|есіңде сақта|remember)',
      caseSensitive: false,
    ).hasMatch(normalized)) {
      return const CoachResponse(
        text:
            'Запомнил. Ты всегда можешь посмотреть или удалить это в разделе «Память наставника».',
        sources: [_progressSource],
      );
    }

    if (_needsSpecialist(normalized)) {
      return const CoachResponse(
        text: 'Этот вопрос требует учёта личной ситуации и мнения '
            'квалифицированного специалиста. Я не буду выдавать фетву или '
            'медицинский совет. Можно открыть официальный раздел вопросов КМДБ.',
        sources: [
          CoachSource(
            title: 'Вопросы и ответы КМДБ',
            category: 'Экспертная консультация',
            verification:
                'Официальный сайт Духовного управления мусульман Казахстана',
            url: specialistUrl,
          ),
        ],
        actionType: CoachActionType.contactSpecialist,
        actionLabel: 'Обратиться к специалисту',
      );
    }

    if (_containsAny(normalized, ['тест', 'проверь меня', 'викторин'])) {
      final weak = context.weakKnowledge.isEmpty
          ? null
          : context.weakKnowledge.first.label;
      return CoachResponse(
        text: weak == null
            ? 'Я выбрал короткую проверку для уровня '
                '${context.placementLevel}. В ней будут аудирование, вопрос '
                'на смысл и задание без очевидной подсказки. Результат сразу '
                'обновит твой персональный маршрут.'
            : 'Сделаем короткую проверку по слабому элементу «$weak». Я не '
                'покажу ответ заранее: урок проверит понимание, порядок и '
                'произношение, а затем вернёт ошибку в повторение.',
        sources: const [_progressSource],
        actionType: CoachActionType.startLesson,
        actionLabel: 'Начать мини-тест',
        lessonId: context.recommendedLessonId,
      );
    }

    if (_containsAny(normalized, [
      'произнош',
      'махрадж',
      'таджвид',
      'мадд',
      'гунн',
      'калькал',
      'ихфа',
      'звук',
      'говорю',
      'голос',
    ])) {
      final pronunciationWeak = context.weakKnowledge
          .where((item) => item.kind.name == 'pronunciation')
          .map((item) => item.label)
          .take(2)
          .toList(growable: false);
      final focus = pronunciationWeak.isEmpty
          ? 'точность текущего урока'
          : pronunciationWeak.map((item) => '«$item»').join(' и ');
      return CoachResponse(
        text: 'Фокус произношения: $focus. Сначала обязательно прослушай '
            'образец, затем повтори короткий фрагмент и только после этого '
            'весь аят. Оценка Muslingo образовательная: она находит вероятные '
            'пропуски и нестабильные места, но не заменяет учителя таджвида.',
        sources: const [_progressSource],
        actionType: CoachActionType.startLesson,
        actionLabel: 'Открыть практику',
        lessonId: context.recommendedLessonId,
      );
    }

    if (_containsAny(normalized, [
      'запомн',
      'наизусть',
      'хафиз',
      'hafiz',
      'раздели',
    ])) {
      final dueText = context.hafizDueCount > 0
          ? ' Сначала повтори ${context.hafizDueCount} назначенных аятов.'
          : '';
      return CoachResponse(
        text: 'Используй цикл памяти: прослушай аят, прочитай вместе с '
            'подсветкой, повтори по частям, скрой часть текста, затем произнеси '
            'весь аят по памяти.$dueText Сейчас в Hafiz закреплено '
            '${context.memorizedVerseCount} аятов.',
        sources: const [_progressSource],
        actionType: CoachActionType.openHafiz,
        actionLabel: 'Открыть Hafiz Mode',
      );
    }

    final vocabulary = _vocabularyAnswer(normalized);
    if (vocabulary != null) return vocabulary;

    if (_containsAny(normalized, ['повтор', 'сегодня', 'забы'])) {
      if (context.dueReviewCount > 0) {
        return CoachResponse(
          text: 'Сегодня сначала закрепи ${context.dueReviewCount} '
              '${_elementWord(context.dueReviewCount)}. Начни с урока '
              '«${context.recommendedLessonTitle ?? 'Повторение'}»: он уже '
              'подошёл по расписанию памяти.',
          sources: const [_progressSource],
          actionType: CoachActionType.startLesson,
          actionLabel: 'Начать повторение',
          lessonId: context.recommendedLessonId,
        );
      }
      return CoachResponse(
        text: 'Просроченных повторений сейчас нет. Подходящий следующий шаг — '
            '«${context.recommendedLessonTitle ?? 'ежедневный урок'}». После '
            'него я назначу повторение каждого элемента отдельно.',
        sources: const [_progressSource],
        actionType: CoachActionType.startLesson,
        actionLabel: 'Начать урок',
        lessonId: context.recommendedLessonId,
      );
    }

    if (_containsAny(normalized, ['слаб', 'ошиб', 'пута'])) {
      if (context.weakKnowledge.isEmpty) {
        final profile = context.skillProfile;
        if (profile != null) {
          final skill = profile.weakestSkill;
          return CoachResponse(
            text: 'По стартовой диагностике слабее всего навык '
                '«${skill.title}» (${profile.scoreFor(skill)}%). Начни с '
                'рекомендованного урока, а после практики я уточню вывод по '
                'реальным ошибкам и повторениям.',
            sources: const [_progressSource],
            actionType: CoachActionType.startLesson,
            actionLabel: 'Начать практику',
            lessonId: context.recommendedLessonId,
          );
        }
        return const CoachResponse(
          text: 'Пока устойчивых слабых мест не найдено. Они появятся здесь '
              'после вопросов, сопоставления и проверки произношения.',
          sources: [_progressSource],
        );
      }
      final labels = context.weakKnowledge
          .take(3)
          .map((knowledge) => '«${knowledge.label}»')
          .join(', ');
      return CoachResponse(
        text: 'Сейчас стоит укрепить: $labels. Я поставил эти элементы раньше '
            'нового материала, чтобы ошибка не закрепилась.',
        sources: const [_progressSource],
        actionType: CoachActionType.startLesson,
        actionLabel: 'Потренировать',
        lessonId: context.recommendedLessonId,
      );
    }

    if (_containsAny(normalized, ['букв', 'алфавит', 'читать араб'])) {
      final weakLetters = context.weakKnowledge
          .where((item) => item.kind.name == 'letter')
          .map((item) => item.label)
          .take(3)
          .toList(growable: false);
      final detail = weakLetters.isEmpty
          ? 'Начни с доступного урока и сравнивай букву в отдельной и связной форме.'
          : 'Сейчас чаще всего путаются ${weakLetters.map((item) => '«$item»').join(', ')}.';
      return CoachResponse(
        text: '$detail Слушай контраст двух звуков, читай короткие слоги и '
            'только затем переходи к кораническому слову.',
        sources: const [_progressSource],
        actionType: CoachActionType.startLesson,
        actionLabel: 'Тренировать чтение',
        lessonId: context.recommendedLessonId,
      );
    }

    if (_containsAny(normalized, ['7 дней', 'семь дней', 'план', 'недел'])) {
      final focus = context.goal?.title ?? 'последовательное чтение Корана';
      return CoachResponse(
        text: 'План на 7 дней для цели «$focus»:\n'
            '1. Сегодня — ${context.recommendedLessonTitle ?? 'стартовый урок'} '
            'и ${context.dueReviewCount} повторений.\n'
            '2. Дни 2-3 — один новый элемент, два закрепления и произношение.\n'
            '3. День 4 — только слабые элементы без нового материала.\n'
            '4. Дни 5-6 — новый материал после Memory Engine.\n'
            '5. День 7 — контрольный урок без подсказок и Hafiz-проверка.\n'
            'План будет меняться по результатам каждого ответа.',
        sources: const [_progressSource],
        actionType: CoachActionType.startLesson,
        actionLabel: 'Начать день 1',
        lessonId: context.recommendedLessonId,
      );
    }

    if (_containsAny(normalized, ['фатих', 'аль-фат'])) {
      return const CoachResponse(
        text: 'Аль-Фатиха — открывающая сура Корана. В учебном маршруте её '
            'удобно понимать как последовательность: хвала Аллаху, признание '
            'Его милости и суда, обращение только к Нему за поклонением и '
            'помощью, затем просьба вести прямым путём. Это краткое учебное '
            'объяснение, а не тафсир от AI.',
        sources: [_fatihahSource],
        actionType: CoachActionType.openQuran,
        actionLabel: 'Открыть суру с переводом',
      );
    }

    if (_containsAny(normalized, ['следующ', 'какую суру', 'новую суру'])) {
      final recommendation = _nextSurahRecommendation(context);
      return CoachResponse(
        text: recommendation.$1,
        sources: [recommendation.$2, _progressSource],
        actionType: CoachActionType.openQuran,
        actionLabel: 'Открыть рекомендованную суру',
      );
    }

    if (_containsAny(normalized, ['терпен', 'сабр'])) {
      return const CoachResponse(
        text: 'В Коране терпение связано с молитвой, опорой в трудности и '
            'надеждой на облегчение. Для изучения начни с аята 2:153, затем '
            'сопоставь его с повторяющейся мыслью в 94:5-6. Я не добавляю к '
            'этим аятам обещаний, которых нет в источнике.',
        sources: _patienceSources,
        actionType: CoachActionType.openQuran,
        actionLabel: 'Открыть аят 2:153',
      );
    }

    if (_containsAny(normalized, ['урок', 'учить', 'сур'])) {
      return CoachResponse(
        text: context.recommendation?.trim().isNotEmpty == true
            ? '${context.recommendation} Сейчас открой '
                '«${context.recommendedLessonTitle ?? 'следующий урок'}».'
            : 'Для уровня ${context.placementLevel} следующий подходящий шаг — '
                '«${context.recommendedLessonTitle ?? 'ежедневный урок'}».',
        sources: const [_progressSource],
        actionType: CoachActionType.startLesson,
        actionLabel: 'Открыть урок',
        lessonId: context.recommendedLessonId,
      );
    }

    if (_containsAny(normalized, ['уров', 'прогресс', 'сколько прош'])) {
      final accuracy = (context.memoryAccuracy * 100).round();
      return CoachResponse(
        text: 'Твой уровень маршрута: ${context.placementLevel}. Пройдено '
            '${context.totalLessons} уроков: Коран — ${context.quranCompleted}, '
            'арабский — ${context.arabicCompleted}, основы — '
            '${context.basicsCompleted}, таджвид — ${context.tajwidCompleted}. '
            'Точность Memory Engine — $accuracy%, '
            'сегодня выполнено ${context.todayProgress} из '
            '${context.dailyGoal}. Следующий шаг — '
            '«${context.recommendedLessonTitle ?? 'ежедневный урок'}».',
        sources: const [_progressSource],
        actionType: CoachActionType.startLesson,
        actionLabel: 'Продолжить маршрут',
        lessonId: context.recommendedLessonId,
      );
    }

    return const CoachResponse(
      text: 'В проверенной базе пока нет достаточно точного ответа на этот '
          'вопрос. Я могу помочь выбрать урок, разобрать Аль-Фатиху, найти '
          'слабые места, объяснить тему терпения или составить план на 7 дней.',
    );
  }

  CoachResponse _withPersonalization(
    CoachResponse response,
    CoachContext context,
  ) {
    if (response.actionType == CoachActionType.contactSpecialist ||
        (response.actionType != CoachActionType.startLesson &&
            !response.sources.contains(_progressSource))) {
      return response;
    }

    final plan = response.dailyPlan.isEmpty
        ? _buildDailyPlan(context)
        : response.dailyPlan;
    final reasoning = response.reasoning?.trim().isNotEmpty == true
        ? response.reasoning
        : _buildReasoning(context);
    final nextAction = response.nextAction?.trim().isNotEmpty == true
        ? response.nextAction
        : _buildNextAction(context);
    final sources = [...response.sources];
    if (!sources.any((source) => source.title == _progressSource.title)) {
      sources.add(_progressSource);
    }
    return CoachResponse(
      text: response.text,
      memorySuggestion: response.memorySuggestion,
      sources: sources,
      reasoning: reasoning,
      dailyPlan: plan,
      nextAction: nextAction,
      actionType: response.actionType,
      actionLabel: response.actionLabel,
      lessonId: response.lessonId,
    );
  }

  List<CoachPlanItem> _buildDailyPlan(CoachContext context) {
    final plan = <CoachPlanItem>[];
    final priority = _priorityKnowledge(context);
    if (context.dueReviewCount > 0) {
      final first = priority.isEmpty ? null : priority.first;
      plan.add(CoachPlanItem(
        title: 'Повторение памяти',
        detail: first == null
            ? '${context.dueReviewCount} элементов по расписанию'
            : '${first.label}: сила ${(first.strength * 100).round()}%, '
                'ошибок ${first.lapses}',
        lessonId: first?.lessonId ?? context.recommendedLessonId,
        isReview: true,
      ));
    }

    final weak = priority.where((item) => item.isWeak).firstOrNull;
    if (weak != null && !plan.any((item) => item.lessonId == weak.lessonId)) {
      plan.add(CoachPlanItem(
        title: 'Укрепить слабое место',
        detail: '${weak.label}: короткая практика без подсказки',
        lessonId: weak.lessonId,
        isReview: true,
      ));
    } else if (context.weakKnowledge.isEmpty && context.skillProfile != null) {
      final skill = context.skillProfile!.weakestSkill;
      plan.add(CoachPlanItem(
        title: 'Фокус диагностики',
        detail: '${skill.title}: ${context.skillProfile!.scoreFor(skill)}%',
        lessonId: context.recommendedLessonId,
      ));
    }

    if (context.recommendedLessonTitle?.trim().isNotEmpty == true &&
        !plan.any((item) => item.lessonId == context.recommendedLessonId)) {
      plan.add(CoachPlanItem(
        title: 'Следующий урок',
        detail: context.recommendedLessonTitle!,
        lessonId: context.recommendedLessonId,
      ));
    }
    if (context.hafizDueCount > 0 && plan.length < 3) {
      plan.add(CoachPlanItem(
        title: 'Hafiz-повторение',
        detail: '${context.hafizDueCount} аятов ожидают проверки',
        isReview: true,
      ));
    }
    return plan.take(3).toList(growable: false);
  }

  String _buildReasoning(CoachContext context) {
    final priority = _priorityKnowledge(context);
    if (context.dueReviewCount > 0) {
      final detail = priority.isEmpty
          ? ''
          : ' Самый срочный элемент: «${priority.first.label}» '
              'с силой ${(priority.first.strength * 100).round()}%.';
      return 'Сначала идут ${context.dueReviewCount} просроченных повторений, '
          'чтобы не закрепить забывание.$detail';
    }
    if (context.weakKnowledge.isNotEmpty) {
      final weak = priority.first;
      return 'Приоритет выбран по слабому элементу «${weak.label}»: '
          'сила ${(weak.strength * 100).round()}%, ошибок ${weak.lapses}.';
    }
    final profile = context.skillProfile;
    if (profile != null) {
      final skill = profile.weakestSkill;
      return 'Пока мало данных Memory Engine, поэтому фокус взят из '
          'диагностики: ${skill.title.toLowerCase()} '
          '${profile.scoreFor(skill)}%.';
    }
    return 'Просроченных повторений нет, поэтому маршрут продолжает следующий '
        'доступный урок уровня ${context.placementLevel}.';
  }

  String _buildNextAction(CoachContext context) {
    final remaining = (context.dailyGoal - context.todayProgress).clamp(0, 999);
    final lesson = context.recommendedLessonTitle ?? 'рекомендованный урок';
    if (remaining == 0) {
      return 'Дневная цель выполнена. Открой «$lesson» только для закрепления.';
    }
    return 'Открой «$lesson». После него останется '
        '${(remaining - 1).clamp(0, 999)} из $remaining шагов дневной цели.';
  }

  List<KnowledgeState> _priorityKnowledge(CoachContext context) {
    final byId = <String, KnowledgeState>{
      for (final item in context.weakKnowledge) item.id: item,
      for (final item in context.dueKnowledge) item.id: item,
    };
    final items = byId.values.toList();
    items.sort((a, b) {
      final dueOrder = (b.isDue() ? 1 : 0).compareTo(a.isDue() ? 1 : 0);
      if (dueOrder != 0) return dueOrder;
      final lapseOrder = b.lapses.compareTo(a.lapses);
      if (lapseOrder != 0) return lapseOrder;
      final strengthOrder = a.strength.compareTo(b.strength);
      if (strengthOrder != 0) return strengthOrder;
      return a.nextReviewAt.compareTo(b.nextReviewAt);
    });
    return items;
  }

  bool _needsSpecialist(String text) => _containsAny(text, [
        'фатва',
        'харам',
        'халяль',
        'грех',
        'развод',
        'наслед',
        'болезн',
        'лекар',
        'диагноз',
        'дозволено ли',
        'запрещено ли',
      ]);

  bool _containsAny(String text, List<String> needles) =>
      needles.any(text.contains);

  CoachResponse? _vocabularyAnswer(String text) {
    const entries = <String, (String, CoachSource)>{
      'альхамду': (
        '«Аль-хамду» (ٱلْحَمْدُ) означает всеобъемлющую хвалу. В Аль-Фатихе '
            'слово открывает аят «Хвала Аллаху, Господу миров».',
        _fatihahSource,
      ),
      'الحمد': (
        '«ٱلْحَمْدُ» означает всеобъемлющую хвалу. В Аль-Фатихе слово '
            'открывает аят «Хвала Аллаху, Господу миров».',
        _fatihahSource,
      ),
      'рабб': (
        '«Рабб» (رَبّ) в учебном переводе — Господь, Владыка и '
            'Воспитывающий. В Аль-Фатихе: «Господь миров».',
        _fatihahSource,
      ),
      'сырат': (
        '«Сырат» (صِرَاط) означает путь. В Аль-Фатихе верующий просит вести '
            'его прямым путём.',
        _fatihahSource,
      ),
      'ахад': (
        '«Ахад» (أَحَد) означает Единственный, Един. Это ключевое слово '
            'первого аята суры Аль-Ихлас.',
        _ikhlasSource,
      ),
      'фаляк': (
        '«Фаляк» (فَلَق) означает рассвет. Сура Аль-Фалак начинается с '
            'обращения к Господу рассвета за защитой.',
        _falaqSource,
      ),
      'нас': (
        '«Ан-нас» (ٱلنَّاس) означает люди. В суре Ан-Нас слово повторяется в '
            'обращении к Господу, Царю и Богу людей.',
        _nasSource,
      ),
    };
    if (!_containsAny(text, ['знач', 'перевод', 'слово'])) return null;
    for (final entry in entries.entries) {
      if (!text.contains(entry.key)) continue;
      return CoachResponse(
        text: entry.value.$1,
        sources: [entry.value.$2],
        actionType: CoachActionType.openQuran,
        actionLabel: 'Открыть в Коране',
      );
    }
    return null;
  }

  (String, CoachSource) _nextSurahRecommendation(CoachContext context) {
    final completed = context.completedLessonTitles.join(' ').toLowerCase();
    if (!completed.contains('фатих')) {
      return (
        'Сначала укрепи Аль-Фатиху: она короткая, постоянно используется в '
            'молитве и даёт базу для понимания структуры аята. Новую суру пока '
            'не добавляю поверх незакреплённой основы.',
        _fatihahSource,
      );
    }
    if (!completed.contains('ихлас')) {
      return (
        'Следующая подходящая сура — Аль-Ихлас: четыре коротких аята и ясная '
            'тема единобожия. Она подходит после уверенной Аль-Фатихи.',
        _ikhlasSource,
      );
    }
    if (!completed.contains('фалак')) {
      return (
        'Следующая подходящая сура — Аль-Фалак. Она короткая и познакомит со '
            'словами, связанными с обращением к Аллаху за защитой.',
        _falaqSource,
      );
    }
    return (
      'Следующая подходящая сура — Ан-Нас. Её удобно учить после Аль-Фалак: '
          'темы связаны, но повторяющиеся окончания требуют внимательного '
          'произношения.',
      _nasSource,
    );
  }

  String _elementWord(int count) {
    final lastTwo = count % 100;
    final last = count % 10;
    if (lastTwo >= 11 && lastTwo <= 14) return 'элементов';
    if (last == 1) return 'элемент';
    if (last >= 2 && last <= 4) return 'элемента';
    return 'элементов';
  }
}
