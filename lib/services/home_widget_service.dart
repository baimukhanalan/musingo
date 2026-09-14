import 'home_widget_service_stub.dart'
    if (dart.library.io) 'home_widget_service_io.dart' as platform;

class HomeWidgetService {
  final platform.HomeWidgetPlatform _platform = platform.HomeWidgetPlatform();

  bool get isSupported => _platform.isSupported;

  Future<void> update({required String localeCode, String coachLine = ''}) =>
      _platform.update(localeCode: localeCode, coachLine: coachLine);

  Future<void> clear() => _platform.clear();

  Future<bool> requestPin() => _platform.requestPin();
}
