import '../../models/lesson.dart';

part 'tajwid_makharij_lessons.dart';
part 'tajwid_sifat_lessons.dart';
part 'tajwid_rules_lessons.dart';
part 'tajwid_madd_waqf_lessons.dart';

const _courseSource =
    'Understand Al Quran Academy: Learn Tajweed - the Easy Way';
const _courseUrl =
    'https://understandquran.com/courses/learn-tajweed-the-easy-way/';

class _AyahSample {
  final int globalNumber;
  final String reference;
  final String arabic;

  const _AyahSample(this.globalNumber, this.reference, this.arabic);
}

const _fatihah1 = _AyahSample(
  1,
  '1:1',
  'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
);
const _fatihah2 = _AyahSample(
  2,
  '1:2',
  'الْحَمْدُ لِلَّهِ رَبِّ الْعَالَمِينَ',
);
const _fatihah6 = _AyahSample(6, '1:6', 'اهْدِنَا الصِّرَاطَ الْمُسْتَقِيمَ');
const _qadr1 =
    _AyahSample(6126, '97:1', 'إِنَّا أَنْزَلْنَاهُ فِي لَيْلَةِ الْقَدْرِ');
const _qadr3 = _AyahSample(
  6128,
  '97:3',
  'لَيْلَةُ الْقَدْرِ خَيْرٌ مِنْ أَلْفِ شَهْرٍ',
);
const _baqara27 = _AyahSample(
  34,
  '2:27',
  'الَّذِينَ يَنْقُضُونَ عَهْدَ اللَّهِ مِنْ بَعْدِ مِيثَاقِهِ',
);
const _zalzalah7 = _AyahSample(
  6145,
  '99:7',
  'فَمَنْ يَعْمَلْ مِثْقَالَ ذَرَّةٍ خَيْرًا يَرَهُ',
);
const _asr1 = _AyahSample(6177, '103:1', 'وَالْعَصْرِ');
const _fil1 = _AyahSample(
    6189, '105:1', 'أَلَمْ تَرَ كَيْفَ فَعَلَ رَبُّكَ بِأَصْحَابِ الْفِيلِ');
const _fil4 =
    _AyahSample(6192, '105:4', 'تَرْمِيهِمْ بِحِجَارَةٍ مِنْ سِجِّيلٍ');
const _nasr1 =
    _AyahSample(6214, '110:1', 'إِذَا جَاءَ نَصْرُ اللَّهِ وَالْفَتْحُ');
const _masad1 =
    _AyahSample(6217, '111:1', 'تَبَّتْ يَدَا أَبِي لَهَبٍ وَتَبَّ');
const _ikhlas1 = _AyahSample(6222, '112:1', 'قُلْ هُوَ اللَّهُ أَحَدٌ');
const _ikhlas2 = _AyahSample(6223, '112:2', 'اللَّهُ الصَّمَدُ');
const _falaq1 = _AyahSample(6226, '113:1', 'قُلْ أَعُوذُ بِرَبِّ الْفَلَقِ');
const _falaq2 = _AyahSample(6227, '113:2', 'مِنْ شَرِّ مَا خَلَقَ');
const _falaq3 = _AyahSample(6228, '113:3', 'وَمِنْ شَرِّ غَاسِقٍ إِذَا وَقَبَ');
const _falaq4 =
    _AyahSample(6229, '113:4', 'وَمِنْ شَرِّ النَّفَّاثَاتِ فِي الْعُقَدِ');
const _nas1 = _AyahSample(6231, '114:1', 'قُلْ أَعُوذُ بِرَبِّ النَّاسِ');

class _TajwidSpec {
  final String title;
  final String subtitle;
  final String explanation;
  final _AyahSample sample;
  final String listeningFocus;
  final List<String> listeningDistractors;
  final String question;
  final String answer;
  final List<String> distractors;
  final List<LessonMatchPair> pairs;

  const _TajwidSpec({
    required this.title,
    required this.subtitle,
    required this.explanation,
    required this.sample,
    required this.listeningFocus,
    required this.listeningDistractors,
    required this.question,
    required this.answer,
    required this.distractors,
    required this.pairs,
  });
}

