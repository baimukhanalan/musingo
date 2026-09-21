part of '../home_screen.dart';

class _DailyPlanCard extends StatelessWidget {
  final Lesson lesson;
  final String focus;
  final bool isReview;
  final VoidCallback onStart;

  const _DailyPlanCard({
    required this.lesson,
    required this.focus,
    required this.isReview,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final minutes = (lesson.steps.length / 2).ceil().clamp(3, 15);
    final heading = isReview
        ? state.tr(ru: 'Повторение', kk: 'Қайталау', en: 'Review')
        : state.tr(ru: 'Сегодня', kk: 'Бүгін', en: 'Today');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Container(
        key: const ValueKey('daily-plan-card'),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF296D8B), Color(0xFF173E5A)],
          ),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(color: const Color(0x557BC9E5)),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.14),
              blurRadius: 24,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$heading · $minutes ${state.tr(ru: 'мин', kk: 'мин', en: 'min')}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                          color: Color(0xFFC8E9F5),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        lesson.title,
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 21,
                          height: 1.2,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                const CatCharacter(mood: CatMood.greet, size: 108),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const ValueKey('daily-plan-start'),
              onPressed: onStart,
              icon: const Icon(Icons.play_arrow_rounded, size: 22),
              label: Text(isReview
                  ? state.tr(ru: 'Повторить', kk: 'Қайталау', en: 'Review')
                  : state.tr(
                      ru: 'Начать урок',
                      kk: 'Сабақты бастау',
                      en: 'Start lesson')),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.navyDark,
                minimumSize: const Size(0, 48),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
                textStyle:
                    const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// MEMORY ENGINE card: accuracy ring + review call-to-action driven by the
/// spaced-repetition state in [AppState].
class _MemoryEngineCard extends StatelessWidget {
  final double accuracy;
  final int dueCount;
  final int weakCount;
  final DateTime? nextReviewAt;
  final VoidCallback? onReview;

  const _MemoryEngineCard({
    required this.accuracy,
    required this.dueCount,
    required this.weakCount,
    required this.nextReviewAt,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bool hasReview = (dueCount > 0 || weakCount > 0) && onReview != null;
    final int accuracyPct = (accuracy * 100).round();
    final ringColor = accuracyPct >= 80
        ? AppColors.success
        : (accuracyPct >= 60 ? AppColors.sky : AppColors.coral);

    final String description = dueCount > 0
        ? state.tr(
            ru: 'Сегодня к повторению: $dueCount · слабых мест: $weakCount',
            kk: 'Бүгін қайталауға: $dueCount · әлсіз жерлер: $weakCount',
            en: 'Due today: $dueCount · weak spots: $weakCount')
        : weakCount > 0
            ? state.tr(
                ru: 'Слабых мест: $weakCount — закрепим, пока не забылось',
                kk: 'Әлсіз жерлер: $weakCount — ұмытылмай тұрып бекітеміз',
                en: "Weak spots: $weakCount — let's reinforce before you forget")
            : '${state.tr(ru: 'Всё под контролем · следующее повторение: ', kk: 'Барлығы бақылауда · келесі қайталау: ', en: 'All under control · next review: ')}'
                '${_reviewDateLabel(nextReviewAt, state)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SectionLabel(
                text: state.tr(
                    ru: 'Закрепление знаний',
                    kk: 'Білімді бекіту',
                    en: 'Knowledge review')),
            const SizedBox(height: 14),
            Row(
              children: [
                ProgressRing(
                  percent: accuracy,
                  size: 62,
                  color: ringColor,
                  child: Text(
                    '$accuracyPct%',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: ringColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr(
                            ru: 'Точность по памяти',
                            kk: 'Есте сақтау дәлдігі',
                            en: 'Memory accuracy'),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasReview) ...[
              const SizedBox(height: 16),
              PremiumButton(
                label: state.tr(ru: 'Повторить', kk: 'Қайталау', en: 'Review'),
                icon: Icons.replay_rounded,
                variant: PremiumButtonVariant.navy,
                onPressed: onReview,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

String _reviewDateLabel(DateTime? date, AppState state) {
  if (date == null) {
    return state.tr(
        ru: 'после урока', kk: 'сабақтан кейін', en: 'after a lesson');
  }
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final days = target.difference(today).inDays;
  if (days <= 0) return state.tr(ru: 'сегодня', kk: 'бүгін', en: 'today');
  if (days == 1) return state.tr(ru: 'завтра', kk: 'ертең', en: 'tomorrow');
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
}
