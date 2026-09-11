# Muslingo: growth, positioning и switching strategy

## Резюме

Muslingo не выиграет рынок обещанием «все исламские функции в одном приложении». Такое поле уже занято крупными супераппами, а попытка повторить их ширину размоет главное преимущество продукта. Реальная возможность находится между четырьмя отдельными категориями: ежедневная привычка чтения, распознавание ошибок при чтении, структурированный учебный путь и человеческая проверка.

Рекомендуемая позиция Muslingo:

> **Muslingo каждый день решает, что тебе учить и повторять, слушает твою практику и объясняет следующий шаг.**

Это обещание должно доказываться внутри первых минут, а не сравнительной рекламой. Пользователь проходит короткую диагностику без регистрации, получает три конкретных наблюдения, первый персональный урок и план на семь дней. Регистрация нужна только для сохранения и синхронизации результата.

Главный стратегический вывод: **не переносить человека из одного приложения насильно, а сохранить непрерывность его учебного пути**. Самый сильный легальный технический маршрут для части данных дает Quran Foundation Connected Apps: после одобрения приложения OAuth2/OIDC может обеспечить общую учетную запись и синхронизацию поддерживаемых закладок, заметок, целей, reading sessions, preferences и streaks.[12][13] Данные из других приложений следует принимать только через официальный API, документированный экспорт пользователя или ручную самодиагностику.

## Метод

Исследование выполнено как срез на 11 сентября 2026 года.

1. Изучены 30 продуктов в шести группах: AI Quran/Hifz, Quran habit/readers, tajwid и Quranic Arabic, исламские академии, исламские супераппы и общие EdTech-бенчмарки.
2. Приоритет источников: официальные сайты, help centers, App Store/Google Play, privacy/terms и официальная документация.
3. Для каждого продукта проверялись app-store positioning, onboarding, referrals, sharing, streak, streak repair, challenges, import/export и teacher/community distribution.
4. В CSV каждое наблюдение начинается с `confirmed`, `inference` или `not_found`.
5. `not_found` означает, что механика не найдена в просмотренных официальных источниках. Это не доказательство, что функции нет в конкретной версии, стране или экспериментальной группе.
6. Учебные тексты, упражнения, аудио, изображения и формулировки конкурентов не копировались.

Полная матрица находится в `competitive-growth-switching-2026-09-11.csv`.

## Ограничения

- App Store и Google Play могут показывать разные описания, цены, рейтинги и функции по странам и платформам.
- Некоторые функции раскатываются как A/B-тесты и не документируются публично.
- Официальная маркетинговая формулировка подтверждает заявление компании, но не независимую эффективность продукта.
- Отсутствие публичного описания импорта, referral или streak repair не доказывает отсутствие функции внутри приложения.
- Старые официальные страницы использовались только там, где свежего описания не найдено. Такие строки помечены ограничением.
- Интеграция Quran Foundation требует одобрения, соблюдения актуальных условий и запрашивания минимальных OAuth scopes. Она не является автоматически доступным импортом всех данных.

## Карта рынка

### 1. AI Quran и Hifz

Tarteel занимает самое четкое обещание: «Memorize, Recite, Fix Mistakes». Его рост строится не только на распознавании, но и на целях, истории ошибок, тестах слабых мест, streak, группах и лидербордах.[1][2] Это делает Tarteel сильным соперником в сценарии самостоятельного хифза.

HIFZ и Sadr занимают методическую нишу Sabaq, Sabqi и Manzil. HIFZ снижает трение гостевым режимом и локальным прогрессом, Sadr усиливает предложение бесплатностью и отсутствием рекламы.[5][6] Mualim и TajweedMate полезны как пример осторожной границы: автоматическая система не должна изображать квалифицированного преподавателя.

**Вывод для Muslingo:** нельзя обещать «лучшее распознавание» без сравнительного набора реальной речи учеников. Можно доказуемо быть полезнее в следующем шаге: что ошибка означает, какой фрагмент повторить, когда вернуться к нему и когда нужна проверка учителя.

### 2. Привычка чтения

Quranly владеет простым jobs-to-be-done: сделать чтение Корана ежедневной привычкой. Цели по времени, недельный трекер, streak и приватный круг принятых друзей создают понятный цикл возвращения.[3][4]

