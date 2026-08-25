import 'dart:convert';
import 'dart:io';

import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/lesson_data.dart';

void main() {
  final targets = <Map<String, Object?>>[];
  for (final course in LessonData.getCourses()) {
    for (final lesson in course.lessons) {
      for (var index = 0; index < lesson.steps.length; index++) {
        final step = lesson.steps[index];
        if (step.type != LessonStepType.speak) continue;
        targets.add({
          'courseId': course.id,
          'lessonId': lesson.id,
          'lessonTitle': lesson.title,
          'stepId': step.id ?? '${lesson.id}:$index',
          'target': step.effectiveSpeechTarget,
          'phoneticTarget': step.transliteration ?? '',
          'passScore': step.effectivePassScore,
        });
      }
    }
  }
  stdout.write(jsonEncode(targets));
}
