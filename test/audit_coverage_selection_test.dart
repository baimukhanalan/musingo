import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/curriculum_repository.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/services/lesson_data.dart';

import 'support/exhaustive_audit.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('representative selection includes boundaries and longest text', () {
    expect(representativeIndices(<String>[], (text) => text.length), isEmpty);
    expect(representativeIndices(['only'], (text) => text.length), [0]);
    expect(
        representativeIndices(
            ['a', 'longest', 'c', 'd', 'e'], (text) => text.length),
        [0, 1, 2, 4]);
  });

  test('default audit preserves RU coverage and full mode covers every item',
      () async {
    await LessonContentLocalization.load();
    final courses = LessonData.getCourses();
    final modules = await CurriculumRepository.load();
    final lessonCounts = <String, int>{};
    final moduleCounts = <String, int>{};
    for (final locale in ['ru', 'kk', 'en']) {
      final localizedCourses =
          LessonContentLocalization.localizeCourses(courses, locale);
      final localizedModules = modules
          .map((module) =>
              LessonContentLocalization.localizeModule(module, locale))
          .toList();
      lessonCounts[locale] = localizedCourses.fold(
          0,
          (sum, course) =>
              sum +
              lessonAuditIndices(course.lessons, locale, exhaustive: false)
                  .length);
      moduleCounts[locale] =
          moduleAuditIndices(localizedModules, exhaustive: false).length;
      expect(
          localizedCourses.fold<int>(
              0,
              (sum, course) =>
                  sum +
                  lessonAuditIndices(course.lessons, locale, exhaustive: true)
                      .length),
          246);
      expect(
          moduleAuditIndices(localizedModules, exhaustive: true).length, 570);
      for (final course in localizedCourses) {
        final selection =
            lessonAuditIndices(course.lessons, locale, exhaustive: false);
        expect(
            selection,
            containsAll(
                [0, course.lessons.length ~/ 2, course.lessons.length - 1]));
      }
    }
    expect(lessonCounts, {'ru': 246, 'kk': 13, 'en': 13});
    expect(moduleCounts, {'ru': 16, 'kk': 16, 'en': 16});
    // Output gives the exact source-dependent default matrix for test/README.md.
    // ignore: avoid_print
    print('Default audit counts: lessons=$lessonCounts, modules=$moduleCounts');
  });
}
