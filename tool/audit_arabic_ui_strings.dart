// A deterministic source-copy audit. This does not exercise rendered layouts or
// translate user content. Run: dart run tool/audit_arabic_ui_strings.dart
import 'dart:io';

import 'package:muslingo/utils/arabic_ui_strings.dart';

final _englishLiterals = RegExp(
  r'''\ben:\s*((?:'(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*")(?:\s*(?:'(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*"))*)''',
  multiLine: true,
);
final _stringLiteral = RegExp(r''''(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*"''');
final _positionalLiterals = RegExp(
  r'''\btr\(\s*(?:'(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*")\s*,\s*(?:'(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*")\s*,\s*('(?:\\.|[^'\\])*'|"(?:\\.|[^"\\])*")\s*\)''',
  multiLine: true,
);

/// Literal `en:` arguments, including adjacent Dart string concatenation.
/// Interpolated strings are checked separately with representative values below.
Map<String, Set<String>> collectStaticUiCopy() {
  final copy = <String, Set<String>>{};
  for (final directory in ['lib/screens', 'lib/widgets']) {
    for (final file in Directory(directory).listSync(recursive: true)) {
      if (file is! File || !file.path.endsWith('.dart')) continue;
      final source = file.readAsStringSync();
      for (final match in [
        ..._englishLiterals.allMatches(source),
        ..._positionalLiterals.allMatches(source),
      ]) {
        final literals = match.group(1)!;
        if (RegExp(r'(?<!\\)\$').hasMatch(literals)) continue;
        final text = _stringLiteral.allMatches(literals).map((literal) {
          final quoted = literal.group(0)!;
          return quoted.substring(1, quoted.length - 1).replaceAllMapped(
                RegExp(r'\\(.)'),
                (escape) => switch (escape.group(1)) {
                  'n' => '\n',
                  'r' => '\r',
                  't' => '\t',
                  final value => value!,
                },
              );
        }).join();
        copy.putIfAbsent(text, () => <String>{}).add(file.path);
      }
    }
  }
  return copy;
}

const dynamicUiSamples = [
  '4 lessons',
  '5 modules',
  '12 verses',
  '~7 min',
  '8 d.',
  '7-day streak',
  'Complete 3 lessons',
  'Complete 4 rules modules',
  'Learn 5 verses',
  'Study 10 days in a row',
  '3 / 42 lessons',
  '2 of 570 modules mastered',
  '5 of 34 lessons completed',
  '35% hidden',
  '35% of the text hidden',
  '570 topic outlines · synthetic voice',
  'الفاتحة · memorization',
  'Ali added to friends',
  'Ali removed from friends',
  '4 learning steps',
  '+12 energy',
  'All 570',
  'All under control · next review: 28.09',
  'Continue ARB-004',
  'Correct answer: الحمد لله',
  'Correct order: الحمد لله',
  'Could not play the audio.',
  'DIAGNOSTIC 3 OF 5',
  'Day streak: 5. Open streak.',
  'Due today: 3 · weak spots: 4',
  'Every morning at 08:30',
  'Found: 2 · Queue: 12',
  'Found: 2',
  'Fragment 2 of 7',
  'Hafiz: 3 · to review: 2',
  'Learned: 3 · to review: 2',
  'Hearts lost: 2',
  'I repeated · 2/3',
  "I'm learning Quran on Muslingo — join and let's compete! My invite code: ABC123",
  'Juz 2 • page 23',
  'Juz 2',
  'Lives: 3. Restore a life.',
  'Match: 85%',
  'Memorize verse 5',
  'Next review: 28.09',
  'Open exact reference 2:255',
  'Recall the sound: ba',
  'Recognized: الحمد لله',
  'Review scheduled tomorrow',
  'Review verse 3. 80 percent mastered',
  'STEP 2 OF 5',
  'Score: 90%',
  'Section 2 of 4',
  'Stage 3 of 5',
  'Streak bonus: +50 XP!',
  'Think about the meaning: الحمد لله',
  'To bonus · 4 days',
  'Verse 2 of 7',
  'Verse 2: الحمد لله',
  'verse #255',
  "Weak spots: 3 — let's reinforce before you forget",
  'Will merge: 5 lessons, 12 memory items, and 3 Hafiz records.',
  "You have 3 scheduled reviews. Let's reinforce them first, then return to new material.",
  'Your starting level: 3',
  'الفاتحة, verse 2',
  'Reading · Listen',
  '3 days left',
  '1 day left',
  '12 completed lessons, review memory, Hafiz, and study stats. Name, email, password, tokens, and voice recordings are excluded.',
  '3 weak spots return tomorrow',
  'Understanding check · 1/2',
  'Understanding check · 2 challenges',
  'A good next step today is “الفاتحة”. I answer based on your progress and show sources for religious materials.',
  'Ali, happy birthday! 🎉 No pressure today: we can do a light review or simply talk.',
  'day in a row',
  'days in a row',
  'Identify the principle “الطهارة”, check it against the text, and apply it in a Muslingo exercise.',
  'A learner has studied “الطهارة”. Which observable outcome demonstrates understanding?',
];

void main() {
  final copy = collectStaticUiCopy();
  final missing = copy.keys.where((text) => !arabicUiStrings.containsKey(text));
  for (final text in missing) {
    stderr.writeln('Missing static Arabic: $text (${copy[text]!.join(', ')})');
  }
  final failures = <String>[];
  for (final sample in dynamicUiSamples) {
    final translated = translateArabicUi(ru: 'unused', en: sample);
    if (translated == sample ||
        !RegExp(r'[\u0600-\u06FF]').hasMatch(translated)) {
      failures.add(sample);
      stderr.writeln('Untranslated dynamic Arabic: $sample');
    }
  }
  if (copy.length < 650) {
    stderr.writeln(
        'Unexpectedly small copy corpus: ${copy.length}. Check extraction.');
    exitCode = 1;
  }
  if (missing.isNotEmpty || failures.isNotEmpty) exitCode = 1;
  stdout.writeln('Arabic UI: ${copy.length - missing.length}/${copy.length} '
      'static literals; ${dynamicUiSamples.length - failures.length}/'
      '${dynamicUiSamples.length} dynamic samples translated.');
  stdout
      .writeln('Unknown text is preserved; this audit does not certify lesson '
          'translations, model answers, runtime errors, or RTL layouts.');
}
