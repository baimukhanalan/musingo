import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  group('native daily ayah widget configuration', () {
    test(
        'native widgets use the app language and hide empty Arabic translations',
        () {
      final ios = File('ios/MuslingoAyahWidget/MuslingoAyahWidget.swift')
          .readAsStringSync();
      final android = File(
              'android/app/src/main/kotlin/com/muslingo/app/MuslingoAyahWidgetProvider.kt')
          .readAsStringSync();
      expect(ios, contains('string(forKey: "widget_locale")'));
      expect(ios,
          contains('entry.localeCode == "ar" ? .rightToLeft : .leftToRight'));
      expect(ios, contains('if !entry.translation.isEmpty'));
      expect(ios, contains('جارٍ إعداد آية اليوم'));
      expect(android, contains('getString("widget_locale", "ru")'));
      expect(android, contains('"setLayoutDirection", direction'));
      expect(android, contains('entry.translation.isEmpty()) View.GONE'));
      expect(android, contains('جارٍ إعداد آية اليوم'));
    });
    test('personal advice is not copied across thirty future widget dates', () {
      final source =
          File('lib/services/home_widget_service_io.dart').readAsStringSync();
      expect(
          source, contains("'coachLine': offset == 0 ? coachLine.trim() : ''"));
    });
    test('supports iPhone Lock Screen families', () {
      final source = File(
        'ios/MuslingoAyahWidget/MuslingoAyahWidget.swift',
      ).readAsStringSync();

      expect(source, contains('.accessoryInline'));
      expect(source, contains('.accessoryRectangular'));
      expect(source, contains('@Environment(\\.widgetFamily)'));
      expect(source, contains('entry.arabic'));
      expect(source, contains('entry.translation'));
      expect(source, contains('URL(string: "muslingo:///home")'));
      expect(
          source, isNot(contains('https://muslingo-mobile.vercel.app/#/home')));
      expect(Uri.parse('muslingo:///home').path, '/home');
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
