import 'dart:async';

/// Owns one user playback request across source retries. Cancelling, replaying,
/// or leaving a lesson invalidates every pending retry/completion from it.
class AudioPlaybackSession {
  AudioPlaybackSession({
    required this.playUrl,
    required this.stopPlayer,
    this.startTimeout = const Duration(seconds: 8),
  });

  final Future<void> Function(String) playUrl;
  final Future<void> Function() stopPlayer;
  final Duration startTimeout;
  int _generation = 0;
  bool starting = false;

  Future<bool> play(List<String> sources) async {
    final request = ++_generation;
    starting = true;
    Object? lastError;
    try {
      for (final source in sources.toSet()) {
        if (request != _generation) return false;
        try {
          await playUrl(source).timeout(startTimeout);
          return request == _generation;
        } catch (error) {
          if (request != _generation) return false;
          lastError = error;
          await stopPlayer();
        }
      }
      if (request != _generation) return false;
      throw lastError ?? StateError('No audio source is available.');
    } finally {
      if (request == _generation) starting = false;
    }
  }

  void cancel() {
    _generation++;
    starting = false;
  }

  Future<void> stop() {
    cancel();
    return stopPlayer();
  }
}
