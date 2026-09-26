import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/notification_copy.dart';
import 'package:muslingo/models/reminder_message.dart';
import 'package:muslingo/services/notification_service_io.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const pluginChannel =
      MethodChannel('dexterous.com/flutter/local_notifications');
  final calls = <MethodCall>[];
  var zone = 'Asia/Almaty';
  final messenger =
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  setUp(() {
    calls.clear();
    zone = 'Asia/Almaty';
    tz_data.initializeTimeZones();
    debugDefaultTargetPlatformOverride = TargetPlatform.iOS;
    IOSFlutterLocalNotificationsPlugin.registerWith();
    messenger.setMockMethodCallHandler(NotificationPlatform.timeZoneChannel,
        (call) async {
      expect(call.method, 'getLocalTimeZone');
      return zone;
    });
    messenger.setMockMethodCallHandler(pluginChannel, (call) async {
      calls.add(call);
      if (call.method == 'getNotificationAppLaunchDetails') {
        return {'notificationLaunchedApp': false};
      }
      if (call.method == 'initialize') return true;
      return null;
    });
  });

  tearDown(() {
    messenger.setMockMethodCallHandler(
        NotificationPlatform.timeZoneChannel, null);
    messenger.setMockMethodCallHandler(pluginChannel, null);
    debugDefaultTargetPlatformOverride = null;
  });

  test(
      'native scheduling sends IANA zone, local hour and private localized preview',
      () async {
    final platform = NotificationPlatform(supportedOverride: true);
    await platform.scheduleDaily(
      hour: 19,
      minute: 30,
      messages: const [
        ReminderMessage('Sensitive title', 'Private learning goal')
      ],
      localeCode: 'kk',
    );
    final scheduled =
        calls.where((call) => call.method == 'zonedSchedule').toList();
    expect(scheduled, hasLength(7));
    for (final call in scheduled) {
      final arguments = call.arguments as Map;
      expect(arguments['timeZoneName'], 'Asia/Almaty');
      expect(arguments['payload'], '/daily-plan');
      expect(arguments['scheduledDateTime'].toString(), contains('T19:30:00'));
      expect(arguments['title'], 'Muslingo');
      expect(arguments['body'],
          const NotificationCopy('kk').visibleBody('', false));
      expect(arguments.toString(), isNot(contains('Private learning goal')));
    }
    final initialization = calls
        .firstWhere((call) => call.method == 'initialize')
        .arguments as Map;
    expect(initialization['notificationCategories'].toString(),
        contains('Сабақты бастау'));
    expect(initialization['requestAlertPermission'], isFalse);
  });

  test(
      'initialization refreshes zone after travel and locale updates action labels',
      () async {
    final platform = NotificationPlatform(supportedOverride: true);
    await platform.initialize();
    expect(tz.local.name, 'Asia/Almaty');
    zone = 'America/New_York';
    await platform.initialize();
    expect(tz.local.name, 'America/New_York');
    await platform.showTest(
        const ReminderMessage('Private title', 'Private body'),
        localeCode: 'en');
    final shown =
        calls.lastWhere((call) => call.method == 'show').arguments as Map;
    expect(shown['title'], 'Muslingo');
    expect(shown['payload'], '/daily-plan');
    expect(shown['body'], 'Open Muslingo to see your personal reminder.');
    final initialization =
        calls.lastWhere((call) => call.method == 'initialize').arguments as Map;
    expect(initialization['notificationCategories'].toString(),
        contains('Start lesson'));
    await platform.showTest(
        const ReminderMessage('Visible title', 'Visible body'),
        localeCode: 'en',
        showOnLockScreen: true);
    final visible =
        calls.lastWhere((call) => call.method == 'show').arguments as Map;
    expect(visible['title'], 'Visible title');
    expect(visible['body'], 'Visible body');
  });

  test('23:59 primary skips the coincident evening reminder but keeps ayahs',
      () async {
    final platform = NotificationPlatform(supportedOverride: true);
    await platform.scheduleDaily(
      hour: 23,
      minute: 59,
      streak: 5,
      messages: const [ReminderMessage('Lesson', 'Continue learning')],
      ayahMessages: const [ReminderMessage('Ayah', 'Daily ayah')],
    );
    final scheduled = calls
        .where((call) => call.method == 'zonedSchedule')
        .map((call) => call.arguments as Map)
        .toList();
    expect(scheduled.map((args) => args['id']),
        [4100, 4101, 4102, 4103, 4104, 4105, 4106, 4300]);
    expect(scheduled.last['payload'], '/daily-ayah');
    for (final args in scheduled.take(7)) {
      expect(args['scheduledDateTime'].toString(), contains('T23:59:00'));
    }
  });

  test('23:58 primary retains a strictly later evening reminder', () async {
    final platform = NotificationPlatform(supportedOverride: true);
    await platform.scheduleDaily(
      hour: 23,
      minute: 58,
      streak: 5,
      messages: const [ReminderMessage('Lesson', 'Continue learning')],
    );
    final scheduled = calls
        .where((call) => call.method == 'zonedSchedule')
        .map((call) => call.arguments as Map)
        .toList();
    expect(scheduled, hasLength(14));
    expect(scheduled.skip(7).map((args) => args['id']),
        [4200, 4201, 4202, 4203, 4204, 4205, 4206]);
    for (final args in scheduled.skip(7)) {
      expect(args['scheduledDateTime'].toString(), contains('T23:59:00'));
    }
  });

  test('calendar scheduling keeps chosen wall-clock time over DST changes', () {
    final ny = tz.getLocation('America/New_York');
    final beforeFall = tz.TZDateTime(ny, 2026, 10, 31, 21);
    final fall = NotificationPlatform.nextWeekdayDate(
        now: beforeFall, weekday: DateTime.sunday, hour: 19, minute: 30);
    expect((fall.year, fall.month, fall.day, fall.hour, fall.minute),
        (2026, 11, 1, 19, 30));
    expect(fall.timeZoneOffset, const Duration(hours: -5));
    final beforeSpring = tz.TZDateTime(ny, 2027, 3, 13, 21);
    final spring = NotificationPlatform.nextWeekdayDate(
        now: beforeSpring, weekday: DateTime.sunday, hour: 19, minute: 30);
    expect((spring.year, spring.month, spring.day, spring.hour, spring.minute),
        (2027, 3, 14, 19, 30));
    expect(spring.timeZoneOffset, const Duration(hours: -4));
  });

  test(
      'unknown device zones fail explicitly while fixed OS GMT identifiers remain valid',
      () {
    expect(() => NotificationPlatform.resolveDeviceTimeZone('device_local'),
        throwsA(isA<tz.LocationNotFoundException>()));
    final fixed = NotificationPlatform.resolveDeviceTimeZone('GMT+0530');
    expect(fixed.name, 'GMT+05:30');
    expect(tz.TZDateTime(fixed, 2026).timeZoneOffset,
        const Duration(hours: 5, minutes: 30));
  });

  test('turning reminders off during scheduling leaves cancellation last',
      () async {
    final platform = NotificationPlatform(supportedOverride: true);
    await Future.wait([
      platform.scheduleDaily(
        hour: 19,
        minute: 30,
        messages: const [ReminderMessage('Title', 'Body')],
      ),
      platform.cancelAll(),
    ]);
    expect(calls.where((call) => call.method == 'zonedSchedule'), hasLength(7));
    expect(calls.last.method, 'cancelAll');
  });

  test('rapid reminder edits and final off action leave no pending schedule',
      () async {
    final platform = NotificationPlatform(supportedOverride: true);
    final operations = <Future<void>>[];
    for (var index = 0; index < 30; index++) {
      operations.add(platform.scheduleDaily(
        hour: 8 + index % 12,
        minute: index % 60,
        messages: const [ReminderMessage('Lesson', 'Continue learning')],
      ));
    }
    operations.add(platform.cancelAll());
    await Future.wait(operations);

    expect(calls.where((call) => call.method == 'zonedSchedule'),
        hasLength(30 * 7));
    expect(calls.last.method, 'cancelAll');
  });

  test('maximum reminder plan stays below the iOS 64 pending limit', () async {
    final platform = NotificationPlatform(supportedOverride: true);
    await platform.scheduleDaily(
      hour: 19,
      minute: 30,
      streak: 6,
      messages: const [ReminderMessage('Lesson', 'Continue learning')],
      ayahMessages: List.generate(
          28, (index) => ReminderMessage('Ayah $index', 'Daily ayah')),
    );
    final scheduled =
        calls.where((call) => call.method == 'zonedSchedule').toList();
    expect(scheduled, hasLength(42));
    expect(scheduled.length, lessThan(64));
  });
}
