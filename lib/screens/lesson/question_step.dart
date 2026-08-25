part of '../lesson_screen.dart';

class _QuestionStep extends StatelessWidget {
  final LessonStep step;
  final int? selectedAnswer;
  final bool answered;
  final void Function(int)? onSelect;
  final bool showHint;

  const _QuestionStep(
      {required this.step,
      this.selectedAnswer,
      required this.answered,
      this.onSelect,
      required this.showHint});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final displayOrder = _displayOrder;
    return Column(
      children: [
        SectionLabel(text: _stepTypeLabel(step, state)),
        const SizedBox(height: 10),
        Text(step.question ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark)),
        const SizedBox(height: 20),
        if (showHint) _buildHint(state),
        // Варианты показываются в детерминированно перемешанном порядке
        // (см. _displayOrder): правильный ответ не «прилипает» к позиции 0,
        // поэтому стратегия «жми первый» больше не проходит. Оригинальный
        // индекс варианта (i) сохраняется для onSelect и всех сверок с
        // correctAnswerIndex, так что подсчёт ошибок и разбор не меняются.
        ...List.generate(displayOrder.length, (displayPos) {
          final i = displayOrder[displayPos];
          return _AnswerOptionCard(
            key: ValueKey('lesson_answer_$i'),
            text: step.answers![i],
            letter: String.fromCharCode(65 + displayPos),
            selected: selectedAnswer == i,
            answered: answered,
            isCorrectOption: i == step.correctAnswerIndex,
            onTap: () => onSelect?.call(i),
          );
        }),
      ],
    );
  }

  /// Порядок показа вариантов ответа. Детерминированно перемешан по seed от
  /// содержимого вопроса: стабилен между ре-рендерами одного шага (порядок не
  /// «прыгает»), но у каждого вопроса свой, поэтому правильный ответ не всегда
  /// на позиции 0. Возвращает исходные индексы вариантов в порядке показа.
  List<int> get _displayOrder =>
      questionAnswerOrder(step.answers?.length ?? 0, _shuffleSeed);

  /// Стабильный seed из содержимого вопроса: одинаков между перестроениями
  /// одного шага, но различается для разных вопросов.
  int get _shuffleSeed {
    final buffer = StringBuffer(step.id ?? step.question ?? 'question');
    final answers = step.answers ?? const <String>[];
    for (final answer in answers) {
      buffer
        ..write('|')
        ..write(answer);
    }
    return buffer.toString().hashCode;
  }

  /// Подсказка НЕ раскрывает правильный вариант: даёт контекст/значение
  /// (explanation → транслитерация → перевод → общий намёк), чтобы вопрос не
  /// становился тривиальным. Использование подсказки ничего не «ломает» в
  /// подсчёте ошибок — она просто помогает вспомнить материал.
  Widget _buildHint(AppState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(_hintText(state),
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark))),
        ],
      ),
    );
  }

  String _hintText(AppState state) {
    final explanation = step.explanation?.trim();
    if (explanation != null && explanation.isNotEmpty) return explanation;
    final translit = step.transliteration?.trim();
    if (translit != null && translit.isNotEmpty) {
      return state.tr(
        ru: 'Вспомни звучание: $translit',
        kk: 'Дыбысталуын есіңе түсір: $translit',
        en: 'Recall the sound: $translit',
      );
    }
    final russian = step.russianText?.trim();
    if (russian != null && russian.isNotEmpty) {
      return state.tr(
        ru: 'Подумай о значении: $russian',
        kk: 'Мағынасын ойлан: $russian',
        en: 'Think about the meaning: $russian',
      );
    }
    return state.tr(
      ru: 'Подумай о смысле и вспомни материал урока.',
      kk: 'Мағынасын ойлап, сабақ материалын есіңе түсір.',
      en: 'Think about the meaning and recall the lesson material.',
    );
  }
}

/// Карточка варианта ответа. Общая для обычного вопроса и аудирования —
/// цвета, буква-маркер и иконки итога здесь одни и те же.
class _AnswerOptionCard extends StatelessWidget {
  final String text;
  final String letter;
  final bool selected;
  final bool answered;
  final bool isCorrectOption;
  final VoidCallback? onTap;

