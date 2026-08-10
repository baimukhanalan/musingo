import 'dart:js_interop';

import 'package:web/web.dart' as web;

import '../models/notification_permission_state.dart';
import '../models/reminder_message.dart';

@JS('muslingoPush.isSupported')
external JSBoolean _pushSupported();

@JS('muslingoPush.subscribe')
external JSPromise<JSBoolean> _pushSubscribe(
  JSNumber hour,
  JSNumber minute,
  JSNumber dueCount,
  JSString learningGoal,
);

@JS('muslingoPush.unsubscribe')
external JSPromise<JSBoolean> _pushUnsubscribe();

@JS('muslingoPush.showTest')
external JSPromise<JSBoolean> _pushShowTest(JSString title, JSString body);

class NotificationPlatform {
  bool get supportsBackgroundScheduling => _pushSupported().toDart;

  Future<void> initialize() async {}

  Future<NotificationPermissionState> permissionState() async {
    if (!supportsBackgroundScheduling) {
      return NotificationPermissionState.unsupported;
    }
    switch (web.Notification.permission) {
      case 'granted':
        return NotificationPermissionState.granted;
      case 'denied':
        return NotificationPermissionState.denied;
      default:
        return NotificationPermissionState.prompt;
    }
  }

  Future<bool> requestPermission() async {
    if (!supportsBackgroundScheduling) return false;
    final result = await web.Notification.requestPermission().toDart;
    return result.toDart == 'granted';
  }

  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required List<ReminderMessage> messages,
    int dueCount = 0,
    String learningGoal = '',
    String name = '',
    int streak = 0,
  }) async {
    // На web реальные локальные уведомления не планируем — контент собирает
    // серверный web-push. Сигнатура совпадает с остальными платформами;
    // name/streak здесь не используются.
    if (web.Notification.permission != 'granted') return;
    final subscribed = (await _pushSubscribe(
      hour.toJS,
      minute.toJS,
      dueCount.toJS,
      learningGoal.toJS,
    ).toDart)
        .toDart;
    if (!subscribed) {
      throw StateError('Web Push subscription failed.');
    }
  }

  Future<void> cancelAll() async {
    if (!supportsBackgroundScheduling) return;
    await _pushUnsubscribe().toDart;
  }

  Future<bool> showTest(ReminderMessage message) async {
    if (web.Notification.permission != 'granted' ||
        !supportsBackgroundScheduling) {
      return false;
    }
    return (await _pushShowTest(message.title.toJS, message.body.toJS).toDart)
        .toDart;
  }
}
