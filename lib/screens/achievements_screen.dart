import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_label.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final achievements = state.achievements;
    final cats = [
      AchievementCategory.lessons,
      AchievementCategory.quran,
      AchievementCategory.rules,
      AchievementCategory.streak
    ];
    final labels = [
      state.tr(ru: 'Уроки', kk: 'Сабақтар', en: 'Lessons'),
      state.tr(ru: 'Коран', kk: 'Құран', en: 'Quran'),
      state.tr(ru: 'Правила', kk: 'Ережелер', en: 'Rules'),
      state.tr(ru: 'Страйк', kk: 'Страйк', en: 'Streak'),
    ];

    final totalUnlocked = achievements.where((a) => a.isUnlocked).length;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(
                unlocked: totalUnlocked,
                total: achievements.length,
                onBack: () => Navigator.pop(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 6, 18, 6),
                child: _CategoryPills(
                  controller: _tabController,
                  labels: labels,
                ),
              ),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: cats.map((cat) {
                    final catAchievements =
                        achievements.where((a) => a.category == cat).toList();
                    return _CategoryView(achievements: catAchievements);
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Navy w900 title with back control and a global "получено" counter.
class _Header extends StatelessWidget {
  final int unlocked;
  final int total;
  final VoidCallback onBack;

  const _Header({
    required this.unlocked,
    required this.total,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 18, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
            icon:
                const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
          ),
          Expanded(
            child: Text(
              state.tr(
                  ru: 'Достижения', kk: 'Жетістіктер', en: 'Achievements'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark,
              ),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.navyDark,
              borderRadius: BorderRadius.circular(30),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.emoji_events_rounded,
                    color: AppColors.gold, size: 15),
                const SizedBox(width: 5),
                Text(
                  '$unlocked / $total',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Pill category selector driving the [TabController]. Purely a restyle of the
/// original TabBar — selection/animation stay owned by the controller.
class _CategoryPills extends StatelessWidget {
  final TabController controller;
  final List<String> labels;

  const _CategoryPills({required this.controller, required this.labels});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.ivory.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: TabBar(
        controller: controller,
        isScrollable: false,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        indicatorColor: Colors.transparent,
        overlayColor: WidgetStateProperty.all(Colors.transparent),
        splashFactory: NoSplash.splashFactory,
        indicator: BoxDecoration(
          color: AppColors.navyDark,
          borderRadius: BorderRadius.circular(30),
        ),
        labelColor: AppColors.white,
        unselectedLabelColor: AppColors.textLight,
        labelPadding: const EdgeInsets.symmetric(vertical: 9, horizontal: 2),
        labelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
        unselectedLabelStyle: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12.5,
          fontWeight: FontWeight.w800,
        ),
        tabs: labels
            .map((l) => Tab(height: 34, child: Text(l)))
            .toList(growable: false),
      ),
    );
  }
}

/// Single category page: progress summary card + grid of premium badges.
class _CategoryView extends StatelessWidget {
  final List<Achievement> achievements;
  const _CategoryView({required this.achievements});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    if (achievements.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Text(
            state.tr(
                ru: 'Достижений в этом разделе пока нет',
                kk: 'Бұл бөлімде әзірге жетістіктер жоқ',
                en: 'No achievements in this section yet'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
        ),
      );
    }

    final unlocked = achievements.where((a) => a.isUnlocked).length;
    final total = achievements.length;
    final percent = total == 0 ? 0.0 : unlocked / total;

    return ListView(
      padding: const EdgeInsets.fromLTRB(18, 8, 18, 28),
      children: [
        _SummaryCard(unlocked: unlocked, total: total, percent: percent),
        const SizedBox(height: 18),
        SectionLabel(
            text: state.tr(ru: 'Бейджи', kk: 'Белгішелер', en: 'Badges')),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            const spacing = 12.0;
            final itemWidth = (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final a in achievements)
                  SizedBox(
                    width: itemWidth,
                    child: _AchievementBadgeCard(achievement: a),
                  ),
              ],
            );
          },
        ),
      ],
    );
  }
}

class _SummaryCard extends StatelessWidget {
  final int unlocked;
  final int total;
  final double percent;

  const _SummaryCard({
    required this.unlocked,
    required this.total,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(
                        text: state.tr(
                            ru: 'Получено', kk: 'Алынды', en: 'Earned')),
                    const SizedBox(height: 6),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.baseline,
                      textBaseline: TextBaseline.alphabetic,
                      children: [
                        Text(
                          '$unlocked',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 30,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navyDark,
                            height: 1,
                          ),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          state.tr(
                              ru: 'из $total',
                              kk: '$total ішінен',
                              en: 'of $total'),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.skyLight,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  '${(percent * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 8,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.sky),
            ),
          ),
        ],
      ),
    );
  }
}

/// Premium achievement badge card: gold-gradient badge when unlocked (with an
/// Arabic-numeral glyph like the profile grid), muted + locked otherwise, plus
/// a получено/заблокировано status row.
class _AchievementBadgeCard extends StatelessWidget {
  final Achievement achievement;
  const _AchievementBadgeCard({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final bool unlocked = achievement.isUnlocked;
    final String glyph = achievement.category == AchievementCategory.quran
        ? 'ق'
        : _toArabicDigits(achievement.requiredValue);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: unlocked ? AppColors.gold.withValues(alpha: 0.5)
              : AppColors.border,
          width: unlocked ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.05),
            blurRadius: 22,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Stack(
            children: [
              Container(
                width: 58,
                height: 58,
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
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  glyph,
                  style: TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 24,
                    fontWeight: FontWeight.w700,
                    color: unlocked ? Colors.white : AppColors.textLight,
                  ),
                ),
              ),
              if (!unlocked)
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.navyDark,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 12),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            achievement.title,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15.5,
              fontWeight: FontWeight.w900,
              color: unlocked ? AppColors.textDark : AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            height: 34,
            child: Text(
              achievement.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12.5,
                height: 1.25,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
          ),
          const SizedBox(height: 10),
          _StatusChip(achievement: achievement),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final Achievement achievement;
  const _StatusChip({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bool unlocked = achievement.isUnlocked;

    final Color bg = unlocked
        ? AppColors.goldLight
        : AppColors.backgroundGrey;
    final Color fg = unlocked ? const Color(0xFF8A6410) : AppColors.textLight;
    final IconData icon =
        unlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded;
    final String label = unlocked
        ? (achievement.unlockedAt != null
            ? _formatDate(achievement.unlockedAt!)
            : state.tr(ru: 'Получено', kk: 'Алынды', en: 'Earned'))
        : state.tr(ru: 'Заблокировано', kk: 'Жабық', en: 'Locked');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: fg),
          const SizedBox(width: 5),
          Flexible(
            child: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 11.5,
                fontWeight: FontWeight.w800,
                color: fg,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}

String _toArabicDigits(int n) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n
      .toString()
      .split('')
      .map((ch) {
        final code = ch.codeUnitAt(0) - 48;
        return (code >= 0 && code <= 9) ? digits[code] : ch;
      })
      .join();
}
