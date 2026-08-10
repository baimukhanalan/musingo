import '../models/lesson.dart';
import 'lessons/quran_lessons.dart';
import 'lessons/arabic_lessons.dart';
import 'lessons/rules_lessons.dart';

class LessonData {
  static List<Course> getCourses() => [quranCourse, arabicCourse, rulesCourse];

  static Course get quranCourse => Course(
        id: 'quran',
        title: 'Коран',
        description: 'Изучай аяты с аудио и переводом',
        type: CourseType.quran,
        lessons: quranLessons,
      );

  static Course get arabicCourse => Course(
        id: 'arabic',
        title: 'Арабский язык',
        description: 'Буквы, чтение и произношение в игровом формате',
        type: CourseType.arabic,
        lessons: arabicLessons,
      );

  static Course get rulesCourse => Course(
        id: 'rules',
        title: 'Основы ислама',
        description: 'Краткое введение в основы ислама с источниками',
        type: CourseType.rules,
        lessons: rulesLessons,
      );
}
