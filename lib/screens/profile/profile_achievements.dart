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
        SectionLabel(
            text: state.tr(
                ru: 'Достижения', kk: 'Жетістіктер', en: 'Achievements')),
        GestureDetector(
          onTap: onSeeAll,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.tr(ru: 'Все', kk: 'Барлығы', en: 'All'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.sky,
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.sky),
            ],
          ),
        ),
      ],
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;
  const _AchievementsGrid({required this.achievements});

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

    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
        childAspectRatio: 0.72,
        children: [
          for (final a in achievements) _AchievementBadge(achievement: a),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final bool unlocked = achievement.isUnlocked;
    final String glyph = achievement.category == AchievementCategory.quran
        ? 'ق'
        : _toArabicDigits(achievement.requiredValue);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: unlocked
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF8CA6B), Color(0xFFEFAE2E)],
                  )
                : null,
            color: unlocked ? null : AppColors.backgroundGrey,
            border: unlocked
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Text(
            glyph,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: unlocked ? Colors.white : AppColors.textLight,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          achievement.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: unlocked ? AppColors.textDark : AppColors.textLight,
          ),
        ),
      ],
    );
  }
}
