# Канонические данные и справочники для Muslingo

## Вывод

Проверено **57 отдельных источников и артефактов** по шести направлениям: текст/переводы/тафсир Корана, хадисы и оценки достоверности, кораническая морфология и лексика, хронология сиры, дуа/азкары, аудио и тайминги. В реестр не копировались тексты корпусов, переводы, хадисы, тафсиры или аудиозаписи.

Для production-версии Muslingo нельзя собирать один «исламский датасет» из всего найденного. Правильная модель — **реестр ресурсов с отдельной лицензией, версией и происхождением каждого слоя**. Лицензия кода API или CMS почти никогда не распространяется автоматически на размещенные в нем переводы, тафсиры и записи чтецов.

Наиболее надежный стартовый стек:

1. **Арабский текст Корана:** Tanzil 1.1 как локальная неизменяемая база с обязательной атрибуцией; KFGQPC Hafs v6 — как государственный эталон для перекрестной проверки и потенциальная замена после письменного подтверждения коммерческих/offline/RAG-прав.
2. **Переводы и тафсир:** Quran Foundation Content API/Content Sync и QuranEnc, но только после выбора конкретных editions и фиксации прав на каждый ресурс. KFGQPC Tafsir al-Muyassar — приоритетный официальный партнерский источник.
3. **Морфология:** Quranic Arabic Corpus v0.4 с соблюдением GPL и специальных условий; QuranMorph/Birzeit — независимый второй анализатор после получения оригинального license-файла.
4. **Хадисы:** HadeethEnc для многоязычных проверенных объяснений, Sunnah.com и Dorar для локаторов/оценок и перекрестной проверки. Никакого scraping.
5. **Сира:** собственная хронология Muslingo, составленная редакцией по лицензированным первичным/академическим изданиям и проверяемая через Dorar Historical Encyclopedia. Готового одновременно открытого, канонического и юридически чистого корпуса не найдено.
6. **Дуа/азкары:** оригинальный структурированный каталог Muslingo с ссылками на Коран/хадисы; точный цифровой текст Hisn al-Muslim лицензировать у правообладателя или собирать заново из разрешенных первичных источников.
7. **Аудио:** Quran Foundation для пользовательского воспроизведения и синхронизации; quran-align CC BY 4.0 как открытый слой таймингов. Записи EveryAyah, QuranicAudio и значительная часть исследовательских аудиодатасетов не имеют достаточно чистой цепочки коммерческих и ML-прав.

## Критические юридические различия

### Можно интегрировать при соблюдении опубликованных условий

