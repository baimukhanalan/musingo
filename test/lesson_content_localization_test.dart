import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/curriculum_repository.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/services/lesson_data.dart';
import 'package:muslingo/services/learning_recommendation_localization.dart';
import 'package:muslingo/screens/curriculum_module_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(LessonContentLocalization.load);

  test('Kazakh daily ayah 85:10 preserves the source meaning of punishment',
      () async {
    // Khalifa Altai, Al-Buruj 85:10:
    // https://quranenc.com/en/browse/kazakh_altai/85
    final catalog =
        jsonDecode(await rootBundle.loadString('assets/data/learning_kk.json'))
            as Map;
    const source =
        'Тем, кто подвергал искушению верующих мужчин и женщин и не раскаялся, уготованы мучения в Геенне и мучения от обжигающего Огня';
    final text = (catalog['translations'] as Map)[source] as String;
    expect(text, contains('тозақтың азабы'));
    expect(text, contains('жапа беріп'));
    expect(text, isNot(contains('жәннәт')));
    expect(text, isNot(contains('жәннат')));
  });

  test('persisted onboarding recommendation switches from any saved language',
      () {
    const original =
        'Начни с Аль-Фатихи: разберем смысл по частям и свяжем перевод с арабскими словами.';
    final kazakh = LearningRecommendationLocalization.localize(original, 'kk');
    expect(kazakh, startsWith('Әл-Фатихадан баста:'));
    final english = LearningRecommendationLocalization.localize(kazakh, 'en');
    expect(english, startsWith('Start with Al-Fatiha:'));
    expect(
        LearningRecommendationLocalization.localize(english, 'ru'), original);
    expect(
        LearningRecommendationLocalization.localize(
            'My own learning plan', 'kk'),
        'My own learning plan');
    expect(LearningRecommendationLocalization.localize(null, 'en'), isNull);
  });

  for (final locale in ['kk', 'en']) {
    test('$locale covers every lesson and preserves grading and recitation',
        () async {
      final source = LessonData.getCourses();
      final translated =
          LessonContentLocalization.localizeCourses(source, locale);
      final catalog = jsonDecode(
              await rootBundle.loadString('assets/data/learning_$locale.json'))
          as Map;
      final dictionary = catalog['translations'] as Map;
      final mergedAnswers = <String>[];
      expect(
          translated.fold<int>(0, (sum, course) => sum + course.lessons.length),
          246);

      void covered(String? text) {
        if (text == null || !RegExp(r'[A-Za-zА-Яа-яЁё]').hasMatch(text)) return;
        expect(dictionary.containsKey(text), isTrue,
            reason: '$locale missing: $text');
        expect(dictionary[text], isNotEmpty);
        expect(dictionary[text], isNot(contains('ZXQ')));
        expect(dictionary[text], isNot(contains('ZNEWLINEZ')));
      }

      for (var c = 0; c < source.length; c++) {
        covered(source[c].title);
        covered(source[c].description);
        for (var l = 0; l < source[c].lessons.length; l++) {
          final original = source[c].lessons[l];
          final localized = translated[c].lessons[l];
          covered(original.title);
          covered(original.subtitle);
          expect(localized.id, original.id);
          expect(localized.status, original.status);
          expect(localized.steps.length, original.steps.length);
          expect(localized.sourceUrl, original.sourceUrl);
          for (var s = 0; s < original.steps.length; s++) {
            final before = original.steps[s];
            final after = localized.steps[s];
            for (final text in [
              before.russianText,
              before.question,
              before.explanation,
              ...?before.answers,
              ...before.orderTokens,
              ...before.extraTokens
            ]) {
              covered(text);
            }
            for (final pair in before.matchPairs) {
              covered(pair.prompt);
              covered(pair.answer);
            }
            expect(after.type, before.type);
            expect(after.correctAnswerIndex, before.correctAnswerIndex);
            expect(after.arabicText, before.arabicText);
            expect(after.effectiveSpeechTarget, before.effectiveSpeechTarget);
            expect(after.quranGlobalAyahNumber, before.quranGlobalAyahNumber);
            expect(after.sourceRefs, before.sourceRefs);
            expect(after.answers?.length, before.answers?.length);
            if (before.type == LessonStepType.speak) {
              expect(
                  RegExp(r'[\u0600-\u06ff]')
                      .hasMatch(before.effectiveSpeechTarget),
                  isTrue,
                  reason:
                      '${original.id}:$s must keep an Arabic recitation target, not an untranslated semantic response');
            }
            for (final pair in [
              [
                before.matchPairs.map((pair) => pair.prompt).toList(),
                after.matchPairs.map((pair) => pair.prompt).toList()
              ],
              [
                before.matchPairs.map((pair) => pair.answer).toList(),
                after.matchPairs.map((pair) => pair.answer).toList()
              ],
              [before.wordBank, after.wordBank],
            ]) {
              if (pair.first.toSet().length == pair.first.length &&
                  pair.last.toSet().length != pair.last.length) {
                mergedAnswers.add(
                    '${original.id}:$s matching/word bank ${pair.first} -> ${pair.last}');
              }
            }
            if (before.answers != null &&
                before.answers!.toSet().length == before.answers!.length) {
              if (after.answers!.toSet().length != after.answers!.length) {
                mergedAnswers.add(
                    '${original.id}:$s ${before.answers} -> ${after.answers}');
              }
            }
          }
          expect(
              identical(
                  LessonContentLocalization.localizeLesson(localized, 'ru'),
                  original),
              isTrue);
        }
      }
      expect(mergedAnswers, isEmpty,
          reason: '$locale distinct answers must stay distinct');
    });

    test('$locale localizes all 570 modules and assessment prompts', () async {
      final originals = await CurriculumRepository.load();
      final modules = originals
          .map((module) =>
              LessonContentLocalization.localizeModule(module, locale))
          .toList();
      expect(modules.length, 570);
      for (var i = 0; i < modules.length; i++) {
        final source = originals[i];
        final localized = modules[i];
        expect(localized.id, source.id);
        expect(localized.sequence, source.sequence);
        expect(localized.title,
            LessonContentLocalization.translateText(source.title, locale));
        expect(localized.objective, isNot(source.objective));
        final challenges = buildCurriculumChallenges(
            module: localized, allModules: modules, locale: locale);
        expect(challenges.length, 5);
        for (final challenge in challenges) {
          expect(challenge.options.length, 4);
          expect(challenge.options.toSet().length, 4);
          expect(challenge.correctIndex, inInclusiveRange(0, 3));
        }
      }
    });
  }

  test('localized cache preserves updated lesson progress', () {
    final source = LessonData.getCourses().first;
    final complete = Course(
        id: source.id,
        title: source.title,
        description: source.description,
        type: source.type,
        lessons: source.lessons
            .map((lesson) => lesson.copyWith(status: LessonStatus.completed))
            .toList());
    final localized = LessonContentLocalization.localizeCourse(complete, 'kk');
    expect(localized.completedLessons, source.lessons.length);
    expect(
        identical(localized,
            LessonContentLocalization.localizeCourse(complete, 'kk')),
        isTrue);
  });
}
