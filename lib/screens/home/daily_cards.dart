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
    final minutes = _estimatedMinutes(lesson.steps.length);
    final minLabel = state.tr(ru: 'мин', kk: 'мин', en: 'min');
    final newCount =
        lesson.steps.where((step) => step.type == LessonStepType.audio).length;
    final practiceCount = lesson.steps
        .where((step) =>
            step.type == LessonStepType.question ||
            step.type == LessonStepType.matching ||
            step.type == LessonStepType.wordOrder ||
            step.type == LessonStepType.listenChoice)
        .length;
    final speakingCount =
        lesson.steps.where((step) => step.type == LessonStepType.speak).length;
    return Semantics(
      button: true,
      label: '${lesson.title}. $focus',
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 14, 18, 6),
        child: Container(
          constraints: const BoxConstraints(minHeight: 206),
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF5FC3EE), Color(0xFF3FA9DC)],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3FA9DC).withValues(alpha: 0.4),
                blurRadius: 34,
                offset: const Offset(0, 16),
              ),
            ],
          ),
          child: Stack(
            children: [
              Positioned(
                top: -46,
                right: -46,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.white.withValues(alpha: 0.13),
                  ),
                ),
              ),
              Positioned(
                right: 2,
                bottom: -6,
                child: Image.asset(
                  'assets/images/cat_learning_real.webp',
                  width: 112,
                  height: 112,
                  fit: BoxFit.contain,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isReview
                          ? '${state.tr(ru: 'Повторение', kk: 'Қайталау', en: 'Review')} · $minutes $minLabel'
                          : '${state.tr(ru: 'Сегодня', kk: 'Бүгін', en: 'Today')} · $minutes $minLabel',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10.5,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.4,
                        color: AppColors.white.withValues(alpha: 0.86),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.only(right: 94),
                      child: Text(
                        lesson.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          height: 1.3,
                          fontWeight: FontWeight.w900,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 7),
                    Padding(
                      padding: const EdgeInsets.only(right: 94),
                      child: Text(
                        '${state.tr(ru: 'новых', kk: 'жаңа', en: 'new')} $newCount · '
                        '${state.tr(ru: 'практика', kk: 'жаттығу', en: 'practice')} $practiceCount · '
                        '${state.tr(ru: 'произношение', kk: 'айтылым', en: 'speaking')} $speakingCount',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.5,
                          height: 1.35,
                          fontWeight: FontWeight.w700,
                          color: AppColors.white.withValues(alpha: 0.88),
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    Material(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(14),
                      child: InkWell(
                        onTap: onStart,
                        borderRadius: BorderRadius.circular(14),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 22, vertical: 12),
                          child: Text(
                            isReview
                                ? state.tr(
                                    ru: 'Повторить',
                                    kk: 'Қайталау',
                                    en: 'Review')
                                : state.tr(
                                    ru: 'Начать урок',
                                    kk: 'Сабақты бастау',
                                    en: 'Start lesson'),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF1E7FB4),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static int _estimatedMinutes(int stepCount) {
    final minutes = (stepCount / 2).ceil();
    if (minutes < 3) return 3;
    if (minutes > 15) return 15;
    return minutes;
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
                '${_reviewDateLabel(nextReviewAt)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel(text: 'Memory Engine'),
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

/// Mentor tip card with the mascot and a link into the AI Coach.
class _MentorTipCard extends StatelessWidget {
  final String? text;
  final VoidCallback onTap;

  const _MentorTipCard({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: PremiumCard(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.skyLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const CatCharacter(mood: CatMood.support, size: 58),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(
                          text: state.tr(
                              ru: 'Совет наставника',
                              kk: 'Ұстаз кеңесі',
                              en: 'Mentor tip')),
                      const SizedBox(height: 5),
                      Text(
                        text?.trim().isNotEmpty == true
                            ? text!
                            : state.tr(
                                ru: 'Учись понемногу каждый день — пять минут регулярно '
                                    'работают лучше часа раз в неделю.',
                                kk: 'Күн сайын аз-аздан үйрен — тұрақты бес минут '
                                    'аптасына бір сағаттан тиімдірек.',
                                en: 'Learn a little every day — five regular minutes '
                                    'beat an hour once a week.',
                              ),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          height: 1.32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _reviewDateLabel(DateTime? date) {
  if (date == null) return 'после урока';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final days = target.difference(today).inDays;
  if (days <= 0) return 'сегодня';
  if (days == 1) return 'завтра';
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
}

String _lessonCountRu(int count) {
  final mod100 = count % 100;
  final mod10 = count % 10;
  final word = mod100 >= 11 && mod100 <= 14
      ? 'уроков'
      : switch (mod10) {
          1 => 'урок',
          2 || 3 || 4 => 'урока',
          _ => 'уроков',
        };
  return '$count $word';
}
