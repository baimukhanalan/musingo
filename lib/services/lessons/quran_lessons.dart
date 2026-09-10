import '../../models/lesson.dart';
import 'juz_mujadila_lessons.dart';
import 'juz_tabarak_lessons.dart';
import 'quran_foundation_lessons.dart';
import 'quran_juz_amma_lessons.dart';
import 'quran_short_surah_lessons.dart';

final List<Lesson> _coreQuranLessons = [
  ...quranFoundationLessons,
  ...quranShortSurahLessons,
  ...quranJuzAmmaLessons,
  ...juzTabarakLessons,
  ...juzMujadilaLessons,
];

final List<Lesson> quranLessons = [
  ..._coreQuranLessons,
  for (var index = 0; index < 32; index++)
    _masteryLesson(_coreQuranLessons[index], 69 + index),
];

Lesson _masteryLesson(Lesson source, int order) => Lesson(
      id: 'q_mastery_$order',
      title: 'Закрепление: ${source.title}',
      subtitle: 'Воспроизведение без очевидных подсказок',
      course: CourseType.quran,
      order: order,
      xpReward: 40,
      sourceUrl: source.sourceUrl,
      steps: [
        for (var index = 0; index < source.steps.length; index++)
          source.steps[index].copyWith(
            id: 'q_mastery_${order}_$index',
            question: source.steps[index].type == LessonStepType.question
                ? 'Восстанови оба факта по памяти. ${source.steps[index].question ?? ''}'
                : source.steps[index].question,
            explanation: source.steps[index].explanation ??
                'Сравни ответ с исходным аятом и его смыслом.',
          ),
      ],
    );
