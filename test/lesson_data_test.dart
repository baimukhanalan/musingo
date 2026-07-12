import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/services/lesson_data.dart';

void main() {
  test('Islam foundations course has seven intro lessons before surah study', () {
    final rules = LessonData.rulesCourse.lessons;

    expect(rules, hasLength(7));
    expect(rules.first.status, LessonStatus.available);
    expect(
      rules.map((lesson) => lesson.title),
      containsAllInOrder([
        'Вера и намерение',
        'Что такое Коран',
        'Пророк Мухаммад',
        'Молитва',
        'Чистота и адаб',
        'Как понимать перевод',
        'Как учить суры',
      ]),
    );
    expect(
      rules.every((lesson) => lesson.steps.any(
            (step) => step.type == LessonStepType.question,
          )),
      isTrue,
    );
  });

  test('speech steps expose production scoring targets', () {
    final quranSpeak = LessonData.quranCourse.lessons
        .expand((lesson) => lesson.steps)
        .firstWhere((step) => step.type == LessonStepType.speak);
    final arabicSpeak = LessonData.arabicCourse.lessons
        .expand((lesson) => lesson.steps)
        .firstWhere((step) => step.type == LessonStepType.speak);

    expect(quranSpeak.effectiveSpeechTarget, isNotEmpty);
    expect(quranSpeak.effectivePassScore, 75);
    expect(arabicSpeak.effectiveSpeechTarget, isNotEmpty);
    expect(arabicSpeak.effectivePassScore, 60);
  });

  test('Quran listening lesson audio is mapped to exact unique ayahs', () {
    final audioSteps = LessonData.quranCourse.lessons
        .expand((lesson) => lesson.steps)
        .where((step) => step.type == LessonStepType.audio)
        .toList(growable: false);

    expect(audioSteps, isNotEmpty);
    expect(
      audioSteps.every((step) => step.quranGlobalAyahNumber != null),
      isTrue,
    );

    final audioAyahs = audioSteps
        .map((step) => step.quranGlobalAyahNumber)
        .toList(growable: false);
    expect(audioAyahs.toSet(), hasLength(audioAyahs.length));

    expect(audioAyahs, containsAll(<int>[1, 8, 6222, 6226, 6231]));
  });
}
