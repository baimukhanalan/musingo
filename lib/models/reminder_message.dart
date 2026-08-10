import '../utils/app_locale.dart';

class ReminderMessage {
  final String title;
  final String body;

  const ReminderMessage(this.title, this.body);
}

/// Персональные напоминания в духе Duolingo: тёплый, игривый тон с ноткой
/// характера маскота-кота, но с уважением к теме приложения. Мотивируем
/// только учебную привычку (стрик, ежедневные шесть минут), без давления
/// на веру или чувства вины.
///
/// Тексты локализованы на русский (по умолчанию), казахский и английский.
/// [buildReminders] подбирает уместные контексты по состоянию пользователя
/// и подставляет данные в плейсхолдеры `{name}`, `{streak}`, `{dueCount}`.
List<ReminderMessage> buildReminders({
  required String name,
  required int streak,
  int dueCount = 0,
  String? learningGoal,
  DateTime? now,
  AppLocale locale = AppLocale.ru,
}) {
  // Запоминаем язык последнего планирования, чтобы парный вечерний нудж
  // (buildStreakReminder, вызывается из планировщика уже без контекста экрана)
  // выводился на том же языке. buildReminders и планирование идут единой
  // парой в одном потоке, поэтому значение всегда актуально.
  _lastLocale = locale;

  final today = now ?? DateTime.now();
  // Ротация вариантов по дню года — детерминированно, но с ежедневной сменой.
  final rotation = today.difference(DateTime(today.year)).inDays;
  final pools = _poolsFor(locale);
  final fill = _fillFactory(
    name: name,
    streak: streak,
    dueCount: dueCount,
    locale: locale,
  );

  ReminderMessage pick(List<ReminderMessage> pool, int shift) {
    final raw = pool[(rotation + shift) % pool.length];
    return ReminderMessage(fill(raw.title), fill(raw.body));
  }

  final messages = <ReminderMessage>[];

  // Контекст стрика.
  if (streak <= 0) {
    // (d) Возвращение после паузы — тёплое приглашение начать заново.
    messages.add(pick(pools.returnAfterPause, 0));
  } else if (_isMilestone(streak)) {
    // (b) Празднование круглого стрика (3/7/30/100 дней).
    messages.add(pick(pools.streakCelebration, 0));
  } else {
    // (a) Стрик под угрозой — бережём серию.
    messages.add(pick(pools.streakAtRisk, 0));
  }

  // (c) Есть аяты на повторение.
  if (dueCount > 0) {
    messages.add(pick(pools.reviewDue, 0));
  }

  // (e) Обычные дневные напоминания.
  messages.add(pick(pools.dailyGeneral, 0));
  messages.add(pick(pools.dailyGeneral, 1));

  // (f) Реплики от лица кота — всегда по имени.
  messages.add(pick(pools.mascot, 0));
  messages.add(pick(pools.mascot, 1));

  return messages;
}

/// Вечерний нудж «не потеряй серию» для второго ежедневного уведомления.
/// Если стрика ещё нет — мягко зовём вернуться. Язык берём из [locale], а по
/// умолчанию — из последнего вызова [buildReminders] (парное планирование).
ReminderMessage buildStreakReminder({
  required String name,
  required int streak,
  DateTime? now,
  AppLocale? locale,
}) {
  final effectiveLocale = locale ?? _lastLocale;
  final today = now ?? DateTime.now();
  final rotation = today.difference(DateTime(today.year)).inDays;
  final pools = _poolsFor(effectiveLocale);
  final fill = _fillFactory(
    name: name,
    streak: streak,
    dueCount: 0,
    locale: effectiveLocale,
  );
  final pool = streak > 0 ? pools.streakAtRisk : pools.returnAfterPause;
  final raw = pool[rotation % pool.length];
  return ReminderMessage(fill(raw.title), fill(raw.body));
}

/// Язык последнего планирования (см. [buildReminders]). По умолчанию русский.
AppLocale _lastLocale = AppLocale.ru;

bool _isMilestone(int streak) =>
    streak == 3 || streak == 7 || streak == 30 || streak == 100;

/// Возвращает функцию подстановки плейсхолдеров. Пустое имя (или гостевое
/// обращение вроде «Гость»/«Қонақ»/«Guest») заменяем тёплым нейтральным
/// словом на языке пользователя, чтобы реплики кота звучали живо.
String Function(String) _fillFactory({
  required String name,
  required int streak,
  required int dueCount,
  required AppLocale locale,
}) {
  final trimmed = name.trim();
  final isGuest = trimmed.isEmpty || _guestLabels.contains(trimmed);
  final who = isGuest ? _poolsFor(locale).guestFallback : trimmed;
  return (String source) => source
      .replaceAll('{name}', who)
      .replaceAll('{streak}', '$streak')
      .replaceAll('{dueCount}', '$dueCount');
}

