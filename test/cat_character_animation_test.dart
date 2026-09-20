import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/widgets/cat_character.dart';

class _DelayedAnimationBundle extends CachingAssetBundle {
  final animation = Completer<ByteData>();
  final bool missingPoster;
  _DelayedAnimationBundle({this.missingPoster = false});

  @override
  Future<ByteData> load(String key) {
    if (key == 'assets/images/ayn_learning.webp') return animation.future;
    if (missingPoster && key == 'assets/images/ayn_learning_still.webp') {
      return Future<ByteData>.error(StateError('Poster unavailable'));
    }
    return rootBundle.load(key);
  }
}

void main() {
  test('Every Ayn mood has a real multi-frame animation and a still poster',
      () async {
    for (final mood in CatMood.values) {
      final name = mood == CatMood.support ? 'thinking' : mood.name;
      final animation = await ui.instantiateImageCodec(
        await File('assets/images/ayn_$name.webp').readAsBytes(),
      );
      expect(animation.frameCount, 72, reason: name);
      final isReaction = const {
        CatMood.greet,
        CatMood.success,
        CatMood.error,
        CatMood.praise,
      }.contains(mood);
      expect(animation.repetitionCount, isReaction ? 0 : -1,
          reason: '$name must ${isReaction ? 'play once' : 'loop calmly'}');
      final frame = await animation.getNextFrame();
      expect(frame.image.width, 384);
      expect(frame.image.height, 384);
      expect(frame.duration.inMilliseconds, inInclusiveRange(41, 42));
      final pixels =
          (await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      expect(pixels.getUint8(3), 0,
          reason: '$name must retain a transparent canvas');
      var duration = frame.duration;
      frame.image.dispose();
      for (var index = 1; index < animation.frameCount; index++) {
        final next = await animation.getNextFrame();
        duration += next.duration;
        next.image.dispose();
      }
      expect(duration, const Duration(seconds: 3), reason: name);
      animation.dispose();

      final still = await ui.instantiateImageCodec(
        await File('assets/images/ayn_${name}_still.webp').readAsBytes(),
      );
      expect(still.frameCount, 1, reason: '$name reduced motion');
      still.dispose();
    }
  });

  test('The complete motion pack stays within the mobile download budget', () {
    var bytes = 0;
    for (final mood in CatMood.values) {
      final name = mood == CatMood.support ? 'thinking' : mood.name;
      bytes += File('assets/images/ayn_$name.webp').lengthSync();
      bytes += File('assets/images/ayn_${name}_still.webp').lengthSync();
    }
    expect(bytes, lessThanOrEqualTo(6 * 1024 * 1024));
  });

  testWidgets('A repeated reaction receives a fresh playback stream',
      (tester) async {
    Widget scene(CatMood mood) => MaterialApp(
          home: CatCharacter(mood: mood),
        );
    Image current(CatMood mood) => tester.widget<Image>(find.byKey(
          ValueKey('assets/images/ayn_${mood.name}.webp'),
        ));

    await tester.pumpWidget(scene(CatMood.success));
    final firstImage = current(CatMood.success).image;
    final firstKey = await tester
        .runAsync(() => firstImage.obtainKey(ImageConfiguration.empty));

    await tester.pumpWidget(scene(CatMood.success));
    final sameKey = await tester.runAsync(() =>
        current(CatMood.success).image.obtainKey(ImageConfiguration.empty));
    expect(sameKey, firstKey,
        reason: 'An ordinary rebuild must not restart the performance');

    await tester.pumpWidget(scene(CatMood.idle));
    await tester.pump(const Duration(milliseconds: 250));
    await tester.pumpWidget(scene(CatMood.success));
    final repeatedKey = await tester.runAsync(() =>
        current(CatMood.success).image.obtainKey(ImageConfiguration.empty));
    expect(repeatedKey, isNot(firstKey),
        reason: 'A new answer must not reuse the previous final frame');
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Two reaction avatars cannot consume each other\'s playback',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: Center(
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          CatCharacter(mood: CatMood.greet, key: ValueKey('first')),
          CatCharacter(mood: CatMood.greet, key: ValueKey('second')),
        ]),
      ),
    ));
    await tester.pump();
    expect(find.byType(CatCharacter), findsNWidgets(2));
    final primaryImages =
        find.byKey(const ValueKey('assets/images/ayn_greet.webp'));
    expect(primaryImages, findsNWidgets(2));
    final images = tester.widgetList<Image>(primaryImages).toList();
    final keys = await tester.runAsync(() async {
      final keys = <Object>[];
      for (final image in images) {
        keys.add(await image.image.obtainKey(ImageConfiguration.empty));
      }
      return keys;
    });
    expect(keys![0], isNot(keys[1]));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('A reaction releases its private cache entry when removed',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CatCharacter(mood: CatMood.success),
    ));
    final provider = tester
        .widget<Image>(
            find.byKey(const ValueKey('assets/images/ayn_success.webp')))
        .image;
    final key = await tester
        .runAsync(() => provider.obtainKey(ImageConfiguration.empty));
    final cache = PaintingBinding.instance.imageCache;
    expect(cache.containsKey(key!), isTrue);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(cache.containsKey(key), isFalse,
        reason: 'Per-event decoder keys must not accumulate between lessons');
  });

  testWidgets('A repeated same-outcome event replays without changing the mood',
      (tester) async {
    Widget scene(int event) => MaterialApp(
          home: CatCharacter(mood: CatMood.error, reactionId: event),
        );
    await tester.pumpWidget(scene(1));
    final first = tester
        .widget<Image>(find.byKey(const ValueKey<(String, Object?)>(
            ('assets/images/ayn_error.webp', 1))))
        .image;
    final firstKey =
        await tester.runAsync(() => first.obtainKey(ImageConfiguration.empty));
    await tester.pumpWidget(scene(2));
    await tester.pump(const Duration(milliseconds: 250));
    final repeated = tester
        .widget<Image>(find.byKey(const ValueKey<(String, Object?)>(
            ('assets/images/ayn_error.webp', 2))))
        .image;
    final repeatedKey = await tester
        .runAsync(() => repeated.obtainKey(ImageConfiguration.empty));
    expect(repeatedKey, isNot(firstKey));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'An active mascot switches to a still while its route is inactive',
      (tester) async {
    Widget scene(bool enabled) => MaterialApp(
          home: TickerMode(
            enabled: enabled,
            child: const CatCharacter(mood: CatMood.learning),
          ),
        );
    await tester.pumpWidget(scene(true));
    expect(find.byKey(const ValueKey('assets/images/ayn_learning.webp')),
        findsOneWidget);
    await tester.pumpWidget(scene(false));
    expect(find.byKey(const ValueKey('assets/images/ayn_learning_still.webp')),
        findsOneWidget);
    await tester.pumpWidget(scene(true));
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byKey(const ValueKey('assets/images/ayn_learning.webp')),
        findsOneWidget);
    expect(find.byKey(const ValueKey('assets/images/ayn_learning_still.webp')),
        findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Reduced motion uses a still and preserves the mascot footprint',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: true),
        child: Center(child: CatCharacter(mood: CatMood.greet, size: 180)),
      ),
    ));
    final image = tester.widget<Image>(find.byType(Image));
    expect(find.byKey(const ValueKey('assets/images/ayn_greet_still.webp')),
        findsOneWidget);
    expect(image.width, 180);
    expect(image.height, 180);
    expect(tester.getSize(find.byType(CatCharacter)), const Size(180, 180));
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Inactive routes use a still instead of animating off-screen',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: TickerMode(
          enabled: false, child: CatCharacter(mood: CatMood.support)),
    ));
    expect(find.byKey(const ValueKey('assets/images/ayn_thinking_still.webp')),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Small repeated chat avatars do not run animation decoders',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: CatCharacter(mood: CatMood.support, size: 30),
    ));
    expect(find.byKey(const ValueKey('assets/images/ayn_thinking_still.webp')),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Backgrounding the app switches its active mascot to a still',
      (tester) async {
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    addTearDown(() => tester.binding
        .handleAppLifecycleStateChanged(AppLifecycleState.resumed));
    await tester.pumpWidget(const MaterialApp(
      home: CatCharacter(mood: CatMood.learning),
    ));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    await tester.pump();
    expect(find.byKey(const ValueKey('assets/images/ayn_learning_still.webp')),
        findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 250));
    expect(find.byKey(const ValueKey('assets/images/ayn_learning.webp')),
        findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('A delayed animation shows its mood poster until a frame arrives',
      (tester) async {
    final bundle = _DelayedAnimationBundle();
    await tester.pumpWidget(MaterialApp(
      home: DefaultAssetBundle(
        bundle: bundle,
        child: const Center(child: CatCharacter(mood: CatMood.learning)),
      ),
    ));
    await tester.pump();
    final poster = find.byKey(const ValueKey('ayn-loading-poster-learning'));
    expect(poster, findsOneWidget);
    expect(tester.getSize(find.byType(CatCharacter)), const Size(180, 180));
    await tester.runAsync(() async {
      bundle.animation
          .complete(await rootBundle.load('assets/images/ayn_learning.webp'));
      await Future<void>.delayed(const Duration(milliseconds: 100));
    });
    for (var attempt = 0;
        attempt < 30 && poster.evaluate().isNotEmpty;
        attempt++) {
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 10)));
      await tester.pump(const Duration(milliseconds: 16));
    }
    expect(poster, findsNothing);
    expect(tester.getSize(find.byType(CatCharacter)), const Size(180, 180));
    await tester.pumpWidget(const SizedBox.shrink());
    expect(tester.takeException(), isNull);
  });

  for (final missingPoster in [false, true]) {
    testWidgets(
        'Animation failure has a bounded fallback (poster missing: $missingPoster)',
        (tester) async {
      final bundle = _DelayedAnimationBundle(missingPoster: missingPoster);
      await tester.pumpWidget(MaterialApp(
        home: DefaultAssetBundle(
          bundle: bundle,
          child: const Center(child: CatCharacter(mood: CatMood.learning)),
        ),
      ));
      await tester.pump();
      await tester.runAsync(() async {
        bundle.animation.completeError(StateError('Animation unavailable'));
        await Future<void>.delayed(const Duration(milliseconds: 40));
      });
      await tester.pump();
      await tester.pump();
      expect(find.byKey(const ValueKey('ayn-loading-poster-learning')),
          findsOneWidget);
      if (missingPoster) {
        expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
      }
      expect(tester.getSize(find.byType(CatCharacter)), const Size(180, 180));
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
    });
  }
}
