import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

class QuranAudioPlaybackState {
  final bool playing;
  final bool completed;
  final Object? error;

  const QuranAudioPlaybackState({
    required this.playing,
    this.completed = false,
    this.error,
  });
}

class QuranAudioPlayer {
  web.HTMLAudioElement? _audio;
  final _stateController =
      StreamController<QuranAudioPlaybackState>.broadcast();

  Stream<QuranAudioPlaybackState> get playbackStateStream =>
      _stateController.stream;

  Future<void> setUrl(String url) async {
    stopCurrent();
    _audio = _buildAudio(url);
  }

  Future<void> setFile(String path) => setUrl(path);

  Future<void> playUrl(String url) async {
    stopCurrent();
    final audio = _buildAudio(url);
    _audio = audio;
    await audio.play().toDart;
  }

  Future<void> playFile(String path) => playUrl(path);

  web.HTMLAudioElement _buildAudio(String url) {
    final audio = web.HTMLAudioElement()
      ..src = url
      ..preload = 'auto';
    audio.onplay = ((web.Event _) {
      _stateController.add(const QuranAudioPlaybackState(playing: true));
    }).toJS;
    audio.onpause = ((web.Event _) {
      _stateController.add(const QuranAudioPlaybackState(playing: false));
    }).toJS;
    audio.onended = ((web.Event _) {
      _stateController.add(
        const QuranAudioPlaybackState(playing: false, completed: true),
      );
    }).toJS;
    audio.onerror = ((web.Event _) {
      _stateController.add(
        QuranAudioPlaybackState(
          playing: false,
          error: StateError('Browser audio stream failed.'),
        ),
      );
    }).toJS;
    return audio;
  }

  Future<void> play() async {
    final audio = _audio;
    if (audio == null) {
      throw StateError('Audio source is not set.');
    }
    await audio.play().toDart;
  }

  Future<void> pause() async {
    _audio?.pause();
  }

  Future<void> stop() async {
    stopCurrent();
  }

  void stopCurrent() {
    final audio = _audio;
    if (audio == null) return;
    audio.pause();
    try {
      audio.currentTime = 0;
    } catch (_) {
      // Some browsers reject seeking before metadata is loaded.
    }
  }

  void dispose() {
    stop();
    _stateController.close();
  }
}
