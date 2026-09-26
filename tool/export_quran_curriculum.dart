import 'dart:convert';
import 'dart:io';

import 'package:muslingo/services/lessons/quran_full_curriculum.dart';
import 'package:muslingo/services/lessons/quran_lessons.dart';

/// Emits source-derived metadata only. No Arabic text or generated theology.
/// Run from the repository root. --check verifies the committed server input.
void main(List<String> arguments) {
  final source = File(QuranFullCurriculum.assetPath).readAsStringSync();
  final curriculum = QuranFullCurriculum.fromCanonicalText(source);
  // Construct once here as well: catches unsolvable source-recall exercises.
  curriculum.lessons();
  final manifest = <String, dynamic>{
    ...curriculum.manifest,
    'legacyLessons': [
      for (final lesson in quranLessons)
        {
          'id': lesson.id,
          'xpReward': lesson.xpReward,
          'stepCount': lesson.steps.length,
          'globalAyahNumbers': (lesson.steps
              .map((step) => step.quranGlobalAyahNumber)
              .whereType<int>()
              .toSet()
              .toList()
            ..sort()),
        },
    ],
  };
  if (arguments.contains('--check')) {
    final saved =
        jsonDecode(File(QuranFullCurriculum.manifestPath).readAsStringSync());
    if (jsonEncode(saved) != jsonEncode(manifest)) {
      stderr.writeln('Quran curriculum manifest is out of date.');
      exitCode = 1;
      return;
    }
    stdout.writeln('Quran curriculum manifest matches canonical source.');
    return;
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(manifest));
}
