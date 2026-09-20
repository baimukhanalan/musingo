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
  final AudioPlayer _player;
  final _states = StreamController<QuranAudioPlaybackState>.broadcast();
  late final StreamSubscription<PlayerState> _stateSubscription;
  late final StreamSubscription<PlayerException> _errorSubscription;
  int _generation = 0;
  bool _starting = false;

  QuranAudioPlayer({AudioPlayer? player}) : _player = player ?? AudioPlayer() {
    _stateSubscription = _player.playerStateStream.listen((state) {
      if (!_states.isClosed) {
        _states.add(QuranAudioPlaybackState(
          playing: state.playing &&
              state.processingState != ProcessingState.completed,
          completed: state.processingState == ProcessingState.completed,
          buffering: state.processingState == ProcessingState.loading ||
              state.processingState == ProcessingState.buffering,
        ));
      }
    });
    // just_audio reports decoder/network interruptions separately from its
    // player state. Forward late errors, but let startup futures own retries.
    _errorSubscription = _player.errorStream.listen((error) {
      if (!_starting && !_states.isClosed) {
        _states.add(QuranAudioPlaybackState(playing: false, error: error));
      }
    });
  }

  Stream<QuranAudioPlaybackState> get playbackStateStream => _states.stream;

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
    _starting = true;
    try {
      await _player.setUrl(url);
      if (request != _generation) return;
      await play();
    } finally {
      if (request == _generation) _starting = false;
    }
  }

  Future<void> playFile(String path) async {
    final request = ++_generation;
    _starting = true;
    try {
      await _player.setFilePath(path);
      if (request != _generation) return;
      await play();
    } finally {
      if (request == _generation) _starting = false;
    }
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
    _starting = false;
    return _player.stop();
  }

  void dispose() {
    _generation++;
    _stateSubscription.cancel();
    _errorSubscription.cancel();
    _states.close();
    _player.dispose();
  }
}
