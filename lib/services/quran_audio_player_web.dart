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
  int _generation = 0;
  bool _starting = false;
  bool _hasStarted = false;
  final _stateController =
      StreamController<QuranAudioPlaybackState>.broadcast();

  Stream<QuranAudioPlaybackState> get playbackStateStream =>
      _stateController.stream;

  Future<void> setUrl(String url) async {
    _generation++;
    _releaseAudio();
    _audio = _buildAudio(url);
    _audio!.load();
  }

  Future<void> setFile(String path) => setUrl(path);

  Future<void> playUrl(String url) async {
    // Reuse the unlocked element and browser cache for replay. Creating a new
    // media element on every tap adds a network round trip and can lose the
    // media gesture permission on mobile Safari.
    if (_audio?.src != url || _audio?.error != null) {
      _generation++;
      _releaseAudio();
      _audio = _buildAudio(url);
    } else {
      stopCurrent();
    }
    await play();
  }

  Future<void> playFile(String path) => playUrl(path);

  web.HTMLAudioElement _buildAudio(String url) {
    final audio = web.HTMLAudioElement()
      ..src = url
      ..preload = 'auto';
    audio.onplaying = ((web.Event _) {
      if (!identical(audio, _audio)) return;
      _hasStarted = true;
      _emit(const QuranAudioPlaybackState(playing: true));
    }).toJS;
    audio.onwaiting = ((web.Event _) {
      if (!identical(audio, _audio)) return;
      _emit(const QuranAudioPlaybackState(playing: false, buffering: true));
    }).toJS;
    audio.onpause = ((web.Event _) {
      if (!identical(audio, _audio)) return;
      _emit(const QuranAudioPlaybackState(playing: false));
    }).toJS;
    audio.onended = ((web.Event _) {
      if (!identical(audio, _audio)) return;
      _emit(
        const QuranAudioPlaybackState(playing: false, completed: true),
      );
    }).toJS;
    audio.onerror = ((web.Event _) {
      if (!identical(audio, _audio)) return;
      // play() rejects for startup errors. Publishing that same error here
      // would bypass the caller's mirror fallback and show a false failure.
      if (_starting || !_hasStarted) return;
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
    _starting = false;
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
    _hasStarted = false;
  }

  Future<void> play() async {
    final audio = _audio;
    if (audio == null) {
      throw StateError('Audio source is not set.');
    }
    final request = ++_generation;
    _starting = true;
    try {
      if (audio.ended) audio.currentTime = 0;
      await audio.play().toDart.timeout(const Duration(seconds: 8));
      if (request != _generation) {
        throw StateError('Audio playback was cancelled.');
      }
    } finally {
      if (request == _generation) _starting = false;
    }
  }

  Future<void> pause() async {
    _audio?.pause();
  }

  Future<void> stop() async {
    stopCurrent();
  }

  void stopCurrent() {
    _generation++;
    if (_starting) {
      _starting = false;
      _releaseAudio();
      _emit(const QuranAudioPlaybackState(playing: false));
      return;
    }
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
    _generation++;
    _starting = false;
    _releaseAudio();
    _stateController.close();
  }
}
