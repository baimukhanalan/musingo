part of '../profile_screen.dart';

class _AchievementsHeader extends StatelessWidget {
  final VoidCallback onSeeAll;
  const _AchievementsHeader({required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: SectionLabel(
              text: state.tr(
                  ru: 'Достижения', kk: 'Жетістіктер', en: 'Achievements')),
        ),
        TextButton.icon(
          onPressed: onSeeAll,
          style: TextButton.styleFrom(foregroundColor: AppColors.navy),
          label: Text(state.tr(ru: 'Все', kk: 'Барлығы', en: 'All')),
          icon: const Icon(Icons.chevron_right_rounded, size: 18),
          iconAlignment: IconAlignment.end,
        ),
      ],
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;
  final VoidCallback onSeeAll;
  const _AchievementsGrid({required this.achievements, required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      final state = context.watch<AppState>();
      return PremiumCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Text(
          state.tr(
              ru: 'Первые достижения появятся после нескольких уроков',
              kk: 'Алғашқы жетістіктер бірнеше сабақтан кейін пайда болады',
              en: 'Your first achievements will appear after a few lessons'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
      );
    }

    final state = context.watch<AppState>();
    // One next milestone per area is useful; eleven tiny locked tiles are not.
    final candidates = <Achievement>[];
    for (final category in AchievementCategory.values) {
      final group = achievements.where((a) => a.category == category).toList();
      if (group.isEmpty) continue;
      final upcoming = group.where((a) => !a.isUnlocked).toList()
        ..sort((a, b) => a.requiredValue.compareTo(b.requiredValue));
      candidates.add(upcoming.isNotEmpty ? upcoming.first : group.last);
    }
    candidates.sort((a, b) {
      final aProgress = achievementProgress(state, a) / a.requiredValue;
      final bProgress = achievementProgress(state, b) / b.requiredValue;
      return bProgress.compareTo(aProgress);
    });
    final preview = candidates.take(3).toList();

    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(builder: (context, constraints) {
        final largeText = MediaQuery.textScalerOf(context).scale(14) > 18;
        return largeText
            ? Column(
                children: [
                  for (var i = 0; i < preview.length; i++) ...[
                    if (i > 0) const SizedBox(height: 16),
                    _AchievementBadge(
                      achievement: preview[i],
                      horizontal: true,
                      onTap: onSeeAll,
                    ),
                  ],
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  for (var i = 0; i < preview.length; i++) ...[
                    if (i > 0) const SizedBox(width: 12),
                    Expanded(
                      child: _AchievementBadge(
                        achievement: preview[i],
                        onTap: onSeeAll,
                      ),
                    ),
                  ],
                ],
              );
      }),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  final bool horizontal;
  final VoidCallback onTap;
  const _AchievementBadge({
    required this.achievement,
    required this.onTap,
    this.horizontal = false,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final title = achievementTitle(state, achievement);
    final progress = achievementProgress(state, achievement);
    final status = achievement.isUnlocked
        ? state.tr(ru: 'Получено', kk: 'Алынды', en: 'Earned')
        : '$progress / ${achievement.requiredValue}';
    final caption = Column(
      crossAxisAlignment:
          horizontal ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          title,
          textAlign: horizontal ? TextAlign.start : TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            height: 1.25,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 4),
        Text(status,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            )),
      ],
    );
    return Semantics(
      button: true,
      label: '$title, $status',
      excludeSemantics: true,
      onTap: onTap,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: horizontal
              ? Row(children: [
                  AchievementEmblem(achievement: achievement, size: 52),
                  const SizedBox(width: 18),
                  Expanded(child: caption),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textGrey),
                ])
              : Column(mainAxisSize: MainAxisSize.min, children: [
                  AchievementEmblem(achievement: achievement, size: 58),
                  const SizedBox(height: 12),
                  caption,
                ]),
        ),
      ),
    );
  }
}
