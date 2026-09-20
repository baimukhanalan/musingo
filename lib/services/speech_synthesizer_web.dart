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
  web.SpeechSynthesisUtterance? _utterance;
  Completer<int>? _pending;
  int _generation = 0;

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
    _cancelCurrent();
    final request = ++_generation;
    final completer = _awaitCompletion ? Completer<int>() : null;
    _pending = completer;
    final utterance = web.SpeechSynthesisUtterance(text)
      ..lang = _language
      ..rate = _rate
      ..pitch = _pitch
      ..volume = _volume;
    utterance.onend = ((web.SpeechSynthesisEvent _) {
      if (request != _generation) return;
      _releaseCurrent();
      _completionHandler?.call();
      if (completer != null && !completer.isCompleted) completer.complete(1);
    }).toJS;
    utterance.onerror = ((web.SpeechSynthesisErrorEvent event) {
      if (request != _generation) return;
      _releaseCurrent();
      final message = event.error;
      _errorHandler?.call(message);
      if (completer != null && !completer.isCompleted) {
        completer
            .completeError(StateError('Speech synthesis failed: $message'));
      }
    }).toJS;
    // Keep a strong reference while speaking. Some browsers can otherwise
    // collect an utterance before delivering its completion callback.
    _utterance = utterance;
    web.window.speechSynthesis.speak(utterance);
    if (completer != null) return await completer.future;
    return 1;
  }

  Future<void> stop() async {
    _cancelCurrent();
  }

  void _releaseCurrent() {
    _utterance?.onend = null;
    _utterance?.onerror = null;
    _utterance = null;
    _pending = null;
  }

  void _cancelCurrent() {
    _generation++;
    final hadUtterance = _utterance != null;
    final pending = _pending;
    // Detach callbacks before cancel(): an intentional stop is not an error.
    _releaseCurrent();
    if (pending != null && !pending.isCompleted) pending.complete(0);
    if (hadUtterance) web.window.speechSynthesis.cancel();
  }
}