/// Гостевые обращения на всех языках — трактуем как отсутствие имени.
const _guestLabels = <String>{'Гость', 'Қонақ', 'Guest', 'гость'};

/// Пулы сообщений для одного языка.
class _LocalePools {
  final List<ReminderMessage> streakAtRisk;
  final List<ReminderMessage> streakCelebration;
  final List<ReminderMessage> reviewDue;
  final List<ReminderMessage> returnAfterPause;
  final List<ReminderMessage> dailyGeneral;
  final List<ReminderMessage> mascot;
  final String guestFallback;

  const _LocalePools({
    required this.streakAtRisk,
    required this.streakCelebration,
    required this.reviewDue,
    required this.returnAfterPause,
    required this.dailyGeneral,
    required this.mascot,
    required this.guestFallback,
  });
}

_LocalePools _poolsFor(AppLocale locale) {
  switch (locale) {
    case AppLocale.kk:
      return _kkPools;
    case AppLocale.en:
      return _enPools;
    case AppLocale.ru:
      return _ruPools;
  }
}

// ===========================================================================
// Русский (по умолчанию).
// ===========================================================================
const _ruPools = _LocalePools(
  guestFallback: 'друг',
  // (a) Стрик под угрозой — вечерний нудж «не потеряй серию».
  streakAtRisk: <ReminderMessage>[
    ReminderMessage(
      'Спаси свой ударный режим',
      'Твой {streak}-дневный стрик держится на волоске. Шесть минут — и серия в безопасности.',
    ),
    ReminderMessage(
      '{name}, серия ждёт тебя',
      'Не дай {streak}-дневному стрику погаснуть сегодня. Хватит одного короткого урока.',
    ),
    ReminderMessage(
      'Ещё чуть-чуть — и день закрыт',
      '{streak} дней подряд — это уже ты. Спокойные шесть минут сохранят серию до завтра.',
    ),
    ReminderMessage(
      'Огонёк почти погас',
      'Твой ударный режим на {streak} дней ждёт всего один шаг. Успеем сегодня?',
    ),
  ],
  // (b) Празднование стрика на круглых датах.
  streakCelebration: <ReminderMessage>[
    ReminderMessage(
      'Ого, {streak} дней подряд!',
      'Ты держишь ритм как чемпион. Ещё один маленький урок — и серия растёт дальше.',
    ),
    ReminderMessage(
      '{streak} дней — это характер',
      'Такую привычку строят единицы. Кот гордится тобой, {name}.',
    ),
    ReminderMessage(
      'Стрик на {streak} дней — красота',
      'Ты приходишь каждый день, и это главное. Продолжим традицию сегодня?',
    ),
  ],
  // (c) Есть аяты на повторение.
  reviewDue: <ReminderMessage>[
    ReminderMessage(
      '{dueCount} аятов ждут повторения',
      'Короткое повторение сегодня — и они закрепятся надолго. Заглянем на минутку?',
    ),
    ReminderMessage(
      'Пора освежить знакомое',
      'Тебя ждёт {dueCount} аятов на повторение. Пара минут — и память скажет спасибо.',
    ),
    ReminderMessage(
      'Повторение зовёт, {name}',
      '{dueCount} аятов почти готовы стать твоими навсегда. Осталось совсем чуть-чуть.',
    ),
  ],
  // (d) Возвращение после паузы (стрик обнулился).
  returnAfterPause: <ReminderMessage>[
    ReminderMessage(
      'Начнём заново, я рядом',
      'Пауза — это нормально. Один маленький урок сегодня, и ты снова в пути.',
    ),
    ReminderMessage(
      'Рад тебя видеть снова',
      'Не будем начинать издалека — всего шесть спокойных минут, чтобы вернуться в ритм.',
    ),
    ReminderMessage(
      'Новый стрик начинается сегодня',
      'Первый день всегда самый лёгкий. Сделаем его вместе, {name}?',
    ),
    ReminderMessage(
      'Тихо возвращаемся к урокам',
      'Без спешки и без упрёков. Просто открой Muslingo и сделай один шаг.',
    ),
  ],
  // (e) Обычные дневные напоминания.
  dailyGeneral: <ReminderMessage>[
    ReminderMessage(
      'Твой сегодняшний шаг готов',
      'Шесть спокойных минут: немного нового и повторение того, что уже знакомо.',
    ),
    ReminderMessage(
      'Сегодня достаточно одного шага',
      'Послушай, пойми смысл и повтори. Урок уже собран под твой прогресс.',
    ),
    ReminderMessage(
      'Маленькое повторение, большой результат',
      'Твой персональный урок продолжает вчерашний путь. Заглянем на минутку?',
    ),
    ReminderMessage(
      'Твой маршрут обновлён',
      'Muslingo подготовил следующий урок по твоему уровню и последним шагам.',
    ),
  ],
  // (f) Реплики от лица кота-маскота — всегда обращаемся по имени.
  mascot: <ReminderMessage>[
    ReminderMessage(
      'Кот скучает по тебе, {name}',
      'Я разложил урок и жду. Заглянешь на шесть минут?',
    ),
    ReminderMessage(
      'Мяу! Пора заниматься, {name}',
      'Кот уже сидит у экрана и машет лапой. Один короткий урок — и он счастлив.',
    ),
    ReminderMessage(
      '{name}, кот приготовил урок',
      'Тёплый коврик, свежий аят и ты. Всё готово для короткого занятия.',
    ),
    ReminderMessage(
      'Кот верит в тебя, {name}',
      'Даже самый маленький шаг сегодня — это уже победа. Сделаем его вместе?',
    ),
  ],
);

