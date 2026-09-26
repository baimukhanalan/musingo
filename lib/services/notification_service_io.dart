import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../models/notification_copy.dart';
import '../models/notification_permission_state.dart';
import '../models/reminder_message.dart';
import '../utils/app_locale.dart';
import '../utils/runtime_environment.dart';

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
  static const _categoryId = 'daily_learning';
  static const timeZoneChannel = MethodChannel('com.muslingo.app/timezone');
  static bool _timeZoneDataLoaded = false;

  /// Колбэк навигации по нажатию на тело уведомления или кнопку «Начать урок».
  /// Приложение может подписаться, чтобы открыть нужный маршрут (payload).
  /// Пока не задан — нажатие просто открывает приложение, ничего не ломая.
  static void Function(String route)? onOpenRoute;

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();
  bool _initialized = false;
  String _localeCode = 'ru';
  String? _initializedLocale;
  final bool? _supportedOverride;
  Future<void> _pendingOperations = Future<void>.value();

  Future<T> _exclusive<T>(Future<T> Function() action) {
    final operation = _pendingOperations.then((_) => action());
    _pendingOperations =
        operation.then<void>((_) {}, onError: (Object _, StackTrace __) {});
    return operation;
  }

  NotificationPlatform({@visibleForTesting bool? supportedOverride})
      : _supportedOverride = supportedOverride;

  NotificationCopy get _copy => NotificationCopy(_localeCode);

  bool get _supported =>
      _supportedOverride ??
      (!isFlutterTest &&
          (defaultTargetPlatform == TargetPlatform.android ||
              defaultTargetPlatform == TargetPlatform.iOS));

  bool get supportsBackgroundScheduling => _supported;
  bool get supportsNativeSurfaces => _supported;

  void setOnOpenRoute(void Function(String route) callback) {
    onOpenRoute = callback;
  }

  Future<void> initialize() async {
    if (!_supported) return;
    // Re-read the OS identifier after travel/time-zone settings changes, even
    // when the plugin itself is already registered.
    await _configureDeviceTimeZone();
    if (_initialized && _initializedLocale == _localeCode) return;
    final wasInitialized = _initialized;

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
              _copy.open,
              options: <DarwinNotificationActionOption>{
                DarwinNotificationActionOption.foreground,
              },
            ),
            DarwinNotificationAction.plain(
              kLaterActionId,
              _copy.later,
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
    final launch =
        wasInitialized ? null : await _plugin.getNotificationAppLaunchDetails();
    _initialized = true;
    _initializedLocale = _localeCode;
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

  Future<void> _configureDeviceTimeZone() async {
    if (!_timeZoneDataLoaded) {
      tz_data.initializeTimeZones();
      _timeZoneDataLoaded = true;
    }
    final identifier =
        await timeZoneChannel.invokeMethod<String>('getLocalTimeZone');
    if (identifier == null || identifier.isEmpty) {
      throw StateError('The device did not return a valid time zone.');
    }
    tz.setLocalLocation(resolveDeviceTimeZone(identifier));
  }

  @visibleForTesting
  static tz.Location resolveDeviceTimeZone(String identifier) {
    try {
      return tz.getLocation(identifier);
    } on tz.LocationNotFoundException {
      // An explicitly selected fixed GMT zone is also a valid OS identifier.
      // Never invent a name such as device_local: native schedulers reject it.
      final match = RegExp(r'^(?:GMT|UTC)([+-])(\d{1,2})(?::?(\d{2}))?$')
          .firstMatch(identifier);
      if (match == null) rethrow;
      final hour = int.parse(match[2]!);
      final minute = int.parse(match[3] ?? '0');
      if (hour > 14 || minute > 59 || (hour == 14 && minute != 0)) rethrow;
      final name =
          'GMT${match[1]}${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';
      final offset =
          (hour * 60 + minute) * 60 * 1000 * (match[1] == '-' ? -1 : 1);
      return tz.Location(name, const [], const [], [
        tz.TimeZone(offset, isDst: false, abbreviation: name),
      ]);
    }
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
    List<ReminderMessage> ayahMessages = const [],
    int ayahHour = 8,
    int ayahMinute = 15,
    bool showOnLockScreen = false,
    String localeCode = 'ru',
  }) =>
      _exclusive(() async {
        _localeCode = localeCode;
        await initialize();
        if (!_supported || messages.isEmpty) return;
        await _plugin.cancelAll();

        // Основное дневное напоминание — ротация персональных сообщений по дням.
        for (var index = 0; index < 7; index++) {
          final message = messages[index % messages.length];
          await _plugin.zonedSchedule(
            4100 + index,
            _visibleTitle(message.title, showOnLockScreen),
            _visibleBody(message.body, showOnLockScreen),
            _nextWeekday(index + 1, hour, minute),
            _detailsFor(message.body, showOnLockScreen: showOnLockScreen),
            payload: '/daily-plan',
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
          final streakMessage = buildStreakReminder(
            name: name,
            streak: streak,
            locale: AppLocale.fromCode(localeCode),
          );
          for (var index = 0; index < 7; index++) {
            await _plugin.zonedSchedule(
              4200 + index,
              _visibleTitle(streakMessage.title, showOnLockScreen),
              _visibleBody(streakMessage.body, showOnLockScreen),
              _nextWeekday(index + 1, eveningHour, eveningMinute),
              _detailsFor(streakMessage.body,
                  showOnLockScreen: showOnLockScreen),
              payload: '/daily-plan',
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
              matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
            );
          }
        }

        // Аят дня планируется отдельной серией одноразовых уведомлений. 28 дней
        // сохраняют ежедневную ротацию и укладываются вместе с уроками в лимит iOS
        // на 64 ожидающих локальных уведомления.
        final now = tz.TZDateTime.now(tz.local);
        var firstAyahDate = tz.TZDateTime(
          tz.local,
          now.year,
          now.month,
          now.day,
          ayahHour,
          ayahMinute,
        );
        if (!firstAyahDate.isAfter(now)) {
          firstAyahDate = tz.TZDateTime(
              tz.local, now.year, now.month, now.day + 1, ayahHour, ayahMinute);
        }
        for (var index = 0;
            index < ayahMessages.length && index < 28;
            index++) {
          final message = ayahMessages[index];
          final scheduled = tz.TZDateTime(
              tz.local,
              firstAyahDate.year,
              firstAyahDate.month,
              firstAyahDate.day + index,
              ayahHour,
              ayahMinute);
          await _plugin.zonedSchedule(
            4300 + index,
            _visibleTitle(message.title, showOnLockScreen),
            _visibleBody(message.body, showOnLockScreen),
            scheduled,
            _detailsFor(message.body, showOnLockScreen: showOnLockScreen),
            payload: '/home',
            androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        }
      });

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
  List<AndroidNotificationAction> get _androidActions => [
        AndroidNotificationAction(
          kOpenLessonActionId,
          _copy.open,
          showsUserInterface: true,
        ),
        AndroidNotificationAction(
          kLaterActionId,
          _copy.later,
          cancelNotification: true,
        ),
      ];

  /// Rich-детали уведомления: разворачиваемый body (BigTextStyle), иконка-кот
  /// (largeIcon) и интерактивные кнопки. body передаём явно, чтобы развёрнутый
  /// вид показывал полный текст сообщения.
  String _visibleBody(String body, bool showOnLockScreen) =>
      _copy.visibleBody(body, showOnLockScreen);

  String _visibleTitle(String title, bool showOnLockScreen) =>
      _copy.visibleTitle(title, showOnLockScreen);

  NotificationDetails _detailsFor(
    String body, {
    bool showOnLockScreen = false,
  }) =>
      NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          _copy.channelName,
          channelDescription: _copy.channelDescription,
          importance: Importance.high,
          priority: Priority.high,
          category: AndroidNotificationCategory.reminder,
          styleInformation: BigTextStyleInformation(
            _visibleBody(body, showOnLockScreen),
          ),
          visibility: showOnLockScreen
              ? NotificationVisibility.public
              : NotificationVisibility.private,
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
    return nextWeekdayDate(
        now: tz.TZDateTime.now(tz.local),
        weekday: weekday,
        hour: hour,
        minute: minute);
  }

  @visibleForTesting
  static tz.TZDateTime nextWeekdayDate({
    required tz.TZDateTime now,
    required int weekday,
    required int hour,
    required int minute,
  }) {
    var scheduled = tz.TZDateTime(
      now.location,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    while (scheduled.weekday != weekday || !scheduled.isAfter(now)) {
      scheduled = tz.TZDateTime(now.location, scheduled.year, scheduled.month,
          scheduled.day + 1, hour, minute);
    }
    return scheduled;
  }

  Future<void> cancelAll({String authToken = ''}) => _exclusive(() async {
        if (!_supported) return;
        // Cancellation must still work if the OS returns an unfamiliar zone.
        // Native plugins are registered by the app independently of scheduling.
        await _plugin.cancelAll();
      });

  Future<bool> showTest(
    ReminderMessage message, {
    String localeCode = 'ru',
    bool showOnLockScreen = false,
  }) =>
      _exclusive(() async {
        _localeCode = localeCode;
        await initialize();
        if (!_supported) return false;
        await _plugin.show(
          4099,
          _visibleTitle(message.title, showOnLockScreen),
          _visibleBody(message.body, showOnLockScreen),
          _detailsFor(message.body, showOnLockScreen: showOnLockScreen),
          payload: '/home',
        );
        return true;
      });
}
