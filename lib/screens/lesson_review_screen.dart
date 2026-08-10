import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../models/lesson.dart';
import '../services/app_state.dart';
import '../services/haptics_service.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_label.dart';
import '../widgets/stat_badge.dart';

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
    final weakKnowledgeCount = result['weakKnowledgeCount'] as int? ?? 0;
    final nextReviewAt = result['nextReviewAt'] as DateTime?;
    final showChests = lesson?.course == CourseType.quran;
    final state = context.watch<AppState>();
    final isGuest = state.isGuest;

    final perfect = heartsLost == 0;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.only(top: 12, bottom: 20),
                    children: [
                      SectionLabel(
                        text: perfect
                            ? state.tr(
                                ru: 'Идеально · без ошибок',
                                kk: 'Мінсіз · қатесіз',
                                en: 'Perfect · no mistakes')
                            : state.tr(
                                ru: 'Урок завершён',
                                kk: 'Сабақ аяқталды',
                                en: 'Lesson complete'),
                      ).animate().fadeIn(duration: 300.ms),
                      const SizedBox(height: 8),
                      Text(
                        state.tr(
                          ru: 'Урок завершён!',
                          kk: 'Сабақ аяқталды!',
                          en: 'Lesson complete!',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 30,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navyDark,
                          height: 1.1,
                        ),
                        textAlign: TextAlign.center,
                      )
                          .animate()
                          .fadeIn(duration: 400.ms)
                          .slideY(begin: -0.2, end: 0),
                      const SizedBox(height: 6),
                      Text(
                        state.tr(
                          ru: 'Ты молодец, продолжай в том же духе!',
                          kk: 'Жарайсың, осылай жалғастыра бер!',
                          en: 'Great job, keep it up!',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      _MascotGlow(
                        mood: perfect ? CatMood.praise : CatMood.success,
                      )
                          .animate()
                          .scale(
                            begin: const Offset(0.5, 0.5),
                            duration: 600.ms,
                            curve: Curves.elasticOut,
                          ),
                      const SizedBox(height: 24),

                      // Итоговые статы урока в белой премиум-карточке.
                      PremiumCard(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 18),
                        child: Row(
                          children: [
                            Expanded(
                              child: StatBadge(
                                icon: Icons.bolt_rounded,
                                value: '+$xpEarned',
                                label: state.tr(
                                    ru: 'XP получено',
                                    kk: 'XP алынды',
                                    en: 'XP earned'),
                                accent: AppColors.gold,
                              ),
                            ),
                            Expanded(
                              child: StatBadge(
                                icon: Icons.local_fire_department_rounded,
                                value: state.tr(
                                    ru: '$newStreak дн.',
                                    kk: '$newStreak күн',
                                    en: '$newStreak d'),
                                label: state.tr(
                                    ru: 'Страйк', kk: 'Страйк', en: 'Streak'),
                                accent: AppColors.coral,
                              ),
                            ),
                            Expanded(
                              child: StatBadge(
                                icon: Icons.battery_charging_full_rounded,
                                value: '+$energyEarned',
                                label: state.tr(
                                    ru: 'Энергия',
                                    kk: 'Энергия',
                                    en: 'Energy'),
                                accent: AppColors.navy,
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1, end: 0),

                      if (heartsLost > 0) ...[
                        const SizedBox(height: 12),
                        _InfoPill(
                          icon: Icons.favorite_rounded,
                          color: AppColors.error,
                          text: state.tr(
                            ru: 'Потеряно жизней: $heartsLost',
                            kk: 'Жоғалған жандар: $heartsLost',
                            en: 'Hearts lost: $heartsLost',
                          ),
                        ),
                      ],

                      if (nextReviewAt != null) ...[
                        const SizedBox(height: 12),
                        _InfoPill(
                          icon: Icons.event_repeat_rounded,
                          color: AppColors.navy,
                          text: weakKnowledgeCount > 0
                              ? state.tr(
                                  ru: '$weakKnowledgeCount слабых мест вернутся ${_reviewDayLabel(nextReviewAt, state)}',
                                  kk: '$weakKnowledgeCount әлсіз тұс ${_reviewDayLabel(nextReviewAt, state)} қайта оралады',
                                  en: '$weakKnowledgeCount weak spots return ${_reviewDayLabel(nextReviewAt, state)}')
                              : state.tr(
                                  ru: 'Повторение назначено ${_reviewDayLabel(nextReviewAt, state)}',
                                  kk: 'Қайталау ${_reviewDayLabel(nextReviewAt, state)} белгіленді',
                                  en: 'Review scheduled ${_reviewDayLabel(nextReviewAt, state)}'),
                        ),
                      ],

                      if (streakBonus > 0) ...[
                        const SizedBox(height: 14),
                        PremiumCard(
                          color: AppColors.goldLight,
                          radius: 18,
                          padding: const EdgeInsets.all(16),
                          shadow: [
                            BoxShadow(
                              color: AppColors.gold.withValues(alpha: 0.18),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                          child: Row(
                            children: [
                              const Icon(Icons.celebration_rounded,
                                  color: AppColors.gold, size: 26),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  state.tr(
                                    ru: 'Бонус за страйк: +$streakBonus XP!',
                                    kk: 'Страйк бонусы: +$streakBonus XP!',
                                    en: 'Streak bonus: +$streakBonus XP!',
                                  ),
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 600.ms),
                      ],

                      if (showChests) ...[
                        const SizedBox(height: 16),
                        _ChestRewardCard(
                          opened: _openedChests,
                          xpEarned: xpEarned,
                          energyEarned: energyEarned,
                          onOpen: () {
                            HapticsService.chest();
                            setState(() => _openedChests++);
                          },
                        ).animate().fadeIn(delay: 650.ms),
                      ],
                    ],
                  ),
                ),

                // Кнопки закреплены снизу.
                PremiumButton(
                  // Кнопку больше не блокируем сундуками: награда за урок уже
                  // начислена, а раскрытие ящиков — необязательный бонус-жест.
                  label: state.tr(
                      ru: 'Продолжить', kk: 'Жалғастыру', en: 'Continue'),
                  icon: Icons.arrow_forward_rounded,
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                      context, '/home', (r) => false),
                ).animate().fadeIn(delay: 700.ms),
                const SizedBox(height: 12),
                PremiumButton(
                  label: isGuest
                      ? state.tr(
                          ru: 'Сохранить прогресс',
                          kk: 'Прогресті сақтау',
                          en: 'Save progress')
                      : state.tr(
                          ru: 'Повторить урок',
                          kk: 'Сабақты қайталау',
                          en: 'Repeat lesson'),
                  variant: PremiumButtonVariant.navy,
                  icon: isGuest
                      ? Icons.bookmark_added_rounded
                      : Icons.refresh_rounded,
                  onPressed: isGuest
                      ? () => Navigator.pushNamed(context, '/login')
                      : lesson == null
                          ? null
                          : () => Navigator.pushReplacementNamed(
                                context,
                                '/lesson',
                                arguments: lesson,
                              ),
                ).animate().fadeIn(delay: 800.ms),
                const SizedBox(height: 16),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _reviewDayLabel(DateTime date, AppState state) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final days = target.difference(today).inDays;
  if (days <= 0) {
    return state.tr(ru: 'сегодня', kk: 'бүгін', en: 'today');
  }
  if (days == 1) {
    return state.tr(ru: 'завтра', kk: 'ертең', en: 'tomorrow');
  }
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
}

/// Маскот в мягком круге-глоу — сигнатурная подача главного экрана.
class _MascotGlow extends StatelessWidget {
  final CatMood mood;

  const _MascotGlow({required this.mood});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 180,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 176,
            height: 176,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.sky.withValues(alpha: 0.22),
                  AppColors.sky.withValues(alpha: 0),
                ],
              ),
            ),
          ),
          CatCharacter(mood: mood, size: 172),
        ],
      ),
    );
  }
}

