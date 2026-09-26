import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/curriculum_repository.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/services/lesson_data.dart';
import 'package:muslingo/services/lesson_video_catalog.dart';
import 'package:muslingo/utils/app_locale.dart';

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
    // The synchronous registry initially contains only the 246 legacy lessons.
    // Coverage must be measured against the same loaded catalog as AppState.
    await LessonData.initialize();
    await LessonContentLocalization.load();
    final courses = LessonData.getCourses();
    expect(LessonData.fullQuranInitialized, isTrue);
    expect(courses.expand((course) => course.lessons), hasLength(1148));
    expect(
        courses
            .expand((course) => course.lessons)
            .where((lesson) => lesson.id.startsWith('q_full_')),
        hasLength(902));
    expect(AppLocale.values.map((locale) => locale.code),
        ['ru', 'kk', 'en', 'ar']);
    final modules = await CurriculumRepository.load();
    final lessonCounts = <String, int>{};
    final moduleCounts = <String, int>{};
    final lessonCountsByCourse = <String, Map<String, int>>{};
    for (final appLocale in AppLocale.values) {
      final locale = appLocale.code;
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
          1148);
      expect(
          moduleAuditIndices(localizedModules, exhaustive: true).length, 570);
      for (final course in localizedCourses) {
        final selection =
            lessonAuditIndices(course.lessons, locale, exhaustive: false);
        lessonCountsByCourse.putIfAbsent(locale, () => {})[course.id] =
            selection.length;
        expect(selection.toSet().length, selection.length);
        expect(
            selection
                .every((index) => index >= 0 && index < course.lessons.length),
            isTrue);
        if (locale != 'ru') {
          expect(selection.length, inInclusiveRange(3, 4),
              reason: '$locale/${course.id}: boundary/long-copy sample');
        }
        expect(
            selection,
            containsAll(
                [0, course.lessons.length ~/ 2, course.lessons.length - 1]));
      }
    }
    // Output gives the exact source-dependent default matrix for test/README.md.
    // ignore: avoid_print
    print('Default audit counts: lessons=$lessonCounts, modules=$moduleCounts');
    // ignore: avoid_print
    print('Default lesson samples by course: $lessonCountsByCourse');
    expect(lessonCounts, {'ru': 1148, 'kk': 14, 'en': 14, 'ar': 15});
    expect(moduleCounts, {'ru': 16, 'kk': 16, 'en': 16, 'ar': 16});
    expect(LessonVideoCatalog.curated.entries, hasLength(13));
    // ignore: avoid_print
    print('Full audit counts: lessons=${1148 * AppLocale.values.length}, '
        'modules=${modules.length * AppLocale.values.length}, '
        'module challenge answers=${modules.length * AppLocale.values.length * 5}, '
        'official video card journeys=${LessonVideoCatalog.curated.entries.length * AppLocale.values.length}');
  });
}
