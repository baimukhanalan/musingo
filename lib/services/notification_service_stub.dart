import '../models/notification_permission_state.dart';
import '../models/reminder_message.dart';

class NotificationPlatform {
  bool get supportsBackgroundScheduling => false;
  bool get supportsNativeSurfaces => false;

  Future<void> initialize() async {}

  Future<NotificationPermissionState> permissionState() async =>
      NotificationPermissionState.unsupported;

  Future<bool> requestPermission() async => false;

  void setOnOpenRoute(void Function(String route) callback) {}

  Future<void> scheduleDaily({
    required int hour,
    required int minute,
    required List<ReminderMessage> messages,
    int dueCount = 0,
    String learningGoal = '',
    String name = '',
    int streak = 0,
    String authToken = '',
    List<ReminderMessage> ayahMessages = const [],
    int ayahHour = 8,
    int ayahMinute = 15,
    bool showOnLockScreen = false,
  }) async {}

  Future<void> cancelAll({String authToken = ''}) async {}

  Future<bool> showTest(ReminderMessage message) async => false;
}
