enum SpeechEvaluationEngine { ai, localFallback }

class SpeechEvaluationResult {
  final String transcript;
  final String normalizedTranscript;
  final String target;
  final int score;
  final bool passed;
  final List<String> weakParts;
  final String feedbackText;
  final SpeechEvaluationEngine engine;
  final bool fallbackUsed;

  const SpeechEvaluationResult({
    required this.transcript,
    required this.normalizedTranscript,
    required this.target,
    required this.score,
    required this.passed,
    required this.weakParts,
    required this.feedbackText,
    required this.engine,
    required this.fallbackUsed,
  });

  factory SpeechEvaluationResult.fromJson(Map<String, dynamic> json) {
    final fallbackUsed = json['fallbackUsed'] == true;
    return SpeechEvaluationResult(
      transcript: json['transcript'] as String? ?? '',
      normalizedTranscript: json['normalizedTranscript'] as String? ?? '',
      target: json['target'] as String? ?? '',
      score: (json['score'] as num?)?.round() ?? 0,
      passed: json['passed'] == true,
      weakParts: (json['weakParts'] as List<dynamic>? ?? const [])
          .whereType<String>()
          .toList(growable: false),
      feedbackText: json['feedbackText'] as String? ?? '',
      engine: fallbackUsed
          ? SpeechEvaluationEngine.localFallback
          : SpeechEvaluationEngine.ai,
      fallbackUsed: fallbackUsed,
    );
  }

  Map<String, dynamic> toJson() => {
        'transcript': transcript,
        'normalizedTranscript': normalizedTranscript,
        'target': target,
        'score': score,
        'passed': passed,
        'weakParts': weakParts,
        'feedbackText': feedbackText,
        'engine': engine.name,
        'fallbackUsed': fallbackUsed,
      };
}
