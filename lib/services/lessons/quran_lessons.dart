import '../../models/lesson.dart';
import 'juz_mujadila_lessons.dart';
import 'juz_tabarak_lessons.dart';
import 'quran_foundation_lessons.dart';
import 'quran_juz_amma_lessons.dart';
import 'quran_short_surah_lessons.dart';

final List<Lesson> quranLessons = [
  ...quranFoundationLessons,
  ...quranShortSurahLessons,
  ...quranJuzAmmaLessons,
  ...juzTabarakLessons,
  ...juzMujadilaLessons,
];
