import '../../models/lesson.dart';

final List<Lesson> quranFirstSurahsLessons = [
  const Lesson(
    id: 'q_asr_1',
    title: 'Аль-Аср',
    subtitle: 'Учебный фрагмент • полный текст во вкладке «Коран»',
    course: CourseType.quran,
    order: 10,
    steps: [
      LessonStep(
        type: LessonStepType.text,
        russianText:
            'Аль-Аср означает «Предвечернее время». Короткая мекканская '
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
        arabicText:
            'إِلَّا الَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ الصَّٰلِحَٰتِ وَتَوَاصَوْا۟ بِالْحَقِّ وَتَوَاصَوْا۟ بِالصَّبْرِ',
        transliteration:
            "Илляллязина аману ва 'амилю-с-салихати ва таваасау биль-хаккы ва таваасау бис-сабр",
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
        russianText:
            'Разве ты не видел, как поступил твой Господь с владельцами '
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
        question:
            'Как переводится «أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَٰبِ الْفِيلِ»?',
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
        answers: ['Птиц стаями, метавших камни', 'Сильный ветер', 'Потоп'],
        correctAnswerIndex: 0,
      ),
      // Cloze: материал бросаемых камней.
      LessonStep(
        type: LessonStepType.question,
        question: 'Птицы бросали в войско каменья из ___',
        answers: [
          'обожжённой глины',
          'пальмовых волокон',
          'расчёсанной шерсти'
        ],
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
        arabicText:
            'الَّذِىٓ أَطْعَمَهُم مِّن جُوعٍۢ وَءَامَنَهُم مِّنْ خَوْفٍۭ',
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
        question:
            'За какие две милости, по последнему аяту, курайшиты должны благодарить Господа?',
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
        russianText:
            'Аль-Каусар означает «Изобилие» — это дар Пророку, мир ему. '
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
        answers: [
          '«Вам — ваша религия, а мне — моя религия»',
          '«Хвала Господу миров»',
          '«Прибегаю к Господу рассвета»'
        ],
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
        russianText:
            'Ан-Наср означает «Помощь». Сура возвещает о помощи Аллаха '
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
        arabicText:
            'وَرَأَيْتَ النَّاسَ يَدْخُلُونَ فِى دِينِ اللَّهِ أَفْوَاجًۭا',
        transliteration: "Ва ра'айтан-наса ядхулюна фи диниллахи афваджа",
        russianText: 'и ты увидишь, как люди толпами принимают религию Аллаха',
      ),
      LessonStep(
        type: LessonStepType.audio,
        quranGlobalAyahNumber: 6216,
        arabicText:
            'فَسَبِّحْ بِحَمْدِ رَبِّكَ وَاسْتَغْفِرْهُ ۚ إِنَّهُۥ كَانَ تَوَّابًۢا',
        transliteration:
            'Фасаббих би-хамди раббика вастагфирх, иннаху кана таввааба',
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
        question:
            'Почему в час победы сура велит прославлять Господа и просить прощения?',
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
        question:
            'Аль-Каусар обещает изобилие Пророку, а что суля Аль-Масад его врагу?',
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
              answer: 'и на шее у неё будет верёвка из пальмовых волокон'),
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
        russianText:
            'Это контроль после блока коротких сур. Вспомни их смысл и '
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
        question:
            'Какая сура завершается словами «Вам — ваша религия, а мне — моя»?',
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
        question:
            'Какая сура призывает поклоняться Господу Каабы за пропитание и безопасность?',
        answers: ['Курайш', 'Аль-Масад', 'Аль-Каусар'],
        correctAnswerIndex: 0,
      ),
      // Логика: сура о сироте и небрежной молитве.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Какая сура порицает того, кто гонит сироту и небрежен в молитве?',
        answers: ['Аль-Маун', 'Аль-Каусар', 'Курайш'],
        correctAnswerIndex: 0,
      ),
      // Логика: сура о том, что богатство не спасло врага Пророка.
      LessonStep(
        type: LessonStepType.question,
        question:
            'В какой суре сказано, что богатство и вражда не спасли Абу Ляхаба?',
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
              prompt: 'إِذَا جَآءَ نَصْرُ اللَّهِ وَالْفَتْحُ',
              answer: 'Ан-Наср'),
        ],
      ),
    ],
  ),
];
