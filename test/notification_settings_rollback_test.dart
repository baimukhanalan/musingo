import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/reminder_message.dart';
import 'package:muslingo/models/mentor_profile.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/notification_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('birthday greeting stays in-app and never enters a weekly reminder slot',
      () async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final notifications = _FakeNotificationService();
    final state = AppState(notificationService: notifications);
    while (!state.isInitialized) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await state.loginAsGuest();
    final now = DateTime.now();
    await state.updateMentorProfile(MentorProfile(
      birthdayMonth: now.month,
      birthdayDay: now.day,
      preferredName: 'Alan',
    ));
    expect(await state.setNotificationsEnabled(true), isTrue);
    expect(notifications.lastMessages, isNotEmpty);
    expect(
        notifications.lastMessages
            .any((message) => message.title.contains('С днём рождения')),
        isFalse);
    expect(state.mentorTipAt(now).id, contains('-birthday-'));
    state.dispose();
  });

  test('failed scheduling restores every visible notification setting',
      () async {
    SharedPreferences.setMockInitialValues({});
    final notifications = _FakeNotificationService();
    final state = AppState(notificationService: notifications);
    while (!state.isInitialized) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await state.loginAsGuest();
    expect(await state.setNotificationsEnabled(true), isTrue);

    notifications.failCancellation = true;
    expect(await state.setNotificationsEnabled(false), isFalse);
    expect(state.notificationsEnabled, isTrue);
    notifications.failCancellation = false;

    notifications.failScheduling = true;
    expect(await state.setReminderTime(7, 15), isFalse);
    expect((state.reminderHour, state.reminderMinute), (19, 30));

    expect(await state.setDailyAyahNotificationsEnabled(true), isFalse);
    expect(state.dailyAyahNotificationsEnabled, isFalse);

    expect(await state.setLockScreenPreviewEnabled(true), isFalse);
    expect(state.lockScreenPreviewEnabled, isFalse);

    notifications.failScheduling = false;
    expect(await state.setDailyAyahNotificationsEnabled(true), isTrue);
    notifications.failScheduling = true;
    expect(await state.setDailyAyahNotificationsEnabled(false), isFalse);
    expect(state.dailyAyahNotificationsEnabled, isTrue);

    state.dispose();
  });

  test('logout persists notifications as disabled for the next launch',
      () async {
    SharedPreferences.setMockInitialValues({});
    final notifications = _FakeNotificationService();
    final state = AppState(notificationService: notifications);
    while (!state.isInitialized) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await state.loginAsGuest();
    expect(await state.setNotificationsEnabled(true), isTrue);
    expect(
      (await SharedPreferences.getInstance()).getBool('notifications_enabled'),
      isTrue,
    );

    await state.logout();

    expect(state.notificationsEnabled, isFalse);
    expect(
      (await SharedPreferences.getInstance()).getBool('notifications_enabled'),
      isFalse,
    );
    state.dispose();
  });

  test('revoked OS permission disables a persisted notification switch',
      () async {
    SharedPreferences.setMockInitialValues({'notifications_enabled': true});
    final notifications = _FakeNotificationService()
      ..permission = NotificationPermissionState.denied;
    final state = AppState(notificationService: notifications);
    while (!state.isInitialized) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }

    expect(state.notificationsEnabled, isFalse);
    expect(
      (await SharedPreferences.getInstance()).getBool('notifications_enabled'),
      isFalse,
    );
    state.dispose();
  });

  test('logout removes a deferred sync snapshot owned by another session',
      () async {
    SharedPreferences.setMockInitialValues({
      'pending_sync_import': '{"completedLessons":["arabic_1"]}',
      'pending_sync_user': 'server-user-a',
      'pending_sync_is_guest': true,
    });
    final state = AppState(notificationService: _FakeNotificationService());
    while (!state.isInitialized) {
      await Future<void>.delayed(const Duration(milliseconds: 10));
    }
    await state.loginAsGuest();
    await state.logout();
    final preferences = await SharedPreferences.getInstance();

    expect(preferences.getString('pending_sync_import'), isNull);
    expect(preferences.getString('pending_sync_user'), isNull);
    expect(preferences.getBool('pending_sync_is_guest'), isNull);
    state.dispose();
  });
}

class _FakeNotificationService extends NotificationService {
  List<ReminderMessage> lastMessages = [];
  bool failScheduling = false;
  bool failCancellation = false;
  NotificationPermissionState permission = NotificationPermissionState.granted;

  @override
  Future<void> initialize() async {}

  @override
  Future<NotificationPermissionState> permissionState() async => permission;

  @override
  Future<bool> requestPermission() async => true;

  @override
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
    String localeCode = 'ru',
  }) async {
    if (failScheduling) throw StateError('scheduler unavailable');
    lastMessages = messages;
  }

  @override
  Future<void> cancelAll({String authToken = ''}) async {
    if (failCancellation) throw StateError('subscription still active');
  }
}