**Вывод для Muslingo:** не атаковать привычку чтения. Предложить продолжение: «Ты уже регулярно читаешь. Теперь преврати чтение в понимание, точное воспроизведение и долгосрочную память».

### 3. Исламские супераппы

Muslim Pro объединяет Today, prayer tracking, Quran, Academy, media, Ummah, daily inspiration, sharing, quests и rewards.[9][10][11] Sajda и Athan также конкурируют шириной ежедневной исламской экосистемы. Их преимущество в частоте утилитарного использования и большом количестве входов, но не обязательно в глубине персонального учебного маршрута.

**Вывод для Muslingo:** не копировать prayer times, qibla, ленту и общую библиотеку как главный продукт. Muslingo должен открываться на одном решении: «Сегодня тебе нужны эти шесть минут по этой причине».

### 4. Tajwid и Quranic Arabic

Learn Quran Tajwid выигрывает доверием через scholar-certified positioning, широкий уровень от алфавита до продвинутого таджвида и placement test.[14] AlifBee выигрывает ясной уровневой структурой и Virtual School. Quranic и Arabic Unlocked делают изучение языка легче и игровее, но не объединяют весь путь чтение → смысл → речь → память → повторение.

**Вывод для Muslingo:** сильный wedge не «еще один курс арабского», а единый профиль навыков. Ошибка в букве, слове, значении и аяте должна менять следующее ежедневное задание.

### 5. Академии и учителя

Arabic101, AMAU, SeekersGuidance, Understand Al Quran и Quran Revolution показывают, что доверие и дистрибуция возникают через преподавателей, понятные программы, отчеты, наставничество и контролируемую коммуникацию.[18][19][20][21]

AMAU также документирует прямую referral-механику: пользователь получает 30 бесплатных дней после первой оплаты приглашенного человека.[17] Для Muslingo приемлема награда доступом или teacher-review credit, но не обещание религиозной награды и не продажа публичного статуса.

### 6. Общий EdTech

Duolingo связывает streak с Friend Streaks, cheers, weekly Friends Quests и семейным приглашением. По его официальным данным, наличие друзей и shared streak коррелирует с более высокой вероятностью продолжать обучение, однако это продуктовая статистика самой компании, а не причинная гарантия для Muslingo.[23]

Busuu использует более мягкую модель: два еженедельных streak shields можно заработать уроком или review, а Premium Plus дает дополнительный repair.[25] Quizlet и Khan Academy показывают, как teacher distribution становится каналом: классы, задания, уведомления, отчеты и экспорт результатов.[27][30] Anki показывает эталон пользовательской переносимости через документированные форматы импорта и экспорта.[28]

## Что действительно заставляет перейти

Пользователь редко меняет образовательное приложение из-за длинного списка функций. Переход происходит, когда новый продукт быстрее решает незакрытую задачу без потери уже вложенного труда.

| Исходная ситуация | Незакрытая задача | Доказательство Muslingo в продукте |
|---|---|---|
| Регулярно читает в Quranly или reader | Не знает, что именно улучшать | Диагностика показывает 3 конкретных слабых навыка и назначает первый урок |
| Учит в Tarteel/Sadr/HIFZ | Видит ошибки, но не получает полного объяснения и курса | Ошибка превращается в короткий lesson loop и повторение по сроку |
| Изучает Arabic/Quranic vocabulary | Не связывает язык с конкретным чтением и аятами | Один skill graph связывает букву, слово, значение, аят и удержание |
| Смотрит академические видео | Понимает пассивно, но не применяет | После объяснения следует retrieval, transfer и delayed review |
| Учится с преподавателем | Нет ежедневной структуры между занятиями | Учитель назначает задания и получает только согласованные результаты |
| Боится потерять прогресс | Переход кажется началом с нуля | Quran Foundation continuity, официальный импорт или быстрый recognition placement |

## Этичный switching flow

### Шаг 1. Вход без сравнения брендов

Первый экран спрашивает не «из какого приложения ты пришел», а:

- что уже умеешь;
- какие суры знаешь;
- читаешь ли арабский текст;
- хочешь читать, понимать, улучшать произношение или запоминать;
- сколько минут реально готов заниматься.

