import '../models/lesson.dart';
import 'lesson_challenge_engine.dart';
import 'lessons/quran_lessons.dart';
import 'lessons/quran_full_curriculum.dart';
import 'lessons/quran_curriculum_asset_io.dart'
    if (dart.library.ui) 'lessons/quran_curriculum_asset_flutter.dart';
import 'lessons/arabic_lessons.dart';
import 'lessons/rules_lessons.dart';
import 'tajwid_data.dart';

class LessonData {
  static List<Lesson> _fullQuranLessons = const [];
  static Future<void>? _initializing;
  static bool get fullQuranInitialized => _fullQuranLessons.isNotEmpty;

  /// Load the complete source-backed path before publishing courses to state.
  /// Repeated calls are safe across account changes and Flutter test zones.
  static Future<void> initialize() {
    if (fullQuranInitialized) return Future<void>.value();
    return _initializing ??=
        _initializeFullQuran().whenComplete(() => _initializing = null);
  }

  static Future<void> _initializeFullQuran() async {
    final text = await loadQuranCurriculumAsset();
    _fullQuranLessons = QuranFullCurriculum.fromCanonicalText(text).lessons();
  }

  static final List<Lesson> _quranLessons =
      LessonChallengeEngine.strengthen(quranLessons);
  static final List<Lesson> _arabicLessons =
      LessonChallengeEngine.strengthen(arabicLessons);
  static final List<Lesson> _rulesLessons =
      LessonChallengeEngine.strengthen(rulesLessons);
  static final List<Lesson> _tajwidLessons =
      LessonChallengeEngine.strengthen(tajwidLessons);

  static List<Course> getCourses() =>
      [quranCourse, arabicCourse, tajwidCourse, rulesCourse];

  // Course order is guidance, not an access gate. Completion is restored from
  // learner progress by AppState; opening any lesson never completes it.
  static List<Lesson> _openLessons(Iterable<Lesson> lessons) => lessons
      .map((lesson) => lesson.copyWith(status: LessonStatus.available))
      .toList(growable: false);

  static Course get quranCourse => Course(
        id: 'quran',
        title: 'Коран',
        description: 'Изучай аяты с аудио и переводом',
        type: CourseType.quran,
        lessons: _openLessons([..._quranLessons, ..._fullQuranLessons]),
      );

  static Course get arabicCourse => Course(
        id: 'arabic',
        title: 'Арабский язык',
        description: 'Буквы, чтение и произношение в игровом формате',
        type: CourseType.arabic,
        lessons: _openLessons(_arabicLessons),
      );

  static Course get rulesCourse => Course(
        id: 'rules',
        title: 'Основы ислама',
        description: 'Краткое введение в основы ислама с источниками',
        type: CourseType.rules,
        lessons: _openLessons(_rulesLessons),
      );

  static Course get tajwidCourse => Course(
        id: 'tajwid',
        title: 'Таджвид',
        description: 'Махрадж, качества букв и правила чтения Корана',
        type: CourseType.tajwid,
        lessons: _openLessons(_tajwidLessons),
      );
}
