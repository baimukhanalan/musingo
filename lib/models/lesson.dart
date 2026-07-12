enum LessonStatus { locked, available, inProgress, completed }

enum LessonStepType { audio, text, question, speak }

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
  final String? speechTarget;
  final SpeechMode speechMode;
  final int? passScore;
  final String? explanation;
  final List<String> sourceRefs;

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
    this.speechTarget,
    this.speechMode = SpeechMode.none,
    this.passScore,
    this.explanation,
    this.sourceRefs = const [],
  });

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

  Lesson copyWith({LessonStatus? status}) => Lesson(
        id: id,
        title: title,
        subtitle: subtitle,
        course: course,
        order: order,
        steps: steps,
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
