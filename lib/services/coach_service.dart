import '../models/coach.dart';
import '../models/learning_profile.dart';
import 'backend_service.dart';

class CoachService {
  static const suggestions = [
    'Что повторить сегодня?',
    'Какой урок мне подходит?',
    'Какие у меня слабые места?',
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
      'goal': context.goal?.storageValue,
      'goalTitle': context.goal?.title,
      'recommendation': context.recommendation,
      'recommendedLessonId': context.recommendedLessonId,
      'recommendedLessonTitle': context.recommendedLessonTitle,
      'dueReviewCount': context.dueReviewCount,
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
      'accuracy': (context.memoryAccuracy * 100).round(),
      'completedLessonIds': completedLessonIds,
      'completedLessonTitles': context.completedLessonTitles,
      'weakAreas': context.weakKnowledge
          .take(8)
          .map((knowledge) => knowledge.label)
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
            '${context.basicsCompleted}. Точность Memory Engine — $accuracy%, '
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
