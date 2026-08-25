part of '../lesson_screen.dart';

class _MatchingStep extends StatefulWidget {
  final LessonStep step;
  final VoidCallback onWrong;
  final VoidCallback onCompleted;

  const _MatchingStep({
    super.key,
    required this.step,
    required this.onWrong,
    required this.onCompleted,
  });

  @override
  State<_MatchingStep> createState() => _MatchingStepState();
}

class _MatchingStepState extends State<_MatchingStep> {
  int? _selectedPrompt;
  int? _selectedAnswer;
  final Set<int> _matchedPrompts = {};

  List<LessonMatchPair> get _pairs => widget.step.matchPairs;

  /// Порядок отображения правой колонки (ответов). Реально перемешан, но
  /// детерминирован в пределах одного показа шага — seed берётся из содержимого
  /// шага, поэтому на каждый rebuild порядок не «прыгает».
  List<int> get _answerOrder =>
      matchingAnswerOrder(_pairs.length, _shuffleSeed);

  /// Стабильный seed от содержимого шага: одинаков между перестроениями одного
  /// и того же шага, но различается для разных шагов.
  int get _shuffleSeed {
    final buffer =
        StringBuffer(widget.step.id ?? widget.step.question ?? 'matching');
    for (final pair in _pairs) {
      buffer
        ..write('|')
        ..write(pair.prompt)
        ..write('>')
        ..write(pair.answer);
    }
    return buffer.toString().hashCode;
  }

  void _selectPrompt(int index) {
    if (_matchedPrompts.contains(index)) return;
    setState(() => _selectedPrompt = index);
    _tryMatch();
  }

  void _selectAnswer(int pairIndex) {
    if (_matchedPrompts.contains(pairIndex)) return;
    setState(() => _selectedAnswer = pairIndex);
    _tryMatch();
  }

  void _tryMatch() {
    final prompt = _selectedPrompt;
    final answer = _selectedAnswer;
    if (prompt == null || answer == null) return;

    if (prompt == answer) {
      setState(() {
        _matchedPrompts.add(prompt);
        _selectedPrompt = null;
        _selectedAnswer = null;
      });
      if (_matchedPrompts.length == _pairs.length) {
        widget.onCompleted();
      } else {
        HapticsService.correct();
      }
      return;
    }

    widget.onWrong();
    setState(() {
      _selectedPrompt = null;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        SectionLabel(text: _stepTypeLabel(widget.step, state)),
        const SizedBox(height: 10),
        Text(
            widget.step.question ??
                state.tr(
                    ru: 'Соедини пары по смыслу',
                    kk: 'Жұптарды мағынасына қарай сәйкестендір',
                    en: 'Match the pairs by meaning'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark)),
        if (widget.step.russianText != null) ...[
          const SizedBox(height: 8),
          Text(widget.step.russianText!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.textGrey)),
        ],
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: List.generate(_pairs.length, (index) {
                  return _MatchCard(
                    key: ValueKey('lesson_match_prompt_$index'),
                    text: _pairs[index].prompt,
                    selected: _selectedPrompt == index,
                    matched: _matchedPrompts.contains(index),
                    onTap: () => _selectPrompt(index),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: _answerOrder.map((pairIndex) {
                  return _MatchCard(
                    key: ValueKey('lesson_match_answer_$pairIndex'),
                    text: _pairs[pairIndex].answer,
                    selected: _selectedAnswer == pairIndex,
                    matched: _matchedPrompts.contains(pairIndex),
                    onTap: () => _selectAnswer(pairIndex),
                  );
                }).toList(growable: false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String text;
  final bool selected;
  final bool matched;
  final VoidCallback onTap;

  const _MatchCard({
    super.key,
    required this.text,
    required this.selected,
    required this.matched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasArabic = containsArabicText(text);
    final border = matched
        ? AppColors.success
        : (selected ? AppColors.pistachio : AppColors.border);
    final background = matched
        ? AppColors.success.withValues(alpha: 0.1)
        : (selected ? AppColors.pistachioLight : AppColors.white);

    return GestureDetector(
      onTap: matched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 62),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: selected || matched ? 2 : 1),
          boxShadow: (selected || matched)
              ? null
              : [
                  BoxShadow(
                    color: AppColors.navyDark.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            textDirection: hasArabic ? TextDirection.rtl : null,
            style: TextStyle(
              fontFamily: hasArabic ? 'Amiri' : 'Nunito',
              fontSize: hasArabic ? 22 : 14,
              fontWeight: FontWeight.w800,
              color: matched ? AppColors.pistachioDark : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// Шаг «Собери фразу»: слова банка нажимаются в правильном порядке.
///
/// Состояние сборки живёт в _LessonScreenState (как и выбранный вариант
/// вопроса) — иначе оно терялось бы при ре-рендере и не было бы доступно
/// проверке в `_onCheck`.
