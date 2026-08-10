import 'package:flutter/material.dart';

/// Программа Академии — это готовый учебный маршрут, собранный из УЖЕ
/// существующих уроков LessonData по их id. Академия не создаёт новых уроков
/// и не генерирует религиозные тексты: она лишь выстраивает проверенный
/// контент в понятную последовательность («Аль-Фатиха целиком», «Алфавит с
/// нуля» и т.д.). Все id ниже обязаны существовать в LessonData — иначе урок
/// просто не найдётся при отображении программы.
class AcademyProgram {
  final String id;
  final String title;
  final String description;
  final IconData icon;
  final List<String> lessonIds;

  const AcademyProgram({
    required this.id,
    required this.title,
    required this.description,
    required this.icon,
    required this.lessonIds,
  });

  int get lessonCount => lessonIds.length;

  /// Ориентировочная длительность: один урок ≈ 5 минут (как в плане на день).
  int get estimatedMinutes => lessonCount * 5;
}

class AcademyData {
  static const List<AcademyProgram> programs = [
    // Сура Аль-Фатиха от первого до последнего аята (уроки q_fatiha_1..4).
    AcademyProgram(
      id: 'ac_fatiha',
      title: 'Сура Аль-Фатиха',
      description: '«Открывающая» от первого аята до прямого пути',
      icon: Icons.menu_book_rounded,
      lessonIds: ['q_fatiha_1', 'q_fatiha_2', 'q_fatiha_3', 'q_fatiha_4'],
    ),
    // Три суры на «Куль» — короткие суры защиты.
    AcademyProgram(
      id: 'ac_three_quls',
      title: 'Три «Куль»',
      description: 'Аль-Ихлас, Аль-Фалак и Ан-Нас — короткие суры защиты',
      icon: Icons.shield_moon_rounded,
      lessonIds: ['q_ikhlas_1', 'q_falaq_1', 'q_nas_1'],
    ),
    // Арабский алфавит и чтение с нуля (курс arabic, уроки a1..a6).
    AcademyProgram(
      id: 'ac_arabic_alphabet',
      title: 'Арабский алфавит с нуля',
      description: 'Буквы, огласовки и первые слоги шаг за шагом',
      icon: Icons.translate_rounded,
      lessonIds: ['a1', 'a2', 'a3', 'a4', 'a5', 'a6'],
    ),
    // Вводный блок основ ислама (курс rules, уроки r1..r7).
    AcademyProgram(
      id: 'ac_islam_basics',
      title: 'Основы ислама за неделю',
      description: 'Семь вводных уроков перед изучением сур',
      icon: Icons.account_balance_rounded,
      lessonIds: ['r1', 'r2', 'r3', 'r4', 'r5', 'r6', 'r7'],
    ),
    // Короткие суры из конца Корана (Джуз Амма).
    AcademyProgram(
      id: 'ac_short_surahs',
      title: 'Короткие суры',
      description: 'От Аль-Аср до Аль-Масад — восемь коротких сур',
      icon: Icons.auto_stories_rounded,
      lessonIds: [
        'q_asr_1',
        'q_fil_1',
        'q_quraysh_1',
        'q_maun_1',
        'q_kawthar_1',
        'q_kafirun_1',
        'q_nasr_1',
        'q_masad_1',
      ],
    ),
  ];
}
