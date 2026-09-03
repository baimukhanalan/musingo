import 'dart:convert';
import 'dart:io';

import 'package:home_widget/home_widget.dart';

import '../models/daily_ayah.dart';
import '../utils/app_locale.dart';

class HomeWidgetPlatform {
  static const _appGroupId = 'group.com.muslingo.app';
  static const _androidProvider = 'MuslingoAyahWidgetProvider';
  static const _iOSWidget = 'MuslingoAyahWidget';

  bool get isSupported => Platform.isAndroid || Platform.isIOS;

  Future<void> update({required String localeCode}) async {
    if (!isSupported) return;
    if (Platform.isIOS) await HomeWidget.setAppGroupId(_appGroupId);

    final locale = AppLocale.fromCode(localeCode);
    final now = DateTime.now();
    final entries = <Map<String, Object?>>[];
    final title = switch (locale) {
      AppLocale.ru => 'Аят дня',
      AppLocale.kk => 'Күн аяты',
      AppLocale.en => 'Ayah of the day',
    };
    for (var offset = 0; offset < 30; offset++) {
      final date = DateTime(now.year, now.month, now.day + offset);
      final ayah = DailyAyahData.ofDay(date);
      if (ayah == null) continue;
      entries.add({
        'date': _dateKey(date),
        'number': ayah.globalAyahNumber,
        'title': title,
        'arabic': ayah.arabic,
        'translation': switch (locale) {
          AppLocale.ru => ayah.translation,
          AppLocale.kk => ayah.translation,
          AppLocale.en => ayah.translation,
        },
      });
    }

    await HomeWidget.saveWidgetData<String>(
      'daily_ayah_payload',
      jsonEncode(entries),
    );
    await HomeWidget.saveWidgetData<String>('widget_locale', locale.code);
    await HomeWidget.updateWidget(
      name: _androidProvider,
      iOSName: _iOSWidget,
    );
  }

  Future<void> clear() async {
    if (!isSupported) return;
    if (Platform.isIOS) await HomeWidget.setAppGroupId(_appGroupId);
    await HomeWidget.saveWidgetData<String>('daily_ayah_payload', '[]');
    await HomeWidget.updateWidget(
      name: _androidProvider,
      iOSName: _iOSWidget,
    );
  }

  Future<bool> requestPin() async {
    if (!Platform.isAndroid) return false;
    await HomeWidget.requestPinWidget(
      name: _androidProvider,
      androidName: _androidProvider,
    );
    return true;
  }

  String _dateKey(DateTime date) => '${date.year.toString().padLeft(4, '0')}-'
      '${date.month.toString().padLeft(2, '0')}-'
      '${date.day.toString().padLeft(2, '0')}';
}
