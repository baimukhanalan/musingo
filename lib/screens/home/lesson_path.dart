part of '../home_screen.dart';

class _LessonPath extends StatelessWidget {
  final List<Lesson> lessons;
  final List<IconData> icons;
  final void Function(BuildContext context, Lesson lesson) onOpenLesson;

  const _LessonPath({
    required this.lessons,
    required this.icons,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    // Ленивый путь уроков: SliverList строит только видимые узлы, а не весь
    // курс сразу (как было в Column внутри SliverToBoxAdapter), сохраняя
    // ленивость CustomScrollView. Геометрия змейки держится на фиксированной
    // высоте узла и горизонтальном сдвиге по индексу (offsets[index % ...]) —
    // каждый узел самодостаточен, соединителей между соседями нет, поэтому
    // ленивое построение не меняет верстку.
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final lesson = lessons[index];
            const offsets = [-0.42, -0.1, 0.28, 0.02, -0.34];
            final nodeOffset = offsets[index % offsets.length];
            final compact = MediaQuery.sizeOf(context).width < 430;
            final mascotOffset = nodeOffset <= 0
                ? nodeOffset + (compact ? 1.08 : 0.8)
                : nodeOffset - (compact ? 1.08 : 0.8);
            final mascotSize = compact ? 82.0 : 94.0;
            final isCurrent = lesson.status == LessonStatus.available ||
                lesson.status == LessonStatus.inProgress;
            final nextOffset = offsets[(index + 1) % offsets.length];
            return SizedBox(
              // Узел урока (круг 70 + отступ 12 + плашка названия ~29 ≈ 111px)
              // не влезал в 104 → Column переполнялся на 7px. Даём запас.
              height: isCurrent ? 134 : 116,
              child: Stack(
                alignment: Alignment.topCenter,
                children: [
                  if (index < lessons.length - 1)
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _PathTrailPainter(
                          from: nodeOffset,
                          to: nextOffset,
                          completed: lesson.status == LessonStatus.completed,
                        ),
                      ),
                    ),
                  Align(
                    alignment: Alignment(nodeOffset, -0.65),
                    child: _PathNode(
                      lesson: lesson,
                      icon: icons[index % icons.length],
                      onTap: () => onOpenLesson(context, lesson),
                    ),
                  ),
                  if (isCurrent)
                    Align(
                      alignment: Alignment(mascotOffset, compact ? 0.55 : 0.72),
                      child: SizedBox(
                        width: mascotSize,
                        height: mascotSize,
                        child: CatCharacter(
                          mood: CatMood.greet,
                          size: mascotSize,
                        ),
                      ),
                    ),
                ],
              ),
            );
          },
          childCount: lessons.length,
        ),
      ),
    );
  }
}

void _showLockedLessonDialog(BuildContext context, Lesson lesson) {
  final state = context.read<AppState>();
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.backgroundGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AppColors.textGrey,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              lesson.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              state.tr(
                  ru: 'Заверши предыдущий урок, чтобы открыть этот шаг.',
                  kk: 'Осы қадамды ашу үшін алдыңғы сабақты аяқта.',
                  en: 'Finish the previous lesson to unlock this step.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(sheetContext),
                icon: const Icon(Icons.check_rounded),
                label: Text(
                    state.tr(ru: 'Понятно', kk: 'Түсінікті', en: 'Got it')),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PathNode extends StatelessWidget {
  final Lesson lesson;
  final IconData icon;
  final VoidCallback? onTap;

  const _PathNode({required this.lesson, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final locked = lesson.status == LessonStatus.locked;
    final completed = lesson.status == LessonStatus.completed;
    final color = locked
        ? AppColors.textLight
        : (completed ? AppColors.gold : AppColors.sky);
    final shadow = locked
        ? const Color(0xFF93A8B5)
        : (completed ? const Color(0xFFC88A25) : AppColors.navy);

    final node = Semantics(
      button: true,
      label:
          '${lesson.title}. ${locked ? state.tr(ru: 'Закрыто', kk: 'Жабық', en: 'Locked') : state.tr(ru: 'Открыть урок', kk: 'Сабақты ашу', en: 'Open lesson')}',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 70,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border:
                    Border.all(color: color.withValues(alpha: 0.85), width: 3),
                boxShadow: [
                  BoxShadow(color: shadow, offset: const Offset(0, 7))
                ],
              ),
              child: Icon(
                  locked
                      ? Icons.lock_rounded
                      : (completed ? Icons.check_rounded : icon),
                  color: Colors.white,
                  size: 34),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxWidth: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
              child: Text(lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
            ),
          ],
        ),
      ),
    );

    if (lesson.status != LessonStatus.available &&
        lesson.status != LessonStatus.inProgress) {
      return node;
    }
    return node
        .animate(onPlay: (controller) => controller.repeat(reverse: true))
        .scale(
          begin: const Offset(1, 1),
          end: const Offset(1.045, 1.045),
          duration: 1100.ms,
          curve: Curves.easeInOut,
        );
  }
}

