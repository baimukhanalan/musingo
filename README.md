# muslingo 🐱

**Duolingo для ислама** — Flutter-приложение для Android и iOS.

## Быстрый старт

```bash
# 1. Установить зависимости
flutter pub get

# 2. Запустить приложение
flutter run

# 3. Собрать APK для Android
flutter build apk --release

# 4. Собрать IPA для iOS
flutter build ios --release
```

## Структура проекта

```
lib/
  main.dart              # Точка входа + навигация
  utils/
    colors.dart          # Цветовая палитра
    constants.dart       # Константы
    theme.dart           # Тема приложения
  models/
    user.dart            # Модель пользователя
    lesson.dart          # Модели урока и курса
    achievement.dart     # Достижения
    leaderboard.dart     # Лидерборд и турниры
  services/
    app_state.dart       # Глобальное состояние (Provider)
    lesson_data.dart     # Данные уроков, сур Корана
  widgets/
    cat_character.dart   # Кот-персонаж с анимациями
    custom_button.dart   # Кнопки
    lesson_card.dart     # Карточка урока
    stats_row.dart       # Полоса статистики
  screens/
    carousel_screen.dart    # Приветственная карусель
    login_screen.dart       # Регистрация / вход
    main_tab_screen.dart    # TabBar навигация
    home_screen.dart        # Главный экран (уроки)
    lesson_screen.dart      # Экран урока
    lesson_review_screen.dart # Итоги урока
    quran_screen.dart       # Коран с аятами
    rules_screen.dart       # Правила ислама
    profile_screen.dart     # Профиль
    premium_screen.dart     # muslingo+
    leaderboard_screen.dart # Лидерборд + турниры
    achievements_screen.dart # Достижения
    streak_screen.dart      # Страйк
    settings_screen.dart    # Настройки + помощь

assets/
  images/
    cat_idle.svg      # Кот — спокойный
    cat_success.svg   # Кот — успех
    cat_error.svg     # Кот — ошибка
    cat_greet.svg     # Кот — приветствие
    cat_support.svg   # Кот — поддержка
    cat_praise.svg    # Кот — похвала
```

## Цветовая палитра

| Цвет | HEX | Использование |
|------|-----|---------------|
| Белый | `#FFFFFF` | Фон |
| Фисташковый светлый | `#C8E6C9` | Акценты |
| Фисташковый тёмный | `#81C784` | Кнопки |
| Успех | `#4CAF50` | Правильные ответы |
| Ошибка | `#E57373` | Неправильные ответы |
| Золотой | `#D4AF37` | Тюрбан кота, достижения |

## Зависимости

- `provider` — управление состоянием
- PNG-иллюстрации кота — состояния помощника
- `flutter_animate` — анимации
- `shared_preferences` — локальное хранилище
- `just_audio` — аудио Корана
- Tanzil Uthmani — встроенный неизменённый арабский текст
