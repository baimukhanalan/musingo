import '../models/lesson.dart';
import '../utils/quran_search.dart';
import 'lessons/quran_curriculum_localization.dart';

/// Controlled lesson headings only. Quran recitation, teaching prose and grading
/// are not rewritten. Names are identifiers, never translated as ordinary words.
String? localizeLearningTitle(String source, CourseType course, String locale) {
  if (course == CourseType.quran) {
    final readingTitle = localizeQuranCurriculumText(source, locale);
    if (readingTitle != null) return readingTitle;
  }
  if (locale == 'ar') return _arabicTitle(source, course);
  if (locale != 'kk' && locale != 'en') return null;
  final kk = locale == 'kk';
  if (course == CourseType.tajwid) {
    final title = _tajwidTitles[source];
    return title == null ? null : (kk ? title.$1 : title.$2);
  }
  if (course != CourseType.quran) return null;
  const reviewPrefix = 'Закрепление: ';
  if (source.startsWith(reviewPrefix)) {
    final title = localizeLearningTitle(
        source.substring(reviewPrefix.length), course, locale);
    return title == null ? null : '${kk ? 'Бекіту' : 'Review'}: $title';
  }
  final ordinary = _quranTopicTitles[source];
  if (ordinary != null) return kk ? ordinary.$1 : ordinary.$2;
  final parts =
      RegExp(r'^(.*?)(, часть [12]|: начало| 1-2)?$').firstMatch(source)!;
  final name = parts[1]!;
  final latinName = _surahNames[name];
  if (latinName == null) return null;
  // Reuse source-verified Kazakh reader names wherever available. Otherwise
  // retain the existing lesson's recognizable Cyrillic phonetic name rather
  // than asking a machine translator to translate its meaning.
  final chapterNumber =
      quranRussianNames.indexOf(_chapterAliases[name] ?? name) + 1;
  final localizedName = kk
      ? quranKazakhNames[chapterNumber] ??
          name
              .replaceFirst(RegExp(r'^Аль-'), 'Әл-')
              .replaceFirst('Ад-Духа', 'Әд-Духа')
      : latinName;
  final suffix = switch (parts[2]) {
    ', часть 1' => kk ? ', 1-бөлім' : ', part 1',
    ', часть 2' => kk ? ', 2-бөлім' : ', part 2',
    ': начало' => kk ? ': басталуы' : ': beginning',
    ' 1-2' => ' 1–2',
    _ => '',
  };
  return '$localizedName$suffix';
}

String? _arabicTitle(String source, CourseType course) {
  if (course == CourseType.tajwid) return _arabicTajwidTitles[source];
  if (course != CourseType.quran) return null;
  const prefix = 'Закрепление: ';
  if (source.startsWith(prefix)) {
    final title = _arabicTitle(source.substring(prefix.length), course);
    return title == null ? null : 'مراجعة: $title';
  }
  const topics = {
    'Хвала Господу миров': 'الحمد لرب العالمين',
    'Поклонение и просьба': 'العبادة والدعاء',
    'Прямой путь': 'الصراط المستقيم',
    'Проверка 5 сур': 'اختبار في خمس سور',
    'Проверка коротких сур': 'اختبار السور القصيرة',
  };
  if (topics[source] case final title?) return title;
  final parts =
      RegExp(r'^(.*?)(, часть [12]|: начало| 1-2)?$').firstMatch(source)!;
  final name = parts[1]!;
  final chapter = quranRussianNames.indexOf(_chapterAliases[name] ?? name) + 1;
  final title = arabicLearningSurahNames[chapter];
  if (title == null) return null;
  final suffix = switch (parts[2]) {
    ', часть 1' => '، الجزء 1',
    ', часть 2' => '، الجزء 2',
    ': начало' => ': البداية',
    ' 1-2' => ' 1–2',
    _ => '',
  };
  return 'سورة $title$suffix';
}

