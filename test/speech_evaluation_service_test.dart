import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/models/speech_evaluation.dart';
import 'package:muslingo/services/speech_evaluation_service.dart';

void main() {
  test('local fallback scores speech against the configured pass score', () {
    final service = SpeechEvaluationService();
    const step = LessonStep(
      type: LessonStepType.speak,
      arabicText: 'بِسْمِ اللَّهِ',
      transliteration: 'Бисмиллях',
      speechMode: SpeechMode.quran,
    );

    final passed = service.evaluateLocally(
      transcript: 'بسم الله',
      target: step.effectiveSpeechTarget,
      passScore: step.effectivePassScore,
    );
    final failed = service.evaluateLocally(
      transcript: 'алхамдулиллях',
      target: step.effectiveSpeechTarget,
      passScore: step.effectivePassScore,
    );

    expect(passed.engine, SpeechEvaluationEngine.localFallback);
    expect(passed.fallbackUsed, isTrue);
    expect(passed.passed, isTrue);
    expect(failed.passed, isFalse);
    expect(failed.feedbackText, isNotEmpty);
    service.dispose();
  });
}
