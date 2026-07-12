import 'package:flutter/material.dart';

enum AchievementCategory { lessons, quran, rules, streak }

class Achievement {
  final String id;
  final String title;
  final String description;
  final AchievementCategory category;
  final IconData icon;
  final int requiredValue;
  final bool isUnlocked;
  final DateTime? unlockedAt;

  const Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.icon,
    required this.requiredValue,
    this.isUnlocked = false,
    this.unlockedAt,
  });

  Achievement copyWith({bool? isUnlocked, DateTime? unlockedAt}) => Achievement(
        id: id,
        title: title,
        description: description,
        category: category,
        icon: icon,
        requiredValue: requiredValue,
        isUnlocked: isUnlocked ?? this.isUnlocked,
        unlockedAt: unlockedAt ?? this.unlockedAt,
      );

  static List<Achievement> defaults() => [
        const Achievement(
            id: 'lessons_10',
            title: '10 уроков',
            description: 'Пройди 10 уроков',
            category: AchievementCategory.lessons,
            icon: Icons.school_rounded,
            requiredValue: 10),
        const Achievement(
            id: 'lessons_50',
            title: '50 уроков',
            description: 'Пройди 50 уроков',
            category: AchievementCategory.lessons,
            icon: Icons.workspace_premium_rounded,
            requiredValue: 50),
        const Achievement(
            id: 'lessons_100',
            title: '100 уроков',
            description: 'Пройди 100 уроков',
            category: AchievementCategory.lessons,
            icon: Icons.emoji_events_rounded,
            requiredValue: 100),
        const Achievement(
            id: 'ayats_10',
            title: '10 аятов',
            description: 'Изучи 10 аятов',
            category: AchievementCategory.quran,
            icon: Icons.menu_book_rounded,
            requiredValue: 10),
        const Achievement(
            id: 'ayats_50',
            title: '50 аятов',
            description: 'Изучи 50 аятов',
            category: AchievementCategory.quran,
            icon: Icons.nightlight_round,
            requiredValue: 50),
        const Achievement(
            id: 'ayats_100',
            title: '100 аятов',
            description: 'Изучи 100 аятов',
            category: AchievementCategory.quran,
            icon: Icons.star_rounded,
            requiredValue: 100),
        const Achievement(
            id: 'modules_5',
            title: '5 модулей',
            description: 'Изучи 5 модулей правил',
            category: AchievementCategory.rules,
            icon: Icons.checklist_rounded,
            requiredValue: 5),
        const Achievement(
            id: 'modules_10',
            title: '10 модулей',
            description: 'Изучи 10 модулей правил',
            category: AchievementCategory.rules,
            icon: Icons.verified_rounded,
            requiredValue: 10),
        const Achievement(
            id: 'streak_7',
            title: '7 дней подряд',
            description: 'Занимайся 7 дней подряд',
            category: AchievementCategory.streak,
            icon: Icons.local_fire_department_rounded,
            requiredValue: 7),
        const Achievement(
            id: 'streak_30',
            title: '30 дней подряд',
            description: 'Занимайся 30 дней подряд',
            category: AchievementCategory.streak,
            icon: Icons.fitness_center_rounded,
            requiredValue: 30),
        const Achievement(
            id: 'streak_100',
            title: '100 дней подряд',
            description: 'Занимайся 100 дней подряд',
            category: AchievementCategory.streak,
            icon: Icons.diamond_rounded,
            requiredValue: 100),
      ];
}
