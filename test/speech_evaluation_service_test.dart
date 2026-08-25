import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/models/speech_evaluation.dart';
import 'package:muslingo/services/speech_evaluation_service.dart';

void main() {
  test('remote evaluator sends recorded audio and accepts its transcript',
      () async {
    late Map<String, dynamic> requestBody;
    final client = MockClient((request) async {
      requestBody = Map<String, dynamic>.from(
        jsonDecode(request.body) as Map,
      );
      return http.Response.bytes(
        utf8.encode(jsonEncode({
          'transcript': 'بسم الله',
          'normalizedTranscript': 'بسمالله',
          'target': 'بِسْمِ اللَّهِ',
          'score': 100,
          'passed': true,
          'weakParts': <String>[],
          'feedbackText': 'Произношение принято.',
          'engine': 'serverAudioTranscription',
          'fallbackUsed': false,
        })),
        200,
        headers: {'content-type': 'application/json; charset=utf-8'},
      );
    });
    final service = SpeechEvaluationService(
      client: client,
      apiBaseUrl: 'https://api.example.test',
    );
    const step = LessonStep(
      type: LessonStepType.speak,
      arabicText: 'بِسْمِ اللَّهِ',
      speechMode: SpeechMode.quran,
    );

    final result = await service.evaluate(
      step: step,
      transcript: '',
      audioBytes: Uint8List.fromList([1, 2, 3, 4]),
    );

    expect(requestBody['audioBase64'], base64Encode([1, 2, 3, 4]));
    expect(requestBody['audioMimeType'], 'audio/webm');
    expect(result.transcript, 'بسم الله');
    expect(result.passed, isTrue);
    expect(result.fallbackUsed, isFalse);
    service.dispose();
  });

  test('audio capability is requested once and cached', () async {
    var requests = 0;
    final service = SpeechEvaluationService(
      apiBaseUrl: 'https://api.example.test',
      client: MockClient((request) async {
        requests++;
        expect(request.url.path, '/api/speech/capabilities');
        return http.Response('{"audioTranscription":true}', 200);
      }),
    );

    expect(await service.supportsAudioTranscription(), isTrue);
    expect(await service.supportsAudioTranscription(), isTrue);
    expect(requests, 1);
    service.dispose();
  });

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
