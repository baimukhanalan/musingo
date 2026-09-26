/// Non-sensitive notification chrome. Never derive this from the last message
/// generated: test sends and concurrent screens must use the selected locale.
class NotificationCopy {
  final String localeCode;
  const NotificationCopy(this.localeCode);

  String get open => switch (localeCode) {
        'kk' => 'Сабақты бастау',
        'en' => 'Start lesson',
        'ar' => 'بدء الدرس',
        _ => 'Начать урок',
      };
  String get later => switch (localeCode) {
        'kk' => 'Кейінірек',
        'en' => 'Later',
        'ar' => 'لاحقًا',
        _ => 'Позже',
      };
  String get channelName => switch (localeCode) {
        'kk' => 'Күнделікті оқу',
        'en' => 'Daily learning',
        'ar' => 'التعلّم اليومي',
        _ => 'Ежедневное обучение',
      };
  String get channelDescription => switch (localeCode) {
        'kk' => 'Келесі сабақ пен қайталау туралы жеке еске салулар',
        'en' => 'Personal reminders for your next lesson and review',
        'ar' => 'تذكيرات شخصية بموعد الدرس التالي والمراجعة',
        _ => 'Персональные напоминания о следующем уроке и повторении',
      };
  String visibleTitle(String title, bool showOnLockScreen) =>
      showOnLockScreen ? title : 'Muslingo';
  String visibleBody(String body, bool showOnLockScreen) => showOnLockScreen
      ? body
      : switch (localeCode) {
          'kk' => 'Жеке еске салуды көру үшін Muslingo қолданбасын аш.',
          'en' => 'Open Muslingo to see your personal reminder.',
          'ar' => 'افتح Muslingo للاطلاع على تذكيرك الشخصي.',
          _ => 'Открой Muslingo, чтобы увидеть персональное напоминание.',
        };
}
