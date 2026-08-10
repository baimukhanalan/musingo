import '../models/coach.dart';
import '../models/learning_profile.dart';
import 'backend_service.dart';

class CoachService {
  static const suggestions = [
    'Что повторить сегодня?',
    'Какой урок мне подходит?',
    'Какие у меня слабые места?',
    'Объясни Аль-Фатиху просто',
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
          context: _contextPayload(
            context,
            xp: xp,
            streak: streak,
            completedLessonIds: completedLessonIds,
          ),
          catalog: catalog,
        );
        if (remote != null) return remote;
      } catch (_) {
        // Любой сбой backend — тихий откат на локальный движок ниже.
      }
    }
    return answer(question, context);
  }

  /// Плоский JSON-снимок прогресса для серверного коуча.
  Map<String, dynamic> _contextPayload(
    CoachContext context, {
    required int xp,
    required int streak,
    required List<String> completedLessonIds,
  }) {
    return {
      'placementLevel': context.placementLevel,
      'goal': context.goal?.title,
      'recommendation': context.recommendation,
      'recommendedLessonId': context.recommendedLessonId,
      'recommendedLessonTitle': context.recommendedLessonTitle,
      'dueReviewCount': context.dueReviewCount,
      'xp': xp,
      'streak': streak,
      'completedLessonIds': completedLessonIds,
      'weakKnowledge': context.weakKnowledge
          .take(8)
          .map((k) => {
                'id': k.id,
                'lessonId': k.lessonId,
                'label': k.label,
                'strength': k.strength,
              })
          .toList(growable: false),
    };
  }

  CoachResponse answer(String question, CoachContext context) {
    final normalized = question.trim().toLowerCase();
    if (normalized.isEmpty) {
      return const CoachResponse(
        text: 'Напиши вопрос об уроке, суре, повторении или своей ошибке.',
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
        return const CoachResponse(
          text: 'Пока устойчивых слабых мест не найдено. Они появятся здесь '
              'после вопросов, matching и проверки произношения.',
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

    if (_containsAny(normalized, ['7 дней', 'семь дней', 'план', 'недел'])) {
      final focus = context.goal?.title ?? 'последовательное чтение Корана';
      return CoachResponse(
        text: 'План на 7 дней для цели «$focus»:\n'
            '1. Сегодня — ${context.recommendedLessonTitle ?? 'стартовый урок'}.\n'
            '2. Дни 2-3 — короткий урок и назначенное повторение.\n'
            '3. День 4 — только слабые элементы и произношение.\n'
            '4. Дни 5-6 — новый материал после повторения.\n'
            '5. День 7 — контрольный урок без подсказок.\n'
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

    if (_containsAny(normalized, ['урок', 'учить', 'следующ', 'сур'])) {
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

    return const CoachResponse(
      text: 'В проверенной базе пока нет достаточно точного ответа на этот '
          'вопрос. Я могу помочь выбрать урок, разобрать Аль-Фатиху, найти '
          'слабые места, объяснить тему терпения или составить план на 7 дней.',
    );
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

  String _elementWord(int count) {
    final lastTwo = count % 100;
    final last = count % 10;
    if (lastTwo >= 11 && lastTwo <= 14) return 'элементов';
    if (last == 1) return 'элемент';
    if (last >= 2 && last <= 4) return 'элемента';
    return 'элементов';
  }
}
