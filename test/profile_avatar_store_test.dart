import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/profile_avatar_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final png = base64Decode(
      'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAACklEQVR4nGMAAQAABQABDQottAAAAABJRU5ErkJggg==');

  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  test('avatar bytes are isolated per account and guest generation', () async {
    final store = ProfileAvatarStore();
    await store.save('user:first', png);
    await store.save('guest:generation-one', png);
    expect(await store.load('user:first'), png);
    expect(await store.load('user:second'), isNull);
    expect(await store.load('guest:generation-two'), isNull);
    await store.remove('guest:generation-one');
    expect(await store.load('guest:generation-one'), isNull);
    expect(await store.load('user:first'), png);
  });

  test('picker rejects oversized and executable/unsupported content', () async {
    await expectLater(
      ProfileAvatarStore.normalize(
          Uint8List(ProfileAvatarStore.maxInputBytes + 1)),
      throwsA(AvatarValidationError.tooLarge),
    );
    await expectLater(
      ProfileAvatarStore.normalize(Uint8List.fromList(
          utf8.encode('<svg><script>alert(1)</script></svg>'))),
      throwsA(AvatarValidationError.unsupported),
    );
    final malformed = Uint8List.fromList([...png.take(12), 0, 0, 0]);
    await expectLater(ProfileAvatarStore.normalize(malformed),
        throwsA(AvatarValidationError.invalidImage));
  });

  test('normalization bounds dimensions and re-encodes a static PNG', () async {
    final recorder = ui.PictureRecorder();
    final canvas = ui.Canvas(recorder);
    canvas.drawPaint(ui.Paint()..color = const ui.Color(0xff125b88));
    final picture = recorder.endRecording();
    final large = await picture.toImage(1600, 800);
    final input = await large.toByteData(format: ui.ImageByteFormat.png);
    large.dispose();
    picture.dispose();
    final normalized =
        await ProfileAvatarStore.normalize(input!.buffer.asUint8List());
    final buffer = await ui.ImmutableBuffer.fromUint8List(normalized);
    final descriptor = await ui.ImageDescriptor.encoded(buffer);
    expect(descriptor.width, 384);
    expect(descriptor.height, 192);
    expect(normalized.length, lessThan(ProfileAvatarStore.maxStoredBytes));
    descriptor.dispose();
    buffer.dispose();
  });

  test('corrupt persisted data falls back to default', () async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        ProfileAvatarStore.keyFor('user:first'), 'not base64%%');
    expect(await ProfileAvatarStore().load('user:first'), isNull);
  });
}