// ===========================================================================
// Қазақша.
// ===========================================================================
const _kkPools = _LocalePools(
  guestFallback: 'дос',
  streakAtRisk: <ReminderMessage>[
    ReminderMessage(
      'Серияңды сақтап қал',
      '{streak} күндік серияң қыл үстінде тұр. Алты минут — серия аман.',
    ),
    ReminderMessage(
      '{name}, серия сені күтіп тұр',
      '{streak} күндік серияңды бүгін өшірме. Бір қысқа сабақ жеткілікті.',
    ),
    ReminderMessage(
      'Тағы сәл-ақ қалды',
      '{streak} күн қатарынан — бұл сенсің. Тыныш алты минут серияңды ертеңге жеткізеді.',
    ),
    ReminderMessage(
      'Оты сөнейін деп тұр',
      '{streak} күндік серияңа бір-ақ қадам қалды. Бүгін үлгереміз бе?',
    ),
  ],
  streakCelebration: <ReminderMessage>[
    ReminderMessage(
      'Пәлі, {streak} күн қатарынан!',
      'Ырғақты чемпиондай ұстап тұрсың. Тағы бір шағын сабақ — серия әрі қарай өседі.',
    ),
    ReminderMessage(
      '{streak} күн — бұл мінез',
      'Мұндай әдетті сирек адам қалыптастырады. Мысық сені мақтан тұтады, {name}.',
    ),
    ReminderMessage(
      '{streak} күндік серия — керемет',
      'Күн сайын келесің, ең бастысы — осы. Дәстүрді бүгін жалғастырамыз ба?',
    ),
  ],
  reviewDue: <ReminderMessage>[
    ReminderMessage(
      '{dueCount} аят қайталауды күтіп тұр',
      'Бүгінгі қысқа қайталау — олар ұзаққа бекиді. Бір минутқа кіреміз бе?',
    ),
    ReminderMessage(
      'Таныс дүниені жаңғырту сәті',
      'Сені {dueCount} аят қайталау күтіп тұр. Бірер минут — жадың рахмет айтады.',
    ),
    ReminderMessage(
      'Қайталау шақырып тұр, {name}',
      '{dueCount} аят мәңгі сенікі болуға сәл-ақ қалды. Азғантай ғана қалды.',
    ),
  ],
  returnAfterPause: <ReminderMessage>[
    ReminderMessage(
      'Қайта бастайық, мен қасыңдамын',
      'Үзіліс — қалыпты нәрсе. Бүгін бір шағын сабақ, сен қайтадан жолдасың.',
    ),
    ReminderMessage(
      'Сені қайта көргеніме қуаныштымын',
      'Алыстан бастамайық — ырғаққа оралу үшін бар болғаны тыныш алты минут.',
    ),
    ReminderMessage(
      'Жаңа серия бүгін басталады',
      'Бірінші күн әрқашан жеңіл. Оны бірге жасайық па, {name}?',
    ),
    ReminderMessage(
      'Сабаққа асықпай ораламыз',
      'Асығыссыз әрі кінәсіз. Muslingo-ны ашып, бір қадам жаса.',
    ),
  ],
  dailyGeneral: <ReminderMessage>[
    ReminderMessage(
      'Бүгінгі қадамың дайын',
      'Тыныш алты минут: азғантай жаңалық және таныс дүниені қайталау.',
    ),
    ReminderMessage(
      'Бүгін бір қадам жеткілікті',
      'Тыңда, мағынасын ұқ және қайтала. Сабақ прогресіңе қарай жиналған.',
    ),
    ReminderMessage(
      'Шағын қайталау, үлкен нәтиже',
      'Жеке сабағың кешегі жолды жалғастырады. Бір минутқа кіреміз бе?',
    ),
    ReminderMessage(
      'Бағытың жаңарды',
      'Muslingo деңгейің мен соңғы қадамдарыңа қарай келесі сабақты дайындады.',
    ),
  ],
  mascot: <ReminderMessage>[
    ReminderMessage(
      'Мысық сені сағынды, {name}',
      'Сабақты жайып қойып, күтіп отырмын. Алты минутқа кіресің бе?',
    ),
    ReminderMessage(
      'Мияу! Оқитын кез, {name}',
      'Мысық экран алдында отыр, тәпелтегін бұлғап тұр. Бір қысқа сабақ — ол бақытты.',
    ),
    ReminderMessage(
      '{name}, мысық сабақ дайындады',
      'Жылы кілем, жаңа аят және сен. Қысқа сабаққа бәрі дайын.',
    ),
    ReminderMessage(
      'Мысық саған сенеді, {name}',
      'Бүгінгі ең кішкентай қадам да — жеңіс. Оны бірге жасайық па?',
    ),
  ],
);

