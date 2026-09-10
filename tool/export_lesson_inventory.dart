import 'dart:convert';
import 'dart:io';

import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/lesson_data.dart';

void main() {
  final courses = LessonData.getCourses();
  final courseRows = courses.map((course) {
    final steps = course.lessons.expand((lesson) => lesson.steps).toList();
    final typeCounts = <String, int>{};
    for (final step in steps) {
      typeCounts.update(step.type.name, (value) => value + 1,
          ifAbsent: () => 1);
    }

    final sourcedSteps =
        steps.where((step) => step.sourceRefs.isNotEmpty).length;
    final lessonsWithSourceUrl =
        course.lessons.where((lesson) => lesson.sourceUrl != null).length;
    final uniqueAyahs = steps
        .map((step) => step.quranGlobalAyahNumber)
        .whereType<int>()
        .toSet();

    return <String, Object>{
      'id': course.id,
      'title': course.title,
      'lessonCount': course.lessons.length,
      'stepCount': steps.length,
      'averageStepsPerLesson': double.parse(
          (steps.length / course.lessons.length).toStringAsFixed(2)),
      'stepTypes': typeCounts,
      'sourcedStepCount': sourcedSteps,
      'sourcedStepPercent':
          double.parse((100 * sourcedSteps / steps.length).toStringAsFixed(1)),
      'lessonsWithSourceUrl': lessonsWithSourceUrl,
      'uniqueQuranAyahsReferenced': uniqueAyahs.length,
      'lessons': course.lessons.map(_lessonRow).toList(),
    };
  }).toList();

  final allLessons = courses.expand((course) => course.lessons).toList();
  final allSteps = allLessons.expand((lesson) => lesson.steps).toList();
  final payload = <String, Object>{
    'generatedFrom': 'LessonData.getCourses()',
    'lessonCount': allLessons.length,
    'stepCount': allSteps.length,
    'courseCount': courses.length,
    'courses': courseRows,
  };

  stdout.writeln(const JsonEncoder.withIndent('  ').convert(payload));
}

Map<String, Object?> _lessonRow(Lesson lesson) {
  final types = <String, int>{};
  for (final step in lesson.steps) {
    types.update(step.type.name, (value) => value + 1, ifAbsent: () => 1);
  }

  return <String, Object?>{
    'id': lesson.id,
    'order': lesson.order,
    'title': lesson.title,
    'subtitle': lesson.subtitle,
    'stepCount': lesson.steps.length,
    'stepTypes': types,
    'sourceUrl': lesson.sourceUrl,
    'allStepsSourced': lesson.steps.every((step) => step.sourceRefs.isNotEmpty),
    'hasPronunciation':
        lesson.steps.any((step) => step.type == LessonStepType.speak),
    'hasListeningChoice':
        lesson.steps.any((step) => step.type == LessonStepType.listenChoice),
    'hasWordOrder':
        lesson.steps.any((step) => step.type == LessonStepType.wordOrder),
    'hasMeaningQuestion':
        lesson.steps.any((step) => step.type == LessonStepType.question),
  };
}
