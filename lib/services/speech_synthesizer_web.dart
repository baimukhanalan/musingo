import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

class SpeechSynthesizer {
  String _language = 'ar-SA';
  double _rate = 1;
  double _pitch = 1;
  double _volume = 1;
  bool _awaitCompletion = false;
  void Function()? _completionHandler;
  void Function(String message)? _errorHandler;

  void setCompletionHandler(void Function() handler) {
    _completionHandler = handler;
  }

  void setErrorHandler(void Function(String message) handler) {
    _errorHandler = handler;
  }

  Future<void> setLanguage(String language) async {
    _language = language;
  }

  Future<void> setSpeechRate(double rate) async {
    _rate = rate;
  }

  Future<void> setPitch(double pitch) async {
    _pitch = pitch;
  }

  Future<void> setVolume(double volume) async {
    _volume = volume;
  }

  Future<void> awaitSpeakCompletion(bool enabled) async {
    _awaitCompletion = enabled;
  }

  Future<int> speak(String text) async {
    if (text.trim().isEmpty) return 0;
    final completer = Completer<int>();
    final utterance = web.SpeechSynthesisUtterance(text)
      ..lang = _language
      ..rate = _rate
      ..pitch = _pitch
      ..volume = _volume;
    utterance.onend = ((web.SpeechSynthesisEvent _) {
      _completionHandler?.call();
      if (!completer.isCompleted) completer.complete(1);
    }).toJS;
    utterance.onerror = ((web.SpeechSynthesisErrorEvent event) {
      final message = event.error;
      _errorHandler?.call(message);
      if (!completer.isCompleted) {
        completer
            .completeError(StateError('Speech synthesis failed: $message'));
      }
    }).toJS;
    web.window.speechSynthesis.speak(utterance);
    if (_awaitCompletion) return await completer.future;
    return 1;
  }

  Future<void> stop() async {
    web.window.speechSynthesis.cancel();
  }
}