final List<Lesson> tajwidLessons = [
  ..._tajwidMakharijSpecs,
  ..._tajwidSifatSpecs,
  ..._tajwidRulesSpecs,
  ..._tajwidMaddWaqfSpecs,
].indexed.map((entry) {
  final order = entry.$1 + 1;
  final spec = entry.$2;
  final id = 'tj${order.toString().padLeft(2, '0')}';
  final refs = <String>[
    _courseSource,
    'Quran ${spec.sample.reference}: https://quran.com/${spec.sample.reference.replaceFirst(':', '/')}',
  ];
  final listenAnswers = _rotatedAnswers(
    spec.listeningFocus,
    spec.listeningDistractors,
    order,
  );
  final quizAnswers = _rotatedAnswers(spec.answer, spec.distractors, order + 1);

  return Lesson(
    id: id,
    title: spec.title,
    subtitle: spec.subtitle,
    course: CourseType.tajwid,
    order: order,
    status: order == 1 ? LessonStatus.available : LessonStatus.locked,
    xpReward: const {16, 24, 36}.contains(order) ? 40 : 30,
    sourceUrl: _courseUrl,
    steps: [
      LessonStep(
        id: '${id}_explain',
        type: LessonStepType.text,
        russianText: spec.explanation,
        explanation: order == 1
            ? 'Образовательная оценка Muslingo не заменяет очную проверку у квалифицированного преподавателя таджвида.'
            : 'Сначала пойми правило, затем найди его в звучащем аяте.',
        sourceRefs: refs,
      ),
      LessonStep(
        id: '${id}_listen',
        type: LessonStepType.audio,
        quranGlobalAyahNumber: spec.sample.globalNumber,
        arabicText: spec.sample.arabic,
        russianText: 'Прослушай аят ${spec.sample.reference} целиком.',
        sourceRefs: refs,
      ),
      LessonStep(
        id: '${id}_recognize',
        type: LessonStepType.listenChoice,
        quranGlobalAyahNumber: spec.sample.globalNumber,
        arabicText: spec.sample.arabic,
        question: 'На чем нужно сосредоточиться в этом примере?',
        answers: listenAnswers.$1,
        correctAnswerIndex: listenAnswers.$2,
        explanation:
            'Не угадывай по названию урока: сначала дослушай весь аят.',
        sourceRefs: refs,
      ),
      LessonStep(
        id: '${id}_rule',
        type: LessonStepType.question,
        question: spec.question,
        answers: quizAnswers.$1,
        correctAnswerIndex: quizAnswers.$2,
        sourceRefs: refs,
      ),
      LessonStep(
        id: '${id}_match',
        type: LessonStepType.matching,
        question: 'Сопоставь термин и его функцию',
        matchPairs: spec.pairs,
        sourceRefs: refs,
      ),
      LessonStep(
        id: '${id}_speak',
        type: LessonStepType.speak,
        quranGlobalAyahNumber: spec.sample.globalNumber,
        arabicText: spec.sample.arabic,
        speechTarget: spec.sample.arabic,
        speechMode: SpeechMode.quran,
        passScore: 75,
        russianText:
            'Еще раз прослушай образец, затем запиши чтение. После результата можно перезаписать попытку.',
        sourceRefs: refs,
      ),
      LessonStep(
        id: '${id}_transfer',
        type: LessonStepType.question,
        question: 'Какое действие точнее всего показывает, что правило понято?',
        answers: const [
          'Услышать признак, объяснить правило и воспроизвести его в чтении',
          'Запомнить только название правила без примера',
          'Читать быстрее, не сравнивая себя с образцом',
        ],
        correctAnswerIndex: 0,
        explanation:
            'В таджвиде знание проверяется слухом, пониманием и практикой вместе.',
        sourceRefs: refs,
      ),
    ],
  );
}).toList(growable: false);

(List<String>, int) _rotatedAnswers(
  String correct,
  List<String> distractors,
  int seed,
) {
  final answers = [correct, ...distractors.take(2)];
  final shift = seed % answers.length;
  final rotated = [...answers.skip(shift), ...answers.take(shift)];
  return (rotated, rotated.indexOf(correct));
}
