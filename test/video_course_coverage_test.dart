import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/academy_lecture_catalog.dart';
import 'package:muslingo/services/lesson_data.dart';
import 'package:muslingo/services/lesson_video_catalog.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every mapped video belongs to a real lesson and every course has video',
      () async {
    await LessonData.initialize();
    final courses = LessonData.getCourses();
    final allIds = courses.expand((course) => course.lessons).map((l) => l.id);
    for (final id in topicMatchedLectureIds.keys) {
      expect(allIds, contains(id), reason: id);
    }
    for (final course in courses) {
      final videoLessons = course.lessons
          .where((lesson) =>
              LessonVideoCatalog.curated.forLesson(lesson.id).isNotEmpty)
          .length;
      expect(videoLessons, greaterThan(0), reason: course.id);
      // ignore: avoid_print
      print('${course.id}: $videoLessons / ${course.lessons.length} lessons');
    }
    expect(AcademyLectureCatalog.all, hasLength(220));
  });
}
