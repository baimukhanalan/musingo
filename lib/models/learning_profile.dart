enum LearningGoal {
  arabicReading,
  shortSurahs,
  pronunciation,
  quranMeaning,
  islamBasics,
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

  static LearningGoal? fromStorage(String? value) {
    for (final goal in LearningGoal.values) {
      if (goal.storageValue == value) return goal;
    }
    return null;
  }
}
