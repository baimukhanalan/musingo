import 'package:muslingo/models/lesson_video.dart';

LessonVideo testLessonVideo({
  String id = 'video-1',
  String lessonId = 'lesson-1',
  String embedUrl = 'https://www.youtube-nocookie.com/embed/abc123XYZ00',
  String sourceUrl = 'https://youtu.be/abc123XYZ00',
  String transcript =
      'This fixture transcript is long enough to provide a complete text alternative.',
  String rightsEvidenceUrl = 'https://example.org/permission/video-1',
  LessonVideoReviewStatus reviewStatus = LessonVideoReviewStatus.approved,
}) {
  return LessonVideo(
    id: id,
    lessonId: lessonId,
    title: 'How the lesson works',
    topic: 'Arabic reading practice',
    languageCode: 'en',
    provider: LessonVideoProvider.youtubeNoCookie,
    embedUrl: embedUrl,
    transcript: transcript,
    source: LessonVideoSource(
      title: 'Original publication',
      publisher: 'Fixture publisher',
      url: sourceUrl,
    ),
    speaker: const LessonVideoSpeaker(
      name: 'Fixture speaker',
      role: 'Reviewed educator',
    ),
    rights: LessonVideoRights(
      holder: 'Fixture rights holder',
      basis: LessonVideoRightsBasis.permissionGranted,
      label: 'Permission recorded',
      evidenceUrl: rightsEvidenceUrl,
      confirmedAt: DateTime.utc(2026, 9, 1),
    ),
    review: LessonVideoReview(
      status: reviewStatus,
      reviewer: 'Fixture reviewer',
      standard: 'Educational and source review',
      reviewedAt: DateTime.utc(2026, 9, 2),
    ),
  );
}
