part of '../lesson_screen.dart';

class _WordOrderStep extends StatelessWidget {
  final LessonStep step;
  final List<int> picks;
  final bool answered;
  final bool isCorrect;
  final void Function(int bankIndex)? onPick;
  final void Function(int position)? onUnpick;

  const _WordOrderStep({
    required this.step,
    required this.picks,
    required this.answered,
    required this.isCorrect,
    this.onPick,
    this.onUnpick,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bank = wordOrderBank(step);
    final used = picks.toSet();
    final rtl = step.orderTokens.any(containsArabicText);

    return Column(
      children: [
        SectionLabel(text: _stepTypeLabel(step, state)),
        const SizedBox(height: 10),
        Text(
            step.question ??
                state.tr(
                    ru: 'Собери фразу в правильном порядке',
                    kk: 'Тіркесті дұрыс ретпен құрастыр',
                    en: 'Put the words in the right order'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark)),
        if (step.russianText != null) ...[
          const SizedBox(height: 8),
          Text(step.russianText!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.textGrey)),
        ],
        const SizedBox(height: 18),
        // Строка ответа: нажатие на слово возвращает его в банк.
        PremiumCard(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 72),
            alignment: Alignment.center,
            child: picks.isEmpty
                ? Text(
                    state.tr(
                        ru: 'Нажимай слова ниже',
                        kk: 'Төмендегі сөздерді бас',
                        en: 'Tap the words below'),
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textLight))
                : Wrap(
                    alignment: WrapAlignment.center,
                    textDirection: rtl ? TextDirection.rtl : null,
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(picks.length, (position) {
                      return _WordChip(
                        key: ValueKey('lesson_order_pick_$position'),
                        text: bank[picks[position]],
                        tone: answered
                            ? (isCorrect
                                ? _WordChipTone.correct
                                : _WordChipTone.wrong)
                            : _WordChipTone.picked,
                        onTap:
                            onUnpick == null ? null : () => onUnpick!(position),
                      );
                    }),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // Банк слов: уже использованные гаснут, но место сохраняют.
        Wrap(
          alignment: WrapAlignment.center,
          textDirection: rtl ? TextDirection.rtl : null,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(bank.length, (bankIndex) {
            final isUsed = used.contains(bankIndex);
            return _WordChip(
              key: ValueKey('lesson_order_bank_$bankIndex'),
              text: bank[bankIndex],
              tone: isUsed ? _WordChipTone.used : _WordChipTone.bank,
              onTap: isUsed || onPick == null ? null : () => onPick!(bankIndex),
            );
          }),
        ),
        if (answered && !isCorrect) ...[
          const SizedBox(height: 16),
          Text(
              state.tr(
                  ru: 'Верный порядок: ${step.orderedAnswer}',
                  kk: 'Дұрыс реті: ${step.orderedAnswer}',
                  en: 'Correct order: ${step.orderedAnswer}'),
              textAlign: TextAlign.center,
              textDirection: rtl ? TextDirection.rtl : null,
              style: TextStyle(
                  fontFamily: containsArabicText(step.orderedAnswer)
                      ? 'Amiri'
                      : 'Nunito',
                  fontSize: containsArabicText(step.orderedAnswer) ? 22 : 15,
                  height: 1.6,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pistachioDark)),
        ],
      ],
    );
  }
}

enum _WordChipTone { bank, used, picked, correct, wrong }

class _WordChip extends StatelessWidget {
  final String text;
  final _WordChipTone tone;
  final VoidCallback? onTap;

  const _WordChip({
    super.key,
    required this.text,
    required this.tone,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasArabic = containsArabicText(text);
    late final Color background;
    late final Color border;
    late final Color textColor;

    switch (tone) {
      case _WordChipTone.bank:
        background = AppColors.white;
        border = AppColors.border;
        textColor = AppColors.textDark;
      case _WordChipTone.used:
        background = AppColors.border.withValues(alpha: 0.35);
        border = AppColors.border;
        textColor = Colors.transparent;
      case _WordChipTone.picked:
        background = AppColors.pistachioLight;
        border = AppColors.pistachio;
        textColor = AppColors.textDark;
      case _WordChipTone.correct:
        background = AppColors.success.withValues(alpha: 0.12);
        border = AppColors.success;
        textColor = AppColors.pistachioDark;
      case _WordChipTone.wrong:
        background = AppColors.error.withValues(alpha: 0.1);
        border = AppColors.error;
        textColor = AppColors.error;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
          boxShadow: tone == _WordChipTone.bank
              ? [
                  BoxShadow(
                    color: AppColors.navyDark.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(text,
            textDirection: hasArabic ? TextDirection.rtl : null,
            style: TextStyle(
                fontFamily: hasArabic ? 'Amiri' : 'Nunito',
                fontSize: hasArabic ? 22 : 15,
                fontWeight: FontWeight.w800,
                color: textColor)),
      ),
    );
  }
}

/// Шаг «Аудирование»: сначала звучит аят или фраза, потом ученик выбирает
/// подходящий вариант. Текст аята намеренно не показывается — иначе задание
/// превращается в обычный вопрос.