// ===========================================================================
// English.
// ===========================================================================
const _enPools = _LocalePools(
  guestFallback: 'friend',
  streakAtRisk: <ReminderMessage>[
    ReminderMessage(
      'Save your streak',
      'Your {streak}-day streak is hanging by a thread. Six minutes and it is safe.',
    ),
    ReminderMessage(
      '{name}, your streak is waiting',
      'Do not let your {streak}-day streak fade today. One short lesson is enough.',
    ),
    ReminderMessage(
      'Almost done for today',
      '{streak} days in a row is already you. A calm six minutes keeps the streak till tomorrow.',
    ),
    ReminderMessage(
      'The spark is almost out',
      'Your {streak}-day streak needs just one step. Can we make it today?',
    ),
  ],
  streakCelebration: <ReminderMessage>[
    ReminderMessage(
      'Wow, {streak} days in a row!',
      'You keep the rhythm like a champion. One more little lesson and the streak grows.',
    ),
    ReminderMessage(
      '{streak} days takes character',
      'Few people build a habit like this. The cat is proud of you, {name}.',
    ),
    ReminderMessage(
      'A {streak}-day streak, beautiful',
      'You show up every day, and that is what matters. Shall we keep the tradition today?',
    ),
  ],
  reviewDue: <ReminderMessage>[
    ReminderMessage(
      '{dueCount} verses are due for review',
      'A short review today and they stick for good. Shall we drop in for a minute?',
    ),
    ReminderMessage(
      'Time to refresh the familiar',
      '{dueCount} verses are waiting for review. A couple of minutes and your memory says thanks.',
    ),
    ReminderMessage(
      'Review is calling, {name}',
      '{dueCount} verses are almost yours forever. Just a little left.',
    ),
  ],
  returnAfterPause: <ReminderMessage>[
    ReminderMessage(
      'Let us start over, I am here',
      'A pause is okay. One small lesson today and you are back on the path.',
    ),
    ReminderMessage(
      'Great to see you again',
      'We will not start from far away, just six calm minutes to find the rhythm.',
    ),
    ReminderMessage(
      'A new streak starts today',
      'The first day is always the easiest. Shall we do it together, {name}?',
    ),
    ReminderMessage(
      'Quietly back to lessons',
      'No rush and no blame. Just open Muslingo and take one step.',
    ),
  ],
  dailyGeneral: <ReminderMessage>[
    ReminderMessage(
      'Your step for today is ready',
      'Six calm minutes: a little new and a review of the familiar.',
    ),
    ReminderMessage(
      'One step is enough today',
      'Listen, catch the meaning, and repeat. The lesson is built around your progress.',
    ),
    ReminderMessage(
      'Small review, big result',
      'Your personal lesson continues yesterday. Shall we drop in for a minute?',
    ),
    ReminderMessage(
      'Your route is updated',
      'Muslingo has prepared the next lesson for your level and latest steps.',
    ),
  ],
  mascot: <ReminderMessage>[
    ReminderMessage(
      'The cat misses you, {name}',
      'I have laid out the lesson and I am waiting. Coming in for six minutes?',
    ),
    ReminderMessage(
      'Meow! Time to study, {name}',
      'The cat is at the screen waving a paw. One short lesson and it is happy.',
    ),
    ReminderMessage(
      '{name}, the cat prepared a lesson',
      'A warm mat, a fresh verse, and you. Everything is ready for a short session.',
    ),
    ReminderMessage(
      'The cat believes in you, {name}',
      'Even the smallest step today is already a win. Shall we take it together?',
    ),
  ],
);

class ReminderMessages {
  static const test = ReminderMessage(
    'Уведомления Muslingo работают',
    'Когда подойдёт время урока, мы напомним спокойно и по делу.',
  );
}
