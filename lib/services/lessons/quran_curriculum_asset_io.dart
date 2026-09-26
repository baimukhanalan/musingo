import 'dart:io';

import 'quran_full_curriculum.dart';

/// Standalone Dart inventory tools run at the repository root.
Future<String> loadQuranCurriculumAsset() =>
    File(QuranFullCurriculum.assetPath).readAsString();
