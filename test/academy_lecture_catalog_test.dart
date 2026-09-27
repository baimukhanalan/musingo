import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/academy_lecture_catalog.dart';
import 'package:muslingo/services/lesson_video_catalog.dart';

void main() {
  test('full lectures are a distinct, source-labelled library', () {
    const lectures = AcademyLectureCatalog.all;
    expect(lectures, hasLength(220));
    expect(lectures.map((item) => item.youtubeId).toSet(), hasLength(220));
    expect(
        lectures.where((item) => item.category == 'reading'), hasLength(139));
    expect(lectures.where((item) => item.category == 'meaning'), hasLength(51));
    expect(lectures.where((item) => item.category == 'prayer'), hasLength(30));
    for (final lecture in lectures) {
      expect(lecture.durationSeconds, greaterThan(0));
      expect(lecture.publisherPage, startsWith('https://abu-yasin.com/video/'));
      final video = lecture.toPlayerVideo();
      expect(const LessonVideoPolicy().validate(video).canDisplay, isTrue,
          reason: lecture.youtubeId);
      expect(video.embedUrl,
          'https://www.youtube-nocookie.com/embed/${lecture.youtubeId}');
    }
  });

  test('course lesson mappings resolve to real lecture topics', () {
    for (final match in topicMatchedLectureIds.entries) {
      expect(AcademyLectureCatalog.byYoutubeId(match.value), isNotNull,
          reason: match.key);
      expect(LessonVideoCatalog.curated.forLesson(match.key), isNotEmpty);
    }
  });
}
