import 'dart:async';
import 'dart:js_interop';

import 'package:web/web.dart' as web;

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
  web.HTMLAudioElement? _audio;
  final _stateController =
      StreamController<QuranAudioPlaybackState>.broadcast();

  Stream<QuranAudioPlaybackState> get playbackStateStream =>
      _stateController.stream;

  Future<void> setUrl(String url) async {
    _releaseAudio();
    _audio = _buildAudio(url);
    _audio!.load();
  }

  Future<void> setFile(String path) => setUrl(path);

  Future<void> playUrl(String url) async {
    _releaseAudio();
    final audio = _buildAudio(url);
    _audio = audio;
    await audio.play().toDart;
  }

  Future<void> playFile(String path) => playUrl(path);

  web.HTMLAudioElement _buildAudio(String url) {
    final audio = web.HTMLAudioElement()
      ..src = url
      ..preload = 'auto';
    audio.onplaying = ((web.Event _) {
      _emit(const QuranAudioPlaybackState(playing: true));
    }).toJS;
    audio.onwaiting = ((web.Event _) {
      _emit(const QuranAudioPlaybackState(playing: false, buffering: true));
    }).toJS;
    audio.onpause = ((web.Event _) {
      _emit(const QuranAudioPlaybackState(playing: false));
    }).toJS;
    audio.onended = ((web.Event _) {
      _emit(
        const QuranAudioPlaybackState(playing: false, completed: true),
      );
    }).toJS;
    audio.onerror = ((web.Event _) {
      _emit(
        QuranAudioPlaybackState(
          playing: false,
          error: StateError('Browser audio stream failed.'),
        ),
      );
    }).toJS;
    return audio;
  }

  void _emit(QuranAudioPlaybackState state) {
    if (!_stateController.isClosed) _stateController.add(state);
  }

  void _releaseAudio() {
    final audio = _audio;
    if (audio == null) return;
    // Detach queued DOM callbacks before disposing or replacing the element.
    audio.onplaying = null;
    audio.onwaiting = null;
    audio.onpause = null;
    audio.onended = null;
    audio.onerror = null;
    audio.pause();
    audio.removeAttribute('src');
    audio.load();
    _audio = null;
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
    _releaseAudio();
    _stateController.close();
  }
}
