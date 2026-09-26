import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/utils/arabic_ui_strings.dart';

import '../tool/audit_arabic_ui_strings.dart' as audit;

void main() {
  test('all static screen and widget English labels have Arabic copy', () {
    final copy = audit.collectStaticUiCopy();
    expect(copy.length, greaterThanOrEqualTo(650));
    for (final entry in copy.entries) {
      expect(arabicUiStrings.containsKey(entry.key), isTrue,
          reason: '${entry.key} in ${entry.value.join(', ')}');
      expect(arabicUiStrings[entry.key]?.trim(), isNotEmpty);
    }
  });

  test('dynamic UI labels translate while preserving numbers and user names',
      () {
    for (final sample in audit.dynamicUiSamples) {
      final translated = translateArabicUi(ru: '', en: sample);
      expect(translated, isNot(sample), reason: sample);
      expect(RegExp(r'[\u0600-\u06FF]').hasMatch(translated), isTrue,
          reason: sample);
    }
    expect(
        translateArabicUi(ru: '', en: 'Ali added to friends'), contains('Ali'));
    expect(translateArabicUi(ru: '', en: 'Open exact reference 2:255'),
        allOf(contains('2'), contains('255')));
    expect(translateArabicUi(ru: '', en: 'Review scheduled tomorrow'),
        contains('غدًا'));
  });

  test('does not replace unknown user content with a generic placeholder', () {
    const message = 'My own words: هل يمكنني طرح سؤال؟';
    expect(translateArabicUi(ru: message), message);
    expect(translateArabicUi(ru: 'исходный текст', en: message), message);
  });
}
