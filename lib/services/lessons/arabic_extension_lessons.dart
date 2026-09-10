import '../../models/lesson.dart';

const _sources = ['Muslingo Arabic Reading Curriculum, expert review required'];

final List<Lesson> arabicExtensionLessons = [
  for (var unitIndex = 0; unitIndex < _units.length; unitIndex++)
    for (var phase = 0; phase < 3; phase++)
      _buildLesson(_units[unitIndex], unitIndex, phase),
];

Lesson _buildLesson(_ArabicUnit unit, int unitIndex, int phase) {
  final order = 23 + unitIndex * 3 + phase;
  final phaseTitle = switch (phase) {
    0 => 'Точный звук',
    1 => 'Форма в слове',
    _ => 'Чтение без подсказки',
  };
  final forms =
      '${unit.letter}  ${unit.letter}ـ  ـ${unit.letter}ـ  ـ${unit.letter}';
  return Lesson(
    id: 'a$order',
    title: '${unit.name}: $phaseTitle',
    subtitle: '${unit.word} · ${unit.meaning}',
    course: CourseType.arabic,
    order: order,
    xpReward: phase == 2 ? 35 : 30,
    steps: [
      LessonStep(
        id: 'a${order}_intro',
        type: LessonStepType.text,
        arabicText: phase == 1 ? forms : unit.word,
        transliteration: unit.transliteration,
        russianText: switch (phase) {
          0 =>
            'Сравни ${unit.name} с ${unit.contrastName}. Сначала найди отличие на слух, затем произнеси слово целиком.',
          1 =>
            'Проследи, как ${unit.name} меняет соединение в слове, не меняя основной звук.',
          _ =>
            'Прочитай слово по огласовкам, проверь смысл и только потом слушай образец.',
        },
        sourceRefs: _sources,
      ),
      LessonStep(
        id: 'a${order}_audio',
        type: LessonStepType.audio,
        arabicText: unit.word,
        transliteration: unit.transliteration,
        russianText: unit.meaning,
        sourceRefs: _sources,
      ),
      LessonStep(
        id: 'a${order}_listen',
        type: LessonStepType.listenChoice,
        arabicText: unit.word,
        question: 'Какое чтение точнее передаёт услышанное слово?',
        answers: [
          unit.contrastReading,
          unit.transliteration,
          unit.shortReading
        ],
        correctAnswerIndex: 1,
        explanation: 'Проверь место образования ${unit.name} и длину гласной.',
        sourceRefs: _sources,
      ),
      LessonStep(
        id: 'a${order}_order',
        type: LessonStepType.wordOrder,
        question: 'Собери слово справа налево по читаемым частям',
        russianText: unit.meaning,
        orderTokens: unit.parts,
        extraTokens: [unit.contrastLetter],
        sourceRefs: _sources,
      ),
      LessonStep(
        id: 'a${order}_reason',
        type: LessonStepType.question,
        question: phase == 1
            ? 'Как узнать ${unit.name} после соединения?'
            : 'Почему вариант «${unit.contrastReading}» здесь неверен?',
        answers: phase == 1
            ? [
                'По основному корпусу и точкам буквы',
                'Только по переводу слова',
                'По длине всей строки',
              ]
            : [
                'Он заменяет ${unit.name} на ${unit.contrastName}',
                'Любое чтение допустимо',
                'Потому что слово читается слева направо',
              ],
        correctAnswerIndex: 0,
        explanation: 'Сначала определи букву, затем огласовку и соединение.',
        sourceRefs: _sources,
      ),
      LessonStep(
        id: 'a${order}_match',
        type: LessonStepType.matching,
        question: 'Соедини знак с его ролью',
        matchPairs: [
          LessonMatchPair(prompt: unit.letter, answer: unit.name),
          LessonMatchPair(
              prompt: unit.contrastLetter, answer: unit.contrastName),
          LessonMatchPair(prompt: unit.word, answer: unit.meaning),
        ],
        sourceRefs: _sources,
      ),
      LessonStep(
        id: 'a${order}_speak',
        type: LessonStepType.speak,
        arabicText: unit.word,
        transliteration: unit.transliteration,
        russianText:
            'Сначала прослушай образец. Затем произнеси слово, сохраняя отличие от ${unit.contrastName}.',
        speechMode: SpeechMode.arabic,
        passScore: phase == 2 ? 72 : 66,
        sourceRefs: _sources,
      ),
    ],
  );
}

class _ArabicUnit {
  final String letter;
  final String name;
  final String contrastLetter;
  final String contrastName;
  final String word;
  final String transliteration;
  final String contrastReading;
  final String shortReading;
  final String meaning;
  final List<String> parts;

  const _ArabicUnit(
      this.letter,
      this.name,
      this.contrastLetter,
      this.contrastName,
      this.word,
      this.transliteration,
      this.contrastReading,
      this.shortReading,
      this.meaning,
      this.parts);
}

