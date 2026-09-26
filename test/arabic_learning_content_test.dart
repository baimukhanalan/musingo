import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/curriculum_audio.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/arabic_learning_localization.dart';
import 'package:muslingo/services/curriculum_repository.dart';
import 'package:muslingo/services/learning_title_localization.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/services/lesson_data.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setUpAll(() async {
    await LessonData.initialize();
    await LessonContentLocalization.load();
  });
  final cyrillic = RegExp(r'[А-Яа-яЁё]');
  final arabic = RegExp(r'[\u0600-\u06ff]');

  test('Arabic instructions cover all 902 units without rewriting 6236 ayahs',
      () {
    final originals = LessonData.quranCourse.lessons
        .where((lesson) => lesson.id.startsWith('q_full_'))
        .toList();
    expect(originals, hasLength(902));
    var ayahs = 0;
    for (final original in originals) {
      final translated =
          LessonContentLocalization.localizeLesson(original, 'ar');
      expect(translated.id, original.id);
      expect(translated.order, original.order);
      expect(translated.xpReward, original.xpReward);
      expect(translated.sourceUrl, original.sourceUrl);
      expect(cyrillic.hasMatch('${translated.title} ${translated.subtitle}'),
          isFalse);
      expect(arabic.hasMatch(translated.title), isTrue);
      expect(
          LessonContentLocalization.hasCompleteLessonTranslation(
              original, 'ar'),
          isTrue);
      for (var i = 0; i < original.steps.length; i++) {
        final before = original.steps[i];
        final after = translated.steps[i];
        for (final text in [
          after.russianText,
          after.question,
          after.explanation
        ]) {
          if (text != null) {
            expect(cyrillic.hasMatch(text), isFalse,
                reason: '${original.id}: $text');
            expect(arabic.hasMatch(text), isTrue, reason: original.id);
          }
        }
        expect(after.arabicText, before.arabicText);
        expect(after.quranGlobalAyahNumber, before.quranGlobalAyahNumber);
        expect(after.answers, before.answers);
        expect(after.correctAnswerIndex, before.correctAnswerIndex);
        expect(after.orderTokens, before.orderTokens);
        expect(after.sourceRefs, before.sourceRefs);
        if (after.quranGlobalAyahNumber != null) ayahs++;
      }
      expect(LessonContentLocalization.localizeLesson(translated, 'ru'),
          same(original));
    }
    expect(ayahs, 6236);
  });

  test(
      'Arabic metadata covers all 570 topics but never claims full lesson translation',
      () async {
    final modules = await CurriculumRepository.load();
    expect(modules, hasLength(570));
    for (final module in modules) {
      final localized = LessonContentLocalization.localizeModule(module, 'ar');
      expect(arabic.hasMatch(localized.title), isTrue, reason: module.id);
      expect(arabic.hasMatch(localized.objective), isTrue, reason: module.id);
      expect(
          cyrillic.hasMatch(
              '${localized.title} ${localized.objective} ${localized.prerequisite}'),
          isFalse);
      expect(localized.id, module.id);
      expect(localized.sequence, module.sequence);
      expect(localized.sourceLocator, module.sourceLocator);
      expect(localized.rightsStatus, module.rightsStatus);
      expect(localized.publicationStatus, module.publicationStatus);
      final outline = CurriculumAudioOutline.fromModule(module, 'ar');
      expect(outline.sections, hasLength(4));
      expect(outline.sections.every(arabic.hasMatch), isTrue);
      expect(outline.sections.any(cyrillic.hasMatch), isFalse);
      expect(outline.sections.first, contains(localized.objective));
      expect(outline.sections.join(' '), isNot(contains('https://')));
    }
    final bytes = await rootBundle.load('assets/data/learning_ar.json');
    final doc = jsonDecode(utf8.decode(
            bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes)))
        as Map;
    expect(doc['reviewed'], isFalse);
    expect(doc['coverage']['moduleTitles'], 570);
    expect(doc['coverage']['moduleObjectives'], 570);
    expect(doc['coverage']['legacyGuidedLessonBodiesComplete'], isFalse);
  });

  test(
      'Arabic controlled legacy headings preserve terminology and translation limits',
      () {
    for (final course in LessonData.getCourses()) {
      for (final lesson in course.lessons
          .where((lesson) => !lesson.id.startsWith('q_full_'))) {
        expect(
            LessonContentLocalization.hasCompleteLessonTranslation(
                lesson, 'ar'),
            isFalse);
        if (course.type == CourseType.quran ||
            course.type == CourseType.tajwid) {
          final title = localizeLearningTitle(lesson.title, course.type, 'ar');
          expect(title, isNotNull, reason: lesson.title);
          expect(cyrillic.hasMatch(title!), isFalse);
          expect(arabic.hasMatch(title), isTrue);
        }
      }
    }
    expect(localizeArabicLearningText('Дад', 'ar'), 'الضاد');
    expect(localizeArabicLearningText('Ха', 'ar'), 'الحاء');
    expect(localizeArabicLearningText('Ха лёгкая', 'ar'), 'الهاء');
    expect(LessonContentLocalization.transliterationFor('Бисмиллях', 'ar'),
        isNull);
    expect(
        LessonContentLocalization.translateText(
            'Русская строка вне перевода', 'ar'),
        'Русская строка вне перевода');
  });

  test('first fifteen Arabic reading lessons have Arabic-facing steps', () {
    final originals = LessonData.arabicCourse.lessons
        .where((lesson) => RegExp(r'^a(?:[1-9]|1[0-5])$').hasMatch(lesson.id))
        .toList();
    expect(originals, hasLength(15));
    for (final original in originals) {
      final localized =
          LessonContentLocalization.localizeLesson(original, 'ar');
      expect(localized.id, original.id);
      expect(localized.steps.length, original.steps.length);
      final visibleText = <String>[
        localized.title,
        localized.subtitle,
        for (final step in localized.steps) ...[
          if (step.russianText != null) step.russianText!,
          if (step.question != null) step.question!,
          if (step.explanation != null) step.explanation!,
          ...?step.answers,
          for (final pair in step.matchPairs) ...[pair.prompt, pair.answer],
        ],
      ];
      for (final value in visibleText) {
        expect(cyrillic.hasMatch(value), isFalse,
            reason: '${original.id}: $value');
      }
      for (var index = 0; index < original.steps.length; index++) {
        expect(localized.steps[index].arabicText,
            original.steps[index].arabicText);
        expect(localized.steps[index].correctAnswerIndex,
            original.steps[index].correctAnswerIndex);
        expect(localized.steps[index].sourceRefs,
            original.steps[index].sourceRefs);
      }
    }
  });

  test('qaf and kaf remain distinct in early letter lessons', () {
    final original = LessonData.arabicCourse.lessons
        .singleWhere((lesson) => lesson.id == 'a11');
    final localized = LessonContentLocalization.localizeLesson(original, 'ar');
    final matching = localized.steps
        .singleWhere((step) => step.type == LessonStepType.matching);
    expect(matching.matchPairs[1].prompt, 'ق');
    expect(matching.matchPairs[1].answer, 'القاف');
    expect(matching.matchPairs[2].prompt, 'ك');
    expect(matching.matchPairs[2].answer, 'الكاف');
    expect(matching.matchPairs[1].answer,
        isNot(matching.matchPairs[2].answer));
  });

  testWidgets('legacy Arabic notice appears at entry only, never on every step',
      (tester) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    expect(state.isInitialized, isTrue);
    await state.loginAsGuest();
    await state.setLocale(AppLocale.ar);
    const fixture = Lesson(
        id: 'r1',
        title: 'Основы ислама',
        subtitle: '',
        course: CourseType.rules,
        order: 1,
        steps: [
          LessonStep(type: LessonStepType.text, russianText: 'Первый шаг'),
          LessonStep(type: LessonStepType.text, russianText: 'Второй шаг'),
        ]);
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(
            home: Directionality(
                textDirection: TextDirection.rtl,
                child: LessonScreen(lesson: fixture)))));
    await tester.pumpAndSettle();
    final notice =
        find.byKey(const ValueKey('arabic-lesson-translation-notice'));
    expect(notice, findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('lesson_primary_action')));
    await tester.pumpAndSettle();
    expect(notice, findsNothing);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    state.dispose();
  });
}
