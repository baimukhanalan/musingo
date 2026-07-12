import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../models/lesson.dart';
import '../services/haptics_service.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/custom_button.dart';

class LessonReviewScreen extends StatefulWidget {
  final Map<String, dynamic> result;
  const LessonReviewScreen({super.key, required this.result});

  @override
  State<LessonReviewScreen> createState() => _LessonReviewScreenState();
}

class _LessonReviewScreenState extends State<LessonReviewScreen> {
  int _openedChests = 0;

  @override
  Widget build(BuildContext context) {
    final result = widget.result;
    final lesson = result['lesson'] as Lesson?;
    final xpEarned = result['xpEarned'] as int? ?? 25;
    final streakBonus = result['streakBonus'] as int? ?? 0;
    final heartsLost = result['heartsLost'] as int? ?? 0;
    final newStreak = result['newStreak'] as int? ?? 0;
    final energyEarned = result['energyEarned'] as int? ?? 0;
    final showChests = lesson?.course == CourseType.quran;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              const Text('Урок завершён!',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark),
                      textAlign: TextAlign.center)
                  .animate()
                  .fadeIn(duration: 400.ms)
                  .slideY(begin: -0.2, end: 0),
              const SizedBox(height: 8),
              const Text('Ты молодец, продолжай в том же духе!',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      color: AppColors.textGrey),
                  textAlign: TextAlign.center),
              const SizedBox(height: 24),
              CatCharacter(
                      mood: heartsLost == 0 ? CatMood.praise : CatMood.success,
                      size: 180)
                  .animate()
                  .scale(
                      begin: const Offset(0.5, 0.5),
                      duration: 600.ms,
                      curve: Curves.elasticOut),
              const SizedBox(height: 28),
              Row(
                children: [
                  _ResultTile(
                      icon: Icons.bolt_rounded,
                      label: 'XP получено',
                      value: '+$xpEarned',
                      color: AppColors.gold),
                  const SizedBox(width: 10),
                  _ResultTile(
                      icon: Icons.local_fire_department_rounded,
                      label: 'Страйк',
                      value: '$newStreak дн.',
                      color: AppColors.coral),
                  const SizedBox(width: 10),
                  _ResultTile(
                      icon: Icons.battery_charging_full_rounded,
                      label: 'Энергия',
                      value: '+$energyEarned',
                      color: AppColors.navy),
                ],
              ).animate().fadeIn(delay: 400.ms),
              if (heartsLost > 0) ...[
                const SizedBox(height: 10),
                Text('Потеряно жизней: $heartsLost',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.error)),
              ],
              if (streakBonus > 0) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.goldLight,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                        color: AppColors.gold.withValues(alpha: 0.4)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.celebration_rounded,
                          color: AppColors.gold, size: 24),
                      const SizedBox(width: 10),
                      Expanded(
                          child: Text('Бонус за страйк: +$streakBonus XP!',
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark))),
                    ],
                  ),
                ).animate().fadeIn(delay: 600.ms),
              ],
              if (showChests) ...[
                const SizedBox(height: 18),
                _ChestRewardRow(
                  opened: _openedChests,
                  onOpen: () {
                    HapticsService.chest();
                    setState(() => _openedChests++);
                  },
                ).animate().fadeIn(delay: 650.ms),
              ],
              const Spacer(),
              CustomButton(
                text: showChests && _openedChests < 3
                    ? 'Открой все ящики'
                    : 'Продолжить',
                onPressed: showChests && _openedChests < 3
                    ? null
                    : () => Navigator.pushNamedAndRemoveUntil(
                        context, '/home', (r) => false),
              ).animate().fadeIn(delay: 700.ms),
              const SizedBox(height: 12),
              CustomButton(
                text: 'Повторить урок',
                isOutlined: true,
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
              ).animate().fadeIn(delay: 800.ms),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _ChestRewardRow extends StatelessWidget {
  final int opened;
  final VoidCallback onOpen;

  const _ChestRewardRow({required this.opened, required this.onOpen});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.skyLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.sky.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          const Text(
            'Награда за суру',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Row(
            children: List.generate(3, (index) {
              final isOpened = index < opened;
              final canOpen = index == opened;
              final isPrize = index == 2;
              return Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: GestureDetector(
                    onTap: canOpen ? onOpen : null,
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      height: 76,
                      decoration: BoxDecoration(
                        color: isOpened ? AppColors.goldLight : AppColors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: isOpened ? AppColors.gold : AppColors.border,
                          width: 2,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            isOpened
                                ? (isPrize
                                    ? Icons.workspace_premium_rounded
                                    : Icons.card_giftcard_rounded)
                                : Icons.inventory_2_rounded,
                            color: isOpened ? AppColors.gold : AppColors.navy,
                            size: 28,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            isOpened
                                ? (isPrize ? '+25 энергии' : '+5 XP')
                                : 'Открыть',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w900,
                              color: isOpened
                                  ? AppColors.textDark
                                  : (canOpen
                                      ? AppColors.navy
                                      : AppColors.textGrey),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _ResultTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _ResultTile(
      {required this.icon,
      required this.label,
      required this.value,
      required this.color});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 26),
            const SizedBox(height: 4),
            Text(value,
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: color)),
            Text(label,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    color: AppColors.textGrey)),
          ],
        ),
      ),
    );
  }
}
