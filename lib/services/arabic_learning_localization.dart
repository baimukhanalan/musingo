/// Letter names are terminology, not ordinary words (Dad, Sin, etc.).
/// Keep deterministic source-based names in Arabic reading exercises instead of
/// allowing the general machine-translation dictionary to change their meaning.
String? localizeArabicLearningText(String source, String locale) {
  if (locale == 'ar') return _arabicTerminology(source);
  if (locale != 'kk' && locale != 'en') return null;
  final kk = locale == 'kk';
  const names = <String, (String, String)>{
    'Алиф': ('Алиф', 'Alif'),
    'Ба': ('Ба', 'Ba'),
    'Та': ('Та', 'Ta'),
    'Са': ('Са', 'Tha'),
    'Джим': ('Джим', 'Jim'),
    'Ха': ('Ха', 'Ha'),
    'Хо': ('Хо', 'Kha'),
    'Даль': ('Даль', 'Dal'),
    'Заль': ('Заль', 'Dhal'),
    'Ра': ('Ра', 'Ra'),
    'Зай': ('Зай', 'Zay'),
    'Син': ('Син', 'Sin'),
    'Шин': ('Шин', 'Shin'),
    'Сад': ('Сад', 'Sad'),
    'Дад': ('Дад', 'Dad'),
    'Та твёрдая': ('Жуан Та', 'Emphatic Ta'),
    'За твёрдая': ('Жуан За', 'Emphatic Za'),
    'Айн': ('Айн', 'Ayn'),
    'Гайн': ('Ғайн', 'Ghayn'),
    'Фа': ('Фа', 'Fa'),
    'Каф глубокая': ('Терең Каф', 'Qaf'),
    'Каф': ('Каф', 'Kaf'),
    'Лям': ('Ләм', 'Lam'),
    'Мим': ('Мим', 'Mim'),
    'Нун': ('Нун', 'Nun'),
    'Ха лёгкая': ('Жеңіл Ха', 'Light Ha'),
    'Вав': ('Уау', 'Waw'),
    'Йа': ('Йа', 'Ya'),
    'Хамза': ('Хамза', 'Hamza'),
  };
  String? name(String value) {
    final pair = names[value];
    return pair == null ? null : (kk ? pair.$1 : pair.$2);
  }

  final exact = name(source);
  if (exact != null) return exact;
  if (source == 'Слышать характеристику в син, сад и зай без преувеличения.') {
    return kk
        ? 'Син, Сад және Зай әріптерінің сипатын асыра сілтемей естіп ажырату.'
        : 'Recognize the quality in Sin, Sad, and Zay without exaggeration.';
  }
  const phases = {
    'Точный звук': ('Дыбысты дәл айту', 'Precise pronunciation'),
    'Форма в слове': ('Сөз ішіндегі пішіні', 'Form within a word'),
    'Чтение без подсказки': ('Көмексіз оқу', 'Reading without hints'),
  };
  final colon = source.indexOf(': ');
  if (colon > 0) {
    final letter = name(source.substring(0, colon));
    final phase = phases[source.substring(colon + 2)];
    if (letter != null && phase != null) {
      return '$letter: ${kk ? phase.$1 : phase.$2}';
    }
  }
  final list = source.split(', ');
  if (list.length > 1 && list.every((item) => name(item) != null)) {
    return list.map((item) => name(item)!).join(', ');
  }

  var match = RegExp(
          r'^Сравни (.+) с (.+)\. Сначала найди отличие на слух, затем произнеси слово целиком\.$')
      .firstMatch(source);
  if (match != null) {
    final first = name(match[1]!);
    final second = name(match[2]!);
    if (first != null && second != null) {
      return kk
          ? '$first және $second әріптерін салыстыр. Алдымен дыбысталу айырмасын тыңдап анықта, содан кейін сөзді толық айт.'
          : 'Compare $first with $second. First listen for the difference, then pronounce the whole word.';
    }
  }
  match = RegExp(
          r'^Проследи, как (.+) меняет соединение в слове, не меняя основной звук\.$')
      .firstMatch(source);
  if (match != null && name(match[1]!) != null) {
    final letter = name(match[1]!)!;
    return kk
        ? '$letter әрпінің негізгі дыбысы өзгермей, сөздегі жалғану пішіні қалай өзгеретінін бақыла.'
        : 'Observe how $letter connects within a word while keeping its basic sound.';
  }
  match = RegExp(r'^Проверь место образования (.+) и длину гласной\.$')
      .firstMatch(source);
  if (match != null && name(match[1]!) != null) {
    final letter = name(match[1]!)!;
    return kk
        ? '$letter әрпінің жасалу орнын және дауысты дыбыстың ұзақтығын тексер.'
        : 'Check the articulation of $letter and the vowel length.';
  }
  match = RegExp(r'^Как узнать (.+) после соединения\?$').firstMatch(source);
  if (match != null && name(match[1]!) != null) {
    final letter = name(match[1]!)!;
    return kk
        ? 'Жалғанған $letter әрпін қалай тануға болады?'
        : 'How do you recognize $letter when it is connected?';
  }
  match = RegExp(r'^Он заменяет (.+) на (.+)$').firstMatch(source);
  if (match != null) {
    final first = name(match[1]!);
    final second = name(match[2]!);
    if (first != null && second != null) {
      return kk
          ? '$first әрпінің орнына $second айтылған'
          : 'It replaces $first with $second';
    }
  }
  match = RegExp(
          r'^Сначала прослушай образец\. Затем произнеси слово, сохраняя отличие от (.+)\.$')
      .firstMatch(source);
  if (match != null && name(match[1]!) != null) {
    final letter = name(match[1]!)!;
    return kk
        ? 'Алдымен үлгіні тыңда. Содан кейін $letter әрпінен айырмасын сақтап, сөзді айт.'
        : 'Listen to the sample first. Then pronounce the word, keeping it distinct from $letter.';
  }
  return null;
}

