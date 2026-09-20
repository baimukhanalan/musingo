import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:just_audio/just_audio.dart';
import 'package:muslingo/services/quran_audio_player_io.dart';

class _NativePlayerEvents implements AudioPlayer {
  final states = StreamController<PlayerState>.broadcast();
  final errors = StreamController<PlayerException>.broadcast();
  bool disposed = false;

  @override
  Stream<PlayerState> get playerStateStream => states.stream;
  @override
  Stream<PlayerException> get errorStream => errors.stream;
  @override
  Future<void> dispose() async {
    disposed = true;
    await states.close();
    await errors.close();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  test(
      'native completed state enables replay even if engine playing stays true',
      () async {
    final native = _NativePlayerEvents();
    final player = QuranAudioPlayer(player: native);
    final received = <QuranAudioPlaybackState>[];
    final subscription = player.playbackStateStream.listen(received.add);
    native.states.add(PlayerState(true, ProcessingState.completed));
    await Future<void>.delayed(Duration.zero);
    expect(received.single.completed, isTrue);
    expect(received.single.playing, isFalse);
    player.dispose();
    await subscription.cancel();
    expect(native.disposed, isTrue);
  });

  test('native late decoder/network errors reach the replay UI', () async {
    final native = _NativePlayerEvents();
    final player = QuranAudioPlayer(player: native);
    final received = <QuranAudioPlaybackState>[];
    final subscription = player.playbackStateStream.listen(received.add);
    final error = PlayerException(1, 'connection interrupted', 0);
    native.errors.add(error);
    await Future<void>.delayed(Duration.zero);
    expect(received.single.error, same(error));
    expect(received.single.playing, isFalse);
    player.dispose();
    await subscription.cancel();
  });
}