- **Tanzil Quran Text 1.1:** CC BY 3.0, но текст разрешено распространять только без изменений; обязательны источник, ссылка и notice ([Text License](https://tanzil.net/docs/text_license)).
- **quran-align timings:** сами JSON-тайминги — CC BY 4.0, код — MIT. Эта лицензия не дает права на связанное аудио ([README](https://github.com/cpfair/quran-align/blob/master/README.md)).
- **Quranic Arabic Corpus 0.4:** GPL плюс требования неизменности файла, ссылки и сохранения notice ([download/terms](https://corpus.quran.com/download/)). Для распространения производной базы необходим отдельный compliance-review.
- **Quran Foundation:** коммерческое или freemium-приложение допустимо, если контент только часть пользовательского опыта, сырые данные не продаются и не распространяются отдельно, а source-specific terms соблюдены. Обычный кэш ограничен одной неделей; Content Sync требует обновляться минимум раз в семь дней. ML-модели и биометрические идентификаторы из QF Content запрещены без письменного согласия ([Developer Terms, 26 August 2026](https://api-docs.quran.com/legal/developer-terms/)).
- **QuranEnc/HadeethEnc:** разрешают неизмененное переиздание с указанием издателя, источника, номера версии, transcript metadata и обязательным обновлением. Коммерческие, embedding и генеративные права прямо не названы, поэтому для Muslingo нужно письменное подтверждение ([QuranEnc API and terms](https://quranenc.com/en/home/api), [HadeethEnc terms](https://hadeethenc.com/en/home)).

### Только через API, договор или письменное разрешение

- **KFGQPC:** Developer Platform явно предлагает Quran/Tafsir/Gharib datasets для приложений и исследований, но не показывает отдельную открытую лицензию для монетизированного offline-продукта или AI-индекса. Это лучший кандидат на официальное партнерство, а не источник для молчаливого копирования ([platform](https://qurancomplex.gov.sa/en/techquran/dev/)).
- **LPMQ Kemenag:** доступ к индонезийскому стандартному Mushaf, переводу 2019 и тафсирам выдается после регистрации, официального письма и активации токена ([API access](https://quran-api.lpmqkemenag.id/)).
- **Sunnah.com:** scraping и массовое воспроизведение запрещены; API key выдается по запросу, offline dump пока не предоставляется ([about](https://sunnah.com/about), [developers](https://sunnah.com/developers)).
- **Dorar:** официальный JSON search API предназначен для показа результатов на сайтах, но массовое хранение, коммерческое распространение и ML не разрешены явно ([API](https://dorar.net/article/389)).
- **IslamHouse:** собственные материалы Rabwah office могут использоваться коммерчески без изменения и с атрибуцией; для материалов сторонних издателей нужно отдельное согласование. Старая инструкция API публиковала лимит 5000 запросов в час на ключ; текущая документация переехала в Postman ([current API docs](https://developers.islamhouse.com/), [archived API guide](https://api2.islamhouse.com/ar/how-to-use/), [rights FAQ](https://d1.islamhouse.com/html/faq.htm)). Перед интеграцией лимит следует подтвердить у IslamHouse.

### Не использовать в production до устранения конфликта прав

- **Tanzil translations:** только non-commercial без отдельного разрешения переводчика/издателя ([terms](https://tanzil.net/trans/)).
- **QuranicAudio:** только бесплатное личное использование; коммерческое использование запрещено ([about](https://quranicaudio.com/about)).
- **EveryAyah audio:** нет общей лицензии на записи. Наличие публичных файлов и зеркал не превращает записи чтецов в public domain.
- **Tarteel AI EveryAyah dataset:** карточка одновременно указывает MIT в metadata и CC BY 4.0 в тексте, а цепочка прав исходных EveryAyah recordings не доказана ([dataset card](https://huggingface.co/datasets/tarteel-ai/everyayah)).
- **AQQD v1.0:** CC0 на упаковку датасета не обязательно очищает права исполнителей и производителей записей, собранных с сайтов и YouTube ([DOI](https://doi.org/10.7910/DVN/A8GM5Y)).
- **Seera Events CC BY dataset:** производный набор ссылается на Dorar, где стоит all-rights-reserved. Его собственная CC BY декларация не доказывает право на исходные тексты ([dataset](https://huggingface.co/datasets/mustknowislam/seera_events)).
- **Open Hadith Data / fawazahmed0:** открытая лицензия структуры или репозитория не очищает авторские права современных переводов Sunnah.com и других upstream editions.

## Архитектура source-grounded AI

### 1. Реестр ресурсов

Каждая запись контента должна ссылаться не просто на `source_name`, а на неизменяемый ресурс:

```text
resource_id
publisher
work_title
edition_or_api_resource_id
language
content_type
license_id
license_snapshot_url
commercial_allowed
offline_allowed
embedding_allowed
generative_derivative_allowed
required_attribution
source_version
retrieved_at
checksum
next_sync_due_at
reviewer
scholarly_scope
```

Если любое из `commercial_allowed`, `offline_allowed` или `embedding_allowed` неизвестно, ingestion в production индекс должен автоматически блокироваться.

### 2. Раздельные хранилища

- **Immutable Quran store:** точный арабский текст, контрольные суммы и сравнение Tanzil/KFGQPC.
- **Licensed interpretation store:** переводы и тафсиры по отдельным resource IDs; нельзя смешивать предложения разных переводов в один «перевод AI».
- **Hadith evidence store:** collection, book, chapter, hadith locator, Arabic edition, translation edition, narrator, grader, grading text, grading authority и URL. Пустая grade означает «нет указанной оценки», а не «слабый» и не «достоверный».
- **Seerah claims store:** событие, диапазон дат, место, источники, уровень уверенности, разногласия, редактор и дата проверки.
- **Dua store:** арабский текст из разрешенного источника, перевод конкретной edition, контекст произнесения, Quran/hadith evidence, grading и reviewer.
- **Audio rights store:** reciter, riwayah, recording owner/publisher, master source, streaming/offline/training permissions, territory, expiry, checksum и timing source.

### 3. Правила ответа AI Coach

1. По религиозным вопросам retrieval выполняется только по allowlisted ресурсам.
2. Ответ отделяет Quran text, translation, tafsir, hadith и редакционное объяснение визуально и в metadata.
3. Цитата открывает конкретную суру/аят, хадис/edition или событие/источник, а не домашнюю страницу.
4. Модель не назначает собственную grade хадиса и не объединяет оценки разных ученых в одну.
5. Для разногласий показывается несколько именованных позиций; AI не объявляет одну «единственно правильной» без заданной редакционной традиции.
6. Коранический арабский текст никогда не проходит через автоматический перевод, исправление или генеративное перефразирование.
7. Для QF Content embedding/training остается выключенным до письменного согласия Quran Foundation.
8. Каждый ответ хранит `retrieval_receipt`: resource IDs, версии, фрагменты/локаторы, время запроса и модель ответа.

## Пробелы, которые нельзя закрыть простым парсингом

### Русский и казахский набор переводов

QuranEnc перечисляет несколько русских и казахский перевод Халифы Алтая, но production-лицензии, права на offline bundle и право строить embeddings нужно подтвердить по каждой edition. Нужен отдельный трехъязычный license pack: Arabic source, Russian translation, Kazakh translation, reviewers и update channel.

### Полный тафсир с правами на RAG

Quran Foundation и QUL дают технический доступ к нескольким тафсирам, но доступность ресурса не равна праву строить локальный векторный индекс и генерировать производные объяснения. Muslingo нужен прямой договор минимум на один краткий и один расширенный тафсир.

### Хадисная нормализация

Нет одного открытого набора, который одновременно имеет проверенный арабский текст, юридически чистые RU/KZ/EN translations, unified numbering, полный набор grader-attributed grades и стабильное versioning. Нужен собственный crosswalk между HadeethEnc, Sunnah.com, Dorar и печатной edition, а не копия случайного GitHub JSON.

### Каноническая сира

Хронология содержит спорные даты и разный статус сообщений. Нужна оригинальная Muslingo timeline с полями `date_range`, `confidence`, `evidence_type`, `school/tradition`, `disagreement_note`. Готовые визуальные таймлайны подходят для сравнения, но не как безусловный source of truth.

### Аудиоправа и произношение

Для проверки произношения требуются два разных типа данных:

- лицензированные профессиональные эталонные записи и точные тайминги;
- добровольно собранные learner recordings с явным consent на хранение, разметку и model training.

Публичная запись известного чтеца не должна использоваться для voice cloning, speaker identification или обучения коммерческой модели без отдельного разрешения. Тайминг аята или слова также не является доказательством правильности махраджа, мадда или гунны.

## План интеграции

### P0 — до нового массового импорта

1. Создать машинно-проверяемый license gate по схеме выше.
2. Направить KFGQPC запрос на Hafs v6, Tafsir al-Muyassar, Gharib и Tajwid: commercial web/iOS/Android, offline redistribution, caching, embeddings/RAG, generated summaries, RU/KZ localization и attribution wording.
3. Зарегистрировать Muslingo в Quran Foundation Developer Console; согласовать AI use и Connected Apps review.
4. Получить от QuranEnc/HadeethEnc письменное подтверждение freemium/offline/embedding use для конкретных keys/versions.
5. Запросить Sunnah.com API key и отдельные условия для production retrieval; запросить у Dorar партнерский доступ.
6. Запретить в ingestion pipeline источники со статусом `unclear`, `non-commercial`, `upstream-conflict` или `no-ml`.

### P1 — надежное ядро

1. Подключить Tanzil 1.1 как неизменяемый Arabic Quran store и ежедневную проверку updates/checksum.
2. Реализовать Quran Foundation Content Sync минимум раз в семь дней для разрешенных layouts/translations/tafsirs/audio.
3. Добавить QAC morphology v0.4 в отдельный GPL-compatible service; сравнить выборочно с QuranMorph.
4. Собрать hadith crosswalk и запретить отображение grade без имени grader/source.
5. Создать оригинальные seerah и dua schemas, заполнение которых проходит scholarly/content/license review.

### P2 — аудио и AI

1. Лицензировать конкретные recordings, не «сайт с аудио» целиком.
2. Использовать QF timings и quran-align как независимые слои; проводить автоматическую проверку monotonicity, coverage и verse boundaries.
3. Собирать learner corpus только по отдельному informed consent, с удалением, сроком хранения и запретом secondary use по умолчанию.
4. Оценивать pronunciation model на отдельном наборе с размеченными специалистами ошибками; обычные записи правильных чтецов не дают negative examples.

## Критерий готовности источника

Источник попадает в production allowlist только когда одновременно существуют:

- точный владелец и edition/resource ID;
- сохраненная копия условий и дата проверки;
- явные commercial, offline, embedding и derivative-use статусы;
- обязательная attribution строка;
- механизм version/update/correction;
- проверка полноты и контрольной суммы;
- назначенный исламский и языковой reviewer;
- тест удаления/отзыва ресурса из индекса и клиентских offline-копий.

Полный построчный реестр с 57 артефактами находится в `canonical-data-source-expansion-2026-09-11.csv`.
