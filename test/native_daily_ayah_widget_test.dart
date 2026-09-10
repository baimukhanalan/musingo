import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('native daily ayah widget configuration', () {
    test('supports iPhone Lock Screen families', () {
      final source = File(
        'ios/MuslingoAyahWidget/MuslingoAyahWidget.swift',
      ).readAsStringSync();

      expect(source, contains('.accessoryInline'));
      expect(source, contains('.accessoryRectangular'));
      expect(source, contains('@Environment(\\.widgetFamily)'));
      expect(source, contains('entry.arabic'));
      expect(source, contains('entry.translation'));
    });

    test('declares Android keyguard compatibility', () {
      final metadata = File(
        'android/app/src/main/res/xml/muslingo_ayah_widget_info.xml',
      ).readAsStringSync();

      expect(metadata, contains('android:initialKeyguardLayout'));
      expect(
          metadata, contains('android:widgetCategory="home_screen|keyguard"'));
    });
  });
}
