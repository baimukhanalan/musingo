import 'dart:convert';
import 'dart:io';

import 'package:muslingo/services/lesson_data.dart';
import 'package:muslingo/services/lesson_video_catalog.dart';

/// Export the actual strengthened lesson text, not source-code fragments.
void main() {
  final strings = <String>{};
  final phoneticTerms = <String>{};
  final nativeVideoStrings = <String, Set<String>>{};
  void add(String? value) {
    if (value != null &&
        value.trim().isNotEmpty &&
        RegExp(r'[A-Za-zА-Яа-яЁё]').hasMatch(value)) {
      strings.add(value);
    }
  }

  final courses = LessonData.getCourses();
  for (final course in courses) {
    add(course.title);
    add(course.description);
    for (final lesson in course.lessons) {
      add(lesson.title);
      add(lesson.subtitle);
      for (final step in lesson.steps) {
        if (step.transliteration?.isNotEmpty == true) {
          phoneticTerms.add(step.transliteration!
              .split(RegExp(r' с | твёрдо| мягко| глубоко'))
              .first);
        }
        if (step.question == 'Какое чтение точнее передаёт услышанное слово?') {
          phoneticTerms.addAll(step.answers!.map((value) =>
              value.split(RegExp(r' с | твёрдо| мягко| глубоко')).first));
        }
        add(step.russianText);
        add(step.question);
        add(step.explanation);
        for (final value in [
          ...?step.answers,
          ...step.orderTokens,
          ...step.extraTokens
        ]) {
          add(value);
        }
        for (final pair in step.matchPairs) {
          add(pair.prompt);
          add(pair.answer);
        }
      }
    }
  }
  final document = jsonDecode(
      File('docs/content/approved-570-curriculum-plan.json')
          .readAsStringSync()) as Map;
  const fields = [
    'strand',
    'module_title',
    'learning_objective',
    'difficulty',
    'prerequisite',
    'source_locator',
    'review_status',
    'video_need',
    'speaker_domain'
  ];
  for (final module in document['modules'] as List) {
    for (final field in fields) {
      add(module[field] as String?);
    }
  }
  for (final video in LessonVideoCatalog.curated.entries) {
    for (final text in [
      video.title,
      video.topic,
      video.transcript,
      video.speaker.role,
      video.rights.label
    ]) {
      add(text);
      (nativeVideoStrings[video.languageCode] ??= {}).add(text);
    }
  }
  final extraFiles = [
    File('lib/models/learning_profile.dart'),
    File('lib/services/coach_service.dart'),
    ...Directory('lib/screens/coach')
        .listSync()
        .whereType<File>()
        .where((file) => file.path.endsWith('.dart')),
  ];
  final literal = RegExp(r"'((?:\\.|[^'\\])*)'");
  for (final file in extraFiles) {
    for (final match in literal.allMatches(file.readAsStringSync())) {
      final text = match.group(1)!;
      if (!text.contains(r'$') && RegExp(r'[А-Яа-яЁё]').hasMatch(text)) {
        add(text.replaceAll(r'\n', '\n').replaceAll(r"\'", "'"));
      }
    }
  }
  stdout.write(jsonEncode({
    'lessonCount':
        courses.fold<int>(0, (sum, course) => sum + course.lessons.length),
    'moduleCount': (document['modules'] as List).length,
    'strings': strings.toList()..sort(),
    'phoneticTerms': phoneticTerms.toList()..sort(),
    'nativeVideoStrings': nativeVideoStrings
        .map((locale, values) => MapEntry(locale, values.toList()..sort())),
  }));
}
