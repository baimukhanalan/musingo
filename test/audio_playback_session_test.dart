import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/audio_playback_session.dart';

void main() {
  test('keeps a failed primary inside the loading phase until mirror starts',
      () async {
    final calls = <String>[];
    late AudioPlaybackSession session;
    session = AudioPlaybackSession(
      playUrl: (url) async {
        expect(session.starting, isTrue);
        calls.add(url);
        if (url == 'primary') throw StateError('source failed');
      },
      stopPlayer: () async => calls.add('stop'),
    );
    expect(await session.play(['primary', 'mirror']), isTrue);
    expect(calls, ['primary', 'stop', 'mirror']);
    expect(session.starting, isFalse);
  });

  test('only exhausted sources fail; the next tap can replay successfully',
      () async {
    var fail = true;
    var calls = 0;
    final session = AudioPlaybackSession(
      playUrl: (_) async {
        calls++;
        if (fail) throw StateError('offline');
      },
      stopPlayer: () async {},
    );
    await expectLater(session.play(['a', 'b', 'a']), throwsStateError);
    expect(calls, 2, reason: 'duplicate fallback URLs are not retried');
    expect(session.starting, isFalse);
    fail = false;
    expect(await session.play(['a', 'b']), isTrue);
    expect(await session.play(['a', 'b']), isTrue, reason: 'replay after end');
  });

  test('stop during startup suppresses old completion and fallback', () async {
    final pending = Completer<void>();
    final calls = <String>[];
    final session = AudioPlaybackSession(
      playUrl: (url) {
        calls.add(url);
        return pending.future;
      },
      stopPlayer: () async => calls.add('stop'),
    );
    final playback = session.play(['a', 'b']);
    await session.stop();
    pending.completeError(StateError('cancelled media request'));
    expect(await playback, isFalse);
    expect(calls, ['a', 'stop']);
    expect(session.starting, isFalse);
  });

  test('leaving the lesson never starts its pending fallback', () async {
    final pending = Completer<void>();
    var calls = 0;
    final session = AudioPlaybackSession(
      playUrl: (_) {
        calls++;
        return pending.future;
      },
      stopPlayer: () async {},
    );
    final playback = session.play(['a', 'b']);
    session.cancel();
    pending.completeError(StateError('removed widget'));
    expect(await playback, isFalse);
    expect(calls, 1);
  });

  test('an old failed request cannot stop a newer successful replay', () async {
    final pending = Completer<void>();
    var calls = 0;
    var stops = 0;
    final session = AudioPlaybackSession(
      playUrl: (_) => ++calls == 1 ? pending.future : Future.value(),
      stopPlayer: () async {
        stops++;
      },
    );
    final first = session.play(['a', 'b']);
    expect(await session.play(['a', 'b']), isTrue);
    pending.completeError(StateError('old request failed'));
    expect(await first, isFalse);
    expect(stops, 0);
  });

  test('a stalled source times out and tries the mirror', () async {
    final pending = Completer<void>();
    var calls = 0;
    var stops = 0;
    final session = AudioPlaybackSession(
      startTimeout: const Duration(milliseconds: 10),
      playUrl: (_) => ++calls == 1 ? pending.future : Future.value(),
      stopPlayer: () async {
        stops++;
      },
    );
    expect(await session.play(['a', 'b']), isTrue);
    expect(calls, 2);
    expect(stops, 1);
    pending.complete();
  });
}