/// Малая пилюля-строка с иконкой (для «жизни»/«повторение»).
class _InfoPill extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String text;

  const _InfoPill({
    required this.icon,
    required this.color,
    required this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: color,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ChestRewardCard extends StatelessWidget {
  final int opened;
  final int xpEarned;
  final int energyEarned;
  final VoidCallback onOpen;

  const _ChestRewardCard({
    required this.opened,
    required this.xpEarned,
    required this.energyEarned,
    required this.onOpen,
  });

  /// Подпись раскрытого ящика — реальная награда за урок, а не выдуманные
  /// «+5 XP», которые нигде не начислялись. Третий ящик показывает энергию.
  String _label(int index, AppState state) {
    if (index == 2) {
      return state.tr(
        ru: '+$energyEarned энергии',
        kk: '+$energyEarned энергия',
        en: '+$energyEarned energy',
      );
    }
    return '+$xpEarned XP';
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      radius: 20,
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          SectionLabel(
              text: state.tr(
                  ru: 'Награда за суру',
                  kk: 'Сүре сыйлығы',
                  en: 'Surah reward')),
          const SizedBox(height: 12),
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
                      height: 82,
                      decoration: BoxDecoration(
                        color:
                            isOpened ? AppColors.goldLight : AppColors.ivory,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isOpened
                              ? AppColors.gold
                              : (canOpen
                                  ? AppColors.sky.withValues(alpha: 0.5)
                                  : AppColors.border),
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
                                ? _label(index, state)
                                : state.tr(
                                    ru: 'Открыть',
                                    kk: 'Ашу',
                                    en: 'Open'),
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
