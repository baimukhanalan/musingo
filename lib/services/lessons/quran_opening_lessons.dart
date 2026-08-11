import '../../models/lesson.dart';

final List<Lesson> quranOpeningLessons = [
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
        answers: ['Собирающая', 'Открывающая', 'Защищающая'],
        correctAnswerIndex: 1,
      ),
      LessonStep(
        type: LessonStepType.matching,
        question: 'Соедини фразу и смысл',
        russianText:
            'Подумай по контексту: фраза начинается с имени Аллаха и двух качеств милости.',
        matchPairs: [
          LessonMatchPair(prompt: 'بِسْمِ اللَّهِ', answer: 'Во имя Аллаха'),
          LessonMatchPair(prompt: 'الرَّحْمَٰنِ', answer: 'Милостивого'),
          LessonMatchPair(prompt: 'الرَّحِيمِ', answer: 'Милосердного'),
        ],
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 1,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        transliteration: 'Бисмилляхи р-рахмани р-рахим',
        russianText: 'Повтори за котом эту фразу',
      ),
      // Проверка перевода: дистракторы — реальные переводы других аятов.
      LessonStep(
        type: LessonStepType.question,
        question: 'Как переводится «بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ»?',
        answers: [
          'Во имя Аллаха, Милостивого, Милосердного',
          'Хвала Аллаху, Господу миров',
          'Веди нас прямым путём'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Что означает слово «الرَّحِيمِ»?',
        answers: ['Милостивого', 'Милосердного', 'Господа миров'],
        correctAnswerIndex: 1,
      ),
      // Cloze на арабском: пропущенное слово — реальные слова из Корана.
      LessonStep(
        type: LessonStepType.question,
        question: 'Вставь пропущенное слово: «بِسْمِ اللَّهِ ___ الرَّحِيمِ»',
        answers: ['الرَّحْمَٰنِ', 'الْعَالَمِينَ', 'الْمُسْتَقِيمَ'],
        correctAnswerIndex: 0,
      ),
      // Логика: связь названия суры и её места в намазе, без криба.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Почему Аль-Фатиху называют «Открывающей» и читают в каждом ракаате?',
        answers: [
          'Она открывает Коран и является основой каждой молитвы',
          'Она самая длинная сура Корана',
          'Она была ниспослана последней'
        ],
        correctAnswerIndex: 0,
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
          'Просьба о прямом пути',
          'Хвала и милость Аллаха',
          'Описание людей Писания'
        ],
        correctAnswerIndex: 1,
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 2,
        arabicText: 'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
        transliteration: "Аль-хамду лилляхи рабби-ль-'алямин",
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Как переводится «الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ»?',
        answers: [
          'Хвала Аллаху, Господу миров',
          'Властелину Дня воздаяния',
          'Тебе одному мы поклоняемся и Тебя одного молим о помощи'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Что означает «الرَّحْمَٰنِ الرَّحِيمِ» в этих аятах?',
        answers: [
          'Милостивому, Милосердному',
          'Хвала Аллаху, Господу миров',
          'Веди нас прямым путём'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.question,
        question:
            'Какой аят Аль-Фатихи идёт сразу после «Хвала Аллаху, Господу миров»?',
        answers: [
          'Милостивому, Милосердному',
          'Властелину Дня воздаяния',
          'Веди нас прямым путём'
        ],
        correctAnswerIndex: 0,
      ),
      // Логика: что объединяет два аята по смыслу.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Что объединяет по смыслу «بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ» и «الرَّحْمَٰنِ الرَّحِيمِ» из 3-го аята?',
        answers: [
          'Оба называют Аллаха качествами милости и милосердия',
          'Оба просят о защите от зла',
          'Оба говорят о Судном дне'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.matching,
        question: 'Соедини транслитерацию и перевод',
        matchPairs: [
          LessonMatchPair(
              prompt: "Аль-хамду лилляхи рабби-ль-'алямин",
              answer: 'Хвала Аллаху, Господу миров'),
          LessonMatchPair(
              prompt: 'Ар-рахмани р-рахим',
              answer: 'Милостивому, Милосердному'),
          LessonMatchPair(
              prompt: 'Бисмилляхи р-рахмани р-рахим',
              answer: 'Во имя Аллаха, Милостивого, Милосердного'),
        ],
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
        russianText: 'Тебе одному мы поклоняемся и Тебя одного молим о помощи',
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'К кому обращена просьба о помощи в 5-м аяте?',
        answers: [
          'К ангелам как свидетелям',
          'К пророкам как наставникам',
          'К Аллаху одному'
        ],
        correctAnswerIndex: 2,
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Как переводится «مَالِكِ يَوْمِ الدِّينِ»?',
        answers: [
          'Властелину Дня воздаяния',
          'Хвала Аллаху, Господу миров',
          'Веди нас прямым путём'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Как переводится «إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ»?',
        answers: [
          'Тебе одному мы поклоняемся и Тебя одного молим о помощи',
          'Хвала Аллаху, Господу миров',
          'Скажи: «Прибегаю к Господу рассвета»'
        ],
        correctAnswerIndex: 0,
      ),
      // Арабское слово с близкими дистракторами из того же аята.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Какое слово в аяте «مَالِكِ يَوْمِ الدِّينِ» означает «Дня»?',
        answers: ['يَوْمِ', 'مَالِكِ', 'الدِّينِ'],
        correctAnswerIndex: 0,
      ),
      // Логика: смысловая связь 5-го аята (поклонение только Аллаху).
      LessonStep(
        type: LessonStepType.question,
        question:
            'Чему учит 5-й аят «Тебе одному мы поклоняемся и Тебя одного молим о помощи»?',
        answers: [
          'Обращать поклонение и просьбу о помощи только к Аллаху',
          'Просить помощи у праведных людей',
          'Поклоняться в определённое время суток'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.matching,
        question: 'Соедини транслитерацию и перевод',
        matchPairs: [
          LessonMatchPair(
              prompt: 'Малики йауми-д-дин', answer: 'Властелину Дня воздаяния'),
          LessonMatchPair(
              prompt: 'Ийяка наъбуду ва ийяка настаъин',
              answer:
                  'Тебе одному мы поклоняемся и Тебя одного молим о помощи'),
          LessonMatchPair(
              prompt: "Аль-хамду лилляхи рабби-ль-'алямин",
              answer: 'Хвала Аллаху, Господу миров'),
        ],
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 5,
        arabicText: 'إِيَّاكَ نَعْبُدُ وَإِيَّاكَ نَسْتَعِينُ',
        transliteration: 'Ийяка наъбуду ва ийяка настаъин',
        russianText: 'Расскажи пятый аят Аль-Фатихи.',
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
        answers: [
          'О прямом пути и защите от заблуждения',
          'О долгой жизни и богатстве',
          'О прощении именно прошлых грехов'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 6,
        arabicText: 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ',
        transliteration: 'Ихдина-с-сырата-ль-мустакым',
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Как переводится «اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ»?',
        answers: [
          'Веди нас прямым путём',
          'Хвала Аллаху, Господу миров',
          'Скажи: «Прибегаю к Господу людей»'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'О ком говорится в 7-м аяте?',
        answers: [
          'О тех, кого Аллах облагодетельствовал, и не о заблудших',
          'Только о тех, на кого пал гнев',
          'О тех, кто заблудился и уже не вернётся'
        ],
        correctAnswerIndex: 0,
      ),
      // Арабское слово: «путь» среди слов того же аята.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Какое слово в «اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ» означает «путь»?',
        answers: ['الصِّرَاطَ', 'اهْدِنَا', 'الْمُسْتَقِيمَ'],
        correctAnswerIndex: 0,
      ),
      // Логика: смысловая арка всей суры.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Аль-Фатиха начинается с хвалы Аллаху, а чем она завершается?',
        answers: [
          'Просьбой о наставлении на прямой путь',
          'Рассказом о сотворении человека',
          'Клятвой предвечерним временем'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.matching,
        question: 'Соедини транслитерацию и перевод',
        matchPairs: [
          LessonMatchPair(
              prompt: 'Ихдина-с-сырата-ль-мустакым',
              answer: 'Веди нас прямым путём'),
          LessonMatchPair(
              prompt:
                  'Сырата-ллязина анъамта алейхим, гайри-ль-магдуби алейхим ва ля-д-даллин',
              answer:
                  'Путём тех, кого Ты облагодетельствовал, не тех, на кого пал гнев, и не заблудших'),
          LessonMatchPair(
              prompt: 'Ийяка наъбуду ва ийяка настаъин',
              answer:
                  'Тебе одному мы поклоняемся и Тебя одного молим о помощи'),
        ],
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
        question: 'Какой смысл объединяет первые аяты Аль-Ихлас?',
        answers: [
          'Просьба о защите от зла',
          'Единство и самодостаточность Аллаха',
          'Просьба о наставлении на прямой путь'
        ],
        correctAnswerIndex: 1,
      ),
      LessonStep(
        type: LessonStepType.matching,
        question: 'Сопоставь слова с их смыслом',
        matchPairs: [
          LessonMatchPair(prompt: 'أَحَدٌ', answer: 'Единый'),
          LessonMatchPair(prompt: 'الصَّمَدُ', answer: 'Самодостаточный'),
          LessonMatchPair(prompt: 'قُلْ', answer: 'Скажи'),
        ],
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 6222,
        arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        transliteration: 'Куль хуваллаху ахад',
        russianText: 'Повтори первый аят суры',
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Как переводится «قُلْ هُوَ اللَّهُ أَحَدٌ»?',
        answers: [
          'Скажи: «Он — Аллах Единый»',
          'Скажи: «Прибегаю к Господу рассвета»',
          'Скажи: «Прибегаю к Господу людей»'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Что означает «اللَّهُ الصَّمَدُ»?',
        answers: [
          'Аллах — Самодостаточный',
          'Скажи: «Он — Аллах Единый»',
          'Милостивому, Милосердному'
        ],
        correctAnswerIndex: 0,
      ),
      // Cloze: концовка первого аята среди концовок трёх «قُلْ»-сур.
      LessonStep(
        type: LessonStepType.question,
        question: 'Заверши первый аят: «قُلْ هُوَ اللَّهُ ___»',
        answers: ['أَحَدٌ', 'الْفَلَقِ', 'النَّاسِ'],
        correctAnswerIndex: 0,
      ),
      // Логика: чем Ихлас отличается от Фалак и Нас по теме.
      LessonStep(
        type: LessonStepType.question,
        question: 'Чем тема Аль-Ихлас отличается от Аль-Фалак и Ан-Нас?',
        answers: [
          'Она описывает Самого Аллаха, а не просьбу о защите',
          'Она просит защиты от рассвета',
          'Она рассказывает о владельцах слона'
        ],
        correctAnswerIndex: 0,
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
        answers: [
          'Утреннюю молитву',
          'Рассвет (утренняя заря)',
          'Заход солнца'
        ],
        correctAnswerIndex: 1,
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 6226,
        arabicText: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
        transliteration: 'Куль а\'узу бираббиль-фалак',
        russianText: 'Расскажи первый аят суры Аль-Фалак.',
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Как переводится «قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ»?',
        answers: [
          'Скажи: «Прибегаю к Господу рассвета»',
          'Скажи: «Прибегаю к Господу людей»',
          'Скажи: «Он — Аллах Единый»'
        ],
        correctAnswerIndex: 0,
      ),
      // Логика: различие первого аята Аль-Фалак и Ан-Нас.
      LessonStep(
        type: LessonStepType.question,
        question: 'Чем начало Аль-Фалак отличается от начала Ан-Нас?',
        answers: [
          'В Аль-Фалак прибегают к Господу рассвета, а в Ан-Нас — к Господу людей',
          'В Аль-Фалак прибегают к Господу людей',
          'Оба начинаются со слов «Он — Аллах Единый»'
        ],
        correctAnswerIndex: 0,
      ),
      // Cloze на арабском: имя суры в конце первого аята.
      LessonStep(
        type: LessonStepType.question,
        question: 'Заверши аят: «قُلْ أَعُوذُ بِرَبِّ ___»',
        answers: ['الْفَلَقِ', 'النَّاسِ', 'الْعَالَمِينَ'],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.matching,
        question: 'Соедини транслитерацию и перевод',
        matchPairs: [
          LessonMatchPair(
              prompt: 'Куль а\'узу бираббиль-фалак',
              answer: 'Скажи: «Прибегаю к Господу рассвета»'),
          LessonMatchPair(
              prompt: 'Куль а\'узу биробби-н-нас',
              answer: 'Скажи: «Прибегаю к Господу людей»'),
          LessonMatchPair(
              prompt: 'Куль хуваллаху ахад',
              answer: 'Скажи: «Он — Аллах Единый»'),
        ],
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
        question: 'Какой смысл у первого аята Ан-Нас?',
        answers: [
          'Просьба о защите у Господа рассвета',
          'Просьба о защите у Господа людей',
          'Прославление единства Аллаха'
        ],
        correctAnswerIndex: 1,
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 6231,
        arabicText: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        transliteration: 'Куль а\'узу биробби-н-нас',
        russianText: 'Расскажи первый аят суры Ан-Нас.',
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Как переводится «قُلْ أَعُوذُ بِرَبِّ النَّاسِ»?',
        answers: [
          'Скажи: «Прибегаю к Господу людей»',
          'Скажи: «Прибегаю к Господу рассвета»',
          'Скажи: «Он — Аллах Единый»'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'К кому прибегают за защитой в суре Ан-Нас?',
        answers: ['К Господу людей', 'К Господу рассвета', 'К Господу миров'],
        correctAnswerIndex: 0,
      ),
      // Cloze на арабском: концовка первого аята.
      LessonStep(
        type: LessonStepType.question,
        question: 'Заверши аят: «قُلْ أَعُوذُ بِرَبِّ ___»',
        answers: ['النَّاسِ', 'الْفَلَقِ', 'أَحَدٌ'],
        correctAnswerIndex: 0,
      ),
      // Логика: обе «муаввизатайн» — суры-защиты.
      LessonStep(
        type: LessonStepType.question,
        question: 'Что общего у сур Аль-Фалак и Ан-Нас?',
        answers: [
          'Обе начинаются с просьбы о защите: «Прибегаю к Господу...»',
          'Обе прославляют единство Аллаха',
          'Обе рассказывают о Судном дне'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.matching,
        question: 'Соедини транслитерацию и перевод',
        matchPairs: [
          LessonMatchPair(
              prompt: 'Куль а\'узу биробби-н-нас',
              answer: 'Скажи: «Прибегаю к Господу людей»'),
          LessonMatchPair(
              prompt: 'Куль а\'узу бираббиль-фалак',
              answer: 'Скажи: «Прибегаю к Господу рассвета»'),
          LessonMatchPair(
              prompt: 'Куль хуваллаху ахад',
              answer: 'Скажи: «Он — Аллах Единый»'),
        ],
      ),
    ],
  ),
  const Lesson(
    id: 'q_review_5_surahs',
    title: 'Проверка 5 сур',
    subtitle: 'Средний тест: смысл и произношение изученных сур',
    course: CourseType.quran,
    order: 8,
    xpReward: 45,
    steps: [
      LessonStep(
        type: LessonStepType.text,
        russianText: 'Это контроль после пяти изученных сурных блоков. '
            'Нужно вспомнить смысл и произнести ключевые аяты без подсказки.',
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Какая сура читается в каждом ракаате намаза?',
        answers: [
          'Аль-Ихлас, потому что короткая',
          'Аль-Фатиха, потому что она основа молитвы',
          'Ан-Нас, потому что последняя'
        ],
        correctAnswerIndex: 1,
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 1,
        arabicText: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
        transliteration: 'Бисмилляхи р-рахмани р-рахим',
        russianText: 'Расскажи первый аят Аль-Фатихи.',
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 6222,
        arabicText: 'قُلْ هُوَ اللَّهُ أَحَدٌ',
        transliteration: 'Куль хуваллаху ахад',
        russianText: 'Расскажи первый аят Аль-Ихлас.',
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 6226,
        arabicText: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ',
        transliteration: 'Куль а\'узу бираббиль-фалак',
        russianText: 'Расскажи первый аят Аль-Фалак.',
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 6231,
        arabicText: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ',
        transliteration: 'Куль а\'узу биробби-н-нас',
        russianText: 'Расскажи первый аят Ан-Нас.',
      ),
      LessonStep(
        type: LessonStepType.question,
        question:
            'Какой перевод соответствует «قُلْ هُوَ اللَّهُ أَحَدٌ» из Аль-Ихлас?',
        answers: [
          'Скажи: «Он — Аллах Единый»',
          'Клянусь предвечерним временем',
          'Хвала Аллаху, Господу миров'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.question,
        question:
            'Какая сура начинается со слов «Прибегаю к Господу рассвета»?',
        answers: ['Аль-Фалак', 'Ан-Нас', 'Аль-Ихлас'],
        correctAnswerIndex: 0,
      ),
      // Логика: какая сура о Самом Аллахе, а не просьба.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Какая из изученных сур описывает единство Самого Аллаха, а не содержит просьбу?',
        answers: ['Аль-Ихлас', 'Аль-Фалак', 'Ан-Нас'],
        correctAnswerIndex: 0,
      ),
      // Логика: пара сур-защиты.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Какие две суры называют «сурами-защиты» (обе начинаются с «Прибегаю к Господу...»)?',
        answers: [
          'Аль-Фалак и Ан-Нас',
          'Аль-Фатиха и Аль-Ихлас',
          'Аль-Ихлас и Ан-Нас'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.question,
        question:
            'Что означает первый аят Аль-Фатихи «بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ»?',
        answers: [
          'Во имя Аллаха, Милостивого, Милосердного',
          'Хвала Аллаху, Господу миров',
          'Скажи: «Прибегаю к Господу людей»'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.matching,
        question: 'Соедини начало суры с её названием',
        matchPairs: [
          LessonMatchPair(
              prompt: 'قُلْ هُوَ اللَّهُ أَحَدٌ', answer: 'Аль-Ихлас'),
          LessonMatchPair(
              prompt: 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ', answer: 'Аль-Фалак'),
          LessonMatchPair(
              prompt: 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ', answer: 'Ан-Нас'),
        ],
      ),
    ],
  ),
  const Lesson(
    id: 'q_baqara_1',
    title: 'Аль-Бакара 1-2',
    subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
    course: CourseType.quran,
    order: 9,
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
        transliteration: 'Залика-ль-китабу ля райба фихи, худан лиль-муттакын',
        russianText: 'Это Писание, в котором нет сомнения, является верным '
            'руководством для богобоязненных.',
      ),
      LessonStep(
        type: LessonStepType.question,
        question:
            'Что логически следует из аята «нет сомнения... руководство для богобоязненных»?',
        answers: [
          'Книга описана как руководство, которому доверяют',
          'Руководством она станет лишь после сомнений',
          'Она полезна только тем, кто уже не грешит'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.question,
        question:
            'Как переводится «ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ»?',
        answers: [
          'Это Писание, в котором нет сомнения, является верным руководством для богобоязненных.',
          'Клянусь предвечерним временем',
          'Хвала Аллаху, Господу миров'
        ],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Что сказано в уроке об отдельных буквах «الٓمٓ»?',
        answers: [
          'Их истинный смысл известен Аллаху',
          'Это имена ангелов',
          'Это тайный счёт числа аятов'
        ],
        correctAnswerIndex: 0,
      ),
      // Арабское слово: «Писание» среди слов того же аята.
      LessonStep(
        type: LessonStepType.question,
        question: 'Какое слово в аяте означает «Писание (Книга)»?',
        answers: ['الْكِتَابُ', 'هُدًى', 'الْمُتَّقِينَ'],
        correctAnswerIndex: 0,
      ),
      LessonStep(
        type: LessonStepType.matching,
        question: 'Соедини транслитерацию и перевод',
        matchPairs: [
          LessonMatchPair(
              prompt: 'Залика-ль-китабу ля райба фихи, худан лиль-муттакын',
              answer:
                  'Это Писание, в котором нет сомнения, является верным руководством для богобоязненных.'),
          LessonMatchPair(
              prompt: 'Алиф. Лям. Мим.',
              answer:
                  'Отдельные буквы в начале суры; их истинный смысл известен Аллаху.'),
          LessonMatchPair(
              prompt: "Аль-хамду лилляхи рабби-ль-'алямин",
              answer: 'Хвала Аллаху, Господу миров'),
        ],
      ),
      LessonStep(
        type: LessonStepType.speak,
        quranGlobalAyahNumber: 9,
        arabicText:
            'ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ',
        transliteration: 'Залика-ль-китабу ля райба фихи, худан лиль-муттакын',
        russianText: 'Прочитай второй аят суры Аль-Бакара.',
      ),
    ],
  ),
];
