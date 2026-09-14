import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/mentor_profile.dart';

void main() {
  test('mentor profile round-trips safe personal settings', () {
    final profile = MentorProfile(
      preferredName: 'Алан',
      birthdayMonth: 9,
      birthdayDay: 14,
      motivation: 'Читать Коран увереннее',
      currentFocus: 'Таджвид',
      tone: MentorTone.focused,
      preferredSessionMinutes: 12,
      memories: [
        MentorMemory(
          id: 'one',
          text: 'Лучше учусь утром',
          createdAt: DateTime(2026, 9, 14),
        ),
      ],
    );

    final restored = MentorProfile.fromJson(profile.toJson());

    expect(restored.preferredName, 'Алан');
    expect(restored.tone, MentorTone.focused);
    expect(restored.preferredSessionMinutes, 12);
    expect(restored.memories.single.text, 'Лучше учусь утром');
    expect(restored.isBirthday(DateTime(2030, 9, 14)), isTrue);
  });

  test('mentor profile clamps invalid and oversized input', () {
    final restored = MentorProfile.fromJson({
      'birthdayMonth': 13,
      'birthdayDay': 40,
      'preferredSessionMinutes': 100,
      'preferredName': 'А' * 100,
      'memories': List.generate(
        30,
        (index) => {
          'id': '$index',
          'text': 'fact $index',
          'createdAt': '2026-09-14T00:00:00.000',
        },
      ),
    });

    expect(restored.birthdayMonth, isNull);
    expect(restored.birthdayDay, isNull);
    expect(restored.preferredSessionMinutes, 30);
    expect(restored.preferredName.length, 60);
    expect(restored.memories, hasLength(20));
  });
}
