import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/lesson_data.dart';

void main() {
  test('production Tajwid course contains 36 ordered lessons', () {
    final course = LessonData.tajwidCourse;

    expect(course.id, 'tajwid');
    expect(course.type, CourseType.tajwid);
    expect(course.lessons, hasLength(36));
    expect(
      course.lessons.map((lesson) => lesson.id),
      List.generate(
        36,
        (index) => 'tj${(index + 1).toString().padLeft(2, '0')}',
      ),
    );
    expect(
      course.lessons.map((lesson) => lesson.order),
      List.generate(36, (index) => index + 1),
    );
    expect(course.lessons.first.status, LessonStatus.available);
    expect(
      course.lessons
          .skip(1)
          .every((lesson) => lesson.status == LessonStatus.locked),
      isTrue,
    );
  });

  test('every Tajwid lesson follows the complete learning loop', () {
    const requiredTypes = <LessonStepType>{
      LessonStepType.text,
      LessonStepType.audio,
      LessonStepType.listenChoice,
      LessonStepType.question,
      LessonStepType.matching,
      LessonStepType.speak,
    };

    for (final lesson in LessonData.tajwidCourse.lessons) {
      final types = lesson.steps.map((step) => step.type).toSet();
      expect(types.containsAll(requiredTypes), isTrue, reason: lesson.id);
      expect(lesson.steps, hasLength(7), reason: lesson.id);
      expect(lesson.sourceUrl, startsWith('https://'));
      expect(
        lesson.steps.every((step) => step.sourceRefs.isNotEmpty),
        isTrue,
        reason: '${lesson.id}: missing source metadata',
      );

      final audioSteps = lesson.steps.where(
        (step) =>
            step.type == LessonStepType.audio ||
            step.type == LessonStepType.listenChoice,
      );
      expect(
        audioSteps.every(
          (step) =>
              step.quranGlobalAyahNumber != null && step.arabicText!.isNotEmpty,
        ),
        isTrue,
        reason: '${lesson.id}: incomplete Quran audio target',
      );

      final speech = lesson.steps.singleWhere(
        (step) => step.type == LessonStepType.speak,
      );
      expect(speech.speechMode, SpeechMode.quran);
      expect(speech.effectivePassScore, 75);
      expect(speech.effectiveSpeechTarget, isNotEmpty);
    }
  });

  test('Tajwid curriculum covers all core sections', () {
    final titles =
        LessonData.tajwidCourse.lessons.map((lesson) => lesson.title);

    expect(titles, contains('Пять зон махраджа'));
    expect(titles, contains('Калькаля'));
    expect(titles, contains('Гунна'));
    expect(titles, contains('Изхар'));
    expect(titles, contains('Ихфа'));
    expect(titles, contains('Мим сакина'));
    expect(titles, contains('Мадд табии'));
    expect(titles, contains('Лям в имени Аллаха'));
    expect(titles, contains('Остановка и знаки вакфа'));
    expect(titles.last, 'Итоговая практика');
  });
}
