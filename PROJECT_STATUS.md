# Muslingo — статус проекта и хендофф

**Обновлено:** 2026-08-10
**Прод (web/PWA + API):** https://muslingo-mobile.vercel.app
**Репозиторий:** github.com/baimukhanalan/musingo (⚠️ см. «Блокеры» — работа сессии закоммичена локально, но НЕ запушена)

Это приложение для изучения Корана, арабского и основ ислама по системе Duolingo:
путь уроков, интервальные повторения, стрик/XP/жизни, проверка произношения,
AI-коуч, Коран-ридер, Hafiz Mode, друзья, уведомления. Три языка интерфейса RU/KZ/EN.

---

## 1. TL;DR — текущее состояние

- **Web/PWA — полностью рабочее и задеплоено** на Vercel. Прод зелёный (`/api/health` 200).
- Пройден полный аудит безопасности/корректности; все Critical/High/Medium и большинство Low закрыты.
- **Премиум-редизайн** всех экранов применён (по прототипу из «Muslingo премиум айн»).
- **Локализация RU/KZ/EN** интерфейса работает (переключатель реальный, сохраняется).
- **Курс: 74 урока** (арабский алфавит 16, Коран 48, основы 10) — арабский сверен с каноном. **Джуз Амма (суры 78–114) покрыт полностью.**
- **Новые типы упражнений** Duolingo: сборка аята из слов и аудирование с выбором перевода.
- **AI-коуч (Groq)** построен и задеплоен; **ждёт `GROQ_API_KEY` в Vercel** (без него — умный локальный fallback).
- **Уведомления** Duolingo-стиля: rich + интерактивные кнопки + локализованный копирайт.
- **Не готово к сторам** физически: нужны твои аккаунты Google Play / Apple Developer, keystore, скриншоты (см. §6).

---

## 2. Архитектура

**Клиент** — Flutter (Provider, именованные маршруты в `lib/main.dart`).
- Состояние: `lib/services/app_state.dart` (хаб: юзер, прогресс, стрик, жизни, память/knowledge states, локаль, `tr()`).
- Экраны: `lib/screens/*` ; общие премиум-виджеты: `lib/widgets/` (`premium_background`, `premium_card`, `premium_button`, `stat_badge`, `language_pills`, `section_label`, `progress_ring`).
- Уроки (контент): `lib/services/lessons/{quran,arabic,rules}_lessons.dart` (собираются в `lib/services/lesson_data.dart`).
- Дизайн-система: `DESIGN_SPEC.md`.

**Бэкенд** — Node 20 ESM, serverless на Vercel. Единая точка входа `api/index.js` → маршруты `server/routes/*`, общие либы `server/lib/*`.
- БД: **Neon Postgres** через `@neondatabase/serverless` (`server/lib/db.js`, ленивая инициализация + аддитивные миграции).
- Аутентификация: JWT (jose, HS256), PBKDF2/scrypt для паролей.
- Ключевые маршруты: `auth-*`, `progress-complete`/`progress-sync`, `friends`, `leaderboard`, `speech-evaluate`, `push-*`, `cron-reminders`, **`coach`** (AI).

**Сборка/деплой:** `vercel.json` — Vercel сам ставит Flutter, гоняет тесты (`pnpm test:api && flutter test`) и собирает web (`flutter build web`). Деплой: `vercel deploy --prod`.

**Данные на пользователя:** таблица `muslingo_progress` (по `user_id`): JSON-документ (xp, streak, hearts, energy, completedLessons, knowledgeStates, hafizProgress, rewardHistory, счётчики), `weekly_xp`, `week_start`, `version` (оптимистическая блокировка). Гости — локально (SharedPreferences), с миграцией в аккаунт при регистрации.

---

## 3. Что сделано (по областям)

### Безопасность и аудит
- Полный аудит (36 находок) — `AUDIT_REPORT.md`. Закрыты все Critical/High/Medium и почти все Low.
- Аутентификация, rate-limit логина и регистрации, JWT (iss/aud/nbf), SSRF-allowlist пушей, IDOR-скоупинг по user_id, hardening заголовков/CSP.
- Cron напоминаний: OIDC/CRON_SECRET (constant-time), курсорная пагинация (без «хвоста»), чистка мёртвых подписок.
- FK-индексы, аддитивные миграции схемы, идемпотентность.

### Корректность геймплея
- C1: устранена потеря прогресса при ≥6 ошибках (кламп errors 0..5 клиент+сервер).
- Античит недельного лидерборда (дневной потолок вклада), reward-replay guard.
- Дневная цель сбрасывается в новый день; стрик-бонус ровно раз в день; регенерация жизней при resume.
- Шаффл вариантов ответа в рантайме; speak-шаги не блокируют (мягкий проход + «Пропустить»); подсказка не палит ответ.
- Согласование XP/learnedAyats клиент↔сервер.

