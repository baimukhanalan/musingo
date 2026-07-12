import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;

import '../models/lesson.dart';
import '../models/speech_evaluation.dart';
import 'backend_service.dart';
import 'speech_recorder.dart';

class SpeechEvaluationService {
  static const _configuredSpeechApiUrl =
      String.fromEnvironment('MUSLINGO_SPEECH_API_URL');

  final http.Client _client;
  final String apiBaseUrl;
  final SpeechRecorder _recorder;

  SpeechEvaluationService({
    http.Client? client,
    String? apiBaseUrl,
    SpeechRecorder? recorder,
  })  : _client = client ?? http.Client(),
        _recorder = recorder ?? SpeechRecorder(),
        apiBaseUrl = apiBaseUrl ??
            (_configuredSpeechApiUrl.isEmpty
                ? BackendService.apiBaseUrl
                : _configuredSpeechApiUrl);

  bool get isRecording => _recorder.isRecording;

  Future<void> record() => _recorder.start();

  Future<Uint8List?> stop() => _recorder.stop();

  Future<void> cancel() => _recorder.cancel();

  Future<SpeechEvaluationResult> evaluate({
    required LessonStep step,
    required String transcript,
    Uint8List? audioBytes,
    String? lessonId,
  }) async {
    final target = step.effectiveSpeechTarget;
    final isQuranSpeech =
        step.speechMode == SpeechMode.quran ||
        step.quranGlobalAyahNumber != null;
    final language = isQuranSpeech ? 'quran-ar' : 'arabic';
    try {
      if (audioBytes != null && audioBytes.isNotEmpty) {
        final request = http.MultipartRequest(
          'POST',
          Uri.parse('$apiBaseUrl/api/speech/evaluate'),
        )
          ..fields['target'] = target
          ..fields['transcript'] = transcript
          ..fields['lessonId'] = lessonId ?? ''
          ..fields['stepId'] = step.id ?? ''
          ..fields['language'] = language
          ..fields['passScore'] = '${step.effectivePassScore}'
          ..files.add(http.MultipartFile.fromBytes(
            'audio',
            audioBytes,
            filename: 'speech.webm',
          ));
        final streamed = await _client.send(request);
        final response = await http.Response.fromStream(streamed);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return SpeechEvaluationResult.fromJson(
            Map<String, dynamic>.from(jsonDecode(response.body) as Map),
          );
        }
      }
      final response = await _client.post(
        Uri.parse('$apiBaseUrl/api/speech/evaluate'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'target': target,
          'transcript': transcript,
          'lessonId': lessonId ?? '',
          'stepId': step.id ?? '',
          'language': language,
          'passScore': step.effectivePassScore,
        }),
      ).timeout(const Duration(seconds: 8));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return SpeechEvaluationResult.fromJson(
          Map<String, dynamic>.from(jsonDecode(response.body) as Map),
        );
      }
    } catch (_) {
      // Fall back to deterministic local scoring below.
    }
    return evaluateLocally(
      transcript: transcript,
      target: target,
      passScore: step.effectivePassScore,
    );
  }

  SpeechEvaluationResult evaluateLocally({
    required String transcript,
    required String target,
    required int passScore,
  }) {
    final normalizedTranscript = normalizeSpeech(transcript);
    final normalizedTarget = normalizeSpeech(target);
    final score = (_similarity(normalizedTranscript, normalizedTarget) * 100)
        .round()
        .clamp(0, 100)
        .toInt();
    final passed = transcript.trim().isNotEmpty && score >= passScore;
    return SpeechEvaluationResult(
      transcript: transcript,
      normalizedTranscript: normalizedTranscript,
      target: target,
      score: score,
      passed: passed,
      weakParts: passed ? const [] : _weakParts(normalizedTranscript, target),
      feedbackText: passed
          ? 'Произношение принято.'
          : transcript.trim().isEmpty
              ? 'Я не услышал фразу. Нажми микрофон и повтори ещё раз.'
              : 'Похоже не совпало с заданием. Повтори медленнее.',
      engine: SpeechEvaluationEngine.localFallback,
      fallbackUsed: true,
    );
  }

  String normalizeSpeech(String value) => value
      .toLowerCase()
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670]'), '')
      .replaceAll(RegExp(r'[^\u0600-\u06FFa-zа-яё0-9]+', unicode: true), '');

  double _similarity(String spoken, String target) {
    if (spoken.isEmpty || target.isEmpty) return 0;
    if (spoken.contains(target) || target.contains(spoken)) return 1;
    final spokenRunes = spoken.runes.toSet();
    final targetRunes = target.runes.toSet();
    final overlap = spokenRunes.intersection(targetRunes).length;
    final total = targetRunes.union(spokenRunes).length;
    return total == 0 ? 0 : overlap / total;
  }

  List<String> _weakParts(String normalizedTranscript, String target) {
    final words = target.split(RegExp(r'\s+')).where((word) => word.isNotEmpty);
    return words
        .where((word) => !normalizedTranscript.contains(normalizeSpeech(word)))
        .take(3)
        .toList(growable: false);
  }

  void dispose() => _client.close();
}
