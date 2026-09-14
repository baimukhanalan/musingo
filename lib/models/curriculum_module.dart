class CurriculumModule {
  final String id;
  final String track;
  final String strand;
  final int sequence;
  final String title;
  final String objective;
  final String difficulty;
  final String prerequisite;
  final String sourceLocator;
  final String rightsStatus;
  final String reviewStatus;
  final String publicationStatus;
  final String videoNeed;
  final String speakerDomain;

  const CurriculumModule({
    required this.id,
    required this.track,
    required this.strand,
    required this.sequence,
    required this.title,
    required this.objective,
    required this.difficulty,
    required this.prerequisite,
    required this.sourceLocator,
    required this.rightsStatus,
    required this.reviewStatus,
    required this.publicationStatus,
    this.videoNeed = '',
    this.speakerDomain = '',
  });

  factory CurriculumModule.fromJson(Map<String, dynamic> json) =>
      CurriculumModule(
        id: json['module_id'] as String? ?? '',
        track: json['track'] as String? ?? '',
        strand: json['strand'] as String? ?? '',
        sequence: (json['sequence'] as num?)?.round() ?? 0,
        title: json['module_title'] as String? ?? '',
        objective: json['learning_objective'] as String? ?? '',
        difficulty: json['difficulty'] as String? ?? '',
        prerequisite: json['prerequisite'] as String? ?? '',
        sourceLocator: json['source_locator'] as String? ?? '',
        rightsStatus: json['rights_status'] as String? ?? '',
        reviewStatus: json['review_status'] as String? ?? '',
        publicationStatus: json['publication_status'] as String? ?? '',
        videoNeed: json['video_need'] as String? ?? '',
        speakerDomain: json['speaker_domain'] as String? ?? '',
      );
}
