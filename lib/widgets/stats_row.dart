import 'package:flutter/material.dart';
import '../utils/colors.dart';

class StatsRow extends StatelessWidget {
  final int streak;
  final int xp;
  final int level;
  final int hearts;
  final int energy;
  final bool isPremium;
  final VoidCallback? onHeartsTap;
  final VoidCallback? onStreakTap;

  const StatsRow({
    super.key,
    required this.streak,
    required this.xp,
    required this.level,
    required this.hearts,
    required this.energy,
    this.isPremium = false,
    this.onHeartsTap,
    this.onStreakTap,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _StatChip(
          icon: Icons.local_fire_department_rounded,
          value: '$streak',
          color: AppColors.coral,
          onTap: onStreakTap,
        ),
        _StatChip(
          icon: Icons.bolt_rounded,
          value: '$xp',
          color: AppColors.gold,
        ),
        _StatChip(
          icon: Icons.diamond_rounded,
          value: '$level',
          color: AppColors.pistachio,
        ),
        _StatChip(
          icon: Icons.battery_charging_full_rounded,
          value: '$energy',
          color: AppColors.navy,
        ),
        _StatChip(
          icon:
              isPremium ? Icons.all_inclusive_rounded : Icons.favorite_rounded,
          value: isPremium ? 'MAX' : '$hearts',
          color: AppColors.error,
          onTap: onHeartsTap,
        ),
      ],
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final Color color;
  final VoidCallback? onTap;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color, size: 23),
            const SizedBox(width: 4),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class LevelProgressBar extends StatelessWidget {
  final int level;
  final double progress;

  const LevelProgressBar(
      {super.key, required this.level, required this.progress});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Уровень $level',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.textGrey,
              ),
            ),
            Text(
              '${(progress * 100).toInt()}%',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: AppColors.pistachio,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: LinearProgressIndicator(
            value: progress,
            minHeight: 10,
            backgroundColor: AppColors.pistachioLight,
            valueColor:
                const AlwaysStoppedAnimation<Color>(AppColors.pistachio),
          ),
        ),
      ],
    );
  }
}

class CourseProgressCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final int completed;
  final int total;
  final VoidCallback? onTap;

  const CourseProgressCard({
    super.key,
    required this.title,
    required this.icon,
    required this.completed,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? completed / total : 0.0;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 6,
                offset: const Offset(0, 2)),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: AppColors.pistachio, size: 36),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark)),
                  const SizedBox(height: 4),
                  Text('$completed из $total уроков',
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          color: AppColors.textGrey)),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 8,
                      backgroundColor: AppColors.pistachioLight,
                      valueColor: const AlwaysStoppedAnimation<Color>(
                          AppColors.pistachio),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded,
                color: AppColors.pistachio, size: 28),
          ],
        ),
      ),
    );
  }
}