### Контент / курс (74 урока)
- Арабский: полный алфавит a1–a16 (28 букв + танвин/шадда/мадд + чтение).
- Коран: Фатиха + **весь Джуз Амма, суры 78–114** (48 уроков), арабский **сверен построчно с каноном** `assets/data/quran-uthmani-tanzil.txt`.
- Последними добавлены суры 78–84 (Ан-Наба, Ан-Назиат, Абаса, Ат-Таквир, Аль-Инфитар, Аль-Мутаффифин, Аль-Иншикак) — 237 аятов, 11 уроков, длинные суры разбиты на две части, чтобы урок оставался длиной с обычную сессию — плюс 90 (Аль-Баляд) и 98 (Аль-Баййина). Арабский текст сгенерирован из ассета скриптом, а не набран руками.
- Основы: r1–r10 (столпы веры/ислама, азкары).
- **Качество вопросов по Duolingo:** правдоподобные дистракторы, cloze-пропуски, вопросы на логику/связки сур, интерливинг, прогрессия. Ответы проверены аудитом (~280+ вопросов, 0 ошибок).
- ⚠️ **Религиозный контент (переводы сур, фикх r8–r10) — ЧЕРНОВИК**, ждёт проверки твоим экспертом. Арабский текст канонический; переводы Кулиев-стиль. Черновой таджвид — за флагом `MUSLINGO_DRAFT_CONTENT` (в прод не выкатан).

### Типы упражнений
- Базовые: аудио-аят, текст, вопрос с вариантами, соединение пар, произношение (речь).
- **Новые:** `LessonStepType.wordOrder` — собрать аят, нажимая слова в правильном порядке (банк = `orderTokens` + `extraTokens`, перемешивается детерминированно и заведомо не в порядке ответа); `LessonStepType.listenChoice` — прослушать аят (или фразу через TTS) и выбрать перевод, арабский текст при этом не показывается.
- Гейт кнопки «Проверить» — `_BottomBar._gateOpen` в `lib/screens/lesson_screen.dart`: по одному условию готовности на тип шага. При добавлении нового типа надо дописать ветку туда, в `_stepTypeLabel`, `_checkLabel`, `_buildStepContent` и в `AppState._knowledgeKind`.
- Проверка новых шагов — рендер-тестами экрана урока (`test/lesson_new_steps_render_test.dart`): анализатор не поймает залоченную кнопку или непроходимый шаг.

### Премиум-редизайн UI
- Все экраны под прототип: онбординг, главная (Сегодня + путь + Memory Engine + аят дня), урок, Коран, AI Coach, Hafiz, профиль, paywall, логин, итог урока, друзья, настройки, стрик, достижения, карусель, установка, Академия, Основы.
- Таббар: Главная · Коран · Coach · Hafiz · Профиль («Основы» — раздел 1 на главной).
- Токены/тема/маскот совпадали с исходником — менялась вёрстка. Спека — `DESIGN_SPEC.md`.

### Локализация RU/KZ/EN
- `AppLocale{ru,kk,en}` + `AppState.tr(ru,kk,en)` + `setLocale` (сохраняется) + делегаты `flutter_localizations`.
- Пилюли RU/KZ/EN реально переключают язык всего UI (подтверждено визуально на главной EN и KZ).
- ⚠️ Локализован **интерфейс**; **религиозный контент остаётся RU** (перевод Корана на 3 языка — отдельная задача с экспертом).

### Уведомления (Duolingo-стиль)
- Мобилка (`flutter_local_notifications`): rich (BigText + иконка-кот), **интерактивные кнопки** «Начать урок»/«Позже» (Android + iOS categories + обработка нажатий), локализованный копирайт RU/KZ/EN (пулы: стрик под угрозой, празднование, повторение, возвращение, реплики кота).
- Web-push (PWA): service worker + VAPID + cron; копирайт в `server/lib/reminder-copy.js`.
- ⚠️ Интерактив реально виден только в нативной сборке (.apk/.ipa) — в web/тестах не проверить.

### AI-коуч (Groq)
- Серверный `POST /api/coach` (`server/routes/coach.js` + `server/lib/groq.js`): собирает контекст ученика (xp, стрик, точность, пройденное, слабые места, рекомендованный урок — у залогиненных из БД), зовёт **Groq llama-3.3-70b**, отвечает на языке пользователя, рекомендует следующий урок (action `startLesson`).
- Религиозная безопасность: фикх/фетвы → «спросить специалиста», без сектантства.
- **Ключ только из `process.env.GROQ_API_KEY`** (нигде не захардкожен). Без ключа → 503 → клиент откатывается на локальный движок `coach_service.dart`.
- Адаптивный подбор следующего урока усилён (слабые места + просроченные повторения + прогресс).

