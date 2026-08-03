import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/hafiz_progress.dart';

void main() {
  test('low score returns the verse tomorrow', () {
    final now = DateTime(2026, 8, 3, 9);
    final progress = HafizProgress.initial(
      surahNumber: 112,
      surahName: 'Al-Ikhlas',
      verseNumber: 1,
      globalVerseNumber: 6222,
      score: 52,
      repetitions: 3,
      reviewedAt: now,
    );

    expect(progress.nextReviewAt, now.add(const Duration(days: 1)));
    expect(progress.masteryLabel, 'Начато');
  });

  test('mastery grows and long repetition interval unlocks', () {
    final now = DateTime(2026, 8, 3, 9);
    final initial = HafizProgress.initial(
      surahNumber: 112,
      surahName: 'Al-Ikhlas',
      verseNumber: 1,
      globalVerseNumber: 6222,
      score: 88,
      repetitions: 6,
      reviewedAt: now,
    );
    final reviewed = initial.reviewed(
      score: 96,
      addedRepetitions: 6,
      reviewedAt: now.add(const Duration(days: 3)),
    );

    expect(reviewed.bestScore, 96);
    expect(reviewed.mastery, greaterThan(initial.mastery));
    expect(
      reviewed.nextReviewAt,
      now.add(const Duration(days: 3 + 14)),
    );
  });
}
