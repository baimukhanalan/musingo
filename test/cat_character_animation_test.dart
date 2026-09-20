import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/widgets/cat_character.dart';

class _MissingMoodBundle extends CachingAssetBundle {
  final bool missingIdle;
  _MissingMoodBundle({this.missingIdle = false});

  @override
  Future<ByteData> load(String key) {
    if (key == 'assets/images/cat_learning_real.webp' ||
        (missingIdle && key == 'assets/images/cat_idle_real.webp')) {
      return Future<ByteData>.error(StateError('Artwork unavailable'));
    }
    return rootBundle.load(key);
  }
}

String assetFor(CatMood mood) =>
    'assets/images/cat_${mood == CatMood.support ? 'thinking' : mood.name}_real.webp';

Widget scene(CatMood mood, {Object? reactionId, bool reducedMotion = false}) =>
    MaterialApp(
      home: MediaQuery(
        data: MediaQueryData(disableAnimations: reducedMotion),
        child: Center(child: CatCharacter(mood: mood, reactionId: reactionId)),
      ),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('Every emotion retains the original transparent single-frame 2D art',
      () async {
    for (final mood in CatMood.values) {
      final codec = await ui.instantiateImageCodec(
        await File(assetFor(mood)).readAsBytes(),
      );
      expect(codec.frameCount, 1, reason: mood.name);
      final frame = await codec.getNextFrame();
      expect(frame.image.height, greaterThanOrEqualTo(180));
      final pixels =
          (await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      expect(pixels.getUint8(3), 0, reason: '${mood.name} transparent canvas');
      frame.image.dispose();
      codec.dispose();
    }
  });

  test('The application bundle excludes the archived 3D experiments', () async {
    final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
    final assets = manifest.listAssets();
    for (final mood in CatMood.values) {
      expect(assets, contains(assetFor(mood)));
    }
    expect(assets.where((asset) => asset.startsWith('assets/images/ayn_')),
        isEmpty);
    expect(assets, contains('assets/images/learning_path_world.webp'));
    expect(assets, contains('assets/images/muslingo_cat.webp'));
  });

  testWidgets('Every mood maps to the original 2D expression', (tester) async {
    for (final mood in CatMood.values) {
      await tester.pumpWidget(scene(mood));
      await tester.pumpAndSettle();
      final image = tester.widget<Image>(find.byKey(ValueKey(assetFor(mood))));
      expect(image.image, isA<ResizeImage>());
      final provider = image.image as ResizeImage;
      expect((provider.imageProvider as AssetImage).assetName, assetFor(mood));
      expect(provider.width, isNull, reason: 'Keep the artwork aspect ratio');
      expect(provider.height, inInclusiveRange(180, 900),
          reason: 'Decode enough pixels for the tightly framed full-body art');
      expect(tester.getSize(find.byType(CatCharacter)), const Size(180, 180));
    }
    expect(tester.takeException(), isNull);
  });

  testWidgets('Emotion changes crossfade without bouncing or moving the image',
      (tester) async {
    await tester.pumpWidget(scene(CatMood.idle));
    await tester.pumpAndSettle();
    final position = tester.getTopLeft(find.byType(CatCharacter));
    await tester.pumpWidget(scene(CatMood.success));
    await tester.pump(const Duration(milliseconds: 110));
    expect(find.byKey(ValueKey(assetFor(CatMood.idle))), findsOneWidget);
    expect(find.byKey(ValueKey(assetFor(CatMood.success))), findsOneWidget);
    expect(tester.getTopLeft(find.byType(CatCharacter)), position);
    expect(
      find.descendant(
          of: find.byType(CatCharacter), matching: find.byType(Transform)),
      findsNothing,
    );
    await tester.pumpAndSettle();
    expect(find.byKey(ValueKey(assetFor(CatMood.idle))), findsNothing);
    expect(tester.binding.transientCallbackCount, 0,
        reason: 'A still mascot must not run an idle animation loop');
  });

  testWidgets('Same-outcome feedback does not flash or allocate a new decoder',
      (tester) async {
    await tester.pumpWidget(scene(CatMood.error, reactionId: 1));
    await tester.pumpAndSettle();
    final imageFinder = find.byKey(ValueKey(assetFor(CatMood.error)));
    final first = tester.widget<Image>(imageFinder).image;
    await tester.pumpWidget(scene(CatMood.error, reactionId: 2));
    expect(imageFinder, findsOneWidget);
    expect(tester.widget<Image>(imageFinder).image, first);
    expect(tester.binding.transientCallbackCount, 0);
  });

  testWidgets('Reduced motion changes the 2D expression immediately',
      (tester) async {
    await tester.pumpWidget(scene(CatMood.greet, reducedMotion: true));
    await tester.pumpWidget(scene(CatMood.support, reducedMotion: true));
    await tester.pump();
    expect(
        tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
        Duration.zero);
    expect(find.byKey(ValueKey(assetFor(CatMood.greet))), findsNothing);
    expect(find.byKey(ValueKey(assetFor(CatMood.support))), findsOneWidget);
    expect(tester.getSize(find.byType(CatCharacter)), const Size(180, 180));
  });

  testWidgets('Small avatars share the same 2D art with a bounded decode size',
      (tester) async {
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MaterialApp(
      home: Center(child: CatCharacter(mood: CatMood.support, size: 30)),
    ));
    final image = tester.widget<Image>(find.byType(Image));
    expect((image.image as ResizeImage).height, 64);
    expect(find.byKey(ValueKey(assetFor(CatMood.support))), findsOneWidget);
    expect(tester.getSize(find.byType(CatCharacter)), const Size(30, 30));
  });

  testWidgets('Inactive routes do not start emotion transitions',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
      home: TickerMode(enabled: false, child: CatCharacter()),
    ));
    expect(
        tester.widget<AnimatedSwitcher>(find.byType(AnimatedSwitcher)).duration,
        Duration.zero);
  });

  for (final entry in {
    'kk': 'Айн амандасады',
    'en': 'Ayn says hello',
    'ru': 'Айн приветствует'
  }.entries) {
    testWidgets('The original artwork keeps ${entry.key} accessibility labels',
        (tester) async {
      final semantics = tester.ensureSemantics();
      await tester.pumpWidget(MaterialApp(
        home: Builder(
            builder: (context) => Localizations.override(
                  context: context,
                  locale: Locale(entry.key),
                  delegates: const [DefaultWidgetsLocalizations.delegate],
                  child: const CatCharacter(mood: CatMood.greet),
                )),
      ));
      expect(find.bySemanticsLabel(entry.value), findsOneWidget);
      semantics.dispose();
    });
  }

  for (final missingIdle in [false, true]) {
    testWidgets(
        'Missing artwork has a bounded fallback (idle missing: $missingIdle)',
        (tester) async {
      await tester.pumpWidget(MaterialApp(
        home: DefaultAssetBundle(
          bundle: _MissingMoodBundle(missingIdle: missingIdle),
          child: const Center(child: CatCharacter(mood: CatMood.learning)),
        ),
      ));
      await tester.runAsync(
          () => Future<void>.delayed(const Duration(milliseconds: 100)));
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('ayn-2d-fallback')), findsOneWidget);
      if (missingIdle) expect(find.byIcon(Icons.pets_rounded), findsOneWidget);
      expect(tester.getSize(find.byType(CatCharacter)), const Size(180, 180));
      expect(tester.takeException(), isNull);
    });
  }
}