class _PathTrailPainter extends CustomPainter {
  final double from;
  final double to;
  final bool completed;

  const _PathTrailPainter({
    required this.from,
    required this.to,
    required this.completed,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final start = Offset(size.width * (from + 1) / 2, 58);
    final end = Offset(size.width * (to + 1) / 2, size.height + 4);
    final path = Path()
      ..moveTo(start.dx, start.dy)
      ..quadraticBezierTo(
        size.width / 2,
        size.height * 0.72,
        end.dx,
        end.dy,
      );
    final paint = Paint()
      ..color = (completed ? AppColors.gold : AppColors.navy)
          .withValues(alpha: completed ? 0.55 : 0.25)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        canvas.drawPath(
          metric.extractPath(distance, distance + 7),
          paint,
        );
        distance += 14;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _PathTrailPainter oldDelegate) =>
      oldDelegate.from != from ||
      oldDelegate.to != to ||
      oldDelegate.completed != completed;
}

class _PathAtmosphere extends StatelessWidget {
  const _PathAtmosphere();

  @override
  Widget build(BuildContext context) {
    final reduceMotion = MediaQuery.of(context).disableAnimations;
    Widget sparkle(IconData icon, double size, Color color) => Icon(
          icon,
          size: size,
          color: color.withValues(alpha: 0.46),
        );

    final first = sparkle(Icons.auto_awesome_rounded, 22, AppColors.gold);
    final second = sparkle(Icons.cloud_rounded, 34, AppColors.white);
    final third = sparkle(Icons.star_rounded, 17, AppColors.coral);

    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            left: 22,
            top: 34,
            child: reduceMotion
                ? first
                : first
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .fade(begin: 0.35, end: 0.9, duration: 1600.ms)
                    .scale(
                      begin: const Offset(0.88, 0.88),
                      end: const Offset(1.08, 1.08),
                    ),
          ),
          Positioned(
            right: 18,
            top: 112,
            child: reduceMotion
                ? second
                : second
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .moveX(begin: -7, end: 7, duration: 3200.ms),
          ),
          Positioned(
            right: 42,
            bottom: 40,
            child: reduceMotion
                ? third
                : third
                    .animate(onPlay: (c) => c.repeat(reverse: true))
                    .rotate(begin: -0.04, end: 0.04, duration: 2100.ms),
          ),
        ],
      ),
    );
  }
}

class _DailyQuest extends StatelessWidget {
  final int completed;
  final int goal;

  const _DailyQuest({required this.completed, required this.goal});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final safeGoal = goal <= 0 ? 3 : goal;
    final progress = (completed / safeGoal).clamp(0.0, 1.0);
    return PremiumCard(
      radius: 20,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: AppColors.goldLight,
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.emoji_events_rounded,
                color: AppColors.gold, size: 29),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    state.tr(
                        ru: 'Учебная цель',
                        kk: 'Оқу мақсаты',
                        en: 'Learning goal'),
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark)),
                Text(
                    '$completed ${state.tr(ru: 'из', kk: 'ішінен', en: 'of')} $safeGoal ${state.tr(ru: 'уроков', kk: 'сабақ', en: 'lessons')}',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGrey)),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.backgroundGrey,
                      color: AppColors.gold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
