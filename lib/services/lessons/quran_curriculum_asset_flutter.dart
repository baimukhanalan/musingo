import 'dart:convert';

import 'package:flutter/services.dart';

import 'quran_full_curriculum.dart';

Future<String> loadQuranCurriculumAsset() async {
  // loadString delegates large files to an isolate. Decode these bundled
  // bytes directly so initialization also completes in Flutter test zones.
  final bytes = await rootBundle.load(QuranFullCurriculum.assetPath);
  return utf8.decode(bytes.buffer.asUint8List(
    bytes.offsetInBytes,
    bytes.lengthInBytes,
  ));
}
