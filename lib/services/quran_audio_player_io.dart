import 'dart:async';

import 'package:just_audio/just_audio.dart';

class QuranAudioPlaybackState {
  final bool playing;
  final bool completed;
  final bool buffering;
  final Object? error;

  const QuranAudioPlaybackState({
    required this.playing,
    this.completed = false,
    this.buffering = false,
    this.error,
  });
}

class QuranAudioPlayer {
  final AudioPlayer _player = AudioPlayer();
  int _generation = 0;

  Stream<QuranAudioPlaybackState> get playbackStateStream =>
      _player.playerStateStream.map(
        (state) => QuranAudioPlaybackState(
          playing: state.playing,
          completed: state.processingState == ProcessingState.completed,
          buffering: state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering,
        ),
      );

  Future<void> setUrl(String url) {
    _generation++;
    return _player.setUrl(url);
  }

  Future<void> setFile(String path) {
    _generation++;
    return _player.setFilePath(path);
  }

  Future<void> playUrl(String url) async {
    final request = ++_generation;
    await _player.setUrl(url);
    if (request != _generation) return;
    await play();
  }

  Future<void> playFile(String path) async {
    final request = ++_generation;
    await _player.setFilePath(path);
    if (request != _generation) return;
    await play();
  }

  Future<void> play() async {
    final request = _generation;
    if (_player.processingState == ProcessingState.completed) {
      await _player.seek(Duration.zero);
      if (request != _generation) return;
    }
    final started = Completer<void>();
    late final StreamSubscription<PlayerState> subscription;
    subscription = _player.playerStateStream.listen((state) {
      if (state.playing &&
          state.processingState == ProcessingState.ready &&
          !started.isCompleted) {
        started.complete();
      }
    });
    unawaited(
      _player.play().catchError((Object error) {
        if (!started.isCompleted) started.completeError(error);
      }),
    );
    try {
      await started.future.timeout(const Duration(seconds: 8));
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> pause() => _player.pause();

  Future<void> stop() {
    _generation++;
    return _player.stop();
  }

  void dispose() {
    _generation++;
    _player.dispose();
  }
}
