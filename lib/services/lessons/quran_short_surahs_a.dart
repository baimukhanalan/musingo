import '../../models/lesson.dart';

final List<Lesson> quranShortSurahsA = [
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
        question:
            'Чем обернётся для хулителя уверенность, что богатство сделает его вечным?',
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
        question:
            'Заполни пропуск: «Страсть к приумножению увлекает вас, пока вы не посетите ___»',
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
        russianText:
            'Аль-Кариа означает «Великое бедствие» (Поражающее) — одно '
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
        answers: ['Пропасть (Преисподняя)', 'Жаркий Огонь', 'Приятная жизнь'],
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
        arabicText:
            'يَوْمَئِذٍۢ يَصْدُرُ النَّاسُ أَشْتَاتًۭا لِّيُرَوْا۟ أَعْمَٰلَهُمْ',
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
        arabicText:
            'تَنَزَّلُ الْمَلَٰٓئِكَةُ وَالرُّوحُ فِيهَا بِإِذْنِ رَبِّهِم مِّن كُلِّ أَمْرٍۢ',
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
        answers: ['С одним днём', 'Она лучше тысячи месяцев', 'С одним годом'],
        correctAnswerIndex: 1,
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'До какого времени длится благополучие этой ночи?',
        answers: ['До полуночи', 'До заката', 'До наступления зари'],
        correctAnswerIndex: 2,
      ),
      // Cloze на арабском: мера сравнения ценности ночи.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Заполни пропуск: «لَيْلَةُ الْقَدْرِ خَيْرٌ مِّنْ أَلْفِ ___» (лучше тысячи…)',
        answers: ['شَهْرٍ', 'يَوْمٍ', 'سَنَةٍ'],
        correctAnswerIndex: 0,
      ),
      // Логика: кто нисходит в эту ночь.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Кто, по суре, нисходит в ночь Предопределения с дозволения Господа?',
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
        arabicText:
            'إِلَّا الَّذِينَ ءَامَنُوا۟ وَعَمِلُوا۟ الصَّٰلِحَٰتِ فَلَهُمْ أَجْرٌ غَيْرُ مَمْنُونٍۢ',
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
        question:
            'Заполни пропуск: «لَقَدْ خَلَقْنَا الْإِنسَٰنَ فِىٓ أَحْسَنِ ___» (в прекраснейшем…)',
        answers: ['تَقْوِيمٍ', 'سَافِلِينَ', 'شَهْرٍ'],
        correctAnswerIndex: 0,
      ),
      // Логика: что определяет конечную участь человека.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Человек создан в прекраснейшем облике; что, по суре, определяет его конечную участь?',
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
        question:
            'Заполни пропуск: «فَإِنَّ مَعَ الْعُسْرِ ___» (за тягостью — …)',
        answers: ['يُسْرًا', 'عُسْرًا', 'نَارًا'],
        correctAnswerIndex: 0,
      ),
      // Логика: зачем обещание об облегчении повторено дважды.
      LessonStep(
        type: LessonStepType.question,
        question:
            'Почему в суре дважды сказано «за тягостью наступает облегчение»?',
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
        answers: ['Прогонять его', 'Не притеснять его', 'Не замечать его'],
        correctAnswerIndex: 1,
      ),
      LessonStep(
        type: LessonStepType.question,
        question: 'Что, по концу суры, нужно делать с милостью Господа?',
        answers: ['Скрывать её', 'Забыть о ней', 'Возвещать о ней'],
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
];
