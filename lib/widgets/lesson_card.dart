import 'package:flutter/material.dart';
import '../models/lesson.dart';
import '../utils/colors.dart';

class LessonCard extends StatelessWidget {
  final Lesson lesson;
  final VoidCallback? onTap;

  const LessonCard({super.key, required this.lesson, this.onTap});

  @override
  Widget build(BuildContext context) {
    final isLocked = lesson.status == LessonStatus.locked;
    final isDone = lesson.status == LessonStatus.completed;
    final isActive = lesson.status == LessonStatus.available ||
        lesson.status == LessonStatus.inProgress;

    Color cardColor;
    Color borderColor;
    Color textColor;
    Widget statusIcon;

    if (isDone) {
      cardColor = AppColors.pistachioLight;
      borderColor = AppColors.pistachio;
      textColor = AppColors.textDark;
      statusIcon = const Icon(Icons.check_circle_rounded,
          color: AppColors.pistachioDark, size: 28);
    } else if (isActive) {
      cardColor = AppColors.white;
      borderColor = AppColors.pistachio;
      textColor = AppColors.textDark;
      statusIcon = Container(
        width: 28,
        height: 28,
        decoration: const BoxDecoration(
          color: AppColors.pistachio,
          shape: BoxShape.circle,
        ),
        child:
            const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 18),
      );
    } else {
      cardColor = AppColors.backgroundGrey;
      borderColor = AppColors.border;
      textColor = AppColors.textGrey;
      statusIcon =
          const Icon(Icons.lock_rounded, color: AppColors.textGrey, size: 24);
    }

    return GestureDetector(
      onTap: isLocked ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: isActive ? 2 : 1),
          boxShadow: isActive
              ? [
                  BoxShadow(
                      color: AppColors.pistachio.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 3))
                ]
              : null,
        ),
        child: Row(
          children: [
            Icon(_lessonIcon(lesson.course),
                color: AppColors.pistachio, size: 32),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Урок ${lesson.order}',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: textColor.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lesson.title,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textColor,
                    ),
                  ),
                  Text(
                    lesson.subtitle,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      color: textColor.withValues(alpha: 0.7),
                    ),
                  ),
                ],
              ),
            ),
            statusIcon,
          ],
        ),
      ),
    );
  }

  IconData _lessonIcon(CourseType course) {
    switch (course) {
      case CourseType.quran:
        return Icons.menu_book_rounded;
      case CourseType.rules:
        return Icons.account_balance_rounded;
      case CourseType.arabic:
        return Icons.translate_rounded;
    }
  }
}
