import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/lesson.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';

class RulesScreen extends StatelessWidget {
  const RulesScreen({super.key});

  static const _icons = [
    Icons.account_balance_rounded,
    Icons.self_improvement_rounded,
    Icons.balance_rounded,
    Icons.volunteer_activism_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final course = context.watch<AppState>().getCourse(CourseType.rules);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Основы ислама',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: course == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
              children: [
                _RulesHeader(course: course),
                const SizedBox(height: 16),
                ...course.lessons.asMap().entries.map(
                      (entry) => _LessonTile(
                        lesson: entry.value,
                        icon: _icons[entry.key % _icons.length],
                        onTap: () => _openLesson(context, entry.value),
                      ),
                    ),
                const _SourcesNote(),
              ],
            ),
    );
  }

  void _openLesson(BuildContext context, Lesson lesson) {
    if (lesson.status == LessonStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Завершите предыдущий урок, чтобы открыть этот.'),
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                lesson.title,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 23,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lesson.subtitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 16),
              _DetailRow(
                icon: Icons.view_carousel_rounded,
                text: '${lesson.steps.length} учебных шага',
              ),
              const SizedBox(height: 9),
              const _DetailRow(
                icon: Icons.verified_outlined,
                text: 'Краткое изложение со ссылкой на богословский источник',
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () {
                    Navigator.pop(sheetContext);
                    Navigator.pushNamed(context, '/lesson', arguments: lesson);
                  },
                  icon: const Icon(Icons.play_arrow_rounded),
                  label: Text(
                    lesson.status == LessonStatus.completed
                        ? 'Повторить урок'
                        : 'Начать урок',
                  ),
                ),
              ),
              if (lesson.sourceUrl != null)
                SizedBox(
                  width: double.infinity,
                  child: TextButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(lesson.sourceUrl!),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: const Text('Открыть первоисточник'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RulesHeader extends StatelessWidget {
  final Course course;

  const _RulesHeader({required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              SizedBox(
                width: 52,
                height: 52,
                child: CatCharacter(mood: CatMood.prayer, size: 52),
              ),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Изучайте последовательно',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Уроки дают базовое понимание. В вопросах личной практики '
            'учитывайте свой мазхаб и обращайтесь к квалифицированному имаму.',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              height: 1.45,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              minHeight: 9,
              value: course.progress,
              backgroundColor: Colors.white24,
              color: AppColors.gold,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${course.completedLessons} из ${course.lessons.length} уроков завершено',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

class _LessonTile extends StatelessWidget {
  final Lesson lesson;
  final IconData icon;
  final VoidCallback onTap;

  const _LessonTile({
    required this.lesson,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isLocked = lesson.status == LessonStatus.locked;
    final isCompleted = lesson.status == LessonStatus.completed;

    return Padding(
      padding: const EdgeInsets.only(bottom: 9),
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: isLocked
                        ? AppColors.backgroundGrey
                        : AppColors.skyLight,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    isLocked ? Icons.lock_rounded : icon,
                    color: isLocked ? AppColors.textLight : AppColors.navy,
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        lesson.title,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: isLocked
                              ? AppColors.textLight
                              : AppColors.textDark,
                        ),
                      ),
                      Text(
                        lesson.subtitle,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                if (isCompleted)
                  const Icon(Icons.check_circle_rounded,
                      color: AppColors.success)
                else
                  Icon(
                    isLocked
                        ? Icons.lock_outline_rounded
                        : Icons.chevron_right_rounded,
                    color: AppColors.textLight,
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String text;

  const _DetailRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppColors.navy),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Nunito',
              height: 1.4,
              color: AppColors.textGrey,
            ),
          ),
        ),
      ],
    );
  }
}

class _SourcesNote extends StatelessWidget {
  const _SourcesNote();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.fromLTRB(8, 14, 8, 0),
      child: Text(
        'Источники каждой карточки: Коран и проверяемые сборники хадисов. '
        'Это вводный материал, а не фетва или полный курс фикха.',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          height: 1.5,
          color: AppColors.textGrey,
        ),
      ),
    );
  }
}
