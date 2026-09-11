import '../models/lesson_video.dart';

class LessonVideoValidation {
  final List<String> errors;

  const LessonVideoValidation(this.errors);

  bool get canDisplay => errors.isEmpty;
}

class LessonVideoPolicy {
  static final RegExp _youtubeId = RegExp(r'^[A-Za-z0-9_-]{6,20}$');
  static final RegExp _vimeoId = RegExp(r'^\d{5,20}$');

  const LessonVideoPolicy();

  LessonVideoValidation validate(LessonVideo video, {DateTime? now}) {
    final errors = <String>[];
    final embed = Uri.tryParse(video.embedUrl);
    final source = Uri.tryParse(video.source.url);

    if (video.id.trim().isEmpty || video.lessonId.trim().isEmpty) {
      errors.add('Video and lesson identifiers are required.');
    }
    if (video.title.trim().isEmpty || video.title.length > 160) {
      errors.add('Video title is missing or too long.');
    }
    if (video.topic.trim().isEmpty || video.topic.length > 160) {
      errors.add('Video topic is missing or too long.');
    }
    if (!_isLanguageCode(video.languageCode)) {
      errors.add('Transcript language code is invalid.');
    }
    if (video.transcript.trim().length < 20 ||
        video.transcript.length > 100000) {
      errors.add('A usable text transcript is required.');
    }
    if (video.speaker.name.trim().isEmpty ||
        video.speaker.role.trim().isEmpty) {
      errors.add('Speaker metadata is incomplete.');
    }
    if (video.source.title.trim().isEmpty ||
        video.source.publisher.trim().isEmpty) {
      errors.add('Source metadata is incomplete.');
    }

    final embedId = _validatedEmbedId(video.provider, embed);
    if (embedId == null) {
      errors.add('Embed URL is not an allowlisted HTTPS provider URL.');
    }
    final sourceId = _validatedSourceId(video.provider, source);
    if (sourceId == null || sourceId != embedId) {
      errors.add('Source URL must match the allowlisted provider and video.');
    }

    if (video.rights.holder.trim().isEmpty ||
        video.rights.label.trim().isEmpty ||
        !_isPlainHttpsUrl(video.rights.evidenceUrl)) {
      errors.add('Rights metadata or evidence is incomplete.');
    }
    if (video.review.status != LessonVideoReviewStatus.approved ||
        video.review.reviewer.trim().isEmpty ||
        video.review.standard.trim().isEmpty) {
      errors.add('Video has not passed editorial review.');
    }

    final clock = now ?? DateTime.now();
    if (video.rights.confirmedAt.isAfter(clock.add(const Duration(days: 1)))) {
      errors.add('Rights confirmation date is invalid.');
    }
    if (video.review.reviewedAt.isAfter(clock.add(const Duration(days: 1)))) {
      errors.add('Review date is invalid.');
    }
    return LessonVideoValidation(List.unmodifiable(errors));
  }

  String? _validatedEmbedId(LessonVideoProvider provider, Uri? uri) {
    if (!_isStrictHttps(uri) || uri!.query.isNotEmpty) return null;
    final segments = uri.pathSegments;
    switch (provider) {
      case LessonVideoProvider.youtubeNoCookie:
        if (uri.host != 'www.youtube-nocookie.com' ||
            segments.length != 2 ||
            segments.first != 'embed' ||
            !_youtubeId.hasMatch(segments.last)) {
          return null;
        }
        return segments.last;
      case LessonVideoProvider.vimeo:
        if (uri.host != 'player.vimeo.com' ||
            segments.length != 2 ||
            segments.first != 'video' ||
            !_vimeoId.hasMatch(segments.last)) {
          return null;
        }
        return segments.last;
    }
  }

  String? _validatedSourceId(LessonVideoProvider provider, Uri? uri) {
    if (!_isStrictHttps(uri)) return null;
    switch (provider) {
      case LessonVideoProvider.youtubeNoCookie:
        if (uri!.host == 'youtu.be' &&
            uri.pathSegments.length == 1 &&
            uri.query.isEmpty &&
            _youtubeId.hasMatch(uri.pathSegments.single)) {
          return uri.pathSegments.single;
        }
        if ((uri.host == 'www.youtube.com' || uri.host == 'youtube.com') &&
            uri.path == '/watch' &&
            uri.queryParameters.length == 1) {
          final id = uri.queryParameters['v'];
          return id != null && _youtubeId.hasMatch(id) ? id : null;
        }
        return null;
      case LessonVideoProvider.vimeo:
        if ((uri!.host == 'vimeo.com' || uri.host == 'www.vimeo.com') &&
            uri.pathSegments.length == 1 &&
            uri.query.isEmpty &&
            _vimeoId.hasMatch(uri.pathSegments.single)) {
          return uri.pathSegments.single;
        }
        return null;
    }
  }

  bool _isStrictHttps(Uri? uri) {
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        (!uri.hasPort || uri.port == 443) &&
        uri.fragment.isEmpty;
  }

  bool _isPlainHttpsUrl(String value) {
    final uri = Uri.tryParse(value);
    return _isStrictHttps(uri);
  }

  bool _isLanguageCode(String value) =>
      RegExp(r'^[a-z]{2,3}(-[A-Z]{2})?$').hasMatch(value);
}

/// Empty by default. A future CMS can hydrate [LessonVideo] records from JSON;
/// only records that pass [LessonVideoPolicy] are exposed to lesson screens.
class LessonVideoCatalog {
  final List<LessonVideo> entries;
  final LessonVideoPolicy policy;

  const LessonVideoCatalog({
    this.entries = const [],
    this.policy = const LessonVideoPolicy(),
  });

  List<LessonVideo> forLesson(String lessonId) => entries
      .where((video) =>
          video.lessonId == lessonId && policy.validate(video).canDisplay)
      .toList(growable: false);
}