### Стор-подготовка
- `com.muslingo.app` на обеих платформах; иконки (adaptive Android + iOS AppIcon без alpha).
- iOS `PrivacyInfo.xcprivacy` (tracking=false), `ITSAppUsesNonExemptEncryption=false`.
- Android **Play App Signing** разведён: `android/app/build.gradle` читает `android/key.properties` (шаблон `android/key.properties.example`), откат на debug без файла. `key.properties`/`*.jks` в `.gitignore`.
- Политика конфиденциальности хостится на `/privacy`, ссылка в настройках.
- Документы: `STORE_SUBMISSION.md` (чеклист/статусы), `STORE_LISTING.md` (готовые тексты листинга RU), `PRIVACY_POLICY.md`, `DEPLOY.md`.

### CI
- `.github/workflows/android-apk.yml` — облачная сборка устанавливаемого (debug-signed) APK как артефакт + Release по тегу `v*`.
- `.github/workflows/push-reminders.yml` — cron веб-пушей (раз в 15 мин, OIDC).

---

## 4. Верификация

Каждый шаг проверялся: `flutter analyze` (чисто), **flutter-тесты** (97), **node-тесты** (138), `flutter build web`. Vercel гоняет те же тесты в `buildCommand` — «красная» сборка = упавший тест.

**Как визуально смотреть web-экраны** (клики по Flutter-canvas в превью вешают пейн; скриншоты/JS — ок):
1. Собрать web + поднять SPA-fallback сервер (обычный `http.server` не даёт deep-link — нужен фолбэк на `index.html`).
2. Подсеять гостя в localStorage: `localStorage['flutter.user'] = JSON.stringify(JSON.stringify(user))` (двойное json-кодирование — так хранит `shared_preferences_web`); язык — `localStorage['flutter.locale']=JSON.stringify("en")`.
3. Открывать экраны прямым хеш-маршрутом: `/#/premium`, `/#/login`, `/#/friends`, `/#/settings`, `/#/coach` и т.п. (маршруты — `lib/main.dart`). Вкладки внутри MainTabScreen (Коран/Hafiz/Профиль) прямым маршрутом не открыть.

---

## 5. Переменные окружения (Vercel)

Обязательные для полного бэкенда: `DATABASE_URL` (Neon), `JWT_SECRET`, `CRON_SECRET`,
`VAPID_PUBLIC_KEY`/`VAPID_PRIVATE_KEY`/`VAPID_SUBJECT`, `MUSLINGO_API_URL`, `MUSLINGO_SPEECH_API_URL`.
Опциональные: `MUSLINGO_APP_ORIGIN`, `MUSLINGO_JWT_*`, `GITHUB_CRON_REPO`.

**Новое / требует действия:**
- `GROQ_API_KEY` — **не задан**. Пока его нет, AI-коуч отдаёт 503 и клиент работает на локальном движке. Добавить в Vercel → Settings → Environment Variables (Production), затем передеплой.

Шаблон — `.env.example`.

---

## 6. Где остановились — блокеры, требующие ДЕЙСТВИЙ ВЛАДЕЛЬЦА

Всё, что можно было сделать без секретов/аккаунтов, — сделано и на проде. Осталось то, что физически требует тебя:

1. **Включить AI-коуч:** добавить `GROQ_API_KEY` в Vercel (Production) → передеплой. ⚠️ Ключ, вставленный в чат ранее, **перевыпустить** в Groq (он засветился). Ассистент не вписывает секретные ключи в конфиг — это твой шаг.
2. **Запушить код в GitHub:** вся работа закоммичена локально, но **не запушена** — в окружении ассистента нет GitHub-креды (keychain пуст, токена нет). Нужен `git push origin main` из твоего терминала (или `gh auth login`, тогда ассистент сможет пушить сам). Расхождение истории с `origin/main` (локально один коммит был схлопнут в другой) устранено: локальные коммиты переложены поверх `origin/main`, дерево не изменилось, **push пройдёт fast-forward без `--force`**. Старая история сохранена в ветке `backup/pre-align-main` — её можно удалить после успешного пуша.
3. **Android APK:** после пуша `.github/workflows/android-apk.yml` соберёт APK автоматически (Actions → артефакт `muslingo-apk`; или тег `v1.0.0` → Release со ссылкой). Локально APK не собрать — на машине нет Android SDK.
4. **iOS `.ipa`:** нельзя даже в облаке без **Apple Developer аккаунта ($99/год)** и сертификатов подписи (блокер C2). Также нужен полный Xcode (здесь только Command Line Tools).
5. **Android release keystore (для Play):** сгенерировать upload-keystore и заполнить `android/key.properties` (команда — в `android/key.properties.example`). Для сайдлоад-теста НЕ нужен (debug-подпись подойдёт).
6. **Аккаунты сторов:** Google Play Console ($25 разово), Apple Developer ($99/год); заполнить Data safety / App Privacy, возрастной рейтинг; скриншоты (снимаешь ты — список экранов/размеров в `STORE_LISTING.md`).
7. **Экспертное ревью религиозного контента:** переводы сур (Кулиев-стиль), фикх-уроки r8–r10, черновой таджвид — показать твоему специалисту перед финалом.

