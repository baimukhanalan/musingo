import '../models/notification_permission_state.dart';
import '../models/reminder_message.dart';

class NotificationPlatform {
  bool get supportsBackgroundScheduling => false;

  Future<void> initialize() async {}

  Future<NotificationPermissionState> permissionState() async =>
      NotificationPermissionState.unsupported;

  Future<bool> requestPermission() async => false;

  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required List<ReminderMessage> messages,
    int dueCount = 0,
    String learningGoal = '',
    String name = '',
    int streak = 0,
  }) async {}

  Future<void> cancelAll() async {}

  Future<bool> showTest(ReminderMessage message) async => false;
}
