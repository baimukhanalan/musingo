import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

void main() {
  test('iOS registers plugins for the background notification action engine',
      () {
    final source = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    expect(source, contains('import flutter_local_notifications'));
    expect(
        source,
        matches(RegExp(
            r'FlutterLocalNotificationsPlugin\.setPluginRegistrantCallback\s*\{\s*registry in\s*GeneratedPluginRegistrant\.register\(with: registry\)',
            multiLine: true)));
    expect(source, isNot(contains('FlutterGeneratedPluginSwiftPackage')));
    final registration = source
        .indexOf('FlutterLocalNotificationsPlugin.setPluginRegistrantCallback');
    final forwarding = source.indexOf(
        'return super.application(application, didFinishLaunchingWithOptions:');
    expect(registration, lessThan(forwarding));
  });
  test('iOS assigns the notification delegate before returning from launch',
      () {
    final source = File('ios/Runner/AppDelegate.swift').readAsStringSync();
    final launchStart =
        source.indexOf('didFinishLaunchingWithOptions launchOptions:');
    final delegate = source.indexOf(
        'UNUserNotificationCenter.current().delegate = self', launchStart);
    final forwarding = source.indexOf(
        'return super.application(application, didFinishLaunchingWithOptions:',
        launchStart);
    expect(launchStart, greaterThanOrEqualTo(0));
    expect(delegate, greaterThan(launchStart));
    expect(delegate, lessThan(forwarding));
    expect(source, contains('import UserNotifications'));
  });
}