---

## 7. Дорожная карта (куда дальше)

**Ближайшее (как разблокируешь §6):**
- Добавить `GROQ_API_KEY` → ассистент передеплоит и проверит живой ответ AI-коуча.
- `git push` → собрать и раздать Android APK для теста на устройстве.
- Показать религиозный контент эксперту, внести правки.

**Продукт (следующие итерации):**
- **AI Learning Path** углубить: чтобы коуч не только советовал, но и динамически перестраивал путь/генерировал микро-упражнения под слабые места.
- **Локализация контента:** переводы сур и основ на KZ/EN (с экспертом) — сейчас только UI.
- **Больше контента:** Джуз Амма закрыт — дальше либо Джуз Табарак (суры 67–77), либо расширение основ/таджвида (после эксперта).
- **Ещё типы упражнений:** перетаскивание (сейчас сборка фразы — по нажатию), выбор аята на слух из нескольких аудио, письмо арабских букв.
- **Оплаты Muslingo+:** сейчас paywall визуальный, платежей нет — подключить (App Store/Play billing или иное).
- **Реальный трёхъязычный контент уведомлений** уже есть; можно добавить больше вариативности/сегментации.

**Тех-долг / отложенное (Low из аудита):**
- CSP `unsafe-inline` (ломает Flutter web bootstrap — отложено), сокращение TTL JWT.
- L9: вынести горячие скаляры прогресса из JSONB в колонки при росте нагрузки.
- Рефактор `lesson_data` уже сделан (per-course файлы); при росте — per-lesson.

---

## 8. Полезные команды

```bash
# Локальная проверка (как на Vercel)
pnpm run test:api
/Users/alanbaimukhan/dev/flutter/bin/flutter test
/Users/alanbaimukhan/dev/flutter/bin/flutter build web --release

# Деплой на прод
vercel deploy --prod

# Релизная сборка Android (когда будет keystore/CI)
flutter build appbundle --release \
  --dart-define=MUSLINGO_API_URL=https://muslingo-mobile.vercel.app \
  --dart-define=MUSLINGO_SPEECH_API_URL=https://muslingo-mobile.vercel.app
```

---

## 9. Ключевые файлы (карта)

| Область | Файлы |
|---|---|
| Состояние/логика | `lib/services/app_state.dart`, `lib/services/backend_service.dart` |
| Уроки (контент) | `lib/services/lessons/*_lessons.dart`, `lib/services/lesson_data.dart` |
| AI-коуч | `server/routes/coach.js`, `server/lib/groq.js`, `lib/services/coach_service.dart` |
| Прогресс/реестр | `server/routes/progress-complete.js` (Set `lessons`, `ayatRewards`, `lessonXp`), `server/lib/db.js` |
| Уведомления | `lib/services/notification_service_io.dart`, `lib/models/reminder_message.dart`, `server/routes/cron-reminders.js` |
| Локализация | `lib/utils/app_locale.dart`, `AppState.tr` |
| Дизайн | `DESIGN_SPEC.md`, `lib/widgets/*` |
| Сторы | `STORE_SUBMISSION.md`, `STORE_LISTING.md`, `android/app/build.gradle`, `ios/Runner/PrivacyInfo.xcprivacy` |
| Аудит | `AUDIT_REPORT.md` |
| CI/деплой | `.github/workflows/*`, `vercel.json`, `DEPLOY.md` |

**Инвариант:** любой новый урок → добавить его id в `server/routes/progress-complete.js` (`lessons` Set + `ayatRewards` для сур + `lessonXp`), иначе `400 unknown_lesson` и прогресс залогиненного не запишется. Тест `server_test/progress-registry.test.js` это стережёт.
