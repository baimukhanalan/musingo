import '../models/lesson.dart';

/// Makes every lesson finish with a two-part retrieval challenge while keeping
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

    final first = lesson.steps[questionIndexes.first];
    final targetIndex = questionIndexes.last;
    final second = questionIndexes.length > 1
        ? lesson.steps[targetIndex]
        : _factFromMatching(lesson) ?? first;
    final challenge = _buildChallenge(lesson, first, second);
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
    LessonStep first,
    LessonStep second,
  ) {
    final firstCorrect = _correctAnswer(first);
    final secondCorrect = _correctAnswer(second);
    final firstDistractor = _closestDistractor(first, firstCorrect);
    final secondDistractor = _closestDistractor(second, secondCorrect);
    final sources =
        <String>{...first.sourceRefs, ...second.sourceRefs}.toList();

    return second.copyWith(
      id: '${lesson.id}_logic_challenge',
      question:
          'Два вывода одновременно. Выбери единственную пару без ошибки.\n\n'
          '1. ${first.question}\n'
          '2. ${second.question}',
      answers: [
        '1 — $firstCorrect\n2 — $secondCorrect',
        '1 — $firstCorrect\n2 — $secondDistractor',
        '1 — $firstDistractor\n2 — $secondCorrect',
        '1 — $firstDistractor\n2 — $secondDistractor',
      ],
      correctAnswerIndex: 0,
      explanation: 'Проверь оба вывода отдельно: один верный пункт ещё не '
          'делает верной всю пару.',
      sourceRefs: sources,
    );
  }

  static String _correctAnswer(LessonStep step) =>
      step.answers![step.correctAnswerIndex!].trim();

  static String _closestDistractor(LessonStep step, String correct) {
    final distractors = <String>[
      for (var index = 0; index < step.answers!.length; index++)
        if (index != step.correctAnswerIndex) step.answers![index].trim(),
    ];
    distractors.sort((a, b) {
      final aDistance = (a.length - correct.length).abs();
      final bDistance = (b.length - correct.length).abs();
      return aDistance.compareTo(bDistance);
    });
    return distractors.first;
  }
}
