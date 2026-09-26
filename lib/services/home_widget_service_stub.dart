class HomeWidgetPlatform {
  bool get isSupported => false;

  Future<Uri?> initiallyLaunchedFromHomeWidget() async => null;

  Stream<Uri?> get widgetClicked => const Stream.empty();

  Future<void> update(
      {required String localeCode, String coachLine = ''}) async {}

  Future<void> clear() async {}

  Future<bool> requestPin() async => false;
}
