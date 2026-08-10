import '../../models/lesson.dart';

/// Structured continuation of the Quran path through Juz Tabarak (surahs
/// 67-77). Arabic text is copied from the bundled Tanzil Uthmani asset and is
/// checked against it in quran_canonical_asset_test.dart.
final List<Lesson> juzTabarakLessons = _juzTabarakSpecs
    .map(
      (spec) => Lesson(
        id: spec.id,
        title: spec.title,
        subtitle: spec.subtitle,
        course: CourseType.quran,
        order: spec.order,
        sourceUrl: spec.sourceUrl,
        steps: [
          LessonStep(
            id: '${spec.id}_intro',
            type: LessonStepType.text,
            russianText: spec.overview,
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_audio_1',
            type: LessonStepType.audio,
            quranGlobalAyahNumber: spec.firstAyahNumber,
            arabicText: spec.firstArabic,
            transliteration: spec.firstTransliteration,
            russianText: spec.firstMeaning,
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_audio_2',
            type: LessonStepType.audio,
            quranGlobalAyahNumber: spec.secondAyahNumber,
            arabicText: spec.secondArabic,
            transliteration: spec.secondTransliteration,
            russianText: spec.secondMeaning,
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_listen',
            type: LessonStepType.listenChoice,
            quranGlobalAyahNumber: spec.firstAyahNumber,
            arabicText: spec.firstArabic,
            question: 'Прослушай аят и выбери наиболее точный смысл',
            answers: spec.listeningAnswers,
            correctAnswerIndex: spec.listeningCorrectIndex,
            explanation:
                'Сначала выдели ключевые слова и только потом сравни варианты.',
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_order',
            type: LessonStepType.wordOrder,
            question: spec.orderQuestion,
            russianText: spec.secondMeaning,
            orderTokens: spec.orderTokens,
            extraTokens: spec.extraTokens,
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_meaning',
            type: LessonStepType.question,
            question: spec.meaningQuestion,
            answers: spec.meaningAnswers,
            correctAnswerIndex: spec.meaningCorrectIndex,
            explanation: spec.meaningHint,
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_reasoning',
            type: LessonStepType.question,
            question: spec.reasoningQuestion,
            answers: spec.reasoningAnswers,
            correctAnswerIndex: spec.reasoningCorrectIndex,
            explanation: spec.reasoningHint,
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_matching',
            type: LessonStepType.matching,
            question: 'Соедини аят с его учебным смыслом',
            matchPairs: [
              LessonMatchPair(
                prompt: spec.firstTransliteration,
                answer: spec.firstMeaning,
              ),
              LessonMatchPair(
                prompt: spec.secondTransliteration,
                answer: spec.secondMeaning,
              ),
            ],
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_speak',
            type: LessonStepType.speak,
            quranGlobalAyahNumber: spec.secondAyahNumber,
            arabicText: spec.secondArabic,
            transliteration: spec.secondTransliteration,
            russianText:
                'Сначала прослушай образец, затем произнеси аят полностью.',
            speechMode: SpeechMode.quran,
            passScore: 75,
            sourceRefs: spec.sourceRefs,
          ),
        ],
      ),
    )
    .toList(growable: false);

class _JuzTabarakSpec {
  final String id;
  final String title;
  final String subtitle;
  final int order;
  final String sourceUrl;
  final List<String> sourceRefs;
  final String overview;
  final int firstAyahNumber;
  final String firstArabic;
  final String firstTransliteration;
  final String firstMeaning;
  final int secondAyahNumber;
  final String secondArabic;
  final String secondTransliteration;
  final String secondMeaning;
  final List<String> listeningAnswers;
  final int listeningCorrectIndex;
  final String orderQuestion;
  final List<String> orderTokens;
  final List<String> extraTokens;
  final String meaningQuestion;
  final List<String> meaningAnswers;
  final int meaningCorrectIndex;
  final String meaningHint;
  final String reasoningQuestion;
  final List<String> reasoningAnswers;
  final int reasoningCorrectIndex;
  final String reasoningHint;

