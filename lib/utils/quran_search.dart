import '../models/quran.dart';

const quranRussianNames = <String>[
  'Аль-Фатиха',
  'Аль-Бакара',
  'Аль Имран',
  'Ан-Ниса',
  'Аль-Маида',
  'Аль-Анам',
  'Аль-Араф',
  'Аль-Анфаль',
  'Ат-Тауба',
  'Юнус',
  'Худ',
  'Юсуф',
  'Ар-Рад',
  'Ибрахим',
  'Аль-Хиджр',
  'Ан-Нахль',
  'Аль-Исра',
  'Аль-Кахф',
  'Марьям',
  'Та Ха',
  'Аль-Анбия',
  'Аль-Хадж',
  'Аль-Муминун',
  'Ан-Нур',
  'Аль-Фуркан',
  'Аш-Шуара',
  'Ан-Намль',
  'Аль-Касас',
  'Аль-Анкабут',
  'Ар-Рум',
  'Лукман',
  'Ас-Саджда',
  'Аль-Ахзаб',
  'Саба',
  'Фатыр',
  'Я Син',
  'Ас-Саффат',
  'Сад',
  'Аз-Зумар',
  'Гафир Аль-Мумин',
  'Фуссилат',
  'Аш-Шура',
  'Аз-Зухруф',
  'Ад-Духан',
  'Аль-Джасия',
  'Аль-Ахкаф',
  'Мухаммад',
  'Аль-Фатх',
  'Аль-Худжурат',
  'Каф',
  'Аз-Зарият',
  'Ат-Тур',
  'Ан-Наджм',
  'Аль-Камар',
  'Ар-Рахман',
  'Аль-Вакиа',
  'Аль-Хадид',
  'Аль-Муджадила',
  'Аль-Хашр',
  'Аль-Мумтахана',
  'Ас-Сафф',
  'Аль-Джумуа',
  'Аль-Мунафикун',
  'Ат-Тагабун',
  'Ат-Талак',
  'Ат-Тахрим',
  'Аль-Мульк',
  'Аль-Калам',
  'Аль-Хакка',
  'Аль-Мааридж',
  'Нух',
  'Аль-Джинн',
  'Аль-Муззаммиль',
  'Аль-Муддассир',
  'Аль-Кияма',
  'Аль-Инсан',
  'Аль-Мурсалят',
  'Ан-Наба',
  'Ан-Назиат',
  'Абаса',
  'Ат-Таквир',
  'Аль-Инфитар',
  'Аль-Мутаффифин',
  'Аль-Иншикак',
  'Аль-Бурудж',
  'Ат-Тарик',
  'Аль-Ала',
  'Аль-Гашия',
  'Аль-Фаджр',
  'Аль-Балад',
  'Аш-Шамс',
  'Аль-Лейл',
  'Ад-Духа',
  'Аш-Шарх',
  'Ат-Тин',
  'Аль-Алак',
  'Аль-Кадр',
  'Аль-Баййина',
  'Аз-Залзала',
  'Аль-Адият',
  'Аль-Кариа',
  'Ат-Такасур',
  'Аль-Аср',
  'Аль-Хумаза',
  'Аль-Филь',
  'Курайш',
  'Аль-Маун',
  'Аль-Каусар',
  'Аль-Кафирун',
  'Ан-Наср',
  'Аль-Масад',
  'Аль-Ихлас',
  'Аль-Фалак',
  'Ан-Нас',
];

bool quranChapterMatches(QuranChapterSummary chapter, String query) {
  final trimmed = query.trim();
  if (trimmed.isEmpty) return true;
  if (chapter.number.toString() == trimmed) return true;
  if (_normalizeArabic(chapter.arabicName)
      .contains(_normalizeArabic(trimmed))) {
    return true;
  }

  final needle = _normalizedVariants(trimmed);
  final russianName = chapter.number <= quranRussianNames.length
      ? quranRussianNames[chapter.number - 1]
      : '';
  final haystack = <String>{
    ..._normalizedVariants(chapter.latinName),
    ..._normalizedVariants(russianName),
  };
  return needle.any((part) =>
      part.isNotEmpty && haystack.any((candidate) => candidate.contains(part)));
}

Set<String> _normalizedVariants(String value) {
  final normalized =
      _transliterate(value.toLowerCase()).replaceAll(RegExp(r'[^a-z0-9]'), '');
  final withoutArticle = normalized.replaceFirst(
    RegExp(r'^(al|an|ar|as|ash|at|az|ad)'),
    '',
  );
  return {
    normalized,
    withoutArticle,
    _collapseVowels(normalized),
    _collapseVowels(withoutArticle),
  };
}

String _collapseVowels(String value) =>
    value.replaceAll(RegExp(r'([aeiou])\1+'), r'$1');

String _normalizeArabic(String value) => value
    .replaceAll(RegExp(r'[\u0610-\u061A\u064B-\u065F\u0670\u06D6-\u06ED]'), '')
    .replaceAll('ٱ', 'ا');

String _transliterate(String value) {
  const letters = <String, String>{
    'а': 'a',
    'ә': 'a',
    'б': 'b',
    'в': 'v',
    'г': 'g',
    'ғ': 'gh',
    'д': 'd',
    'е': 'e',
    'ё': 'e',
    'ж': 'zh',
    'з': 'z',
    'и': 'i',
    'й': 'y',
    'к': 'k',
    'қ': 'q',
    'л': 'l',
    'м': 'm',
    'н': 'n',
    'ң': 'n',
    'о': 'o',
    'ө': 'o',
    'п': 'p',
    'р': 'r',
    'с': 's',
    'т': 't',
    'у': 'u',
    'ұ': 'u',
    'ү': 'u',
    'ф': 'f',
    'х': 'kh',
    'һ': 'h',
    'ц': 'ts',
    'ч': 'ch',
    'ш': 'sh',
    'щ': 'sh',
    'ы': 'y',
    'і': 'i',
    'э': 'e',
    'ю': 'yu',
    'я': 'ya',
    'ъ': '',
    'ь': '',
  };
  final buffer = StringBuffer();
  for (final rune in value.runes) {
    final character = String.fromCharCode(rune);
    buffer.write(letters[character] ?? character);
  }
  return buffer.toString();
}
