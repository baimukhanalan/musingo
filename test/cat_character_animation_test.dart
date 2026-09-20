import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/widgets/cat_character.dart';

void main() {
  test('Every Ayn mood has a real multi-frame animation and a still poster',
      () async {
    for (final mood in CatMood.values) {
      final name = mood == CatMood.support ? 'thinking' : mood.name;
      final animation = await ui.instantiateImageCodec(
        await File('assets/images/ayn_$name.webp').readAsBytes(),
      );
      expect(animation.frameCount, 32, reason: name);
      final frame = await animation.getNextFrame();
      expect(frame.image.width, 384);
      expect(frame.image.height, 384);
      expect(frame.duration.inMilliseconds, inInclusiveRange(60, 65));
      final pixels =
          (await frame.image.toByteData(format: ui.ImageByteFormat.rawRgba))!;
      expect(pixels.getUint8(3), 0,
          reason: '$name must retain a transparent canvas');
      frame.image.dispose();
      animation.dispose();

      final still = await ui.instantiateImageCodec(
        await File('assets/images/ayn_${name}_still.webp').readAsBytes(),
      );
      expect(still.frameCount, 1, reason: '$name reduced motion');
      still.dispose();
    }
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
}
