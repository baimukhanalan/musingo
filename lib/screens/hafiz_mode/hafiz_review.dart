part of '../hafiz_mode_screen.dart';

class _HiddenVerse extends StatefulWidget {
  final QuranVerse verse;
  final double level;

  const _HiddenVerse({required this.verse, required this.level});

  @override
  State<_HiddenVerse> createState() => _HiddenVerseState();
}

class _HiddenVerseState extends State<_HiddenVerse> {
  final Set<int> _revealed = {};

  @override
  void didUpdateWidget(_HiddenVerse oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new hide level re-hides the words that were peeked.
    if (oldWidget.level != widget.level) _revealed.clear();
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.verse.arabicText
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    final hiddenEvery = widget.level < 0.34
        ? 99
        : widget.level < 0.67
            ? 3
            : widget.level < 1
                ? 2
                : 1;
    return PremiumCard(
      child: Wrap(
        alignment: WrapAlignment.center,
        textDirection: TextDirection.rtl,
        spacing: 8,
        runSpacing: 8,
        children: words.indexed.map((item) {
          final hidden = hiddenEvery != 99 && item.$1 % hiddenEvery == 0;
          final peeked = _revealed.contains(item.$1);
          final showHidden = hidden && !peeked;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: hidden
                ? () => setState(() {
                      if (peeked) {
                        _revealed.remove(item.$1);
                      } else {
                        _revealed.add(item.$1);
                      }
                    })
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color:
                    showHidden ? AppColors.skyLight : AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: showHidden ? AppColors.sky : AppColors.border,
                ),
              ),
              child: showHidden
                  ? const Text(
                      '● ● ●',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                        color: AppColors.sky,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : Text(
                      item.$2,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 28,
                        height: 1.5,
                        color: AppColors.textDark,
                      ),
                    ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

/// Data-driven review schedule card: shows the next spaced-repetition date from
/// stored progress (real AppState data — no fabricated plan).
class _ReviewCard extends StatelessWidget {
  final HafizProgress? progress;

  const _ReviewCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final progress = this.progress;
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.tr(
                ru: 'РАСПИСАНИЕ ПОВТОРЕНИЙ',
                kk: 'ҚАЙТАЛАУ КЕСТЕСІ',
                en: 'REVIEW SCHEDULE'),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          _row(
            icon: Icons.play_circle_fill_rounded,
            color: AppColors.sky,
            title: state.tr(ru: 'Сегодня', kk: 'Бүгін', en: 'Today'),
            trailing:
                state.tr(ru: 'заучивание', kk: 'жаттау', en: 'memorization'),
          ),
          const SizedBox(height: 10),
          if (progress == null)
            _row(
              icon: Icons.schedule_rounded,
              color: AppColors.textLight,
              title: state.tr(
                  ru: 'Следующее повторение',
                  kk: 'Келесі қайталау',
                  en: 'Next review'),
              trailing: state.tr(
                  ru: 'после проверки',
                  kk: 'тексеруден кейін',
                  en: 'after checking'),
            )
          else ...[
            _row(
              icon: Icons.event_repeat_rounded,
              color: AppColors.gold,
              title: state.tr(
                  ru: 'Следующее повторение',
                  kk: 'Келесі қайталау',
                  en: 'Next review'),
              trailing: _dateLabel(progress.nextReviewAt),
            ),
            const SizedBox(height: 10),
            _row(
              icon: Icons.verified_rounded,
              color: AppColors.success,
              title: progress.masteryLabel,
              trailing: 'mastery ${(progress.mastery * 100).round()}%',
            ),
          ],
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required Color color,
    required String title,
    required String trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.14),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}

/// Small Muslingo+ upsell note.
class _PlusNote extends StatelessWidget {
  final String text;

  const _PlusNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded,
              size: 18, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final int stage;
  final bool enabled;
  final SpeechEvaluationResult? result;
  final VoidCallback onContinue;

  const _BottomAction({
    required this.stage,
    required this.enabled,
    required this.result,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: PremiumButton(
        label: stage == 5
            ? result == null
                ? state.tr(
                    ru: 'Сначала запиши аят',
                    kk: 'Алдымен аятты жаз',
                    en: 'Record the verse first')
                : state.tr(
                    ru: 'Сохранить результат',
                    kk: 'Нәтижені сақтау',
                    en: 'Save the result')
            : state.tr(ru: 'Продолжить', kk: 'Жалғастыру', en: 'Continue'),
        icon: stage == 5 ? Icons.save_rounded : Icons.arrow_forward_rounded,
        onPressed: enabled ? onContinue : null,
      ),
    );
  }
}

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
