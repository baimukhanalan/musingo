import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/models/speech_evaluation.dart';
import 'package:muslingo/services/speech_evaluation_service.dart';

void main() {
  test('local speech scoring accepts phonetic Quran transliteration', () {
    final service = SpeechEvaluationService();
    final result = service.evaluateLocally(
      transcript: 'бисмилляхи р рахмани р рахим',
      target: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      phoneticTarget: 'Бисмилляхи р-рахмани р-рахим',
      passScore: 70,
    );

    expect(result.passed, isTrue);
    expect(result.score, greaterThanOrEqualTo(70));
    service.dispose();
  });

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

  test('a single recognized letter does not pass a full ayah at 100%', () {
    // Regression guard: previously any substring of the target (e.g. one
    // letter) short-circuited similarity to 1.0 and passed the step.
    final service = SpeechEvaluationService();
    final result = service.evaluateLocally(
      transcript: 'م',
      target: 'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
      passScore: 70,
    );

    expect(result.score, lessThan(50));
    expect(result.passed, isFalse);
    service.dispose();
  });
}