Выбор текущего приложения может быть необязательным аналитическим вопросом после получения ценности. Он не должен менять оценку пользователя или использоваться для унизительного сравнения.

### Шаг 2. Трехминутная recognition diagnostic

Диагностика должна позволять подтвердить уже имеющиеся навыки и пропустить очевидные основы, но не выдавать итог по одному вопросу. Результат:

1. «Уверенно».
2. «Нужно проверить еще раз».
3. «Следующая лучшая тренировка».

### Шаг 3. Один полноценный урок

До регистрации пользователь проходит полный цикл: слушает образец, отвечает, произносит, видит ограниченную и честную оценку, повторяет проблемный фрагмент и получает назначение следующего review.

### Шаг 4. Карта первых семи дней

Вместо общего paywall:

> «Мы сохраним твою текущую точку: 2 новых навыка, 4 повторения и 1 проверка произношения на ближайшие семь дней».

Это первое доказательство персонального маршрута.

### Шаг 5. Безопасная непрерывность

Разрешенные пути:

1. Quran Foundation OAuth2/OIDC после одобрения Connected Apps, с минимальными scopes и экраном предварительного просмотра.[12][13]
2. Официальный экспорт, который пользователь сам получил из другого продукта.
3. Ручной выбор известных сур, последнего аята и целей.
4. Быстрая диагностика, восстанавливающая уровень без копирования данных.

Запрещенные пути:

- чтение private storage другого приложения;
- запрос чужого пароля или токена;
- scraping закрытого аккаунта;
- импорт чужого или нелицензированного учебного контента;
- начисление XP за импортированные заявления без проверки;
- использование логотипа конкурента или фразы «официальный перенос» без разрешения;
- обещание сохранить все данные, если поддерживается только часть.

### Шаг 6. Прозрачная регистрация

После первого результата:

- «Продолжить без аккаунта»;
- Apple/Google/phone;
- объяснение, что именно синхронизируется;
- возможность удалить импорт, голос и аккаунт;
- отсутствие обязательной публичной лиги.

## Стратегические движения

### Движение 1. Владеть ежедневным решением

Главный экран и коммуникация должны отвечать на один вопрос: **что мне учить сегодня и почему именно это**.

Минимальный ежедневный цикл:

- 2 новых элемента;
- 3 review из Memory Engine;
- 1 pronunciation attempt после обязательного образца;
- 1 вопрос на смысл;
- конкретное следующее повторение.

Это объединяет разрозненные преимущества конкурентов в один учебный маршрут, не копируя их контент.

### Движение 2. Доказывать персонализацию до регистрации

Growth loop начинается с shareable diagnostic, а не с referral-кода:

1. Пользователь делится ссылкой «Проверь свой уровень чтения за 3 минуты».
2. Друг получает полноценный первый результат без аккаунта.
3. Делится не религиозным статусом, а нейтральным достижением: завершен учебный шаг или составлен план.
4. Отправитель получает не XP за веру, а доступ к дополнительному review или teacher credit после реального завершения первого урока другом.

### Движение 3. Частная взаимная ответственность

Первая социальная версия должна быть приватной:

- до пяти подтвержденных близких людей;
- общий learning streak только по факту учебной активности;
- мягкий nudge без раскрытия ошибки, записи голоса или содержания вопроса;
- opt-out из рейтингов;
- отдельные правила и parental control для несовершеннолетних.

Модель ближе к принятому кругу Quranly и Friend Streak, чем к открытой религиозной ленте.[3][23]

### Движение 4. Милосердное восстановление streak

Streak не должен становиться платным наказанием. Рекомендуемая логика:

- один grace day после стабильной недели;
- восстановление через короткое повторение слабого материала;
- болезнь, поездка и отпуск переводят цель в maintenance mode;
- интерфейс прямо говорит, что знание не исчезло вместе со streak;
- восстановление не начисляет бонусный XP задним числом.

Busuu показывает рабочий паттерн заработанных shields, Tarteel позволяет учитывать off-platform session, а Duolingo использует Freeze.[2][24][25] Muslingo должен сделать recovery образовательным и спокойным.

### Движение 5. Teacher и mosque distribution

Учительский слой важнее публичной социальной сети:

