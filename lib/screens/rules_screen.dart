import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/lesson.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_label.dart';

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
    final state = context.watch<AppState>();
    final course = state.getCourse(CourseType.rules);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _RulesTopBar(onBack: () => Navigator.pop(context)),
              Expanded(
                child: course == null
                    ? const Center(child: CircularProgressIndicator())
                    : ListView(
                        padding: const EdgeInsets.fromLTRB(18, 4, 18, 32),
                        children: [
                          _RulesHeader(course: course),
                          const SizedBox(height: 22),
                          SectionLabel(
                              text: state.tr(
                                  ru: 'Уроки раздела',
                                  kk: 'Бөлім сабақтары',
                                  en: 'Section lessons')),
                          const SizedBox(height: 12),
                          ...course.lessons.asMap().entries.map(
                                (entry) => _LessonTile(
                                  lesson: entry.value,
                                  icon: _icons[entry.key % _icons.length],
                                  onTap: () =>
                                      _openLesson(context, entry.value),
                                ),
                              ),
                          const SizedBox(height: 6),
                          const _SourcesNote(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _openLesson(BuildContext context, Lesson lesson) {
    final state = context.read<AppState>();
    final user = state.user;
    if (lesson.status == LessonStatus.locked) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr(
              ru: 'Завершите предыдущий урок, чтобы открыть этот.',
              kk: 'Мұны ашу үшін алдыңғы сабақты аяқтаңыз.',
              en: 'Finish the previous lesson to open this one.')),
        ),
      );
      return;
    }
    if (user != null && !user.isPremium && user.hearts <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr(
              ru: 'Жизни закончились. Восстанови жизнь на главном экране.',
              kk: 'Жүректер бітті. Басты экранда жүректі қалпына келтір.',
              en: 'You are out of hearts. Restore a heart on the home screen.')),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
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
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                lesson.subtitle,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 18),
              _DetailRow(
                icon: Icons.view_carousel_rounded,
                text: state.tr(
                    ru: '${lesson.steps.length} учебных шага',
                    kk: '${lesson.steps.length} оқу қадамы',
                    en: '${lesson.steps.length} learning steps'),
              ),
              const SizedBox(height: 10),
              _DetailRow(
                icon: Icons.verified_outlined,
                text: state.tr(
                    ru: 'Краткое изложение со ссылкой на богословский источник',
                    kk: 'Діни дереккөзге сілтемесі бар қысқаша мазмұн',
                    en: 'A brief summary with a link to a theological source'),
              ),
              const SizedBox(height: 22),
              PremiumButton(
                label: lesson.status == LessonStatus.completed
                    ? state.tr(
                        ru: 'Повторить урок',
                        kk: 'Сабақты қайталау',
                        en: 'Repeat lesson')
                    : state.tr(
                        ru: 'Начать урок',
                        kk: 'Сабақты бастау',
                        en: 'Start lesson'),
                icon: Icons.play_arrow_rounded,
                onPressed: () {
                  Navigator.pop(sheetContext);
                  Navigator.pushNamed(context, '/lesson', arguments: lesson);
                },
              ),
              if (lesson.sourceUrl != null) ...[
                const SizedBox(height: 6),
                Center(
                  child: TextButton.icon(
                    onPressed: () => launchUrl(
                      Uri.parse(lesson.sourceUrl!),
                      mode: LaunchMode.externalApplication,
                    ),
                    icon: const Icon(Icons.open_in_new_rounded, size: 18),
                    label: Text(state.tr(
                        ru: 'Открыть первоисточник',
                        kk: 'Түпнұсқаны ашу',
                        en: 'Open the original source')),
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.navy,
                      textStyle: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Screen top bar: back control + navy w900 title, matching the premium
/// screens (Достижения/Профиль) rather than a Material AppBar.
class _RulesTopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _RulesTopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 18, 2),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
            icon: const Icon(Icons.arrow_back_rounded,
                color: AppColors.navyDark),
          ),
          Expanded(
            child: Text(
              state.tr(
                  ru: 'Основы ислама',
                  kk: 'Ислам негіздері',
                  en: 'Basics of Islam'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RulesHeader extends StatelessWidget {
  final Course course;

  const _RulesHeader({required this.course});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final percent = course.progress.clamp(0.0, 1.0);

    return PremiumCard(
      padding: EdgeInsets.zero,
      // Navy premium gradient: linear-gradient(120deg,#123D5B,#155B88,#123D5B).
      color: Colors.transparent,
      shadow: [
        BoxShadow(
          color: AppColors.navyDark.withValues(alpha: 0.28),
          blurRadius: 26,
          offset: const Offset(0, 14),
        ),
      ],
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment(-0.9, -1),
            end: Alignment(0.9, 1),
            colors: [
              AppColors.navyDark,
              AppColors.navy,
              AppColors.navyDark,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 52,
                    height: 52,
                    child: CatCharacter(mood: CatMood.prayer, size: 52),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          state.tr(
                              ru: 'РАЗДЕЛ · ОСНОВЫ',
                              kk: 'БӨЛІМ · НЕГІЗДЕР',
                              en: 'SECTION · BASICS'),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.gold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          state.tr(
                              ru: 'Изучайте последовательно',
                              kk: 'Ретімен үйреніңіз',
                              en: 'Study in order'),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  ProgressRing(
                    percent: percent,
                    size: 54,
                    color: AppColors.gold,
                    child: Text(
                      '${(percent * 100).round()}%',
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Text(
                state.tr(
                    ru: 'Уроки дают базовое понимание. В вопросах личной практики '
                        'учитывайте свой мазхаб и обращайтесь к квалифицированному имаму.',
                    kk: 'Сабақтар негізгі түсінік береді. Жеке амал мәселелерінде '
                        'өз мазхабыңызды ескеріп, білікті имамға жүгініңіз.',
                    en: 'The lessons give a basic understanding. For matters of personal '
                        'practice, consider your madhhab and consult a qualified imam.'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  height: 1.45,
                  fontWeight: FontWeight.w600,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 16),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  minHeight: 9,
                  value: percent,
                  backgroundColor: Colors.white24,
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.gold),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.tr(
                    ru: '${course.completedLessons} из ${course.lessons.length} уроков завершено',
                    kk: '${course.lessons.length} сабақтың ${course.completedLessons}-і аяқталды',
                    en: '${course.completedLessons} of ${course.lessons.length} lessons completed'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                  color: Colors.white70,
                ),
              ),
            ],
          ),
        ),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        shadowColor: AppColors.navyDark.withValues(alpha: 0.05),
        elevation: 0,
        child: Ink(
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.navyDark.withValues(alpha: 0.05),
                blurRadius: 22,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 50,
                    height: 50,
                    decoration: BoxDecoration(
                      color: isLocked
                          ? AppColors.backgroundGrey
                          : AppColors.skyLight,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Icon(
                      isLocked ? Icons.lock_rounded : icon,
                      color: isLocked ? AppColors.textLight : AppColors.navy,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16.5,
                            fontWeight: FontWeight.w900,
                            color: isLocked
                                ? AppColors.textLight
                                : AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          lesson.subtitle,
                          style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: isLocked
                                ? AppColors.textLight
                                : AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  _TrailingStatus(
                    isLocked: isLocked,
                    isCompleted: isCompleted,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Trailing status affordance: gold check badge when completed, muted lock when
/// locked, otherwise a sky chevron in a soft circle.
class _TrailingStatus extends StatelessWidget {
  final bool isLocked;
  final bool isCompleted;

  const _TrailingStatus({required this.isLocked, required this.isCompleted});

  @override
  Widget build(BuildContext context) {
    if (isCompleted) {
      return Container(
        width: 30,
        height: 30,
        decoration: const BoxDecoration(
          color: AppColors.success,
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 18),
      );
    }

    final Color bg =
        isLocked ? AppColors.backgroundGrey : AppColors.skyLight;
    return Container(
      width: 30,
      height: 30,
      decoration: BoxDecoration(color: bg, shape: BoxShape.circle),
      child: Icon(
        isLocked ? Icons.lock_outline_rounded : Icons.chevron_right_rounded,
        color: isLocked ? AppColors.textLight : AppColors.navy,
        size: 18,
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
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
            color: AppColors.skyLight,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, size: 20, color: AppColors.navy),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              height: 1.4,
              fontWeight: FontWeight.w600,
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
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 8, 10, 0),
      child: Text(
        state.tr(
            ru: 'Источники каждой карточки: Коран и проверяемые сборники хадисов. '
                'Это вводный материал, а не фетва или полный курс фикха.',
            kk: 'Әр картаның дереккөздері: Құран және тексерілетін хадис жинақтары. '
                'Бұл кіріспе материал, фетва немесе толық фиқһ курсы емес.',
            en: 'Sources for each card: the Quran and verifiable hadith collections. '
                'This is introductory material, not a fatwa or a full fiqh course.'),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11.5,
          height: 1.5,
          fontWeight: FontWeight.w600,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}
