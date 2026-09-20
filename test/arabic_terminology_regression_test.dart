import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/arabic_learning_localization.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/services/lesson_data.dart';
import 'package:muslingo/services/lessons/arabic_extension_lessons.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(LessonContentLocalization.load);

  test('right-joining letters only show isolated and final forms', () {
    const rightJoining = {'ا', 'د', 'ذ', 'ر', 'ز', 'و'};
    for (final lesson in arabicExtensionLessons) {
      if (!lesson.title.endsWith('Форма в слове')) continue;
      final matching = lesson.steps
          .firstWhere((step) => step.type == LessonStepType.matching);
      final letter = matching.matchPairs.first.prompt;
      final forms = lesson.steps.first.arabicText!.split('  ');
      if (rightJoining.contains(letter)) {
        expect(forms, [letter, 'ـ$letter'], reason: lesson.id);
      } else {
        expect(forms, [letter, '$letterـ', 'ـ$letterـ', 'ـ$letter'],
            reason: lesson.id);
      }
      // Form rendering must not change grading or the spoken word.
      expect(matching.matchPairs.first.answer, lesson.title.split(':').first);
      expect(
          lesson.steps
              .where((step) => step.type == LessonStepType.speak)
              .single
              .effectiveSpeechTarget,
          lesson.steps
              .where((step) => step.type == LessonStepType.audio)
              .single
              .arabicText);
    }
  });

  for (final locale in ['kk', 'en']) {
    test('$locale: all 78 extension titles and letter names are terminology',
        () {
      expect(arabicExtensionLessons, hasLength(78));
      for (final original in arabicExtensionLessons) {
        final localized =
            LessonContentLocalization.localizeLesson(original, locale);
        final sourceName = original.title.split(':').first;
        final name = localizeArabicLearningText(sourceName, locale)!;
        expect(localized.title, startsWith('$name: '), reason: original.id);
        expect(localized.title, isNot(contains('Dud')));
        expect(localized.title, isNot(contains('Әкем')));
        expect(localized.title, isNot(contains('For hard')));
        final matching = localized.steps
            .firstWhere((step) => step.type == LessonStepType.matching);
        expect(matching.matchPairs.first.answer, name, reason: original.id);
        final intro = localized.steps.first.russianText!;
        expect(intro, isNot(contains('Dud')));
        expect(intro, isNot(contains('Әкем')));
      }
    });

    test('$locale: combined reasoning answers retain the same letter names',
        () {
      final source = LessonData.getCourses()
          .expand((course) => course.lessons)
          .singleWhere((lesson) => lesson.id == 'a65');
      final localized =
          LessonContentLocalization.localizeLesson(source, locale);
      final challenge = localized.steps
          .singleWhere((step) => step.id == 'a65_logic_challenge');
      for (final answer in challenge.answers!) {
        expect(answer, isNot(contains('Dud')));
        expect(answer, isNot(contains('Әкем')));
      }
      expect(challenge.answers![challenge.correctAnswerIndex!],
          contains(locale == 'kk' ? 'Дад' : 'Dad'));
    });
  }

  test('ordinary prose containing similar fragments is not rewritten', () {
    expect(localizeArabicLearningText('Сад весной', 'kk'), isNull);
    expect(localizeArabicLearningText('Такая практика полезна', 'en'), isNull);
  });

  test('the articulation objective keeps letter names, not gardens and rabbits',
      () {
    const source = 'Слышать характеристику в син, сад и зай без преувеличения.';
    final result = LessonContentLocalization.translateText(source, 'kk');
    expect(result, contains('Син, Сад және Зай'));
    expect(result, isNot(contains('қоян')));
    expect(result, isNot(contains('бақ')));
  });
}