  const _JuzTabarakSpec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.order,
    required this.sourceUrl,
    required this.sourceRefs,
    required this.overview,
    required this.firstAyahNumber,
    required this.firstArabic,
    required this.firstTransliteration,
    required this.firstMeaning,
    required this.secondAyahNumber,
    required this.secondArabic,
    required this.secondTransliteration,
    required this.secondMeaning,
    required this.listeningAnswers,
    required this.listeningCorrectIndex,
    required this.orderQuestion,
    required this.orderTokens,
    required this.extraTokens,
    required this.meaningQuestion,
    required this.meaningAnswers,
    required this.meaningCorrectIndex,
    required this.meaningHint,
    required this.reasoningQuestion,
    required this.reasoningAnswers,
    required this.reasoningCorrectIndex,
    required this.reasoningHint,
  });
}

const List<_JuzTabarakSpec> _juzTabarakSpecs = [
  _JuzTabarakSpec(
    id: 'q_mulk_1',
    title: 'Аль-Мульк',
    subtitle: 'Аяты 1-2: власть, жизнь и испытание',
    order: 49,
    sourceUrl: 'https://quran.com/67',
    sourceRefs: ['Коран 67:1-2'],
    overview:
        'Аль-Мульк означает «Власть». Начало суры связывает власть Аллаха над всем сущим с целью жизни и смерти: человек испытывается не количеством, а качеством поступков.',
    firstAyahNumber: 5242,
    firstArabic:
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ تَبَٰرَكَ ٱلَّذِى بِيَدِهِ ٱلْمُلْكُ وَهُوَ عَلَىٰ كُلِّ شَىْءٍۢ قَدِيرٌ',
    firstTransliteration:
        'Табаракаллязи биядихиль-мульку ва хува аля кулли шайин кадир',
    firstMeaning:
        'Благословен Тот, в Чьей Руке власть и Кто способен на всякую вещь',
    secondAyahNumber: 5243,
    secondArabic:
        'ٱلَّذِى خَلَقَ ٱلْمَوْتَ وَٱلْحَيَوٰةَ لِيَبْلُوَكُمْ أَيُّكُمْ أَحْسَنُ عَمَلًۭا ۚ وَهُوَ ٱلْعَزِيزُ ٱلْغَفُورُ',
    secondTransliteration:
        'Аллязи халякаль-маута валь-хаята лияблювакум айюкум ахсану амаля',
    secondMeaning:
        'Он создал смерть и жизнь, чтобы испытать, чьи поступки лучше',
    listeningAnswers: [
      'Он создал небеса без опор',
      'В Его Руке власть, и Он способен на всякую вещь',
      'Человек создан слабым'
    ],
    listeningCorrectIndex: 1,
    orderQuestion: 'Восстанови ключевую часть аята 2',
    orderTokens: ['ٱلَّذِى', 'خَلَقَ', 'ٱلْمَوْتَ', 'وَٱلْحَيَوٰةَ'],
    extraTokens: ['ٱلسَّمَآءَ'],
    meaningQuestion: 'По аяту 2, что является критерием испытания?',
    meaningAnswers: [
      'Продолжительность жизни',
      'Количество имущества',
      'Качество поступков'
    ],
    meaningCorrectIndex: 2,
    meaningHint:
        'Сравни слова «сколько» и «лучше»: аят использует только одно из этих понятий.',
    reasoningQuestion: 'Как связаны первые два аята суры?',
    reasoningAnswers: [
      'Власть Аллаха означает, что жизнь имеет цель и ответственность',
      'Первый аят отменяет испытание из второго',
      'Они описывают две несвязанные истории'
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Подумай, почему после упоминания власти сразу названа цель жизни и смерти.',
  ),
  _JuzTabarakSpec(
    id: 'q_qalam_1',
    title: 'Аль-Калям',
    subtitle: 'Аяты 1 и 4: знание и нравственность',
    order: 50,
    sourceUrl: 'https://quran.com/68',
    sourceRefs: ['Коран 68:1', 'Коран 68:4'],
    overview:
        'Сура начинается клятвой письменной тростью и тем, что люди записывают, а затем подчёркивает великий нрав Пророка. Урок соединяет знание, ответственность за слово и характер.',
    firstAyahNumber: 5272,
    firstArabic:
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ نٓ ۚ وَٱلْقَلَمِ وَمَا يَسْطُرُونَ',
    firstTransliteration: 'Нун. Валь-каля́ми ва ма ястурун',
    firstMeaning: 'Нун. Клянусь письменной тростью и тем, что они записывают',
    secondAyahNumber: 5275,
    secondArabic: 'وَإِنَّكَ لَعَلَىٰ خُلُقٍ عَظِيمٍۢ',
    secondTransliteration: 'Ва иннака ляаля хулюкин азым',
    secondMeaning: 'Поистине, твой нрав велик',
    listeningAnswers: [
      'Клянусь письменной тростью и тем, что записывают',
      'Клянусь рассветом и десятью ночами',
      'Читай во имя твоего Господа'
    ],
    listeningCorrectIndex: 0,
    orderQuestion: 'Собери аят о великом нраве',
    orderTokens: ['وَإِنَّكَ', 'لَعَلَىٰ', 'خُلُقٍ', 'عَظِيمٍۢ'],
    extraTokens: ['قَلَمٍ'],
    meaningQuestion: 'Что прямо восхваляется в аяте 4?',
    meaningAnswers: ['Красноречие', 'Великий нрав', 'Богатство'],
    meaningCorrectIndex: 1,
    meaningHint:
        'Ищи качество личности, а не внешний успех или отдельный навык.',
    reasoningQuestion:
        'Какой учебный вывод следует из соседства тем письма и нрава?',
    reasoningAnswers: [
      'Знание полезно, когда сопровождается ответственностью и хорошим характером',
      'Записывать знания не следует',
      'Хороший нрав заменяет обучение'
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Обе темы усиливают друг друга, а не исключают одна другую.',
  ),
  _JuzTabarakSpec(
    id: 'q_haqqah_1',
    title: 'Аль-Хакка',
    subtitle: 'Аяты 1 и 19: неизбежная истина',
    order: 51,
    sourceUrl: 'https://quran.com/69',
    sourceRefs: ['Коран 69:1', 'Коран 69:19'],
    overview:
        'Название «Аль-Хакка» указывает на неизбежную Истину Судного дня. Сура противопоставляет разные итоги, а человек с книгой деяний в правой руке рад своей открытой и честной записи.',
    firstAyahNumber: 5324,
    firstArabic: 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ ٱلْحَآقَّةُ',
    firstTransliteration: 'Аль-Хакка',
    firstMeaning: 'Неизбежная истина',
    secondAyahNumber: 5342,
    secondArabic:
        'فَأَمَّا مَنْ أُوتِىَ كِتَٰبَهُۥ بِيَمِينِهِۦ فَيَقُولُ هَآؤُمُ ٱقْرَءُوا۟ كِتَٰبِيَهْ',
    secondTransliteration:
        'Фа амма ман у́тия китабаху бияминихи фаякулю хауму-крау китабия',
    secondMeaning:
        'Получивший книгу в правую руку скажет: «Вот, прочтите мою книгу»',
    listeningAnswers: [
      'Час приблизился',
      'Неизбежная истина',
      'День различения'
    ],
    listeningCorrectIndex: 1,
    orderQuestion: 'Собери начало аята о книге деяний',
    orderTokens: ['فَأَمَّا', 'مَنْ', 'أُوتِىَ', 'كِتَٰبَهُۥ', 'بِيَمِينِهِۦ'],
    extraTokens: ['بِشِمَالِهِۦ'],
    meaningQuestion: 'Почему человек из аята 19 предлагает прочесть его книгу?',
    meaningAnswers: [
      'Он радуется своему благому итогу',
      'Он не знает, кому она принадлежит',
      'Он хочет изменить запись'
    ],
    meaningCorrectIndex: 0,
    meaningHint:
        'Обрати внимание, в какую руку ему дана книга и с каким настроением он говорит.',
    reasoningQuestion: 'Как название суры связано со сценой получения книги?',
    reasoningAnswers: [
      'Книга показывает неизбежный итог реальных поступков',
      'Название относится только к письменности',
      'Получение книги отменяет расчёт'
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Сопоставь неизбежность события и запись того, что уже было сделано.',
  ),
  _JuzTabarakSpec(
    id: 'q_maarij_1',
    title: 'Аль-Мааридж',
    subtitle: 'Аяты 5 и 24: терпение и ответственность',
    order: 52,
    sourceUrl: 'https://quran.com/70',
    sourceRefs: ['Коран 70:5', 'Коран 70:24-25'],
    overview:
        'Сура учит красивому терпению и описывает устойчивые качества верующих. Среди них — признание известной доли имущества за просящим и лишённым.',
    firstAyahNumber: 5380,
    firstArabic: 'فَٱصْبِرْ صَبْرًۭا جَمِيلًا',
    firstTransliteration: 'Фасбир сабран джамиля',
    firstMeaning: 'Терпи красивым терпением',
    secondAyahNumber: 5399,
    secondArabic: 'وَٱلَّذِينَ فِىٓ أَمْوَٰلِهِمْ حَقٌّۭ مَّعْلُومٌۭ',
    secondTransliteration: 'Валлязина фи амвалихим хаккун малюм',
    secondMeaning: 'В их имуществе есть известная доля',
    listeningAnswers: [
      'Проявляй красивое терпение',
      'Спеши получить ответ',
      'Оставь всякую ответственность'
    ],
    listeningCorrectIndex: 0,
    orderQuestion: 'Собери аят об известной доле',
    orderTokens: [
      'وَٱلَّذِينَ',
      'فِىٓ',
      'أَمْوَٰلِهِمْ',
      'حَقٌّۭ',
      'مَّعْلُومٌۭ'
    ],
    extraTokens: ['صَبْرًۭا'],
    meaningQuestion: 'Кому посвящено продолжение аята об известной доле?',
    meaningAnswers: [
      'Только родственникам',
      'Просящему и лишённому',
      'Только путешественнику'
    ],
    meaningCorrectIndex: 1,
    meaningHint: 'Ответ раскрывается следующим, 25-м аятом суры.',
    reasoningQuestion:
        'Что объединяет красивое терпение и помощь из имущества?',
    reasoningAnswers: [
      'Оба качества требуют устойчивости, а не разового порыва',
      'Оба разрешены только в путешествии',
      'Помощь противоречит терпению'
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Подумай о привычке, которая сохраняется и в трудности, и в достатке.',
  ),
  _JuzTabarakSpec(
    id: 'q_nuh_1',
    title: 'Нух',
    subtitle: 'Аяты 5 и 10: постоянство призыва',
    order: 53,
    sourceUrl: 'https://quran.com/71',
    sourceRefs: ['Коран 71:5', 'Коран 71:10'],
    overview:
        'Сура передаёт терпеливый призыв пророка Нуха к своему народу. Он обращался к ним ночью и днём и звал просить прощения у Господа.',
    firstAyahNumber: 5424,
    firstArabic: 'قَالَ رَبِّ إِنِّى دَعَوْتُ قَوْمِى لَيْلًۭا وَنَهَارًۭا',
    firstTransliteration: 'Каля рабби инни даавту кауми лайлян ва нахара',
    firstMeaning: 'Он сказал: «Господи, я призывал мой народ ночью и днём»',
    secondAyahNumber: 5429,
    secondArabic: 'فَقُلْتُ ٱسْتَغْفِرُوا۟ رَبَّكُمْ إِنَّهُۥ كَانَ غَفَّارًۭا',
    secondTransliteration: 'Факультустагфиру раббакум иннаху кана гаффара',
    secondMeaning:
        'Я говорил: «Просите прощения у вашего Господа, ведь Он Прощающий»',
    listeningAnswers: [
      'Я призывал свой народ только утром',
      'Я призывал свой народ ночью и днём',
      'Я оставил свой народ без наставления'
    ],
    listeningCorrectIndex: 1,
    orderQuestion: 'Собери призыв просить прощения',
    orderTokens: [
      'فَقُلْتُ',
      'ٱسْتَغْفِرُوا۟',
      'رَبَّكُمْ',
      'إِنَّهُۥ',
      'كَانَ',
      'غَفَّارًۭا'
    ],
    extraTokens: ['لَيْلًۭا'],
    meaningQuestion: 'Что показывает выражение «ночью и днём»?',
    meaningAnswers: [
      'Однократный призыв',
      'Постоянство и терпение',
      'Запрет говорить днём'
    ],
    meaningCorrectIndex: 1,
    meaningHint:
        'Речь идёт о длительности усилия, а не об ограничении времени.',
    reasoningQuestion: 'Какой следующий шаг после призыва назван в аяте 10?',
    reasoningAnswers: [
      'Просить у Аллаха прощения',
      'Требовать немедленного знамения',
      'Прекратить обращение'
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Вспомни глагол «истагфиру» и его корень, связанный с прощением.',
  ),
  _JuzTabarakSpec(
    id: 'q_jinn_1',
    title: 'Аль-Джинн',
    subtitle: 'Аяты 1-2: услышать и последовать',
    order: 54,
    sourceUrl: 'https://quran.com/72',
    sourceRefs: ['Коран 72:1-2'],
    overview:
        'В начале суры группа джиннов слышит удивительный Коран, распознаёт в нём руководство к прямому пути, верует и отвергает приобщение сотоварищей к Господу.',
    firstAyahNumber: 5448,
    firstArabic:
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ قُلْ أُوحِىَ إِلَىَّ أَنَّهُ ٱسْتَمَعَ نَفَرٌۭ مِّنَ ٱلْجِنِّ فَقَالُوٓا۟ إِنَّا سَمِعْنَا قُرْءَانًا عَجَبًۭا',
    firstTransliteration:
        'Куль ухия иляйя аннахустамаа нафарун миналь-джинни факалу инна самина куранан аджаба',
    firstMeaning: 'Мне открыто, что группа джиннов услышала удивительный Коран',
    secondAyahNumber: 5449,
    secondArabic:
        'يَهْدِىٓ إِلَى ٱلرُّشْدِ فَـَٔامَنَّا بِهِۦ ۖ وَلَن نُّشْرِكَ بِرَبِّنَآ أَحَدًۭا',
    secondTransliteration:
        'Яхди иляр-рушди фа аманна бихи ва лян нушрика бираббина ахада',
    secondMeaning:
        'Он ведёт к прямому пути; мы уверовали и никого не приобщим к Господу',
    listeningAnswers: [
      'Группа джиннов услышала удивительный Коран',
      'Люди отказались слушать любую речь',
      'Ангелы записали свиток'
    ],
    listeningCorrectIndex: 0,
    orderQuestion: 'Собери вывод слушателей из аята 2',
    orderTokens: ['يَهْدِىٓ', 'إِلَى', 'ٱلرُّشْدِ', 'فَـَٔامَنَّا', 'بِهِۦ'],
    extraTokens: ['فَكَذَّبْنَا'],
    meaningQuestion: 'Какая последовательность показана в первых аятах?',
    meaningAnswers: [
      'Услышали, распознали руководство и уверовали',
      'Уверовали, не услышав послания',
      'Услышали и решили скрыть смысл'
    ],
    meaningCorrectIndex: 0,
    meaningHint: 'Проследи действия по порядку между первым и вторым аятами.',
    reasoningQuestion:
        'Какой принцип следует сразу после признания руководства?',
    reasoningAnswers: [
      'Отказ от единобожия',
      'Не приобщать никого к Господу',
      'Не рассказывать об услышанном'
    ],
    reasoningCorrectIndex: 1,
    reasoningHint:
        'Вторая половина аята 2 начинается со слов «и никогда не...».',
  ),
  _JuzTabarakSpec(
    id: 'q_muzzammil_1',
    title: 'Аль-Муззаммиль',
    subtitle: 'Аяты 4 и 8: размеренное чтение',
    order: 55,
    sourceUrl: 'https://quran.com/73',
    sourceRefs: ['Коран 73:4', 'Коран 73:8'],
    overview:
        'Сура связывает ночное поклонение с подготовкой к весомому слову. Коран велено читать размеренно, поминая имя Господа и обращаясь к Нему всем сердцем.',
    firstAyahNumber: 5479,
    firstArabic: 'أَوْ زِدْ عَلَيْهِ وَرَتِّلِ ٱلْقُرْءَانَ تَرْتِيلًا',
    firstTransliteration: 'Ау зид алейхи ва раттилиль-Курана тартиля',
    firstMeaning: 'Или добавь к этому и читай Коран размеренным чтением',
    secondAyahNumber: 5483,
    secondArabic: 'وَٱذْكُرِ ٱسْمَ رَبِّكَ وَتَبَتَّلْ إِلَيْهِ تَبْتِيلًۭا',
    secondTransliteration: 'Вазкурисма раббика ва табатталь иляйхи табтиля',
    secondMeaning: 'Поминай имя Господа и посвяти себя Ему',
    listeningAnswers: [
      'Читай Коран как можно быстрее',
      'Читай Коран размеренно',
      'Читай только про себя'
    ],
    listeningCorrectIndex: 1,
    orderQuestion: 'Собери повеление о размеренном чтении',
    orderTokens: ['وَرَتِّلِ', 'ٱلْقُرْءَانَ', 'تَرْتِيلًا'],
    extraTokens: ['سَرِيعًا'],
    meaningQuestion: 'Что означает «тартиль» в контексте урока?',
    meaningAnswers: [
      'Размеренное, ясное чтение',
      'Чтение без остановки и смысла',
      'Только громкое чтение'
    ],
    meaningCorrectIndex: 0,
    meaningHint:
        'Сосредоточься на качестве и ясности, а не на скорости или громкости.',
    reasoningQuestion:
        'Почему поминание Господа следует рядом с указанием читать размеренно?',
    reasoningAnswers: [
      'Чтение — не только техника, оно связано с вниманием сердца',
      'Поминание заменяет чтение Корана',
      'Размеренность нужна только ночью'
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Сопоставь действие языка и внутреннее направление человека.',
  ),
  _JuzTabarakSpec(
    id: 'q_muddaththir_1',
    title: 'Аль-Муддассир',
    subtitle: 'Аяты 2 и 4: встать и действовать',
    order: 56,
    sourceUrl: 'https://quran.com/74',
    sourceRefs: ['Коран 74:2-4'],
    overview:
        'Короткие повеления в начале суры задают ритм ответственности: встать, предостерегать, возвеличивать Господа и хранить чистоту.',
    firstAyahNumber: 5497,
    firstArabic: 'قُمْ فَأَنذِرْ',
    firstTransliteration: 'Кум фа-анзир',
    firstMeaning: 'Встань и предостерегай',
    secondAyahNumber: 5499,
    secondArabic: 'وَثِيَابَكَ فَطَهِّرْ',
    secondTransliteration: 'Ва сиябака фатаххир',
    secondMeaning: 'Одежды свои очищай',
    listeningAnswers: [
      'Встань и предостерегай',
      'Сядь и жди',
      'Отправляйся в путь ночью'
    ],
    listeningCorrectIndex: 0,
    orderQuestion: 'Собери аят о чистоте',
    orderTokens: ['وَثِيَابَكَ', 'فَطَهِّرْ'],
    extraTokens: ['فَٱصْبِرْ'],
    meaningQuestion: 'Какой характер имеют первые повеления суры?',
    meaningAnswers: [
      'Пассивное ожидание',
      'Последовательное действие и ответственность',
      'Поиск личной выгоды'
    ],
    meaningCorrectIndex: 1,
    meaningHint:
        'Посмотри на форму глаголов: каждый из них побуждает к конкретному действию.',
    reasoningQuestion: 'Почему чистота упомянута рядом с призывом?',
    reasoningAnswers: [
      'Ответственность включает и обращение к людям, и личную чистоту',
      'Чистота важна только перед путешествием',
      'Призыв отменяет личную дисциплину'
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Внешняя задача не освобождает человека от работы над собой.',
  ),
  _JuzTabarakSpec(
    id: 'q_qiyamah_1',
    title: 'Аль-Кияма',
    subtitle: 'Аяты 1-2: расчёт и совесть',
    order: 57,
    sourceUrl: 'https://quran.com/75',
    sourceRefs: ['Коран 75:1-2'],
    overview:
        'Сура открывается упоминанием Дня воскресения и души, которая укоряет себя. Вместе эти образы учат ответственности: будущий расчёт связан с честной оценкой себя уже сейчас.',
    firstAyahNumber: 5552,
    firstArabic:
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ لَآ أُقْسِمُ بِيَوْمِ ٱلْقِيَٰمَةِ',
    firstTransliteration: 'Ля уксиму бияумиль-кияма',
    firstMeaning: 'Клянусь Днём воскресения',
    secondAyahNumber: 5553,
    secondArabic: 'وَلَآ أُقْسِمُ بِٱلنَّفْسِ ٱللَّوَّامَةِ',
    secondTransliteration: 'Ва ля уксиму бин-нафсиль-ляввама',
    secondMeaning: 'Клянусь душой, укоряющей себя',
    listeningAnswers: [
      'Клянусь Днём воскресения',
      'Клянусь утренним временем',
      'Клянусь городом'
    ],
    listeningCorrectIndex: 0,
    orderQuestion: 'Собери аят об укоряющей душе',
    orderTokens: ['وَلَآ', 'أُقْسِمُ', 'بِٱلنَّفْسِ', 'ٱللَّوَّامَةِ'],
    extraTokens: ['ٱلْمُطْمَئِنَّةِ'],
    meaningQuestion: 'Что делает «ан-нафс аль-ляввама»?',
    meaningAnswers: [
      'Всегда оправдывает себя',
      'Укоряет себя за ошибки',
      'Не замечает поступков'
    ],
    meaningCorrectIndex: 1,
    meaningHint: 'Смысл корня связан с порицанием и внутренним упрёком.',
    reasoningQuestion: 'Как связаны два образа в начале суры?',
    reasoningAnswers: [
      'Самоотчёт сейчас готовит к окончательному расчёту',
      'Совесть отменяет День воскресения',
      'Между ними нет смысловой связи'
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Подумай о двух уровнях оценки поступков: внутреннем и окончательном.',
  ),
  _JuzTabarakSpec(
    id: 'q_insan_1',
    title: 'Аль-Инсан',
    subtitle: 'Аяты 2-3: испытание и выбор',
    order: 58,
    sourceUrl: 'https://quran.com/76',
    sourceRefs: ['Коран 76:2-3'],
    overview:
        'Сура напоминает о происхождении человека, его способности слышать и видеть и о показанном ему пути. После наставления человек проявляет благодарность или неблагодарность.',
    firstAyahNumber: 5593,
    firstArabic:
        'إِنَّا خَلَقْنَا ٱلْإِنسَٰنَ مِن نُّطْفَةٍ أَمْشَاجٍۢ نَّبْتَلِيهِ فَجَعَلْنَٰهُ سَمِيعًۢا بَصِيرًا',
    firstTransliteration:
        'Инна халякналь-инсана мин нутфатин амшаджин набталихи фаджаальнаху самиан басыра',
    firstMeaning:
        'Мы создали человека из смешанной капли, испытывая его, и сделали слышащим и видящим',
    secondAyahNumber: 5594,
    secondArabic:
        'إِنَّا هَدَيْنَٰهُ ٱلسَّبِيلَ إِمَّا شَاكِرًۭا وَإِمَّا كَفُورًا',
    secondTransliteration: 'Инна хадайнахус-сабиля имма шакиран ва имма кафура',
    secondMeaning: 'Мы указали ему путь: быть благодарным или неблагодарным',
    listeningAnswers: [
      'Человек создан без испытания',
      'Человек создан, наделён слухом и зрением для испытания',
      'Человек не способен видеть знамения'
    ],
    listeningCorrectIndex: 1,
    orderQuestion: 'Собери аят о показанном пути',
    orderTokens: [
      'إِنَّا',
      'هَدَيْنَٰهُ',
      'ٱلسَّبِيلَ',
      'إِمَّا',
      'شَاكِرًۭا',
      'وَإِمَّا',
      'كَفُورًا'
    ],
    extraTokens: ['غَافِلًۭا'],
    meaningQuestion: 'Какие способности отдельно названы в аяте 2?',
    meaningAnswers: ['Слух и зрение', 'Сила и скорость', 'Память и письмо'],
    meaningCorrectIndex: 0,
    meaningHint: 'Аят называет два способа воспринимать окружающий мир.',
    reasoningQuestion:
        'Почему после способностей в аяте 2 говорится о пути в аяте 3?',
    reasoningAnswers: [
      'Способности помогают распознать руководство и сделать выбор',
      'Руководство делает способности ненужными',
      'Выбор не связан с испытанием'
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Свяжи инструменты восприятия, испытание и нравственный ответ.',
  ),
  _JuzTabarakSpec(
    id: 'q_mursalat_1',
    title: 'Аль-Мурсалят',
    subtitle: 'Аяты 20-21: происхождение человека',
    order: 59,
    sourceUrl: 'https://quran.com/77',
    sourceRefs: ['Коран 77:20-23'],
    overview:
        'Сура многократно возвращает слушателя к ответственности перед Днём различения. Аяты 20-23 приводят близкое человеку доказательство: его создание и развитие происходят по точной мере.',
    firstAyahNumber: 5642,
    firstArabic: 'أَلَمْ نَخْلُقكُّم مِّن مَّآءٍۢ مَّهِينٍۢ',
    firstTransliteration: 'Алям нахлюккум мин маин махин',
    firstMeaning: 'Разве Мы не создали вас из презренной жидкости?',
    secondAyahNumber: 5643,
    secondArabic: 'فَجَعَلْنَٰهُ فِى قَرَارٍۢ مَّكِينٍ',
    secondTransliteration: 'Фаджаальнаху фи карарин макин',
    secondMeaning: 'И поместили её в надёжном месте',
    listeningAnswers: [
      'Разве Мы не создали вас из жидкости?',
      'Разве Мы не сделали землю ровной?',
      'Разве не пришло к вам ясное знамение?'
    ],
    listeningCorrectIndex: 0,
    orderQuestion: 'Собери продолжение о надёжном месте',
    orderTokens: ['فَجَعَلْنَٰهُ', 'فِى', 'قَرَارٍۢ', 'مَّكِينٍ'],
    extraTokens: ['مَّهِينٍۢ'],
    meaningQuestion: 'Для чего сура напоминает человеку о его происхождении?',
    meaningAnswers: [
      'Чтобы показать точность создания и способность Аллаха воскресить',
      'Чтобы отрицать ответственность',
      'Чтобы сравнить богатство людей'
    ],
    meaningCorrectIndex: 0,
    meaningHint:
        'Вспомни общую тему суры: обещанный День и доказательства могущества.',
    reasoningQuestion:
        'Как слова «по известной мере» из продолжения усиливают смысл аятов?',
    reasoningAnswers: [
      'Создание представлено целенаправленным и точно определённым',
      'Развитие человека показано случайным',
      'Мера относится только к имуществу'
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Сопоставь надёжное место, установленный срок и меру.',
  ),
];
