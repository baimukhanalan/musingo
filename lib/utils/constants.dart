class AppConstants {
  static const String appName = 'muslingo';
  static const String appVersion = '1.0.0';

  // Геймификация
  static const int maxHearts = 5;
  static const int xpPerCorrectAnswer = 5;
  static const int xpPerLesson = 25;
  static const int xpPerRepeat = 2;
  static const int xpPerModule = 15;
  static const int xpPerLevel = 500;

  // Страйк-бонусы
  static const int streak7Days = 10;
  static const int streak30Days = 50;
  static const int streak100Days = 200;

  // Уроки
  static const int quranLessonsCount = 20;
  static const int rulesLessonsCount = 15;

  // Размеры
  static const double borderRadius = 12.0;
  static const double buttonHeight = 56.0;
  static const double cardRadius = 16.0;
  static const double padding = 16.0;
  static const double paddingLarge = 24.0;

  // Анимации (ms)
  static const int animDuration = 300;
  static const int animLong = 600;
}

class AppStrings {
  static const String lessons = 'Уроки';
  static const String quran = 'Коран';
  static const String rules = 'Правила';
  static const String profile = 'Профиль';

  static const String check = 'Проверить';
  static const String hint = 'Подсказка';
  static const String continueStr = 'Продолжить';
  static const String repeat = 'Повторить урок';
  static const String start = 'Начать';

  static const String streak = 'дней подряд';
  static const String xp = 'XP';
  static const String level = 'Уровень';
  static const String hearts = 'Жизни';
}