- код группы или invite link;
- учебные назначения;
- due reviews и recurring errors;
- согласие на передачу конкретной аудиозаписи;
- rubric-based feedback;
- срок хранения и удаление аудио;
- teacher role, audit log и отзыв доступа;
- экспорт сводки без лишних персональных данных.

Пилоты лучше начинать с 3–5 преподавателей и 2–3 небольших групп, измеряя не регистрации, а возврат к назначенному повторению и снижение повторяющейся ошибки.

### Движение 6. Quran Foundation continuity

Нужно отдельно провести партнерский и технический discovery:

1. Подать Muslingo в Connected Apps.
2. Проверить соответствие Vision Aligned/Transformational требованиям.
3. Спроектировать Authorization Code with PKCE.
4. Запрашивать только `openid` и реально необходимые scopes.
5. Показать пользователю preview синхронизируемых объектов.
6. Разделить «синхронизировано из Quran.com» и «оценено Muslingo».
7. Не превращать закладку или streak в подтвержденное mastery.

Это стратегически сильнее сомнительного «импорта из всех приложений»: путь проверяемый, добровольный и поддерживает экосистему вместо закрытого захвата данных.[12][13]

## Позиционирование

### Основная формула

> **Персональный путь чтения, понимания и запоминания Корана. Каждый день Muslingo выбирает следующий урок, слушает практику и возвращает к слабым местам.**

### Короткая app-store формула

> **Learn, recite and remember Quran with your daily AI learning path.**

### Три доказательства рядом с обещанием

1. Диагностика до регистрации.
2. Ежедневный план из новых и повторяемых навыков.
3. Честная проверка речи с confidence и возможностью teacher review.

### Чего нельзя писать сейчас

- «Самое точное распознавание Корана» без независимого benchmark.
- «Полностью исправляет таджвид» без teacher-labeled validation.
- «Лучше Tarteel/Sajda/Muslim Pro» как общий непроверяемый тезис.
- «Перенесем весь прогресс» без официального API или поддержанного файла.
- «AI-устаз» или обещание заменить квалифицированного преподавателя.
- «Заработай награду за приглашение» в формулировке, смешивающей подписку и религиозную награду.

## Конкурентные переходы без ложных сравнений

| Аудитория | Допустимая формулировка | Продуктовый маршрут |
|---|---|---|
| Пользователь Quran reader | «Преврати чтение в персональный урок» | Последний аят → 1 вопрос на смысл → 1 pronunciation step → review |
| Пользователь habit app | «Сохрани привычку и добавь измеримое обучение» | Выбрать обычное время → импортировать цель вручную → 7-day plan |
| Пользователь Hifz app | «Свяжи запоминание с пониманием и причинами ошибок» | Известные суры → diagnostic recall → weak segments |
| Ученик академии | «Практикуйся между занятиями по плану преподавателя» | Group invite → assignment → consented submission |
| Новый пользователь | «Узнай, с чего начать, за три минуты» | Goal → diagnostic → first lesson → account after result |

На публичных страницах лучше сравнивать подходы и задачи, а не использовать чужие товарные знаки в заголовках кампаний без юридической проверки.

## План на 90 дней

### Дни 0–30: доказательство первого результата

- Свести onboarding к goal → diagnostic → first lesson → result → optional account.
- Сформировать skill graph для букв, чтения, слов, смысла, аятов и pronunciation attempts.
- Добавить seven-day plan после диагностики.
- Ввести confidence/abstain для автоматической проверки речи.
- Провести discovery и заявку Quran Foundation Connected Apps.

**Критерии выхода:** не менее 70% начавших диагностику доходят до результата; не менее 50% результата запускают первый персональный урок; ни один uncertain speech result не показывается как уверенная ошибка.

### Дни 31–60: удержание и безопасный переход

- Memory Engine назначает review по элементам, а не по завершенным экранам.
- Maintenance mode и recovery lesson для streak.
- Preview для ручного переноса известных сур, последнего аята и целей.
- Shareable diagnostic link и нейтральная карточка завершения.
- Приватные accountability invites без публичного religious leaderboard.

**Критерии выхода:** рост возврата к назначенному review на D7; импорт не начисляет mastery/XP без проверки; пользователь может удалить перенесенные данные и голос.

### Дни 61–90: teacher distribution

