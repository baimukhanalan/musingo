class QuranChapterSummary {
  final int number;
  final String arabicName;
  final String latinName;
  final int ayahCount;
  final String revelationType;

  const QuranChapterSummary({
    required this.number,
    required this.arabicName,
    required this.latinName,
    required this.ayahCount,
    required this.revelationType,
  });

  String get revelationLabel =>
      revelationType == 'Medinan' ? 'Мединская' : 'Мекканская';

  factory QuranChapterSummary.fromJson(Map<String, dynamic> json) {
    return QuranChapterSummary(
      number: json['number'] as int,
      arabicName: json['name'] as String,
      latinName: json['englishName'] as String,
      ayahCount: json['numberOfAyahs'] as int,
      revelationType: json['revelationType'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'number': number,
        'name': arabicName,
        'englishName': latinName,
        'numberOfAyahs': ayahCount,
        'revelationType': revelationType,
      };
}

class QuranVerse {
  final int globalNumber;
  final int numberInChapter;
  final String arabicText;
  final String translation;
  final String transliteration;
  final String audioUrl;
  final String? audioFallbackUrl;
  final int juz;
  final int page;

  const QuranVerse({
    required this.globalNumber,
    required this.numberInChapter,
    required this.arabicText,
    required this.translation,
    required this.transliteration,
    required this.audioUrl,
    this.audioFallbackUrl,
    required this.juz,
    required this.page,
  });
}

class QuranChapter {
  final QuranChapterSummary summary;
  final List<QuranVerse> verses;
  final String fullAudioUrl;

  const QuranChapter({
    required this.summary,
    required this.verses,
    required this.fullAudioUrl,
  });
}
