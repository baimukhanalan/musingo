import 'dart:convert';

import 'package:flutter/foundation.dart';
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
  final bool _hasExplicitApiBaseUrl;

  SpeechEvaluationService({
    http.Client? client,
    String? apiBaseUrl,
    SpeechRecorder? recorder,
  })  : _client = client ?? http.Client(),
        _recorder = recorder ?? SpeechRecorder(),
        _hasExplicitApiBaseUrl = apiBaseUrl != null && apiBaseUrl.isNotEmpty,
        apiBaseUrl = apiBaseUrl ??
            (_configuredSpeechApiUrl.isEmpty
                ? BackendService.apiBaseUrl
                : _configuredSpeechApiUrl);

  bool get isRecording => _recorder.isRecording;

  bool get hasRemoteEvaluator =>
      _hasExplicitApiBaseUrl ||
      _configuredSpeechApiUrl.isNotEmpty ||
      BackendService.hasConfiguredApiUrl ||
      !kIsWeb;

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
    final phoneticTarget = step.transliteration?.trim() ?? '';
    final isQuranSpeech =
        step.speechMode == SpeechMode.quran ||
        step.quranGlobalAyahNumber != null;
    final language = isQuranSpeech ? 'quran-ar' : 'arabic';
    try {
      if (!hasRemoteEvaluator) {
        return evaluateLocally(
          transcript: transcript,
          target: target,
          phoneticTarget: phoneticTarget,
          passScore: step.effectivePassScore,
        );
      }
      // The /api/speech/evaluate endpoint only parses JSON and only performs a
      // text (Levenshtein) comparison; it ignores any uploaded audio. The old
      // multipart request therefore always failed with 400 invalid_json before
      // silently retrying as text. We send a single JSON request instead.
      // Real audio-based AI scoring is a separate, unimplemented feature.
      final response = await _client.post(
        Uri.parse('$apiBaseUrl/api/speech/evaluate'),
        headers: const {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'target': target,
          'phoneticTarget': phoneticTarget,
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
      phoneticTarget: phoneticTarget,
      passScore: step.effectivePassScore,
    );
  }

  SpeechEvaluationResult evaluateLocally({
    required String transcript,
    required String target,
    String phoneticTarget = '',
    required int passScore,
  }) {
    final normalizedTranscript = normalizeSpeech(transcript);
    final normalizedTarget = _bestNormalizedTarget(
      normalizedTranscript,
      [target, phoneticTarget],
    );
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
      .replaceAll('ё', 'е')
      .replaceAll(RegExp(r'[^\u0600-\u06FFa-zа-яе0-9]+', unicode: true), '');

  String _bestNormalizedTarget(String transcript, List<String> targets) {
    var best = '';
    var bestScore = 0.0;
    for (final target in targets) {
      final normalized = normalizeSpeech(target);
      if (normalized.isEmpty) continue;
      final score = _similarity(transcript, normalized);
      if (score >= bestScore) {
        best = normalized;
        bestScore = score;
      }
    }
    return best;
  }

  double _similarity(String spoken, String target) {
    if (spoken.isEmpty || target.isEmpty) return 0;
    // A full normalized match already scores 1.0 through the edit metric below
    // (distance 0). We intentionally do NOT short-circuit on substring
    // containment: a single recognized letter that happens to appear in the
    // target must not score a long ayah at 100%. Partial overlap flows through
    // to the regular Levenshtein / character-set similarity instead.
    final distance = _levenshteinDistance(spoken, target);
    final longest = spoken.length > target.length ? spoken.length : target.length;
    final editSimilarity = longest == 0 ? 0.0 : 1 - (distance / longest);
    final spokenRunes = spoken.runes.toSet();
    final targetRunes = target.runes.toSet();
    final overlap = spokenRunes.intersection(targetRunes).length;
    final total = targetRunes.union(spokenRunes).length;
    final setSimilarity = total == 0 ? 0.0 : overlap / total;
    return editSimilarity > setSimilarity ? editSimilarity : setSimilarity;
  }

  int _levenshteinDistance(String a, String b) {
    final aRunes = a.runes.toList(growable: false);
    final bRunes = b.runes.toList(growable: false);
    if (aRunes.isEmpty) return bRunes.length;
    if (bRunes.isEmpty) return aRunes.length;
    var previous = List<int>.generate(bRunes.length + 1, (index) => index);
    for (var i = 0; i < aRunes.length; i++) {
      final current = List<int>.filled(bRunes.length + 1, 0);
      current[0] = i + 1;
      for (var j = 0; j < bRunes.length; j++) {
        final cost = aRunes[i] == bRunes[j] ? 0 : 1;
        final deletion = previous[j + 1] + 1;
        final insertion = current[j] + 1;
        final substitution = previous[j] + cost;
        current[j + 1] = [deletion, insertion, substitution].reduce(
          (value, element) => value < element ? value : element,
        );
      }
      previous = current;
    }
    return previous.last;
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