- Teacher role и малые группы.
- Assignments, due reviews и consented audio review.
- Rubric, audit log, revoke access и retention controls.
- Пилоты с преподавателями RU/KZ-аудитории.
- Referral reward только после activated learner и только как доступ/teacher credit.

**Критерии выхода:** учителя регулярно возвращают rubric feedback; повторяемые ошибки снижаются после review; доступ к аудио проверен по ролям; нет открытого показа частной религиозной активности.

## Метрики

### North Star

**Количество пользователей, которые завершили персональный урок и вернулись к следующему назначенному повторению.**

### Growth

- diagnostic start → result;
- result → first personalized lesson;
- account creation after result;
- invite opened → diagnostic completed;
- diagnostic completed → D7 assigned-review return;
- approved continuity/import completed without support incident.

### Learning quality

- delayed recall at 7/30/90 days;
- recurrence rate по типу ошибки;
- доля uncertain speech attempts;
- agreement автоматической оценки с teacher labels;
- доля рекомендаций, которые пользователь завершил;
- время учителя на один review.

### Trust guardrails

- удаления голоса и аккаунта выполнены в SLA;
- ни одной утечки аудио между группами;
- opt-out из social/league доступен;
- claims на store/landing соответствуют текущей валидации;
- referral abuse и fake activation rate;
- жалобы на давление streak/paywall.

## Решение

Следующий этап Muslingo должен быть не наращиванием случайных функций, а сборкой доказуемого перехода:

1. **Начать без аккаунта.**
2. **Показать реальный уровень и слабые места.**
3. **Дать полноценный персональный урок.**
4. **Назначить следующий review.**
5. **Сохранить путь через аккаунт, официальный sync или честный ручной перенос.**
6. **Добавить приватного человека, если автоматической уверенности недостаточно.**

Тогда пользователь понимает преимущество не из заявления «мы лучше», а из опыта: другое приложение показывает контент или ошибку, а Muslingo превращает его текущий уровень в конкретное ежедневное решение.

## Источники

