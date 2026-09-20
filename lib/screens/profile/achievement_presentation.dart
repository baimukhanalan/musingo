import 'package:flutter/material.dart';

import '../../models/achievement.dart';
import '../../models/lesson.dart';
import '../../services/app_state.dart';
import '../../utils/colors.dart';

/// Presentation is localized without changing persisted achievement identities.
String achievementTitle(AppState state, Achievement achievement) {
  final n = achievement.requiredValue;
  return switch (achievement.category) {
    AchievementCategory.lessons =>
      state.tr(ru: '$n уроков', kk: '$n сабақ', en: '$n lessons'),
    AchievementCategory.quran =>
      state.tr(ru: '$n аятов', kk: '$n аят', en: '$n verses'),
    AchievementCategory.rules =>
      state.tr(ru: '$n модулей', kk: '$n модуль', en: '$n modules'),
    AchievementCategory.streak => state.tr(
        ru: '$n дней подряд', kk: '$n күн қатарынан', en: '$n-day streak'),
  };
}

String achievementDescription(AppState state, Achievement achievement) {
  final n = achievement.requiredValue;
  return switch (achievement.category) {
    AchievementCategory.lessons => state.tr(
        ru: 'Заверши $n уроков',
        kk: '$n сабақты аяқтаңыз',
        en: 'Complete $n lessons'),
    AchievementCategory.quran => state.tr(
        ru: 'Изучи $n аятов', kk: '$n аятты үйреніңіз', en: 'Learn $n verses'),
    AchievementCategory.rules => state.tr(
        ru: 'Заверши $n модулей правил',
        kk: '$n ереже модулін аяқтаңыз',
        en: 'Complete $n rules modules'),
    AchievementCategory.streak => state.tr(
        ru: 'Занимайся $n дней подряд',
        kk: '$n күн қатарынан оқыңыз',
        en: 'Study $n days in a row'),
  };
}

int achievementProgress(AppState state, Achievement achievement) {
  final progress = switch (achievement.category) {
    AchievementCategory.lessons => state.user?.totalLessons ?? 0,
    AchievementCategory.quran => state.user?.learnedAyats ?? 0,
    AchievementCategory.rules =>
      state.getCourse(CourseType.rules)?.completedLessons ?? 0,
    AchievementCategory.streak => state.user?.streak ?? 0,
  };
  return progress.clamp(0, achievement.requiredValue);
}

/// Real vector icons remain recognizable before and after an award is earned.
/// A small lock/check conveys status without turning the whole badge grey.
class AchievementEmblem extends StatelessWidget {
  final Achievement achievement;
  final double size;

  const AchievementEmblem({
    super.key,
    required this.achievement,
    this.size = 64,
  });

  @override
  Widget build(BuildContext context) {
    final unlocked = achievement.isUnlocked;
    final accent = switch (achievement.category) {
      AchievementCategory.lessons => AppColors.navy,
      AchievementCategory.quran => const Color(0xFF378475),
      AchievementCategory.rules => const Color(0xFF7761AA),
      AchievementCategory.streak => const Color(0xFFD77545),
    };
    return SizedBox.square(
      dimension: size,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(size * 0.31),
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: unlocked
                      ? [accent.withValues(alpha: 0.82), accent]
                      : [
                          Color.lerp(Colors.white, accent, 0.09)!,
                          Color.lerp(Colors.white, accent, 0.19)!,
                        ],
                ),
                border: Border.all(
                    color: unlocked
                        ? accent.withValues(alpha: 0.2)
                        : accent.withValues(alpha: 0.12)),
                boxShadow: unlocked
                    ? [
                        BoxShadow(
                          color: accent.withValues(alpha: 0.16),
                          blurRadius: 12,
                          offset: const Offset(0, 5),
                        ),
                      ]
                    : null,
              ),
              child: Icon(achievement.icon,
                  color: unlocked ? Colors.white : accent, size: size * 0.52),
            ),
          ),
          Positioned(
            right: -3,
            bottom: -3,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: unlocked ? AppColors.goldLight : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: Icon(
                unlocked ? Icons.check_rounded : Icons.lock_outline_rounded,
                size: size * 0.20,
                color: unlocked ? const Color(0xFF856019) : AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
