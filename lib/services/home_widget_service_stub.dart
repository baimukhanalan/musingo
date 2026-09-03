class HomeWidgetPlatform {
  bool get isSupported => false;

  Future<void> update({required String localeCode}) async {}

  Future<void> clear() async {}

  Future<bool> requestPin() async => false;
}
