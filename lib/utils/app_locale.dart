import 'package:flutter/widgets.dart';

/// Язык интерфейса приложения. Отдельно от [NativeLanguage] (родной язык для
/// подсказок): AppLocale управляет тем, на каком языке показывается сам UI.
enum AppLocale {
  ru('ru', 'RU'),
  kk('kk', 'KZ'),
  en('en', 'EN');

  /// Код языка для хранения/[Locale] — "ru" / "kk" / "en".
  final String code;

  /// Короткая подпись для пилюль переключателя — "RU" / "KZ" / "EN".
  final String label;

  const AppLocale(this.code, this.label);

  /// [Locale] для MaterialApp.
  Locale toLocale() => Locale(code);

  /// Разбор сохранённого кода. Неизвестный/пустой код даёт дефолт — русский.
  static AppLocale fromCode(String? code) {
    for (final locale in values) {
      if (locale.code == code) return locale;
    }
    return AppLocale.ru;
  }

  /// Разбор по подписи пилюли ("RU"/"KZ"/"EN"). Для обратной совместимости с
  /// [LanguagePills], который исторически оперировал подписями, а не кодами.
  static AppLocale? fromLabel(String? label) {
    for (final locale in values) {
      if (locale.label == label) return locale;
    }
    return null;
  }
}
