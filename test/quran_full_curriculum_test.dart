import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/services/lesson_data.dart';
import 'package:muslingo/services/lessons/quran_full_curriculum.dart';
import 'package:muslingo/services/lessons/quran_curriculum_asset_flutter.dart';
import 'package:muslingo/services/lessons/quran_lessons.dart';
import 'package:muslingo/services/quran_audio_sources.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late String canonicalText;
  late QuranFullCurriculum curriculum;
  late List<Lesson> lessons;
  late List<Lesson> legacyLessons;

  setUpAll(() async {
    legacyLessons = LessonData.quranCourse.lessons;
    canonicalText = await loadQuranCurriculumAsset();
    curriculum = QuranFullCurriculum.fromCanonicalText(canonicalText);
    lessons = curriculum.lessons();
    await LessonData.initialize();
    await LessonContentLocalization.load();
  });

  test('902 short units cover all 114 surahs and 6236 ayahs exactly once', () {
    expect(curriculum.units, hasLength(902));
    expect(curriculum.units.map((unit) => unit.surah).toSet(),
        List.generate(114, (index) => index + 1).toSet());
    final audio = lessons
        .expand((lesson) => lesson.steps)
        .where((step) => step.type == LessonStepType.audio)
        .toList(growable: false);
    expect(audio, hasLength(6236));
    expect(audio.map((step) => step.quranGlobalAyahNumber),
        List.generate(6236, (index) => index + 1));
    final source = const LineSplitter()
        .convert(canonicalText)
        .where((line) => RegExp(r'^\d+\|\d+\|').hasMatch(line))
        .map((line) => line.split('|').sublist(2).join('|'))
        .toList();
    for (var index = 0; index < audio.length; index++) {
      expect(audio[index].arabicText, source[index],
          reason: 'Global ayah ${index + 1} changed');
      final unit = curriculum.units.firstWhere((unit) =>
          index + 1 >= unit.ayahs.first.globalNumber &&
          index + 1 <= unit.ayahs.last.globalNumber);
      final ayah =
          unit.ayahs.firstWhere((ayah) => ayah.globalNumber == index + 1);
      expect(
          quranAudioSources(index + 1).last,
          endsWith('${ayah.surah.toString().padLeft(3, '0')}'
              '${ayah.number.toString().padLeft(3, '0')}.mp3'));
    }
    for (final unit in curriculum.units) {
      expect(unit.ayahs.map((ayah) => ayah.surah).toSet(), {unit.surah});
    }
  });

  test('duration is an explicit estimate, including practice, without clamping',
      () {
    final estimates = curriculum.units.map((unit) => unit.estimatedSeconds);
    expect(estimates.reduce((a, b) => a > b ? a : b), 366);
    expect(estimates.reduce((a, b) => a + b) / estimates.length, lessThan(420));
    for (final unit in curriculum.units) {
      expect(unit.estimatedSeconds,
          78 + (unit.wordCount * 2.2).ceil() + unit.ayahs.length * 6);
      expect(unit.estimatedSeconds, lessThanOrEqualTo(420), reason: unit.id);
      expect(unit.ayahs.length, lessThanOrEqualTo(12), reason: unit.id);
    }
    // The longest ayah is not clipped or split to satisfy the estimate.
    final debt =
        curriculum.units.singleWhere((unit) => unit.id == 'q_full_2_282_282');
    expect(debt.wordCount, 128);
    expect(debt.ayahs, hasLength(1));
    expect(debt.estimatedSeconds, 366);
    expect(debt.toLesson().steps, hasLength(5));
    expect(curriculum.manifest['durationModel']['kind'],
        'estimate_not_measured_audio_duration');
  });

  test('source-derived recall is solvable and does not generate interpretation',
      () {
    for (var index = 0; index < lessons.length; index++) {
      final lesson = lessons[index];
      final unit = curriculum.units[index];
      expect(lesson.steps.length, unit.stepCount);
      expect(lesson.steps.length, greaterThanOrEqualTo(5));
      expect(lesson.sourceUrl, 'https://tanzil.net');
      expect(lesson.steps.every((step) => step.sourceRefs.isNotEmpty), isTrue);
      expect(lesson.steps.first.russianText, contains('не перевод или тафсир'));
      final order = lesson.steps
          .singleWhere((step) => step.type == LessonStepType.wordOrder);
      expect(order.orderTokens.length, inInclusiveRange(2, 6));
      expect(
          unit.ayahs.any((ayah) =>
              ayah.words.take(order.orderTokens.length).join(' ') ==
              order.orderedAnswer),
          isTrue);
      expect(order.extraTokens, isEmpty);
      final recall = lesson.steps
          .singleWhere((step) => step.type == LessonStepType.question);
      final words = unit.ayahs.expand((ayah) => ayah.words).toSet();
      expect(recall.answers!.toSet(), hasLength(3));
      expect(recall.answers!.every(words.contains), isTrue);
      expect(
          unit.ayahs.any((ayah) =>
              ayah.words.last == recall.answers![recall.correctAnswerIndex!]),
          isTrue);
    }
  });

  test('legacy IDs, order, source content and rewards are preserved', () async {
    await Future.wait([LessonData.initialize(), LessonData.initialize()]);
    final current = LessonData.quranCourse.lessons;
    expect(legacyLessons, hasLength(100));
    expect(current, hasLength(1002));
    for (var index = 0; index < 100; index++) {
      expect(current[index].id, legacyLessons[index].id);
      expect(current[index].steps, same(legacyLessons[index].steps));
      expect(current[index].sourceUrl, legacyLessons[index].sourceUrl);
      expect(current[index].xpReward, legacyLessons[index].xpReward);
    }
    expect(
        current.map((lesson) => lesson.id).toSet(), hasLength(current.length));
    expect(current[100].id, 'q_full_1_1_7');
    expect(current[100].status, LessonStatus.available);
    expect(current.every((lesson) => lesson.status == LessonStatus.available),
        isTrue);
    expect(LessonData.getCourses().expand((course) => course.lessons),
        hasLength(1148));
  });

  test('server metadata is deterministic and carries no duplicate Arabic text',
      () {
    final manifest =
        jsonDecode(File(QuranFullCurriculum.manifestPath).readAsStringSync())
            as Map;
    for (final entry in curriculum.manifest.entries) {
      expect(manifest[entry.key], entry.value, reason: entry.key);
    }
    final legacy = manifest['legacyLessons'] as List;
    expect(legacy, hasLength(quranLessons.length));
    for (var index = 0; index < quranLessons.length; index++) {
      final lesson = quranLessons[index];
      final ayahs = lesson.steps
          .map((step) => step.quranGlobalAyahNumber)
          .whereType<int>()
          .toSet()
          .toList()
        ..sort();
      expect(legacy[index], {
        'id': lesson.id,
        'xpReward': lesson.xpReward,
        'stepCount': lesson.steps.length,
        'globalAyahNumbers': ayahs,
      });
    }
    expect(RegExp(r'[\u0621-\u064a]').hasMatch(jsonEncode(manifest)), isFalse);
    final again = QuranFullCurriculum.fromCanonicalText(canonicalText);
    expect(again.manifest, curriculum.manifest);
  });

  test(
      'all new lesson UI follows RU, KK and EN without changing source or grading',
      () {
    for (final locale in ['kk', 'en']) {
      for (final original in lessons) {
        final localized =
            LessonContentLocalization.localizeLesson(original, locale);
        expect(localized.title, isNot(original.title));
        expect(localized.subtitle, isNot(original.subtitle));
        expect(localized.id, original.id);
        expect(localized.sourceUrl, original.sourceUrl);
        for (var index = 0; index < original.steps.length; index++) {
          final before = original.steps[index];
          final after = localized.steps[index];
          if (before.russianText != null) {
            expect(after.russianText, isNot(before.russianText));
          }
          if (before.question != null) {
            expect(after.question, isNot(before.question));
          }
          if (before.explanation != null) {
            expect(after.explanation, isNot(before.explanation));
          }
          expect(after.arabicText, before.arabicText);
          expect(after.quranGlobalAyahNumber, before.quranGlobalAyahNumber);
          expect(after.orderTokens, before.orderTokens);
          expect(after.answers, before.answers);
          expect(after.correctAnswerIndex, before.correctAnswerIndex);
          expect(after.sourceRefs, before.sourceRefs);
          if (locale == 'en') {
            expect(
                RegExp(r'[А-Яа-яЁё]').hasMatch(
                    '${after.russianText ?? ''}${after.question ?? ''}${after.explanation ?? ''}'),
                isFalse);
          }
        }
        expect(
            identical(LessonContentLocalization.localizeLesson(localized, 'ru'),
                original),
            isTrue);
      }
    }
  });

  test('source parser rejects missing, duplicate and out-of-order ayahs', () {
    final rows = const LineSplitter().convert(canonicalText);
    expect(() => QuranFullCurriculum.fromCanonicalText(rows.skip(1).join('\n')),
        throwsFormatException);
    expect(
        () => QuranFullCurriculum.fromCanonicalText(
            '${rows.first}\n$canonicalText'),
        throwsFormatException);
    expect(
        () => QuranFullCurriculum.fromCanonicalText(
            canonicalText.replaceFirst('1|2|', '1|3|')),
        throwsFormatException);
    expect(
        () => QuranFullCurriculum.fromCanonicalText(
            canonicalText.replaceFirst('2|1|', '115|1|')),
        throwsFormatException);
  });

  test('guest progress restoration preserves the independent Quran entry',
      () async {
    SharedPreferences.setMockInitialValues({});
    Future<AppState> ready() async {
      final state = AppState();
      addTearDown(state.dispose);
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      expect(state.isInitialized, isTrue);
      return state;
    }

    final state = await ready();
    await state.loginAsGuest();
    Lesson find(AppState state, String id) => state
        .getCourse(CourseType.quran)!
        .lessons
        .singleWhere((lesson) => lesson.id == id);
    expect(find(state, 'q_full_1_1_7').status, LessonStatus.available);
    expect(find(state, 'q_full_2_1_10').status, LessonStatus.available);
    await state.completeLesson('q_full_1_1_7', 0);
    final restored = await ready();
    expect(find(restored, 'q_full_1_1_7').status, LessonStatus.completed);
    expect(find(restored, 'q_full_2_1_10').status, LessonStatus.available);
    expect(find(restored, 'q_full_2_11_18').status, LessonStatus.available);
    expect(find(restored, 'q_fatiha_1').status, LessonStatus.available);
    expect(find(restored, 'q_fatiha_2').status, LessonStatus.available);
  });
}
