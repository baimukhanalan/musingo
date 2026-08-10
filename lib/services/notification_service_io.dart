import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_permission_state.dart';
import '../models/reminder_message.dart';

/// ID действий-кнопок уведомления. `open_lesson` открывает приложение на
/// нужном экране, `later` просто закрывает уведомление.
const String kOpenLessonActionId = 'open_lesson';
const String kLaterActionId = 'later';

/// Фоновый обработчик действий уведомления. Вызывается в отдельном изоляте,
/// когда приложение не на переднем плане. Навигацию отсюда выполнить нельзя,
/// поэтому «Позже» тихо закрывается (cancelNotification/destructive уже сделали
/// своё), а «Начать урок» откроет приложение — маршрутизация подхватится, когда
/// приложение выйдет на передний план.
@pragma('vm:entry-point')
void notificationTapBackground(NotificationResponse response) {
  // Намеренно без действий: в фоновом изоляте нет доступа к навигатору.
}

class NotificationPlatform {
  static const _channelId = 'daily_learning';
  static const _channelName = 'Ежедневное обучение';
  static const _channelDescription =
      'Персональные напоминания о следующем уроке и повторении';
  static const _categoryId = 'daily_learning';

  /// Колбэк навигации по нажатию на тело уведомления или кнопку «Начать урок».
  /// Приложение может подписаться, чтобы открыть нужный маршрут (payload).
  /// Пока не задан — нажатие просто открывает приложение, ничего не ломая.
  static void Function(String route)? onOpenRoute;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  bool get _supported =>
      defaultTargetPlatform == TargetPlatform.android ||
      defaultTargetPlatform == TargetPlatform.iOS;

  bool get supportsBackgroundScheduling => _supported;

  void setOnOpenRoute(void Function(String route) callback) {
    onOpenRoute = callback;
  }

  Future<void> initialize() async {
    if (_initialized || !_supported) return;

    const android = AndroidInitializationSettings('@mipmap/ic_launcher');
    final darwin = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
      notificationCategories: <DarwinNotificationCategory>[
        DarwinNotificationCategory(
          _categoryId,
          actions: <DarwinNotificationAction>[
            DarwinNotificationAction.plain(
              kOpenLessonActionId,
              'Начать урок',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              kLaterActionId,
              'Позже',
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.destructive,
              },
            ),
          ],
        ),
      ],
    );
    final settings = InitializationSettings(
      android: android,
      iOS: darwin,
    );
    await _plugin.initialize(
      settings,
      onDidReceiveNotificationResponse: _handleResponse,
      onDidReceiveBackgroundNotificationResponse: notificationTapBackground,
    );
    final launch = await _plugin.getNotificationAppLaunchDetails();
    _configureDeviceTimeZone();
    _initialized = true;
    if (launch?.didNotificationLaunchApp == true) {
      final response = launch?.notificationResponse;
      if (response != null) _handleResponse(response);
    }
  }

  /// Обработка нажатий на переднем плане: по телу уведомления или по кнопке
  /// «Начать урок» — навигация на маршрут из payload (по умолчанию '/home');
  /// по кнопке «Позже» — ничего, уведомление уже закрыто.
  static void _handleResponse(NotificationResponse response) {
    if (response.actionId == kLaterActionId) return;
    final payload = response.payload;
    final route = (payload == null || payload.isEmpty) ? '/home' : payload;
    onOpenRoute?.call(route);
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
    String name = '',
    int streak = 0,
    String authToken = '',
  }) async {
    await initialize();
    if (!_supported || messages.isEmpty) return;
    await cancelAll();

    // Основное дневное напоминание — ротация персональных сообщений по дням.
    for (var index = 0; index < 7; index++) {
      final message = messages[index % messages.length];
      await _plugin.zonedSchedule(
        4100 + index,
        message.title,
        message.body,
        _nextWeekday(index + 1, hour, minute),
        _detailsFor(message.body),
        payload: '/home',
        androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      );
    }

    // Второе — вечерний нудж «не потеряй серию». Планируем только если серия
    // идёт, позже основного и не раньше 20:30. В сумме не более 2 в день.
    if (streak > 0) {
      final eveningMinutes = _eveningMinutes(hour, minute);
      final eveningHour = eveningMinutes ~/ 60;
      final eveningMinute = eveningMinutes % 60;
      final streakMessage = buildStreakReminder(name: name, streak: streak);
      for (var index = 0; index < 7; index++) {
        await _plugin.zonedSchedule(
          4200 + index,
          streakMessage.title,
          streakMessage.body,
          _nextWeekday(index + 1, eveningHour, eveningMinute),
          _detailsFor(streakMessage.body),
          payload: '/home',
          androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
          uiLocalNotificationDateInterpretation:
              UILocalNotificationDateInterpretation.absoluteTime,
          matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        );
      }
    }
  }

  /// Время вечернего напоминания: не раньше 20:30 и на час позже основного,
  /// но в пределах текущих суток.
  int _eveningMinutes(int hour, int minute) {
    const floor = 20 * 60 + 30;
    final afterPrimary = hour * 60 + minute + 60;
    var minutes = afterPrimary > floor ? afterPrimary : floor;
    if (minutes > 23 * 60 + 59) minutes = 23 * 60 + 59;
    return minutes;
  }

  /// Интерактивные кнопки уведомления (Android). На iOS их даёт категория
  /// [_categoryId], зарегистрированная при инициализации.
  static const _androidActions = <AndroidNotificationAction>[
    AndroidNotificationAction(
      kOpenLessonActionId,
      'Начать урок',
      showsUserInterface: true,
    ),
    AndroidNotificationAction(
      kLaterActionId,
      'Позже',
      cancelNotification: true,
    ),
  ];

  /// Rich-детали уведомления: разворачиваемый body (BigTextStyle), иконка-кот
  /// (largeIcon) и интерактивные кнопки. body передаём явно, чтобы развёрнутый
  /// вид показывал полный текст сообщения.
  NotificationDetails _detailsFor(String body) => NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _channelName,
          channelDescription: _channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          styleInformation: BigTextStyleInformation(body),
          largeIcon: const DrawableResourceAndroidBitmap('@mipmap/ic_launcher'),
          actions: _androidActions,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
          threadIdentifier: 'daily_learning',
          categoryIdentifier: _categoryId,
        ),
      );

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

  Future<void> cancelAll({String authToken = ''}) async {
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
      _detailsFor(message.body),
      payload: '/home',
    );
    return true;
  }
}