/// Chapter identifiers verified against https://api.alquran.cloud/v1/surah.
/// Display spelling omits optional diacritics; the canonical ayah asset is never
/// changed. Only chapters used by the legacy guided title set are listed here.
const arabicLearningSurahNames = <int, String>{
  1: 'الفاتحة',
  2: 'البقرة',
  58: 'المجادلة',
  59: 'الحشر',
  60: 'الممتحنة',
  61: 'الصف',
  62: 'الجمعة',
  63: 'المنافقون',
  64: 'التغابن',
  65: 'الطلاق',
  66: 'التحريم',
  67: 'الملك',
  68: 'القلم',
  69: 'الحاقة',
  70: 'المعارج',
  71: 'نوح',
  72: 'الجن',
  73: 'المزمل',
  74: 'المدثر',
  75: 'القيامة',
  76: 'الإنسان',
  77: 'المرسلات',
  78: 'النبأ',
  79: 'النازعات',
  80: 'عبس',
  81: 'التكوير',
  82: 'الانفطار',
  83: 'المطففين',
  84: 'الانشقاق',
  85: 'البروج',
  86: 'الطارق',
  87: 'الأعلى',
  88: 'الغاشية',
  89: 'الفجر',
  90: 'البلد',
  91: 'الشمس',
  92: 'الليل',
  93: 'الضحى',
  94: 'الشرح',
  95: 'التين',
  96: 'العلق',
  97: 'القدر',
  98: 'البينة',
  99: 'الزلزلة',
  100: 'العاديات',
  101: 'القارعة',
  102: 'التكاثر',
  103: 'العصر',
  104: 'الهمزة',
  105: 'الفيل',
  106: 'قريش',
  107: 'الماعون',
  108: 'الكوثر',
  109: 'الكافرون',
  110: 'النصر',
  111: 'المسد',
  112: 'الإخلاص',
  113: 'الفلق',
  114: 'الناس',
};

const _arabicTajwidTitles = <String, String>{
  'Что такое таджвид': 'ما التجويد؟',
  'Пять зон махраджа': 'مناطق المخارج الخمس',
  'Полость рта и мадд': 'الجوف والمد',
  'Глубокая часть горла': 'أقصى الحلق',
  'Средняя часть горла': 'وسط الحلق',
  'Верхняя часть горла': 'أدنى الحلق',
  'Губные буквы': 'حروف الشفتين',
  'Буква ف': 'حرف الفاء',
  'Межзубные ث ذ ظ': 'الحروف ث ذ ظ',
  'Буквы ت د ط': 'الحروف ت د ط',
  'Свистящие ز س ص': 'حروف الصفير ز س ص',
  'Середина языка': 'وسط اللسان',
  'Бок языка: ض и ل': 'حافة اللسان: ض و ل',
  'Задняя часть языка': 'أقصى اللسان',
  'Кончик языка: ل ن ر': 'طرف اللسان: ل ن ر',
  'Контроль махраджей': 'تقييم المخارج',
  'Хамс и джахр': 'الهمس والجهر',
  'Сила потока звука': 'قوة جريان الصوت',
  'Твердые буквы': 'الحروف المفخمة',
  'Калькаля': 'القلقلة',
  'Гунна': 'الغنة',
  'Изхар': 'الإظهار',
  'Идгам с гунной': 'الإدغام بغنة',
  'Идгам без гунны': 'الإدغام بغير غنة',
  'Икляб': 'الإقلاب',
  'Ихфа': 'الإخفاء',
  'Мим сакина': 'الميم الساكنة',
  'Мадд табии': 'المد الطبيعي',
  'Муттасиль и мунфасиль': 'المد المتصل والمنفصل',
  'Мадд лязим': 'المد اللازم',
  'Мадд арид': 'المد العارض للسكون',
  'Лям в имени Аллаха': 'لام لفظ الجلالة',
  'Солнечные и лунные': 'الحروف الشمسية والقمرية',
  'Буква ر': 'حرف الراء',
  'Остановка и знаки вакфа': 'الوقف وعلاماته',
  'Итоговая практика': 'التدريب الختامي',
};

