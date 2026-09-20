import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/services/lesson_data.dart';
import 'package:muslingo/services/quran_audio_sources.dart';

void main() {
  test('both mirrors match every one of the 6236 canonical verse addresses',
      () {
    final lines =
        File('assets/data/quran-uthmani-tanzil.txt').readAsLinesSync();
    var global = 0;
    for (final line in lines) {
      final match = RegExp(r'^(\d+)\|(\d+)\|').firstMatch(line);
      if (match == null) continue;
      global++;
      final chapter = match[1]!.padLeft(3, '0');
      final verse = match[2]!.padLeft(3, '0');
      expect(quranAudioSources(global), [
        'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$global.mp3',
        'https://everyayah.com/data/Alafasy_128kbps/$chapter$verse.mp3',
      ]);
    }
    expect(global, 6236);
  });

  test('all lesson ayahs have two independent playable-source addresses', () {
    final numbers = LessonData.getCourses()
        .expand((course) => course.lessons)
        .expand((lesson) => lesson.steps)
        .map((step) => step.quranGlobalAyahNumber)
        .whereType<int>()
        .toSet();
    expect(numbers, hasLength(606));
    for (final number in numbers) {
      final sources = quranAudioSources(number).map(Uri.parse).toList();
      expect(sources.map((uri) => uri.host).toSet(), hasLength(2));
      expect(sources.every((uri) => uri.scheme == 'https'), isTrue);
      expect(sources.any((uri) => uri.path.contains('/api/')), isFalse);
    }
  });

  test('rejects invalid ayah addresses rather than playing a different verse',
      () {
    for (final number in [-1, 0, 6237]) {
      expect(() => quranAudioSources(number), throwsRangeError);
    }
  });
}
