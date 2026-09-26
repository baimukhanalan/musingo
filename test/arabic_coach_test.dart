import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/coach.dart';
import 'package:muslingo/services/coach_service.dart';

void main() {
  const context = CoachContext(
    goal: null,
    placementLevel: 2,
    recommendation: '',
    recommendedLessonId: 'q1',
    recommendedLessonTitle: 'الفاتحة: البداية',
    dueReviewCount: 2,
    weakKnowledge: [],
  );
  final service = CoachService();
  test('every Arabic suggestion has an Arabic offline response', () {
    expect(CoachService.suggestionsFor('ar'), hasLength(8));
    for (final question in CoachService.suggestionsFor('ar')) {
      final response = service.answer(question, context, locale: 'ar');
      expect(response.isOffline, isTrue);
      expect(RegExp(r'[\u0600-\u06ff]').hasMatch(response.text), isTrue);
      expect(RegExp(r'[А-Яа-я]').hasMatch(response.text), isFalse);
      expect(RegExp(r'[А-Яа-я]').hasMatch(response.actionLabel ?? ''), isFalse);
      for (final source in response.sources) {
        expect(RegExp(r'[А-Яа-я]').hasMatch(source.title), isFalse);
      }
    }
  });
  test(
      'unknown religious questions and dreams do not fabricate offline answers',
      () {
    final dream = service.answer('ما معنى حلمي؟', context, locale: 'ar');
    expect(dream.text, contains('لا أستطيع الجزم'));
    expect(dream.actionType, isNull);
    final other =
        service.answer('أخبرني عن مسألة غير معروفة', context, locale: 'ar');
    expect(other.text, contains('لن أختلق'));
    expect(other.isOffline, isTrue);
  });
}
