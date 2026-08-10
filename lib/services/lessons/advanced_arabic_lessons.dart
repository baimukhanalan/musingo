import '../../models/lesson.dart';

const _sourceRefs = ['Учебная программа Muslingo: арабское чтение'];

/// Six practical lessons that move the learner from isolated letters to
/// connected Quranic phrases. Each lesson keeps the same rich loop as the
/// Quran path: explanation, listening, reconstruction, reasoning and speech.
final List<Lesson> advancedArabicLessons = _specs
    .map(
      (spec) => Lesson(
        id: spec.id,
        title: spec.title,
        subtitle: spec.subtitle,
        course: CourseType.arabic,
        order: spec.order,
        xpReward: 30,
        steps: [
          LessonStep(
            id: '${spec.id}_intro',
            type: LessonStepType.text,
            arabicText: spec.displayArabic,
            russianText: spec.explanation,
            sourceRefs: _sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_audio',
            type: LessonStepType.audio,
            arabicText: spec.sampleArabic,
            transliteration: spec.transliteration,
            russianText: spec.sampleMeaning,
            sourceRefs: _sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_listen',
            type: LessonStepType.listenChoice,
            arabicText: spec.sampleArabic,
            question: 'Прослушай и выбери точное чтение или смысл',
            answers: spec.listeningAnswers,
            correctAnswerIndex: spec.listeningCorrectIndex,
            explanation: spec.listeningHint,
            sourceRefs: _sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_order',
            type: LessonStepType.wordOrder,
            question: spec.orderQuestion,
            russianText: spec.sampleMeaning,
            orderTokens: spec.orderTokens,
            extraTokens: spec.extraTokens,
            sourceRefs: _sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_rule',
            type: LessonStepType.question,
            question: spec.ruleQuestion,
            answers: spec.ruleAnswers,
            correctAnswerIndex: spec.ruleCorrectIndex,
            explanation: spec.ruleHint,
            sourceRefs: _sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_reasoning',
            type: LessonStepType.question,
            question: spec.reasoningQuestion,
            answers: spec.reasoningAnswers,
            correctAnswerIndex: spec.reasoningCorrectIndex,
            explanation: spec.reasoningHint,
            sourceRefs: _sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_matching',
            type: LessonStepType.matching,
            question: spec.matchingQuestion,
            matchPairs: spec.matchPairs,
            sourceRefs: _sourceRefs,
          ),
          LessonStep(
            id: '${spec.id}_speak',
            type: LessonStepType.speak,
            arabicText: spec.sampleArabic,
            transliteration: spec.transliteration,
            russianText: 'Сначала прослушай образец, затем произнеси фразу.',
            speechMode: SpeechMode.arabic,
            passScore: 65,
            sourceRefs: _sourceRefs,
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
  final String displayArabic;
  final String explanation;
  final String sampleArabic;
  final String transliteration;
  final String sampleMeaning;
  final List<String> listeningAnswers;
  final int listeningCorrectIndex;
  final String listeningHint;
  final String orderQuestion;
  final List<String> orderTokens;
  final List<String> extraTokens;
  final String ruleQuestion;
  final List<String> ruleAnswers;
  final int ruleCorrectIndex;
  final String ruleHint;
  final String reasoningQuestion;
  final List<String> reasoningAnswers;
  final int reasoningCorrectIndex;
  final String reasoningHint;
  final String matchingQuestion;
  final List<LessonMatchPair> matchPairs;

  const _Spec({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.order,
    required this.displayArabic,
    required this.explanation,
    required this.sampleArabic,
    required this.transliteration,
    required this.sampleMeaning,
    required this.listeningAnswers,
    required this.listeningCorrectIndex,
    required this.listeningHint,
    required this.orderQuestion,
    required this.orderTokens,
    required this.extraTokens,
    required this.ruleQuestion,
    required this.ruleAnswers,
    required this.ruleCorrectIndex,
    required this.ruleHint,
    required this.reasoningQuestion,
    required this.reasoningAnswers,
    required this.reasoningCorrectIndex,
    required this.reasoningHint,
    required this.matchingQuestion,
    required this.matchPairs,
  });
}

const List<_Spec> _specs = [
  _Spec(
    id: 'a17',
    title: 'Четыре формы буквы',
    subtitle: 'Изолированная, начальная, средняя и конечная',
    order: 17,
    displayArabic: 'ب  بـ  ـبـ  ـب',
    explanation:
        'Одна буква меняет внешний вид в зависимости от позиции, но сохраняет свой звук. Сравни четыре формы ب и найди общий корпус и точку.',
    sampleArabic: 'بَابٌ',
    transliteration: 'баабун',
    sampleMeaning: 'дверь',
    listeningAnswers: ['баабун', 'таабун', 'наабун'],
    listeningCorrectIndex: 0,
    listeningHint: 'Следи за первой и последней формой ب.',
    orderQuestion: 'Собери слово «дверь» из двух читаемых частей',
    orderTokens: ['بَا', 'بٌ'],
    extraTokens: ['تٌ'],
    ruleQuestion: 'Что остаётся неизменным у четырёх форм одной буквы?',
    ruleAnswers: [
      'Основной звук буквы',
      'Количество точек у всех букв',
      'Направление чтения'
    ],
    ruleCorrectIndex: 0,
    ruleHint: 'Форма зависит от позиции, а не создаёт новую букву.',
    reasoningQuestion:
        'Почему конечная форма ـب не читается как отдельная новая буква?',
    reasoningAnswers: [
      'Это та же ب, соединённая с предыдущей буквой',
      'Потому что у неё нет звука',
      'Потому что конечные буквы всегда пропускаются',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Сравни точку и основу всех четырёх начертаний.',
    matchingQuestion: 'Соедини форму и позицию',
    matchPairs: [
      LessonMatchPair(prompt: 'ب', answer: 'изолированная'),
      LessonMatchPair(prompt: 'بـ', answer: 'начальная'),
      LessonMatchPair(prompt: 'ـبـ', answer: 'средняя'),
      LessonMatchPair(prompt: 'ـب', answer: 'конечная'),
    ],
  ),
  _Spec(
    id: 'a18',
    title: 'Буквы, которые разрывают связь',
    subtitle: 'ا د ذ ر ز و не соединяются слева',
    order: 18,
    displayArabic: 'ا  د  ذ  ر  ز  و',
    explanation:
        'Эти шесть букв принимают соединение справа, но не передают его следующей букве. Поэтому внутри слова после них появляется видимый разрыв.',
    sampleArabic: 'وَرْدٌ',
    transliteration: 'вардун',
    sampleMeaning: 'роза',
    listeningAnswers: ['вардун', 'бардун', 'зайдун'],
    listeningCorrectIndex: 0,
    listeningHint: 'Начало даёт و с фатхой, затем ر с сукуном.',
    orderQuestion: 'Собери слово «роза» по читаемым частям',
    orderTokens: ['وَ', 'رْ', 'دٌ'],
    extraTokens: ['بْ'],
    ruleQuestion: 'Что происходит после буквы ر внутри слова?',
    ruleAnswers: [
      'Следующая буква начинается без соединения слева',
      'Следующая буква исчезает',
      'Слово читается справа налево второй раз',
    ],
    ruleCorrectIndex: 0,
    ruleHint: 'ر соединяется с предыдущей буквой, но не со следующей.',
    reasoningQuestion: 'В слове دَرَسَ почему после первой د виден разрыв?',
    reasoningAnswers: [
      'د не соединяется с буквой слева от неё по ходу письма',
      'ر всегда пишется отдельно от всех букв',
      'Фатха запрещает соединение',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Причина в самой букве د, а не в огласовке.',
    matchingQuestion: 'Соедини букву и свойство',
    matchPairs: [
      LessonMatchPair(prompt: 'ا', answer: 'не соединяется со следующей'),
      LessonMatchPair(prompt: 'د', answer: 'не соединяется со следующей'),
      LessonMatchPair(prompt: 'ب', answer: 'соединяется с обеих сторон'),
    ],
  ),
  _Spec(
    id: 'a19',
    title: 'Солнечные и лунные буквы',
    subtitle: 'Как читать артикль ال',
    order: 19,
    displayArabic: 'الشَّمْسُ  الْقَمَرُ',
    explanation:
        'Перед солнечной буквой ل артикля не звучит, а следующая буква получает шадду. Перед лунной буквой ل читается ясно.',
    sampleArabic: 'الشَّمْسُ وَالْقَمَرُ',
    transliteration: 'аш-шамсу валь-камару',
    sampleMeaning: 'солнце и луна',
    listeningAnswers: [
      'аш-шамсу валь-камару',
      'аль-шамсу ва-камару',
      'аш-камару валь-шамсу'
    ],
    listeningCorrectIndex: 0,
    listeningHint:
        'В الشَّمْسُ услышишь удвоенное «ш», в الْقَمَرُ — ясное «ль».',
    orderQuestion: 'Собери сочетание «солнце и луна»',
    orderTokens: ['الشَّمْسُ', 'وَ', 'الْقَمَرُ'],
    extraTokens: ['النُّورُ'],
    ruleQuestion: 'Почему الشَّمْسُ читается «аш-шамсу»?',
    ruleAnswers: [
      'ش — солнечная: ل не звучит, а ش удваивается',
      'В слове нет артикля',
      'Любая ش всегда удваивается',
    ],
    ruleCorrectIndex: 0,
    ruleHint: 'Обрати внимание на шадду над ش.',
    reasoningQuestion:
        'Как по записи понять, что в الْقَمَرُ нужно произнести ل?',
    reasoningAnswers: [
      'Над ل стоит сукун, а следующая ق без шадды',
      'ق является солнечной буквой',
      'В конце слова стоит дамма',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Сравни знаки над ل и первой буквой корня.',
    matchingQuestion: 'Соедини слово и способ чтения артикля',
    matchPairs: [
      LessonMatchPair(prompt: 'الشَّمْسُ', answer: 'ل не произносится'),
      LessonMatchPair(prompt: 'الْقَمَرُ', answer: 'ل произносится'),
      LessonMatchPair(prompt: 'النُّورُ', answer: 'ن произносится с шаддой'),
    ],
  ),
  _Spec(
    id: 'a20',
    title: 'Коранические слова',
    subtitle: 'Корень, форма и смысл',
    order: 20,
    displayArabic: 'رَبٌّ  رَحْمَةٌ  كِتَابٌ',
    explanation:
        'Учись узнавать частые слова целиком, но продолжай видеть их буквы и огласовки. Это ускоряет чтение без угадывания.',
    sampleArabic: 'كِتَابٌ مُبِينٌ',
    transliteration: 'китаабун мубиинун',
    sampleMeaning: 'ясное писание',
    listeningAnswers: ['ясное писание', 'милосердный Господь', 'прямой путь'],
    listeningCorrectIndex: 0,
    listeningHint: 'كِتَابٌ — книга или писание, مُبِينٌ — ясный.',
    orderQuestion: 'Собери словосочетание «ясное писание»',
    orderTokens: ['كِتَابٌ', 'مُبِينٌ'],
    extraTokens: ['رَحِيمٌ'],
    ruleQuestion: 'Какой признак помогает узнать долгий «аа» в كِتَابٌ?',
    ruleAnswers: ['ا после تَ', 'Касра под ك', 'Танвин в конце'],
    ruleCorrectIndex: 0,
    ruleHint: 'Долгота образуется сочетанием короткой гласной и буквы мадда.',
    reasoningQuestion:
        'Почему полезно узнавать слово целиком, не переставая читать буквы?',
    reasoningAnswers: [
      'Так скорость растёт, а проверка по буквам защищает от угадывания',
      'Тогда огласовки больше не нужны',
      'Любое похожее слово можно считать тем же самым',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Сочетай зрительную память со звуковым разбором.',
    matchingQuestion: 'Соедини слово и базовый смысл',
    matchPairs: [
      LessonMatchPair(prompt: 'رَبٌّ', answer: 'Господь'),
      LessonMatchPair(prompt: 'رَحْمَةٌ', answer: 'милость'),
      LessonMatchPair(prompt: 'كِتَابٌ', answer: 'книга, писание'),
    ],
  ),
  _Spec(
    id: 'a21',
    title: 'Пауза и продолжение',
    subtitle: 'Как окончание меняется при остановке',
    order: 21,
    displayArabic: 'رَحِيمٌ  ←  رَحِيمْ',
    explanation:
        'При остановке конечная краткая огласовка обычно не произносится: رَحِيمٌ в связном чтении и رَحِيمْ при паузе. Это базовая учебная модель, не полный курс правил остановки.',
    sampleArabic: 'غَفُورٌ رَحِيمٌ',
    transliteration: 'гафуурун рахиим',
    sampleMeaning: 'Прощающий, Милосердный',
    listeningAnswers: ['гафуурун рахиим', 'гафур рахаама', 'гафииран рахуум'],
    listeningCorrectIndex: 0,
    listeningHint:
        'Первое слово связано со вторым, на втором сделана остановка.',
    orderQuestion: 'Собери сочетание двух качеств',
    orderTokens: ['غَفُورٌ', 'رَحِيمٌ'],
    extraTokens: ['كِتَابٌ'],
    ruleQuestion: 'Как учебно прочитать رَحِيمٌ при полной остановке?',
    ruleAnswers: ['рахиим', 'рахиимун', 'рахиима'],
    ruleCorrectIndex: 0,
    ruleHint: 'При паузе конечный танвин не звучит, долгий слог сохраняется.',
    reasoningQuestion:
        'Почему в одной строке первое слово сохраняет танвин, а второе нет?',
    reasoningAnswers: [
      'Первое связано со следующим, на втором заканчивается фраза',
      'Танвин читается только у первого слова любой строки',
      'Второе слово написано без огласовок',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Решает место остановки, а не порядковый номер слова.',
    matchingQuestion: 'Соедини режим и чтение',
    matchPairs: [
      LessonMatchPair(prompt: 'رَحِيمٌ ...', answer: 'рахиимун — продолжаем'),
      LessonMatchPair(prompt: 'رَحِيمٌ ۝', answer: 'рахиим — останавливаемся'),
    ],
  ),
  _Spec(
    id: 'a22',
    title: 'Читаем смысловыми группами',
    subtitle: 'Фраза без пословного угадывания',
    order: 22,
    displayArabic: 'هَٰذَا  كِتَابٌ  مُبِينٌ',
    explanation:
        'Сначала найди указательное слово, затем предмет и его признак. Чтение смысловыми группами помогает удерживать порядок и понимать фразу целиком.',
    sampleArabic: 'هَٰذَا كِتَابٌ مُبِينٌ',
    transliteration: 'хааза китаабун мубиинун',
    sampleMeaning: 'это — ясное писание',
    listeningAnswers: [
      'это — ясное писание',
      'эта милость близка',
      'тот путь прямой'
    ],
    listeningCorrectIndex: 0,
    listeningHint: 'هَٰذَا указывает на предмет, مُبِينٌ описывает его.',
    orderQuestion: 'Восстанови естественный порядок фразы',
    orderTokens: ['هَٰذَا', 'كِتَابٌ', 'مُبِينٌ'],
    extraTokens: ['رَحْمَةٌ'],
    ruleQuestion: 'Какую роль выполняет مُبِينٌ?',
    ruleAnswers: [
      'Описывает слово كِتَابٌ',
      'Заменяет указательное слово',
      'Отрицает всю фразу'
    ],
    ruleCorrectIndex: 0,
    ruleHint: 'Это признак предмета: писание какое? Ясное.',
    reasoningQuestion:
        'Почему вариант مُبِينٌ هَٰذَا كِتَابٌ меняет естественную учебную структуру?',
    reasoningAnswers: [
      'Признак поставлен раньше указания и самого предмета',
      'Арабский всегда читается слева направо',
      'Слово مُبِينٌ может стоять только отдельно',
    ],
    reasoningCorrectIndex: 0,
    reasoningHint: 'Ищи последовательность: указание → предмет → описание.',
    matchingQuestion: 'Соедини слово и роль во фразе',
    matchPairs: [
      LessonMatchPair(prompt: 'هَٰذَا', answer: 'указание: это'),
      LessonMatchPair(prompt: 'كِتَابٌ', answer: 'предмет: писание'),
      LessonMatchPair(prompt: 'مُبِينٌ', answer: 'признак: ясное'),
    ],
  ),
];
