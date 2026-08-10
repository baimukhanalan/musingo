import '../../models/lesson.dart';

final List<Lesson> quranLessons = [
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
          question: 'Почему Аль-Фатиху называют «Открывающей» и читают в каждом ракаате?',
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
          question: 'Какой аят Аль-Фатихи идёт сразу после «Хвала Аллаху, Господу миров»?',
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
          question: 'Что объединяет по смыслу «بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ» и «الرَّحْمَٰنِ الرَّحِيمِ» из 3-го аята?',
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
          russianText:
              'Тебе одному мы поклоняемся и Тебя одного молим о помощи',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'К кому обращена просьба о помощи в 5-м аяте?',
          answers: ['К ангелам как свидетелям', 'К пророкам как наставникам', 'К Аллаху одному'],
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
          question: 'Какое слово в аяте «مَالِكِ يَوْمِ الدِّينِ» означает «Дня»?',
          answers: ['يَوْمِ', 'مَالِكِ', 'الدِّينِ'],
          correctAnswerIndex: 0,
        ),
        // Логика: смысловая связь 5-го аята (поклонение только Аллаху).
        LessonStep(
          type: LessonStepType.question,
          question: 'Чему учит 5-й аят «Тебе одному мы поклоняемся и Тебя одного молим о помощи»?',
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
                prompt: 'Малики йауми-д-дин',
                answer: 'Властелину Дня воздаяния'),
            LessonMatchPair(
                prompt: 'Ийяка наъбуду ва ийяка настаъин',
                answer: 'Тебе одному мы поклоняемся и Тебя одного молим о помощи'),
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
          question: 'Какое слово в «اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ» означает «путь»?',
          answers: ['الصِّرَاطَ', 'اهْدِنَا', 'الْمُسْتَقِيمَ'],
          correctAnswerIndex: 0,
        ),
        // Логика: смысловая арка всей суры.
        LessonStep(
          type: LessonStepType.question,
          question: 'Аль-Фатиха начинается с хвалы Аллаху, а чем она завершается?',
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
                answer: 'Тебе одному мы поклоняемся и Тебя одного молим о помощи'),
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
          answers: ['Утреннюю молитву', 'Рассвет (утренняя заря)', 'Заход солнца'],
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
          answers: [
            'К Господу людей',
            'К Господу рассвета',
            'К Господу миров'
          ],
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
          question: 'Какой перевод соответствует «قُلْ هُوَ اللَّهُ أَحَدٌ» из Аль-Ихлас?',
          answers: [
            'Скажи: «Он — Аллах Единый»',
            'Клянусь предвечерним временем',
            'Хвала Аллаху, Господу миров'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какая сура начинается со слов «Прибегаю к Господу рассвета»?',
          answers: ['Аль-Фалак', 'Ан-Нас', 'Аль-Ихлас'],
          correctAnswerIndex: 0,
        ),
        // Логика: какая сура о Самом Аллахе, а не просьба.
        LessonStep(
          type: LessonStepType.question,
          question: 'Какая из изученных сур описывает единство Самого Аллаха, а не содержит просьбу?',
          answers: ['Аль-Ихлас', 'Аль-Фалак', 'Ан-Нас'],
          correctAnswerIndex: 0,
        ),
        // Логика: пара сур-защиты.
        LessonStep(
          type: LessonStepType.question,
          question: 'Какие две суры называют «сурами-защиты» (обе начинаются с «Прибегаю к Господу...»)?',
          answers: [
            'Аль-Фалак и Ан-Нас',
            'Аль-Фатиха и Аль-Ихлас',
            'Аль-Ихлас и Ан-Нас'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что означает первый аят Аль-Фатихи «بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ»?',
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
            LessonMatchPair(prompt: 'قُلْ هُوَ اللَّهُ أَحَدٌ', answer: 'Аль-Ихлас'),
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
          transliteration:
              'Залика-ль-китабу ля райба фихи, худан лиль-муттакын',
          russianText: 'Это Писание, в котором нет сомнения, является верным '
              'руководством для богобоязненных.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что логически следует из аята «нет сомнения... руководство для богобоязненных»?',
          answers: [
            'Книга описана как руководство, которому доверяют',
            'Руководством она станет лишь после сомнений',
            'Она полезна только тем, кто уже не грешит'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «ذَٰلِكَ الْكِتَابُ لَا رَيْبَ ۛ فِيهِ ۛ هُدًى لِّلْمُتَّقِينَ»?',
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
          transliteration:
              'Залика-ль-китабу ля райба фихи, худан лиль-муттакын',
          russianText: 'Прочитай второй аят суры Аль-Бакара.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_asr_1',
      title: 'Аль-Аср',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 10,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Аср означает «Предвечернее время». Короткая мекканская '
              'сура о том, что человек в убытке, кроме тех, кто уверовал, '
              'творил добро и призывал к истине и терпению.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6177,
          arabicText: 'وَالْعَصْرِ',
          transliteration: "Валь-'аср",
          russianText: 'Клянусь предвечерним временем',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6178,
          arabicText: 'إِنَّ الْإِنسَٰنَ لَفِى خُسْرٍ',
          transliteration: 'Инналь-инсана ляфи хуср',
          russianText: 'Воистину, человек в убытке',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6179,
          arabicText: 'إِلَّا الَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ الصَّٰلِحَٰتِ وَتَوَاصَوْا۟ بِالْحَقِّ وَتَوَاصَوْا۟ بِالصَّبْرِ',
          transliteration: "Илляллязина аману ва 'амилю-с-салихати ва таваасау биль-хаккы ва таваасау бис-сабр",
          russianText: 'кроме тех, которые уверовали, творили добрые дела, '
              'заповедали друг другу истину и терпение',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'В чём главный смысл суры Аль-Аср?',
          answers: [
            'Все люди в убытке, кроме уверовавших и терпеливых',
            'Погоня за богатством отвлекает человека до самой смерти',
            'Богатство и потомство спасают от наказания'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «إِنَّ الْإِنسَٰنَ لَفِى خُسْرٍ»?',
          answers: [
            'Воистину, человек в убытке',
            'Воистину, Мы даровали тебе аль-Каусар (изобилие)',
            'Воистину, твой ненавистник сам окажется безвестным'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кто, по суре Аль-Аср, не окажется в убытке?',
          answers: [
            'Те, кто уверовал, творил добро и заповедал истину и терпение',
            'Только богатые торговцы',
            'Те, кто прожил долгую жизнь'
          ],
          correctAnswerIndex: 0,
        ),
        // Cloze: ключевое слово 2-го аята.
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Воистину, человек в ___»',
          answers: ['убытке', 'изобилии', 'безопасности'],
          correctAnswerIndex: 0,
        ),
        // Логика: четыре условия спасения по 3-му аяту.
        LessonStep(
          type: LessonStepType.question,
          question: 'Что, по 3-му аяту, спасает человека от убытка?',
          answers: [
            'Вера, добрые дела и призыв к истине и терпению',
            'Богатство и слава',
            'Долгая жизнь и здоровье'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(
                prompt: "Валь-'аср", answer: 'Клянусь предвечерним временем'),
            LessonMatchPair(
                prompt: 'Инналь-инсана ляфи хуср',
                answer: 'Воистину, человек в убытке'),
            LessonMatchPair(
                prompt:
                    "Илляллязина аману ва 'амилю-с-салихати ва таваасау биль-хаккы ва таваасау бис-сабр",
                answer:
                    'кроме тех, которые уверовали, творили добрые дела, заповедали друг другу истину и терпение'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6177,
          arabicText: 'وَالْعَصْرِ',
          transliteration: "Валь-'аср",
          russianText: 'Расскажи первый аят суры Аль-Аср.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_fil_1',
      title: 'Аль-Филь',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 11,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Филь означает «Слон». Сура напоминает, как Аллах '
              'защитил Каабу и обратил в ничто замысел войска с боевым '
              'слоном.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6189,
          arabicText: 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَٰبِ الْفِيلِ',
          transliteration: "Алам тара кайфа фа'аля раббука би-асхабиль-филь",
          russianText: 'Разве ты не видел, как поступил твой Господь с владельцами '
              'слона?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6190,
          arabicText: 'أَلَمْ يَجْعَلْ كَيْدَهُمْ فِى تَضْلِيلٍۢ',
          transliteration: "Алам ядж'аль кайдахум фи тадлиль",
          russianText: 'Разве Он не сделал их козни тщетными?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6191,
          arabicText: 'وَأَرْسَلَ عَلَيْهِمْ طَيْرًا أَبَابِيلَ',
          transliteration: "Ва арсаля 'алейхим тайран абабиль",
          russianText: 'И наслал на них птиц стаями',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6192,
          arabicText: 'تَرْمِيهِم بِحِجَارَةٍۢ مِّن سِجِّيلٍۢ',
          transliteration: 'Тармихим би-хиджаратин мин сиджжиль',
          russianText: 'которые бросали в них каменья из обожжённой глины',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6193,
          arabicText: 'فَجَعَلَهُمْ كَعَصْفٍۢ مَّأْكُولٍۭ',
          transliteration: "Фаджа'аляхум ка-'асфин ма'куль",
          russianText: 'и превратил их в подобие изъеденных иссохших листьев',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О чём рассказывает сура Аль-Филь?',
          answers: [
            'О защите Каабы и крахе войска со слоном',
            'О безопасных торговых поездках курайшитов',
            'О заботе о сироте и бедняке'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'الْفِيلِ', answer: 'Слон'),
            LessonMatchPair(prompt: 'طَيْرًا', answer: 'Птицы'),
            LessonMatchPair(prompt: 'حِجَارَةٍ', answer: 'Камни'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6189,
          arabicText: 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَٰبِ الْفِيلِ',
          transliteration: "Алам тара кайфа фа'аля раббука би-асхабиль-филь",
          russianText: 'Расскажи первый аят суры Аль-Филь.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَٰبِ الْفِيلِ»?',
          answers: [
            'Разве ты не видел, как поступил твой Господь с владельцами слона?',
            'Разве Он не сделал их козни тщетными?',
            'И наслал на них птиц стаями'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что Аллах наслал на войско со слоном?',
          answers: [
            'Птиц стаями, метавших камни',
            'Сильный ветер',
            'Потоп'
          ],
          correctAnswerIndex: 0,
        ),
        // Cloze: материал бросаемых камней.
        LessonStep(
          type: LessonStepType.question,
          question: 'Птицы бросали в войско каменья из ___',
          answers: ['обожжённой глины', 'пальмовых волокон', 'расчёсанной шерсти'],
          correctAnswerIndex: 0,
        ),
        // Логика: итог/последовательность событий суры.
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем закончилась история войска со слоном в суре Аль-Филь?',
          answers: [
            'Оно стало подобно изъеденным иссохшим листьям',
            'Оно захватило Каабу',
            'Оно с миром вернулось домой'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'q_quraysh_1',
      title: 'Курайш',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 12,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Сура Курайш напоминает племени курайшитов о милости '
              'Аллаха: безопасные торговые поездки, пропитание и защита — '
              'повод искренне поклоняться Господу Каабы.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6194,
          arabicText: 'لِإِيلَٰفِ قُرَيْشٍ',
          transliteration: 'Ли-иляфи Курайш',
          russianText: 'Ради единения курайшитов',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6195,
          arabicText: 'إِۦلَٰفِهِمْ رِحْلَةَ الشِّتَآءِ وَالصَّيْفِ',
          transliteration: 'Иляфихим рихлята-ш-шитаи ва-с-сайф',
          russianText: 'единения их во время зимних и летних поездок',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6196,
          arabicText: 'فَلْيَعْبُدُوا۟ رَبَّ هَٰذَا الْبَيْتِ',
          transliteration: "Фаль-я'буду рабба хазаль-байт",
          russianText: 'Пусть же они поклоняются Господу этого Дома (Каабы)',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6197,
          arabicText: 'الَّذِىٓ أَطْعَمَهُم مِّن جُوعٍۢ وَءَامَنَهُم مِّنْ خَوْفٍۭ',
          transliteration: "Аллязи ат'амахум мин джу'ин ва аманахум мин хауф",
          russianText: 'который накормил их, избавив от голода, и защитил их от '
              'страха',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'К чему призывает сура Курайш?',
          answers: [
            'Поклоняться Господу Каабы, давшему пропитание и безопасность',
            'Гордиться знатностью своего племени',
            'Прекратить зимние и летние поездки'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6196,
          arabicText: 'فَلْيَعْبُدُوا۟ رَبَّ هَٰذَا الْبَيْتِ',
          transliteration: "Фаль-я'буду рабба хазаль-байт",
          russianText: 'Расскажи третий аят суры Курайш.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «فَلْيَعْبُدُوا۟ رَبَّ هَٰذَا الْبَيْتِ»?',
          answers: [
            'Пусть же они поклоняются Господу этого Дома (Каабы)',
            'Ради единения курайшитов',
            'Не помогло ему его богатство и то, что он приобрёл'
          ],
          correctAnswerIndex: 0,
        ),
        // Логика: за какие милости велено благодарить.
        LessonStep(
          type: LessonStepType.question,
          question: 'За какие две милости, по последнему аяту, курайшиты должны благодарить Господа?',
          answers: [
            'За избавление от голода и защиту от страха',
            'За победу над врагами и богатую добычу',
            'За долгую жизнь и многочисленное потомство'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(
                prompt: 'Ли-иляфи Курайш', answer: 'Ради единения курайшитов'),
            LessonMatchPair(
                prompt: "Фаль-я'буду рабба хазаль-байт",
                answer: 'Пусть же они поклоняются Господу этого Дома (Каабы)'),
            LessonMatchPair(
                prompt: 'Иляфихим рихлята-ш-шитаи ва-с-сайф',
                answer: 'единения их во время зимних и летних поездок'),
          ],
        ),
      ],
    ),
    const Lesson(
      id: 'q_maun_1',
      title: 'Аль-Маун',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 13,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Маун означает «Мелочь» (посильная помощь). Сура '
              'порицает того, кто считает воздаяние ложью, гонит сироту, '
              'небрежен в молитве и отказывает людям даже в малой помощи.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6198,
          arabicText: 'أَرَءَيْتَ الَّذِى يُكَذِّبُ بِالدِّينِ',
          transliteration: "А-ра'айталь-лязи юказзибу бид-дин",
          russianText: 'Видел ли ты того, кто считает ложью воздаяние?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6199,
          arabicText: 'فَذَٰلِكَ الَّذِى يَدُعُّ الْيَتِيمَ',
          transliteration: "Фазаликаль-лязи яду'ул-ятим",
          russianText: 'Это — тот, кто гонит сироту',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6200,
          arabicText: 'وَلَا يَحُضُّ عَلَىٰ طَعَامِ الْمِسْكِينِ',
          transliteration: "Ва ля яхудду 'аля та'амиль-мискин",
          russianText: 'и не побуждает накормить бедняка',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6201,
          arabicText: 'فَوَيْلٌۭ لِّلْمُصَلِّينَ',
          transliteration: 'Фавайлюн лиль-мусаллин',
          russianText: 'Горе молящимся',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6202,
          arabicText: 'الَّذِينَ هُمْ عَن صَلَاتِهِمْ سَاهُونَ',
          transliteration: "Аллязина хум 'ан салятихим сахун",
          russianText: 'которые небрежны к своим молитвам',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6203,
          arabicText: 'الَّذِينَ هُمْ يُرَآءُونَ',
          transliteration: "Аллязина хум юра'ун",
          russianText: 'которые лишь показывают себя',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6204,
          arabicText: 'وَيَمْنَعُونَ الْمَاعُونَ',
          transliteration: "Ва ямна'уналь-ма'ун",
          russianText: 'и отказывают даже в мелкой помощи',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кого порицает сура Аль-Маун?',
          answers: [
            'Того, кто отвергает воздаяние и небрежен в молитве и добре',
            'Того, кто копит богатство и злословит о людях',
            'Того, кто искренне заботится о сироте'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6198,
          arabicText: 'أَرَءَيْتَ الَّذِى يُكَذِّبُ بِالدِّينِ',
          transliteration: "А-ра'айталь-лязи юказзибу бид-дин",
          russianText: 'Расскажи первый аят суры Аль-Маун.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «أَرَءَيْتَ الَّذِى يُكَذِّبُ بِالدِّينِ»?',
          answers: [
            'Видел ли ты того, кто считает ложью воздаяние?',
            'Это — тот, кто гонит сироту',
            'Горе молящимся'
          ],
          correctAnswerIndex: 0,
        ),
        // Арабское слово: «сирота» среди близких существительных суры.
        LessonStep(
          type: LessonStepType.question,
          question: 'Какое слово в суре Аль-Маун означает «сирота»?',
          answers: ['الْيَتِيمَ', 'الْمِسْكِينِ', 'الْمَاعُونَ'],
          correctAnswerIndex: 0,
        ),
        // Логика: за что грозит «горе молящимся».
        LessonStep(
          type: LessonStepType.question,
          question: 'За что, по суре, грозит «горе молящимся»?',
          answers: [
            'За небрежность к молитве и показное поклонение',
            'За слишком долгую молитву',
            'За молитву в неурочное время'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(
                prompt: "Фазаликаль-лязи яду'ул-ятим",
                answer: 'Это — тот, кто гонит сироту'),
            LessonMatchPair(
                prompt: 'Фавайлюн лиль-мусаллин', answer: 'Горе молящимся'),
            LessonMatchPair(
                prompt: "Аллязина хум юра'ун",
                answer: 'которые лишь показывают себя'),
          ],
        ),
      ],
    ),
    const Lesson(
      id: 'q_kawthar_1',
      title: 'Аль-Каусар',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 14,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Каусар означает «Изобилие» — это дар Пророку, мир ему. '
              'Самая короткая сура Корана: в благодарность велено '
              'совершать молитву ради Господа и приносить жертву.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6205,
          arabicText: 'إِنَّآ أَعْطَيْنَٰكَ الْكَوْثَرَ',
          transliteration: "Инна а'тайнакаль-каусар",
          russianText: 'Воистину, Мы даровали тебе аль-Каусар (изобилие)',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6206,
          arabicText: 'فَصَلِّ لِرَبِّكَ وَانْحَرْ',
          transliteration: 'Фасалли ли-раббика ванхар',
          russianText: 'Посему совершай молитву ради своего Господа и заколи '
              'жертву',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6207,
          arabicText: 'إِنَّ شَانِئَكَ هُوَ الْأَبْتَرُ',
          transliteration: "Инна шани'ака хуваль-абтар",
          russianText: 'Воистину, твой ненавистник сам окажется безвестным',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что велено делать в благодарность в суре Аль-Каусар?',
          answers: [
            'Совершать молитву ради Господа и приносить жертву',
            'Поститься весь год напролёт',
            'Раздать всё имущество бедным'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'الْكَوْثَرَ', answer: 'Изобилие'),
            LessonMatchPair(prompt: 'فَصَلِّ', answer: 'Совершай молитву'),
            LessonMatchPair(prompt: 'وَانْحَرْ', answer: 'И заколи жертву'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6205,
          arabicText: 'إِنَّآ أَعْطَيْنَٰكَ الْكَوْثَرَ',
          transliteration: "Инна а'тайнакаль-каусар",
          russianText: 'Расскажи первый аят суры Аль-Каусар.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «إِنَّآ أَعْطَيْنَٰكَ الْكَوْثَرَ»?',
          answers: [
            'Воистину, Мы даровали тебе аль-Каусар (изобилие)',
            'Воистину, человек в убытке',
            'Воистину, твой ненавистник сам окажется безвестным'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «فَصَلِّ لِرَبِّكَ وَانْحَرْ»?',
          answers: [
            'Посему совершай молитву ради своего Господа и заколи жертву',
            'Пусть же они поклоняются Господу этого Дома (Каабы)',
            'Веди нас прямым путём'
          ],
          correctAnswerIndex: 0,
        ),
        // Cloze на арабском: название дара в первом аяте.
        LessonStep(
          type: LessonStepType.question,
          question: 'Заверши первый аят: «إِنَّآ أَعْطَيْنَٰكَ ___»',
          answers: ['الْكَوْثَرَ', 'الْفَلَقِ', 'النَّاسِ'],
          correctAnswerIndex: 0,
        ),
        // Логика: смысл последнего аята про ненавистника.
        LessonStep(
          type: LessonStepType.question,
          question: 'Что сказано в последнем аяте о ненавистнике Пророка?',
          answers: [
            'Что он сам окажется безвестным (лишённым блага)',
            'Что ему будет дано изобилие',
            'Что он получит долгую жизнь'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'q_kafirun_1',
      title: 'Аль-Кафирун',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 15,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Кафирун означает «Неверующие». Сура провозглашает '
              'чёткое размежевание в поклонении и завершается словами: '
              '«Вам — ваша религия, а мне — моя религия».',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6208,
          arabicText: 'قُلْ يَٰٓأَيُّهَا الْكَٰفِرُونَ',
          transliteration: 'Куль йа айюхаль-кафирун',
          russianText: 'Скажи: «О неверующие!»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6209,
          arabicText: 'لَآ أَعْبُدُ مَا تَعْبُدُونَ',
          transliteration: "Ля а'буду ма та'будун",
          russianText: 'Я не поклоняюсь тому, чему поклоняетесь вы',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6210,
          arabicText: 'وَلَآ أَنتُمْ عَٰبِدُونَ مَآ أَعْبُدُ',
          transliteration: "Ва ля антум 'абидуна ма а'буд",
          russianText: 'а вы не поклоняетесь Тому, чему поклоняюсь я',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6211,
          arabicText: 'وَلَآ أَنَا۠ عَابِدٌۭ مَّا عَبَدتُّمْ',
          transliteration: "Ва ля ана 'абидун ма 'абаттум",
          russianText: 'Я не поклоняюсь так, как поклонялись вы',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6212,
          arabicText: 'وَلَآ أَنتُمْ عَٰبِدُونَ مَآ أَعْبُدُ',
          transliteration: "Ва ля антум 'абидуна ма а'буд",
          russianText: 'и вы не поклоняетесь так, как поклоняюсь я',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6213,
          arabicText: 'لَكُمْ دِينُكُمْ وَلِىَ دِينِ',
          transliteration: 'Лякум динукум ва лия дин',
          russianText: 'Вам — ваша религия, а мне — моя религия!',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какими словами завершается сура Аль-Кафирун?',
          answers: ['«Вам — ваша религия, а мне — моя религия»', '«Хвала Господу миров»', '«Прибегаю к Господу рассвета»'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'الْكَافِرُونَ', answer: 'Неверующие'),
            LessonMatchPair(prompt: 'دِينُكُمْ', answer: 'Ваша религия'),
            LessonMatchPair(prompt: 'دِينِ', answer: 'Моя религия'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6213,
          arabicText: 'لَكُمْ دِينُكُمْ وَلِىَ دِينِ',
          transliteration: 'Лякум динукум ва лия дин',
          russianText: 'Расскажи последний аят суры Аль-Кафирун.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «لَآ أَعْبُدُ مَا تَعْبُدُونَ»?',
          answers: [
            'Я не поклоняюсь тому, чему поклоняетесь вы',
            'Хвала Аллаху, Господу миров',
            'Скажи: «О неверующие!»'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О чём говорит сура Аль-Кафирун?',
          answers: [
            'О чётком размежевании в поклонении',
            'О единстве и самодостаточности Аллаха',
            'О помощи Аллаха и грядущей победе'
          ],
          correctAnswerIndex: 0,
        ),
        // Cloze на арабском: последнее слово суры.
        LessonStep(
          type: LessonStepType.question,
          question: 'Заверши последний аят: «لَكُمْ دِينُكُمْ وَلِىَ ___»',
          answers: ['دِينِ', 'النَّاسِ', 'الْفَلَقِ'],
          correctAnswerIndex: 0,
        ),
        // Логика: главный вывод суры.
        LessonStep(
          type: LessonStepType.question,
          question: 'Какой вывод подводит итог суры Аль-Кафирун?',
          answers: [
            'В основах поклонения нет смешения: «Вам — ваша религия, а мне — моя»',
            'Со временем все станут поклоняться одинаково',
            'Верующий должен принять обычаи неверующих'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'q_nasr_1',
      title: 'Ан-Наср',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 16,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Ан-Наср означает «Помощь». Сура возвещает о помощи Аллаха '
              'и победе, когда люди толпами принимают ислам, и велит '
              'прославлять Господа и просить у Него прощения.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6214,
          arabicText: 'إِذَا جَآءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
          transliteration: 'Иза джаа насруллахи валь-фатх',
          russianText: 'Когда придёт помощь Аллаха и настанет победа',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6215,
          arabicText: 'وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِى دِينِ اللَّهِ أَفْوَاجًۭا',
          transliteration: "Ва ра'айтан-наса ядхулюна фи диниллахи афваджа",
          russianText: 'и ты увидишь, как люди толпами принимают религию Аллаха',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6216,
          arabicText: 'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ ۚ إِنَّهُۥ كَانَ تَوَّابًۢا',
          transliteration: 'Фасаббих би-хамди раббика вастагфирх, иннаху кана таввааба',
          russianText: 'то восславь хвалой Господа твоего и попроси у Него '
              'прощения. Воистину, Он принимает покаяние',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что велит делать сура Ан-Наср при помощи и победе?',
          answers: [
            'Прославлять Господа и просить прощения',
            'Гордиться победой перед людьми',
            'Собирать военную добычу'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'نَصْرُ', answer: 'Помощь'),
            LessonMatchPair(prompt: 'الْفَتْحُ', answer: 'Победа'),
            LessonMatchPair(prompt: 'النَّاسَ', answer: 'Люди'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6214,
          arabicText: 'إِذَا جَآءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
          transliteration: 'Иза джаа насруллахи валь-фатх',
          russianText: 'Расскажи первый аят суры Ан-Наср.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «إِذَا جَآءَ نَصْرُ اللَّهِ وَالْفَتْحُ»?',
          answers: [
            'Когда придёт помощь Аллаха и настанет победа',
            'Ради единения курайшитов',
            'Да отсохнут руки Абу Ляхаба, и сам он уже сгинул'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что, согласно суре Ан-Наср, увидит верующий?',
          answers: [
            'Как люди толпами принимают религию Аллаха',
            'Как войско отступает со слоном',
            'Как купцы уезжают в зимнюю поездку'
          ],
          correctAnswerIndex: 0,
        ),
        // Cloze на арабском: слово «помощь» в первом аяте.
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «إِذَا جَآءَ ___ اللَّهِ وَالْفَتْحُ»',
          answers: ['نَصْرُ', 'رَبِّ', 'يَوْمِ'],
          correctAnswerIndex: 0,
        ),
        // Логика: почему в час победы велено просить прощения.
        LessonStep(
          type: LessonStepType.question,
          question: 'Почему в час победы сура велит прославлять Господа и просить прощения?',
          answers: [
            'Потому что победа — милость Аллаха, её встречают смирением',
            'Потому что победа была случайной',
            'Потому что нужно потребовать награду за неё'
          ],
          correctAnswerIndex: 0,
        ),
      ],
    ),
    const Lesson(
      id: 'q_masad_1',
      title: 'Аль-Масад',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 17,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Масад означает «Пальмовые волокна». Сура о том, что '
              'богатство и вражда Абу Ляхаба, злейшего врага Пророка, не '
              'спасли его от наказания.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6217,
          arabicText: 'تَبَّتْ يَدَآ أَبِى لَهَبٍۢ وَتَبَّ',
          transliteration: 'Таббат яда аби ляхабин ва табб',
          russianText: 'Да отсохнут руки Абу Ляхаба, и сам он уже сгинул',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6218,
          arabicText: 'مَآ أَغْنَىٰ عَنْهُ مَالُهُۥ وَمَا كَسَبَ',
          transliteration: "Ма агна 'анху малюху ва ма касаб",
          russianText: 'Не помогло ему его богатство и то, что он приобрёл',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6219,
          arabicText: 'سَيَصْلَىٰ نَارًۭا ذَاتَ لَهَبٍۢ',
          transliteration: 'Саясля наран зата ляхаб',
          russianText: 'Он попадёт в пламенный Огонь',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6220,
          arabicText: 'وَامْرَأَتُهُۥ حَمَّالَةَ الْحَطَبِ',
          transliteration: "Вамра'атуху хаммаляталь-хатаб",
          russianText: 'а жена его будет носить дрова',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6221,
          arabicText: 'فِى جِيدِهَا حَبْلٌۭ مِّن مَّسَدٍۭ',
          transliteration: 'Фи джидиха хаблюм мим масад',
          russianText: 'и на шее у неё будет верёвка из пальмовых волокон',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О чём предупреждает сура Аль-Масад?',
          answers: [
            'Богатство и вражда не спасли Абу Ляхаба от наказания',
            'Знатный род оберегает человека от наказания',
            'Накопленное богатство продлевает жизнь'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6217,
          arabicText: 'تَبَّتْ يَدَآ أَبِى لَهَبٍۢ وَتَبَّ',
          transliteration: 'Таббат яда аби ляхабин ва табб',
          russianText: 'Расскажи первый аят суры Аль-Масад.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «تَبَّتْ يَدَآ أَبِى لَهَبٍۢ وَتَبَّ»?',
          answers: [
            'Да отсохнут руки Абу Ляхаба, и сам он уже сгинул',
            'Не помогло ему его богатство и то, что он приобрёл',
            'Он попадёт в пламенный Огонь'
          ],
          correctAnswerIndex: 0,
        ),
        // Логика: что не спасло Абу Ляхаба (тонкий дистрактор — родство).
        LessonStep(
          type: LessonStepType.question,
          question: 'Что, по 2-му аяту, не помогло Абу Ляхабу?',
          answers: [
            'Его богатство и то, что он приобрёл',
            'Его многочисленные молитвы',
            'Его родство с Пророком'
          ],
          correctAnswerIndex: 0,
        ),
        // Логика: контраст с сурой Аль-Каусар.
        LessonStep(
          type: LessonStepType.question,
          question: 'Аль-Каусар обещает изобилие Пророку, а что суля Аль-Масад его врагу?',
          answers: [
            'Гибель, огонь и бесславный конец',
            'Долгую и спокойную жизнь',
            'Богатую торговую прибыль'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(
                prompt: "Ма агна 'анху малюху ва ма касаб",
                answer: 'Не помогло ему его богатство и то, что он приобрёл'),
            LessonMatchPair(
                prompt: 'Саясля наран зата ляхаб',
                answer: 'Он попадёт в пламенный Огонь'),
            LessonMatchPair(
                prompt: 'Фи джидиха хаблюм мим масад',
                answer:
                    'и на шее у неё будет верёвка из пальмовых волокон'),
          ],
        ),
      ],
    ),
    const Lesson(
      id: 'q_review_short_surahs',
      title: 'Проверка коротких сур',
      subtitle: 'Средний тест: смысл и произношение новых сур',
      course: CourseType.quran,
      order: 18,
      xpReward: 45,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Это контроль после блока коротких сур. Вспомни их смысл и '
              'произнеси ключевые аяты без подсказки.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'В какой суре говорится о владельцах слона?',
          answers: ['Аль-Филь', 'Аль-Каусар', 'Ан-Наср'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какая сура завершается словами «Вам — ваша религия, а мне — моя»?',
          answers: ['Аль-Аср', 'Аль-Кафирун', 'Аль-Масад'],
          correctAnswerIndex: 1,
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6205,
          arabicText: 'إِنَّآ أَعْطَيْنَٰكَ الْكَوْثَرَ',
          transliteration: "Инна а'тайнакаль-каусар",
          russianText: 'Расскажи первый аят суры Аль-Каусар.',
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6177,
          arabicText: 'وَالْعَصْرِ',
          transliteration: "Валь-'аср",
          russianText: 'Расскажи первый аят суры Аль-Аср.',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какая сура призывает поклоняться Господу Каабы за пропитание и безопасность?',
          answers: ['Курайш', 'Аль-Масад', 'Аль-Каусар'],
          correctAnswerIndex: 0,
        ),
        // Логика: сура о сироте и небрежной молитве.
        LessonStep(
          type: LessonStepType.question,
          question: 'Какая сура порицает того, кто гонит сироту и небрежен в молитве?',
          answers: ['Аль-Маун', 'Аль-Каусар', 'Курайш'],
          correctAnswerIndex: 0,
        ),
        // Логика: сура о том, что богатство не спасло врага Пророка.
        LessonStep(
          type: LessonStepType.question,
          question: 'В какой суре сказано, что богатство и вражда не спасли Абу Ляхаба?',
          answers: ['Аль-Масад', 'Аль-Филь', 'Ан-Наср'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «إِنَّآ أَعْطَيْنَٰكَ الْكَوْثَرَ»?',
          answers: [
            'Воистину, Мы даровали тебе аль-Каусар (изобилие)',
            'Воистину, человек в убытке',
            'Когда придёт помощь Аллаха и настанет победа'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини начало суры с её названием',
          matchPairs: [
            LessonMatchPair(prompt: 'وَالْعَصْرِ', answer: 'Аль-Аср'),
            LessonMatchPair(
                prompt: 'إِنَّآ أَعْطَيْنَٰكَ الْكَوْثَرَ', answer: 'Аль-Каусар'),
            LessonMatchPair(
                prompt: 'إِذَا جَآءَ نَصْرُ اللَّهِ وَالْفَتْحُ', answer: 'Ан-Наср'),
          ],
        ),
      ],
    ),
    const Lesson(
      id: 'q_humaza_1',
      title: 'Аль-Хумаза',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 19,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Хумаза означает «Хулитель». Сура порицает того, кто '
              'злословит о людях, копит богатство и думает, что оно сделает '
              'его вечным, — и предупреждает о наказании Огнём.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6180,
          arabicText: 'وَيْلٌۭ لِّكُلِّ هُمَزَةٍۢ لُّمَزَةٍ',
          transliteration: 'Вайлюн ли-кулли хумазатин люмаза',
          russianText: 'Горе всякому хулителю и злословящему',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6181,
          arabicText: 'الَّذِى جَمَعَ مَالًۭا وَعَدَّدَهُۥ',
          transliteration: "Аллязи джама'а малян ва 'аддадах",
          russianText: 'который копит богатство и подсчитывает его',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6182,
          arabicText: 'يَحْسَبُ أَنَّ مَالَهُۥٓ أَخْلَدَهُۥ',
          transliteration: 'Яхсабу анна малаху ахладах',
          russianText: 'думая, что богатство увековечит его',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6183,
          arabicText: 'كَلَّا ۖ لَيُنۢبَذَنَّ فِى الْحُطَمَةِ',
          transliteration: 'Калля, ляюмбазанна филь-хутама',
          russianText: 'Но нет! Его непременно ввергнут в аль-Хутаму (Огонь)',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6184,
          arabicText: 'وَمَآ أَدْرَىٰكَ مَا الْحُطَمَةُ',
          transliteration: 'Ва ма адрака маль-хутама',
          russianText: 'Откуда тебе знать, что такое аль-Хутама?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6185,
          arabicText: 'نَارُ اللَّهِ الْمُوقَدَةُ',
          transliteration: 'Нару-ллахиль-муукада',
          russianText: 'Это — разожжённый огонь Аллаха',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6186,
          arabicText: 'الَّتِى تَطَّلِعُ عَلَى الْأَفْـِٔدَةِ',
          transliteration: "Алляти таттали'у 'аляль-аф'ида",
          russianText: 'который вздымается над сердцами',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6187,
          arabicText: 'إِنَّهَا عَلَيْهِم مُّؤْصَدَةٌۭ',
          transliteration: "Иннаха 'алейхим му'сада",
          russianText: 'Воистину, он сомкнётся над ними',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6188,
          arabicText: 'فِى عَمَدٍۢ مُّمَدَّدَةٍۭ',
          transliteration: "Фи 'амадим мумаддада",
          russianText: 'в вытянутых столбах',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кого порицает сура Аль-Хумаза?',
          answers: [
            'Того, кто злословит о людях и копит богатство',
            'Того, кто отвергает воздаяние и гонит сироту',
            'Того, кто раздаёт своё богатство бедным'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что о богатстве думает порицаемый в суре человек?',
          answers: [
            'Что его нужно раздать бедным',
            'Что оно бесполезно',
            'Что оно сделает его вечным'
          ],
          correctAnswerIndex: 2,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «وَيْلٌۭ لِّكُلِّ هُمَزَةٍۢ لُّمَزَةٍ»?',
          answers: [
            'Клянусь предвечерним временем',
            'Горе всякому хулителю и злословящему',
            'Хвала Аллаху, Господу миров'
          ],
          correctAnswerIndex: 1,
        ),
        // Cloze на арабском: что именно копит порицаемый.
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «الَّذِى جَمَعَ ___ وَعَدَّدَهُ»',
          answers: ['مَالًا', 'نَارًا', 'يَتِيمًا'],
          correctAnswerIndex: 0,
        ),
        // Логика: чем обернётся уверенность в вечности богатства.
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем обернётся для хулителя уверенность, что богатство сделает его вечным?',
          answers: [
            'Он будет ввергнут в аль-Хутаму — разожжённый огонь Аллаха',
            'Он получит неиссякаемую награду',
            'Его богатство приумножится'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'مَالًۭا', answer: 'Богатство'),
            LessonMatchPair(prompt: 'الْحُطَمَةُ', answer: 'Огонь (аль-Хутама)'),
            LessonMatchPair(prompt: 'نَارُ', answer: 'Огонь'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6180,
          arabicText: 'وَيْلٌۭ لِّكُلِّ هُمَزَةٍۢ لُّمَزَةٍ',
          transliteration: 'Вайлюн ли-кулли хумазатин люмаза',
          russianText: 'Расскажи первый аят суры Аль-Хумаза.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_takathur_1',
      title: 'Ат-Такасур',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 20,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Ат-Такасур означает «Страсть к приумножению». Сура '
              'предупреждает, что погоня за богатством и превосходством '
              'отвлекает человека вплоть до смерти, а затем последует спрос.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6169,
          arabicText: 'أَلْهَىٰكُمُ التَّكَاثُرُ',
          transliteration: 'Альхакумут-такасур',
          russianText: 'Страсть к приумножению (богатства) увлекает вас',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6170,
          arabicText: 'حَتَّىٰ زُرْتُمُ الْمَقَابِرَ',
          transliteration: 'Хатта зуртумуль-макабир',
          russianText: 'пока вы не посетите могилы',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6171,
          arabicText: 'كَلَّا سَوْفَ تَعْلَمُونَ',
          transliteration: "Калля, сауфа та'лямун",
          russianText: 'Но нет! Скоро вы узнаете!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6172,
          arabicText: 'ثُمَّ كَلَّا سَوْفَ تَعْلَمُونَ',
          transliteration: "Сумма калля, сауфа та'лямун",
          russianText: 'Ещё раз нет! Скоро вы узнаете!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6173,
          arabicText: 'كَلَّا لَوْ تَعْلَمُونَ عِلْمَ الْيَقِينِ',
          transliteration: "Калля, ляу та'лямуна 'ильмаль-якын",
          russianText:
              'Но нет! Если бы вы только обладали знанием с полной убеждённостью!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6174,
          arabicText: 'لَتَرَوُنَّ الْجَحِيمَ',
          transliteration: 'Латараунналь-джахим',
          russianText: 'Вы непременно увидите Ад',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6175,
          arabicText: 'ثُمَّ لَتَرَوُنَّهَا عَيْنَ الْيَقِينِ',
          transliteration: "Сумма латарауннаха 'айналь-якын",
          russianText: 'Затем вы увидите его воочию',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6176,
          arabicText: 'ثُمَّ لَتُسْـَٔلُنَّ يَوْمَئِذٍ عَنِ النَّعِيمِ',
          transliteration: "Сумма латус'алунна яумаизин 'анин-на'им",
          russianText: 'В тот день вы будете спрошены о благах',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О чём предупреждает сура Ат-Такасур?',
          answers: [
            'О том, что богатство даёт человеку вечность',
            'О том, что погоня за приумножением отвлекает вплоть до смерти',
            'О пользе странствий и торговли'
          ],
          correctAnswerIndex: 1,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «أَلْهَىٰكُمُ التَّكَاثُرُ»?',
          answers: [
            'Страсть к приумножению (богатства) увлекает вас',
            'Клянусь предвечерним временем',
            'Горе молящимся'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О чём человек будет спрошен в тот День, по концу суры?',
          answers: [
            'О числе поездок',
            'О именах предков',
            'О благах, которыми он пользовался'
          ],
          correctAnswerIndex: 2,
        ),
        // Cloze: до чего доводит человека страсть к приумножению.
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Страсть к приумножению увлекает вас, пока вы не посетите ___»',
          answers: ['могилы', 'храмы', 'рынки'],
          correctAnswerIndex: 0,
        ),
        // Логика: контраст Такасур и Аль-Аср (обе о времени и потере).
        LessonStep(
          type: LessonStepType.question,
          question: 'Что общего у сур Ат-Такасур и Аль-Аср?',
          answers: [
            'Обе предупреждают: без веры и дел человек тратит жизнь впустую',
            'Обе рассказывают о защите Каабы',
            'Обе клянутся мчащимися конями'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(
                prompt: 'Хатта зуртумуль-макабир',
                answer: 'пока вы не посетите могилы'),
            LessonMatchPair(
                prompt: 'Латараунналь-джахим',
                answer: 'Вы непременно увидите Ад'),
            LessonMatchPair(
                prompt: "Сумма латус'алунна яумаизин 'анин-на'им",
                answer: 'В тот день вы будете спрошены о благах'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6169,
          arabicText: 'أَلْهَىٰكُمُ التَّكَاثُرُ',
          transliteration: 'Альхакумут-такасур',
          russianText: 'Расскажи первый аят суры Ат-Такасур.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_qaria_1',
      title: 'Аль-Кариа',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 21,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Кариа означает «Великое бедствие» (Поражающее) — одно '
              'из названий Судного дня. Сура описывает потрясение того Дня и '
              'взвешивание дел на весах.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6158,
          arabicText: 'الْقَارِعَةُ',
          transliteration: "Аль-кари'а",
          russianText: 'Великое бедствие (Поражающее)',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6159,
          arabicText: 'مَا الْقَارِعَةُ',
          transliteration: "Маль-кари'а",
          russianText: 'Что такое Великое бедствие?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6160,
          arabicText: 'وَمَآ أَدْرَىٰكَ مَا الْقَارِعَةُ',
          transliteration: "Ва ма адрака маль-кари'а",
          russianText: 'Откуда тебе знать, что такое Великое бедствие?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6161,
          arabicText: 'يَوْمَ يَكُونُ النَّاسُ كَالْفَرَاشِ الْمَبْثُوثِ',
          transliteration: 'Яума якунун-насу каль-фараашиль-мабсус',
          russianText: 'В тот день люди будут подобны рассеянным мотылькам',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6162,
          arabicText: 'وَتَكُونُ الْجِبَالُ كَالْعِهْنِ الْمَنفُوشِ',
          transliteration: "Ва такунуль-джибалю каль-'ихниль-манфуш",
          russianText: 'а горы будут подобны расчёсанной шерсти',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6163,
          arabicText: 'فَأَمَّا مَن ثَقُلَتْ مَوَٰزِينُهُۥ',
          transliteration: 'Фа-амма ман сакулят маваазинух',
          russianText: 'Тогда тот, чья чаша весов окажется тяжёлой',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6164,
          arabicText: 'فَهُوَ فِى عِيشَةٍۢ رَّاضِيَةٍۢ',
          transliteration: 'Фахува фи ишатир-радыя',
          russianText: 'обретёт приятную жизнь',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6165,
          arabicText: 'وَأَمَّا مَنْ خَفَّتْ مَوَٰزِينُهُۥ',
          transliteration: 'Ва амма ман хаффат маваазинух',
          russianText: 'Тому же, чья чаша весов окажется лёгкой',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6166,
          arabicText: 'فَأُمُّهُۥ هَاوِيَةٌۭ',
          transliteration: 'Фа-уммуху хаавия',
          russianText: 'пристанищем будет Пропасть (Преисподняя)',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6167,
          arabicText: 'وَمَآ أَدْرَىٰكَ مَا هِيَهْ',
          transliteration: 'Ва ма адрака ма хийях',
          russianText: 'Откуда тебе знать, что это такое?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6168,
          arabicText: 'نَارٌ حَامِيَةٌۢ',
          transliteration: 'Нарун хамия',
          russianText: 'Это — жаркий Огонь',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что означает «Аль-Кариа»?',
          answers: [
            'Землетрясение в тот День',
            'Великое бедствие (Судный день)',
            'Разожжённый огонь'
          ],
          correctAnswerIndex: 1,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'С чем сравниваются люди в тот День по суре Аль-Кариа?',
          answers: [
            'С рассеянными мотыльками',
            'С каплями дождя',
            'С расчёсанной шерстью'
          ],
          correctAnswerIndex: 0,
        ),
        // Логика: близкая пара образов — люди и горы.
        LessonStep(
          type: LessonStepType.question,
          question: 'А с чем в тот День сравниваются горы?',
          answers: [
            'С расчёсанной шерстью',
            'С рассеянными мотыльками',
            'С каплями дождя'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что ждёт того, чья чаша весов окажется тяжёлой?',
          answers: [
            'Пропасть (Преисподняя)',
            'Жаркий Огонь',
            'Приятная жизнь'
          ],
          correctAnswerIndex: 2,
        ),
        // Логика: судьба по «лёгкой» чаше весов (контраст с предыдущим).
        LessonStep(
          type: LessonStepType.question,
          question: 'А что ждёт того, чья чаша весов окажется лёгкой?',
          answers: [
            'Пропасть — жаркий Огонь',
            'Приятная жизнь',
            'Неиссякаемая награда'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'الْجِبَالُ', answer: 'Горы'),
            LessonMatchPair(prompt: 'مَوَٰزِينُهُۥ', answer: 'Его весы'),
            LessonMatchPair(prompt: 'نَارٌ', answer: 'Огонь'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6158,
          arabicText: 'الْقَارِعَةُ',
          transliteration: "Аль-кари'а",
          russianText: 'Расскажи первый аят суры Аль-Кариа.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_adiyat_1',
      title: 'Аль-Адият',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 22,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Адият означает «Мчащиеся» (скакуны). Сура клянётся '
              'мчащимися конями и напоминает, что человек неблагодарен '
              'своему Господу, а в Судный день откроется всё сокрытое.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6147,
          arabicText: 'وَالْعَٰدِيَٰتِ ضَبْحًۭا',
          transliteration: "Валь-'адияти дабха",
          russianText: 'Клянусь мчащимися, тяжело дышащими',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6148,
          arabicText: 'فَالْمُورِيَٰتِ قَدْحًۭا',
          transliteration: 'Фаль-мурияти кадха',
          russianText: 'высекающими искры копытами',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6149,
          arabicText: 'فَالْمُغِيرَٰتِ صُبْحًۭا',
          transliteration: 'Фаль-мугырати субха',
          russianText: 'нападающими на заре',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6150,
          arabicText: 'فَأَثَرْنَ بِهِۦ نَقْعًۭا',
          transliteration: 'Фа-асарна бихи нак\'а',
          russianText: 'которые поднимают этим облако пыли',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6151,
          arabicText: 'فَوَسَطْنَ بِهِۦ جَمْعًا',
          transliteration: "Фавасатна бихи джам'а",
          russianText: 'и врываются с ним в гущу врага',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6152,
          arabicText: 'إِنَّ الْإِنسَٰنَ لِرَبِّهِۦ لَكَنُودٌۭ',
          transliteration: 'Инналь-инсана ли-раббихи лякануд',
          russianText: 'Воистину, человек неблагодарен своему Господу',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6153,
          arabicText: 'وَإِنَّهُۥ عَلَىٰ ذَٰلِكَ لَشَهِيدٌۭ',
          transliteration: "Ва иннаху 'аля залика ляшахид",
          russianText: 'и он сам является тому свидетелем',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6154,
          arabicText: 'وَإِنَّهُۥ لِحُبِّ الْخَيْرِ لَشَدِيدٌ',
          transliteration: 'Ва иннаху ли-хуббиль-хайри ляшадид',
          russianText: 'Воистину, он страстно любит блага',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6155,
          arabicText: 'أَفَلَا يَعْلَمُ إِذَا بُعْثِرَ مَا فِى الْقُبُورِ',
          transliteration: "Афаля я'ляму иза бу'сира ма филь-кубур",
          russianText: 'Разве он не знает, что будет, когда извлекут то, что в '
              'могилах',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6156,
          arabicText: 'وَحُصِّلَ مَا فِى الصُّدُورِ',
          transliteration: 'Ва хуссыля ма фис-судур',
          russianText: 'и обнаружится то, что в груди',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6157,
          arabicText: 'إِنَّ رَبَّهُم بِهِمْ يَوْمَئِذٍۢ لَّخَبِيرٌۢ',
          transliteration: 'Инна раббахум бихим яумаизин ляхабир',
          russianText: 'в тот день Господь их будет осведомлён о них',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем клянётся начало суры Аль-Адият?',
          answers: [
            'Предвечерним временем',
            'Мчащимися скакунами',
            'Смоковницей и оливой'
          ],
          correctAnswerIndex: 1,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «إِنَّ الْإِنسَٰنَ لِرَبِّهِۦ لَكَنُودٌۭ»?',
          answers: [
            'Воистину, человек неблагодарен своему Господу',
            'Воистину, человек в убытке',
            'Воистину, Мы даровали тебе изобилие'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что откроется в Судный день по концу суры Аль-Адият?',
          answers: [
            'Только внешние дела',
            'Ничего не изменится',
            'То, что скрыто в могилах и в груди'
          ],
          correctAnswerIndex: 2,
        ),
        // Логика: главный упрёк человеку в середине суры.
        LessonStep(
          type: LessonStepType.question,
          question: 'В чём сура Аль-Адият упрекает человека?',
          answers: [
            'Он неблагодарен Господу и страстно любит блага',
            'Он слишком много молится',
            'Он раздаёт всё своё имущество'
          ],
          correctAnswerIndex: 0,
        ),
        // Логика: зачем клятва мчащимися конями.
        LessonStep(
          type: LessonStepType.question,
          question: 'К какому выводу подводит клятва мчащимися конями?',
          answers: [
            'Что человек неблагодарен своему Господу',
            'Что кони достойнее людей',
            'Что нужно готовиться к торговле'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'الْإِنسَٰنَ', answer: 'Человек'),
            LessonMatchPair(prompt: 'الْقُبُورِ', answer: 'Могилы'),
            LessonMatchPair(prompt: 'الصُّدُورِ', answer: 'Груди (сердца)'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6147,
          arabicText: 'وَالْعَٰدِيَٰتِ ضَبْحًۭا',
          transliteration: "Валь-'адияти дабха",
          russianText: 'Расскажи первый аят суры Аль-Адият.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_zalzala_1',
      title: 'Аз-Зальзаля',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 23,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аз-Зальзаля означает «Землетрясение». Сура описывает '
              'сотрясение земли в Судный день и итог: даже добро или зло '
              'весом с пылинку человек увидит.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6139,
          arabicText: 'إِذَا زُلْزِلَتِ الْأَرْضُ زِلْزَالَهَا',
          transliteration: 'Иза зульзилятиль-арду зильзаляха',
          russianText: 'Когда земля содрогнётся своим сотрясением',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6140,
          arabicText: 'وَأَخْرَجَتِ الْأَرْضُ أَثْقَالَهَا',
          transliteration: 'Ва ахраджатиль-арду аскаляха',
          russianText: 'и извергнет земля свои ноши',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6141,
          arabicText: 'وَقَالَ الْإِنسَٰنُ مَا لَهَا',
          transliteration: 'Ва каляль-инсану ма ляха',
          russianText: 'и человек скажет: «Что с нею?»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6142,
          arabicText: 'يَوْمَئِذٍۢ تُحَدِّثُ أَخْبَارَهَا',
          transliteration: 'Яумаизин тухаддису ахбараха',
          russianText: 'В тот день она поведает свои вести',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6143,
          arabicText: 'بِأَنَّ رَبَّكَ أَوْحَىٰ لَهَا',
          transliteration: 'Би-анна раббака аухаа ляха',
          russianText: 'потому что Господь твой внушит ей это',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6144,
          arabicText: 'يَوْمَئِذٍۢ يَصْدُرُ النَّاسُ أَشْتَاتًۭا لِّيُرَوْا۟ أَعْمَٰلَهُمْ',
          transliteration: "Яумаизин ясдурун-насу ашратан лиюрау а'маляхум",
          russianText: 'В тот день люди выйдут толпами, чтобы им показали их '
              'деяния',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6145,
          arabicText: 'فَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًۭا يَرَهُۥ',
          transliteration: "Фаман я'маль мискаля зарратин хайран ярах",
          russianText: 'Кто сделал добро весом в пылинку, увидит его',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6146,
          arabicText: 'وَمَن يَعْمَلْ مِثْقَالَ ذَرَّةٍۢ شَرًّۭا يَرَهُۥ',
          transliteration: "Ва ман я'маль мискаля зарратин шарран ярах",
          russianText: 'и кто сделал зло весом в пылинку, увидит его',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О чём главная тема суры Аз-Зальзаля?',
          answers: [
            'О сотрясении земли и отчёте за дела',
            'О ночи Предопределения',
            'О заботе о сироте и бедняке'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что, по суре, увидит человек в Судный день?',
          answers: [
            'Только чужие дела',
            'Даже добро или зло весом с пылинку',
            'Ничего из своих дел'
          ],
          correctAnswerIndex: 1,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «إِذَا زُلْزِلَتِ الْأَرْضُ زِلْزَالَهَا»?',
          answers: [
            'Клянусь предвечерним временем',
            'Хвала Аллаху, Господу миров',
            'Когда земля содрогнётся своим сотрясением'
          ],
          correctAnswerIndex: 2,
        ),
        // Cloze: концовка предпоследнего аята.
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Кто сделал добро весом в пылинку, ___»',
          answers: ['увидит его', 'забудет о нём', 'не увидит его'],
          correctAnswerIndex: 0,
        ),
        // Логика: смысл образа «весом с пылинку».
        LessonStep(
          type: LessonStepType.question,
          question: 'Чему учит образ «добро или зло весом с пылинку»?',
          answers: [
            'Ни одно, даже мельчайшее дело не пропадёт без отчёта',
            'Малые дела не учитываются вовсе',
            'Учитываются только большие поступки'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'الْأَرْضُ', answer: 'Земля'),
            LessonMatchPair(prompt: 'ذَرَّةٍ', answer: 'Пылинка'),
            LessonMatchPair(prompt: 'خَيْرًۭا', answer: 'Добро'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6139,
          arabicText: 'إِذَا زُلْزِلَتِ الْأَرْضُ زِلْزَالَهَا',
          transliteration: 'Иза зульзилятиль-арду зильзаляха',
          russianText: 'Расскажи первый аят суры Аз-Зальзаля.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_qadr_1',
      title: 'Аль-Кадр',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 24,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Кадр означает «Предопределение». Сура о ночи '
              'Предопределения, в которую был ниспослан Коран: она лучше '
              'тысячи месяцев и благополучна до самой зари.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6126,
          arabicText: 'إِنَّآ أَنزَلْنَٰهُ فِى لَيْلَةِ الْقَدْرِ',
          transliteration: 'Инна анзальнаху фи ляйлятиль-кадр',
          russianText: 'Воистину, Мы ниспослали его (Коран) в ночь '
              'Предопределения',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6127,
          arabicText: 'وَمَآ أَدْرَىٰكَ مَا لَيْلَةُ الْقَدْرِ',
          transliteration: 'Ва ма адрака ма ляйлятуль-кадр',
          russianText: 'Откуда тебе знать, что такое ночь Предопределения?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6128,
          arabicText: 'لَيْلَةُ الْقَدْرِ خَيْرٌۭ مِّنْ أَلْفِ شَهْرٍۢ',
          transliteration: 'Ляйлятуль-кадри хайрун мин альфи шахр',
          russianText: 'Ночь Предопределения лучше тысячи месяцев',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6129,
          arabicText: 'تَنَزَّلُ الْمَلَٰٓئِكَةُ وَالرُّوحُ فِيهَا بِإِذْنِ رَبِّهِم مِّن كُلِّ أَمْرٍۢ',
          transliteration:
              'Танаццалюль-маляикату вар-руху фиха би-изни раббихим мин кулли амр',
          russianText: 'В эту ночь ангелы и Дух (Джибриль) нисходят с дозволения '
              'их Господа по всем повелениям',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6130,
          arabicText: 'سَلَٰمٌ هِىَ حَتَّىٰ مَطْلَعِ الْفَجْرِ',
          transliteration: "Салямун хия хатта матля'иль-фаджр",
          russianText: 'Она благополучна вплоть до наступления зари',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что было ниспослано в ночь Предопределения?',
          answers: ['Коран', 'Тора', 'Псалмы'],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'С чем сравнивается ночь Предопределения по её ценности?',
          answers: [
            'С одним днём',
            'Она лучше тысячи месяцев',
            'С одним годом'
          ],
          correctAnswerIndex: 1,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'До какого времени длится благополучие этой ночи?',
          answers: [
            'До полуночи',
            'До заката',
            'До наступления зари'
          ],
          correctAnswerIndex: 2,
        ),
        // Cloze на арабском: мера сравнения ценности ночи.
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ ___» (лучше тысячи…)',
          answers: ['شَهْرٍ', 'يَوْمٍ', 'سَنَةٍ'],
          correctAnswerIndex: 0,
        ),
        // Логика: кто нисходит в эту ночь.
        LessonStep(
          type: LessonStepType.question,
          question: 'Кто, по суре, нисходит в ночь Предопределения с дозволения Господа?',
          answers: [
            'Ангелы и Дух (Джибриль)',
            'Только праведные люди',
            'Пророки прошлых народов'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'لَيْلَةِ', answer: 'Ночь'),
            LessonMatchPair(prompt: 'الْمَلَٰٓئِكَةُ', answer: 'Ангелы'),
            LessonMatchPair(prompt: 'الْفَجْرِ', answer: 'Заря'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6126,
          arabicText: 'إِنَّآ أَنزَلْنَٰهُ فِى لَيْلَةِ الْقَدْرِ',
          transliteration: 'Инна анзальнаху фи ляйлятиль-кадр',
          russianText: 'Расскажи первый аят суры Аль-Кадр.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_tin_1',
      title: 'Ат-Тин',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 25,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Ат-Тин означает «Смоковница». Сура клянётся смоковницей '
              'и оливой и напоминает: человек сотворён в прекраснейшем '
              'облике, а спасутся уверовавшие и творившие добро.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6099,
          arabicText: 'وَالتِّينِ وَالزَّيْتُونِ',
          transliteration: 'Ват-тини ваз-зайтун',
          russianText: 'Клянусь смоковницей и оливой',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6100,
          arabicText: 'وَطُورِ سِينِينَ',
          transliteration: 'Ва тури синин',
          russianText: 'клянусь горой Синаем',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6101,
          arabicText: 'وَهَٰذَا الْبَلَدِ الْأَمِينِ',
          transliteration: 'Ва хазаль-балядиль-амин',
          russianText: 'и этим безопасным городом (Меккой)!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6102,
          arabicText: 'لَقَدْ خَلَقْنَا الْإِنسَٰنَ فِىٓ أَحْسَنِ تَقْوِيمٍۢ',
          transliteration: 'Лякад халакналь-инсана фи ахсани таквим',
          russianText: 'Мы сотворили человека в прекраснейшем облике',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6103,
          arabicText: 'ثُمَّ رَدَدْنَٰهُ أَسْفَلَ سَٰفِلِينَ',
          transliteration: 'Сумма рададнаху асфаля сафилин',
          russianText: 'а потом низвергнем его в нижайшее из низких',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6104,
          arabicText: 'إِلَّا الَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ الصَّٰلِحَٰتِ فَلَهُمْ أَجْرٌ غَيْرُ مَمْنُونٍۢ',
          transliteration:
              "Илляллязина аману ва 'амилю-с-салихати фалахум аджрун гайру мамнун",
          russianText: 'за исключением тех, которые уверовали и творили добрые '
              'дела. Им уготована неиссякаемая награда',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6105,
          arabicText: 'فَمَا يُكَذِّبُكَ بَعْدُ بِالدِّينِ',
          transliteration: 'Фама юказзибука ба\'ду бид-дин',
          russianText: 'Что же после этого заставляет тебя считать ложью '
              'воздаяние?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6106,
          arabicText: 'أَلَيْسَ اللَّهُ بِأَحْكَمِ الْحَٰكِمِينَ',
          transliteration: 'Алейсаллаху би-ахкамиль-хакимин',
          russianText: 'Разве Аллах не является Наимудрейшим из судей?',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем клянётся начало суры Ат-Тин?',
          answers: [
            'Смоковницей и оливой',
            'Мчащимися конями',
            'Предвечерним временем'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'В каком облике, по суре, сотворён человек?',
          answers: [
            'В нижайшем из низких',
            'В прекраснейшем облике',
            'Без всякой соразмерности'
          ],
          correctAnswerIndex: 1,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кому уготована неиссякаемая награда по суре Ат-Тин?',
          answers: [
            'Самым богатым',
            'Всем без исключения',
            'Уверовавшим и творившим добрые дела'
          ],
          correctAnswerIndex: 2,
        ),
        // Cloze на арабском: качество, в котором сотворён человек.
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «لَقَدْ خَلَقْنَا الْإِنسَٰنَ فِىٓ أَحْسَنِ ___» (в прекраснейшем…)',
          answers: ['تَقْوِيمٍ', 'سَافِلِينَ', 'شَهْرٍ'],
          correctAnswerIndex: 0,
        ),
        // Логика: что определяет конечную участь человека.
        LessonStep(
          type: LessonStepType.question,
          question: 'Человек создан в прекраснейшем облике; что, по суре, определяет его конечную участь?',
          answers: [
            'Вера и добрые дела',
            'Знатность его рода',
            'Размер его богатства'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'التِّينِ', answer: 'Смоковница'),
            LessonMatchPair(prompt: 'الزَّيْتُونِ', answer: 'Олива'),
            LessonMatchPair(prompt: 'الْإِنسَٰنَ', answer: 'Человек'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6099,
          arabicText: 'وَالتِّينِ وَالزَّيْتُونِ',
          transliteration: 'Ват-тини ваз-зайтун',
          russianText: 'Расскажи первый аят суры Ат-Тин.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_sharh_1',
      title: 'Аш-Шарх',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 26,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аш-Шарх означает «Раскрытие». Сура утешает Пророка, мир '
              'ему: Аллах раскрыл его грудь и облегчил ношу, и обещает, что за '
              'тягостью непременно приходит облегчение.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6091,
          arabicText: 'أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ',
          transliteration: 'Алам нашрах ляка садрак',
          russianText: 'Разве Мы не раскрыли для тебя грудь твою?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6092,
          arabicText: 'وَوَضَعْنَا عَنكَ وِزْرَكَ',
          transliteration: "Ва вада'на 'анка визрак",
          russianText: 'и не сняли с тебя ношу твою',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6093,
          arabicText: 'الَّذِىٓ أَنقَضَ ظَهْرَكَ',
          transliteration: 'Аллязи анкада захрак',
          russianText: 'которая отягощала твою спину?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6094,
          arabicText: 'وَرَفَعْنَا لَكَ ذِكْرَكَ',
          transliteration: "Ва рафа'на ляка зикрак",
          russianText: 'и не возвысили твоё поминание (славу)?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6095,
          arabicText: 'فَإِنَّ مَعَ الْعُسْرِ يُسْرًا',
          transliteration: "Фа-инна ма'аль-'усри юсра",
          russianText: 'Воистину, за тягостью наступает облегчение',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6096,
          arabicText: 'إِنَّ مَعَ الْعُسْرِ يُسْرًۭا',
          transliteration: "Инна ма'аль-'усри юсра",
          russianText: 'За каждой тягостью наступает облегчение',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6097,
          arabicText: 'فَإِذَا فَرَغْتَ فَانصَبْ',
          transliteration: 'Фа-иза фарагта фансаб',
          russianText: 'Посему, освободившись, трудись в поклонении',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6098,
          arabicText: 'وَإِلَىٰ رَبِّكَ فَارْغَب',
          transliteration: 'Ва иля раббика фаргаб',
          russianText: 'и к Господу твоему устремляйся',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какое утешение повторяет сура Аш-Шарх?',
          answers: [
            'За тягостью наступает облегчение',
            'Трудности никогда не заканчиваются',
            'Облегчение приходит только к богатым'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как переводится «أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ»?',
          answers: [
            'Клянусь предвечерним временем',
            'Разве Мы не раскрыли для тебя грудь твою?',
            'Хвала Аллаху, Господу миров'
          ],
          correctAnswerIndex: 1,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'К чему призывает конец суры Аш-Шарх?',
          answers: [
            'Оставить дела',
            'Копить богатство',
            'Освободившись, трудиться и устремляться к Господу'
          ],
          correctAnswerIndex: 2,
        ),
        // Cloze на арабском: слово «облегчение».
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «فَإِنَّ مَعَ الْعُسْرِ ___» (за тягостью — …)',
          answers: ['يُسْرًا', 'عُسْرًا', 'نَارًا'],
          correctAnswerIndex: 0,
        ),
        // Логика: зачем обещание об облегчении повторено дважды.
        LessonStep(
          type: LessonStepType.question,
          question: 'Почему в суре дважды сказано «за тягостью наступает облегчение»?',
          answers: [
            'Чтобы усилить утешение: за каждой тягостью непременно придёт облегчение',
            'Потому что тягостей всегда две',
            'Чтобы указать на две разные суры'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'صَدْرَكَ', answer: 'Твою грудь'),
            LessonMatchPair(prompt: 'الْعُسْرِ', answer: 'Тягость'),
            LessonMatchPair(prompt: 'يُسْرًا', answer: 'Облегчение'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6091,
          arabicText: 'أَلَمْ نَشْرَحْ لَكَ صَدْرَكَ',
          transliteration: 'Алам нашрах ляка садрак',
          russianText: 'Расскажи первый аят суры Аш-Шарх.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_duha_1',
      title: 'Ад-Духа',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 27,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Ад-Духа означает «Утро». Сура утешает Пророка, мир ему: '
              'Господь не покинул его, будущее для него лучше настоящего, а в '
              'ответ на милость велено быть добрым к сироте и просящему.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6080,
          arabicText: 'وَالضُّحَىٰ',
          transliteration: 'Вад-духа',
          russianText: 'Клянусь утром (предполуденным светом)',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6081,
          arabicText: 'وَالَّيْلِ إِذَا سَجَىٰ',
          transliteration: 'Валь-ляйли иза саджа',
          russianText: 'и ночью, когда она густеет!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6082,
          arabicText: 'مَا وَدَّعَكَ رَبُّكَ وَمَا قَلَىٰ',
          transliteration: "Ма вадда'ака раббука ва ма каля",
          russianText: 'Не покинул тебя Господь твой и не возненавидел',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6083,
          arabicText: 'وَلَلْـَٔاخِرَةُ خَيْرٌۭ لَّكَ مِنَ الْأُولَىٰ',
          transliteration: 'Ва лаль-ахырату хайрун ляка миналь-уля',
          russianText: 'Воистину, будущее для тебя лучше, чем настоящее',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6084,
          arabicText: 'وَلَسَوْفَ يُعْطِيكَ رَبُّكَ فَتَرْضَىٰٓ',
          transliteration: "Ва лясауфа ю'тыка раббука фатарда",
          russianText: 'Господь твой непременно одарит тебя, и ты будешь доволен',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6085,
          arabicText: 'أَلَمْ يَجِدْكَ يَتِيمًۭا فَـَٔاوَىٰ',
          transliteration: 'Алам яджидка ятиман фа-аваа',
          russianText: 'Разве Он не нашёл тебя сиротой и не приютил?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6086,
          arabicText: 'وَوَجَدَكَ ضَآلًّۭا فَهَدَىٰ',
          transliteration: 'Ва ваджадака даллян фахада',
          russianText: 'Он нашёл тебя заблудшим и повёл прямым путём',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6087,
          arabicText: 'وَوَجَدَكَ عَآئِلًۭا فَأَغْنَىٰ',
          transliteration: "Ва ваджадака 'аилян фа-агна",
          russianText: 'Он нашёл тебя бедным и обогатил',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6088,
          arabicText: 'فَأَمَّا الْيَتِيمَ فَلَا تَقْهَرْ',
          transliteration: 'Фа-аммаль-ятима фаля такхар',
          russianText: 'Посему не притесняй сироту',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6089,
          arabicText: 'وَأَمَّا السَّآئِلَ فَلَا تَنْهَرْ',
          transliteration: 'Ва аммас-саиля фаля танхар',
          russianText: 'и не прогоняй просящего',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6090,
          arabicText: 'وَأَمَّا بِنِعْمَةِ رَبِّكَ فَحَدِّثْ',
          transliteration: "Ва амма би-ни'мати раббика фахаддис",
          russianText: 'и возвещай о милости твоего Господа',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какое утешение несёт сура Ад-Духа?',
          answers: [
            'Господь не покинул Пророка и не возненавидел',
            'Господь оставил Пророка без внимания',
            'Настоящее для Пророка лучше будущего'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как велит сура относиться к сироте?',
          answers: [
            'Прогонять его',
            'Не притеснять его',
            'Не замечать его'
          ],
          correctAnswerIndex: 1,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что, по концу суры, нужно делать с милостью Господа?',
          answers: [
            'Скрывать её',
            'Забыть о ней',
            'Возвещать о ней'
          ],
          correctAnswerIndex: 2,
        ),
        // Логика: обещание о будущем.
        LessonStep(
          type: LessonStepType.question,
          question: 'Что, по суре Ад-Духа, сказано о будущем Пророка?',
          answers: [
            'Будущее для него лучше, чем настоящее',
            'Будущее хуже настоящего',
            'В будущем ничего не изменится'
          ],
          correctAnswerIndex: 0,
        ),
        // Логика: что общего у соседних сур-утешений.
        LessonStep(
          type: LessonStepType.question,
          question: 'Что общего у сур Ад-Духа и Аш-Шарх?',
          answers: [
            'Обе утешают Пророка обещанием милости и облегчения',
            'Обе рассказывают о Судном дне',
            'Обе клянутся мчащимися конями'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'الضُّحَىٰ', answer: 'Утро'),
            LessonMatchPair(prompt: 'الَّيْلِ', answer: 'Ночь'),
            LessonMatchPair(prompt: 'الْيَتِيمَ', answer: 'Сирота'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6080,
          arabicText: 'وَالضُّحَىٰ',
          transliteration: 'Вад-духа',
          russianText: 'Расскажи первый аят суры Ад-Духа.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_ala_1',
      title: 'Аль-Аля',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 28,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Аля означает «Всевышний». Сура велит славить имя '
              'Господа, напоминает о Его творении и наставлении, и учит, что '
              'преуспел тот, кто очистился, поминал Господа и молился.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5949,
          arabicText: 'سَبِّحِ اسْمَ رَبِّكَ الْأَعْلَى',
          transliteration: "Саббихисма раббикаль-а'ля",
          russianText: 'Славь имя Господа твоего Всевышнего',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5950,
          arabicText: 'الَّذِى خَلَقَ فَسَوَّىٰ',
          transliteration: 'Аллязи халака фасавва',
          russianText: 'который сотворил всё сущее и придал ему соразмерность',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5951,
          arabicText: 'وَالَّذِى قَدَّرَ فَهَدَىٰ',
          transliteration: 'Валлязи каддара фахада',
          russianText: 'который предопределил и направил к цели',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5952,
          arabicText: 'وَالَّذِىٓ أَخْرَجَ الْمَرْعَىٰ',
          transliteration: "Валлязи ахраджаль-мар'а",
          russianText: 'который взрастил пастбище',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5953,
          arabicText: 'فَجَعَلَهُۥ غُثَآءً أَحْوَىٰ',
          transliteration: "Фаджа'аляху гусаан ахва",
          russianText: 'а потом превратил его в сухую бурую массу',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5954,
          arabicText: 'سَنُقْرِئُكَ فَلَا تَنسَىٰٓ',
          transliteration: "Санукри'ука фаля танса",
          russianText: 'Мы прочтём тебе, и ты не забудешь',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5955,
          arabicText: 'إِلَّا مَا شَآءَ اللَّهُ ۚ إِنَّهُۥ يَعْلَمُ الْجَهْرَ وَمَا يَخْفَىٰ',
          transliteration:
              "Илля ма шаа-ллаху, иннаху я'лямуль-джахра ва ма яхфа",
          russianText: 'кроме того, что пожелает Аллах. Он знает явное и то, '
              'что сокрыто',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5956,
          arabicText: 'وَنُيَسِّرُكَ لِلْيُسْرَىٰ',
          transliteration: 'Ва нуяссирука лиль-юсра',
          russianText: 'Мы облегчим тебе путь к легчайшему',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5957,
          arabicText: 'فَذَكِّرْ إِن نَّفَعَتِ الذِّكْرَىٰ',
          transliteration: "Фазаккир ин нафа'атиз-зикра",
          russianText: 'Наставляй же, если наставление принесёт пользу',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5958,
          arabicText: 'سَيَذَّكَّرُ مَن يَخْشَىٰ',
          transliteration: 'Саяззаккару ман яхша',
          russianText: 'Воспримет его тот, кто боится Аллаха',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5959,
          arabicText: 'وَيَتَجَنَّبُهَا الْأَشْقَى',
          transliteration: 'Ва ятаджаннабухаль-ашка',
          russianText: 'и уклонится от него самый несчастный',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5960,
          arabicText: 'الَّذِى يَصْلَى النَّارَ الْكُبْرَىٰ',
          transliteration: 'Аллязи ясляан-нараль-кубра',
          russianText: 'который войдёт в Огонь величайший',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5961,
          arabicText: 'ثُمَّ لَا يَمُوتُ فِيهَا وَلَا يَحْيَىٰ',
          transliteration: 'Сумма ля ямуту фиха ва ля яхья',
          russianText: 'где не умрёт и не будет жить',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5962,
          arabicText: 'قَدْ أَفْلَحَ مَن تَزَكَّىٰ',
          transliteration: 'Кад афляха ман тазакка',
          russianText: 'Преуспел тот, кто очистился',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5963,
          arabicText: 'وَذَكَرَ اسْمَ رَبِّهِۦ فَصَلَّىٰ',
          transliteration: 'Ва закарасма раббихи фасалля',
          russianText: 'поминал имя Господа своего и совершал молитву',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5964,
          arabicText: 'بَلْ تُؤْثِرُونَ الْحَيَوٰةَ الدُّنْيَا',
          transliteration: "Баль ту'сируналь-хаятад-дунья",
          russianText: 'Но вы отдаёте предпочтение мирской жизни',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5965,
          arabicText: 'وَالْـَٔاخِرَةُ خَيْرٌۭ وَأَبْقَىٰٓ',
          transliteration: 'Валь-ахырату хайрун ва абка',
          russianText: 'хотя Последняя жизнь лучше и вечнее',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5966,
          arabicText: 'إِنَّ هَٰذَا لَفِى الصُّحُفِ الْأُولَىٰ',
          transliteration: 'Инна хаза ляфис-сухуфиль-уля',
          russianText: 'Воистину, это записано в первых свитках',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5967,
          arabicText: 'صُحُفِ إِبْرَٰهِيمَ وَمُوسَىٰ',
          transliteration: 'Сухуфи ибрахима ва муса',
          russianText: 'свитках Ибрахима (Авраама) и Мусы (Моисея)',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'С чего начинается сура Аль-Аля?',
          answers: [
            'Со славословия имени Господа Всевышнего',
            'С клятвы смоковницей и оливой',
            'С клятвы предвечерним временем'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кто, по суре Аль-Аля, преуспел?',
          answers: [
            'Тот, кто накопил больше всех',
            'Тот, кто очистился, поминал Господа и молился',
            'Тот, кто предпочёл мирскую жизнь'
          ],
          correctAnswerIndex: 1,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какая жизнь, по суре, лучше и вечнее?',
          answers: [
            'Мирская жизнь',
            'Жизнь в богатстве',
            'Последняя жизнь'
          ],
          correctAnswerIndex: 2,
        ),
        // Cloze на арабском: чем завершается «Преуспел тот, кто…».
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «قَدْ أَفْلَحَ مَن ___» (преуспел тот, кто…)',
          answers: ['تَزَكَّىٰ', 'جَمَعَ', 'كَذَّبَ'],
          correctAnswerIndex: 0,
        ),
        // Логика: кому противопоставлен преуспевший.
        LessonStep(
          type: LessonStepType.question,
          question: 'Кому в конце суры противопоставлен тот, кто очистился и молился?',
          answers: [
            'Тем, кто предпочёл мирскую жизнь, хотя Последняя лучше и вечнее',
            'Тем, кто клялся смоковницей и оливой',
            'Владельцам слона'
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Сопоставь слова с их смыслом',
          matchPairs: [
            LessonMatchPair(prompt: 'الْأَعْلَى', answer: 'Всевышний'),
            LessonMatchPair(prompt: 'خَلَقَ', answer: 'Сотворил'),
            LessonMatchPair(prompt: 'الْـَٔاخِرَةُ', answer: 'Последняя жизнь'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5949,
          arabicText: 'سَبِّحِ اسْمَ رَبِّكَ الْأَعْلَى',
          transliteration: "Саббихисма раббикаль-а'ля",
          russianText: 'Расскажи первый аят суры Аль-Аля.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_alaq_1',
      title: 'Аль-Аляк',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 29,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Аляк означает «Сгусток крови». С этой мекканской суры началось ниспослание Корана: она велит читать во имя Господа, напоминает о сотворении человека и о том, что человек преступает границы, возомнив себя ни в чём не нуждающимся.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6107,
          arabicText: 'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِى خَلَقَ',
          transliteration: "Икра' бисми раббикаллязи халак",
          russianText: 'Читай во имя Господа твоего, Который сотворил',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6108,
          arabicText: 'خَلَقَ الْإِنسَٰنَ مِنْ عَلَقٍ',
          transliteration: "Халакаль-инсана мин 'аляк",
          russianText: 'сотворил человека из сгустка крови',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6109,
          arabicText: 'اقْرَأْ وَرَبُّكَ الْأَكْرَمُ',
          transliteration: "Икра' ва раббукаль-акрам",
          russianText: 'Читай, ведь твой Господь — Самый великодушный',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6110,
          arabicText: 'الَّذِى عَلَّمَ بِالْقَلَمِ',
          transliteration: "Аллязи 'аллама биль-калям",
          russianText: 'Который научил посредством письменной трости',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6111,
          arabicText: 'عَلَّمَ الْإِنسَٰنَ مَا لَمْ يَعْلَمْ',
          transliteration: "'Алламаль-инсана ма лям я'лям",
          russianText: 'научил человека тому, чего он не знал',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6112,
          arabicText: 'كَلَّآ إِنَّ الْإِنسَٰنَ لَيَطْغَىٰٓ',
          transliteration: 'Калля инналь-инсана ляятга',
          russianText: 'Но нет! Человек преступает границы дозволенного',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6113,
          arabicText: 'أَن رَّءَاهُ اسْتَغْنَىٰٓ',
          transliteration: 'Ар-рааху-стагна',
          russianText: 'когда ему кажется, что он ни в чём не нуждается',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6114,
          arabicText: 'إِنَّ إِلَىٰ رَبِّكَ الرُّجْعَىٰٓ',
          transliteration: "Инна иля раббикар-рудж'а",
          russianText: 'Воистину, к твоему Господу предстоит возвращение',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6115,
          arabicText: 'أَرَءَيْتَ الَّذِى يَنْهَىٰ',
          transliteration: "Ара'айталлязи янха",
          russianText: 'Видел ли ты того, кто запрещает',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6116,
          arabicText: 'عَبْدًا إِذَا صَلَّىٰٓ',
          transliteration: "'Абдан иза салля",
          russianText: 'рабу, когда тот молится?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6117,
          arabicText: 'أَرَءَيْتَ إِن كَانَ عَلَى الْهُدَىٰٓ',
          transliteration: "Ара'айта ин кана 'аляль-худа",
          russianText: 'Что ты думаешь, а вдруг он был на прямом пути',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6118,
          arabicText: 'أَوْ أَمَرَ بِالتَّقْوَىٰٓ',
          transliteration: 'Ау амара бит-таква',
          russianText: 'или призывал к богобоязненности?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6119,
          arabicText: 'أَرَءَيْتَ إِن كَذَّبَ وَتَوَلَّىٰٓ',
          transliteration: "Ара'айта ин каззаба ва тавалля",
          russianText: 'Что ты думаешь, а вдруг он счёл истину ложью и отвернулся?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6120,
          arabicText: 'أَلَمْ يَعْلَم بِأَنَّ اللَّهَ يَرَىٰ',
          transliteration: "Алям я'лям би'анналлаха яра",
          russianText: 'Неужели он не знал, что Аллах видит его?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6121,
          arabicText: 'كَلَّا لَئِن لَّمْ يَنتَهِ لَنَسْفَعًۢا بِالنَّاصِيَةِ',
          transliteration: "Калля ляил лям янтахи лянасфа'ам бин-насия",
          russianText: 'Но нет! Если он не прекратит, Мы схватим его за хохол',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6122,
          arabicText: 'نَاصِيَةٍۢ كَٰذِبَةٍ خَاطِئَةٍۢ',
          transliteration: 'Насиятин казибатин хатыа',
          russianText: 'хохол лживый, грешный',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6123,
          arabicText: 'فَلْيَدْعُ نَادِيَهُۥ',
          transliteration: "Фальяд'у надияh",
          russianText: 'Пусть он зовёт на помощь своих сообщников',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6124,
          arabicText: 'سَنَدْعُ الزَّبَانِيَةَ',
          transliteration: "Санад'уз-забания",
          russianText: 'Мы же позовём стражей Ада',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6125,
          arabicText: 'كَلَّا لَا تُطِعْهُ وَاسْجُدْ وَاقْتَرِب ۩',
          transliteration: "Калля ля тути'hу васджуд вактариб",
          russianText: 'Но нет! Не повинуйся ему, а пади ниц и приближайся к Аллаху',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'С какого повеления начинается сура Аль-Аляк?',
          answers: [
            '«Читай во имя Господа твоего, Который сотворил»',
            '«Славь имя Господа твоего Всевышнего»',
            '«Клянусь предвечерним временем»',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Из чего, по суре, сотворён человек?',
          answers: [
            "Из сгустка крови ('аляк)",
            'Из капли изливающейся жидкости',
            'Из сухой звонкой глины',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чему научил человека Господь, «Который научил посредством письменной трости»?',
          answers: [
            'Тому, чего человек не знал',
            'Счёту дней и ночей',
            'Именам всех ангелов',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Человек преступает границы, когда ему кажется, что он ни в чём не ___»',
          answers: [
            'нуждается',
            'виноват',
            'сомневается',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем завершается сура Аль-Аляк?',
          answers: [
            'Повелением пасть ниц и приближаться к Аллаху',
            'Обещанием изобилия (аль-Каусар)',
            'Клятвой смоковницей и оливой',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: "Икра' бисми раббикаллязи халак", answer: 'Читай во имя Господа твоего, Который сотворил'),
            LessonMatchPair(prompt: "Халакаль-инсана мин 'аляк", answer: 'сотворил человека из сгустка крови'),
            LessonMatchPair(prompt: "Икра' ва раббукаль-акрам", answer: 'Читай, ведь твой Господь — Самый великодушный'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6107,
          arabicText: 'اقْرَأْ بِاسْمِ رَبِّكَ الَّذِى خَلَقَ',
          transliteration: "Икра' бисми раббикаллязи халак",
          russianText: 'Расскажи первый аят суры Аль-Аляк.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_shams_1',
      title: 'Аш-Шамс',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 30,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аш-Шамс означает «Солнце». Мекканская сура начинается с череды клятв солнцем, луной, днём, ночью, небом, землёй и душой, а завершается судьбой самудян: преуспел тот, кто очистил свою душу, и погиб тот, кто погряз в грехе.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6044,
          arabicText: 'وَالشَّمْسِ وَضُحَىٰهَا',
          transliteration: 'Ваш-шамси ва духаха',
          russianText: 'Клянусь солнцем и его утренним сиянием',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6045,
          arabicText: 'وَالْقَمَرِ إِذَا تَلَىٰهَا',
          transliteration: 'Валь-камари иза таляха',
          russianText: 'Клянусь луной, которая следует за ним',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6046,
          arabicText: 'وَالنَّهَارِ إِذَا جَلَّىٰهَا',
          transliteration: 'Ван-нахари иза джалляха',
          russianText: 'Клянусь днём, который делает его ясным',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6047,
          arabicText: 'وَالَّيْلِ إِذَا يَغْشَىٰهَا',
          transliteration: 'Валь-ляйли иза ягшаха',
          russianText: 'Клянусь ночью, которая его покрывает',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6048,
          arabicText: 'وَالسَّمَآءِ وَمَا بَنَىٰهَا',
          transliteration: 'Вас-самаи ва ма банаха',
          russianText: 'Клянусь небом и Тем, Кто его построил',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6049,
          arabicText: 'وَالْأَرْضِ وَمَا طَحَىٰهَا',
          transliteration: 'Валь-арды ва ма тахаха',
          russianText: 'Клянусь землёй и Тем, Кто её распростёр',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6050,
          arabicText: 'وَنَفْسٍۢ وَمَا سَوَّىٰهَا',
          transliteration: 'Ва нафсин ва ма савваха',
          russianText: 'Клянусь душой и Тем, Кто придал ей соразмерность',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6051,
          arabicText: 'فَأَلْهَمَهَا فُجُورَهَا وَتَقْوَىٰهَا',
          transliteration: 'Фа-альхамаха фуджураха ва таква ха',
          russianText: 'и внушил ей её грехи и её богобоязненность',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6052,
          arabicText: 'قَدْ أَفْلَحَ مَن زَكَّىٰهَا',
          transliteration: 'Кад афляха ман заккаха',
          russianText: 'Преуспел тот, кто очистил её',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6053,
          arabicText: 'وَقَدْ خَابَ مَن دَسَّىٰهَا',
          transliteration: 'Ва кад хаба ман дассаха',
          russianText: 'и понёс урон тот, кто скрыл её во грехе',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6054,
          arabicText: 'كَذَّبَتْ ثَمُودُ بِطَغْوَىٰهَآ',
          transliteration: 'Каззабат самуду битагваха',
          russianText: 'Самудяне сочли пророка лжецом из-за своего беззакония',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6055,
          arabicText: 'إِذِ انۢبَعَثَ أَشْقَىٰهَا',
          transliteration: "Изин-ба'аса ашкаха",
          russianText: 'когда самый несчастный из них вызвался убить верблюдицу',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6056,
          arabicText: 'فَقَالَ لَهُمْ رَسُولُ اللَّهِ نَاقَةَ اللَّهِ وَسُقْيَٰهَا',
          transliteration: 'Факаля ляхум расулуллахи накаталлахи ва сукйаха',
          russianText: 'Посланник Аллаха сказал им: «Берегите верблюдицу Аллаха и её питьё!»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6057,
          arabicText: 'فَكَذَّبُوهُ فَعَقَرُوهَا فَدَمْدَمَ عَلَيْهِمْ رَبُّهُم بِذَنۢبِهِمْ فَسَوَّىٰهَا',
          transliteration: "Факаззабуху фа'акаруха фадамдама 'аляйхим раббухум бизанбихим фасавваха",
          russianText: 'Они сочли его лжецом и зарезали её, и Господь погубил их за грех и сровнял их с землёй',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6058,
          arabicText: 'وَلَا يَخَافُ عُقْبَٰهَا',
          transliteration: "Ва ля яхафу 'укбаха",
          russianText: 'и не опасался Он последствий этого',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем клянётся начало суры Аш-Шамс?',
          answers: [
            'Солнцем, луной, днём и ночью',
            'Зарёй и десятью ночами',
            'Небом и ночным путником',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кто, по суре Аш-Шамс, преуспел?',
          answers: [
            'Тот, кто очистил свою душу',
            'Тот, кто накопил больше всех',
            'Тот, кто прожил долгую жизнь',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'За что были погублены самудяне?',
          answers: [
            'За то, что сочли пророка лжецом и зарезали верблюдицу',
            'За поклонение слону',
            'За то, что не кормили сироту',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Преуспел тот, кто ___ её (душу)»',
          answers: [
            'очистил',
            'унизил',
            'забыл',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что противопоставлено в суре: «Преуспел тот, кто очистил душу»?',
          answers: [
            '«и понёс урон тот, кто скрыл её во грехе»',
            '«хотя Последняя жизнь лучше и вечнее»',
            '«и уклонится от него самый несчастный»',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Ваш-шамси ва духаха', answer: 'Клянусь солнцем и его утренним сиянием'),
            LessonMatchPair(prompt: 'Кад афляха ман заккаха', answer: 'Преуспел тот, кто очистил душу'),
            LessonMatchPair(prompt: 'Каззабат самуду битагваха', answer: 'Самудяне сочли пророка лжецом'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6044,
          arabicText: 'وَالشَّمْسِ وَضُحَىٰهَا',
          transliteration: 'Ваш-шамси ва духаха',
          russianText: 'Расскажи первый аят суры Аш-Шамс.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_layl_1',
      title: 'Аль-Лейль',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 31,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Лейль означает «Ночь». Мекканская сура клянётся ночью и днём и противопоставляет два пути: щедрого богобоязненного человека, которому облегчён путь к легчайшему, и скупца, отвергшего истину, которому облегчён путь к тягчайшему.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6059,
          arabicText: 'وَالَّيْلِ إِذَا يَغْشَىٰ',
          transliteration: 'Валь-ляйли иза ягша',
          russianText: 'Клянусь ночью, когда она покрывает мраком',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6060,
          arabicText: 'وَالنَّهَارِ إِذَا تَجَلَّىٰ',
          transliteration: 'Ван-нахари иза таджалля',
          russianText: 'Клянусь днём, когда он проясняется',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6061,
          arabicText: 'وَمَا خَلَقَ الذَّكَرَ وَالْأُنثَىٰٓ',
          transliteration: 'Ва ма халаказ-закара валь-унса',
          russianText: 'и Тем, Кто сотворил мужчину и женщину',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6062,
          arabicText: 'إِنَّ سَعْيَكُمْ لَشَتَّىٰ',
          transliteration: "Инна са'йакум ляшатта",
          russianText: 'Воистину, ваши стремления различны',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6063,
          arabicText: 'فَأَمَّا مَنْ أَعْطَىٰ وَاتَّقَىٰ',
          transliteration: "Фа-амма ман а'та ваттака",
          russianText: 'Тому, кто делал пожертвования и был богобоязнен',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6064,
          arabicText: 'وَصَدَّقَ بِالْحُسْنَىٰ',
          transliteration: 'Ва саддака биль-хусна',
          russianText: 'и признавал истинность прекраснейшего',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6065,
          arabicText: 'فَسَنُيَسِّرُهُۥ لِلْيُسْرَىٰ',
          transliteration: 'Фасануяссируху лиль-юсра',
          russianText: 'Мы облегчим путь к легчайшему',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6066,
          arabicText: 'وَأَمَّا مَنۢ بَخِلَ وَاسْتَغْنَىٰ',
          transliteration: 'Ва амма мам бахиля вастагна',
          russianText: 'А тому, кто был скуп и полагал, что не нуждается в Аллахе',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6067,
          arabicText: 'وَكَذَّبَ بِالْحُسْنَىٰ',
          transliteration: 'Ва каззаба биль-хусна',
          russianText: 'и счёл ложью прекраснейшее',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6068,
          arabicText: 'فَسَنُيَسِّرُهُۥ لِلْعُسْرَىٰ',
          transliteration: "Фасануяссируху лиль-'усра",
          russianText: 'Мы облегчим путь к тягчайшему',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6069,
          arabicText: 'وَمَا يُغْنِى عَنْهُ مَالُهُۥٓ إِذَا تَرَدَّىٰٓ',
          transliteration: "Ва ма югни 'анху малуху иза тарадда",
          russianText: 'Не спасёт его богатство, когда он падёт в Огонь',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6070,
          arabicText: 'إِنَّ عَلَيْنَا لَلْهُدَىٰ',
          transliteration: "Инна 'аляйна ляль-худа",
          russianText: 'Воистину, Нам надлежит вести прямым путём',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6071,
          arabicText: 'وَإِنَّ لَنَا لَلْـَٔاخِرَةَ وَالْأُولَىٰ',
          transliteration: 'Ва инна ляна ляль-ахира валь-уля',
          russianText: 'Воистину, Нам принадлежит и Последняя, и первая жизнь',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6072,
          arabicText: 'فَأَنذَرْتُكُمْ نَارًۭا تَلَظَّىٰ',
          transliteration: 'Фа-анзартукум наран таляззa',
          russianText: 'Я предостерёг вас от пылающего Огня',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6073,
          arabicText: 'لَا يَصْلَىٰهَآ إِلَّا الْأَشْقَى',
          transliteration: 'Ля ясляха илляль-ашка',
          russianText: 'Войдёт в него только самый несчастный',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6074,
          arabicText: 'الَّذِى كَذَّبَ وَتَوَلَّىٰ',
          transliteration: 'Аллязи каззаба ва тавалля',
          russianText: 'который счёл истину ложью и отвернулся',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6075,
          arabicText: 'وَسَيُجَنَّبُهَا الْأَتْقَى',
          transliteration: 'Ва саюджаннабухаль-атка',
          russianText: 'Отдалён будет от него самый богобоязненный',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6076,
          arabicText: 'الَّذِى يُؤْتِى مَالَهُۥ يَتَزَكَّىٰ',
          transliteration: "Аллязи ю'ти малаху ятазакка",
          russianText: 'который раздаёт своё имущество, очищаясь',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6077,
          arabicText: 'وَمَا لِأَحَدٍ عِندَهُۥ مِن نِّعْمَةٍۢ تُجْزَىٰٓ',
          transliteration: "Ва ма ли-ахадин 'индаху мин ни'матин туджза",
          russianText: 'и всякую милость возмещает не ради награды',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6078,
          arabicText: 'إِلَّا ابْتِغَآءَ وَجْهِ رَبِّهِ الْأَعْلَىٰ',
          transliteration: "Илляб-тигаа ваджхи раббихиль-а'ля",
          russianText: 'а только из стремления к Лику Господа своего Всевышнего',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6079,
          arabicText: 'وَلَسَوْفَ يَرْضَىٰ',
          transliteration: 'Ва лясауфа ярда',
          russianText: 'И он непременно будет доволен',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем клянётся начало суры Аль-Лейль?',
          answers: [
            'Ночью, днём и Тем, Кто сотворил мужчину и женщину',
            'Солнцем и его утренним сиянием',
            'Небом, обладателем созвездий',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кому Аллах «облегчит путь к легчайшему»?',
          answers: [
            'Тому, кто давал милостыню, был богобоязнен и признавал истину',
            'Тому, кто был скуп и счёл истину ложью',
            'Тому, кто накопил больше всех',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Ради чего, по суре, богобоязненный раздаёт имущество?',
          answers: [
            'Ради Лика Господа своего Всевышнего',
            'Ради похвалы людей',
            'Ради возврата долга',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «А тому, кто был скуп... Мы облегчим путь к ___»',
          answers: [
            'тягчайшему',
            'легчайшему',
            'изобилию',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какие два пути противопоставляет сура Аль-Лейль?',
          answers: [
            'Путь щедрого и богобоязненного — и путь скупого, отвергшего истину',
            'Путь богатых торговцев — и путь бедняков',
            'Путь владельцев слона — и путь жителей Мекки',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Валь-ляйли иза ягша', answer: 'Клянусь ночью, когда она покрывает мраком'),
            LessonMatchPair(prompt: 'Фасануяссируху лиль-юсра', answer: 'Мы облегчим путь к легчайшему'),
            LessonMatchPair(prompt: "Фасануяссируху лиль-'усра", answer: 'Мы облегчим путь к тягчайшему'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 6059,
          arabicText: 'وَالَّيْلِ إِذَا يَغْشَىٰ',
          transliteration: 'Валь-ляйли иза ягша',
          russianText: 'Расскажи первый аят суры Аль-Лейль.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_fajr_1',
      title: 'Аль-Фаджр',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 32,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Фаджр означает «Заря». Мекканская сура клянётся зарёй и ночами, напоминает о гибели адитов, самудян и Фараона, порицает любовь к богатству и небрежение к сироте, а завершается радостным призывом к умиротворённой душе вернуться к Господу и войти в Рай.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5994,
          arabicText: 'وَالْفَجْرِ',
          transliteration: 'Валь-фаджр',
          russianText: 'Клянусь зарёй',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5995,
          arabicText: 'وَلَيَالٍ عَشْرٍۢ',
          transliteration: "Ва ляялин 'ашр",
          russianText: 'клянусь десятью ночами',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5996,
          arabicText: 'وَالشَّفْعِ وَالْوَتْرِ',
          transliteration: "Ваш-шаф'и валь-ватр",
          russianText: 'клянусь чётом и нечётом',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5997,
          arabicText: 'وَالَّيْلِ إِذَا يَسْرِ',
          transliteration: 'Валь-ляйли иза яср',
          russianText: 'клянусь ночью, когда она уходит',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5998,
          arabicText: 'هَلْ فِى ذَٰلِكَ قَسَمٌۭ لِّذِى حِجْرٍ',
          transliteration: 'Халь фи заликя касамул лизи хиджр',
          russianText: 'Неужели этого не достаточно для обладающего разумом?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5999,
          arabicText: 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِعَادٍ',
          transliteration: "Алям тара кайфа фа'аля раббука би'ад",
          russianText: 'Разве ты не видел, как Господь твой поступил с адитами',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6000,
          arabicText: 'إِرَمَ ذَاتِ الْعِمَادِ',
          transliteration: "Ирама затиль-'имад",
          russianText: 'народом Ирама, обладавшим колоннами',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6001,
          arabicText: 'الَّتِى لَمْ يُخْلَقْ مِثْلُهَا فِى الْبِلَٰدِ',
          transliteration: 'Алляти лям юхляк мислюха филь-биляд',
          russianText: 'подобных которым не было создано в странах',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6002,
          arabicText: 'وَثَمُودَ الَّذِينَ جَابُوا۟ الصَّخْرَ بِالْوَادِ',
          transliteration: 'Ва самудаллязина джабус-сахра биль-вад',
          russianText: 'и с самудянами, которые высекали скалы в долине',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6003,
          arabicText: 'وَفِرْعَوْنَ ذِى الْأَوْتَادِ',
          transliteration: "Ва фир'ауна зиль-автад",
          russianText: 'и с Фараоном, обладателем кольев',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6004,
          arabicText: 'الَّذِينَ طَغَوْا۟ فِى الْبِلَٰدِ',
          transliteration: 'Аллязина тагау филь-биляд',
          russianText: 'которые преступали границы дозволенного в странах',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6005,
          arabicText: 'فَأَكْثَرُوا۟ فِيهَا الْفَسَادَ',
          transliteration: 'Фа-аксару фихаль-фасад',
          russianText: 'и умножали в них нечестие',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6006,
          arabicText: 'فَصَبَّ عَلَيْهِمْ رَبُّكَ سَوْطَ عَذَابٍ',
          transliteration: "Фасабба 'аляйхим раббука саута 'азаб",
          russianText: 'Тогда твой Господь обрушил на них бич мучений',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6007,
          arabicText: 'إِنَّ رَبَّكَ لَبِالْمِرْصَادِ',
          transliteration: 'Инна раббака лябиль-мирсад',
          russianText: 'Воистину, твой Господь наблюдает, как в засаде',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6008,
          arabicText: 'فَأَمَّا الْإِنسَٰنُ إِذَا مَا ابْتَلَىٰهُ رَبُّهُۥ فَأَكْرَمَهُۥ وَنَعَّمَهُۥ فَيَقُولُ رَبِّىٓ أَكْرَمَنِ',
          transliteration: "Фа-аммаль-инсану иза мабталяху раббуху фа-акрамаху ва на''амаху файакулю рабби акраман",
          russianText: 'Когда Господь испытывает человека, оказывая ему милость и одаряя благами, тот говорит: «Господь мой почтил меня!»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6009,
          arabicText: 'وَأَمَّآ إِذَا مَا ابْتَلَىٰهُ فَقَدَرَ عَلَيْهِ رِزْقَهُۥ فَيَقُولُ رَبِّىٓ أَهَٰنَنِ',
          transliteration: "Ва амма иза мабталяху факадара 'аляйхи ризкаху файакулю рабби ахаанан",
          russianText: 'Когда же Он испытывает его, ограничивая его в пропитании, тот говорит: «Господь мой унизил меня!»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6010,
          arabicText: 'كَلَّا ۖ بَل لَّا تُكْرِمُونَ الْيَتِيمَ',
          transliteration: 'Калля баль ля тукримуналь-ятим',
          russianText: 'Но нет! Вы сами не почитаете сироту',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6011,
          arabicText: 'وَلَا تَحَٰٓضُّونَ عَلَىٰ طَعَامِ الْمِسْكِينِ',
          transliteration: "Ва ля тахаддуна 'аля та'амиль-мискин",
          russianText: 'не побуждаете друг друга кормить бедняка',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6012,
          arabicText: 'وَتَأْكُلُونَ التُّرَاثَ أَكْلًۭا لَّمًّۭا',
          transliteration: "Ва та'кулюнат-тураса аклял ляммa",
          russianText: 'жадно пожираете наследство целиком',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6013,
          arabicText: 'وَتُحِبُّونَ الْمَالَ حُبًّۭا جَمًّۭا',
          transliteration: 'Ва тухиббуналь-маля хуббан джаммa',
          russianText: 'и любите богатство любовью безмерной',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6014,
          arabicText: 'كَلَّآ إِذَا دُكَّتِ الْأَرْضُ دَكًّۭا دَكًّۭا',
          transliteration: 'Калля иза дуккатиль-арду даккан даккa',
          russianText: 'Но нет! Когда земля будет раздроблена на куски',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6015,
          arabicText: 'وَجَآءَ رَبُّكَ وَالْمَلَكُ صَفًّۭا صَفًّۭا',
          transliteration: 'Ва джаа раббука валь-малаку саффан саффa',
          russianText: 'и придёт твой Господь с ангелами, выстроившимися рядами',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6016,
          arabicText: 'وَجِا۟ىٓءَ يَوْمَئِذٍۭ بِجَهَنَّمَ ۚ يَوْمَئِذٍۢ يَتَذَكَّرُ الْإِنسَٰنُ وَأَنَّىٰ لَهُ الذِّكْرَىٰ',
          transliteration: "Ва джиа йаума'изин биджаханнам, йаума'изин ятазаккаруль-инсану ва анна ляхуз-зикра",
          russianText: 'и будет в тот день приведён Ад. В тот день человек помянет назидание, но к чему ему оно?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6017,
          arabicText: 'يَقُولُ يَٰلَيْتَنِى قَدَّمْتُ لِحَيَاتِى',
          transliteration: 'Йакулю йаляйтани каддамту лихаяти',
          russianText: 'Он скажет: «О, если бы я приготовил что-нибудь для своей жизни!»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6018,
          arabicText: 'فَيَوْمَئِذٍۢ لَّا يُعَذِّبُ عَذَابَهُۥٓ أَحَدٌۭ',
          transliteration: "Файаума'изил ля ю'аззибу 'азабаху ахад",
          russianText: 'В тот день никто не причинит таких мучений, как Он',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6019,
          arabicText: 'وَلَا يُوثِقُ وَثَاقَهُۥٓ أَحَدٌۭ',
          transliteration: 'Ва ля юсику васакаху ахад',
          russianText: 'и никто не наложит таких оков, как Он',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6020,
          arabicText: 'يَٰٓأَيَّتُهَا النَّفْسُ الْمُطْمَئِنَّةُ',
          transliteration: "Йа-айятухан-нафсуль-мутма'инна",
          russianText: 'О обретшая покой душа!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6021,
          arabicText: 'ارْجِعِىٓ إِلَىٰ رَبِّكِ رَاضِيَةًۭ مَّرْضِيَّةًۭ',
          transliteration: "Ирджи'и иля раббики радыятам мардыйя",
          russianText: 'Вернись к своему Господу удовлетворённой и снискавшей довольство!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6022,
          arabicText: 'فَادْخُلِى فِى عِبَٰدِى',
          transliteration: "Фадхули фи 'ибади",
          russianText: 'Войди в круг Моих рабов!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 6023,
          arabicText: 'وَادْخُلِى جَنَّتِى',
          transliteration: 'Вадхули джаннати',
          russianText: 'И войди в Мой Рай!',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какие народы приводятся в суре Аль-Фаджр как пример наказания?',
          answers: [
            'Адиты (народ Ирама), самудяне и Фараон',
            'Владельцы слона и курайшиты',
            'Владельцы рва и воинства',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что говорит человек, когда Господь одаряет его благами, а что — когда ограничивает удел?',
          answers: [
            '«Господь почтил меня» — и «Господь унизил меня»',
            '«Господь испытал меня» — и «Господь простил меня»',
            '«Я преуспел» — и «Я в убытке»',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'В чём сура упрекает людей?',
          answers: [
            'Не почитают сироту, не кормят бедняка и жадно любят богатство',
            'Клянутся ложными богами',
            'Забывают славить имя Господа',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «О обретшая ___ душа! Вернись к своему Господу»',
          answers: [
            'покой',
            'богатство',
            'сомнение',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем завершается сура Аль-Фаджр?',
          answers: [
            'Обращением к умиротворённой душе войти в Рай',
            'Клятвой предвечерним временем',
            'Повелением зарезать верблюдицу',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Валь-фаджр', answer: 'Клянусь зарёй'),
            LessonMatchPair(prompt: "Ирама затиль-'имад", answer: 'народом Ирама, обладавшим колоннами'),
            LessonMatchPair(prompt: "Йа-айятухан-нафсуль-мутма'инна", answer: 'О обретшая покой душа!'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5994,
          arabicText: 'وَالْفَجْرِ',
          transliteration: 'Валь-фаджр',
          russianText: 'Расскажи первый аят суры Аль-Фаджр.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_ghashiya_1',
      title: 'Аль-Гашия',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 33,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Гашия означает «Покрывающее» — одно из имён Дня воскресения. Мекканская сура рисует два исхода: поникшие, измученные лица в пылающем Огне и блаженные лица в возвышенном Саду, а затем призывает взглянуть на знамения творения.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5968,
          arabicText: 'هَلْ أَتَىٰكَ حَدِيثُ الْغَٰشِيَةِ',
          transliteration: 'Халь атака хадисуль-гашия',
          russianText: 'Дошёл ли до тебя рассказ о Покрывающем?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5969,
          arabicText: 'وُجُوهٌۭ يَوْمَئِذٍ خَٰشِعَةٌ',
          transliteration: "Вуджухуй йаума'изин хашиа",
          russianText: 'Одни лица в тот день будут поникшими',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5970,
          arabicText: 'عَامِلَةٌۭ نَّاصِبَةٌۭ',
          transliteration: "'Амилятун насыба",
          russianText: 'изнурёнными, утомлёнными',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5971,
          arabicText: 'تَصْلَىٰ نَارًا حَامِيَةًۭ',
          transliteration: 'Тасля наран хамия',
          russianText: 'Они будут гореть в пылающем Огне',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5972,
          arabicText: 'تُسْقَىٰ مِنْ عَيْنٍ ءَانِيَةٍۢ',
          transliteration: "Тускa мин 'айнин ания",
          russianText: 'и поить их будут из источника кипящего',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5973,
          arabicText: 'لَّيْسَ لَهُمْ طَعَامٌ إِلَّا مِن ضَرِيعٍۢ',
          transliteration: "Ляйса ляхум та'амун илля мин дари'",
          russianText: 'Не будет у них пищи, кроме ядовитых колючек',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5974,
          arabicText: 'لَّا يُسْمِنُ وَلَا يُغْنِى مِن جُوعٍۢ',
          transliteration: "Ля юсмину ва ля югни мин джу'",
          russianText: 'которые не насыщают и не утоляют голода',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5975,
          arabicText: 'وُجُوهٌۭ يَوْمَئِذٍۢ نَّاعِمَةٌۭ',
          transliteration: "Вуджухуй йаума'изин на'има",
          russianText: 'Другие лица в тот день будут блаженными',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5976,
          arabicText: 'لِّسَعْيِهَا رَاضِيَةٌۭ',
          transliteration: "Лиса'йиха радыя",
          russianText: 'Они будут довольны своими стараниями',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5977,
          arabicText: 'فِى جَنَّةٍ عَالِيَةٍۢ',
          transliteration: "Фи джаннатин 'алия",
          russianText: 'в Саду возвышенном',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5978,
          arabicText: 'لَّا تَسْمَعُ فِيهَا لَٰغِيَةًۭ',
          transliteration: "Ля тасма'у фиха лагия",
          russianText: 'где не услышат пустых речей',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5979,
          arabicText: 'فِيهَا عَيْنٌۭ جَارِيَةٌۭ',
          transliteration: "Фиха 'айнун джария",
          russianText: 'Там есть текущий источник',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5980,
          arabicText: 'فِيهَا سُرُرٌۭ مَّرْفُوعَةٌۭ',
          transliteration: 'Фиха сурурум марфуа',
          russianText: 'там воздвигнуты высокие ложа',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5981,
          arabicText: 'وَأَكْوَابٌۭ مَّوْضُوعَةٌۭ',
          transliteration: 'Ва аквабум маудуа',
          russianText: 'расставлены чаши',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5982,
          arabicText: 'وَنَمَارِقُ مَصْفُوفَةٌۭ',
          transliteration: 'Ва намарику масфуфа',
          russianText: 'разложены подушки',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5983,
          arabicText: 'وَزَرَابِىُّ مَبْثُوثَةٌ',
          transliteration: 'Ва зарабийю мабсуса',
          russianText: 'и разостланы ковры',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5984,
          arabicText: 'أَفَلَا يَنظُرُونَ إِلَى الْإِبِلِ كَيْفَ خُلِقَتْ',
          transliteration: 'Афаля янзуруна иляль-ибили кайфа хуликат',
          russianText: 'Неужели они не смотрят на верблюдов — как они сотворены',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5985,
          arabicText: 'وَإِلَى السَّمَآءِ كَيْفَ رُفِعَتْ',
          transliteration: "Ва иляс-самаи кайфа руфи'ат",
          russianText: 'и на небо — как оно возвышено',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5986,
          arabicText: 'وَإِلَى الْجِبَالِ كَيْفَ نُصِبَتْ',
          transliteration: 'Ва иляль-джибали кайфа нусыбат',
          russianText: 'и на горы — как они водружены',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5987,
          arabicText: 'وَإِلَى الْأَرْضِ كَيْفَ سُطِحَتْ',
          transliteration: 'Ва иляль-арды кайфа сутыхат',
          russianText: 'и на землю — как она распростёрта?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5988,
          arabicText: 'فَذَكِّرْ إِنَّمَآ أَنتَ مُذَكِّرٌۭ',
          transliteration: 'Фазаккир иннама анта музаккир',
          russianText: 'Наставляй же, ведь ты — наставник',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5989,
          arabicText: 'لَّسْتَ عَلَيْهِم بِمُصَيْطِرٍ',
          transliteration: "Ляста 'аляйхим бимусайтыр",
          russianText: 'и ты не властен принуждать их',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5990,
          arabicText: 'إِلَّا مَن تَوَلَّىٰ وَكَفَرَ',
          transliteration: 'Илля ман тавалля ва кафар',
          russianText: 'А тех, кто отвернётся и не уверует',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5991,
          arabicText: 'فَيُعَذِّبُهُ اللَّهُ الْعَذَابَ الْأَكْبَرَ',
          transliteration: "Файу'аззибухуллахуль-'азабаль-акбар",
          russianText: 'Аллах подвергнет величайшим мучениям',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5992,
          arabicText: 'إِنَّ إِلَيْنَآ إِيَابَهُمْ',
          transliteration: 'Инна иляйна ийабахум',
          russianText: 'Воистину, к Нам они вернутся',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5993,
          arabicText: 'ثُمَّ إِنَّ عَلَيْنَا حِسَابَهُم',
          transliteration: "Сумма инна 'аляйна хисабахум",
          russianText: 'и затем Нам предстоит их сосчитать',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О чём предупреждает начало суры Аль-Гашия?',
          answers: [
            'О Дне воскресения — Покрывающем (ошеломляющем)',
            'О предвечернем времени',
            'О ночном путнике',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем будут поить обитателей Огня, по суре?',
          answers: [
            'Из источника кипящего',
            'Из чистого мёда',
            'Из текущего родника Рая',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'На какие творения сура призывает взглянуть как на знамения?',
          answers: [
            'На верблюдов, небо, горы и землю',
            'На солнце, луну и звёзды',
            'На реки, моря и облака',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Наставляй же, ведь ты — ___»',
          answers: [
            'наставник',
            'владыка',
            'свидетель',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какие две группы лиц противопоставляет сура Аль-Гашия?',
          answers: [
            'Поникшие лица в Огне — и блаженные лица в возвышенном Саду',
            'Богатые торговцы — и бедняки',
            'Владельцы слона — и жители Мекки',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Халь атака хадисуль-гашия', answer: 'Дошёл ли до тебя рассказ о Покрывающем?'),
            LessonMatchPair(prompt: "Вуджухуй йаума'изин на'има", answer: 'Другие лица в тот день будут блаженными'),
            LessonMatchPair(prompt: 'Фазаккир иннама анта музаккир', answer: 'Наставляй же, ведь ты — наставник'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5968,
          arabicText: 'هَلْ أَتَىٰكَ حَدِيثُ الْغَٰشِيَةِ',
          transliteration: 'Халь атака хадисуль-гашия',
          russianText: 'Расскажи первый аят суры Аль-Гашия.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_tariq_1',
      title: 'Ат-Тарик',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 34,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Ат-Тарик означает «Ночной путник» — ярко сияющую звезду. Мекканская сура клянётся небом и звездой, напоминает, что над каждой душой есть хранитель, указывает на сотворение человека как довод воскрешения и утверждает, что Коран — различающее Слово, а не шутка.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5932,
          arabicText: 'وَالسَّمَآءِ وَالطَّارِقِ',
          transliteration: 'Вас-самаи ват-тарик',
          russianText: 'Клянусь небом и ночным путником',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5933,
          arabicText: 'وَمَآ أَدْرَىٰكَ مَا الطَّارِقُ',
          transliteration: 'Ва ма адрака мат-тарик',
          russianText: 'Откуда тебе знать, что такое ночной путник?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5934,
          arabicText: 'النَّجْمُ الثَّاقِبُ',
          transliteration: 'Ан-наджмус-сакиб',
          russianText: 'Это — пронизывающая мраком звезда',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5935,
          arabicText: 'إِن كُلُّ نَفْسٍۢ لَّمَّا عَلَيْهَا حَافِظٌۭ',
          transliteration: "Ин куллю нафсил ляммa 'аляйха хафиз",
          russianText: 'Нет души, при которой не было бы хранителя',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5936,
          arabicText: 'فَلْيَنظُرِ الْإِنسَٰنُ مِمَّ خُلِقَ',
          transliteration: 'Фальянзуриль-инсану мимма хулик',
          russianText: 'Пусть посмотрит человек, из чего он создан',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5937,
          arabicText: 'خُلِقَ مِن مَّآءٍۢ دَافِقٍۢ',
          transliteration: 'Хулика мим маин дафик',
          russianText: 'Он создан из изливающейся жидкости',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5938,
          arabicText: 'يَخْرُجُ مِنۢ بَيْنِ الصُّلْبِ وَالتَّرَآئِبِ',
          transliteration: 'Йахруджу мим байнис-сульби ват-тараиб',
          russianText: 'которая выходит между поясницей и грудными костями',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5939,
          arabicText: 'إِنَّهُۥ عَلَىٰ رَجْعِهِۦ لَقَادِرٌۭ',
          transliteration: "Иннаху 'аля радж'ихи лякадир",
          russianText: 'Воистину, Он способен вернуть его к жизни',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5940,
          arabicText: 'يَوْمَ تُبْلَى السَّرَآئِرُ',
          transliteration: 'Йаума тублас-сараир',
          russianText: 'В тот день, когда будут раскрыты тайны',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5941,
          arabicText: 'فَمَا لَهُۥ مِن قُوَّةٍۢ وَلَا نَاصِرٍۢ',
          transliteration: 'Фама ляху мин куввaтин ва ля насыр',
          russianText: 'не будет у него ни силы, ни помощника',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5942,
          arabicText: 'وَالسَّمَآءِ ذَاتِ الرَّجْعِ',
          transliteration: "Вас-самаи затир-радж'",
          russianText: 'Клянусь небом, возвращающим дождь',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5943,
          arabicText: 'وَالْأَرْضِ ذَاتِ الصَّدْعِ',
          transliteration: "Валь-арды затис-сад'",
          russianText: 'и землёй, раскалывающейся растениями',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5944,
          arabicText: 'إِنَّهُۥ لَقَوْلٌۭ فَصْلٌۭ',
          transliteration: 'Иннаху лякаулюн фасл',
          russianText: 'Воистину, это — Слово различающее',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5945,
          arabicText: 'وَمَا هُوَ بِالْهَزْلِ',
          transliteration: 'Ва ма хуа биль-хазл',
          russianText: 'а не шутка',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5946,
          arabicText: 'إِنَّهُمْ يَكِيدُونَ كَيْدًۭا',
          transliteration: 'Иннахум якидуна кайдa',
          russianText: 'Воистину, они замышляют козни',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5947,
          arabicText: 'وَأَكِيدُ كَيْدًۭا',
          transliteration: 'Ва акиду кайдa',
          russianText: 'и Я замышляю Свой план',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5948,
          arabicText: 'فَمَهِّلِ الْكَٰفِرِينَ أَمْهِلْهُمْ رُوَيْدًۢا',
          transliteration: 'Фамаххилиль-кафирина амхильхум рувайдa',
          russianText: 'Дай же неверующим отсрочку, повремени с ними немного',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем клянётся начало суры Ат-Тарик?',
          answers: [
            'Небом и ночным путником (звездой)',
            'Солнцем и его сиянием',
            'Зарёй и десятью ночами',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что сура говорит о каждой душе?',
          answers: [
            'При ней есть хранитель (ангел)',
            'Она будет жить вечно',
            'Она сотворена из глины',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'На что указывает сура, говоря «Пусть посмотрит человек, из чего он создан»?',
          answers: [
            'На то, что человек создан из изливающейся жидкости — и потому Аллах способен воскресить его',
            'На то, что человек создан из сгустка крови и станет прахом',
            'На то, что человек создан из огня',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Это — Слово ___, а не шутка»',
          answers: [
            'различающее',
            'забытое',
            'тайное',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем завершается сура Ат-Тарик?',
          answers: [
            'Повелением дать неверующим краткую отсрочку',
            'Обещанием Райских садов',
            'Клятвой чётом и нечётом',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Вас-самаи ват-тарик', answer: 'Клянусь небом и ночным путником'),
            LessonMatchPair(prompt: 'Ан-наджмус-сакиб', answer: 'Это — пронизывающая мраком звезда'),
            LessonMatchPair(prompt: 'Иннаху лякаулюн фасл', answer: 'Это — Слово различающее'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5932,
          arabicText: 'وَالسَّمَآءِ وَالطَّارِقِ',
          transliteration: 'Вас-самаи ват-тарик',
          russianText: 'Расскажи первый аят суры Ат-Тарик.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_buruj_1',
      title: 'Аль-Бурудж',
      subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 35,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Бурудж означает «Созвездия» (небесные башни). Мекканская сура клянётся небом со звёздами и рассказывает о «владельцах рва», сжигавших верующих за их веру, обещая мучителям Геенну, а уверовавшим — сады, и напоминает, что Коран хранится в Хранимой скрижали.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5910,
          arabicText: 'وَالسَّمَآءِ ذَاتِ الْبُرُوجِ',
          transliteration: 'Вас-самаи затиль-бурудж',
          russianText: 'Клянусь небом, обладателем созвездий',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5911,
          arabicText: 'وَالْيَوْمِ الْمَوْعُودِ',
          transliteration: "Валь-йаумиль-мау'уд",
          russianText: 'клянусь днём обещанным',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5912,
          arabicText: 'وَشَاهِدٍۢ وَمَشْهُودٍۢ',
          transliteration: 'Ва шахидин ва машхуд',
          russianText: 'клянусь свидетелем и засвидетельствованным',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5913,
          arabicText: 'قُتِلَ أَصْحَٰبُ الْأُخْدُودِ',
          transliteration: 'Кутиля асхабуль-ухдуд',
          russianText: 'Убиты будут владельцы рва',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5914,
          arabicText: 'النَّارِ ذَاتِ الْوَقُودِ',
          transliteration: 'Ан-нари затиль-вакуд',
          russianText: 'огня, обладающего растопкой',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5915,
          arabicText: 'إِذْ هُمْ عَلَيْهَا قُعُودٌۭ',
          transliteration: "Из хум 'аляйха ку'уд",
          russianText: 'когда они сидели у него',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5916,
          arabicText: 'وَهُمْ عَلَىٰ مَا يَفْعَلُونَ بِالْمُؤْمِنِينَ شُهُودٌۭ',
          transliteration: "Ва хум 'аля ма яф'алуна биль-му'минина шухуд",
          russianText: 'и сами свидетельствовали о том, что творили с верующими',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5917,
          arabicText: 'وَمَا نَقَمُوا۟ مِنْهُمْ إِلَّآ أَن يُؤْمِنُوا۟ بِاللَّهِ الْعَزِيزِ الْحَمِيدِ',
          transliteration: "Ва ма накаму минхум илля ай йу'мину биллахиль-'азизиль-хамид",
          russianText: 'Они мстили им только за то, что те уверовали в Аллаха, Могущественного, Достохвального',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5918,
          arabicText: 'الَّذِى لَهُۥ مُلْكُ السَّمَٰوَٰتِ وَالْأَرْضِ ۚ وَاللَّهُ عَلَىٰ كُلِّ شَىْءٍۢ شَهِيدٌ',
          transliteration: "Аллязи ляху мулькус-самавати валь-ард, валлаху 'аля кулли шайин шахид",
          russianText: 'Которому принадлежит власть над небесами и землёй. Аллах — Свидетель всякой вещи',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5919,
          arabicText: 'إِنَّ الَّذِينَ فَتَنُوا۟ الْمُؤْمِنِينَ وَالْمُؤْمِنَٰتِ ثُمَّ لَمْ يَتُوبُوا۟ فَلَهُمْ عَذَابُ جَهَنَّمَ وَلَهُمْ عَذَابُ الْحَرِيقِ',
          transliteration: "Инналлязина фатануль-му'минина валь-му'минати сумма лям ятубу фаляхум 'азабу джаханнама ва ляхум 'азабуль-харик",
          russianText: 'Тем, кто подвергал искушению верующих мужчин и женщин и не раскаялся, уготованы мучения в Геенне и мучения от обжигающего Огня',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5920,
          arabicText: 'إِنَّ الَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ الصَّٰلِحَٰتِ لَهُمْ جَنَّٰتٌۭ تَجْرِى مِن تَحْتِهَا الْأَنْهَٰرُ ۚ ذَٰلِكَ الْفَوْزُ الْكَبِيرُ',
          transliteration: "Инналлязина аману ва 'амилюс-салихати ляхум джаннатун таджри мин тахтихаль-анхар, залика ль-фаузуль-кабир",
          russianText: 'А тем, кто уверовал и творил добро, уготованы сады, где текут реки. Это — великое преуспеяние',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5921,
          arabicText: 'إِنَّ بَطْشَ رَبِّكَ لَشَدِيدٌ',
          transliteration: 'Инна батша раббика ляшадид',
          russianText: 'Воистину, Хватка твоего Господа сурова',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5922,
          arabicText: 'إِنَّهُۥ هُوَ يُبْدِئُ وَيُعِيدُ',
          transliteration: "Иннаху хуа юбди'у ва йу'ид",
          russianText: 'Воистину, Он начинает творение и повторяет его',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5923,
          arabicText: 'وَهُوَ الْغَفُورُ الْوَدُودُ',
          transliteration: 'Ва хуаль-гафуруль-вадуд',
          russianText: 'Он — Прощающий, Любящий',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5924,
          arabicText: 'ذُو الْعَرْشِ الْمَجِيدُ',
          transliteration: "Зуль-'аршиль-маджид",
          russianText: 'Владыка Трона, Славный',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5925,
          arabicText: 'فَعَّالٌۭ لِّمَا يُرِيدُ',
          transliteration: "Фа''алюл лима юрид",
          russianText: 'вершащий то, что пожелает',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5926,
          arabicText: 'هَلْ أَتَىٰكَ حَدِيثُ الْجُنُودِ',
          transliteration: 'Халь атака хадисуль-джунуд',
          russianText: 'Дошёл ли до тебя рассказ о воинствах',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5927,
          arabicText: 'فِرْعَوْنَ وَثَمُودَ',
          transliteration: "Фир'ауна ва самуд",
          russianText: 'о Фараоне и самудянах?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5928,
          arabicText: 'بَلِ الَّذِينَ كَفَرُوا۟ فِى تَكْذِيبٍۢ',
          transliteration: 'Балиль-лязина кафару фи такзиб',
          russianText: 'Но неверующие продолжают считать это ложью',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5929,
          arabicText: 'وَاللَّهُ مِن وَرَآئِهِم مُّحِيطٌۢ',
          transliteration: 'Валлаху мин вараихим мухит',
          russianText: 'Аллах же объемлет их со всех сторон',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5930,
          arabicText: 'بَلْ هُوَ قُرْءَانٌۭ مَّجِيدٌۭ',
          transliteration: "Баль хуа кур'анум маджид",
          russianText: 'Да, это — славный Коран',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5931,
          arabicText: 'فِى لَوْحٍۢ مَّحْفُوظٍۭ',
          transliteration: 'Фи ляухим махфуз',
          russianText: 'в Хранимой скрижали',
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем клянётся начало суры Аль-Бурудж?',
          answers: [
            'Небом, обладателем созвездий, и днём обещанным',
            'Солнцем и луной',
            'Смоковницей и оливой',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кто такие «владельцы рва», упомянутые в суре?',
          answers: [
            'Те, кто сжигал верующих в огне за их веру',
            'Владельцы стада верблюдов',
            'Войско, шедшее на Мекку со слоном',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'За что «владельцы рва» мстили верующим?',
          answers: [
            'Только за то, что те уверовали в Аллаха',
            'За неуплату дани',
            'За порчу их посевов',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Да, это — славный Коран, в Хранимой ___»',
          answers: [
            'скрижали',
            'пещере',
            'гавани',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какие два воздаяния противопоставляет сура Аль-Бурудж?',
          answers: [
            'Мучения Геенны для мучителей — и сады с реками для уверовавших',
            'Богатство для щедрых — и бедность для скупых',
            'Долгую жизнь — и раннюю смерть',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Вас-самаи затиль-бурудж', answer: 'Клянусь небом, обладателем созвездий'),
            LessonMatchPair(prompt: 'Кутиля асхабуль-ухдуд', answer: 'Убиты будут владельцы рва'),
            LessonMatchPair(prompt: 'Ва хуаль-гафуруль-вадуд', answer: 'Он — Прощающий, Любящий'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5910,
          arabicText: 'وَالسَّمَآءِ ذَاتِ الْبُرُوجِ',
          transliteration: 'Вас-самаи затиль-бурудж',
          russianText: 'Расскажи первый аят суры Аль-Бурудж.',
        ),
      ],
    ),
];