const _units = <_ArabicUnit>[
  _ArabicUnit('ا', 'Алиф', 'ع', 'Айн', 'آمَنَ', 'аамана', 'аъмана', 'амана',
      'уверовал', ['آ', 'مَ', 'نَ']),
  _ArabicUnit('ب', 'Ба', 'ت', 'Та', 'بَابٌ', 'баабун', 'таабун', 'бабун',
      'дверь', ['بَا', 'بٌ']),
  _ArabicUnit('ت', 'Та', 'ط', 'Та твёрдая', 'تِينٌ', 'тиинун', 'тыинун',
      'тинун', 'инжир', ['تِي', 'نٌ']),
  _ArabicUnit('ث', 'Са', 'س', 'Син', 'ثَوْبٌ', 'саубун', 'саубун с обычным с',
      'сауб', 'одежда', ['ثَوْ', 'بٌ']),
  _ArabicUnit('ج', 'Джим', 'ح', 'Ха', 'جَبَلٌ', 'джабалун', 'хабалун', 'джабал',
      'гора', ['جَ', 'بَ', 'لٌ']),
  _ArabicUnit('ح', 'Ха', 'ه', 'Ха лёгкая', 'حَقٌّ', 'хаккун',
      'хаккун с лёгким х', 'хак', 'истина', ['حَ', 'قٌّ']),
  _ArabicUnit('خ', 'Хо', 'ح', 'Ха', 'خَيْرٌ', 'хайрун', 'хайрун с мягким х',
      'хайр', 'благо', ['خَيْ', 'رٌ']),
  _ArabicUnit('د', 'Даль', 'ذ', 'Заль', 'دِينٌ', 'диинун', 'зиинун', 'динун',
      'религия', ['دِي', 'نٌ']),
  _ArabicUnit('ذ', 'Заль', 'ز', 'Зай', 'ذِكْرٌ', 'зикрун', 'зикрун с обычным з',
      'зикр', 'поминание', ['ذِكْ', 'رٌ']),
  _ArabicUnit('ر', 'Ра', 'ز', 'Зай', 'رَحْمَةٌ', 'рахматун', 'захматун',
      'рахма', 'милость', ['رَحْ', 'مَ', 'ةٌ']),
  _ArabicUnit('ز', 'Зай', 'س', 'Син', 'زَكَاةٌ', 'закаатун', 'сакаатун',
      'закатун', 'закят', ['زَ', 'كَا', 'ةٌ']),
  _ArabicUnit('س', 'Син', 'ص', 'Сад', 'سَلَامٌ', 'салаамун', 'салаамун твёрдо',
      'салам', 'мир', ['سَ', 'لَا', 'مٌ']),
  _ArabicUnit('ش', 'Шин', 'س', 'Син', 'شَمْسٌ', 'шамсун', 'самсун', 'шамс',
      'солнце', ['شَمْ', 'سٌ']),
  _ArabicUnit('ص', 'Сад', 'س', 'Син', 'صَبْرٌ', 'сабрун твёрдо', 'сабрун мягко',
      'сабр', 'терпение', ['صَبْ', 'رٌ']),
  _ArabicUnit('ض', 'Дад', 'د', 'Даль', 'ضُحًى', 'духан', 'духан с обычным д',
      'духа', 'утро', ['ضُ', 'حًى']),
  _ArabicUnit('ط', 'Та твёрдая', 'ت', 'Та', 'طَيِّبٌ', 'таййибун',
      'таййибун мягко', 'тайиб', 'благой', ['طَيِّ', 'بٌ']),
  _ArabicUnit('ظ', 'За твёрдая', 'ز', 'Зай', 'ظُلْمٌ', 'зульмун твёрдо',
      'зульмун мягко', 'зулм', 'несправедливость', ['ظُلْ', 'مٌ']),
  _ArabicUnit('ع', 'Айн', 'ا', 'Алиф', 'عِلْمٌ', 'ильм с айн', 'ильм без айн',
      'ильм', 'знание', ['عِلْ', 'مٌ']),
  _ArabicUnit('غ', 'Гайн', 'خ', 'Хо', 'غَفُورٌ', 'гафуурун', 'хафуурун',
      'гафур', 'прощающий', ['غَ', 'فُو', 'رٌ']),
  _ArabicUnit('ف', 'Фа', 'ق', 'Каф глубокая', 'فَلَاحٌ', 'фалаахун', 'калаахун',
      'фалах', 'успех', ['فَ', 'لَا', 'حٌ']),
  _ArabicUnit('ق', 'Каф глубокая', 'ك', 'Каф', 'قَلْبٌ', 'кальбун глубоко',
      'кальбун мягко', 'кальб', 'сердце', ['قَلْ', 'بٌ']),
  _ArabicUnit('ك', 'Каф', 'ق', 'Каф глубокая', 'كِتَابٌ', 'китаабун',
      'китаабун глубоко', 'китаб', 'книга', ['كِ', 'تَا', 'بٌ']),
  _ArabicUnit('ل', 'Лям', 'ر', 'Ра', 'لَيْلٌ', 'ляйлун', 'райлюн', 'ляйл',
      'ночь', ['لَيْ', 'لٌ']),
  _ArabicUnit('م', 'Мим', 'ن', 'Нун', 'مَاءٌ', 'мааун', 'нааун', 'маун', 'вода',
      ['مَا', 'ءٌ']),
  _ArabicUnit('ن', 'Нун', 'م', 'Мим', 'نُورٌ', 'нуурун', 'мууран', 'нур',
      'свет', ['نُو', 'رٌ']),
  _ArabicUnit('ه', 'Ха лёгкая', 'ح', 'Ха', 'هُدًى', 'худан легко',
      'худан глубоко', 'худа', 'руководство', ['هُ', 'دًى']),
];
