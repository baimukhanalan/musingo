import 'dart:convert';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:crypto/crypto.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum AvatarValidationError { tooLarge, unsupported, invalidImage, storage }

/// Local-only thumbnails, explicitly isolated by account/guest generation.
/// Originals, paths and EXIF metadata are never persisted or uploaded.
class ProfileAvatarStore {
  static const maxInputBytes = 5 * 1024 * 1024;
  static const maxStoredBytes = 768 * 1024;
  static const thumbnailEdge = 384;
  static const pendingScopeKey = 'profile_avatar_pending_scope_v1';

  static String keyFor(String scope) =>
      'profile_avatar_v1_${sha256.convert(utf8.encode(scope))}';

  Future<Uint8List?> load(String scope) async {
    final prefs = await SharedPreferences.getInstance();
    final value = prefs.getString(keyFor(scope));
    if (value == null || value.length > maxStoredBytes * 2) return null;
    try {
      final bytes = base64Decode(value);
      return bytes.length <= maxStoredBytes && isSupportedImage(bytes)
          ? bytes
          : null;
    } on FormatException {
      return null;
    }
  }

  Future<void> save(String scope, Uint8List thumbnail) async {
    if (thumbnail.length > maxStoredBytes || !isSupportedImage(thumbnail)) {
      throw AvatarValidationError.invalidImage;
    }
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.setString(keyFor(scope), base64Encode(thumbnail))) {
      throw AvatarValidationError.storage;
    }
  }

  Future<void> remove(String scope) async {
    final prefs = await SharedPreferences.getInstance();
    if (!await prefs.remove(keyFor(scope))) {
      throw AvatarValidationError.storage;
    }
  }

  static bool isSupportedImage(Uint8List bytes) {
    if (bytes.length < 12) return false;
    final png = bytes[0] == 0x89 &&
        bytes[1] == 0x50 &&
        bytes[2] == 0x4e &&
        bytes[3] == 0x47 &&
        bytes[4] == 0x0d &&
        bytes[5] == 0x0a &&
        bytes[6] == 0x1a &&
        bytes[7] == 0x0a;
    final jpeg = bytes[0] == 0xff && bytes[1] == 0xd8 && bytes[2] == 0xff;
    final webp =
        ascii.decode(bytes.sublist(0, 4), allowInvalid: true) == 'RIFF' &&
            ascii.decode(bytes.sublist(8, 12), allowInvalid: true) == 'WEBP';
    return png || jpeg || webp;
  }

  static Future<Uint8List> normalize(Uint8List input) async {
    if (input.length > maxInputBytes) throw AvatarValidationError.tooLarge;
    if (!isSupportedImage(input)) throw AvatarValidationError.unsupported;
    ui.ImmutableBuffer? buffer;
    ui.ImageDescriptor? descriptor;
    ui.Codec? codec;
    ui.Image? image;
    try {
      buffer = await ui.ImmutableBuffer.fromUint8List(input);
      descriptor = await ui.ImageDescriptor.encoded(buffer);
      if (descriptor.width > 8192 ||
          descriptor.height > 8192 ||
          descriptor.width * descriptor.height > 25000000) {
        throw AvatarValidationError.tooLarge;
      }
      final longest = descriptor.width > descriptor.height
          ? descriptor.width
          : descriptor.height;
      final scale = longest > thumbnailEdge ? thumbnailEdge / longest : 1.0;
      codec = await descriptor.instantiateCodec(
        targetWidth: (descriptor.width * scale).round().clamp(1, thumbnailEdge),
        targetHeight:
            (descriptor.height * scale).round().clamp(1, thumbnailEdge),
      );
      image = (await codec.getNextFrame()).image;
      final png = await image.toByteData(format: ui.ImageByteFormat.png);
      if (png == null) throw AvatarValidationError.invalidImage;
      final result =
          png.buffer.asUint8List(png.offsetInBytes, png.lengthInBytes);
      if (result.length > maxStoredBytes) throw AvatarValidationError.tooLarge;
      return result;
    } on AvatarValidationError {
      rethrow;
    } catch (_) {
      throw AvatarValidationError.invalidImage;
    } finally {
      image?.dispose();
      codec?.dispose();
      descriptor?.dispose();
      buffer?.dispose();
    }
  }
}
