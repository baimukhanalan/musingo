import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/screens/tajwid_review_screen.dart';
import 'package:muslingo/services/lesson_data.dart';
import 'package:muslingo/services/tajwid_data.dart';

void main() {
  test('черновые уроки таджвида корректно структурированы', () {
    final lessons = TajwidDraftData.lessons();
    expect(lessons, isNotEmpty);
    final ids = <String>{};
    for (final lesson in lessons) {
      expect(lesson.id.startsWith('tj_'), isTrue, reason: lesson.id);
      expect(ids.add(lesson.id), isTrue, reason: 'дубликат id ${lesson.id}');
      expect(lesson.steps, isNotEmpty, reason: lesson.id);
      for (final step in lesson.steps) {
        if (step.type == LessonStepType.question) {
          expect(step.answers, isNotNull, reason: lesson.id);
          expect(step.answers!.length, greaterThanOrEqualTo(2), reason: lesson.id);
          expect(step.correctAnswerIndex, isNotNull, reason: lesson.id);
          expect(step.correctAnswerIndex! >= 0, isTrue, reason: lesson.id);
          expect(step.correctAnswerIndex! < step.answers!.length, isTrue,
              reason: lesson.id);
        }
      }
    }
  });

  test('черновой таджвид НЕ входит в прод-курсы', () {
    final courseLessonIds = <String>{
      for (final course in LessonData.getCourses())
        for (final lesson in course.lessons) lesson.id,
    };
    for (final draft in TajwidDraftData.lessons()) {
      expect(courseLessonIds.contains(draft.id), isFalse,
          reason: 'черновой ${draft.id} просочился в прод-курсы');
    }
  });

  testWidgets('экран ревью таджвида рендерится с дисклеймером', (tester) async {
    await tester.pumpWidget(const MaterialApp(home: TajwidReviewScreen()));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Таджвид — черновик'), findsOneWidget);
    expect(find.textContaining('ЧЕРНОВИК'), findsWidgets);
    // Первый урок в зоне видимости (дальние строит ленивый ListView по скроллу).
    expect(find.text('1. Что такое таджвид'), findsOneWidget);
  });
}
