enum LessonVideoProvider { youtubeNoCookie, vimeo }

enum LessonVideoRightsBasis {
  owned,
  licensed,
  permissionGranted,
  publicDomain,
}

enum LessonVideoReviewStatus { draft, pending, approved, rejected }

class LessonVideoSource {
  final String title;
  final String publisher;
  final String url;

  const LessonVideoSource({
    required this.title,
    required this.publisher,
    required this.url,
  });

  Map<String, dynamic> toJson() => {
        'title': title,
        'publisher': publisher,
        'url': url,
      };

  factory LessonVideoSource.fromJson(Map<String, dynamic> json) =>
      LessonVideoSource(
        title: _requiredString(json, 'title'),
        publisher: _requiredString(json, 'publisher'),
        url: _requiredString(json, 'url'),
      );
}

class LessonVideoSpeaker {
  final String name;
  final String role;

  const LessonVideoSpeaker({required this.name, required this.role});

  Map<String, dynamic> toJson() => {'name': name, 'role': role};

  factory LessonVideoSpeaker.fromJson(Map<String, dynamic> json) =>
      LessonVideoSpeaker(
        name: _requiredString(json, 'name'),
        role: _requiredString(json, 'role'),
      );
}

class LessonVideoRights {
  final String holder;
  final LessonVideoRightsBasis basis;
  final String label;
  final String evidenceUrl;
  final DateTime confirmedAt;

  const LessonVideoRights({
    required this.holder,
    required this.basis,
    required this.label,
    required this.evidenceUrl,
    required this.confirmedAt,
  });

  Map<String, dynamic> toJson() => {
        'holder': holder,
        'basis': basis.name,
        'label': label,
        'evidenceUrl': evidenceUrl,
        'confirmedAt': confirmedAt.toUtc().toIso8601String(),
      };

  factory LessonVideoRights.fromJson(Map<String, dynamic> json) =>
      LessonVideoRights(
        holder: _requiredString(json, 'holder'),
        basis: LessonVideoRightsBasis.values.byName(
          _requiredString(json, 'basis'),
        ),
        label: _requiredString(json, 'label'),
        evidenceUrl: _requiredString(json, 'evidenceUrl'),
        confirmedAt: _requiredDate(json, 'confirmedAt'),
      );
}

class LessonVideoReview {
  final LessonVideoReviewStatus status;
  final String reviewer;
  final String standard;
  final DateTime reviewedAt;

  const LessonVideoReview({
    required this.status,
    required this.reviewer,
    required this.standard,
    required this.reviewedAt,
  });

  Map<String, dynamic> toJson() => {
        'status': status.name,
        'reviewer': reviewer,
        'standard': standard,
        'reviewedAt': reviewedAt.toUtc().toIso8601String(),
      };

  factory LessonVideoReview.fromJson(Map<String, dynamic> json) =>
      LessonVideoReview(
        status: LessonVideoReviewStatus.values.byName(
          _requiredString(json, 'status'),
        ),
        reviewer: _requiredString(json, 'reviewer'),
        standard: _requiredString(json, 'standard'),
        reviewedAt: _requiredDate(json, 'reviewedAt'),
      );
}

class LessonVideo {
  final String id;
  final String lessonId;
  final String title;
  final String topic;
  final String languageCode;
  final LessonVideoProvider provider;
  final String embedUrl;
  final String transcript;
  final LessonVideoSource source;
  final LessonVideoSpeaker speaker;
  final LessonVideoRights rights;
  final LessonVideoReview review;

  const LessonVideo({
    required this.id,
    required this.lessonId,
    required this.title,
    required this.topic,
    required this.languageCode,
    required this.provider,
    required this.embedUrl,
    required this.transcript,
    required this.source,
    required this.speaker,
    required this.rights,
    required this.review,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'lessonId': lessonId,
        'title': title,
        'topic': topic,
        'languageCode': languageCode,
        'provider': provider.name,
        'embedUrl': embedUrl,
        'transcript': transcript,
        'source': source.toJson(),
        'speaker': speaker.toJson(),
        'rights': rights.toJson(),
        'review': review.toJson(),
      };

  factory LessonVideo.fromJson(Map<String, dynamic> json) => LessonVideo(
        id: _requiredString(json, 'id'),
        lessonId: _requiredString(json, 'lessonId'),
        title: _requiredString(json, 'title'),
        topic: _requiredString(json, 'topic'),
        languageCode: _requiredString(json, 'languageCode'),
        provider: LessonVideoProvider.values.byName(
          _requiredString(json, 'provider'),
        ),
        embedUrl: _requiredString(json, 'embedUrl'),
        transcript: _requiredString(json, 'transcript'),
        source: LessonVideoSource.fromJson(_requiredMap(json, 'source')),
        speaker: LessonVideoSpeaker.fromJson(_requiredMap(json, 'speaker')),
        rights: LessonVideoRights.fromJson(_requiredMap(json, 'rights')),
        review: LessonVideoReview.fromJson(_requiredMap(json, 'review')),
      );
}

String _requiredString(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! String || value.trim().isEmpty) {
    throw FormatException('Missing or empty $key');
  }
  return value.trim();
}

Map<String, dynamic> _requiredMap(Map<String, dynamic> json, String key) {
  final value = json[key];
  if (value is! Map) throw FormatException('Missing $key object');
  return Map<String, dynamic>.from(value);
}

DateTime _requiredDate(Map<String, dynamic> json, String key) {
  final value = _requiredString(json, key);
  final parsed = DateTime.tryParse(value);
  if (parsed == null) throw FormatException('Invalid $key');
  return parsed;
}
