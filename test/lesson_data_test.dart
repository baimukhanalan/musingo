import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/lesson_data.dart';

void main() {
  const juzTabarakIds = <String>[
    'q_mulk_1',
    'q_qalam_1',
    'q_haqqah_1',
    'q_maarij_1',
    'q_nuh_1',
    'q_jinn_1',
    'q_muzzammil_1',
    'q_muddaththir_1',
    'q_qiyamah_1',
    'q_insan_1',
    'q_mursalat_1',
  ];
  const juzMujadilaIds = <String>[
    'q_mujadila_1',
    'q_hashr_1',
    'q_mumtahanah_1',
    'q_saff_1',
    'q_jumuah_1',
    'q_munafiqun_1',
    'q_taghabun_1',
    'q_talaq_1',
    'q_tahrim_1',
  ];
  const advancedArabicIds = <String>[
    'a17',
    'a18',
    'a19',
    'a20',
    'a21',
    'a22',
  ];

  test('curriculum contains exactly 100 ordered lessons', () {
    final courses = LessonData.getCourses();
    expect(courses.expand((course) => course.lessons), hasLength(100));
    expect(LessonData.quranCourse.lessons, hasLength(68));
    expect(LessonData.arabicCourse.lessons, hasLength(22));
    expect(LessonData.rulesCourse.lessons, hasLength(10));

    final quran = LessonData.quranCourse.lessons;
    expect(quran.skip(48).take(11).map((lesson) => lesson.id), juzTabarakIds);
    expect(quran.skip(48).take(11).map((lesson) => lesson.order),
        List<int>.generate(11, (index) => 49 + index));
    expect(quran.skip(59).map((lesson) => lesson.id), juzMujadilaIds);
    expect(quran.skip(59).map((lesson) => lesson.order),
        List<int>.generate(9, (index) => 60 + index));
    expect(
      LessonData.arabicCourse.lessons.skip(16).map((lesson) => lesson.id),
      advancedArabicIds,
    );
  });

  test('every Juz Tabarak lesson follows the rich learning loop', () {
    final lessons = LessonData.quranCourse.lessons
        .where((lesson) => juzTabarakIds.contains(lesson.id));
    const requiredTypes = <LessonStepType>{
      LessonStepType.text,
      LessonStepType.audio,
      LessonStepType.listenChoice,
      LessonStepType.wordOrder,
      LessonStepType.question,
      LessonStepType.matching,
      LessonStepType.speak,
    };

    expect(lessons, hasLength(juzTabarakIds.length));
    for (final lesson in lessons) {
      final types = lesson.steps.map((step) => step.type).toSet();
      expect(types.containsAll(requiredTypes), isTrue, reason: lesson.id);
      expect(lesson.steps, hasLength(9), reason: lesson.id);
      expect(lesson.sourceUrl, startsWith('https://quran.com/'));
      expect(
        lesson.steps.every((step) => step.sourceRefs.isNotEmpty),
        isTrue,
        reason: '${lesson.id}: source metadata is incomplete',
      );
      expect(
        lesson.steps.where((step) => step.type == LessonStepType.question),
        hasLength(2),
      );
    }
  });

  test('new Quran and Arabic lessons follow the rich learning loop', () {
    final ids = <String>{...juzMujadilaIds, ...advancedArabicIds};
    final lessons = LessonData.getCourses()
        .expand((course) => course.lessons)
        .where((lesson) => ids.contains(lesson.id));
    const requiredTypes = <LessonStepType>{
      LessonStepType.text,
      LessonStepType.audio,
      LessonStepType.listenChoice,
      LessonStepType.wordOrder,
      LessonStepType.question,
      LessonStepType.matching,
      LessonStepType.speak,
    };

    expect(lessons, hasLength(ids.length));
    for (final lesson in lessons) {
      final types = lesson.steps.map((step) => step.type).toSet();
      expect(types.containsAll(requiredTypes), isTrue, reason: lesson.id);
      expect(lesson.steps.length, greaterThanOrEqualTo(8), reason: lesson.id);
      expect(
        lesson.steps.every((step) => step.sourceRefs.isNotEmpty),
        isTrue,
        reason: '${lesson.id}: source metadata is incomplete',
      );
    }
  });

  test('Islam foundations course keeps the seven intro lessons in order', () {
    final rules = LessonData.rulesCourse.lessons;

    // Курс «Основы» расширяется, но семь исходных вводных уроков должны
    // оставаться на месте и в том же порядке (первым — доступный).
    expect(rules.length, greaterThanOrEqualTo(7));
    expect(rules.first.status, LessonStatus.available);
    expect(
      rules.map((lesson) => lesson.title),
      containsAllInOrder([
        'Вера и намерение',
        'Что такое Коран',
        'Пророк Мухаммад',
        'Молитва',
        'Чистота и адаб',
        'Как понимать перевод',
        'Как учить суры',
      ]),
    );
    expect(
      rules.every((lesson) => lesson.steps.any(
            (step) => step.type == LessonStepType.question,
          )),
      isTrue,
    );
  });

  test('speech steps expose production scoring targets', () {
    final quranSpeak = LessonData.quranCourse.lessons
        .expand((lesson) => lesson.steps)
        .firstWhere((step) => step.type == LessonStepType.speak);
    final arabicSpeak = LessonData.arabicCourse.lessons
        .expand((lesson) => lesson.steps)
        .firstWhere((step) => step.type == LessonStepType.speak);

    expect(quranSpeak.effectiveSpeechTarget, isNotEmpty);
    expect(quranSpeak.effectivePassScore, 75);
    expect(arabicSpeak.effectiveSpeechTarget, isNotEmpty);
    expect(arabicSpeak.effectivePassScore, 60);
  });

  test('Quran listening lesson audio is mapped to exact unique ayahs', () {
    final audioSteps = LessonData.quranCourse.lessons
        .expand((lesson) => lesson.steps)
        .where((step) => step.type == LessonStepType.audio)
        .toList(growable: false);

    expect(audioSteps, isNotEmpty);
    expect(
      audioSteps.every((step) => step.quranGlobalAyahNumber != null),
      isTrue,
    );

    final audioAyahs = audioSteps
        .map((step) => step.quranGlobalAyahNumber)
        .toList(growable: false);
    expect(audioAyahs.toSet(), hasLength(audioAyahs.length));

    expect(audioAyahs, containsAll(<int>[1, 8, 6222, 6226, 6231]));
  });

  test('logic matching steps have usable pairs', () {
    final matchingSteps = LessonData.getCourses()
        .expand((course) => course.lessons)
        .expand((lesson) => lesson.steps)
        .where((step) => step.type == LessonStepType.matching)
        .toList(growable: false);

    expect(matchingSteps.length, greaterThanOrEqualTo(5));
    for (final step in matchingSteps) {
      expect(step.matchPairs.length, greaterThanOrEqualTo(2));
      expect(
        step.matchPairs.every(
          (pair) =>
              pair.prompt.trim().isNotEmpty && pair.answer.trim().isNotEmpty,
        ),
        isTrue,
      );
    }
  });

  test('new short-surah and arabic lessons are registered in their courses',
      () {
    // These ids must stay in sync, character for character, with the
    // `lessons` Set in server/routes/progress-complete.js — otherwise the
    // backend answers 400 unknown_lesson when the lesson is completed.
    const newQuranIds = <String>[
      'q_asr_1',
      'q_fil_1',
      'q_quraysh_1',
      'q_maun_1',
      'q_kawthar_1',
      'q_kafirun_1',
      'q_nasr_1',
      'q_masad_1',
      'q_review_short_surahs',
    ];
    const newArabicIds = <String>['a4', 'a5', 'a6'];

    final quranIds = LessonData.quranCourse.lessons.map((l) => l.id).toSet();
    final arabicIds = LessonData.arabicCourse.lessons.map((l) => l.id).toSet();

    expect(quranIds.containsAll(newQuranIds), isTrue);
    expect(arabicIds.containsAll(newArabicIds), isTrue);
  });

  test('lesson ids are unique across the whole curriculum', () {
    final ids = LessonData.getCourses()
        .expand((course) => course.lessons)
        .map((lesson) => lesson.id)
        .toList(growable: false);

    expect(ids.toSet(), hasLength(ids.length));
  });

  test('every lesson has non-empty steps and well-formed questions', () {
    final lessons = LessonData.getCourses().expand((course) => course.lessons);

    for (final lesson in lessons) {
      expect(lesson.id.trim(), isNotEmpty);
      expect(lesson.steps, isNotEmpty, reason: '${lesson.id} has no steps');

      for (final step in lesson.steps) {
        if (step.type != LessonStepType.question) continue;
        final answers = step.answers;
        expect(answers, isNotNull,
            reason: '${lesson.id}: question has no answers');
        expect(
          answers!.length,
          greaterThanOrEqualTo(2),
          reason: '${lesson.id}: question needs at least two answers',
        );
        expect(
          answers.every((answer) => answer.trim().isNotEmpty),
          isTrue,
          reason: '${lesson.id}: question has an empty answer',
        );
        final index = step.correctAnswerIndex;
        expect(index, isNotNull, reason: '${lesson.id}: no correctAnswerIndex');
        expect(
          index! >= 0 && index < answers.length,
          isTrue,
          reason: '${lesson.id}: correctAnswerIndex out of range',
        );
      }
    }
  });

  test('word-order steps carry a solvable token set', () {
    // Шаг «Собери фразу» без ≥2 слов ответа не решается и вешает гейт
    // «Проверить»; дистракторы не должны дублировать слова ответа, иначе
    // правильных сборок становится несколько, а засчитывается одна.
    final steps = LessonData.getCourses()
        .expand((course) => course.lessons)
        .expand((lesson) => lesson.steps)
        .where((step) => step.type == LessonStepType.wordOrder)
        .toList(growable: false);

    for (final step in steps) {
      expect(step.orderTokens.length, greaterThanOrEqualTo(2));
      expect(
        step.orderTokens.every((token) => token.trim().isNotEmpty),
        isTrue,
      );
      expect(
        step.extraTokens.every((token) => token.trim().isNotEmpty),
        isTrue,
      );
      expect(
        step.extraTokens.any(step.orderTokens.contains),
        isFalse,
        reason: 'дистрактор повторяет слово ответа: ${step.orderedAnswer}',
      );
    }
  });

  test('listening steps have audio to play and well-formed options', () {
    // Аудирование без источника звука превращается в вопрос без вопроса:
    // нужен номер аята (или арабский текст для TTS) и корректные варианты.
    final steps = LessonData.getCourses()
        .expand((course) => course.lessons)
        .expand((lesson) => lesson.steps)
        .where((step) => step.type == LessonStepType.listenChoice)
        .toList(growable: false);

    for (final step in steps) {
      expect(
        step.quranGlobalAyahNumber != null ||
            (step.arabicText?.trim().isNotEmpty ?? false),
        isTrue,
        reason: 'нечего проигрывать: ${step.question}',
      );
      final answers = step.answers;
      expect(answers, isNotNull);
      expect(answers!.length, greaterThanOrEqualTo(3));
      expect(answers.every((answer) => answer.trim().isNotEmpty), isTrue);
      final index = step.correctAnswerIndex;
      expect(index, isNotNull);
      expect(index! >= 0 && index < answers.length, isTrue);
    }
  });

  test('course registry ids stay exactly quran/arabic/rules', () {
    // Реестр курсов не должен меняться: серверные маршруты и прогресс
    // опираются на эти три id. Обогащение уроков не должно их трогать.
    final courseIds = LessonData.getCourses().map((c) => c.id).toList();

    expect(courseIds, equals(<String>['quran', 'arabic', 'rules']));
    expect(courseIds.toSet(), equals(<String>{'quran', 'arabic', 'rules'}));
  });

  test('every lesson in every course is enriched to at least five steps', () {
    // После обогащения каждый урок должен содержать >=5 осмысленных шагов.
    for (final course in LessonData.getCourses()) {
      for (final lesson in course.lessons) {
        expect(
          lesson.steps.length,
          greaterThanOrEqualTo(5),
          reason: '${course.id}/${lesson.id}: слишком мало шагов '
              '(${lesson.steps.length})',
        );
      }
    }
  });

  test('every question offers at least three usable answers', () {
    // Более строгий контракт обогащённых вопросов: минимум 3 варианта,
    // все непустые, correctAnswerIndex строго в диапазоне.
    final questions = LessonData.getCourses()
        .expand((course) => course.lessons)
        .expand((lesson) => lesson.steps)
        .where((step) => step.type == LessonStepType.question)
        .toList(growable: false);

    expect(questions, isNotEmpty);
    for (final step in questions) {
      final answers = step.answers;
      expect(answers, isNotNull);
      expect(answers!.length, greaterThanOrEqualTo(3));
      expect(
        answers.every((answer) => answer.trim().isNotEmpty),
        isTrue,
      );
      final index = step.correctAnswerIndex;
      expect(index, isNotNull);
      expect(index! >= 0 && index < answers.length, isTrue);
    }
  });

  test('every matching step keeps non-empty, well-formed pairs', () {
    final matchingSteps = LessonData.getCourses()
        .expand((course) => course.lessons)
        .expand((lesson) => lesson.steps)
        .where((step) => step.type == LessonStepType.matching)
        .toList(growable: false);

    expect(matchingSteps, isNotEmpty);
    for (final step in matchingSteps) {
      expect(step.matchPairs, isNotEmpty);
      expect(step.matchPairs.length, greaterThanOrEqualTo(2));
      expect(
        step.matchPairs.every(
          (pair) =>
              pair.prompt.trim().isNotEmpty && pair.answer.trim().isNotEmpty,
        ),
        isTrue,
      );
    }
  });
}
