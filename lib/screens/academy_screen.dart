import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson.dart';
import '../services/academy_data.dart';
import '../services/app_state.dart';
import '../services/haptics_service.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/section_label.dart';

/// Академия — готовые учебные маршруты из уже существующих уроков. Каждая
/// программа разворачивается в список своих уроков с их статусом; тап по
/// доступному уроку открывает его через обычный маршрут /lesson.
class AcademyScreen extends StatelessWidget {
  const AcademyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(programCount: AcademyData.programs.length),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 4, 18, 28),
                  children: [
                    const _AcademyIntro(),
                    const SizedBox(height: 20),
                    SectionLabel(
                        text: state.tr(
                            ru: 'Учебные программы',
                            kk: 'Оқу бағдарламалары',
                            en: 'Study programs')),
                    const SizedBox(height: 12),
                    for (final program in AcademyData.programs) ...[
                      _ProgramCard(
                        program: program,
                        lessons: _resolveLessons(state, program),
                      ),
                      const SizedBox(height: 14),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Достаёт реальные уроки программы из AppState по id. Уроков, которых нет в
  /// LessonData, здесь не будет — просто пропускаем отсутствующие.
  List<Lesson> _resolveLessons(AppState state, AcademyProgram program) {
    final lessons = <Lesson>[];
    for (final id in program.lessonIds) {
      final lesson = _lessonById(state, id);
      if (lesson != null) lessons.add(lesson);
    }
    return lessons;
  }

  Lesson? _lessonById(AppState state, String id) {
    for (final course in state.courses) {
      for (final lesson in course.lessons) {
        if (lesson.id == id) return lesson;
      }
    }
    return null;
  }
}

/// Navy w900 title with back control and a programs counter pill.
class _Header extends StatelessWidget {
  final int programCount;

  const _Header({required this.programCount});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 18, 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
            icon:
                const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
          ),
          Expanded(
            child: Text(
              state.tr(ru: 'Академия', kk: 'Академия', en: 'Academy'),
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
                const Icon(Icons.school_rounded,
                    color: AppColors.gold, size: 15),
                const SizedBox(width: 5),
                Text(
                  '$programCount',
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

/// Premium navy-gradient intro banner introducing the academy programs.
class _AcademyIntro extends StatelessWidget {
  const _AcademyIntro();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        // linear-gradient(120deg, #123D5B, #155B88, #123D5B)
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, AppColors.navy, AppColors.navyDark],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(16),
            ),
            child:
                const Icon(Icons.school_rounded, color: Colors.white, size: 28),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.tr(
                      ru: 'Учебные программы',
                      kk: 'Оқу бағдарламалары',
                      en: 'Study programs'),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  state.tr(
                      ru: 'Готовые маршруты из уроков приложения — проходи по порядку',
                      kk: 'Қосымша сабақтарынан құрылған дайын маршруттар — ретімен өт',
                      en: 'Ready-made routes from the app lessons — go in order'),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    height: 1.35,
                    fontWeight: FontWeight.w700,
                    color: Colors.white70,
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

class _ProgramCard extends StatelessWidget {
  final AcademyProgram program;
  final List<Lesson> lessons;

  const _ProgramCard({required this.program, required this.lessons});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final completed = lessons
        .where((lesson) => lesson.status == LessonStatus.completed)
        .length;

    // Мягкую премиум-тень даём через внешний Container, а белый фон/скругление и
    // всплески ExpansionTile — через Material с shape: цветной BoxDecoration
    // перекрыл бы ripple ближайшего Material.
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          // rgba(18,61,91,.05) blur 26 y12
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.05),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Material(
        color: AppColors.white,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(22),
        ),
        child: Theme(
          // Убираем стандартные разделители ExpansionTile, чтобы вписаться в
          // карточку.
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            childrenPadding: const EdgeInsets.fromLTRB(10, 0, 10, 10),
            iconColor: AppColors.navy,
            collapsedIconColor: AppColors.textLight,
            leading: Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                color: AppColors.skyLight,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(program.icon, color: AppColors.navy, size: 25),
            ),
            title: Text(
              program.title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16.5,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    program.description,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.5,
                      height: 1.3,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _MetaChip(
                        icon: Icons.check_circle_rounded,
                        label: state.tr(
                            ru: '$completed / ${program.lessonCount} уроков',
                            kk: '$completed / ${program.lessonCount} сабақ',
                            en: '$completed / ${program.lessonCount} lessons'),
                      ),
                      const SizedBox(width: 8),
                      _MetaChip(
                        icon: Icons.schedule_rounded,
                        label: state.tr(
                            ru: '~${program.estimatedMinutes} мин',
                            kk: '~${program.estimatedMinutes} мин',
                            en: '~${program.estimatedMinutes} min'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            children: [
              for (final lesson in lessons) _ProgramLessonRow(lesson: lesson),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small navy-tinted meta pill used for the program progress/time summary.
class _MetaChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _MetaChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.skyLight.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: AppColors.navy),
          const SizedBox(width: 5),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}

class _ProgramLessonRow extends StatelessWidget {
  final Lesson lesson;

  const _ProgramLessonRow({required this.lesson});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final locked = lesson.status == LessonStatus.locked;
    final completed = lesson.status == LessonStatus.completed;
    final statusColor = locked
        ? AppColors.textLight
        : (completed ? AppColors.gold : AppColors.sky);
    final statusIcon = locked
        ? Icons.lock_rounded
        : (completed ? Icons.check_rounded : Icons.play_arrow_rounded);

    return Semantics(
      button: true,
      label:
          '${lesson.title}. ${locked ? state.tr(ru: 'Закрыто', kk: 'Жабық', en: 'Locked') : state.tr(ru: 'Открыть урок', kk: 'Сабақты ашу', en: 'Open lesson')}',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => _openLesson(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(11),
                ),
                child: Icon(statusIcon, color: statusColor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      lesson.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (lesson.subtitle.isNotEmpty) ...[
                      const SizedBox(height: 1),
                      Text(
                        lesson.subtitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                locked
                    ? Icons.lock_outline_rounded
                    : Icons.chevron_right_rounded,
                color: AppColors.textLight,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLesson(BuildContext context) {
    HapticsService.tap();
    if (lesson.status == LessonStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AppState>().tr(
              ru: 'Заверши предыдущий урок программы, чтобы открыть этот.',
              kk: 'Мұны ашу үшін бағдарламаның алдыңғы сабағын аяқта.',
              en: 'Finish the previous lesson in the program to open this one.')),
          backgroundColor: AppColors.navy,
        ),
      );
      return;
    }
    Navigator.pushNamed(context, '/lesson', arguments: lesson);
  }
}
