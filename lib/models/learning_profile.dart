import 'dart:math' as math;

import '../utils/app_locale.dart';

enum LearningGoal {
  arabicReading,
  shortSurahs,
  pronunciation,
  quranMeaning,
  islamBasics,
}

enum LearningSkill {
  letters,
  reading,
  surahRecall,
  meaning,
  tajwid,
}

class LearningSkillProfile {
  final Map<LearningSkill, int> scores;

  const LearningSkillProfile(this.scores);

  int scoreFor(LearningSkill skill) => scores[skill]?.clamp(0, 100) ?? 0;

  LearningSkill get weakestSkill => LearningSkill.values.reduce(
        (current, next) => scoreFor(next) < scoreFor(current) ? next : current,
      );

  int get overallScore {
    if (scores.isEmpty) return 0;
    final total = LearningSkill.values.fold<int>(
      0,
      (sum, skill) => sum + scoreFor(skill),
    );
    return (total / LearningSkill.values.length).round();
  }

  int get placementLevel =>
      math.max(1, math.min(8, (overallScore / 13).floor() + 1));

  Map<String, dynamic> toJson() => {
        for (final skill in LearningSkill.values) skill.name: scoreFor(skill),
      };

  factory LearningSkillProfile.fromJson(Map<String, dynamic> json) {
    final scores = <LearningSkill, int>{};
    for (final skill in LearningSkill.values) {
      final raw = json[skill.name];
      if (raw == null) {
        scores[skill] = 0;
        continue;
      }
      if (raw is! num ||
          !raw.isFinite ||
          raw % 1 != 0 ||
          raw < 0 ||
          raw > 100) {
        throw FormatException(
          'Некорректная оценка навыка ${skill.name}.',
        );
      }
      scores[skill] = raw.toInt();
    }
    return LearningSkillProfile({
      for (final entry in scores.entries) entry.key: entry.value,
    });
  }
}

extension LearningSkillDetails on LearningSkill {
  String get title {
    switch (this) {
      case LearningSkill.letters:
        return 'Буквы';
      case LearningSkill.reading:
        return 'Чтение';
      case LearningSkill.surahRecall:
        return 'Суры';
      case LearningSkill.meaning:
        return 'Смысл';
      case LearningSkill.tajwid:
        return 'Таджвид';
    }
  }
}

extension LearningGoalDetails on LearningGoal {
  String get storageValue => name;

  String get title {
    switch (this) {
      case LearningGoal.arabicReading:
        return 'Читать арабский текст';
      case LearningGoal.shortSurahs:
        return 'Выучить короткие суры';
      case LearningGoal.pronunciation:
        return 'Улучшить произношение';
      case LearningGoal.quranMeaning:
        return 'Понимать смысл Корана';
      case LearningGoal.islamBasics:
        return 'Изучить основы ислама';
    }
  }

  String titleFor(AppLocale locale) {
    if (locale == AppLocale.ru) return title;
    return switch ((this, locale)) {
      (LearningGoal.arabicReading, AppLocale.kk) => 'Араб мәтінін оқу',
      (LearningGoal.shortSurahs, AppLocale.kk) => 'Қысқа сүрелерді жаттау',
      (LearningGoal.pronunciation, AppLocale.kk) => 'Айтылымды жақсарту',
      (LearningGoal.quranMeaning, AppLocale.kk) => 'Құран мағынасын түсіну',
      (LearningGoal.islamBasics, AppLocale.kk) => 'Ислам негіздерін үйрену',
      (LearningGoal.arabicReading, AppLocale.en) => 'Read Arabic text',
      (LearningGoal.shortSurahs, AppLocale.en) => 'Memorize short surahs',
      (LearningGoal.pronunciation, AppLocale.en) => 'Improve pronunciation',
      (LearningGoal.quranMeaning, AppLocale.en) => 'Understand the Quran',
      (LearningGoal.islamBasics, AppLocale.en) => 'Learn Islam basics',
      _ => title,
    };
  }

  String get dailyFocus {
    switch (this) {
      case LearningGoal.arabicReading:
        return 'Буквы, чтение и короткая практика произношения';
      case LearningGoal.shortSurahs:
        return 'Новый фрагмент суры и повторение знакомого аята';
      case LearningGoal.pronunciation:
        return 'Прослушивание образца и точное повторение';
      case LearningGoal.quranMeaning:
        return 'Аят, ключевые слова и вопрос на понимание';
      case LearningGoal.islamBasics:
        return 'Одна основная тема и короткая проверка понимания';
    }
  }

  String dailyFocusFor(AppLocale locale) {
    if (locale == AppLocale.ru) return dailyFocus;
    return switch ((this, locale)) {
      (LearningGoal.arabicReading, AppLocale.kk) =>
        'Әріптер, оқу және қысқа айтылым жаттығуы',
      (LearningGoal.shortSurahs, AppLocale.kk) =>
        'Сүренің жаңа бөлігі және таныс аятты қайталау',
      (LearningGoal.pronunciation, AppLocale.kk) =>
        'Үлгіні тыңдау және дәл қайталау',
      (LearningGoal.quranMeaning, AppLocale.kk) =>
        'Аят, негізгі сөздер және түсіну сұрағы',
      (LearningGoal.islamBasics, AppLocale.kk) =>
        'Бір негізгі тақырып және қысқа түсіну тексерісі',
      (LearningGoal.arabicReading, AppLocale.en) =>
        'Letters, reading, and short pronunciation practice',
      (LearningGoal.shortSurahs, AppLocale.en) =>
        'A new surah fragment and review of a familiar ayah',
      (LearningGoal.pronunciation, AppLocale.en) =>
        'Listen to the model and repeat accurately',
      (LearningGoal.quranMeaning, AppLocale.en) =>
        'An ayah, key words, and a comprehension question',
      (LearningGoal.islamBasics, AppLocale.en) =>
        'One core topic and a short comprehension check',
      _ => dailyFocus,
    };
  }

  static LearningGoal? fromStorage(String? value) {
    for (final goal in LearningGoal.values) {
      if (goal.storageValue == value) return goal;
    }
    return null;
  }
}
