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
  bool? _audioTranscriptionAvailable;

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

  Future<bool> supportsAudioTranscription() async {
    if (!hasRemoteEvaluator) return false;
    final cached = _audioTranscriptionAvailable;
    if (cached != null) return cached;
    try {
      final response = await _client.get(
        Uri.parse('$apiBaseUrl/api/speech/capabilities'),
        headers: const {'Accept': 'application/json'},
      ).timeout(const Duration(seconds: 4));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        final body = Map<String, dynamic>.from(
          jsonDecode(response.body) as Map,
        );
        return _audioTranscriptionAvailable =
            body['audioTranscription'] == true;
      }
    } catch (_) {
      // A missing capability endpoint means audio upload is not safe to use.
    }
    return _audioTranscriptionAvailable = false;
  }

  Future<SpeechEvaluationResult> evaluate({
    required LessonStep step,
    required String transcript,
    Uint8List? audioBytes,
    String? lessonId,
  }) async {
    final target = step.effectiveSpeechTarget;
    final phoneticTarget = step.transliteration?.trim() ?? '';
    final isQuranSpeech = step.speechMode == SpeechMode.quran ||
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
      final encodedAudio = audioBytes == null || audioBytes.isEmpty
          ? null
          : base64Encode(audioBytes);
      final response = await _client
          .post(
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
              if (encodedAudio != null) 'audioBase64': encodedAudio,
              if (encodedAudio != null)
                'audioMimeType': _recorder.mimeType ?? 'audio/webm',
            }),
          )
          .timeout(const Duration(seconds: 8));
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
    final regularSimilarity = _similarity(
      normalizedTranscript,
      normalizedTarget,
    );
    final vowelSimilarity = _similarity(
      _normalizeArabicVowelHints(transcript),
      _normalizeArabicVowelHints(target),
    );
    final phoneticSimilarity = _similarity(
      _normalizePhonetic(transcript),
      _normalizePhonetic(phoneticTarget),
    );
    final similarity = [
      regularSimilarity,
      vowelSimilarity,
      phoneticSimilarity,
    ].reduce((best, value) => best > value ? best : value);
    final score = (similarity * 100).round().clamp(0, 100).toInt();
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
      .replaceAll(RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
      .replaceAll(RegExp(r'[یى]'), 'ي')
      .replaceAll('ک', 'ك')
      .replaceAll('ё', 'е')
      .replaceAll(RegExp(r'[^\u0600-\u06FFa-zа-яе0-9]+', unicode: true), '');

  String _normalizeArabicVowelHints(String value) => value
      .toLowerCase()
      .replaceAll('\u064B', 'ان')
      .replaceAll('\u064C', 'ون')
      .replaceAll('\u064D', 'ين')
      .replaceAll('\u064E', 'ا')
      .replaceAll('\u064F', 'و')
      .replaceAll('\u0650', 'ي')
      .replaceAll(RegExp(r'[\u0651-\u065F\u0670\u06D6-\u06ED]'), '')
      .replaceAll(RegExp(r'[یى]'), 'ي')
      .replaceAll('ک', 'ك')
      .replaceAll(RegExp(r'[^\u0600-\u06FF]+', unicode: true), '');

  String _normalizePhonetic(String value) {
    const cyrillicToLatin = <String, String>{
      'а': 'a',
      'б': 'b',
      'в': 'v',
      'г': 'g',
      'д': 'd',
      'е': 'e',
      'ё': 'yo',
      'ж': 'zh',
      'з': 'z',
      'и': 'i',
      'й': 'y',
      'к': 'k',
      'л': 'l',
      'м': 'm',
      'н': 'n',
      'о': 'o',
      'п': 'p',
      'р': 'r',
      'с': 's',
      'т': 't',
      'у': 'u',
      'ф': 'f',
      'х': 'kh',
      'ц': 'ts',
      'ч': 'ch',
      'ш': 'sh',
      'щ': 'sh',
      'ы': 'y',
      'э': 'e',
      'ю': 'yu',
      'я': 'ya',
      'ъ': '',
      'ь': '',
    };
    final buffer = StringBuffer();
    for (final rune in value.toLowerCase().runes) {
      final character = String.fromCharCode(rune);
      buffer.write(cyrillicToLatin[character] ?? character);
    }
    return buffer.toString().replaceAll(RegExp(r'[^a-z0-9]+'), '');
  }

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
    if (target.runes.length >= 8 && spoken.contains(target)) return 1;
    final distance = _levenshteinDistance(spoken, target);
    final longest =
        spoken.length > target.length ? spoken.length : target.length;
    final editSimilarity = longest == 0 ? 0.0 : 1 - (distance / longest);
    final spokenRunes = spoken.runes.toSet();
    final targetRunes = target.runes.toSet();
    final overlap = spokenRunes.intersection(targetRunes).length;
    final total = targetRunes.union(spokenRunes).length;
    final setSimilarity = total == 0 ? 0.0 : overlap / total;
    final shortest =
        spoken.length < target.length ? spoken.length : target.length;
    final coverage = longest == 0 ? 0.0 : shortest / longest;
    final coveragePenalty = (coverage * 1.15).clamp(0.0, 1.0);
    final raw = editSimilarity > setSimilarity ? editSimilarity : setSimilarity;
    return raw * coveragePenalty;
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
