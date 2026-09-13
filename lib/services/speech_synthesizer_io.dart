import 'package:flutter_tts/flutter_tts.dart';

class SpeechSynthesizer {
  final FlutterTts _tts = FlutterTts();

  void setCompletionHandler(void Function() handler) =>
      _tts.setCompletionHandler(handler);

  void setErrorHandler(void Function(String message) handler) =>
      _tts.setErrorHandler((message) => handler('$message'));

  Future<void> setLanguage(String language) async {
    await _tts.setLanguage(language);
  }

  Future<void> setSpeechRate(double rate) async {
    await _tts.setSpeechRate(rate);
  }

  Future<void> setPitch(double pitch) async {
    await _tts.setPitch(pitch);
  }

  Future<void> setVolume(double volume) async {
    await _tts.setVolume(volume);
  }

  Future<void> awaitSpeakCompletion(bool enabled) async {
    await _tts.awaitSpeakCompletion(enabled);
  }

  Future<int> speak(String text) async {
    final result = await _tts.speak(text);
    return result == 1 ? 1 : 0;
  }

  Future<void> stop() async {
    await _tts.stop();
  }
}