1. Tarteel. [App Store positioning](https://apps.apple.com/us/app/tarteel-ai-quran-memorization/id1391009396). Accessed 2026-09-11.
2. Tarteel Help Center. [Groups and Leaderboards](https://support.tarteel.ai/en/articles/12414382-groups-and-leaderboards); [off-platform session and streak restoration](https://support.tarteel.ai/en/articles/12414408-how-to-add-an-off-platform-session); [Testing FAQs](https://support.tarteel.ai/en/articles/16557351-testing-faqs). Accessed 2026-09-11.
3. Quranly. [Official product page](https://www.quranly.app/). Accessed 2026-09-11.
4. Quranly. [Product feature overview](https://www.quranly.app/blog/quranly-everything-you-need-to-know); [App Store listing](https://apps.apple.com/us/app/quran-by-quranly/id1559233786). Accessed 2026-09-11.
5. HIFZ. [Help and support](https://gethifz.com/support). Updated 2026-06-13; accessed 2026-09-11.
6. Sadr. [Official product page](https://sadr.app/?lang=en); [support and sharing](https://sadr.app/support-us). Accessed 2026-09-11.
7. Naml. [Official product page](https://naml-app.com/en); [pricing and guest onboarding](https://naml-app.com/en/pricing). Accessed 2026-09-11.
8. Learn Quran Tajwid. [Google Play listing](https://play.google.com/store/apps/details?id=com.bi.learnquran). Accessed 2026-09-11.
9. Muslim Pro. [App Store listing](https://apps.apple.com/us/app/muslim-pro-quran-athan/id388389451). Accessed 2026-09-11.
10. Muslim Pro Help Center. [Updated app guide](https://support.muslimpro.com/hc/en-us/articles/49726715851545-Guide-to-the-Updated-and-Enhanced-App); [Community: Ummah Pro](https://support.muslimpro.com/help/en/articles/community-ummah-pro). Accessed 2026-09-11.
11. Muslim Pro Help Center. [Quest and Stars](https://support.muslimpro.com/help/en/articles/quest-and-stars); [Daily Inspiration sharing](https://support.muslimpro.com/help/en/articles/how-can-i-access-inspiration-daily-verse-du-a-and-quotes). Accessed 2026-09-11.
12. Quran Foundation. [Connected Apps](https://api-docs.quran.com/docs/connected-apps/); [mobile app authentication](https://api-docs.quran.com/docs/tutorials/oidc/mobile-apps/). Accessed 2026-09-11.
13. Quran Foundation. [User APIs](https://api-docs.quran.com/docs/category/user-related-apis-1.0.0/); [OAuth2 quickstart](https://api-docs.quran.com/docs/tutorials/oidc/user-apis-quickstart/). Accessed 2026-09-11.
14. AlifBee. [Official product page](https://www.alifbee.com/en); [placement test](https://help.alifbee.com/hc/en-us/articles/9421698273821--Placement-test). Accessed 2026-09-11.
15. Arabic101 Academy. [Courses](https://academy.arabic101.org/courses/); [teacher onboarding](https://arabic101.org/aca/getting-started/); [teacher workflow](https://arabic101.org/aca/faq-teaching/). Accessed 2026-09-11.
16. Arabic Unlocked. [Official product](https://arabicunlocked.com/); [Academy](https://arabicunlocked.com/academy/). Accessed 2026-09-11.
17. AMAU Help Center. [Refer and Win](https://helpdesk.amauacademy.com/articles/gift-sharing-and-family-use/refer-and-win/). Updated 2026-03-14; accessed 2026-09-11.
18. SeekersGuidance. [Academy](https://academy.seekersguidance.org/); [Islamic Scholars Fund and learning network](https://seekersguidance.org/islamic-scholars-fund/). Accessed 2026-09-11.
19. Understand Al Quran Academy. [Official site](https://understandquran.com/); [online madrasah](https://understandquran.com/online-madrasah/). Accessed 2026-09-11.
20. Quran Revolution. [Official product page](https://easierquran.com/). Accessed 2026-09-11.
21. Pillars. [Official positioning](https://www.thepillarsapp.com/); [privacy](https://thepillarsapp.com/privacy); [scope FAQ](https://thepillarsapp.com/faqs). Accessed 2026-09-11.
22. IslamicFinder. [Athan Community](https://www.islamicfinder.org/news/how-athan-is-changing-the-way-muslims-connect/); [privacy policy](https://www.islamicfinder.org/privacypolicy/). Accessed 2026-09-11.
23. Duolingo. [Social features](https://blog.duolingo.com/friends-social-features/). Accessed 2026-09-11.
24. Duolingo. [Habit and streak mechanics](https://blog.duolingo.com/putting-in-work-the-habit-of-language-learning/); [streak maintenance and Friends Quests](https://blog.duolingo.com/tips-for-maintaining-streak/). Accessed 2026-09-11.
25. Busuu Help Center. [Community exercise corrections](https://help.busuu.com/hc/fr/articles/16722928943377-Comment-envoyer-mes-exercices-%C3%A0-la-communaut%C3%A9); [streak shields and repair](https://help.busuu.com/hc/de/articles/16498048476305-Was-ist-ein-Schutzschild-und-wie-kann-ich-es-nutzen). Accessed 2026-09-11.
26. Memrise. [Streaks](https://memrise.zendesk.com/hc/en-us/articles/360015973598-What-are-Streaks-and-how-do-they-work). Accessed 2026-09-11.
27. Quizlet Help Center. [Accessing, sharing and exporting](https://help.quizlet.com/hc/en-us/sections/360005877232-Accessing-and-sharing); [teacher classes and progress](https://help.quizlet.com/hc/en-au/articles/360035357412-Adding-sets-to-a-class). Accessed 2026-09-11.
28. Anki Manual. [Importing](https://docs.ankiweb.net/importing/intro.html); [Exporting](https://docs.ankiweb.net/exporting.html). Accessed 2026-09-11.
29. LingQ. [Product and import](https://www.lingq.com/); [signup/referral field](https://www.lingq.com/en/accounts/new/); [schools](https://www.lingq.com/en/schools/). Accessed 2026-09-11.
30. Khan Academy Help Center. [Teacher reporting](https://support.khanacademy.org/hc/en-us/articles/360031129891-What-reporting-options-are-available-on-Khan-Academy-for-teachers-to-track-student-performance); [mastery system](https://support.khanacademy.org/hc/en-us/articles/115002552631-How-does-Khan-Academy-s-Mastery-system-work). Accessed 2026-09-11.
