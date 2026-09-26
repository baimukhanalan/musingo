import 'package:muslingo/models/curriculum_module.dart';
import 'package:muslingo/models/lesson.dart';

/// Additional full-language/full-library UI journeys are opt-in. Every Russian
/// guided lesson remains in the default run, including the 902 complete-Quran
/// units added by LessonData.initialize() (1,148 guided lessons in total).
const exhaustiveAudit = bool.fromEnvironment('MUSLINGO_EXHAUSTIVE_AUDIT');

List<int> representativeIndices<T>(List<T> items, int Function(T) textLength) {
  if (items.isEmpty) return const [];
  var longest = 0;
  for (var index = 1; index < items.length; index++) {
    if (textLength(items[index]) > textLength(items[longest])) longest = index;
  }
  return ({0, items.length ~/ 2, items.length - 1, longest}.toList()..sort());
}

List<int> lessonAuditIndices(List<Lesson> lessons, String locale,
    {bool exhaustive = exhaustiveAudit}) {
  if (locale == 'ru' || exhaustive) {
    return List.generate(lessons.length, (index) => index);
  }
  return representativeIndices(lessons, (lesson) {
    return lesson.title.length +
        lesson.subtitle.length +
        lesson.steps.fold<int>(0, (total, step) {
          return total +
              (step.russianText?.length ?? 0) +
              (step.question?.length ?? 0) +
              (step.explanation?.length ?? 0) +
              (step.answers?.join().length ?? 0) +
              step.matchPairs.fold<int>(0,
                  (sum, pair) => sum + pair.prompt.length + pair.answer.length);
        });
  });
}

List<int> moduleAuditIndices(List<CurriculumModule> modules,
    {bool exhaustive = exhaustiveAudit}) {
  if (exhaustive) return List.generate(modules.length, (index) => index);
  final byTrack = <String, List<int>>{};
  for (var index = 0; index < modules.length; index++) {
    byTrack.putIfAbsent(modules[index].track, () => []).add(index);
  }
  final result = <int>[];
  for (final track in byTrack.values) {
    result.addAll(representativeIndices(track, (index) {
      final module = modules[index];
      return module.title.length + module.objective.length;
    }).map((index) => track[index]));
  }
  return result..sort();
}
