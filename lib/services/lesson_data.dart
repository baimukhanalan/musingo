import '../models/lesson.dart';

class LessonData {
  static List<Course> getCourses() => [quranCourse, arabicCourse, rulesCourse];

  static Course get quranCourse => Course(
        id: 'quran',
        title: 'Коран',
        description: 'Изучай аяты с аудио и переводом',
        type: CourseType.quran,
        lessons: _quranLessons,
      );

  static Course get arabicCourse => Course(
        id: 'arabic',
        title: 'Арабский язык',
        description: 'Буквы, чтение и произношение в игровом формате',
        type: CourseType.arabic,
        lessons: _arabicLessons,
      );

  static Course get rulesCourse => Course(
        id: 'rules',
        title: 'Основы ислама',
        description: 'Краткое введение в основы ислама с источниками',
        type: CourseType.rules,
        lessons: _rulesLessons,
      );

  static final List<Lesson> _quranLessons = [
    const Lesson(
      id: 'q_fatiha_1',
      title: 'Аль-Фатиха: начало',
      subtitle: 'Смысл названия и первый аят',
      course: CourseType.quran,
      order: 1,
      status: LessonStatus.available,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Фатиха означает «Открывающая». Сура стоит в начале '
              'Корана и читается в каждом ракаате намаза. В этом уроке ты '
              'сначала поймёшь смысл, потом проверишь себя и произнесёшь аят.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 1,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          transliteration: 'Бисмилляхи р-рахмани р-рахим',
          russianText: 'Во имя Аллаха, Милостивого, Милосердного',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что означает «Аль-Фатиха»?',
          answers: ['Открывающая', 'Последняя', 'Лунная'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 1,
          arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
          transliteration: 'Бисмилляхи р-рахмани р-рахим',
          russianText: 'Повтори за котом эту фразу',
        ),
      ],
    ),
    const Lesson(
      id: 'q_fatiha_2',
      title: 'Хвала Господу миров',
      subtitle: 'Аяты 2-3: милость и благодарность',
      course: CourseType.quran,
      order: 2,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Перед проверкой прочитай смысл: сура учит начинать '
              'обращение к Аллаху с хвалы и признания Его милости.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 2,
          arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          transliteration: "Аль-хамду лилляхи рабби-ль-'алямин",
          russianText: 'Хвала Аллаху, Господу миров',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 3,
          arabicText: 'الرَّحْمَٰنِ الرَّحِيمِ',
          transliteration: 'Ар-рахмани р-рахим',
          russianText: 'Милостивому, Милосердному',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какая главная тема аятов 2-3?',
          answers: [
            'Хвала и милость Аллаха',
            'Описание битвы',
            'История пророка Нуха'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 2,
          arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
          transliteration: "Аль-хамду лилляхи рабби-ль-'алямин",
        ),
      ],
    ),
    const Lesson(
      id: 'q_fatiha_3',
      title: 'Поклонение и просьба',
      subtitle: 'Аяты 4-5: Судный день и искренность',
      course: CourseType.quran,
      order: 3,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аяты 4-5 напоминают о Дне воздаяния и учат обращаться '
              'за помощью только к Аллаху.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 4,
          arabicText: 'مَالِكِ يَوْمِ الدِّينِ',
          transliteration: 'Малики йауми-д-дин',
          russianText: 'Властелину Дня воздаяния',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5,
          arabicText: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
          transliteration: 'Ийяка наъбуду ва ийяка настаъин',
          russianText:
              'Тебе одному мы поклоняемся и Тебя одного молим о помощи',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'К кому обращена просьба о помощи в 5-м аяте?',
          answers: ['К Аллаху', 'К людям', 'К ангелам'],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'q_fatiha_4',
      title: 'Прямой путь',
      subtitle: 'Аяты 6-7 и итог смысла суры',
      course: CourseType.quran,
      order: 4,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Заключение суры — просьба вести прямым путём и уберечь '
              'от пути заблуждения. После объяснения будет проверка и повтор.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6,
          arabicText: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          transliteration: 'Ихдина-с-сырата-ль-мустакым',
          russianText: 'Веди нас прямым путём',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 7,
          arabicText:
              'صِرَاطَ الَّذِينَ أَنْعَمْتَ عَلَيْهِمْ غَيْرِ الْمَغْضُوبِ عَلَيْهِمْ وَلَا الضَّالِّينَ',
          transliteration:
              'Сырата-ллязина анъамта алейхим, гайри-ль-магдуби алейхим ва ля-д-даллин',
          russianText:
              'Путём тех, кого Ты облагодетельствовал, не тех, на кого пал гнев, и не заблудших',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О чём просит верующий в конце Аль-Фатихи?',
          answers: ['О прямом пути', 'О богатстве', 'О долгом сне'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6,
          arabicText: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
          transliteration: 'Ихдина-с-сырата-ль-мустакым',
        ),
      ],
    ),
    const Lesson(
      id: 'q_ikhlas_1',
      title: 'Аль-Ихлас',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 5,
      steps: [
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6222,
          arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          transliteration: 'Куль хуваллаху ахад',
          russianText: 'Скажи: «Он — Аллах Единый»',
        ),
        LessonStep(
          type: LessonStepType.text,
          quranGlobalAyahNumber: 6223,
          arabicText: 'اللَّهُ الصَّمَدُ',
          transliteration: 'Аллаху-с-самад',
          russianText: 'Аллах — Самодостаточный',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Сколько аятов в суре Аль-Ихлас?',
          answers: ['4 аята', '7 аятов', '3 аята'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6222,
          arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
          transliteration: 'Куль хуваллаху ахад',
          russianText: 'Повтори первый аят суры',
        ),
      ],
    ),
    const Lesson(
      id: 'q_falaq_1',
      title: 'Аль-Фалак',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 6,
      steps: [
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6226,
          arabicText: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
          transliteration: 'Куль а\'узу бираббиль-фалак',
          russianText: 'Скажи: «Прибегаю к Господу рассвета»',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что означает «Аль-Фалак»?',
          answers: ['Рассвет', 'Закат', 'Полдень'],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'q_nas_1',
      title: 'Ан-Нас',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 7,
      steps: [
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6231,
          arabicText: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
          transliteration: 'Куль а\'узу биробби-н-нас',
          russianText: 'Скажи: «Прибегаю к Господу людей»',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем является сура «Ан-Нас»?',
          answers: ['Последней сурой Корана', 'Первой сурой', 'Средней сурой'],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'q_baqara_1',
      title: 'Аль-Бакара 1-2',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 8,
      steps: [
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 8,
          arabicText: 'الٓمٓ',
          transliteration: 'Алиф. Лям. Мим.',
          russianText: 'Отдельные буквы в начале суры; их истинный смысл '
              'известен Аллаху.',
        ),
        LessonStep(
          type: LessonStepType.text,
          quranGlobalAyahNumber: 9,
          arabicText:
              'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
          transliteration:
              'Залика-ль-китабу ля райба фихи, худан лиль-муттакын',
          russianText: 'Это Писание, в котором нет сомнения, является верным '
              'руководством для богобоязненных.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Самая длинная сура Корана — это?',
          answers: ['Аль-Бакара', 'Аль-Фатиха', 'Ясин'],
          correctAnswerIndex: 0,
        ),
      ],
    ),
  ];

  static final List<Lesson> _arabicLessons = [
    const Lesson(
      id: 'a1',
      title: 'Первые буквы',
      subtitle: 'Алиф, Ба, Та: звук, форма и голос',
      course: CourseType.arabic,
      order: 1,
      status: LessonStatus.available,
      xpReward: 20,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          arabicText: 'ا  ب  ت',
          transliteration: 'Алиф, Ба, Та',
          russianText: 'Начинаем с трёх базовых букв. Сначала узнай форму, '
              'потом выбери правильный ответ и произнеси звук.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          arabicText: 'ا',
          transliteration: 'Алиф',
          russianText: 'Алиф часто передаёт долгий звук «а».',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какая буква называется «Ба»?',
          answers: ['ب', 'ت', 'ا'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'ب',
          transliteration: 'Ба',
          russianText: 'Произнеси букву Ба.',
        ),
      ],
    ),
    const Lesson(
      id: 'a2',
      title: 'Короткие гласные',
      subtitle: 'Фатха, касра и дамма',
      course: CourseType.arabic,
      order: 2,
      xpReward: 20,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          arabicText: 'بَ  بِ  بُ',
          transliteration: 'ба, би, бу',
          russianText: 'Фатха даёт звук «а», касра — «и», дамма — «у».',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как читается «بِ»?',
          answers: ['би', 'ба', 'бу'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'بَ بِ بُ',
          transliteration: 'ба би бу',
        ),
      ],
    ),
    const Lesson(
      id: 'a3',
      title: 'Собери слог',
      subtitle: 'Чтение простых сочетаний',
      course: CourseType.arabic,
      order: 3,
      xpReward: 25,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          arabicText: 'تَ  بَ  بَا',
          transliteration: 'та, ба, баа',
          russianText: 'Теперь соединяем буквы и гласные в короткие слоги.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какой вариант читается как «та»?',
          answers: ['تَ', 'بَ', 'ا'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'تَ',
          transliteration: 'та',
        ),
      ],
    ),
  ];

  static final List<Lesson> _rulesLessons = [
    const Lesson(
      id: 'r1',
      title: 'Вера и намерение',
      subtitle: 'С чего начинается обучение',
      course: CourseType.rules,
      order: 1,
      status: LessonStatus.available,
      sourceUrl: 'https://quran.com/98/5',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          explanation: 'Базовый урок перед сурами.',
          russianText: 'В исламе важны вера, искренность и намерение. '
              'Перед изучением Корана ученик вспоминает, что цель обучения — '
              'понимать смысл, исправлять чтение и применять знание спокойно.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что помогает начать обучение правильно?',
          answers: ['Искреннее намерение', 'Спешка', 'Соревнование ради похвалы'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'بِسْمِ اللَّهِ',
          transliteration: 'Бисмиллях',
          speechMode: SpeechMode.phrase,
          russianText: 'Произнеси короткую фразу перед началом.',
        ),
      ],
    ),
    const Lesson(
      id: 'r2',
      title: 'Что такое Коран',
      subtitle: 'Писание, чтение и уважение',
      course: CourseType.rules,
      order: 2,
      sourceUrl: 'https://quran.com/2/2',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          explanation: 'Короткая рамка перед чтением сур.',
          russianText: 'Коран для мусульман — речь Аллаха и руководство. '
              'В Muslingo ученик сначала слушает, затем читает, понимает '
              'перевод и только после этого проверяет себя.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какой порядок обучения безопаснее?',
          answers: ['Слушать, читать, понимать, повторять', 'Только угадывать', 'Пропускать смысл'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 9,
          arabicText:
              'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
          transliteration:
              'Залика-ль-китабу ля райба фихи, худан лиль-муттакын',
          russianText: 'Это Писание, в котором нет сомнения...',
        ),
      ],
    ),
    const Lesson(
      id: 'r3',
      title: 'Пророк Мухаммад',
      subtitle: 'Пример мягкости и обучения',
      course: CourseType.rules,
      order: 3,
      sourceUrl: 'https://quran.com/33/21',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Мусульмане учатся Корану вместе с примером Пророка '
              'Мухаммада, мир ему. Этот урок напоминает: знание должно делать '
              'человека внимательнее, мягче и ответственнее.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что должно сопровождать знание?',
          answers: ['Хороший нрав', 'Грубость', 'Высокомерие'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'اللَّهُمَّ صَلِّ عَلَى مُحَمَّدٍ',
          transliteration: 'Аллахумма салли аля Мухаммад',
          speechMode: SpeechMode.phrase,
          russianText: 'Повтори короткую формулу салавата.',
        ),
      ],
    ),
    const Lesson(
      id: 'r4',
      title: 'Молитва',
      subtitle: 'Связь с Аллахом',
      course: CourseType.rules,
      order: 4,
      sourceUrl: 'https://quran.com/4/103',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Намаз — центральная практика мусульманина. Вводный '
              'урок не заменяет обучение у учителя, но помогает понять: '
              'Коран и короткие суры часто нужны именно в молитве.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Зачем Muslingo учит короткие суры?',
          answers: ['Чтобы понимать и читать их в поклонении', 'Чтобы не слушать аудио', 'Чтобы пропускать перевод'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'اللَّهُ أَكْبَرُ',
          transliteration: 'Аллаху Акбар',
          speechMode: SpeechMode.phrase,
          russianText: 'Произнеси фразу спокойно и четко.',
        ),
      ],
    ),
    const Lesson(
      id: 'r5',
      title: 'Чистота и адаб',
      subtitle: 'Перед чтением и учебой',
      course: CourseType.rules,
      order: 5,
      sourceUrl: 'https://quran.com/56/79',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Адаб — это уважительное поведение. Перед чтением '
              'Корана важно выбрать спокойное место, не торопиться, слушать '
              'внимательно и относиться к тексту с уважением.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что относится к адабу обучения?',
          answers: ['Внимательность и уважение', 'Смех над ошибками', 'Чтение без слушания'],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'r6',
      title: 'Как понимать перевод',
      subtitle: 'Смысл без самовольных выводов',
      course: CourseType.rules,
      order: 6,
      sourceUrl: 'https://quran.com/16/43',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Перевод помогает понять общий смысл, но не заменяет '
              'арабский текст и объяснение ученых. В приложении перевод нужен '
              'для обучения, а сложные вопросы следует уточнять у знающих.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что важно помнить о переводе?',
          answers: ['Он помогает, но не заменяет арабский текст', 'Он всегда равен оригиналу', 'Он не нужен вообще'],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'r7',
      title: 'Как учить суры',
      subtitle: 'Слушай, понимай, повторяй',
      course: CourseType.rules,
      order: 7,
      sourceUrl: 'https://quran.com/73/4',
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Лучший порядок для новичка: прослушать всю суру, '
              'разобрать короткий фрагмент, понять перевод, повторить вслух '
              'и вернуться к ошибкам. Так построены уроки Muslingo.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какой порядок будет в уроках сур?',
          answers: ['Слушать, понимать, повторять, исправлять ошибки', 'Только читать быстро', 'Только проходить тест'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          arabicText: 'الْحَمْدُ لِلَّهِ',
          transliteration: 'Аль-хамду лиллях',
          speechMode: SpeechMode.phrase,
          russianText: 'Повтори фразу благодарности.',
        ),
      ],
    ),
  ];
}
