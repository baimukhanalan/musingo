import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_label.dart';
import 'profile/achievement_presentation.dart';

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
      state.tr(ru: 'Серия', kk: 'Серия', en: 'Streak'),
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
    final title = Text(
      state.tr(ru: 'Достижения', kk: 'Жетістіктер', en: 'Achievements'),
      style: const TextStyle(
        fontFamily: 'Nunito',
        fontSize: 22,
        fontWeight: FontWeight.w900,
        color: AppColors.navyDark,
      ),
    );
    final counter = Container(
      padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(24),
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
              fontWeight: FontWeight.w800,
              color: AppColors.white,
            ),
          ),
        ],
      ),
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 18, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
            icon:
                const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
          ),
          Expanded(
            child: MediaQuery.textScalerOf(context).scale(14) > 18
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      title,
                      const SizedBox(height: 8),
                      counter,
                    ],
                  )
                : Row(
                    children: [
                      Expanded(child: title),
                      const SizedBox(width: 10),
                      counter,
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
        isScrollable: true,
        tabAlignment: TabAlignment.start,
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
        labelPadding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
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
            final singleColumn = constraints.maxWidth < 340 ||
                MediaQuery.textScalerOf(context).scale(14) > 18;
            final itemWidth = singleColumn
                ? constraints.maxWidth
                : (constraints.maxWidth - spacing) / 2;
            return Wrap(
              spacing: spacing,
              runSpacing: spacing,
              children: [
                for (final a in achievements)
                  SizedBox(
                    width: itemWidth,
                    child: _AchievementBadgeCard(
                      achievement: a,
                      horizontal: singleColumn,
                    ),
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
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
            text: state.tr(ru: 'Получено', kk: 'Алынды', en: 'Earned'),
          ),
          const SizedBox(height: 6),
          Text(
            '$unlocked / $total',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 24,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: percent,
              minHeight: 7,
              backgroundColor: AppColors.backgroundGrey,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.navy),
            ),
          ),
        ],
      ),
    );
  }
}

/// Full requirements stay readable at every text scale; no fixed text heights.
class _AchievementBadgeCard extends StatelessWidget {
  final Achievement achievement;
  final bool horizontal;
  const _AchievementBadgeCard({
    required this.achievement,
    required this.horizontal,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final title = achievementTitle(state, achievement);
    final description = achievementDescription(state, achievement);
    final caption = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            height: 1.2,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          description,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            height: 1.4,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 12),
        _StatusChip(achievement: achievement),
      ],
    );
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: achievement.isUnlocked
              ? AppColors.gold.withValues(alpha: 0.45)
              : AppColors.border.withValues(alpha: 0.6),
        ),
      ),
      child: horizontal
          ? Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AchievementEmblem(achievement: achievement),
                const SizedBox(width: 18),
                Expanded(child: caption),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AchievementEmblem(achievement: achievement),
                const SizedBox(height: 18),
                caption,
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

    final Color bg = unlocked ? AppColors.goldLight : AppColors.skyLight;
    final Color fg = unlocked ? const Color(0xFF8A6410) : AppColors.navy;
    final IconData icon =
        unlocked ? Icons.check_circle_rounded : Icons.flag_outlined;
    final String label = unlocked
        ? (achievement.unlockedAt != null
            ? _formatDate(achievement.unlockedAt!)
            : state.tr(ru: 'Получено', kk: 'Алынды', en: 'Earned'))
        : '${achievementProgress(state, achievement)} / ${achievement.requiredValue}';

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
