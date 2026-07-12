import 'dart:async';

import 'package:just_audio/just_audio.dart';

class QuranAudioPlaybackState {
  final bool playing;
  final bool completed;

  const QuranAudioPlaybackState({
    required this.playing,
    this.completed = false,
  });
}

class QuranAudioPlayer {
  final AudioPlayer _player = AudioPlayer();

  Stream<QuranAudioPlaybackState> get playbackStateStream =>
      _player.playerStateStream.map(
        (state) => QuranAudioPlaybackState(
          playing: state.playing,
          completed: state.processingState == ProcessingState.completed,
        ),
      );

  Future<void> setUrl(String url) => _player.setUrl(url);

  Future<void> setFile(String path) => _player.setFilePath(path);

  Future<void> playUrl(String url) async {
    await setUrl(url);
    await play();
  }

  Future<void> playFile(String path) async {
    await setFile(path);
    await play();
  }

  Future<void> play() async {
    final started = Completer<void>();
    late final StreamSubscription<PlayerState> subscription;
    subscription = _player.playerStateStream.listen((state) {
      if (state.playing && !started.isCompleted) {
        started.complete();
      }
    });
    unawaited(
      _player.play().catchError((Object error) {
        if (!started.isCompleted) started.completeError(error);
      }),
    );
    try {
      await started.future.timeout(
        const Duration(seconds: 3),
        onTimeout: () {},
      );
    } finally {
      await subscription.cancel();
    }
  }

  Future<void> pause() => _player.pause();

  Future<void> stop() => _player.stop();

  void dispose() {
    _player.dispose();
  }
}
