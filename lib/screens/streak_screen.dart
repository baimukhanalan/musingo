import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = context.watch<AppState>().user;
    if (user == null) return const SizedBox.shrink();

    final streak = user.streak;
    int nextBonus = 7;
    if (streak >= 7) nextBonus = 30;
    if (streak >= 30) nextBonus = 100;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Мой страйк',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            CatCharacter(
                mood: streak > 0 ? CatMood.praise : CatMood.support, size: 150),
            const SizedBox(height: 20),
            Text('$streak',
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 72,
                    fontWeight: FontWeight.w800,
                    color: AppColors.coral)),
            const Text('дней подряд',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    color: AppColors.textGrey)),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.errorLight,
                borderRadius: BorderRadius.circular(16),
                border:
                    Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('До бонуса ($nextBonus дней)',
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.textDark)),
                      Text('$streak/$nextBonus',
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.coral)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: (streak / nextBonus).clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: AppColors.errorLight,
                      valueColor:
                          const AlwaysStoppedAnimation<Color>(AppColors.coral),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const _StreakBonusList(),
            const SizedBox(height: 20),
            _StreakCalendar(streak: streak),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _StreakBonusList extends StatelessWidget {
  const _StreakBonusList();

  @override
  Widget build(BuildContext context) {
    final bonuses = [
      {'days': 7, 'xp': 10, 'icon': Icons.star_rounded},
      {'days': 30, 'xp': 50, 'icon': Icons.fitness_center_rounded},
      {'days': 100, 'xp': 200, 'icon': Icons.diamond_rounded},
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Бонусы за страйк',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        const SizedBox(height: 10),
        Row(
          children: bonuses
              .map((b) => Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        children: [
                          Icon(b['icon'] as IconData,
                              color: AppColors.gold, size: 24),
                          const SizedBox(height: 4),
                          Text('${b['days']} дн.',
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.textDark)),
                          Text('+${b['xp']} XP',
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.pistachio)),
                        ],
                      ),
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _StreakCalendar extends StatelessWidget {
  final int streak;
  const _StreakCalendar({required this.streak});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    const daysToShow = 21;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Последние 3 недели',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 17,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        const SizedBox(height: 10),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            mainAxisSpacing: 6,
            crossAxisSpacing: 6,
            childAspectRatio: 1,
          ),
          itemCount: daysToShow,
          itemBuilder: (ctx, i) {
            final day = now.subtract(Duration(days: daysToShow - 1 - i));
            final daysAgo = daysToShow - 1 - i;
            final isStudied = daysAgo < streak;
            final isToday = daysAgo == 0;

            return Container(
              decoration: BoxDecoration(
                color: isStudied
                    ? AppColors.pistachio
                    : (isToday
                        ? AppColors.pistachioLight
                        : AppColors.backgroundGrey),
                shape: BoxShape.circle,
                border: isToday
                    ? Border.all(color: AppColors.pistachio, width: 2)
                    : null,
              ),
              child: Center(
                child: isStudied
                    ? const Icon(Icons.local_fire_department_rounded,
                        color: Colors.white, size: 16)
                    : Text('${day.day}',
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isToday
                                ? AppColors.pistachio
                                : AppColors.textGrey)),
              ),
            );
          },
        ),
      ],
    );
  }
}
