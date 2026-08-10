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
    const Lesson(
      id: 'q_naba_1',
      title: 'Ан-Наба, часть 1',
      subtitle: 'Аяты 1–20 • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 36,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Ан-Наба означает «Весть». Мекканская сура открывает Джуз Амма вопросом: о чём спорят люди? О великой вести — воскрешении. Первая половина перечисляет знамения Аллаха в творении: земля-ложе, горы-колышки, сон-отдых, ночь-покрывало, семь твердынь, солнце-светильник, дождь и сады — и подводит к Дню различения.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5673,
          arabicText: 'عَمَّ يَتَسَآءَلُونَ',
          transliteration: 'Амма ятасаалюн',
          russianText: 'О чём они расспрашивают друг друга?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5674,
          arabicText: 'عَنِ النَّبَإِ الْعَظِيمِ',
          transliteration: "Анин-набаиль-'азым",
          russianText: 'О великой вести',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5675,
          arabicText: 'الَّذِى هُمْ فِيهِ مُخْتَلِفُونَ',
          transliteration: 'Аллязи хум фихи мухталифун',
          russianText: 'относительно которой они расходятся во мнениях',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5676,
          arabicText: 'كَلَّا سَيَعْلَمُونَ',
          transliteration: "Калля сая'лямун",
          russianText: 'Но нет, они узнают!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5677,
          arabicText: 'ثُمَّ كَلَّا سَيَعْلَمُونَ',
          transliteration: "Сумма калля сая'лямун",
          russianText: 'Ещё раз нет, они узнают!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5678,
          arabicText: 'أَلَمْ نَجْعَلِ الْأَرْضَ مِهَٰدًۭا',
          transliteration: "Алям надж'алиль-арда михада",
          russianText: 'Разве Мы не сделали землю ложем',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5679,
          arabicText: 'وَالْجِبَالَ أَوْتَادًۭا',
          transliteration: 'Валь-джибаля автада',
          russianText: 'а горы — колышками?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5680,
          arabicText: 'وَخَلَقْنَٰكُمْ أَزْوَٰجًۭا',
          transliteration: 'Ва халякнакум азваджа',
          russianText: 'Мы сотворили вас парами',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5681,
          arabicText: 'وَجَعَلْنَا نَوْمَكُمْ سُبَاتًۭا',
          transliteration: "Ва джа'альна наумакум субата",
          russianText: 'и сделали ваш сон отдыхом',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5682,
          arabicText: 'وَجَعَلْنَا الَّيْلَ لِبَاسًۭا',
          transliteration: "Ва джа'альналь-лейля либаса",
          russianText: 'и сделали ночь покрывалом',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5683,
          arabicText: 'وَجَعَلْنَا النَّهَارَ مَعَاشًۭا',
          transliteration: "Ва джа'альнан-нахара ма'аша",
          russianText: 'и сделали день временем для заработка',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5684,
          arabicText: 'وَبَنَيْنَا فَوْقَكُمْ سَبْعًۭا شِدَادًۭا',
          transliteration: "Ва банайна фаукакум саб'ан шидада",
          russianText: 'Мы воздвигли над вами семь твердынь',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5685,
          arabicText: 'وَجَعَلْنَا سِرَاجًۭا وَهَّاجًۭا',
          transliteration: "Ва джа'альна сираджан ваххаджа",
          russianText: 'и установили пылающий светильник',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5686,
          arabicText: 'وَأَنزَلْنَا مِنَ الْمُعْصِرَٰتِ مَآءًۭ ثَجَّاجًۭا',
          transliteration: "Ва анзальна миналь-му'сырати маан саджджаджа",
          russianText: 'Мы низвели из облаков обильно льющуюся воду',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5687,
          arabicText: 'لِّنُخْرِجَ بِهِۦ حَبًّۭا وَنَبَاتًۭا',
          transliteration: 'Линухриджа бихи хаббан ва набата',
          russianText: 'чтобы взрастить ею зёрна и растения',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5688,
          arabicText: 'وَجَنَّٰتٍ أَلْفَافًا',
          transliteration: 'Ва джаннатин альфафа',
          russianText: 'и густые сады',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5689,
          arabicText: 'إِنَّ يَوْمَ الْفَصْلِ كَانَ مِيقَٰتًۭا',
          transliteration: 'Инна яумаль-фасли кана микaта',
          russianText: 'Воистину, День различения наступит в назначенный срок',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5690,
          arabicText: 'يَوْمَ يُنفَخُ فِى الصُّورِ فَتَأْتُونَ أَفْوَاجًۭا',
          transliteration: "Яума юнфаху фис-сури фата'туна афваджа",
          russianText: 'В тот день затрубят в Рог, и вы придёте толпами',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5691,
          arabicText: 'وَفُتِحَتِ السَّمَآءُ فَكَانَتْ أَبْوَٰبًۭا',
          transliteration: 'Ва футихатис-самау факанат абваба',
          russianText: 'и небо раскроется и станет вратами',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5692,
          arabicText: 'وَسُيِّرَتِ الْجِبَالُ فَكَانَتْ سَرَابًا',
          transliteration: 'Ва суййиратиль-джибалю факанат сараба',
          russianText: 'и горы придут в движение и станут маревом',
        ),
        LessonStep(
          type: LessonStepType.listenChoice,
          quranGlobalAyahNumber: 5673,
          arabicText: 'عَمَّ يَتَسَآءَلُونَ',
          question: 'Прослушай аят и выбери его перевод',
          answers: [
            'О чём они расспрашивают друг друга?',
            'Клянусь небом и ночным путником',
            'Разве Мы не сделали землю ложем?',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.wordOrder,
          question: 'Собери шестой аят суры',
          russianText: 'Разве Мы не сделали землю ложем',
          orderTokens: [
            'أَلَمْ',
            'نَجْعَلِ',
            'الْأَرْضَ',
            'مِهَٰدًۭا',
          ],
          extraTokens: [
            'أَوْتَادًۭا',
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О какой «великой вести» спорят люди в начале суры Ан-Наба?',
          answers: [
            'О воскрешении и Дне суда',
            'О переселении в Медину',
            'О разделе военной добычи',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'С чем сура сравнивает горы?',
          answers: [
            'С колышками, удерживающими землю',
            'С вратами небес',
            'С пылающими светильниками',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Мы сделали ваш сон ___»',
          answers: [
            'отдыхом',
            'наказанием',
            'испытанием',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что названо в суре «пылающим светильником»?',
          answers: [
            'Солнце',
            'Луна',
            'Молния',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что происходит с горами в День различения по аяту 20?',
          answers: [
            'Они приходят в движение и становятся маревом',
            'Они превращаются в сады',
            'Они остаются неподвижными',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Амма ятасаалюн', answer: 'О чём они расспрашивают друг друга?'),
            LessonMatchPair(prompt: 'Валь-джибаля автада', answer: 'а горы — колышками?'),
            LessonMatchPair(prompt: 'Ва джаннатин альфафа', answer: 'и густые сады'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5673,
          arabicText: 'عَمَّ يَتَسَآءَلُونَ',
          transliteration: 'Амма ятасаалюн',
          russianText: 'Расскажи первый аят суры Ан-Наба.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_naba_2',
      title: 'Ан-Наба, часть 2',
      subtitle: 'Аяты 21–40 • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 37,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Вторая половина суры Ан-Наба показывает две дороги Дня различения: Геенна как засада для преступивших границы — и успех богобоязненных с садами, виноградниками и полными чашами, где не услышать ни пустословия, ни лжи. Завершается сура предостережением о близком наказании и словами неверующего: «Лучше бы мне быть прахом!»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5693,
          arabicText: 'إِنَّ جَهَنَّمَ كَانَتْ مِرْصَادًۭا',
          transliteration: 'Инна джаханнама канат мирсада',
          russianText: 'Воистину, Геенна стала местом засады',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5694,
          arabicText: 'لِّلطَّٰغِينَ مَـَٔابًۭا',
          transliteration: 'Лит-тагина маaба',
          russianText: 'пристанищем для преступивших границы',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5695,
          arabicText: 'لَّٰبِثِينَ فِيهَآ أَحْقَابًۭا',
          transliteration: 'Лябисина фиха ахкаба',
          russianText: 'Они пробудут там долгие века',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5696,
          arabicText: 'لَّا يَذُوقُونَ فِيهَا بَرْدًۭا وَلَا شَرَابًا',
          transliteration: 'Ля язукуна фиха бардан ва ля шараба',
          russianText: 'Они не вкусят там ни прохлады, ни питья',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5697,
          arabicText: 'إِلَّا حَمِيمًۭا وَغَسَّاقًۭا',
          transliteration: 'Илля хамиман ва гассака',
          russianText: 'кроме кипятка и гноя',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5698,
          arabicText: 'جَزَآءًۭ وِفَاقًا',
          transliteration: 'Джазаан вифака',
          russianText: 'Таково воздаяние по заслугам',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5699,
          arabicText: 'إِنَّهُمْ كَانُوا۟ لَا يَرْجُونَ حِسَابًۭا',
          transliteration: 'Иннахум кяню ля ярджуна хисаба',
          russianText: 'Воистину, они не ожидали расчёта',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5700,
          arabicText: 'وَكَذَّبُوا۟ بِـَٔايَٰتِنَا كِذَّابًۭا',
          transliteration: 'Ва каззабу би-аятина киззаба',
          russianText: 'и полностью отвергали Наши знамения',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5701,
          arabicText: 'وَكُلَّ شَىْءٍ أَحْصَيْنَٰهُ كِتَٰبًۭا',
          transliteration: 'Ва кулля шайин ахсайнаху китаба',
          russianText: 'Мы же всякую вещь подсчитали и записали',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5702,
          arabicText: 'فَذُوقُوا۟ فَلَن نَّزِيدَكُمْ إِلَّا عَذَابًا',
          transliteration: "Фазуку фалян назидакум илля 'азаба",
          russianText: 'Вкушайте же! Мы не прибавим вам ничего, кроме мучений',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5703,
          arabicText: 'إِنَّ لِلْمُتَّقِينَ مَفَازًا',
          transliteration: 'Инна лиль-муттакина мафаза',
          russianText: 'Воистину, богобоязненных ожидает успех',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5704,
          arabicText: 'حَدَآئِقَ وَأَعْنَٰبًۭا',
          transliteration: "Хадаика ва а'наба",
          russianText: 'сады и виноградники',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5705,
          arabicText: 'وَكَوَاعِبَ أَتْرَابًۭا',
          transliteration: "Ва кава'иба атраба",
          russianText: 'и сверстницы',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5706,
          arabicText: 'وَكَأْسًۭا دِهَاقًۭا',
          transliteration: "Ва ка'сан дихака",
          russianText: 'и полные чаши',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5707,
          arabicText: 'لَّا يَسْمَعُونَ فِيهَا لَغْوًۭا وَلَا كِذَّٰبًۭا',
          transliteration: "Ля ясма'уна фиха лягван ва ля киззаба",
          russianText: 'Они не услышат там ни пустословия, ни лжи',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5708,
          arabicText: 'جَزَآءًۭ مِّن رَّبِّكَ عَطَآءً حِسَابًۭا',
          transliteration: "Джазаан мир-раббика 'атаан хисаба",
          russianText: 'Это — воздаяние от твоего Господа, дар исчисленный',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5709,
          arabicText: 'رَّبِّ السَّمَٰوَٰتِ وَالْأَرْضِ وَمَا بَيْنَهُمَا الرَّحْمَٰنِ ۖ لَا يَمْلِكُونَ مِنْهُ خِطَابًۭا',
          transliteration: 'Раббис-самавати валь-арды ва ма байнахумар-Рахман, ля ямликуна минху хитаба',
          russianText: 'Господа небес и земли и того, что между ними, Милостивого, с Которым они не смеют заговорить',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5710,
          arabicText: 'يَوْمَ يَقُومُ الرُّوحُ وَالْمَلَٰٓئِكَةُ صَفًّۭا ۖ لَّا يَتَكَلَّمُونَ إِلَّا مَنْ أَذِنَ لَهُ الرَّحْمَٰنُ وَقَالَ صَوَابًۭا',
          transliteration: 'Яума якумур-руху валь-маляикату саффа, ля ятакаллямуна илля ман азина ляхур-Рахману ва каля саваба',
          russianText: 'В тот день Дух и ангелы станут рядами. Не заговорит никто, кроме тех, кому позволит Милостивый, и скажет он правду',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5711,
          arabicText: 'ذَٰلِكَ الْيَوْمُ الْحَقُّ ۖ فَمَن شَآءَ اتَّخَذَ إِلَىٰ رَبِّهِۦ مَـَٔابًا',
          transliteration: 'Заликаль-яумуль-хакк, фаман шаа-ттахаза иля раббихи маaба',
          russianText: 'Это — Истинный день. Кто хочет, тот найдёт путь к своему Господу',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5712,
          arabicText: 'إِنَّآ أَنذَرْنَٰكُمْ عَذَابًۭا قَرِيبًۭا يَوْمَ يَنظُرُ الْمَرْءُ مَا قَدَّمَتْ يَدَاهُ وَيَقُولُ الْكَافِرُ يَٰلَيْتَنِى كُنتُ تُرَٰبًۢا',
          transliteration: "Инна анзарнакум 'азабан кариба, яума янзуруль-мар'у ма каддамат ядах, ва якулюль-кафиру я лейтани кунту тураба",
          russianText: 'Мы предостерегли вас от близких мучений. В тот день человек увидит, что уготовили его руки, а неверующий скажет: «Лучше бы мне быть прахом!»',
        ),
        LessonStep(
          type: LessonStepType.listenChoice,
          quranGlobalAyahNumber: 5703,
          arabicText: 'إِنَّ لِلْمُتَّقِينَ مَفَازًا',
          question: 'Прослушай аят и выбери его перевод',
          answers: [
            'Воистину, богобоязненных ожидает успех',
            'Воистину, Геенна стала местом засады',
            'Таково воздаяние по заслугам',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.wordOrder,
          question: 'Собери аят 24 суры Ан-Наба',
          russianText: 'Они не вкусят там ни прохлады, ни питья',
          orderTokens: [
            'لَّا',
            'يَذُوقُونَ',
            'فِيهَا',
            'بَرْدًۭا',
            'وَلَا',
            'شَرَابًا',
          ],
          extraTokens: [
            'حَمِيمًۭا',
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кому Геенна станет пристанищем по аятам 21–22?',
          answers: [
            'Преступившим границы дозволенного',
            'Всем без исключения',
            'Только тем, кто не совершал хадж',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Почему сура называет наказание «воздаянием по заслугам»?',
          answers: [
            'Они не ожидали расчёта и отвергали знамения',
            'Они были бедны',
            'Они жили в Мекке',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Мы всякую вещь подсчитали и ___»',
          answers: [
            'записали',
            'простили',
            'скрыли',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чего не услышат обитатели садов?',
          answers: [
            'Ни пустословия, ни лжи',
            'Ни пения птиц',
            'Ни шума воды',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какими словами заканчивается сура Ан-Наба?',
          answers: [
            'Словами неверующего: «Лучше бы мне быть прахом!»',
            'Клятвой зарёй и десятью ночами',
            'Повелением совершать намаз',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Инна джаханнама канат мирсада', answer: 'Воистину, Геенна стала местом засады'),
            LessonMatchPair(prompt: 'Инна лиль-муттакина мафаза', answer: 'Воистину, богобоязненных ожидает успех'),
            LessonMatchPair(prompt: 'Джазаан вифака', answer: 'Таково воздаяние по заслугам'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5703,
          arabicText: 'إِنَّ لِلْمُتَّقِينَ مَفَازًا',
          transliteration: 'Инна лиль-муттакина мафаза',
          russianText: 'Расскажи аят 31 суры Ан-Наба.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_naziat_1',
      title: 'Ан-Назиат, часть 1',
      subtitle: 'Аяты 1–26 • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 38,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Ан-Назиат означает «Исторгающие» — так названы ангелы, забирающие души. Мекканская сура начинается пятью клятвами, описывает ужас воскрешения и приводит в пример историю Мусы и Фараона: Фараон сказал «Я — ваш всевышний господь», и Аллах покарал его в обоих мирах. В этом — назидание для богобоязненных.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5713,
          arabicText: 'وَالنَّٰزِعَٰتِ غَرْقًۭا',
          transliteration: "Ван-нази'ати гарка",
          russianText: 'Клянусь исторгающими души жёстко',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5714,
          arabicText: 'وَالنَّٰشِطَٰتِ نَشْطًۭا',
          transliteration: 'Ван-нашитати нашта',
          russianText: 'извлекающими души легко',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5715,
          arabicText: 'وَالسَّٰبِحَٰتِ سَبْحًۭا',
          transliteration: 'Вас-сабихати сабха',
          russianText: 'плывущими стремительно',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5716,
          arabicText: 'فَالسَّٰبِقَٰتِ سَبْقًۭا',
          transliteration: 'Фас-сабикати сабка',
          russianText: 'опережающими стремительно',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5717,
          arabicText: 'فَالْمُدَبِّرَٰتِ أَمْرًۭا',
          transliteration: 'Фаль-мудаббирати амра',
          russianText: 'и исполняющими повеления',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5718,
          arabicText: 'يَوْمَ تَرْجُفُ الرَّاجِفَةُ',
          transliteration: 'Яума тарджуфур-раджифа',
          russianText: 'В тот день сотрясётся сотрясающаяся',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5719,
          arabicText: 'تَتْبَعُهَا الرَّادِفَةُ',
          transliteration: "Татба'ухар-радифа",
          russianText: 'а за ней последует следующая',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5720,
          arabicText: 'قُلُوبٌۭ يَوْمَئِذٍۢ وَاجِفَةٌ',
          transliteration: 'Кулюбун яумаизин ваджифа',
          russianText: 'Сердца в тот день будут трепетать',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5721,
          arabicText: 'أَبْصَٰرُهَا خَٰشِعَةٌۭ',
          transliteration: "Абсаруха хаши'а",
          russianText: 'а взоры их будут смиренны',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5722,
          arabicText: 'يَقُولُونَ أَءِنَّا لَمَرْدُودُونَ فِى الْحَافِرَةِ',
          transliteration: 'Якулюна аинна лямардудуна филь-хафира',
          russianText: 'Они говорят: «Неужели мы вернёмся в прежнее состояние',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5723,
          arabicText: 'أَءِذَا كُنَّا عِظَٰمًۭا نَّخِرَةًۭ',
          transliteration: "Аиза кунна 'изаман нахира",
          russianText: 'после того как станем истлевшими костями?»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5724,
          arabicText: 'قَالُوا۟ تِلْكَ إِذًۭا كَرَّةٌ خَاسِرَةٌۭ',
          transliteration: 'Калю тилька изан карратун хасира',
          russianText: 'Они говорят: «Тогда это будет возвращением с убытком!»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5725,
          arabicText: 'فَإِنَّمَا هِىَ زَجْرَةٌۭ وَٰحِدَةٌۭ',
          transliteration: 'Фаиннама хия заджратун вахида',
          russianText: 'Но это будет лишь один окрик',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5726,
          arabicText: 'فَإِذَا هُم بِالسَّاهِرَةِ',
          transliteration: 'Фаиза хум бис-сахира',
          russianText: 'и вот они окажутся на поверхности земли',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5727,
          arabicText: 'هَلْ أَتَىٰكَ حَدِيثُ مُوسَىٰٓ',
          transliteration: 'Халь атака хадису Муса',
          russianText: 'Дошёл ли до тебя рассказ о Мусе?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5728,
          arabicText: 'إِذْ نَادَىٰهُ رَبُّهُۥ بِالْوَادِ الْمُقَدَّسِ طُوًى',
          transliteration: 'Из надаху раббуху биль-вадиль-мукаддаси Тува',
          russianText: 'Вот Господь его воззвал к нему в священной долине Тува',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5729,
          arabicText: 'اذْهَبْ إِلَىٰ فِرْعَوْنَ إِنَّهُۥ طَغَىٰ',
          transliteration: "Изхаб иля Фир'ауна иннаху тага",
          russianText: '«Ступай к Фараону, ибо он преступил границы дозволенного»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5730,
          arabicText: 'فَقُلْ هَل لَّكَ إِلَىٰٓ أَن تَزَكَّىٰ',
          transliteration: 'Факуль халь ляка иля ан тазакка',
          russianText: 'и скажи: «Не желаешь ли очиститься',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5731,
          arabicText: 'وَأَهْدِيَكَ إِلَىٰ رَبِّكَ فَتَخْشَىٰ',
          transliteration: 'Ва ахдияка иля раббика фатахша',
          russianText: 'чтобы я указал тебе путь к твоему Господу и ты стал богобоязненным?»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5732,
          arabicText: 'فَأَرَىٰهُ الْـَٔايَةَ الْكُبْرَىٰ',
          transliteration: 'Фаараху аятал-кубра',
          russianText: 'Он показал ему величайшее знамение',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5733,
          arabicText: 'فَكَذَّبَ وَعَصَىٰ',
          transliteration: "Факаззаба ва 'аса",
          russianText: 'но тот счёл его ложью и ослушался',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5734,
          arabicText: 'ثُمَّ أَدْبَرَ يَسْعَىٰ',
          transliteration: "Сумма адбара яс'а",
          russianText: 'а потом отвернулся и принялся усердствовать',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5735,
          arabicText: 'فَحَشَرَ فَنَادَىٰ',
          transliteration: 'Фахашара фанада',
          russianText: 'Он собрал народ и воззвал',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5736,
          arabicText: 'فَقَالَ أَنَا۠ رَبُّكُمُ الْأَعْلَىٰ',
          transliteration: "Факаля ана раббукумуль-а'ля",
          russianText: 'и сказал: «Я — ваш всевышний господь!»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5737,
          arabicText: 'فَأَخَذَهُ اللَّهُ نَكَالَ الْـَٔاخِرَةِ وَالْأُولَىٰٓ',
          transliteration: 'Фаахазахуллаху накаляль-ахирати валь-уля',
          russianText: 'Тогда Аллах покарал его наказанием в Последней жизни и в первой',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5738,
          arabicText: 'إِنَّ فِى ذَٰلِكَ لَعِبْرَةًۭ لِّمَن يَخْشَىٰٓ',
          transliteration: "Инна фи залика ля'ибратал лиман яхша",
          russianText: 'Воистину, в этом — назидание для того, кто богобоязнен',
        ),
        LessonStep(
          type: LessonStepType.listenChoice,
          quranGlobalAyahNumber: 5727,
          arabicText: 'هَلْ أَتَىٰكَ حَدِيثُ مُوسَىٰٓ',
          question: 'Прослушай аят и выбери его перевод',
          answers: [
            'Дошёл ли до тебя рассказ о Мусе?',
            'Дошёл ли до тебя рассказ о Покрывающем?',
            'Клянусь небом и ночным путником',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.wordOrder,
          question: 'Собери аят 15 суры Ан-Назиат',
          russianText: 'Дошёл ли до тебя рассказ о Мусе?',
          orderTokens: [
            'هَلْ',
            'أَتَىٰكَ',
            'حَدِيثُ',
            'مُوسَىٰٓ',
          ],
          extraTokens: [
            'إِلَىٰ',
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кто такие «исторгающие», давшие имя суре?',
          answers: [
            'Ангелы, забирающие души',
            'Ветры пустыни',
            'Волны моря',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что отвечали отрицающие воскрешение на весть о возвращении к жизни?',
          answers: [
            '«Неужели мы вернёмся, став истлевшими костями?»',
            '«Мы уверовали сразу»',
            '«Мы попросим отсрочку»',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Сколько окриков понадобится для воскрешения по аяту 13?',
          answers: [
            'Один',
            'Три',
            'Семь',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'В какой долине Аллах воззвал к Мусе?',
          answers: [
            'В священной долине Тува',
            'В долине Мина',
            'В долине Бакка',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем закончилась дерзость Фараона, сказавшего «Я — ваш всевышний господь»?',
          answers: [
            'Аллах покарал его в Последней жизни и в первой',
            'Он раскаялся и уверовал',
            'Он покинул Египет',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: "Ван-нази'ати гарка", answer: 'Клянусь исторгающими души жёстко'),
            LessonMatchPair(prompt: 'Халь атака хадису Муса', answer: 'Дошёл ли до тебя рассказ о Мусе?'),
            LessonMatchPair(prompt: "Изхаб иля Фир'ауна иннаху тага", answer: 'Ступай к Фараону, ибо он преступил границы'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5727,
          arabicText: 'هَلْ أَتَىٰكَ حَدِيثُ مُوسَىٰٓ',
          transliteration: 'Халь атака хадису Муса',
          russianText: 'Расскажи аят 15 суры Ан-Назиат.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_naziat_2',
      title: 'Ан-Назиат, часть 2',
      subtitle: 'Аяты 27–46 • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 39,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Вторая половина суры отвечает отрицающим воскрешение: сотворить небо, распростереть землю, вывести воду и пастбища — труднее, чем вернуть человека к жизни. Дальше сура делит людей надвое: преступивший границы и полюбивший мирское получит Ад, а боявшийся Господа и удержавший душу от страстей — Рай. О времени Часа знает только Аллах.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5739,
          arabicText: 'ءَأَنتُمْ أَشَدُّ خَلْقًا أَمِ السَّمَآءُ ۚ بَنَىٰهَا',
          transliteration: 'Аантум ашадду халькан амис-самау банаха',
          russianText: 'Вас ли труднее сотворить или небо? Он воздвиг его',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5740,
          arabicText: 'رَفَعَ سَمْكَهَا فَسَوَّىٰهَا',
          transliteration: 'Рафа’а самкаха фасавваха',
          russianText: 'поднял его свод и сделал его совершенным',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5741,
          arabicText: 'وَأَغْطَشَ لَيْلَهَا وَأَخْرَجَ ضُحَىٰهَا',
          transliteration: 'Ва агташа лейляха ва ахраджа духаха',
          russianText: 'Он сделал ночь его тёмной и вывел его утреннюю зарю',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5742,
          arabicText: 'وَالْأَرْضَ بَعْدَ ذَٰلِكَ دَحَىٰهَآ',
          transliteration: "Валь-арда ба'да залика дахаха",
          russianText: 'После этого Он распростёр землю',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5743,
          arabicText: 'أَخْرَجَ مِنْهَا مَآءَهَا وَمَرْعَىٰهَا',
          transliteration: "Ахраджа минха мааха ва мар'аха",
          russianText: 'вывел из неё воду и пастбища',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5744,
          arabicText: 'وَالْجِبَالَ أَرْسَىٰهَا',
          transliteration: 'Валь-джибаля арсаха',
          russianText: 'и утвердил горы',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5745,
          arabicText: 'مَتَٰعًۭا لَّكُمْ وَلِأَنْعَٰمِكُمْ',
          transliteration: "Мата'ал лякум ва ли ан'амикум",
          russianText: 'на пользу вам и вашему скоту',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5746,
          arabicText: 'فَإِذَا جَآءَتِ الطَّآمَّةُ الْكُبْرَىٰ',
          transliteration: 'Фаиза джаатит-таммату-ль-кубра',
          russianText: 'Когда же наступит Величайшее бедствие',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5747,
          arabicText: 'يَوْمَ يَتَذَكَّرُ الْإِنسَٰنُ مَا سَعَىٰ',
          transliteration: "Яума ятазаккаруль-инсану ма са'а",
          russianText: 'в тот день человек вспомнит о том, к чему стремился',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5748,
          arabicText: 'وَبُرِّزَتِ الْجَحِيمُ لِمَن يَرَىٰ',
          transliteration: 'Ва бурризатиль-джахиму лиман яра',
          russianText: 'и Ад будет показан тем, кто увидит',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5749,
          arabicText: 'فَأَمَّا مَن طَغَىٰ',
          transliteration: 'Фаамма ман тага',
          russianText: 'Тому, кто преступил границы дозволенного',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5750,
          arabicText: 'وَءَاثَرَ الْحَيَوٰةَ الدُّنْيَا',
          transliteration: 'Ва асараль-хаятад-дунья',
          russianText: 'и отдал предпочтение мирской жизни',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5751,
          arabicText: 'فَإِنَّ الْجَحِيمَ هِىَ الْمَأْوَىٰ',
          transliteration: "Фаиннал-джахима хияль-ма'ва",
          russianText: 'пристанищем будет Ад',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5752,
          arabicText: 'وَأَمَّا مَنْ خَافَ مَقَامَ رَبِّهِۦ وَنَهَى النَّفْسَ عَنِ الْهَوَىٰ',
          transliteration: "Ва амма ман хафа макама раббихи ва нахан-нафса 'аниль-хава",
          russianText: 'Тому же, кто боялся предстать перед своим Господом и удерживал душу от страстей',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5753,
          arabicText: 'فَإِنَّ الْجَنَّةَ هِىَ الْمَأْوَىٰ',
          transliteration: "Фаиннал-джанната хияль-ма'ва",
          russianText: 'пристанищем будет Рай',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5754,
          arabicText: 'يَسْـَٔلُونَكَ عَنِ السَّاعَةِ أَيَّانَ مُرْسَىٰهَا',
          transliteration: "Яс'алюнака 'анис-са'ати айяна мурсаха",
          russianText: 'Тебя спрашивают о Часе: «Когда он наступит?»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5755,
          arabicText: 'فِيمَ أَنتَ مِن ذِكْرَىٰهَآ',
          transliteration: 'Фима анта мин зикраха',
          russianText: 'Тебе ли знать об этом?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5756,
          arabicText: 'إِلَىٰ رَبِّكَ مُنتَهَىٰهَآ',
          transliteration: 'Иля раббика мунтахаха',
          russianText: 'Только твой Господь знает его предел',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5757,
          arabicText: 'إِنَّمَآ أَنتَ مُنذِرُ مَن يَخْشَىٰهَا',
          transliteration: 'Иннама анта мунзиру ман яхшаха',
          russianText: 'Ты — всего лишь предостерегающий для тех, кто страшится его',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5758,
          arabicText: 'كَأَنَّهُمْ يَوْمَ يَرَوْنَهَا لَمْ يَلْبَثُوٓا۟ إِلَّا عَشِيَّةً أَوْ ضُحَىٰهَا',
          transliteration: "Кааннахум яума яраунаха лям ялбасу илля 'ашийятан ав духаха",
          russianText: 'В тот день, когда они увидят его, им покажется, что они пробыли на земле лишь вечер или утро',
        ),
        LessonStep(
          type: LessonStepType.listenChoice,
          quranGlobalAyahNumber: 5753,
          arabicText: 'فَإِنَّ الْجَنَّةَ هِىَ الْمَأْوَىٰ',
          question: 'Прослушай аят и выбери его перевод',
          answers: [
            'пристанищем будет Рай',
            'пристанищем будет Ад',
            'и утвердил горы',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.wordOrder,
          question: 'Собери аят 41 суры Ан-Назиат',
          russianText: 'пристанищем будет Рай',
          orderTokens: [
            'فَإِنَّ',
            'الْجَنَّةَ',
            'هِىَ',
            'الْمَأْوَىٰ',
          ],
          extraTokens: [
            'الْجَحِيمَ',
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какой довод в пользу воскрешения приводят аяты 27–33?',
          answers: [
            'Сотворение неба и земли труднее, чем воскрешение человека',
            'Долгая жизнь пророков',
            'Смена времён года',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что вспомнит человек в день Величайшего бедствия?',
          answers: [
            'То, к чему он стремился при жизни',
            'Имена своих предков',
            'Дорогу домой',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кому сура обещает Ад?',
          answers: [
            'Преступившему границы и предпочётшему мирскую жизнь',
            'Тому, кто был беден',
            'Тому, кто много спрашивал',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Тому, кто боялся предстать перед Господом и удерживал душу от страстей, пристанищем будет ___»',
          answers: [
            'Рай',
            'Ад',
            'пустыня',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что сура отвечает на вопрос «Когда наступит Час?»',
          answers: [
            'Знание о нём — только у Господа',
            'Он наступит через тысячу лет',
            'Он уже наступил',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Валь-джибаля арсаха', answer: 'и утвердил горы'),
            LessonMatchPair(prompt: "Фаиннал-джахима хияль-ма'ва", answer: 'пристанищем будет Ад'),
            LessonMatchPair(prompt: "Фаиннал-джанната хияль-ма'ва", answer: 'пристанищем будет Рай'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5753,
          arabicText: 'فَإِنَّ الْجَنَّةَ هِىَ الْمَأْوَىٰ',
          transliteration: "Фаиннал-джанната хияль-ма'ва",
          russianText: 'Расскажи аят 41 суры Ан-Назиат.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_abasa_1',
      title: 'Абаса, часть 1',
      subtitle: 'Аяты 1–23 • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 40,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Абаса означает «Нахмурился». Сура ниспослана о случае, когда во время разговора со знатью Мекки к Пророку ﷺ подошёл слепой сподвижник Абдуллах ибн Умм Мактум, ищущий знания, и остался без внимания. Аллах учит: искренне ищущий истину дороже равнодушного богача. Дальше сура напоминает человеку, из чего он создан.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5759,
          arabicText: 'عَبَسَ وَتَوَلَّىٰٓ',
          transliteration: "'Абаса ва тавалля",
          russianText: 'Он нахмурился и отвернулся',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5760,
          arabicText: 'أَن جَآءَهُ الْأَعْمَىٰ',
          transliteration: "ан джаахуль-а'ма",
          russianText: 'оттого, что к нему подошёл слепой',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5761,
          arabicText: 'وَمَا يُدْرِيكَ لَعَلَّهُۥ يَزَّكَّىٰٓ',
          transliteration: "Ва ма юдрика ля'алляху язакка",
          russianText: 'Откуда тебе знать? Возможно, он бы очистился',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5762,
          arabicText: 'أَوْ يَذَّكَّرُ فَتَنفَعَهُ الذِّكْرَىٰٓ',
          transliteration: "ав язаккару фатанфа'ахуз-зикра",
          russianText: 'или помянул бы назидание, и оно принесло бы ему пользу',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5763,
          arabicText: 'أَمَّا مَنِ اسْتَغْنَىٰ',
          transliteration: 'Амма манистагна',
          russianText: 'Тому, кто счёл себя богатым',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5764,
          arabicText: 'فَأَنتَ لَهُۥ تَصَدَّىٰ',
          transliteration: 'фаанта ляху тасадда',
          russianText: 'ты оказываешь внимание',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5765,
          arabicText: 'وَمَا عَلَيْكَ أَلَّا يَزَّكَّىٰ',
          transliteration: "Ва ма 'алейка алля язакка",
          russianText: 'Что же с тебя, если он не очистится?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5766,
          arabicText: 'وَأَمَّا مَن جَآءَكَ يَسْعَىٰ',
          transliteration: "Ва амма ман джаака яс'а",
          russianText: 'А того, кто пришёл к тебе со рвением',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5767,
          arabicText: 'وَهُوَ يَخْشَىٰ',
          transliteration: 'ва хува яхша',
          russianText: 'и страшится Аллаха',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5768,
          arabicText: 'فَأَنتَ عَنْهُ تَلَهَّىٰ',
          transliteration: "фаанта 'анху талахха",
          russianText: 'ты оставляешь без внимания',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5769,
          arabicText: 'كَلَّآ إِنَّهَا تَذْكِرَةٌۭ',
          transliteration: 'Калля иннаха тазкира',
          russianText: 'Но нет! Это — Назидание',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5770,
          arabicText: 'فَمَن شَآءَ ذَكَرَهُۥ',
          transliteration: 'фаман шаа закараху',
          russianText: 'и пусть помянет его всякий желающий',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5771,
          arabicText: 'فِى صُحُفٍۢ مُّكَرَّمَةٍۢ',
          transliteration: 'Фи сухуфим мукаррама',
          russianText: 'Оно записано в почитаемых свитках',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5772,
          arabicText: 'مَّرْفُوعَةٍۢ مُّطَهَّرَةٍۭ',
          transliteration: "Марфу'атим мутаххара",
          russianText: 'вознесённых и очищенных',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5773,
          arabicText: 'بِأَيْدِى سَفَرَةٍۢ',
          transliteration: 'Биайди сафара',
          russianText: 'в руках посланцев',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5774,
          arabicText: 'كِرَامٍۭ بَرَرَةٍۢ',
          transliteration: 'Кирамим барара',
          russianText: 'благородных и покорных',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5775,
          arabicText: 'قُتِلَ الْإِنسَٰنُ مَآ أَكْفَرَهُۥ',
          transliteration: 'Кутиляль-инсану ма акфараху',
          russianText: 'Да сгинет человек! Как же он неблагодарен!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5776,
          arabicText: 'مِنْ أَىِّ شَىْءٍ خَلَقَهُۥ',
          transliteration: 'Мин аййи шайин халякаху',
          russianText: 'Из чего Он сотворил его?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5777,
          arabicText: 'مِن نُّطْفَةٍ خَلَقَهُۥ فَقَدَّرَهُۥ',
          transliteration: 'Мин нутфатин халякаху факаддараху',
          russianText: 'Он сотворил его из капли и соразмерил',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5778,
          arabicText: 'ثُمَّ السَّبِيلَ يَسَّرَهُۥ',
          transliteration: 'Суммас-сабиля яссараху',
          russianText: 'потом облегчил ему путь',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5779,
          arabicText: 'ثُمَّ أَمَاتَهُۥ فَأَقْبَرَهُۥ',
          transliteration: 'Сумма аматаху фаакбараху',
          russianText: 'потом умертвил его и поместил в могилу',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5780,
          arabicText: 'ثُمَّ إِذَا شَآءَ أَنشَرَهُۥ',
          transliteration: 'Сумма иза шаа аншараху',
          russianText: 'а потом воскресит его, когда пожелает',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5781,
          arabicText: 'كَلَّا لَمَّا يَقْضِ مَآ أَمَرَهُۥ',
          transliteration: 'Калля лямма якди ма амараху',
          russianText: 'Но нет! Он не выполнил того, что Он повелел ему',
        ),
        LessonStep(
          type: LessonStepType.listenChoice,
          quranGlobalAyahNumber: 5759,
          arabicText: 'عَبَسَ وَتَوَلَّىٰٓ',
          question: 'Прослушай аят и выбери его перевод',
          answers: [
            'Он нахмурился и отвернулся',
            'Да сгинет человек! Как же он неблагодарен!',
            'Но нет! Это — Назидание',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.wordOrder,
          question: 'Собери аят 18 суры Абаса',
          russianText: 'Из чего Он сотворил его?',
          orderTokens: [
            'مِنْ',
            'أَىِّ',
            'شَىْءٍ',
            'خَلَقَهُۥ',
          ],
          extraTokens: [
            'السَّبِيلَ',
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О чём напоминает начало суры Абаса?',
          answers: [
            'Искренне ищущий знание дороже равнодушного богача',
            'Богатым нужно уделять больше внимания',
            'Слепым нельзя учиться',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как сура называет Коран в аяте 11?',
          answers: [
            'Назиданием',
            'Наказанием',
            'Загадкой',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Где, по суре, записано это Назидание?',
          answers: [
            'В почитаемых, вознесённых и очищенных свитках',
            'На камнях Каабы',
            'В памяти арабских поэтов',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Он сотворил его из ___ и соразмерил»',
          answers: [
            'капли',
            'глины',
            'огня',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какой порядок жизни человека описывают аяты 19–22?',
          answers: [
            'Сотворение, облегчение пути, смерть и могила, затем воскрешение',
            'Рождение, богатство, слава',
            'Сон, бодрствование, работа',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: "'Абаса ва тавалля", answer: 'Он нахмурился и отвернулся'),
            LessonMatchPair(prompt: 'Калля иннаха тазкира', answer: 'Но нет! Это — Назидание'),
            LessonMatchPair(prompt: 'Кутиляль-инсану ма акфараху', answer: 'Да сгинет человек! Как же он неблагодарен!'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5759,
          arabicText: 'عَبَسَ وَتَوَلَّىٰٓ',
          transliteration: "'Абаса ва тавалля",
          russianText: 'Расскажи первый аят суры Абаса.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_abasa_2',
      title: 'Абаса, часть 2',
      subtitle: 'Аяты 24–42 • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 41,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Вторая половина суры зовёт человека посмотреть на собственную еду: дождь, рассечённая земля, зёрна, виноград, маслины, пальмы, сады и пастбища — всё это дар Аллаха. А затем — Оглушительный глас, в день которого человек убежит от брата, матери, отца, жены и детей: у каждого будет своя забота. Одни лица засияют, другие покроются пылью.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5782,
          arabicText: 'فَلْيَنظُرِ الْإِنسَٰنُ إِلَىٰ طَعَامِهِۦٓ',
          transliteration: "Фальянзуриль-инсану иля та'амихи",
          russianText: 'Пусть посмотрит человек на своё пропитание',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5783,
          arabicText: 'أَنَّا صَبَبْنَا الْمَآءَ صَبًّۭا',
          transliteration: 'Анна сабабналь-маа сабба',
          russianText: 'Мы проливаем воду обильно',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5784,
          arabicText: 'ثُمَّ شَقَقْنَا الْأَرْضَ شَقًّۭا',
          transliteration: 'Сумма шакакналь-арда шакка',
          russianText: 'потом рассекаем землю трещинами',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5785,
          arabicText: 'فَأَنۢبَتْنَا فِيهَا حَبًّۭا',
          transliteration: 'Фаамбатна фиха хабба',
          russianText: 'и взращиваем на ней зёрна',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5786,
          arabicText: 'وَعِنَبًۭا وَقَضْبًۭا',
          transliteration: "Ва 'инабан ва кадба",
          russianText: 'виноград и травы',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5787,
          arabicText: 'وَزَيْتُونًۭا وَنَخْلًۭا',
          transliteration: 'Ва зайтунан ва нахля',
          russianText: 'маслины и пальмы',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5788,
          arabicText: 'وَحَدَآئِقَ غُلْبًۭا',
          transliteration: 'Ва хадаика гульба',
          russianText: 'густые сады',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5789,
          arabicText: 'وَفَٰكِهَةًۭ وَأَبًّۭا',
          transliteration: 'Ва факихатан ва абба',
          russianText: 'фрукты и пастбища',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5790,
          arabicText: 'مَّتَٰعًۭا لَّكُمْ وَلِأَنْعَٰمِكُمْ',
          transliteration: "Мата'ал лякум ва ли ан'амикум",
          russianText: 'на пользу вам и вашему скоту',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5791,
          arabicText: 'فَإِذَا جَآءَتِ الصَّآخَّةُ',
          transliteration: 'Фаиза джаатис-саххa',
          russianText: 'Когда же раздастся Оглушительный глас',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5792,
          arabicText: 'يَوْمَ يَفِرُّ الْمَرْءُ مِنْ أَخِيهِ',
          transliteration: "Яума яфирруль-мар'у мин ахих",
          russianText: 'в тот день человек убежит от своего брата',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5793,
          arabicText: 'وَأُمِّهِۦ وَأَبِيهِ',
          transliteration: 'Ва уммихи ва абих',
          russianText: 'от матери и отца',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5794,
          arabicText: 'وَصَٰحِبَتِهِۦ وَبَنِيهِ',
          transliteration: 'Ва сахибатихи ва баних',
          russianText: 'от жены и детей',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5795,
          arabicText: 'لِكُلِّ امْرِئٍۢ مِّنْهُمْ يَوْمَئِذٍۢ شَأْنٌۭ يُغْنِيهِ',
          transliteration: "Ликуллим-риим минхум яумаизин ша'нуй югних",
          russianText: 'У каждого человека в тот день будет забота, которой ему хватит сполна',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5796,
          arabicText: 'وُجُوهٌۭ يَوْمَئِذٍۢ مُّسْفِرَةٌۭ',
          transliteration: 'Вуджухуй яумаизим мусфира',
          russianText: 'Одни лица в тот день будут сиять',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5797,
          arabicText: 'ضَاحِكَةٌۭ مُّسْتَبْشِرَةٌۭ',
          transliteration: 'Дахикатум мустабшира',
          russianText: 'смеяться и ликовать',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5798,
          arabicText: 'وَوُجُوهٌۭ يَوْمَئِذٍ عَلَيْهَا غَبَرَةٌۭ',
          transliteration: "Ва вуджухуй яумаизин 'алейха габара",
          russianText: 'На других лицах в тот день будет пыль',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5799,
          arabicText: 'تَرْهَقُهَا قَتَرَةٌ',
          transliteration: 'Тархакуха катара',
          russianText: 'покрывающая их мраком',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5800,
          arabicText: 'أُو۟لَٰٓئِكَ هُمُ الْكَفَرَةُ الْفَجَرَةُ',
          transliteration: 'Уляика хумуль-кафаратуль-фаджара',
          russianText: 'Это — неверующие грешники',
        ),
        LessonStep(
          type: LessonStepType.listenChoice,
          quranGlobalAyahNumber: 5782,
          arabicText: 'فَلْيَنظُرِ الْإِنسَٰنُ إِلَىٰ طَعَامِهِۦٓ',
          question: 'Прослушай аят и выбери его перевод',
          answers: [
            'Пусть посмотрит человек на своё пропитание',
            'Пусть посмотрит человек, из чего он создан',
            'Мы проливаем воду обильно',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.wordOrder,
          question: 'Собери аят 34 суры Абаса',
          russianText: 'в тот день человек убежит от своего брата',
          orderTokens: [
            'يَوْمَ',
            'يَفِرُّ',
            'الْمَرْءُ',
            'مِنْ',
            'أَخِيهِ',
          ],
          extraTokens: [
            'وَأَبِيهِ',
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'К чему призывает аят «Пусть посмотрит человек на своё пропитание»?',
          answers: [
            'Увидеть в обычной еде знамение и дар Аллаха',
            'Есть только растительную пищу',
            'Считать калории',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что происходит по порядку в аятах 25–26?',
          answers: [
            'Проливается вода, затем рассекается земля',
            'Сначала растут деревья, потом идёт дождь',
            'Земля высыхает и трескается от жары',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'От кого человек убежит в день Оглушительного гласа?',
          answers: [
            'От брата, матери, отца, жены и детей',
            'Только от врагов',
            'От правителей',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Почему в тот день каждому будет не до других?',
          answers: [
            'У каждого будет своя забота, которой хватит сполна',
            'Все будут спать',
            'Никто не будет узнавать друг друга по именам',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем сура противопоставляет две группы лиц в конце?',
          answers: [
            'Сияющие и смеющиеся — против покрытых пылью и мраком',
            'Молодые — против старых',
            'Богатые — против бедных',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: "Фальянзуриль-инсану иля та'амихи", answer: 'Пусть посмотрит человек на своё пропитание'),
            LessonMatchPair(prompt: 'Вуджухуй яумаизим мусфира', answer: 'Одни лица в тот день будут сиять'),
            LessonMatchPair(prompt: 'Уляика хумуль-кафаратуль-фаджара', answer: 'Это — неверующие грешники'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5782,
          arabicText: 'فَلْيَنظُرِ الْإِنسَٰنُ إِلَىٰ طَعَامِهِۦٓ',
          transliteration: "Фальянзуриль-инсану иля та'амихи",
          russianText: 'Расскажи аят 24 суры Абаса.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_takwir_1',
      title: 'Ат-Таквир',
      subtitle: 'Аяты 1–29 • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 42,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Ат-Таквир означает «Свёртывание». Первая половина суры двенадцатью «когда» рисует картину конца света: свёрнутое солнце, осыпавшиеся звёзды, сдвинутые горы, запылавшие моря — и вопрос к убитой живьём девочке, за какой грех её убили. Вторая половина клянётся звёздами, ночью и зарёй, защищая Пророка ﷺ: Коран — слово благородного посланца, а не речи дьявола.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5801,
          arabicText: 'إِذَا الشَّمْسُ كُوِّرَتْ',
          transliteration: 'Изаш-шамсу куввират',
          russianText: 'Когда солнце будет свёрнуто',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5802,
          arabicText: 'وَإِذَا النُّجُومُ انكَدَرَتْ',
          transliteration: 'ва изан-нуджумун-кадарат',
          russianText: 'когда звёзды осыплются',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5803,
          arabicText: 'وَإِذَا الْجِبَالُ سُيِّرَتْ',
          transliteration: 'ва изаль-джибалю суййират',
          russianText: 'когда горы сдвинутся с мест',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5804,
          arabicText: 'وَإِذَا الْعِشَارُ عُطِّلَتْ',
          transliteration: "ва изаль-'ишару 'уттылят",
          russianText: 'когда верблюдицы на сносях останутся без присмотра',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5805,
          arabicText: 'وَإِذَا الْوُحُوشُ حُشِرَتْ',
          transliteration: 'ва изаль-вухушу хушират',
          russianText: 'когда дикие звери будут собраны',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5806,
          arabicText: 'وَإِذَا الْبِحَارُ سُجِّرَتْ',
          transliteration: 'ва изаль-бихару суджджират',
          russianText: 'когда моря запылают',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5807,
          arabicText: 'وَإِذَا النُّفُوسُ زُوِّجَتْ',
          transliteration: 'ва изан-нуфусу зуввиджат',
          russianText: 'когда души будут распределены по парам',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5808,
          arabicText: 'وَإِذَا الْمَوْءُۥدَةُ سُئِلَتْ',
          transliteration: "ва изаль-мау'удату суилят",
          russianText: 'когда зарытую живьём девочку спросят',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5809,
          arabicText: 'بِأَىِّ ذَنۢبٍۢ قُتِلَتْ',
          transliteration: 'биаййи занбин кутилят',
          russianText: 'за какой грех она была убита',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5810,
          arabicText: 'وَإِذَا الصُّحُفُ نُشِرَتْ',
          transliteration: 'ва изас-сухуфу нушират',
          russianText: 'когда свитки дел будут развёрнуты',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5811,
          arabicText: 'وَإِذَا السَّمَآءُ كُشِطَتْ',
          transliteration: 'ва изас-самау кушитат',
          russianText: 'когда небо будет сдёрнуто',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5812,
          arabicText: 'وَإِذَا الْجَحِيمُ سُعِّرَتْ',
          transliteration: "ва изаль-джахиму су'ират",
          russianText: 'когда Ад будет разожжён',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5813,
          arabicText: 'وَإِذَا الْجَنَّةُ أُزْلِفَتْ',
          transliteration: 'ва изаль-джаннату узлифат',
          russianText: 'когда Рай будет приближен',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5814,
          arabicText: 'عَلِمَتْ نَفْسٌۭ مَّآ أَحْضَرَتْ',
          transliteration: "'алимат нафсум ма ахдарат",
          russianText: 'тогда познает душа, что она принесла с собой',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5815,
          arabicText: 'فَلَآ أُقْسِمُ بِالْخُنَّسِ',
          transliteration: 'Фаля уксиму биль-хуннас',
          russianText: 'Клянусь отступающими планетами',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5816,
          arabicText: 'الْجَوَارِ الْكُنَّسِ',
          transliteration: 'аль-джавариль-куннас',
          russianText: 'движущимися и исчезающими',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5817,
          arabicText: 'وَالَّيْلِ إِذَا عَسْعَسَ',
          transliteration: "валь-лейли иза 'ас'ас",
          russianText: 'Клянусь ночью, когда она отступает',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5818,
          arabicText: 'وَالصُّبْحِ إِذَا تَنَفَّسَ',
          transliteration: 'вас-субхи иза танаффас',
          russianText: 'и зарёй, когда она забрезжит',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5819,
          arabicText: 'إِنَّهُۥ لَقَوْلُ رَسُولٍۢ كَرِيمٍۢ',
          transliteration: 'Иннаху лякаулю расулин карим',
          russianText: 'Воистину, это — слово благородного посланца',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5820,
          arabicText: 'ذِى قُوَّةٍ عِندَ ذِى الْعَرْشِ مَكِينٍۢ',
          transliteration: "зи куввaтин 'инда зиль-'арши макин",
          russianText: 'обладателя силы при Владыке Трона, могущественного',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5821,
          arabicText: 'مُّطَاعٍۢ ثَمَّ أَمِينٍۢ',
          transliteration: "мута'ин самма амин",
          russianText: 'которому там повинуются, доверенного',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5822,
          arabicText: 'وَمَا صَاحِبُكُم بِمَجْنُونٍۢ',
          transliteration: 'Ва ма сахибукум бимаджнун',
          russianText: 'Ваш товарищ не является одержимым',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5823,
          arabicText: 'وَلَقَدْ رَءَاهُ بِالْأُفُقِ الْمُبِينِ',
          transliteration: 'Ва лякад рааху биль-уфукиль-мубин',
          russianText: 'Он видел его на ясном горизонте',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5824,
          arabicText: 'وَمَا هُوَ عَلَى الْغَيْبِ بِضَنِينٍۢ',
          transliteration: "Ва ма хува 'аляль-гайби бидaнин",
          russianText: 'Он не скупится передавать сокровенное',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5825,
          arabicText: 'وَمَا هُوَ بِقَوْلِ شَيْطَٰنٍۢ رَّجِيمٍۢ',
          transliteration: 'Ва ма хува бикаули шайтанир-раджим',
          russianText: 'Это не речи побиваемого дьявола',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5826,
          arabicText: 'فَأَيْنَ تَذْهَبُونَ',
          transliteration: 'Фаайна тазхабун',
          russianText: 'Куда же вы идёте?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5827,
          arabicText: 'إِنْ هُوَ إِلَّا ذِكْرٌۭ لِّلْعَٰلَمِينَ',
          transliteration: "Ин хува илля зикрул лиль-'алямин",
          russianText: 'Это — лишь Напоминание мирам',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5828,
          arabicText: 'لِمَن شَآءَ مِنكُمْ أَن يَسْتَقِيمَ',
          transliteration: 'лиман шаа минкум ай ястаким',
          russianText: 'тем из вас, кто желает следовать прямым путём',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5829,
          arabicText: 'وَمَا تَشَآءُونَ إِلَّآ أَن يَشَآءَ اللَّهُ رَبُّ الْعَٰلَمِينَ',
          transliteration: "Ва ма ташаууна илля ай яшааллаху раббуль-'алямин",
          russianText: 'Но вы не пожелаете этого, если не пожелает Аллах, Господь миров',
        ),
        LessonStep(
          type: LessonStepType.listenChoice,
          quranGlobalAyahNumber: 5801,
          arabicText: 'إِذَا الشَّمْسُ كُوِّرَتْ',
          question: 'Прослушай аят и выбери его перевод',
          answers: [
            'Когда солнце будет свёрнуто',
            'Когда небо расколется',
            'Когда земля содрогнётся от сотрясения',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.wordOrder,
          question: 'Собери аят 19 суры Ат-Таквир',
          russianText: 'Воистину, это — слово благородного посланца',
          orderTokens: [
            'إِنَّهُۥ',
            'لَقَوْلُ',
            'رَسُولٍۢ',
            'كَرِيمٍۢ',
          ],
          extraTokens: [
            'رَّجِيمٍۢ',
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что означает название суры Ат-Таквир?',
          answers: [
            'Свёртывание — солнце будет свёрнуто',
            'Раскалывание неба',
            'Ночной путник',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О чём спросят зарытую живьём девочку в аятах 8–9?',
          answers: [
            'За какой грех она была убита',
            'Кто её родители',
            'Где она жила',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Заполни пропуск: «Тогда познает душа, что она ___»',
          answers: [
            'принесла с собой',
            'забыла дома',
            'услышала от людей',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как сура отвечает на обвинения в адрес Пророка ﷺ?',
          answers: [
            'Ваш товарищ не одержимый, а Коран — не речи дьявола',
            'Пророк не обязан отвечать',
            'Обвинителям обещана награда',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем завершается сура Ат-Таквир?',
          answers: [
            'Напоминанием, что желание человека следует воле Господа миров',
            'Клятвой смоковницей и оливой',
            'Повелением сражаться',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Изаш-шамсу куввират', answer: 'Когда солнце будет свёрнуто'),
            LessonMatchPair(prompt: 'Фаайна тазхабун', answer: 'Куда же вы идёте?'),
            LessonMatchPair(prompt: 'Ва ма сахибукум бимаджнун', answer: 'Ваш товарищ не является одержимым'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5801,
          arabicText: 'إِذَا الشَّمْسُ كُوِّرَتْ',
          transliteration: 'Изаш-шамсу куввират',
          russianText: 'Расскажи первый аят суры Ат-Таквир.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_infitar_1',
      title: 'Аль-Инфитар',
      subtitle: 'Аяты 1–19 • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 43,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Инфитар означает «Раскалывание». Сура описывает день, когда небо расколется, звёзды осыплются, моря сольются, а могилы перевернутся — и душа узнает всё, что совершила. Затем следует прямой вопрос человеку: что обмануло тебя относительно твоего Щедрого Господа? Над каждым есть благородные ангелы-писцы, и в День воздаяния власть будет принадлежать только Аллаху.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5830,
          arabicText: 'إِذَا السَّمَآءُ انفَطَرَتْ',
          transliteration: 'Изас-самау-нфатарат',
          russianText: 'Когда небо расколется',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5831,
          arabicText: 'وَإِذَا الْكَوَاكِبُ انتَثَرَتْ',
          transliteration: 'ва изаль-кавакибу-нтасарат',
          russianText: 'когда звёзды осыплются',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5832,
          arabicText: 'وَإِذَا الْبِحَارُ فُجِّرَتْ',
          transliteration: 'ва изаль-бихару фуджджират',
          russianText: 'когда моря сольются',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5833,
          arabicText: 'وَإِذَا الْقُبُورُ بُعْثِرَتْ',
          transliteration: "ва изаль-кубуру бу'сырат",
          russianText: 'когда могилы перевернутся',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5834,
          arabicText: 'عَلِمَتْ نَفْسٌۭ مَّا قَدَّمَتْ وَأَخَّرَتْ',
          transliteration: "'алимат нафсум ма каддамат ва аххарат",
          russianText: 'тогда познает душа, что она совершила и что оставила после себя',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5835,
          arabicText: 'يَٰٓأَيُّهَا الْإِنسَٰنُ مَا غَرَّكَ بِرَبِّكَ الْكَرِيمِ',
          transliteration: 'Я аййухаль-инсану ма гаррака бираббикаль-карим',
          russianText: 'О человек! Что ввело тебя в заблуждение относительно твоего Щедрого Господа',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5836,
          arabicText: 'الَّذِى خَلَقَكَ فَسَوَّىٰكَ فَعَدَلَكَ',
          transliteration: "аллязи халякака фасаввака фа'адаляк",
          russianText: 'Который сотворил тебя, придал тебе облик и сделал тебя соразмерным?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5837,
          arabicText: 'فِىٓ أَىِّ صُورَةٍۢ مَّا شَآءَ رَكَّبَكَ',
          transliteration: 'фи аййи суратим ма шаа раккабак',
          russianText: 'Он придал тебе тот облик, какой пожелал',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5838,
          arabicText: 'كَلَّا بَلْ تُكَذِّبُونَ بِالدِّينِ',
          transliteration: 'Калля баль туказзибуна бид-дин',
          russianText: 'Но нет! Вы считаете ложью воздаяние',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5839,
          arabicText: 'وَإِنَّ عَلَيْكُمْ لَحَٰفِظِينَ',
          transliteration: "Ва инна 'алейкум ляхафизын",
          russianText: 'Воистину, над вами есть хранители',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5840,
          arabicText: 'كِرَامًۭا كَٰتِبِينَ',
          transliteration: 'кираман катибин',
          russianText: 'благородные писцы',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5841,
          arabicText: 'يَعْلَمُونَ مَا تَفْعَلُونَ',
          transliteration: "я'лямуна ма таф'алюн",
          russianText: 'которые знают обо всём, что вы совершаете',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5842,
          arabicText: 'إِنَّ الْأَبْرَارَ لَفِى نَعِيمٍۢ',
          transliteration: "Иннал-абрара ляфи на'им",
          russianText: 'Воистину, благочестивые окажутся в блаженстве',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5843,
          arabicText: 'وَإِنَّ الْفُجَّارَ لَفِى جَحِيمٍۢ',
          transliteration: 'ва иннал-фуджджара ляфи джахим',
          russianText: 'Воистину, грешники окажутся в Аду',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5844,
          arabicText: 'يَصْلَوْنَهَا يَوْمَ الدِّينِ',
          transliteration: 'ясляунаха яумад-дин',
          russianText: 'куда они войдут в День воздаяния',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5845,
          arabicText: 'وَمَا هُمْ عَنْهَا بِغَآئِبِينَ',
          transliteration: "ва ма хум 'анха бигаибин",
          russianText: 'и откуда им не уклониться',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5846,
          arabicText: 'وَمَآ أَدْرَىٰكَ مَا يَوْمُ الدِّينِ',
          transliteration: 'Ва ма адрака ма яумуд-дин',
          russianText: 'Откуда тебе знать, что такое День воздаяния?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5847,
          arabicText: 'ثُمَّ مَآ أَدْرَىٰكَ مَا يَوْمُ الدِّينِ',
          transliteration: 'Сумма ма адрака ма яумуд-дин',
          russianText: 'Ещё раз: откуда тебе знать, что такое День воздаяния?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5848,
          arabicText: 'يَوْمَ لَا تَمْلِكُ نَفْسٌۭ لِّنَفْسٍۢ شَيْـًۭٔا ۖ وَالْأَمْرُ يَوْمَئِذٍۢ لِّلَّهِ',
          transliteration: 'Яума ля тамлику нафсул линафсин шайа, валь-амру яумаизил лиллях',
          russianText: 'В тот день ни одна душа не сможет ничем помочь другой, и власть в тот день будет принадлежать Аллаху',
        ),
        LessonStep(
          type: LessonStepType.listenChoice,
          quranGlobalAyahNumber: 5830,
          arabicText: 'إِذَا السَّمَآءُ انفَطَرَتْ',
          question: 'Прослушай аят и выбери его перевод',
          answers: [
            'Когда небо расколется',
            'Когда солнце будет свёрнуто',
            'Когда небо разверзнется',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.wordOrder,
          question: 'Собери аят 13 суры Аль-Инфитар',
          russianText: 'Воистину, благочестивые окажутся в блаженстве',
          orderTokens: [
            'إِنَّ',
            'الْأَبْرَارَ',
            'لَفِى',
            'نَعِيمٍۢ',
          ],
          extraTokens: [
            'جَحِيمٍۢ',
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Какой вопрос сура задаёт человеку в аяте 6?',
          answers: [
            'Что ввело тебя в заблуждение относительно твоего Щедрого Господа?',
            'Сколько у тебя имущества?',
            'Кто твои предки?',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кто такие «благородные писцы» в аятах 10–12?',
          answers: [
            'Ангелы-хранители, записывающие дела человека',
            'Переписчики Корана',
            'Учёные-богословы',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как сура противопоставляет две группы людей?',
          answers: [
            'Благочестивые — в блаженстве, грешники — в Аду',
            'Богатые — в блаженстве, бедные — в Аду',
            'Мужчины — в блаженстве, женщины — в Аду',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Зачем вопрос «Что такое День воздаяния?» повторяется дважды?',
          answers: [
            'Чтобы усилить и подчеркнуть величие этого дня',
            'Это ошибка переписчика',
            'Речь о двух разных днях',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кому будет принадлежать власть в День воздаяния?',
          answers: [
            'Только Аллаху',
            'Ангелам',
            'Праведным правителям',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Изас-самау-нфатарат', answer: 'Когда небо расколется'),
            LessonMatchPair(prompt: 'кираман катибин', answer: 'благородные писцы'),
            LessonMatchPair(prompt: "Иннал-абрара ляфи на'им", answer: 'Воистину, благочестивые окажутся в блаженстве'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5830,
          arabicText: 'إِذَا السَّمَآءُ انفَطَرَتْ',
          transliteration: 'Изас-самау-нфатарат',
          russianText: 'Расскажи первый аят суры Аль-Инфитар.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_mutaffifin_1',
      title: 'Аль-Мутаффифин, часть 1',
      subtitle: 'Аяты 1–20 • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 44,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Мутаффифин означает «Обвешивающие». Сура начинается с грозного «Горе!» тем, кто требует полной меры себе, но недодаёт другим — обман в мелочах назван прямой дорогой к отрицанию Дня суда. Дальше сура противопоставляет две книги дел: Сиджжин для грешников и Иллиййун для благочестивых, и объясняет, что сердца отрицающих покрылись ржавчиной от их же дел.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5849,
          arabicText: 'وَيْلٌۭ لِّلْمُطَفِّفِينَ',
          transliteration: 'Вайлюл лиль-мутаффифин',
          russianText: 'Горе обвешивающим',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5850,
          arabicText: 'الَّذِينَ إِذَا اكْتَالُوا۟ عَلَى النَّاسِ يَسْتَوْفُونَ',
          transliteration: "аллязина иза-ктаалю 'алян-наси ястауфун",
          russianText: 'которые требуют полной меры, когда люди отмеривают им',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5851,
          arabicText: 'وَإِذَا كَالُوهُمْ أَو وَّزَنُوهُمْ يُخْسِرُونَ',
          transliteration: 'ва иза калюхум ав вазанухум юхсирун',
          russianText: 'а когда сами отмеривают или взвешивают другим, наносят им урон',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5852,
          arabicText: 'أَلَا يَظُنُّ أُو۟لَٰٓئِكَ أَنَّهُم مَّبْعُوثُونَ',
          transliteration: "Аля язунну уляика аннахум маб'усун",
          russianText: 'Разве не думают они, что будут воскрешены',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5853,
          arabicText: 'لِيَوْمٍ عَظِيمٍۢ',
          transliteration: "лияумин 'азым",
          russianText: 'в Великий день',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5854,
          arabicText: 'يَوْمَ يَقُومُ النَّاسُ لِرَبِّ الْعَٰلَمِينَ',
          transliteration: "яума якумун-насу лираббиль-'алямин",
          russianText: 'в тот день, когда люди предстанут перед Господом миров?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5855,
          arabicText: 'كَلَّآ إِنَّ كِتَٰبَ الْفُجَّارِ لَفِى سِجِّينٍۢ',
          transliteration: 'Калля инна китабаль-фуджджари ляфи сиджджин',
          russianText: 'Но нет! Книга грешников — в Сиджжине',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5856,
          arabicText: 'وَمَآ أَدْرَىٰكَ مَا سِجِّينٌۭ',
          transliteration: 'Ва ма адрака ма сиджджин',
          russianText: 'Откуда тебе знать, что такое Сиджжин?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5857,
          arabicText: 'كِتَٰبٌۭ مَّرْقُومٌۭ',
          transliteration: 'Китабум маркум',
          russianText: 'Это — исписанная книга',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5858,
          arabicText: 'وَيْلٌۭ يَوْمَئِذٍۢ لِّلْمُكَذِّبِينَ',
          transliteration: 'Вайлюй яумаизил лиль-муказзибин',
          russianText: 'Горе в тот день обвиняющим во лжи',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5859,
          arabicText: 'الَّذِينَ يُكَذِّبُونَ بِيَوْمِ الدِّينِ',
          transliteration: 'аллязина юказзибуна бияумид-дин',
          russianText: 'которые считают ложью День воздаяния!',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5860,
          arabicText: 'وَمَا يُكَذِّبُ بِهِۦٓ إِلَّا كُلُّ مُعْتَدٍ أَثِيمٍ',
          transliteration: "Ва ма юказзибу бихи илля куллю му'тадин асим",
          russianText: 'Его считает ложью только преступник и грешник',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5861,
          arabicText: 'إِذَا تُتْلَىٰ عَلَيْهِ ءَايَٰتُنَا قَالَ أَسَٰطِيرُ الْأَوَّلِينَ',
          transliteration: "Иза тутля 'алейхи аятуна каля асатируль-аввалин",
          russianText: 'Когда ему читают Наши аяты, он говорит: «Сказки древних народов!»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5862,
          arabicText: 'كَلَّا ۖ بَلْ ۜ رَانَ عَلَىٰ قُلُوبِهِم مَّا كَانُوا۟ يَكْسِبُونَ',
          transliteration: "Калля, баль рана 'аля кулюбихим ма кяню яксибун",
          russianText: 'Но нет! Их сердца покрылись ржавчиной из-за того, что они приобретали',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5863,
          arabicText: 'كَلَّآ إِنَّهُمْ عَن رَّبِّهِمْ يَوْمَئِذٍۢ لَّمَحْجُوبُونَ',
          transliteration: "Калля иннахум 'ар-раббихим яумаизил лямахджубун",
          russianText: 'В тот день они будут отделены от своего Господа завесой',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5864,
          arabicText: 'ثُمَّ إِنَّهُمْ لَصَالُوا۟ الْجَحِيمِ',
          transliteration: 'Сумма иннахум лясалюль-джахим',
          russianText: 'а потом они войдут в Ад',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5865,
          arabicText: 'ثُمَّ يُقَالُ هَٰذَا الَّذِى كُنتُم بِهِۦ تُكَذِّبُونَ',
          transliteration: 'Сумма юкалю хазаллязи кунтум бихи туказзибун',
          russianText: 'и будет сказано: «Вот то, что вы считали ложью»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5866,
          arabicText: 'كَلَّآ إِنَّ كِتَٰبَ الْأَبْرَارِ لَفِى عِلِّيِّينَ',
          transliteration: "Калля инна китабаль-абрари ляфи 'иллиййин",
          russianText: 'Но нет! Книга благочестивых — в Иллиййуне',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5867,
          arabicText: 'وَمَآ أَدْرَىٰكَ مَا عِلِّيُّونَ',
          transliteration: "Ва ма адрака ма 'иллиййун",
          russianText: 'Откуда тебе знать, что такое Иллиййун?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5868,
          arabicText: 'كِتَٰبٌۭ مَّرْقُومٌۭ',
          transliteration: 'Китабум маркум',
          russianText: 'Это — исписанная книга',
        ),
        LessonStep(
          type: LessonStepType.listenChoice,
          quranGlobalAyahNumber: 5849,
          arabicText: 'وَيْلٌۭ لِّلْمُطَفِّفِينَ',
          question: 'Прослушай аят и выбери его перевод',
          answers: [
            'Горе обвешивающим',
            'Горе всякому хулителю и обидчику',
            'Горе в тот день обвиняющим во лжи',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.wordOrder,
          question: 'Собери аят 11 суры Аль-Мутаффифин',
          russianText: 'которые считают ложью День воздаяния',
          orderTokens: [
            'الَّذِينَ',
            'يُكَذِّبُونَ',
            'بِيَوْمِ',
            'الدِّينِ',
          ],
          extraTokens: [
            'الْفُجَّارِ',
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кого сура называет «обвешивающими»?',
          answers: [
            'Тех, кто требует полной меры себе, но недодаёт другим',
            'Тех, кто торгует на рынке',
            'Тех, кто не платит закят',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Почему обман в мере — это не мелочь?',
          answers: [
            'За ним стоит забвение о воскрешении и Дне суда',
            'Он портит весы',
            'Он запрещён только в Мекке',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что такое Сиджжин по аятам 7–9?',
          answers: [
            'Запись дел грешников — исписанная книга',
            'Название горы',
            'Имя ангела',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем сура объясняет отрицание аятов Корана?',
          answers: [
            'Сердца покрылись ржавчиной из-за совершённых дел',
            'Отсутствием образования',
            'Слишком сложным языком',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Где находится книга благочестивых?',
          answers: [
            'В Иллиййуне',
            'В Сиджжине',
            'В Таснимe',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Вайлюл лиль-мутаффифин', answer: 'Горе обвешивающим'),
            LessonMatchPair(prompt: 'Калля инна китабаль-фуджджари ляфи сиджджин', answer: 'Книга грешников — в Сиджжине'),
            LessonMatchPair(prompt: "Калля инна китабаль-абрари ляфи 'иллиййин", answer: 'Книга благочестивых — в Иллиййуне'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5849,
          arabicText: 'وَيْلٌۭ لِّلْمُطَفِّفِينَ',
          transliteration: 'Вайлюл лиль-мутаффифин',
          russianText: 'Расскажи первый аят суры Аль-Мутаффифин.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_mutaffifin_2',
      title: 'Аль-Мутаффифин, часть 2',
      subtitle: 'Аяты 21–36 • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 45,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Вторая половина суры описывает награду благочестивых: блаженство, ложа, сияние на лицах, запечатанный напиток с печатью из мускуса — «пусть ради этого состязаются состязающиеся». А в конце сура возвращает картину назад: в мирской жизни грешники смеялись над верующими и подмигивали друг другу, а в Последней жизни всё перевернётся.',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5869,
          arabicText: 'يَشْهَدُهُ الْمُقَرَّبُونَ',
          transliteration: 'Яшхадухуль-мукаррабун',
          russianText: 'которую видят приближённые',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5870,
          arabicText: 'إِنَّ الْأَبْرَارَ لَفِى نَعِيمٍ',
          transliteration: "Иннал-абрара ляфи на'им",
          russianText: 'Воистину, благочестивые будут в блаженстве',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5871,
          arabicText: 'عَلَى الْأَرَآئِكِ يَنظُرُونَ',
          transliteration: "'аляль-араики янзурун",
          russianText: 'и будут созерцать, возлежа на ложах',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5872,
          arabicText: 'تَعْرِفُ فِى وُجُوهِهِمْ نَضْرَةَ النَّعِيمِ',
          transliteration: "Та'рифу фи вуджухихим надратан-на'им",
          russianText: 'На их лицах ты увидишь сияние блаженства',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5873,
          arabicText: 'يُسْقَوْنَ مِن رَّحِيقٍۢ مَّخْتُومٍ',
          transliteration: 'Юскауна мир-рахикым махтум',
          russianText: 'Их будут поить запечатанным выдержанным напитком',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5874,
          arabicText: 'خِتَٰمُهُۥ مِسْكٌۭ ۚ وَفِى ذَٰلِكَ فَلْيَتَنَافَسِ الْمُتَنَٰفِسُونَ',
          transliteration: 'Хитамуху миск, ва фи залика фальятанафасиль-мутанафисун',
          russianText: 'Печать его — мускус. Пусть же ради этого состязаются состязающиеся',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5875,
          arabicText: 'وَمِزَاجُهُۥ مِن تَسْنِيمٍ',
          transliteration: 'Ва мизаджуху мин тасним',
          russianText: 'Оно смешано с водой из Таснима',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5876,
          arabicText: 'عَيْنًۭا يَشْرَبُ بِهَا الْمُقَرَّبُونَ',
          transliteration: "'айнай яшрабу бихаль-мукаррабун",
          russianText: 'источника, из которого пьют приближённые',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5877,
          arabicText: 'إِنَّ الَّذِينَ أَجْرَمُوا۟ كَانُوا۟ مِنَ الَّذِينَ ءَامَنُوا۟ يَضْحَكُونَ',
          transliteration: 'Инналлязина аджраму кяню миналлязина аману ядхакун',
          russianText: 'Грешники смеялись над теми, которые уверовали',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5878,
          arabicText: 'وَإِذَا مَرُّوا۟ بِهِمْ يَتَغَامَزُونَ',
          transliteration: 'Ва иза марру бихим ятагамазун',
          russianText: 'Проходя мимо них, они подмигивали друг другу',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5879,
          arabicText: 'وَإِذَا انقَلَبُوٓا۟ إِلَىٰٓ أَهْلِهِمُ انقَلَبُوا۟ فَكِهِينَ',
          transliteration: 'Ва иза-нкалябу иля ахлихиму-нкалябу факихин',
          russianText: 'а возвращаясь к своим семьям, они возвращались радостными',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5880,
          arabicText: 'وَإِذَا رَأَوْهُمْ قَالُوٓا۟ إِنَّ هَٰٓؤُلَآءِ لَضَآلُّونَ',
          transliteration: 'Ва иза рааухум калю инна хаулаи лядаллюн',
          russianText: 'Увидев их, они говорили: «Воистину, эти впали в заблуждение»',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5881,
          arabicText: 'وَمَآ أُرْسِلُوا۟ عَلَيْهِمْ حَٰفِظِينَ',
          transliteration: "Ва ма урсилю 'алейхим хафизын",
          russianText: 'Но они не были посланы к ним хранителями',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5882,
          arabicText: 'فَالْيَوْمَ الَّذِينَ ءَامَنُوا۟ مِنَ الْكُفَّارِ يَضْحَكُونَ',
          transliteration: 'Фаль-яумаллязина аману миналь-куффари ядхакун',
          russianText: 'В тот день уверовавшие будут смеяться над неверующими',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5883,
          arabicText: 'عَلَى الْأَرَآئِكِ يَنظُرُونَ',
          transliteration: "'аляль-араики янзурун",
          russianText: 'созерцая, возлежа на ложах',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5884,
          arabicText: 'هَلْ ثُوِّبَ الْكُفَّارُ مَا كَانُوا۟ يَفْعَلُونَ',
          transliteration: "Халь суввибаль-куффару ма кяню яф'алюн",
          russianText: 'Разве неверующие не получили воздаяние за то, что они совершали?',
        ),
        LessonStep(
          type: LessonStepType.listenChoice,
          quranGlobalAyahNumber: 5870,
          arabicText: 'إِنَّ الْأَبْرَارَ لَفِى نَعِيمٍ',
          question: 'Прослушай аят и выбери его перевод',
          answers: [
            'Воистину, благочестивые будут в блаженстве',
            'Воистину, грешники окажутся в Аду',
            'Горе обвешивающим',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.wordOrder,
          question: 'Собери аят 22 суры Аль-Мутаффифин',
          russianText: 'Воистину, благочестивые будут в блаженстве',
          orderTokens: [
            'إِنَّ',
            'الْأَبْرَارَ',
            'لَفِى',
            'نَعِيمٍ',
          ],
          extraTokens: [
            'الْأَرَآئِكِ',
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем запечатан напиток благочестивых по аяту 26?',
          answers: [
            'Мускусом',
            'Воском',
            'Золотом',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'К чему призывает фраза «Пусть ради этого состязаются состязающиеся»?',
          answers: [
            'Соревноваться в благих делах ради награды у Аллаха',
            'Соревноваться в богатстве',
            'Спорить о толковании аятов',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Как вели себя грешники по отношению к верующим в мирской жизни?',
          answers: [
            'Смеялись, подмигивали и называли их заблудшими',
            'Помогали им деньгами',
            'Просили их совета',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что означает аят «они не были посланы к ним хранителями»?',
          answers: [
            'Никто не поручал грешникам судить верующих',
            'Ангелы не охраняли верующих',
            'Верующим не нужна защита',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем заканчивается сура Аль-Мутаффифин?',
          answers: [
            'Вопросом: получили ли неверующие воздаяние за свои дела',
            'Клятвой зарёй',
            'Рассказом о Мусе',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: "Иннал-абрара ляфи на'им", answer: 'Воистину, благочестивые будут в блаженстве'),
            LessonMatchPair(prompt: "Та'рифу фи вуджухихим надратан-на'им", answer: 'На их лицах ты увидишь сияние блаженства'),
            LessonMatchPair(prompt: 'Ва иза марру бихим ятагамазун', answer: 'Проходя мимо них, они подмигивали друг другу'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5870,
          arabicText: 'إِنَّ الْأَبْرَارَ لَفِى نَعِيمٍ',
          transliteration: "Иннал-абрара ляфи на'им",
          russianText: 'Расскажи аят 22 суры Аль-Мутаффифин.',
        ),
      ],
    ),
    const Lesson(
      id: 'q_inshiqaq_1',
      title: 'Аль-Иншикак',
      subtitle: 'Аяты 1–25 • полный текст во вкладке «Коран»',
      course: CourseType.quran,
      order: 46,
      steps: [
        LessonStep(
          type: LessonStepType.text,
          russianText: 'Аль-Иншикак означает «Разверзание». Небо разверзнется, земля будет распростёрта и извергнет всё, что внутри, — и обе покорятся Господу. Сура напоминает: человек идёт к встрече со своим Господом, и книга дел будет вручена ему в правую руку либо из-за спины. Клятвы вечерней зарёй, ночью и полной луной подводят к главному вопросу: почему же они не веруют?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5885,
          arabicText: 'إِذَا السَّمَآءُ انشَقَّتْ',
          transliteration: 'Изас-самау-ншаккат',
          russianText: 'Когда небо разверзнется',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5886,
          arabicText: 'وَأَذِنَتْ لِرَبِّهَا وَحُقَّتْ',
          transliteration: 'ва азинат лираббиха ва хуккат',
          russianText: 'и покорится своему Господу, как ему надлежит',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5887,
          arabicText: 'وَإِذَا الْأَرْضُ مُدَّتْ',
          transliteration: 'ва изаль-арду муддат',
          russianText: 'когда земля будет распростёрта',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5888,
          arabicText: 'وَأَلْقَتْ مَا فِيهَا وَتَخَلَّتْ',
          transliteration: 'ва алькат ма фиха ва тахаллят',
          russianText: 'извергнет то, что внутри неё, и опустеет',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5889,
          arabicText: 'وَأَذِنَتْ لِرَبِّهَا وَحُقَّتْ',
          transliteration: 'ва азинат лираббиха ва хуккат',
          russianText: 'и покорится своему Господу, как ей надлежит',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5890,
          arabicText: 'يَٰٓأَيُّهَا الْإِنسَٰنُ إِنَّكَ كَادِحٌ إِلَىٰ رَبِّكَ كَدْحًۭا فَمُلَٰقِيهِ',
          transliteration: 'Я аййухаль-инсану иннака кадихун иля раббика кадхан фамулякых',
          russianText: 'О человек! Ты стремишься к своему Господу и встретишь Его',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5891,
          arabicText: 'فَأَمَّا مَنْ أُوتِىَ كِتَٰبَهُۥ بِيَمِينِهِۦ',
          transliteration: 'Фаамма ман утия китабаху бияминих',
          russianText: 'Тот, кому книга будет вручена в правую руку',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5892,
          arabicText: 'فَسَوْفَ يُحَاسَبُ حِسَابًۭا يَسِيرًۭا',
          transliteration: 'фасауфа юхасабу хисабай ясира',
          russianText: 'получит лёгкий расчёт',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5893,
          arabicText: 'وَيَنقَلِبُ إِلَىٰٓ أَهْلِهِۦ مَسْرُورًۭا',
          transliteration: 'ва янкалибу иля ахлихи масрура',
          russianText: 'и вернётся к своей семье радостным',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5894,
          arabicText: 'وَأَمَّا مَنْ أُوتِىَ كِتَٰبَهُۥ وَرَآءَ ظَهْرِهِۦ',
          transliteration: 'Ва амма ман утия китабаху вараа захрих',
          russianText: 'А тот, кому книга будет вручена из-за спины',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5895,
          arabicText: 'فَسَوْفَ يَدْعُوا۟ ثُبُورًۭا',
          transliteration: "фасауфа яд'у субура",
          russianText: 'станет призывать погибель',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5896,
          arabicText: 'وَيَصْلَىٰ سَعِيرًا',
          transliteration: "ва ясля са'ира",
          russianText: 'и войдёт в Пламя',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5897,
          arabicText: 'إِنَّهُۥ كَانَ فِىٓ أَهْلِهِۦ مَسْرُورًا',
          transliteration: 'Иннаху кана фи ахлихи масрура',
          russianText: 'Он радовался, находясь в кругу своей семьи',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5898,
          arabicText: 'إِنَّهُۥ ظَنَّ أَن لَّن يَحُورَ',
          transliteration: 'Иннаху занна ал-лян яхур',
          russianText: 'и полагал, что не вернётся к Господу',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5899,
          arabicText: 'بَلَىٰٓ إِنَّ رَبَّهُۥ كَانَ بِهِۦ بَصِيرًۭا',
          transliteration: 'Баля инна раббаху кана бихи басыра',
          russianText: 'Но нет! Господь его видел его',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5900,
          arabicText: 'فَلَآ أُقْسِمُ بِالشَّفَقِ',
          transliteration: 'Фаля уксиму биш-шафак',
          russianText: 'Клянусь вечерней зарёй',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5901,
          arabicText: 'وَالَّيْلِ وَمَا وَسَقَ',
          transliteration: 'валь-лейли ва ма васак',
          russianText: 'ночью и тем, что она собирает',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5902,
          arabicText: 'وَالْقَمَرِ إِذَا اتَّسَقَ',
          transliteration: 'валь-камари иза-ттасак',
          russianText: 'и луной, когда она становится полной',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5903,
          arabicText: 'لَتَرْكَبُنَّ طَبَقًا عَن طَبَقٍۢ',
          transliteration: "Лятаркабунна табакан 'ан табак",
          russianText: 'Вы переходите из одного состояния в другое',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5904,
          arabicText: 'فَمَا لَهُمْ لَا يُؤْمِنُونَ',
          transliteration: "Фама ляхум ля ю'минун",
          russianText: 'Что же с ними, что они не веруют',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5905,
          arabicText: 'وَإِذَا قُرِئَ عَلَيْهِمُ الْقُرْءَانُ لَا يَسْجُدُونَ ۩',
          transliteration: "ва иза кури'а 'алейхимуль-Кур'ану ля ясджудун",
          russianText: 'и не падают ниц, когда им читают Коран?',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5906,
          arabicText: 'بَلِ الَّذِينَ كَفَرُوا۟ يُكَذِّبُونَ',
          transliteration: 'Балиллязина кафару юказзибун',
          russianText: 'Неверующие считают это ложью',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5907,
          arabicText: 'وَاللَّهُ أَعْلَمُ بِمَا يُوعُونَ',
          transliteration: "Валлаху а'ляму бима ю'ун",
          russianText: 'но Аллах лучше знает, что они хранят в себе',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5908,
          arabicText: 'فَبَشِّرْهُم بِعَذَابٍ أَلِيمٍ',
          transliteration: "Фабашширхум би'азабин алим",
          russianText: 'Обрадуй же их вестью о мучительных страданиях',
        ),
        LessonStep(
          type: LessonStepType.audio,
          quranGlobalAyahNumber: 5909,
          arabicText: 'إِلَّا الَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ الصَّٰلِحَٰتِ لَهُمْ أَجْرٌ غَيْرُ مَمْنُونٍۭ',
          transliteration: "Илляллязина аману ва 'амилюс-салихати ляхум аджрун гайру мамнун",
          russianText: 'кроме тех, которые уверовали и совершали праведные деяния: им уготована награда неиссякаемая',
        ),
        LessonStep(
          type: LessonStepType.listenChoice,
          quranGlobalAyahNumber: 5885,
          arabicText: 'إِذَا السَّمَآءُ انشَقَّتْ',
          question: 'Прослушай аят и выбери его перевод',
          answers: [
            'Когда небо разверзнется',
            'Когда небо расколется',
            'Когда солнце будет свёрнуто',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.wordOrder,
          question: 'Собери аят 7 суры Аль-Иншикак',
          russianText: 'Тот, кому книга будет вручена в правую руку',
          orderTokens: [
            'فَأَمَّا',
            'مَنْ',
            'أُوتِىَ',
            'كِتَٰبَهُۥ',
            'بِيَمِينِهِۦ',
          ],
          extraTokens: [
            'وَرَآءَ',
          ],
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что делают небо и земля в начале суры Аль-Иншикак?',
          answers: [
            'Покоряются своему Господу, как им надлежит',
            'Сопротивляются повелению',
            'Остаются неизменными',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'О чём напоминает аят 6 «Ты стремишься к своему Господу и встретишь Его»?',
          answers: [
            'Вся жизнь человека — путь к встрече с Господом',
            'Нужно много путешествовать',
            'Встреча произойдёт во сне',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Что ждёт того, кому книга вручена в правую руку?',
          answers: [
            'Лёгкий расчёт и возвращение к семье радостным',
            'Долгий суд',
            'Пламя',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Чем ошибался тот, кто радовался в кругу семьи, но не веровал?',
          answers: [
            'Он полагал, что не вернётся к своему Господу',
            'Он не любил свою семью',
            'Он не знал арабского языка',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.question,
          question: 'Кого сура исключает из мучительного наказания в последнем аяте?',
          answers: [
            'Уверовавших и совершавших праведные деяния',
            'Богатых',
            'Живших в Мекке',
          ],
          correctAnswerIndex: 0,
        ),
        LessonStep(
          type: LessonStepType.matching,
          question: 'Соедини транслитерацию и перевод',
          matchPairs: [
            LessonMatchPair(prompt: 'Изас-самау-ншаккат', answer: 'Когда небо разверзнется'),
            LessonMatchPair(prompt: 'Фаамма ман утия китабаху бияминих', answer: 'Тот, кому книга будет вручена в правую руку'),
            LessonMatchPair(prompt: "Лятаркабунна табакан 'ан табак", answer: 'Вы переходите из одного состояния в другое'),
          ],
        ),
        LessonStep(
          type: LessonStepType.speak,
          quranGlobalAyahNumber: 5885,
          arabicText: 'إِذَا السَّمَآءُ انشَقَّتْ',
          transliteration: 'Изас-самау-ншаккат',
          russianText: 'Расскажи первый аят суры Аль-Иншикак.',
        ),
      ],
    ),
];
