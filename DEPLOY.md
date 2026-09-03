# Деплой на Vercel

Инструкция по деплою Muslingo на существующий проект Vercel.

- **Проект:** `muslingo-mobile`
- **Организация (orgId):** `team_4KPwa1NMRMdJJhGGaP1pUif8`
- **Регион функций:** `fra1`

## Как устроена сборка

Собранный web в репозитории **не хранится** — Flutter ставится и собирается
самим Vercel. Всё описано в `vercel.json`, руками ничего дополнительно
настраивать не нужно:

- `installCommand` — ставит зависимости (`pnpm install --frozen-lockfile`),
  клонирует стабильный Flutter в `.vercel_flutter`, включает web и делает
  `flutter pub get`.
- `buildCommand` — прогоняет тесты (`pnpm test:api`, `flutter test`) и собирает
  web (`flutter build web --release`), пробрасывая `MUSLINGO_API_URL` и
  `MUSLINGO_SPEECH_API_URL` из переменных окружения.
- `outputDirectory` — `build/web`.
- `api/index.js` — serverless-точка входа бэкенда (маршруты в `server/routes/*`).

Так как тесты входят в `buildCommand`, «красная» сборка на Vercel означает
упавший тест — чинить нужно тест/код, а не деплой.

## Вариант A. Локальный режим (без бэкенда)

Самый простой случай — только web-приложение, вся логика на устройстве.

1. Переменные окружения **не задавай** (ни клиентские, ни серверные).
   Без `MUSLINGO_API_URL` приложение работает локально: гость, локальные
   аккаунты, локальный прогресс.
2. Задеплой:

   ```bash
   vercel deploy --prod
   ```

   (или пуш в ветку, привязанную к прод-деплою проекта `muslingo-mobile`).

## Вариант B. Полный бэкенд (синхронизация, лидерборд, пуши)

1. Заведи базу **Neon Postgres** и получи строку подключения.
2. Выставь переменные окружения проекта на Vercel
   (Project → Settings → Environment Variables):

   - `DATABASE_URL` — строка подключения к Neon.
   - `JWT_SECRET` — секрет для подписи JWT.
   - `CRON_SECRET` — секрет для cron-эндпоинта напоминаний.
   - `VAPID_PUBLIC_KEY`, `VAPID_PRIVATE_KEY`, `VAPID_SUBJECT` — для веб-пушей.
   - `OPENAI_API_KEY` — серверная транскрипция произношения на устройствах,
     где локальное распознавание речи недоступно.
   - `MUSLINGO_API_URL` и `MUSLINGO_SPEECH_API_URL` — обычно URL самого
     проекта (например `https://muslingo-mobile.vercel.app`), чтобы клиент
     ходил в свой же бэкенд.

   Необязательные: `MUSLINGO_APP_ORIGIN`, `MUSLINGO_JWT_ISS`, `MUSLINGO_JWT_AUD`,
   `MUSLINGO_JWT_TTL`, `MUSLINGO_LOGIN_IP_MAX`, `MUSLINGO_PUSH_ALLOWED_HOSTS`.
   Шаблон значений — в `.env.example`.

3. Задеплой:

   ```bash
   vercel deploy --prod
   ```

## Проверка деплоя

1. Дождись успешной сборки в дашборде Vercel (тесты проходят в `buildCommand`).
2. Открой прод-URL — web-приложение должно грузиться и работать в локальном режиме.
3. Если включён бэкенд — проверь здоровье API:

   ```bash
   curl https://muslingo-mobile.vercel.app/api/health
   ```

4. Быстрая проверка перед пушем (те же шаги, что делает Vercel):

   ```bash
   pnpm run test:api
   /Users/alanbaimukhan/dev/flutter/bin/flutter test
   /Users/alanbaimukhan/dev/flutter/bin/flutter build web --release
   ```

## Активация напоминаний (web-push)

Инфраструктура пушей уже рабочая: включение в приложении (Настройки → уведомления)
запрашивает разрешение и подписывает устройство, service worker
(`web/push/muslingo_push_sw.js`) показывает уведомление и открывает урок по клику,
кнопка «Отправить тест прямо сейчас» проверяет доставку мгновенно.

Чтобы приходили **ежедневные** напоминания, эндпоинт `/api/cron/reminders` нужно
вызывать **каждые 15 минут** (он сам выберет тех, у кого сейчас их время). Эндпоинт
требует авторизацию. Любой из способов (без оплаты):

1. **GitHub Actions** (уже есть `.github/workflows/push-reminders.yml`, раз в 15 мин
   через OIDC). После подключения репозитория к GitHub задай env
   `GITHUB_CRON_REPO` = `owner/repo` твоего репозитория (по умолчанию стоит
   плейсхолдер) — иначе OIDC-проверка не пройдёт.
2. **Внешний бесплатный cron** (например cron-job.org): job раз в 15 минут,
   URL `https://muslingo-mobile.vercel.app/api/cron/reminders`, заголовок
   `Authorization: Bearer <значение CRON_SECRET>`. Работает без GitHub.
3. **Vercel Cron** — только на плане Pro (Hobby ограничен раз в сутки). При Pro
   добавь в `vercel.json` блок `"crons": [{ "path": "/api/cron/reminders",
   "schedule": "*/15 * * * *" }]` — Vercel сам добавит `Authorization: Bearer
   CRON_SECRET`, если переменная задана.

Проверить вручную:

```bash
curl -H "Authorization: Bearer <CRON_SECRET>" https://muslingo-mobile.vercel.app/api/cron/reminders
```

Ответ вида `{"checked":N,"due":M,"sent":K,...}` подтверждает работу.

## Курс таджвида

Таджвид входит в основной learning path как самостоятельный production-курс из
36 уроков. Контент разделён на махраджи, сифаты, правила нун/мим, мадд и вакф;
каждый урок содержит аудирование, проверку понимания и запись произношения.

Автоматическая оценка голоса является образовательной и не должна описываться
как заключение квалифицированного преподавателя. Перед расширением курса и
публикацией спорных деталей контент нужно передавать на исламскую и языковую
проверку через предусмотренный CMS review workflow.