// Equivalent source spellings already present in guided lessons vs the reader.
const _chapterAliases = <String, String>{
  'Ат-Таляк': 'Ат-Талак',
  'Аль-Калям': 'Аль-Калам',
  'Аль-Аля': 'Аль-Ала',
  'Аль-Баляд': 'Аль-Балад',
  'Аль-Лейль': 'Аль-Лейл',
  'Аль-Аляк': 'Аль-Алак',
  'Аз-Зальзаля': 'Аз-Залзала',
};

// The Russian keys come from the existing lesson materials. Latin names match
// the chapter identifiers used by QuranRepository's provider, verified at
// https://api.alquran.cloud/v1/surah (not English translations of the names).
const _surahNames = <String, String>{
  'Аль-Фатиха': 'Al-Faatiha',
  'Аль-Бакара': 'Al-Baqara',
  'Аль-Муджадила': 'Al-Mujaadila',
  'Аль-Хашр': 'Al-Hashr',
  'Аль-Мумтахана': 'Al-Mumtahana',
  'Ас-Сафф': 'As-Saff',
  'Аль-Джумуа': "Al-Jumu'a",
  'Аль-Мунафикун': 'Al-Munaafiqoon',
  'Ат-Тагабун': 'At-Taghaabun',
  'Ат-Таляк': 'At-Talaaq',
  'Ат-Тахрим': 'At-Tahrim',
  'Аль-Мульк': 'Al-Mulk',
  'Аль-Калям': 'Al-Qalam',
  'Аль-Хакка': 'Al-Haaqqa',
  'Аль-Мааридж': "Al-Ma'aarij",
  'Нух': 'Nooh',
  'Аль-Джинн': 'Al-Jinn',
  'Аль-Муззаммиль': 'Al-Muzzammil',
  'Аль-Муддассир': 'Al-Muddaththir',
  'Аль-Кияма': 'Al-Qiyaama',
  'Аль-Инсан': 'Al-Insaan',
  'Аль-Мурсалят': 'Al-Mursalaat',
  'Ан-Наба': 'An-Naba',
  'Ан-Назиат': "An-Naazi'aat",
  'Абаса': 'Abasa',
  'Ат-Таквир': 'At-Takwir',
  'Аль-Инфитар': 'Al-Infitaar',
  'Аль-Мутаффифин': 'Al-Mutaffifin',
  'Аль-Иншикак': 'Al-Inshiqaaq',
  'Аль-Бурудж': 'Al-Burooj',
  'Ат-Тарик': 'At-Taariq',
  'Аль-Аля': "Al-A'laa",
  'Аль-Гашия': 'Al-Ghaashiya',
  'Аль-Фаджр': 'Al-Fajr',
  'Аль-Баляд': 'Al-Balad',
  'Аш-Шамс': 'Ash-Shams',
  'Аль-Лейль': 'Al-Lail',
  'Ад-Духа': 'Ad-Dhuhaa',
  'Аш-Шарх': 'Ash-Sharh',
  'Ат-Тин': 'At-Tin',
  'Аль-Аляк': 'Al-Alaq',
  'Аль-Кадр': 'Al-Qadr',
  'Аль-Баййина': 'Al-Bayyina',
  'Аз-Зальзаля': 'Az-Zalzala',
  'Аль-Адият': 'Al-Aadiyaat',
  'Аль-Кариа': "Al-Qaari'a",
  'Ат-Такасур': 'At-Takaathur',
  'Аль-Аср': 'Al-Asr',
  'Аль-Хумаза': 'Al-Humaza',
  'Аль-Филь': 'Al-Fil',
  'Курайш': 'Quraish',
  'Аль-Маун': "Al-Maa'un",
  'Аль-Каусар': 'Al-Kawthar',
  'Аль-Кафирун': 'Al-Kaafiroon',
  'Ан-Наср': 'An-Nasr',
  'Аль-Масад': 'Al-Masad',
  'Аль-Ихлас': 'Al-Ikhlaas',
  'Аль-Фалак': 'Al-Falaq',
  'Ан-Нас': 'An-Naas',
};

