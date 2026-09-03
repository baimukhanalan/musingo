import '../models/notification_permission_state.dart';
import '../models/reminder_message.dart';
export '../models/notification_permission_state.dart';
import 'notification_service_stub.dart'
    if (dart.library.io) 'notification_service_io.dart'
    if (dart.library.js_interop) 'notification_service_web.dart' as platform;

class NotificationService {
  final platform.NotificationPlatform _platform =
      platform.NotificationPlatform();

  bool get supportsBackgroundScheduling =>
      _platform.supportsBackgroundScheduling;
  bool get supportsNativeSurfaces => _platform.supportsNativeSurfaces;

  Future<void> initialize() => _platform.initialize();

  Future<NotificationPermissionState> permissionState() =>
      _platform.permissionState();

  Future<bool> requestPermission() => _platform.requestPermission();

  void setOnOpenRoute(void Function(String route) callback) =>
      _platform.setOnOpenRoute(callback);

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
  }) =>
      _platform.scheduleDaily(
        hour: hour,
        minute: minute,
        messages: messages,
        dueCount: dueCount,
        learningGoal: learningGoal,
        name: name,
        streak: streak,
        authToken: authToken,
        ayahMessages: ayahMessages,
        ayahHour: ayahHour,
        ayahMinute: ayahMinute,
        showOnLockScreen: showOnLockScreen,
      );

  Future<void> cancelAll({String authToken = ''}) =>
      _platform.cancelAll(authToken: authToken);

  Future<bool> showTest(ReminderMessage message) => _platform.showTest(message);
}
