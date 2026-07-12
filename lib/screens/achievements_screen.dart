import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';

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
    final achievements = context.watch<AppState>().achievements;
    final cats = [
      AchievementCategory.lessons,
      AchievementCategory.quran,
      AchievementCategory.rules,
      AchievementCategory.streak
    ];
    final labels = ['Уроки', 'Коран', 'Правила', 'Страйк'];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Достижения',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.pistachio,
          unselectedLabelColor: AppColors.textGrey,
          indicatorColor: AppColors.pistachio,
          labelStyle: const TextStyle(
              fontFamily: 'Nunito', fontWeight: FontWeight.w700, fontSize: 13),
          tabs: labels.map((l) => Tab(text: l)).toList(),
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: cats.map((cat) {
          final catAchievements =
              achievements.where((a) => a.category == cat).toList();
          final unlocked = catAchievements.where((a) => a.isUnlocked).length;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    Text('Получено: $unlocked из ${catAchievements.length}',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            color: AppColors.textGrey)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: catAchievements.isEmpty
                              ? 0
                              : unlocked / catAchievements.length,
                          minHeight: 6,
                          backgroundColor: AppColors.pistachioLight,
                          valueColor: const AlwaysStoppedAnimation<Color>(
                              AppColors.pistachio),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: catAchievements.length,
                  itemBuilder: (ctx, i) =>
                      _AchievementTile(achievement: catAchievements[i]),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _AchievementTile extends StatelessWidget {
  final Achievement achievement;
  const _AchievementTile({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final isUnlocked = achievement.isUnlocked;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isUnlocked
            ? AppColors.pistachioLight.withValues(alpha: 0.35)
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUnlocked ? AppColors.pistachio : AppColors.border,
          width: isUnlocked ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: isUnlocked
                      ? AppColors.pistachio
                      : AppColors.backgroundGrey,
                  shape: BoxShape.circle,
                ),
                child: Icon(achievement.icon,
                    color: isUnlocked ? Colors.white : AppColors.textGrey,
                    size: 28),
              ),
              if (!isUnlocked)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.35),
                        shape: BoxShape.circle),
                    child: const Icon(Icons.lock_rounded,
                        color: Colors.white, size: 22),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(achievement.title,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color:
                          isUnlocked ? AppColors.textDark : AppColors.textGrey,
                    )),
                Text(achievement.description,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: AppColors.textGrey)),
                if (achievement.unlockedAt != null)
                  Text('Получено: ${_formatDate(achievement.unlockedAt!)}',
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          color: AppColors.pistachio)),
              ],
            ),
          ),
          if (isUnlocked)
            const Icon(Icons.check_circle_rounded,
                color: AppColors.pistachio, size: 28),
        ],
      ),
    );
  }

  String _formatDate(DateTime d) =>
      '${d.day}.${d.month.toString().padLeft(2, '0')}.${d.year}';
}
