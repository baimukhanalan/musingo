import '../services/lesson_data.dart';
import '../services/lesson_content_localization.dart';
import '../utils/app_locale.dart';
import 'reminder_message.dart';

class AyahOfDay {
  final int globalAyahNumber;
  final String arabic;
  final String transliteration;
  final String translation;

  const AyahOfDay({
    required this.globalAyahNumber,
    required this.arabic,
    required this.transliteration,
    required this.translation,
  });

  String? translationFor(AppLocale locale) {
    if (locale == AppLocale.ru) return translation;
    final localized =
        LessonContentLocalization.translateText(translation, locale.code);
    // Never present untranslated Russian as a Kazakh or English translation.
    return localized == translation || localized.trim().isEmpty
        ? null
        : localized;
  }

  String transliterationFor(AppLocale locale) =>
      LessonContentLocalization.transliterationFor(
          transliteration, locale.code) ??
      transliteration;

  String secondaryTextFor(AppLocale locale) =>
      translationFor(locale) ?? transliterationFor(locale);
}

class DailyAyahData {
  static List<AyahOfDay> buildPool() {
    final byNumber = <int, AyahOfDay>{};
    for (final lesson in LessonData.quranCourse.lessons) {
      for (final step in lesson.steps) {
        final number = step.quranGlobalAyahNumber;
        final arabic = step.arabicText?.trim();
        final translit = step.transliteration?.trim();
        final russian = step.russianText?.trim();
        if (number == null ||
            arabic == null ||
            arabic.isEmpty ||
            translit == null ||
            translit.isEmpty ||
            russian == null ||
            russian.isEmpty) {
          continue;
        }
        byNumber.putIfAbsent(
          number,
          () => AyahOfDay(
            globalAyahNumber: number,
            arabic: arabic,
            transliteration: translit,
            translation: russian,
          ),
        );
      }
    }
    return byNumber.values.toList(growable: false)
      ..sort((a, b) => a.globalAyahNumber.compareTo(b.globalAyahNumber));
  }

  static int calendarDayIndex(DateTime date) {
    return DateTime.utc(date.year, date.month, date.day)
            .millisecondsSinceEpoch ~/
        Duration.millisecondsPerDay;
  }

  static AyahOfDay? ofDay(DateTime date, {List<AyahOfDay>? pool}) {
    final ayahs = pool ?? buildPool();
    if (ayahs.isEmpty) return null;
    return ayahs[calendarDayIndex(date) % ayahs.length];
  }

  static Duration untilNextLocalDay(DateTime date) {
    final tomorrow = DateTime(date.year, date.month, date.day + 1);
    return tomorrow.difference(date);
  }

  static List<ReminderMessage> notificationMessages({
    required DateTime start,
    required int count,
    required AppLocale locale,
  }) {
    final pool = buildPool();
    final title = switch (locale) {
      AppLocale.ru => 'Аят дня',
      AppLocale.kk => 'Күн аяты',
      AppLocale.en => 'Ayah of the day',
    };
    return List<ReminderMessage>.generate(count, (index) {
      final date = DateTime(start.year, start.month, start.day + index);
      final ayah = ofDay(date, pool: pool);
      if (ayah == null) return const ReminderMessage('', '');
      return ReminderMessage(
        '$title · №${ayah.globalAyahNumber}',
        '${ayah.arabic}\n${ayah.secondaryTextFor(locale)}',
      );
    }).where((message) => message.title.isNotEmpty).toList(growable: false);
  }
}