  const _AnswerOptionCard({
    super.key,
    required this.text,
    required this.letter,
    required this.selected,
    required this.answered,
    required this.isCorrectOption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.white;
    Color border = AppColors.border;
    Color textColor = AppColors.textDark;

    if (selected) {
      if (answered) {
        if (isCorrectOption) {
          bg = AppColors.success.withValues(alpha: 0.12);
          border = AppColors.success;
          textColor = AppColors.pistachioDark;
        } else {
          bg = AppColors.error.withValues(alpha: 0.1);
          border = AppColors.error;
          textColor = AppColors.error;
        }
      } else {
        bg = AppColors.pistachioLight;
        border = AppColors.pistachio;
      }
    } else if (answered && isCorrectOption) {
      bg = AppColors.success.withValues(alpha: 0.1);
      border = AppColors.success;
    }

    final bool highlighted = selected || (answered && isCorrectOption);
    final bool hasArabic = containsArabicText(text);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2),
          boxShadow: highlighted
              ? null
              : [
                  BoxShadow(
                    color: AppColors.navyDark.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: border.withValues(alpha: 0.15),
                shape: BoxShape.circle,
                border: Border.all(color: border, width: 1.5),
              ),
              child: Center(
                  child: Text(letter,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: border))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  textDirection: hasArabic ? TextDirection.rtl : null,
                  style: TextStyle(
                      fontFamily: hasArabic ? 'Amiri' : 'Nunito',
                      fontSize: hasArabic ? 22 : 17,
                      fontWeight: FontWeight.w700,
                      color: textColor)),
            ),
            if (answered && isCorrectOption)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 24),
            if (answered && selected && !isCorrectOption)
              const Icon(Icons.cancel_rounded,
                  color: AppColors.error, size: 24),
          ],
        ),
      ),
    );
  }
}

/// Есть ли в строке арабские буквы — от этого зависят шрифт (Amiri) и
/// направление письма в карточках, чипах и банке слов.
bool containsArabicText(String value) {
  for (final rune in value.runes) {
    if (rune >= 0x0600 && rune <= 0x06ff) return true;
  }
  return false;
}

/// Банк слов для wordOrder-шага в порядке показа.
///
/// Правильные слова и дистракторы перемешаны детерминированно (seed от
/// содержимого шага — порядок стабилен между ре-рендерами), но заведомо не
/// совпадают с эталонной последовательностью: иначе задание решалось бы
/// нажатием слов слева направо без знания аята.
@visibleForTesting
List<String> wordOrderBank(LessonStep step) {
  final bank = step.wordBank;
  if (bank.length < 2) return bank;

  final buffer = StringBuffer(step.id ?? step.question ?? 'wordOrder');
  for (final token in bank) {
    buffer
      ..write('|')
      ..write(token);
  }
  final seed = buffer.toString().hashCode;

  for (var attempt = 0; attempt < 8; attempt++) {
    final shuffled = List<String>.of(bank)
      ..shuffle(Random(Object.hash(seed, attempt)));
    if (shuffled.join(' ') != step.orderedAnswer) return shuffled;
  }
  return List<String>.of(bank.reversed);
}

/// Детерминированная перестановка вариантов ответа вопроса.
///
/// Возвращает исходные индексы вариантов в порядке показа. Перемешивание
/// детерминировано по [seed] (стабильно между ре-рендерами одного шага), но у
/// каждого вопроса свой seed — правильный ответ не «прилипает» к позиции 0.
@visibleForTesting
List<int> questionAnswerOrder(int count, int seed) {
  final order = List<int>.generate(count, (index) => index);
  if (count < 2) return order;
  order.shuffle(Random(seed));
  return order;
}

/// Детерминированная перестановка правой колонки matching-задания.
///
/// Возвращает порядок индексов пар для показа ответов: правая колонка реально
/// перемешана (не сдвинута на один элемент, как было раньше), стабильна в
/// пределах одного показа (за счёт [seed] от содержимого шага) и без
/// тривиальных совпадений — ответ i не стоит напротив своего prompt i, иначе
/// задание решалось бы без знания. Соответствие пар сохраняется: перемешивается
/// только порядок отображения, а не связь prompt↔answer.
@visibleForTesting
List<int> matchingAnswerOrder(int count, int seed) {
  final order = List<int>.generate(count, (index) => index);
  if (count < 2) return order;
  for (var attempt = 0; attempt < 8; attempt++) {
    // Мешаем seed с номером попытки хешем, а не сложением: иначе соседние
    // seed'ы разных шагов могли бы дать одинаковую перестановку через retry.
    final shuffled = List<int>.of(order)
      ..shuffle(Random(Object.hash(seed, attempt)));
    var hasFixedPoint = false;
    for (var i = 0; i < count; i++) {
      if (shuffled[i] == i) {
        hasFixedPoint = true;
        break;
      }
    }
    if (!hasFixedPoint) return shuffled;
  }
  // Крайне маловероятный фолбэк: циклический сдвиг — гарантированная
  // перестановка без совпадений (для count >= 2).
  return [for (var i = 0; i < count; i++) (i + 1) % count];
}
