import '../models/lesson.dart';
import 'lesson_challenge_engine.dart';
import 'lessons/quran_lessons.dart';
import 'lessons/arabic_lessons.dart';
import 'lessons/rules_lessons.dart';
import 'tajwid_data.dart';

class LessonData {
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

  static Course get quranCourse => Course(
        id: 'quran',
        title: 'Коран',
        description: 'Изучай аяты с аудио и переводом',
        type: CourseType.quran,
        lessons: _quranLessons,
      );

  static Course get arabicCourse => Course(
        id: 'arabic',
        title: 'Арабский язык',
        description: 'Буквы, чтение и произношение в игровом формате',
        type: CourseType.arabic,
        lessons: _arabicLessons,
      );

  static Course get rulesCourse => Course(
        id: 'rules',
        title: 'Основы ислама',
        description: 'Краткое введение в основы ислама с источниками',
        type: CourseType.rules,
        lessons: _rulesLessons,
      );

  static Course get tajwidCourse => Course(
        id: 'tajwid',
        title: 'Таджвид',
        description: 'Махрадж, качества букв и правила чтения Корана',
        type: CourseType.tajwid,
        lessons: _tajwidLessons,
      );
}
