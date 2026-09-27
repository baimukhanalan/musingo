import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/lesson_video_catalog.dart';
import 'package:muslingo/services/lesson_video_segments.dart';
import 'package:muslingo/services/academy_lecture_catalog.dart';

void main() {
  test('reviewed long videos become short, contiguous provider-hosted parts',
      () {
    final catalog = LessonVideoCatalog.curated.entries;
    expect(catalog, hasLength(13 + topicMatchedLectureIds.length + 3));
    var visibleParts = 0;
    for (final video in catalog) {
      final duration = reviewedVideoDurationSeconds[video.id] ??
          AcademyLectureCatalog.byYoutubeId(
                  Uri.parse(video.embedUrl).pathSegments.last)!
              .durationSeconds;
      final segments = lessonVideoSegments(video);
      if (duration <= 360) {
        expect(segments, isEmpty, reason: video.id);
        visibleParts++;
        continue;
      }
      expect(segments.first.startSeconds, 0, reason: video.id);
      expect(segments.last.endSeconds, duration, reason: video.id);
      visibleParts += segments.length;
      for (var index = 0; index < segments.length; index++) {
        final segment = segments[index];
        expect(segment.number, index + 1);
        expect(segment.total, segments.length);
        expect(segment.durationSeconds, inInclusiveRange(1, 360));
        if (index > 0) {
          expect(segment.startSeconds, segments[index - 1].endSeconds);
        }
        final uri = segment.playbackUri(video);
        expect(uri.host, 'www.youtube-nocookie.com');
        expect(
            uri.queryParameters.keys.toSet(), anyOf({'end'}, {'start', 'end'}));
        expect(uri.queryParameters['end'], '${segment.endSeconds}');
        expect(uri.queryParameters.containsKey('autoplay'), isFalse);
      }
    }
    // One original Idgham video supports two different lesson cards.
    expect(visibleParts, greaterThan(37));
  });

  test('timecodes and invalid ranges are handled explicitly', () {
    expect(lessonVideoTimecode(0), '0:00');
    expect(lessonVideoTimecode(1305), '21:45');
    final video = LessonVideoCatalog.curated.entries.first;
    expect(
      () => const LessonVideoSegment(
        number: 1,
        total: 1,
        startSeconds: 10,
        endSeconds: 400,
      ).playbackUri(video),
      throwsArgumentError,
    );
  });
}
