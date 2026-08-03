import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_permission_state.dart';
import '../models/reminder_message.dart';

class NotificationPlatform {
  static const _channelId = 'daily_learning';
  static const _channelName = 'Ежедневное обучение';
  static const _channelDescription =
      'Персональные напоминания о следующем уроке и повторении';

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _supported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  bool get supportsBackgroundScheduling => _supported;

  Future<void> initialize() async {
    if (_initialized || !_supported) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    const darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );
    const settings = InitializationSettings(
      android: android,
      iOS: darwin,
    );
    await _plugin.initialize(settings);
    _configureDeviceTimeZone();
    _initialized = true;
  }

  void _configureDeviceTimeZone() {
    final offset = DateTime.now().timeZoneOffset.inMilliseconds;
    final abbreviation = DateTime.now().timeZoneName;
    final location = tz.Location(
      'device_local',
      const [],
      const [],
      [tz.TimeZone(offset, isDst: false, abbreviation: abbreviation)],
    );
    tz.setLocalLocation(location);
  }

  Future<NotificationPermissionState> permissionState() async {
    await initialize();
    if (!_supported) return NotificationPermissionState.unsupported;
    if (defaultTargetPlatform == TargetPlatform.android) {
      final enabled = await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.areNotificationsEnabled() ??
          false;
      return enabled
          ? NotificationPermissionState.granted
          : NotificationPermissionState.prompt;
    }
    final options = await _plugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.checkPermissions();
    return options?.isEnabled == true
        ? NotificationPermissionState.granted
        : NotificationPermissionState.prompt;
  }

  Future<bool> requestPermission() async {
    await initialize();
    if (!_supported) return false;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return await _plugin
              .resolvePlatformSpecificImplementation<
                  AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          false;
    }
    return await _plugin
            .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin>()
            ?.requestPermissions(alert: true, badge: true, sound: true) ??
        false;
  }

  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required List<ReminderMessage> messages,
    int dueCount = 0,
    String learningGoal = '',
  }) async {
    await initialize();
    if (!_supported || messages.isEmpty) return;
    await cancelAll();

    for (var index = 0; index < 7; index++) {
      final message = messages[index % messages.length];
      await _plugin.zonedSchedule(
        4100 + index,
        message.title,
        message.body,
        _nextWeekday(index + 1, hour, minute),
        const NotificationDetails(
          android: AndroidNotificationDetails(
            _channelId,
            _channelName,
            channelDescription: _channelDescription,
            importance: Importance.high,
            priority: Priority.high,
            category: AndroidNotificationCategory.reminder,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
            threadIdentifier: 'daily_learning',
          ),
        ),
        payload: '/home',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }
  }

  tz.TZDateTime _nextWeekday(int weekday, int hour, int minute) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduled = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = scheduled.add(const Duration(days: 1));
    }
    return scheduled;
  }

  Future<void> cancelAll() async {
    if (!_supported) return;
    await initialize();
    await _plugin.cancelAll();
  }

  Future<bool> showTest(ReminderMessage message) async {
    await initialize();
    if (!_supported) return false;
    await _plugin.show(
      4099,
      message.title,
      message.body,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: '/home',
    );
    return true;
  }
}