const _quranTopicTitles = <String, (String, String)>{
  'Хвала Господу миров': (
    'Әлемдердің Раббысына мадақ',
    'Praise to the Lord of the worlds'
  ),
  'Поклонение и просьба': ('Құлшылық және тілек', 'Worship and supplication'),
  'Прямой путь': ('Тура жол', 'The straight path'),
  'Проверка 5 сур': ('5 сүре бойынша тексеру', 'Five-surah assessment'),
  'Проверка коротких сур': (
    'Қысқа сүрелер бойынша тексеру',
    'Short-surah assessment'
  ),
};

// Source-based terminology for all 36 Tajwid headings. These labels summarize
// existing lessons; they do not introduce any new recitation rule or doctrine.
const _tajwidTitles = <String, (String, String)>{
  'Что такое таджвид': ('Тәжуид деген не', 'What is Tajwid'),
  'Пять зон махраджа': ('Махраждың бес аймағы', 'Five articulation regions'),
  'Полость рта и мадд': ('Ауыз қуысы және мәдд', 'The oral cavity and madd'),
  'Глубокая часть горла': (
    'Жұтқыншақтың терең бөлігі',
    'The deepest part of the throat'
  ),
  'Средняя часть горла': (
    'Жұтқыншақтың ортаңғы бөлігі',
    'The middle of the throat'
  ),
  'Верхняя часть горла': (
    'Жұтқыншақтың жоғарғы бөлігі',
    'The upper part of the throat'
  ),
  'Губные буквы': ('Ерін әріптері', 'Lip letters'),
  'Буква ف': ('ف әрпі', 'The letter ف'),
  'Межзубные ث ذ ظ': ('Тісаралық ث ذ ظ әріптері', 'Interdental ث ذ ظ'),
  'Буквы ت د ط': ('ت د ط әріптері', 'The letters ت د ط'),
  'Свистящие ز س ص': ('Ысқырықты ز س ص әріптері', 'Sibilants ز س ص'),
  'Середина языка': ('Тілдің ортаңғы бөлігі', 'The middle of the tongue'),
  'Бок языка: ض и ل': (
    'Тілдің бүйірі: ض және ل',
    'The side of the tongue: ض and ل'
  ),
  'Задняя часть языка': ('Тілдің артқы бөлігі', 'The back of the tongue'),
  'Кончик языка: ل ن ر': ('Тілдің ұшы: ل ن ر', 'The tip of the tongue: ل ن ر'),
  'Контроль махраджей': ('Махраждарды тексеру', 'Articulation assessment'),
  'Хамс и джахр': ('Һәмс және жәһр', 'Hams and jahr'),
  'Сила потока звука': ('Дыбыс ағынының күші', 'Strength of sound flow'),
  'Твердые буквы': ('Жуан әріптер', 'Emphatic letters'),
  'Калькаля': ('Қалқала', 'Qalqalah'),
  'Гунна': ('Ғұнна', 'Ghunnah'),
  'Изхар': ('Изһар', 'Izhar'),
  'Идгам с гунной': ('Ғұннамен идғам', 'Idgham with ghunnah'),
  'Идгам без гунны': ('Ғұннасыз идғам', 'Idgham without ghunnah'),
  'Икляб': ('Иқлаб', 'Iqlab'),
  'Ихфа': ('Ихфа', 'Ikhfa'),
  'Мим сакина': ('Сукунды мим', 'Mim sakinah'),
  'Мадд табии': ('Табиғи мәдд', 'Madd tabi‘i'),
  'Муттасиль и мунфасиль': ('Муттасыл және мунфасыл', 'Muttasil and munfasil'),
  'Мадд лязим': ('Ләзім мәдд', 'Madd lazim'),
  'Мадд арид': ('Арид мәдд', 'Madd ‘arid'),
  'Лям в имени Аллаха': ('Алла есіміндегі ләм', 'Lam in the name of Allah'),
  'Солнечные и лунные': ('Күн және ай әріптері', 'Sun and moon letters'),
  'Буква ر': ('ر әрпі', 'The letter ر'),
  'Остановка и знаки вакфа': (
    'Тоқтау және уақф белгілері',
    'Pausing and waqf signs'
  ),
  'Итоговая практика': ('Қорытынды жаттығу', 'Final practice'),
};
