import 'package:flutter/material.dart';

import '../models/lesson.dart';
import '../services/tajwid_data.dart';
import '../utils/colors.dart';

/// Read-only экран для проверки чернового модуля таджвида специалистом.
/// Ничего не засчитывает и не отправляет на сервер — только показывает весь
/// контент (правила и вопросы с отмеченным верным ответом), чтобы специалист
/// мог всё вычитать и указать правки.
class TajwidReviewScreen extends StatelessWidget {
  const TajwidReviewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final lessons = TajwidDraftData.lessons();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Таджвид — черновик',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _NoticeCard(),
          const SizedBox(height: 16),
          ...lessons.map((lesson) => _LessonReviewCard(lesson: lesson)),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _NoticeCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.warning_amber_rounded, color: AppColors.gold, size: 24),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              TajwidDraftData.reviewNotice,
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  height: 1.4,
                  color: AppColors.textDark),
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonReviewCard extends StatelessWidget {
  final Lesson lesson;
  const _LessonReviewCard({required this.lesson});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('${lesson.order}. ${lesson.title}',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark)),
          Text(lesson.subtitle,
              style: const TextStyle(
                  fontFamily: 'Nunito', fontSize: 13, color: AppColors.textGrey)),
          const SizedBox(height: 12),
          ...lesson.steps.map(_buildStep),
        ],
      ),
    );
  }

  Widget _buildStep(LessonStep step) {
    switch (step.type) {
      case LessonStepType.question:
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Вопрос: ${step.question ?? ''}',
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark)),
              const SizedBox(height: 6),
              ...List.generate(step.answers?.length ?? 0, (i) {
                final correct = i == step.correctAnswerIndex;
                return Padding(
                  padding: const EdgeInsets.only(left: 8, bottom: 2),
                  child: Row(
                    children: [
                      Icon(
                        correct
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        size: 16,
                        color: correct ? AppColors.success : AppColors.textLight,
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(step.answers![i],
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                color: correct
                                    ? AppColors.textDark
                                    : AppColors.textGrey,
                                fontWeight: correct
                                    ? FontWeight.w700
                                    : FontWeight.w400)),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        );
      default:
        final text = step.russianText ?? step.arabicText ?? '';
        if (text.isEmpty) return const SizedBox.shrink();
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Text('• $text',
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.4,
                  color: AppColors.textDark)),
        );
    }
  }
}
