# Muslingo 🐱

Персональный AI-тренер по Корану, арабскому языку и основам ислама.
Приложение написано на Flutter и работает и в вебе, и на мобильных
(Android / iOS) из одной кодовой базы.

## Что это

Muslingo — обучающее приложение в духе языковых тренажёров, но про Коран
и ислам. Внутри:

- **Уроки** — короткие интерактивные задания по чтению и пониманию.
- **Коран** — чтение аятов с каноническим арабским текстом, переводом и аудио.
- **Режим хафиза** — заучивание наизусть с отслеживанием прогресса.
- **AI-тренер (коуч)** — персональные подсказки и разборы на основе твоего
  прогресса; ответы сопровождаются ссылками на источники.
- **Оценка произношения** — распознавание речи и обратная связь по чтению.
- **Геймификация** — страйки, жизни, достижения, лидерборд и лиги, друзья.

Приложение **локально-первое**. Без заданного `MUSLINGO_API_URL` и без базы
данных оно полностью работает на устройстве: гостевой вход, локальные
email-аккаунты и локальный прогресс хранятся в `shared_preferences`.
Бэкенд подключается опционально и добавляет синхронизацию прогресса между
устройствами, серверный лидерборд и пуш-напоминания.

## Стек

- **Клиент:** Flutter (Dart, `>=3.0.0 <4.0.0`), `provider` для состояния,
  `go_router`, `just_audio`, `speech_to_text`, `flutter_local_notifications`.
- **Бэкенд (опционально):** Node.js (ESM, `>=20`) как serverless-функции на
  Vercel — единая точка входа `api/index.js` маршрутизирует запросы в
  `server/routes/*`.
- **База данных (опционально):** Neon Postgres (`@neondatabase/serverless`).
- **Аутентификация бэкенда:** JWT (`jose`); пуш-уведомления через `web-push` (VAPID).
- **Данные Корана:** канонический арабский текст встроен в ассеты; переводы и
  аудио подтягиваются из внешних источников (alquran.cloud и др.) с кешированием.

## Структура проекта

```
lib/
  main.dart      # Точка входа и навигация
  screens/       # Экраны (уроки, Коран, хафиз, коуч, профиль, лидерборд, …)
  services/      # Логика: состояние, backend, Коран, речь, аудио, уведомления
  models/        # Модели данных (user, lesson, quran, coach, …)
  widgets/       # Переиспользуемые виджеты (кот-персонаж, кнопки, карточки)
  utils/         # Цвета, константы, тема
assets/          # images / audio / data / fonts
server/          # Бэкенд: routes/ (эндпоинты) и lib/ (auth, db, http, …)
api/             # index.js — точка входа serverless на Vercel
test/            # Тесты Flutter (dart)
server_test/     # Тесты бэкенда (node --test)
```

Часть сервисов имеет разделение на `*_io.dart` / `*_web.dart` / `*_stub.dart`
для платформенных реализаций (аудио, речь, уведомления, установка PWA).

## Как запустить

Flutter SDK в этом окружении лежит вне PATH, поэтому вызовы указаны полным путём.

```bash
# Установить зависимости Flutter
/Users/alanbaimukhan/dev/flutter/bin/flutter pub get

# Запустить в браузере (локальный режим, без бэкенда)
/Users/alanbaimukhan/dev/flutter/bin/flutter run -d chrome
```

Чтобы подключить бэкенд при локальном запуске, передай URL через dart-define:

```bash
/Users/alanbaimukhan/dev/flutter/bin/flutter run -d chrome \
  --dart-define=MUSLINGO_API_URL=https://muslingo-mobile.vercel.app
```

## Тесты

```bash
# Тесты клиента (Flutter)
/Users/alanbaimukhan/dev/flutter/bin/flutter test

# Тесты бэкенда (Node, node --test)
pnpm run test:api
```

## Сборка web

```bash
/Users/alanbaimukhan/dev/flutter/bin/flutter build web --release
```

Результат — в `build/web`. Опционально можно передать
`--dart-define=MUSLINGO_API_URL=...` и `--dart-define=MUSLINGO_SPEECH_API_URL=...`.

## Деплой на Vercel

Проект на Vercel называется **muslingo-mobile**. Сборка Flutter выполняется
**на стороне Vercel** — репозиторий не хранит собранный web. Команды заданы в
`vercel.json`:

- `installCommand` ставит зависимости и клонирует стабильный Flutter в
  `.vercel_flutter`;
- `buildCommand` прогоняет тесты (`pnpm test:api`, `flutter test`) и собирает
  web (`flutter build web --release`), пробрасывая dart-define из переменных
  окружения;
- `outputDirectory` — `build/web`.

Подробности и пошаговая инструкция — в [DEPLOY.md](DEPLOY.md).

## Переменные окружения

**Клиент (dart-define, опциональные):**

| Переменная                 | Назначение                                                  |
|----------------------------|-------------------------------------------------------------|
| `MUSLINGO_API_URL`         | Базовый URL бэкенда. Если не задан — приложение локальное.  |
| `MUSLINGO_SPEECH_API_URL`  | URL сервиса оценки произношения (обычно тот же хост).       |

**Сервер (нужны только если включаешь бэкенд):**

| Переменная          | Назначение                                    |
|---------------------|-----------------------------------------------|
| `DATABASE_URL`      | Строка подключения к Neon Postgres.           |
| `JWT_SECRET`        | Секрет для подписи JWT.                        |
| `CRON_SECRET`       | Защита cron-эндпоинта напоминаний.            |
| `VAPID_PUBLIC_KEY`  | Публичный ключ VAPID для веб-пушей.           |
| `VAPID_PRIVATE_KEY` | Приватный ключ VAPID.                         |
| `VAPID_SUBJECT`     | Контактный subject для VAPID (mailto/URL).    |

Дополнительно бэкенд читает необязательные `MUSLINGO_APP_ORIGIN`,
`MUSLINGO_JWT_ISS`, `MUSLINGO_JWT_AUD`, `MUSLINGO_JWT_TTL`,
`MUSLINGO_LOGIN_IP_MAX`, `MUSLINGO_PUSH_ALLOWED_HOSTS`. Пример — в `.env.example`.

Для **локального режима** серверные переменные не нужны вовсе: не задавай
`MUSLINGO_API_URL` — и приложение полностью работает на устройстве.
