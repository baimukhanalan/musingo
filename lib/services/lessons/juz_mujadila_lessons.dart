import '../../models/lesson.dart';

/// The next Quran-path block: all nine surahs of Juz Al-Mujadila (58-66).
/// Arabic is copied byte-for-byte from the bundled Tanzil Uthmani asset and
/// verified by quran_canonical_asset_test.dart.
final List<Lesson> juzMujadilaLessons = _specs
    .map(
      (spec) => Lesson(
        id: spec.id,
        title: spec.title,
        subtitle: spec.subtitle,
        course: CourseType.quran,
        order: spec.order,
        sourceUrl: 'https://quran.com/${spec.surah}',
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
            quranGlobalAyahNumber: spec.firstGlobal,
            arabicText: spec.firstArabic,
            russianText: spec.firstMeaning,
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_audio_2',
            type: LessonStepType.audio,
            quranGlobalAyahNumber: spec.secondGlobal,
            arabicText: spec.secondArabic,
            russianText: spec.secondMeaning,
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_listen',
            type: LessonStepType.listenChoice,
            quranGlobalAyahNumber: spec.firstGlobal,
            arabicText: spec.firstArabic,
            question: 'Прослушай аят и выбери наиболее точный смысл',
            answers: spec.listeningAnswers,
            correctAnswerIndex: spec.listeningCorrectIndex,
            explanation:
                'Сначала найди ключевую мысль аята, затем исключи близкие, но неточные варианты.',
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_order',
            type: LessonStepType.wordOrder,
            question: spec.orderQuestion,
            russianText: spec.orderMeaning,
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
            question: 'Соедини ключевую часть аята с её смыслом',
            matchPairs: [
              LessonMatchPair(
                prompt: spec.firstKey,
                answer: spec.firstMeaning,
              ),
              LessonMatchPair(
                prompt: spec.secondKey,
                answer: spec.secondMeaning,
              ),
            ],
            sourceRefs: spec.sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_speak',
            type: LessonStepType.speak,
            quranGlobalAyahNumber: spec.secondGlobal,
            arabicText: spec.secondArabic,
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

class _Spec {
  final String id;
  final String title;
  final String subtitle;
  final int order;
  final int surah;
  final List<String> sourceRefs;
  final String overview;
  final int firstGlobal;
  final String firstArabic;
  final String firstKey;
  final String firstMeaning;
  final int secondGlobal;
  final String secondArabic;
  final String secondKey;
  final String secondMeaning;
  final List<String> listeningAnswers;
  final int listeningCorrectIndex;
  final String orderQuestion;
  final String orderMeaning;
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

  const _Spec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.order,
    required this.surah,
    required this.sourceRefs,
    required this.overview,
    required this.firstGlobal,
    required this.firstArabic,
    required this.firstKey,
    required this.firstMeaning,
    required this.secondGlobal,
    required this.secondArabic,
    required this.secondKey,
    required this.secondMeaning,
    required this.listeningAnswers,
    required this.listeningCorrectIndex,
    required this.orderQuestion,
    required this.orderMeaning,
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

const List<_Spec> _specs = [
  _Spec(
    id: 'q_mujadila_1',
    title: 'Аль-Муджадила',
    subtitle: 'Аяты 1 и 11: услышанный голос и знание',
    order: 60,
    surah: 58,
    sourceRefs: ['Коран 58:1', 'Коран 58:11'],
    overview:
        'Начало суры показывает, что обращение человека не остаётся неуслышанным. Аят 11 связывает уважительное поведение в собрании с верой и ценностью знания.',
    firstGlobal: 5105,
    firstArabic:
        'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ قَدْ سَمِعَ ٱللَّهُ قَوْلَ ٱلَّتِى تُجَٰدِلُكَ فِى زَوْجِهَا وَتَشْتَكِىٓ إِلَى ٱللَّهِ وَٱللَّهُ يَسْمَعُ تَحَاوُرَكُمَآ ۚ إِنَّ ٱللَّهَ سَمِيعٌۢ بَصِيرٌ',
    firstKey: 'قَدْ سَمِعَ ٱللَّهُ',
    firstMeaning: 'Аллах услышал обращение женщины и её разговор',
    secondGlobal: 5115,
    secondArabic:
        'يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوٓا۟ إِذَا قِيلَ لَكُمْ تَفَسَّحُوا۟ فِى ٱلْمَجَٰلِسِ فَٱفْسَحُوا۟ يَفْسَحِ ٱللَّهُ لَكُمْ ۖ وَإِذَا قِيلَ ٱنشُزُوا۟ فَٱنشُزُوا۟ يَرْفَعِ ٱللَّهُ ٱلَّذِينَ ءَامَنُوا۟ مِنكُمْ وَٱلَّذِينَ أُوتُوا۟ ٱلْعِلْمَ دَرَجَٰتٍۢ ۚ وَٱللَّهُ بِمَا تَعْمَلُونَ خَبِيرٌۭ',
    secondKey: 'يَرْفَعِ ٱللَّهُ ٱلَّذِينَ ءَامَنُوا۟',
    secondMeaning: 'Аллах возвышает уверовавших и обладателей знания',
    listeningAnswers: [
      'Знание освобождает от уважения к другим',
      'Аллах услышал обращение женщины и её разговор',
      'На собраниях нельзя менять своё место',
    ],
    listeningCorrectIndex: 1,
    orderQuestion: 'Собери начало утверждения о знании и вере',
    orderMeaning: 'Аллах возвышает уверовавших',
    orderTokens: ['يَرْفَعِ', 'ٱللَّهُ', 'ٱلَّذِينَ', 'ءَامَنُوا۟'],
    extraTokens: ['تَفَسَّحُوا۟'],
    meaningQuestion: 'Что требуется, когда просят освободить место?',
    meaningAnswers: [
      'Сделать вид, что просьбы не было',
      'Уступить пространство другим',
      'Сразу покинуть любое собрание',
    ],
    meaningCorrectIndex: 1,
    meaningHint: 'Аят соединяет знание с конкретным уважительным действием.',
    reasoningQuestion: 'Что объединяет два выбранных аята?',
    reasoningAnswers: [
      'Ценность голоса человека, уважения и знания',
      'Запрет задавать вопросы',
      'Преимущество положения над знанием',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Сопоставь услышанную жалобу, поведение в собрании и возвышение обладателей знания.',
  ),
  _Spec(
    id: 'q_hashr_1',
    title: 'Аль-Хашр',
    subtitle: 'Аяты 9-10: щедрость и чистое сердце',
    order: 61,
    surah: 59,
    sourceRefs: ['Коран 59:9-10'],
    overview:
        'Эти аяты показывают две стороны братства: отдавать предпочтение нуждающемуся и просить, чтобы в сердце не оставалось неприязни к верующим.',
    firstGlobal: 5135,
    firstArabic:
        'وَٱلَّذِينَ تَبَوَّءُو ٱلدَّارَ وَٱلْإِيمَٰنَ مِن قَبْلِهِمْ يُحِبُّونَ مَنْ هَاجَرَ إِلَيْهِمْ وَلَا يَجِدُونَ فِى صُدُورِهِمْ حَاجَةًۭ مِّمَّآ أُوتُوا۟ وَيُؤْثِرُونَ عَلَىٰٓ أَنفُسِهِمْ وَلَوْ كَانَ بِهِمْ خَصَاصَةٌۭ ۚ وَمَن يُوقَ شُحَّ نَفْسِهِۦ فَأُو۟لَٰٓئِكَ هُمُ ٱلْمُفْلِحُونَ',
    firstKey: 'وَيُؤْثِرُونَ عَلَىٰٓ أَنفُسِهِمْ',
    firstMeaning: 'Они предпочитают других себе, даже испытывая нужду',
    secondGlobal: 5136,
    secondArabic:
        'وَٱلَّذِينَ جَآءُو مِنۢ بَعْدِهِمْ يَقُولُونَ رَبَّنَا ٱغْفِرْ لَنَا وَلِإِخْوَٰنِنَا ٱلَّذِينَ سَبَقُونَا بِٱلْإِيمَٰنِ وَلَا تَجْعَلْ فِى قُلُوبِنَا غِلًّۭا لِّلَّذِينَ ءَامَنُوا۟ رَبَّنَآ إِنَّكَ رَءُوفٌۭ رَّحِيمٌ',
    secondKey: 'وَلَا تَجْعَلْ فِى قُلُوبِنَا غِلًّۭا',
    secondMeaning: 'Просьба не оставлять в сердцах неприязни к верующим',
    listeningAnswers: [
      'Они откладывают помощь до изобилия',
      'Они избегают переселившихся',
      'Они предпочитают других себе, даже испытывая нужду',
    ],
    listeningCorrectIndex: 2,
    orderQuestion: 'Собери ключевую часть о бескорыстии',
    orderMeaning: 'Они предпочитают других себе',
    orderTokens: ['وَيُؤْثِرُونَ', 'عَلَىٰٓ', 'أَنفُسِهِمْ'],
    extraTokens: ['غِلًّۭا'],
    meaningQuestion: 'От чего просит защитить сердце аят 10?',
    meaningAnswers: ['От знания', 'От неприязни к верующим', 'От щедрости'],
    meaningCorrectIndex: 1,
    meaningHint: 'Ищи внутреннее чувство, противоположное братству.',
    reasoningQuestion: 'Почему щедрость и очищение сердца стоят рядом?',
    reasoningAnswers: [
      'Внешняя помощь укрепляется внутренней доброжелательностью',
      'Помощь делает состояние сердца неважным',
      'Оба аята говорят только об имуществе',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Сравни действие первого аята и молитву второго.',
  ),
  _Spec(
    id: 'q_mumtahanah_1',
    title: 'Аль-Мумтахана',
    subtitle: 'Аяты 8-9: доброта, справедливость и границы',
    order: 62,
    surah: 60,
    sourceRefs: ['Коран 60:8-9'],
    overview:
        'Аяты требуют различать мирное отношение и реальную агрессию. С теми, кто не воюет и не изгоняет, предписаны доброта и справедливость; для преследования проведена граница.',
    firstGlobal: 5158,
    firstArabic:
        'لَّا يَنْهَىٰكُمُ ٱللَّهُ عَنِ ٱلَّذِينَ لَمْ يُقَٰتِلُوكُمْ فِى ٱلدِّينِ وَلَمْ يُخْرِجُوكُم مِّن دِيَٰرِكُمْ أَن تَبَرُّوهُمْ وَتُقْسِطُوٓا۟ إِلَيْهِمْ ۚ إِنَّ ٱللَّهَ يُحِبُّ ٱلْمُقْسِطِينَ',
    firstKey: 'أَن تَبَرُّوهُمْ وَتُقْسِطُوٓا۟ إِلَيْهِمْ',
    firstMeaning: 'Проявлять доброту и справедливость к тем, кто не воюет',
    secondGlobal: 5159,
    secondArabic:
        'إِنَّمَا يَنْهَىٰكُمُ ٱللَّهُ عَنِ ٱلَّذِينَ قَٰتَلُوكُمْ فِى ٱلدِّينِ وَأَخْرَجُوكُم مِّن دِيَٰرِكُمْ وَظَٰهَرُوا۟ عَلَىٰٓ إِخْرَاجِكُمْ أَن تَوَلَّوْهُمْ ۚ وَمَن يَتَوَلَّهُمْ فَأُو۟لَٰٓئِكَ هُمُ ٱلظَّٰلِمُونَ',
    secondKey: 'ٱلَّذِينَ قَٰتَلُوكُمْ فِى ٱلدِّينِ',
    secondMeaning: 'Граница относится к тем, кто воюет и участвует в изгнании',
    listeningAnswers: [
      'Справедливость допустима только внутри своей семьи',
      'Проявлять доброту и справедливость к тем, кто не воюет',
      'Одинаково относиться к мирным людям и агрессорам',
    ],
    listeningCorrectIndex: 1,
    orderQuestion: 'Собери два качества отношения к мирным людям',
    orderMeaning: 'Проявлять к ним доброту и справедливость',
    orderTokens: ['أَن', 'تَبَرُّوهُمْ', 'وَتُقْسِطُوٓا۟', 'إِلَيْهِمْ'],
    extraTokens: ['قَٰتَلُوكُمْ'],
    meaningQuestion: 'Кого прямо описывает аят 8?',
    meaningAnswers: [
      'Тех, кто не воевал и не изгонял',
      'Только близких родственников',
      'Тех, кто участвовал в изгнании',
    ],
    meaningCorrectIndex: 0,
    meaningHint: 'Ответ строится на двух отрицаниях внутри аята.',
    reasoningQuestion: 'Как избежать ошибочного чтения этих двух аятов?',
    reasoningAnswers: [
      'Учитывать различие между мирным отношением и преследованием',
      'Применять запрет второго аята ко всем без различия',
      'Игнорировать призыв к справедливости в первом аяте',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Сравни условия, а не только отдельные слова.',
  ),
  _Spec(
    id: 'q_saff_1',
    title: 'Ас-Сафф',
    subtitle: 'Аяты 2-3: единство слов и поступков',
    order: 63,
    surah: 61,
    sourceRefs: ['Коран 61:2-3'],
    overview:
        'Два коротких аята формулируют сильную проверку искренности: обещание и призыв должны подтверждаться поступком, а не оставаться красивыми словами.',
    firstGlobal: 5165,
    firstArabic:
        'يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ لِمَ تَقُولُونَ مَا لَا تَفْعَلُونَ',
    firstKey: 'لِمَ تَقُولُونَ مَا لَا تَفْعَلُونَ',
    firstMeaning: 'Почему вы говорите то, чего не делаете?',
    secondGlobal: 5166,
    secondArabic:
        'كَبُرَ مَقْتًا عِندَ ٱللَّهِ أَن تَقُولُوا۟ مَا لَا تَفْعَلُونَ',
    secondKey: 'أَن تَقُولُوا۟ مَا لَا تَفْعَلُونَ',
    secondMeaning: 'Тяжко говорить то, что не подтверждается делом',
    listeningAnswers: [
      'Почему вы говорите то, чего не делаете?',
      'Почему вы не записываете каждое слово?',
      'Почему поступок важнее намерения во всех случаях?',
    ],
    listeningCorrectIndex: 0,
    orderQuestion: 'Восстанови вопрос аята 2',
    orderMeaning: 'Почему вы говорите то, чего не делаете?',
    orderTokens: ['لِمَ', 'تَقُولُونَ', 'مَا', 'لَا', 'تَفْعَلُونَ'],
    extraTokens: ['تَعْلَمُونَ'],
    meaningQuestion: 'Какой разрыв критикуют аяты?',
    meaningAnswers: [
      'Между словом и поступком',
      'Между чтением и письмом',
      'Между работой и отдыхом',
    ],
    meaningCorrectIndex: 0,
    meaningHint: 'Повторяющаяся конструкция противопоставляет два глагола.',
    reasoningQuestion: 'Как применить смысл без поспешного осуждения других?',
    reasoningAnswers: [
      'Сначала проверять собственные обещания и действия',
      'Искать чужие ошибки и публиковать их',
      'Перестать давать любые обещания',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Аят обращён к верующим во множественном числе, включая читателя.',
  ),
  _Spec(
    id: 'q_jumuah_1',
    title: 'Аль-Джумуа',
    subtitle: 'Аяты 9-10: молитва, труд и поминание',
    order: 64,
    surah: 62,
    sourceRefs: ['Коран 62:9-10'],
    overview:
        'Пятничный призыв временно меняет приоритет: торговлю оставляют ради молитвы. После неё разрешено возвращаться к делам, продолжая часто поминать Аллаха.',
    firstGlobal: 5186,
    firstArabic:
        'يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوٓا۟ إِذَا نُودِىَ لِلصَّلَوٰةِ مِن يَوْمِ ٱلْجُمُعَةِ فَٱسْعَوْا۟ إِلَىٰ ذِكْرِ ٱللَّهِ وَذَرُوا۟ ٱلْبَيْعَ ۚ ذَٰلِكُمْ خَيْرٌۭ لَّكُمْ إِن كُنتُمْ تَعْلَمُونَ',
    firstKey: 'فَٱسْعَوْا۟ إِلَىٰ ذِكْرِ ٱللَّهِ',
    firstMeaning: 'На пятничный призыв устремляются к поминанию Аллаха',
    secondGlobal: 5187,
    secondArabic:
        'فَإِذَا قُضِيَتِ ٱلصَّلَوٰةُ فَٱنتَشِرُوا۟ فِى ٱلْأَرْضِ وَٱبْتَغُوا۟ مِن فَضْلِ ٱللَّهِ وَٱذْكُرُوا۟ ٱللَّهَ كَثِيرًۭا لَّعَلَّكُمْ تُفْلِحُونَ',
    secondKey: 'وَٱذْكُرُوا۟ ٱللَّهَ كَثِيرًۭا',
    secondMeaning: 'После молитвы ищут удел и продолжают часто поминать Аллаха',
    listeningAnswers: [
      'После призыва нужно ускорить торговлю',
      'Работа полностью запрещена по пятницам',
      'На пятничный призыв устремляются к поминанию Аллаха',
    ],
    listeningCorrectIndex: 2,
    orderQuestion: 'Собери ключевой призыв аята 9',
    orderMeaning: 'Устремляйтесь к поминанию Аллаха',
    orderTokens: ['فَٱسْعَوْا۟', 'إِلَىٰ', 'ذِكْرِ', 'ٱللَّهِ'],
    extraTokens: ['ٱلْبَيْعَ'],
    meaningQuestion: 'Что происходит после завершения молитвы?',
    meaningAnswers: [
      'Можно расходиться по земле и искать милость Аллаха',
      'Любая работа остаётся запрещённой',
      'Поминание Аллаха прекращается',
    ],
    meaningCorrectIndex: 0,
    meaningHint: 'Аят 10 начинается условием «когда молитва завершится».',
    reasoningQuestion: 'Как два аята выстраивают приоритеты?',
    reasoningAnswers: [
      'Молитва имеет своё время, а труд продолжается вместе с поминанием',
      'Труд всегда выше молитвы',
      'Духовная жизнь исключает повседневные дела',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Не вырывай один аят из пары: сначала остановка, затем продолжение дел.',
  ),
  _Spec(
    id: 'q_munafiqun_1',
    title: 'Аль-Мунафикун',
    subtitle: 'Аяты 9-10: внимание и действие без отсрочки',
    order: 65,
    surah: 63,
    sourceRefs: ['Коран 63:9-10'],
    overview:
        'Имущество и семья названы возможными отвлечениями, если вытесняют поминание. Следующий аят призывает расходовать из дарованного до момента, когда сожаление уже не исправит упущенное.',
    firstGlobal: 5197,
    firstArabic:
        'يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ لَا تُلْهِكُمْ أَمْوَٰلُكُمْ وَلَآ أَوْلَٰدُكُمْ عَن ذِكْرِ ٱللَّهِ ۚ وَمَن يَفْعَلْ ذَٰلِكَ فَأُو۟لَٰٓئِكَ هُمُ ٱلْخَٰسِرُونَ',
    firstKey: 'لَا تُلْهِكُمْ أَمْوَٰلُكُمْ وَلَآ أَوْلَٰدُكُمْ',
    firstMeaning: 'Не позволяйте имуществу и детям отвлекать от поминания',
    secondGlobal: 5198,
    secondArabic:
        'وَأَنفِقُوا۟ مِن مَّا رَزَقْنَٰكُم مِّن قَبْلِ أَن يَأْتِىَ أَحَدَكُمُ ٱلْمَوْتُ فَيَقُولَ رَبِّ لَوْلَآ أَخَّرْتَنِىٓ إِلَىٰٓ أَجَلٍۢ قَرِيبٍۢ فَأَصَّدَّقَ وَأَكُن مِّنَ ٱلصَّٰلِحِينَ',
    secondKey: 'وَأَنفِقُوا۟ مِن مَّا رَزَقْنَٰكُم',
    secondMeaning: 'Расходуйте из дарованного до прихода смерти',
    listeningAnswers: [
      'Имущество само по себе запрещено',
      'Не позволяйте имуществу и детям отвлекать от поминания',
      'Семья освобождает от ответственности',
    ],
    listeningCorrectIndex: 1,
    orderQuestion: 'Собери призыв к своевременной щедрости',
    orderMeaning: 'Расходуйте из того, чем Мы вас наделили',
    orderTokens: ['وَأَنفِقُوا۟', 'مِن', 'مَّا', 'رَزَقْنَٰكُم'],
    extraTokens: ['أَمْوَٰلُكُمْ'],
    meaningQuestion: 'В чём опасность, названная в аяте 9?',
    meaningAnswers: [
      'В самих детях и имуществе',
      'В отвлечении от поминания Аллаха',
      'В любом планировании будущего',
    ],
    meaningCorrectIndex: 1,
    meaningHint:
        'Аят критикует не дар, а то, что он начинает делать с вниманием.',
    reasoningQuestion: 'Почему аят 10 добавляет тему отсрочки?',
    reasoningAnswers: [
      'Чтобы побудить к доброму действию до необратимого сожаления',
      'Чтобы обещать человеку дополнительное время',
      'Чтобы запретить заботиться о семье',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Сравни возможность действовать сейчас и просьбу вернуть время позже.',
  ),
  _Spec(
    id: 'q_taghabun_1',
    title: 'Ат-Тагабун',
    subtitle: 'Аяты 11 и 15: испытание и наставление сердца',
    order: 66,
    surah: 64,
    sourceRefs: ['Коран 64:11', 'Коран 64:15'],
    overview:
        'Сура учит смотреть на испытание без упрощений: трудность происходит с дозволения Аллаха, вера направляет сердце, а любимые дары могут стать проверкой приоритетов.',
    firstGlobal: 5210,
    firstArabic:
        'مَآ أَصَابَ مِن مُّصِيبَةٍ إِلَّا بِإِذْنِ ٱللَّهِ ۗ وَمَن يُؤْمِنۢ بِٱللَّهِ يَهْدِ قَلْبَهُۥ ۚ وَٱللَّهُ بِكُلِّ شَىْءٍ عَلِيمٌۭ',
    firstKey: 'وَمَن يُؤْمِنۢ بِٱللَّهِ يَهْدِ قَلْبَهُۥ',
    firstMeaning: 'Вера в Аллаха становится причиной наставления сердца',
    secondGlobal: 5214,
    secondArabic:
        'إِنَّمَآ أَمْوَٰلُكُمْ وَأَوْلَٰدُكُمْ فِتْنَةٌۭ ۚ وَٱللَّهُ عِندَهُۥٓ أَجْرٌ عَظِيمٌۭ',
    secondKey: 'أَمْوَٰلُكُمْ وَأَوْلَٰدُكُمْ فِتْنَةٌۭ',
    secondMeaning: 'Имущество и дети могут быть испытанием',
    listeningAnswers: [
      'Вера гарантирует отсутствие трудностей',
      'Любая трудность означает наказание',
      'Вера в Аллаха становится причиной наставления сердца',
    ],
    listeningCorrectIndex: 2,
    orderQuestion: 'Собери часть о наставлении сердца',
    orderMeaning: 'Кто верует в Аллаха — Он наставляет его сердце',
    orderTokens: ['وَمَن', 'يُؤْمِنۢ', 'بِٱللَّهِ', 'يَهْدِ', 'قَلْبَهُۥ'],
    extraTokens: ['فِتْنَةٌۭ'],
    meaningQuestion: 'Что аят 15 говорит об имуществе и детях?',
    meaningAnswers: [
      'Они всегда являются злом',
      'Они могут быть испытанием',
      'Они заменяют ответственность человека',
    ],
    meaningCorrectIndex: 1,
    meaningHint:
        'Слово «фитна» здесь указывает на проверку, а не на отрицание дара.',
    reasoningQuestion: 'Как два аята помогают во время трудности?',
    reasoningAnswers: [
      'Проверять сердце и приоритеты, сохраняя веру',
      'Обещать себе, что испытаний больше не будет',
      'Считать любой дар доказательством превосходства',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint:
        'Свяжи наставление сердца с тем, как человек относится к дарам.',
  ),
  _Spec(
    id: 'q_talaq_1',
    title: 'Ат-Таляк',
    subtitle: 'Аяты 2-3: справедливость, выход и упование',
    order: 67,
    surah: 65,
    sourceRefs: ['Коран 65:2-3'],
    overview:
        'В юридическом контексте развода сура требует достойного поведения и свидетельства, а затем формулирует общий духовный принцип: богобоязненность, выход и упование. Урок не заменяет консультацию специалиста по семейным вопросам.',
    firstGlobal: 5219,
    firstArabic:
        'فَإِذَا بَلَغْنَ أَجَلَهُنَّ فَأَمْسِكُوهُنَّ بِمَعْرُوفٍ أَوْ فَارِقُوهُنَّ بِمَعْرُوفٍۢ وَأَشْهِدُوا۟ ذَوَىْ عَدْلٍۢ مِّنكُمْ وَأَقِيمُوا۟ ٱلشَّهَٰدَةَ لِلَّهِ ۚ ذَٰلِكُمْ يُوعَظُ بِهِۦ مَن كَانَ يُؤْمِنُ بِٱللَّهِ وَٱلْيَوْمِ ٱلْـَٔاخِرِ ۚ وَمَن يَتَّقِ ٱللَّهَ يَجْعَل لَّهُۥ مَخْرَجًۭا',
    firstKey: 'وَمَن يَتَّقِ ٱللَّهَ يَجْعَل لَّهُۥ مَخْرَجًۭا',
    firstMeaning: 'Богобоязненному Аллах создаёт выход',
    secondGlobal: 5220,
    secondArabic:
        'وَيَرْزُقْهُ مِنْ حَيْثُ لَا يَحْتَسِبُ ۚ وَمَن يَتَوَكَّلْ عَلَى ٱللَّهِ فَهُوَ حَسْبُهُۥٓ ۚ إِنَّ ٱللَّهَ بَٰلِغُ أَمْرِهِۦ ۚ قَدْ جَعَلَ ٱللَّهُ لِكُلِّ شَىْءٍۢ قَدْرًۭا',
    secondKey: 'وَمَن يَتَوَكَّلْ عَلَى ٱللَّهِ فَهُوَ حَسْبُهُۥٓ',
    secondMeaning: 'Тому, кто уповает на Аллаха, достаточно Его',
    listeningAnswers: [
      'Любое решение можно принимать без свидетелей',
      'Богобоязненному Аллах создаёт выход',
      'Упование отменяет необходимость правильных действий',
    ],
    listeningCorrectIndex: 1,
    orderQuestion: 'Собери обещание о выходе',
    orderMeaning: 'Кто боится Аллаха — Он создаёт ему выход',
    orderTokens: [
      'وَمَن',
      'يَتَّقِ',
      'ٱللَّهَ',
      'يَجْعَل',
      'لَّهُۥ',
      'مَخْرَجًۭا'
    ],
    extraTokens: ['أَجَلَهُنَّ'],
    meaningQuestion: 'Какое поведение названо в семейном контексте аята 2?',
    meaningAnswers: [
      'Удержать или расстаться достойным образом и призвать свидетелей',
      'Скрыть решение от всех',
      'Действовать только под влиянием эмоций',
    ],
    meaningCorrectIndex: 0,
    meaningHint: 'Смысл упования не отделён от справедливой процедуры.',
    reasoningQuestion: 'Что в этих аятах означает упование?',
    reasoningAnswers: [
      'Действовать правильно и полагаться на Аллаха в результате',
      'Не предпринимать никаких действий',
      'Самостоятельно обещать себе гарантированный исход',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Сначала в аяте названы действия, затем упование.',
  ),
  _Spec(
    id: 'q_tahrim_1',
    title: 'Ат-Тахрим',
    subtitle: 'Аяты 8 и 11: искреннее покаяние и стойкость',
    order: 68,
    surah: 66,
    sourceRefs: ['Коран 66:8', 'Коран 66:11'],
    overview:
        'Сура призывает к искреннему покаянию и приводит пример веры женщины Фараона. Её окружение не определило её выбор: она просила близости к Аллаху и спасения от несправедливости.',
    firstGlobal: 5237,
    firstArabic:
        'يَٰٓأَيُّهَا ٱلَّذِينَ ءَامَنُوا۟ تُوبُوٓا۟ إِلَى ٱللَّهِ تَوْبَةًۭ نَّصُوحًا عَسَىٰ رَبُّكُمْ أَن يُكَفِّرَ عَنكُمْ سَيِّـَٔاتِكُمْ وَيُدْخِلَكُمْ جَنَّٰتٍۢ تَجْرِى مِن تَحْتِهَا ٱلْأَنْهَٰرُ يَوْمَ لَا يُخْزِى ٱللَّهُ ٱلنَّبِىَّ وَٱلَّذِينَ ءَامَنُوا۟ مَعَهُۥ ۖ نُورُهُمْ يَسْعَىٰ بَيْنَ أَيْدِيهِمْ وَبِأَيْمَٰنِهِمْ يَقُولُونَ رَبَّنَآ أَتْمِمْ لَنَا نُورَنَا وَٱغْفِرْ لَنَآ ۖ إِنَّكَ عَلَىٰ كُلِّ شَىْءٍۢ قَدِيرٌۭ',
    firstKey: 'تُوبُوٓا۟ إِلَى ٱللَّهِ تَوْبَةًۭ نَّصُوحًا',
    firstMeaning: 'Обратитесь к Аллаху с искренним покаянием',
    secondGlobal: 5240,
    secondArabic:
        'وَضَرَبَ ٱللَّهُ مَثَلًۭا لِّلَّذِينَ ءَامَنُوا۟ ٱمْرَأَتَ فِرْعَوْنَ إِذْ قَالَتْ رَبِّ ٱبْنِ لِى عِندَكَ بَيْتًۭا فِى ٱلْجَنَّةِ وَنَجِّنِى مِن فِرْعَوْنَ وَعَمَلِهِۦ وَنَجِّنِى مِنَ ٱلْقَوْمِ ٱلظَّٰلِمِينَ',
    secondKey: 'رَبِّ ٱبْنِ لِى عِندَكَ بَيْتًۭا فِى ٱلْجَنَّةِ',
    secondMeaning: 'Жена Фараона попросила дом в Раю возле Аллаха',
    listeningAnswers: [
      'Покаяние нужно откладывать до старости',
      'Обратитесь к Аллаху с искренним покаянием',
      'Окружение полностью определяет веру человека',
    ],
    listeningCorrectIndex: 1,
    orderQuestion: 'Собери призыв к искреннему покаянию',
    orderMeaning: 'Покайтесь перед Аллахом искренним покаянием',
    orderTokens: ['تُوبُوٓا۟', 'إِلَى', 'ٱللَّهِ', 'تَوْبَةًۭ', 'نَّصُوحًا'],
    extraTokens: ['فِرْعَوْنَ'],
    meaningQuestion: 'Почему пример жены Фараона особенно выразителен?',
    meaningAnswers: [
      'Она сохранила веру вопреки несправедливому окружению',
      'Её положение автоматически гарантировало спасение',
      'Она просила только земного богатства',
    ],
    meaningCorrectIndex: 0,
    meaningHint: 'Сопоставь её окружение и содержание её просьбы.',
    reasoningQuestion: 'Что объединяет покаяние и этот пример стойкости?',
    reasoningAnswers: [
      'Личная ответственность обратиться к Аллаху и выбрать верность',
      'Зависимость духовного выбора только от семьи',
      'Невозможность измениться после ошибки',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Оба аята говорят о личном движении к Аллаху.',
  ),
];