String? _arabicTerminology(String source) {
  final exact = _arabicLetterNames[source];
  if (exact != null) return exact;
  const phases = {
    'Точный звук': 'النطق الدقيق',
    'Форма в слове': 'شكل الحرف في الكلمة',
    'Чтение без подсказки': 'القراءة دون تلميحات',
  };
  final colon = source.indexOf(': ');
  if (colon > 0) {
    final letter = _arabicLetterNames[source.substring(0, colon)];
    final phase = phases[source.substring(colon + 2)];
    if (letter != null && phase != null) return '$letter: $phase';
  }
  final list = source.split(', ');
  if (list.length > 1 && list.every(_arabicLetterNames.containsKey)) {
    return list.map((item) => _arabicLetterNames[item]!).join('، ');
  }
  var match = RegExp(
          r'^Сравни (.+) с (.+)\. Сначала найди отличие на слух, затем произнеси слово целиком\.$')
      .firstMatch(source);
  if (match != null) {
    final first = _arabicLetterNames[match[1]];
    final second = _arabicLetterNames[match[2]];
    if (first != null && second != null) {
      return 'قارن $first بـ$second. ميّز الفرق بالاستماع أولًا، ثم انطق الكلمة كاملة.';
    }
  }
  match = RegExp(r'^Он заменяет (.+) на (.+)$').firstMatch(source);
  if (match != null) {
    final first = _arabicLetterNames[match[1]];
    final second = _arabicLetterNames[match[2]];
    if (first != null && second != null) return 'يستبدل $first بـ$second';
  }
  for (final entry in <String, String Function(String)>{
    r'^Проследи, как (.+) меняет соединение в слове, не меняя основной звук\.$':
        (letter) =>
            'لاحظ كيف يتغيّر اتصال $letter في الكلمة دون تغيير صوته الأساسي.',
    r'^Проверь место образования (.+) и длину гласной\.$': (letter) =>
        'تحقّق من مخرج $letter وطول الحركة.',
    r'^Как узнать (.+) после соединения\?$': (letter) =>
        'كيف تتعرّف إلى $letter عند اتصاله؟',
    r'^Сначала прослушай образец\. Затем произнеси слово, сохраняя отличие от (.+)\.$':
        (letter) =>
            'استمع إلى النموذج أولًا، ثم انطق الكلمة مع الحفاظ على الفرق عن $letter.',
  }.entries) {
    match = RegExp(entry.key).firstMatch(source);
    final letter = match == null ? null : _arabicLetterNames[match[1]];
    if (letter != null) return entry.value(letter);
  }
  if (source == 'Слышать характеристику в син, сад и зай без преувеличения.') {
    return 'تمييز الصفة سمعيًا في السين والصاد والزاي دون مبالغة.';
  }
  return null;
}

const _arabicLetterNames = <String, String>{
  'Алиф': 'الألف',
  'Ба': 'الباء',
  'Та': 'التاء',
  'Са': 'الثاء',
  'Джим': 'الجيم',
  'Ха': 'الحاء',
  'Хо': 'الخاء',
  'Даль': 'الدال',
  'Заль': 'الذال',
  'Ра': 'الراء',
  'Зай': 'الزاي',
  'Син': 'السين',
  'Шин': 'الشين',
  'Сад': 'الصاد',
  'Дад': 'الضاد',
  'Та твёрдая': 'الطاء',
  'За твёрдая': 'الظاء',
  'Айн': 'العين',
  'Гайн': 'الغين',
  'Фа': 'الفاء',
  'Каф глубокая': 'القاف',
  'Каф': 'الكاف',
  'Лям': 'اللام',
  'Мим': 'الميم',
  'Нун': 'النون',
  'Ха лёгкая': 'الهاء',
  'Вав': 'الواو',
  'Йа': 'الياء',
  'Хамза': 'الهمزة',
};
