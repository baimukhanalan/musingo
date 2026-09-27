import '../models/lesson_video.dart';
import 'academy_lecture_catalog.dart';

/// A timed view of an original provider-hosted video, not a copied clip.
class LessonVideoSegment {
  final int number;
  final int total;
  final int startSeconds;
  final int endSeconds;

  const LessonVideoSegment({
    required this.number,
    required this.total,
    required this.startSeconds,
    required this.endSeconds,
  });

  int get durationSeconds => endSeconds - startSeconds;

  Uri playbackUri(LessonVideo video) {
    if (video.provider != LessonVideoProvider.youtubeNoCookie ||
        startSeconds < 0 ||
        endSeconds <= startSeconds ||
        durationSeconds > 360) {
      throw ArgumentError('Invalid timed YouTube segment');
    }
    final base = Uri.parse(video.embedUrl);
    if (base.query.isNotEmpty || base.fragment.isNotEmpty) {
      throw ArgumentError('Video embed must be canonical');
    }
    return base.replace(queryParameters: {
      if (startSeconds > 0) 'start': '$startSeconds',
      'end': '$endSeconds',
    });
  }
}

/// Duration is from each publisher's public YouTube watch-page metadata,
/// checked on 2026-09-27. Keep it explicit: unknown videos are never split
/// against a guessed duration. Segments are neutral time ranges, not claims
/// that a particular religious rule begins at a particular timestamp.
const Map<String, int> reviewedVideoDurationSeconds = {
  'ruslan-arabic-alphabet': 310,
  'erlan-quran-alippesi-01': 320,
  'ruslan-harakat': 942,
  'ruslan-letter-ayn': 839,
  'ruslan-tanwin': 849,
  'ruslan-tashdid': 794,
  'ruslan-madd': 1305,
  'ruslan-tajwid-intro': 948,
  'ruslan-izhar': 1081,
  'ruslan-idgham-with-ghunnah': 1055,
  'ruslan-idgham-without-ghunnah': 1055,
  'ruslan-iqlab': 550,
  'ruslan-mim-sakinah': 1167,
  'matched-r1': 537,
  'matched-r5': 361,
  'matched-r9': 403,
};

/// At most six minutes per part. Balanced boundaries avoid a tiny last part.
/// The learner can still select the uncut original video separately.
List<LessonVideoSegment> lessonVideoSegments(LessonVideo video) {
  final duration = reviewedVideoDurationSeconds[video.id] ??
      AcademyLectureCatalog.byYoutubeId(
              Uri.tryParse(video.embedUrl)?.pathSegments.lastOrNull ?? '')
          ?.durationSeconds;
  if (video.provider != LessonVideoProvider.youtubeNoCookie ||
      duration == null ||
      duration <= 360) {
    return const [];
  }
  final count = (duration + 359) ~/ 360;
  return List.generate(count, (index) {
    final start = duration * index ~/ count;
    final end = duration * (index + 1) ~/ count;
    return LessonVideoSegment(
      number: index + 1,
      total: count,
      startSeconds: start,
      endSeconds: end,
    );
  }, growable: false);
}

String lessonVideoTimecode(int seconds) {
  final minutes = seconds ~/ 60;
  final remainder = seconds % 60;
  return '$minutes:${remainder.toString().padLeft(2, '0')}';
}
