import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/screens/lesson_screen.dart';

void main() {
  group('wordOrderBank — банк слов шага «Собери фразу»', () {
    const step = LessonStep(
      id: 'test_word_order',
      type: LessonStepType.wordOrder,
      orderTokens: ['الْحَمْدُ', 'لِلَّهِ', 'رَبِّ', 'الْعَٰلَمِينَ'],
      extraTokens: ['الرَّحِيمِ'],
    );

    test('содержит все слова ответа и дистракторы, ничего не теряя', () {
      final bank = wordOrderBank(step);
      expect(bank.length, step.wordBank.length);
      expect(List<String>.of(bank)..sort(),
          List<String>.of(step.wordBank)..sort());
    });

    test('не отдаёт слова сразу в правильном порядке', () {
      // Иначе задание решается нажатием слов подряд, без знания аята.
      expect(wordOrderBank(step).join(' '), isNot(step.orderedAnswer));
    });

    test('детерминирован: ре-рендер не пересыпает банк', () {
      expect(wordOrderBank(step), wordOrderBank(step));
    });

    test('банк из одного слова отдаётся как есть', () {
      const single = LessonStep(
        type: LessonStepType.wordOrder,
        orderTokens: ['بِسْمِ'],
      );
      expect(wordOrderBank(single), ['بِسْمِ']);
    });

    test('orderedAnswer собирает эталон через один пробел', () {
      expect(step.orderedAnswer, 'الْحَمْدُ لِلَّهِ رَبِّ الْعَٰلَمِينَ');
    });
  });

  group('containsArabicText — выбор шрифта и направления письма', () {
    test('различает арабский и кириллицу/латиницу', () {
      expect(containsArabicText('الْعَٰلَمِينَ'), isTrue);
      expect(containsArabicText('Аль-хамду лилляхи'), isFalse);
      expect(containsArabicText('Praise be to Allah'), isFalse);
      expect(containsArabicText(''), isFalse);
    });
  });

  group('questionAnswerOrder — детерминированный шаффл вариантов (M1)', () {
    test('возвращает полноценную перестановку исходных индексов', () {
      for (final count in [2, 3, 4, 5, 6]) {
        final order = questionAnswerOrder(count, 12345);
        expect(order.length, count);
        expect(order.toSet(), List.generate(count, (i) => i).toSet(),
            reason: 'count=$count должен быть перестановкой без потерь');
      }
    });

    test('детерминирован: одинаковый seed → одинаковый порядок (ре-рендер не пересыпает)',
        () {
      final a = questionAnswerOrder(4, 42);
      final b = questionAnswerOrder(4, 42);
      expect(a, b);
    });

    test('count < 2 отдаёт исходный порядок без изменений', () {
      expect(questionAnswerOrder(0, 7), isEmpty);
      expect(questionAnswerOrder(1, 7), [0]);
    });

    test(
        'правильный ответ не «прилипает» к позиции 0: по разным seed правильный индекс встаёт на разные места',
        () {
      // Считаем, что исходный correctAnswerIndex == 0 (как в 82% датасета).
      // После шаффла его позиция показа = order.indexOf(0). По множеству
      // seed'ов эта позиция должна принимать несколько разных значений —
      // значит стратегия «жми первый» больше не выигрывает стабильно.
      const count = 4;
      final positions = <int>{};
      for (var seed = 0; seed < 40; seed++) {
        positions.add(questionAnswerOrder(count, seed).indexOf(0));
      }
      expect(positions.length, greaterThan(1),
          reason: 'правильный ответ должен появляться на разных позициях');
    });
  });
}
