import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/reminder_message.dart';

// Фиксированная дата, чтобы ротация вариантов была детерминированной.
final _now = DateTime(2026, 8, 9);

bool _mentions(List<ReminderMessage> messages, String needle) =>
    messages.any((m) => m.title.contains(needle) || m.body.contains(needle));

void main() {
  group('buildReminders', () {
    test('при streak>0 есть сообщение с числом серии', () {
      final messages = buildReminders(name: 'Амина', streak: 12, now: _now);
      expect(messages, isNotEmpty);
      expect(_mentions(messages, '12'), isTrue);
    });

    test('при dueCount>0 упоминается число повторений', () {
      final messages = buildReminders(
        name: 'Амина',
        streak: 5,
        dueCount: 8,
        now: _now,
      );
      expect(_mentions(messages, '8'), isTrue);
    });

    test('при dueCount==0 плейсхолдер {dueCount} не протекает', () {
      final messages = buildReminders(name: 'Амина', streak: 5, now: _now);
      expect(_mentions(messages, '{dueCount}'), isFalse);
    });

    test('имя подставляется в реплики маскота', () {
      final messages = buildReminders(name: 'Амина', streak: 3, now: _now);
      expect(_mentions(messages, 'Амина'), isTrue);
      // Плейсхолдеры не должны оставаться сырыми.
      expect(_mentions(messages, '{name}'), isFalse);
      expect(_mentions(messages, '{streak}'), isFalse);
    });

    test('пустое имя заменяется тёплым обращением', () {
      final messages = buildReminders(name: '', streak: 4, now: _now);
      expect(_mentions(messages, '{name}'), isFalse);
      expect(_mentions(messages, 'друг'), isTrue);
    });

    test('«Гость» тоже заменяется на нейтральное обращение', () {
      final messages = buildReminders(name: 'Гость', streak: 4, now: _now);
      expect(_mentions(messages, 'друг'), isTrue);
    });

    test('список непустой во всех контекстах стрика', () {
      for (final streak in [0, 1, 3, 7, 30, 100, 250]) {
        final messages = buildReminders(
          name: 'Амина',
          streak: streak,
          dueCount: streak.isEven ? 4 : 0,
          now: _now,
        );
        expect(messages, isNotEmpty, reason: 'streak=$streak');
        // Ни один плейсхолдер не должен протекать.
        for (final m in messages) {
          expect(m.title.contains('{'), isFalse, reason: m.title);
          expect(m.body.contains('{'), isFalse, reason: m.body);
        }
      }
    });

    test('возвращение после паузы (streak==0) не показывает нулевую серию', () {
      final messages = buildReminders(name: 'Амина', streak: 0, now: _now);
      expect(messages, isNotEmpty);
      // Не должно быть неловкого «0-дневный стрик».
      expect(_mentions(messages, '0-дневный'), isFalse);
    });
  });

  group('buildStreakReminder', () {
    test('при streak>0 упоминает число серии', () {
      final message = buildStreakReminder(name: 'Амина', streak: 9, now: _now);
      final text = '${message.title} ${message.body}';
      expect(text.contains('9'), isTrue);
      expect(text.contains('{'), isFalse);
    });

    test('при streak==0 мягко зовёт вернуться без числа', () {
      final message = buildStreakReminder(name: 'Амина', streak: 0, now: _now);
      expect(message.title, isNotEmpty);
      expect(message.body, isNotEmpty);
      expect('${message.title} ${message.body}'.contains('{'), isFalse);
    });
  });

  test('ReminderMessages.test остаётся доступным', () {
    expect(ReminderMessages.test.title, isNotEmpty);
    expect(ReminderMessages.test.body, isNotEmpty);
  });
}
