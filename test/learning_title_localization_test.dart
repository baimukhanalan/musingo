import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/learning_title_localization.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/services/lesson_data.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(LessonContentLocalization.load);

  for (final locale in ['kk', 'en']) {
    test(
        '$locale: all 100 Quran and 36 Tajwid titles have controlled terminology',
        () {
      final courses = LessonData.getCourses();
      for (final type in [CourseType.quran, CourseType.tajwid]) {
        final lessons =
            courses.singleWhere((course) => course.type == type).lessons;
        expect(lessons, hasLength(type == CourseType.quran ? 100 : 36));
        for (final source in lessons) {
          final controlled = localizeLearningTitle(source.title, type, locale);
          expect(controlled, isNotNull,
              reason: '${source.id}: ${source.title}');
          final localized =
              LessonContentLocalization.localizeLesson(source, locale);
          expect(localized.title, controlled);
          expect(localized.id, source.id);
          expect(localized.sourceUrl, source.sourceUrl);
          if (source.title.startsWith('Закрепление: ')) {
            expect(localized.title,
                startsWith(locale == 'kk' ? 'Бекіту: ' : 'Review: '));
          }
          for (var index = 0; index < source.steps.length; index++) {
            expect(localized.steps[index].arabicText,
                source.steps[index].arabicText);
            expect(localized.steps[index].correctAnswerIndex,
                source.steps[index].correctAnswerIndex);
          }
        }
      }
    });
  }

  test('Ad-Duha remains a surah name, including review and language changes',
      () {
    final source = LessonData.getCourses()
        .expand((course) => course.lessons)
        .singleWhere((lesson) => lesson.title == 'Закрепление: Ад-Духа');
    final kazakh = LessonContentLocalization.localizeLesson(source, 'kk');
    expect(kazakh.title, 'Бекіту: Әд-Духа');
    final english = LessonContentLocalization.localizeLesson(kazakh, 'en');
    expect(english.title, 'Review: Ad-Dhuhaa');
    expect(LessonContentLocalization.localizeLesson(english, 'ru').title,
        source.title);
    expect(
        localizeLearningTitle('Закрепление: Аль-Аля', CourseType.quran, 'en'),
        "Review: Al-A'laa");
    expect(
        localizeLearningTitle('Закрепление: Аш-Шамс', CourseType.quran, 'kk'),
        'Бекіту: Аш-Шамс');
  });

  test('madd and throat headings do not turn into mud or food', () {
    expect(localizeLearningTitle('Полость рта и мадд', CourseType.tajwid, 'kk'),
        'Ауыз қуысы және мәдд');
    for (final title in [
      'Глубокая часть горла',
      'Средняя часть горла',
      'Верхняя часть горла'
    ]) {
      expect(localizeLearningTitle(title, CourseType.tajwid, 'kk'),
          startsWith('Жұтқыншақтың '));
    }
  });

  test('guided headings reuse source-verified Kazakh reader names', () {
    const names = {
      'Аль-Фатиха: начало': 'Фатиха: басталуы',
      'Аль-Бакара 1-2': 'Бақара 1–2',
      'Аль-Мульк': 'Мүлік',
      'Аль-Мурсалят': 'Мурсәләт',
      'Ан-Наба, часть 2': 'Нәба, 2-бөлім',
      'Ат-Таквир': 'Тәкуир',
      'Аз-Зальзаля': 'Зілзала',
      'Ат-Такасур': 'Тәкәсур',
      'Аль-Кафирун': 'Кәфирун',
      'Аль-Ихлас': 'Ықылас',
      'Аль-Фалак': 'Фәлақ',
      'Ан-Нас': 'Нас',
    };
    for (final entry in names.entries) {
      expect(localizeLearningTitle(entry.key, CourseType.quran, 'kk'),
          entry.value);
    }
  });

  test('the title layer does not rewrite arbitrary prose or other courses', () {
    expect(localizeLearningTitle('Ад', CourseType.quran, 'kk'), isNull);
    expect(localizeLearningTitle('Ад-Духа', CourseType.arabic, 'kk'), isNull);
    expect(localizeLearningTitle('Полость рта и мадд', CourseType.rules, 'kk'),
        isNull);
  });
}
