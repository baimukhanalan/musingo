import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson_video.dart';
import 'package:muslingo/services/lesson_video_catalog.dart';

import 'support/lesson_video_fixture.dart';

void main() {
  const policy = LessonVideoPolicy();
  final now = DateTime.utc(2026, 9, 11);

  test('accepts an approved HTTPS privacy-enhanced provider record', () {
    final video = testLessonVideo();
    final result = policy.validate(video, now: now);

    expect(result.canDisplay, isTrue, reason: result.errors.join('\n'));
    expect(
      const LessonVideoCatalog().forLesson('lesson-1'),
      isEmpty,
      reason: 'The production catalog stays empty until CMS review.',
    );
  });

  test('rejects HTTP, lookalike hosts, query autoplay, and source mismatch',
      () {
    final unsafe = [
      testLessonVideo(
          embedUrl: 'http://www.youtube-nocookie.com/embed/abc123XYZ00'),
      testLessonVideo(
          embedUrl:
              'https://www.youtube-nocookie.com.evil.test/embed/abc123XYZ00'),
      testLessonVideo(
          embedUrl:
              'https://www.youtube-nocookie.com/embed/abc123XYZ00?autoplay=1'),
      testLessonVideo(sourceUrl: 'https://youtu.be/different01'),
    ];

    for (final video in unsafe) {
      expect(policy.validate(video, now: now).canDisplay, isFalse);
    }
  });

  test('rejects missing transcript, rights evidence, or editorial approval',
      () {
    final missingTranscript = testLessonVideo(transcript: 'short');
    final missingRights = testLessonVideo(rightsEvidenceUrl: 'javascript:x');
    final pending =
        testLessonVideo(reviewStatus: LessonVideoReviewStatus.pending);

    expect(policy.validate(missingTranscript, now: now).canDisplay, isFalse);
    expect(policy.validate(missingRights, now: now).canDisplay, isFalse);
    expect(policy.validate(pending, now: now).canDisplay, isFalse);
  });

  test('catalog exposes only valid approved videos for the requested lesson',
      () {
    final valid = testLessonVideo();
    final invalid = testLessonVideo(
      id: 'video-2',
      embedUrl: 'https://example.com/video/abc123XYZ00',
    );
    final other = testLessonVideo(id: 'video-3', lessonId: 'lesson-2');
    final catalog = LessonVideoCatalog(entries: [valid, invalid, other]);

    expect(catalog.forLesson('lesson-1'), [valid]);
    expect(catalog.forLesson('lesson-2'), [other]);
    expect(
      catalog.forLesson('lesson-1', languageCode: 'kk'),
      isEmpty,
      reason: 'A learner should not see a video in another explanation track.',
    );
  });

  test('curated catalog maps only reviewed optional videos to real lessons',
      () {
    expect(
      LessonVideoCatalog.curated.forLesson('a1', languageCode: 'ru'),
      hasLength(1),
    );
    expect(
      LessonVideoCatalog.curated.forLesson('a1', languageCode: 'kk'),
      hasLength(1),
    );
    expect(
      LessonVideoCatalog.curated.forLesson('a2', languageCode: 'kk'),
      isEmpty,
    );
    expect(
      LessonVideoCatalog.curated.entries.every(
        (video) =>
            policy.validate(video, now: DateTime.utc(2026, 9, 12)).canDisplay,
      ),
      isTrue,
    );
  });

  test('CMS JSON round-trip retains mandatory governance metadata', () {
    final video = testLessonVideo();
    final restored = LessonVideo.fromJson(video.toJson());

    expect(restored.id, video.id);
    expect(restored.source.publisher, video.source.publisher);
    expect(restored.speaker.role, video.speaker.role);
    expect(restored.rights.basis, LessonVideoRightsBasis.permissionGranted);
    expect(restored.review.status, LessonVideoReviewStatus.approved);
    expect(policy.validate(restored, now: now).canDisplay, isTrue);
  });
}
