import '../models/lesson.dart';

/// Makes every lesson finish with a multi-part reasoning challenge while keeping
/// the existing lesson step order and interaction algorithm intact.
class LessonChallengeEngine {
  const LessonChallengeEngine._();

  static List<Lesson> strengthen(List<Lesson> lessons) =>
      lessons.map(_strengthenLesson).toList(growable: false);

  static Lesson _strengthenLesson(Lesson lesson) {
    final questionIndexes = <int>[];
    for (var index = 0; index < lesson.steps.length; index++) {
      if (_isUsableQuestion(lesson.steps[index])) questionIndexes.add(index);
    }
    if (questionIndexes.isEmpty) return lesson;

    final targetIndex = questionIndexes.last;
    final facts = <LessonStep>[
      lesson.steps[questionIndexes.first],
      if (questionIndexes.length > 2)
        lesson.steps[questionIndexes[questionIndexes.length ~/ 2]],
      if (questionIndexes.length > 1) lesson.steps[targetIndex],
    ];
    final matchingFact = _factFromMatching(lesson);
    if (facts.length < 3 && matchingFact != null) facts.add(matchingFact);
    while (facts.length < 2) {
      facts.add(facts.first);
    }
    final challenge = _buildChallenge(lesson, facts.take(3).toList());
    final steps = List<LessonStep>.of(lesson.steps)..[targetIndex] = challenge;
    return lesson.copyWith(steps: List.unmodifiable(steps));
  }

  static bool _isUsableQuestion(LessonStep step) {
    final answers = step.answers;
    final correct = step.correctAnswerIndex;
    return step.type == LessonStepType.question &&
        step.question?.trim().isNotEmpty == true &&
        answers != null &&
        answers.length >= 3 &&
        correct != null &&
        correct >= 0 &&
        correct < answers.length;
  }

  static LessonStep? _factFromMatching(Lesson lesson) {
    for (final step in lesson.steps.reversed) {
      if (step.type != LessonStepType.matching || step.matchPairs.length < 2) {
        continue;
      }
      final first = step.matchPairs.first;
      final second = step.matchPairs[1];
      return LessonStep(
        id: '${lesson.id}_matching_fact',
        type: LessonStepType.question,
        question: 'Какое соответствие верно?',
        answers: [
          '${first.prompt} — ${first.answer}',
          '${first.prompt} — ${second.answer}',
          '${second.prompt} — ${first.answer}',
        ],
        correctAnswerIndex: 0,
        sourceRefs: step.sourceRefs,
      );
    }
    return null;
  }

  static LessonStep _buildChallenge(
    Lesson lesson,
    List<LessonStep> facts,
  ) {
    final correct = facts.map(_correctAnswer).toList(growable: false);
    final distractors = [
      for (var index = 0; index < facts.length; index++)
        _closestDistractor(facts[index], correct[index]),
    ];
    final sources = <String>{
      for (final fact in facts) ...fact.sourceRefs,
    }.toList();
    final prompts = [
      for (var index = 0; index < facts.length; index++)
        '${index + 1}. ${facts[index].question}',
    ].join('\n');
    String answerWithErrorAt(int? errorIndex) => [
          for (var index = 0; index < facts.length; index++)
            '${index + 1} — ${index == errorIndex ? distractors[index] : correct[index]}',
        ].join('\n');
    final options = <String>[
      answerWithErrorAt(null),
      answerWithErrorAt(0),
      answerWithErrorAt(facts.length > 1 ? 1 : 0),
      facts.length > 2
          ? answerWithErrorAt(2)
          : [
              '1 — ${distractors[0]}',
              '2 — ${distractors[1]}',
            ].join('\n'),
    ];
    final correctIndex = lesson.order % options.length;
    final correctOption = options.removeAt(0);
    options.insert(correctIndex, correctOption);

    return facts.last.copyWith(
      id: '${lesson.id}_logic_challenge',
      question: '${facts.length == 3 ? 'Три' : 'Два'} вывода одновременно. '
          'Выбери единственную цепочку без ошибки.\n\n$prompts',
      answers: options,
      correctAnswerIndex: correctIndex,
      explanation: 'Проверь каждое звено отдельно и только потом оцени всю '
          'цепочку: один верный вывод не делает верным весь ответ.',
      sourceRefs: sources,
    );
  }

  static String _correctAnswer(LessonStep step) =>
      step.answers![step.correctAnswerIndex!].trim();

  static String _closestDistractor(LessonStep step, String correct) {
    final distractors = <String>[
      for (var index = 0; index < step.answers!.length; index++)
        if (index != step.correctAnswerIndex &&
            step.answers![index].trim() != correct)
          step.answers![index].trim(),
    ];
    if (distractors.isEmpty) {
      return '$correct — но без проверки остальных звеньев';
    }
    distractors.sort((a, b) {
      final aDistance = (a.length - correct.length).abs();
      final bDistance = (b.length - correct.length).abs();
      return aDistance.compareTo(bDistance);
    });
    return distractors.first;
  }
}
