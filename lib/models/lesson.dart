enum LessonStatus { locked, available, inProgress, completed }

/// Типы шагов урока.
///
/// [wordOrder] — собрать фразу/аят, нажимая слова в правильном порядке
/// (последовательность в `orderTokens`, лишние слова-дистракторы в
/// `extraTokens`). [listenChoice] — аудирование: шаг проигрывает аят
/// (`quranGlobalAyahNumber`) или фразу (`arabicText` через TTS), а ученик
/// выбирает подходящий вариант из `answers`/`correctAnswerIndex`.
enum LessonStepType {
  audio,
  text,
  question,
  matching,
  speak,
  wordOrder,
  listenChoice
}

enum CourseType { quran, rules, arabic }

enum SpeechMode { none, quran, arabic, phrase }

class LessonStep {
  final String? id;
  final LessonStepType type;
  final String? audioPath;
  final int? quranGlobalAyahNumber;
  final String? arabicText;
  final String? transliteration;
  final String? russianText;
  final String? question;
  final List<String>? answers;
  final int? correctAnswerIndex;
  final List<LessonMatchPair> matchPairs;
  final String? speechTarget;
  final SpeechMode speechMode;
  final int? passScore;
  final String? explanation;
  final List<String> sourceRefs;

  /// Правильная последовательность слов для [LessonStepType.wordOrder].
  final List<String> orderTokens;

  /// Лишние слова, подмешиваемые в банк wordOrder-шага (дистракторы).
  final List<String> extraTokens;

  const LessonStep({
    this.id,
    required this.type,
    this.audioPath,
    this.quranGlobalAyahNumber,
    this.arabicText,
    this.transliteration,
    this.russianText,
    this.question,
    this.answers,
    this.correctAnswerIndex,
    this.matchPairs = const [],
    this.speechTarget,
    this.speechMode = SpeechMode.none,
    this.passScore,
    this.explanation,
    this.sourceRefs = const [],
    this.orderTokens = const [],
    this.extraTokens = const [],
  });

  /// Полный банк слов wordOrder-шага (правильные + дистракторы) до перемешивания.
  List<String> get wordBank => [...orderTokens, ...extraTokens];

  /// Эталонная строка ответа wordOrder-шага: слова через один пробел.
  String get orderedAnswer => orderTokens.join(' ');

  String get effectiveSpeechTarget =>
      speechTarget ?? arabicText ?? transliteration ?? '';

  int get effectivePassScore {
    if (passScore != null) return passScore!;
    if (type == LessonStepType.speak && quranGlobalAyahNumber != null) {
      return 75;
    }
    switch (speechMode) {
      case SpeechMode.quran:
        return 75;
      case SpeechMode.arabic:
        return 60;
      case SpeechMode.phrase:
        return 65;
      case SpeechMode.none:
        return 60;
    }
  }

  LessonStep copyWith({
    String? id,
    String? question,
    List<String>? answers,
    int? correctAnswerIndex,
    String? explanation,
    List<String>? sourceRefs,
  }) =>
      LessonStep(
        id: id ?? this.id,
        type: type,
        audioPath: audioPath,
        quranGlobalAyahNumber: quranGlobalAyahNumber,
        arabicText: arabicText,
        transliteration: transliteration,
        russianText: russianText,
        question: question ?? this.question,
        answers: answers ?? this.answers,
        correctAnswerIndex: correctAnswerIndex ?? this.correctAnswerIndex,
        matchPairs: matchPairs,
        speechTarget: speechTarget,
        speechMode: speechMode,
        passScore: passScore,
        explanation: explanation ?? this.explanation,
        sourceRefs: sourceRefs ?? this.sourceRefs,
        orderTokens: orderTokens,
        extraTokens: extraTokens,
      );
}

class LessonMatchPair {
  final String prompt;
  final String answer;

  const LessonMatchPair({
    required this.prompt,
    required this.answer,
  });
}

class Lesson {
  final String id;
  final String title;
  final String subtitle;
  final CourseType course;
  final int order;
  final LessonStatus status;
  final List<LessonStep> steps;
  final int xpReward;
  final String? sourceUrl;

  const Lesson({
    required this.id,
    required this.title,
    required this.subtitle,
    required this.course,
    required this.order,
    required this.steps,
    this.status = LessonStatus.locked,
    this.xpReward = 25,
    this.sourceUrl,
  });

  Lesson copyWith({LessonStatus? status, List<LessonStep>? steps}) => Lesson(
        id: id,
        title: title,
        subtitle: subtitle,
        course: course,
        order: order,
        steps: steps ?? this.steps,
        status: status ?? this.status,
        xpReward: xpReward,
        sourceUrl: sourceUrl,
      );
}

class Course {
  final String id;
  final String title;
  final String description;
  final CourseType type;
  final List<Lesson> lessons;

  const Course({
    required this.id,
    required this.title,
    required this.description,
    required this.type,
    required this.lessons,
  });

  int get completedLessons =>
      lessons.where((l) => l.status == LessonStatus.completed).length;

  double get progress =>
      lessons.isEmpty ? 0 : completedLessons / lessons.length;
}
