import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson.dart';
import '../models/learning_profile.dart';
import '../services/app_state.dart';
import '../services/app_install_service.dart';
import '../services/haptics_service.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/stats_row.dart';

enum _LearningMode { quran, arabic }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _LearningMode _mode = _LearningMode.quran;
  bool _languagePromptOpen = false;

  static const _quranIcons = [
    Icons.auto_awesome_rounded,
    Icons.headphones_rounded,
    Icons.menu_book_rounded,
    Icons.record_voice_over_rounded,
    Icons.workspace_premium_rounded,
  ];

  static const _arabicIcons = [
    Icons.translate_rounded,
    Icons.record_voice_over_rounded,
    Icons.spellcheck_rounded,
    Icons.school_rounded,
    Icons.workspace_premium_rounded,
  ];

  static const _rulesIcons = [
    Icons.account_balance_rounded,
    Icons.self_improvement_rounded,
    Icons.balance_rounded,
    Icons.volunteer_activism_rounded,
    Icons.mosque_rounded,
    Icons.translate_rounded,
    Icons.school_rounded,
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) return const SizedBox.shrink();

    final quranCourse = state.getCourse(CourseType.quran);
    final arabicCourse = state.getCourse(CourseType.arabic);
    final rulesCourse = state.getCourse(CourseType.rules);
    final activeCourse =
        _mode == _LearningMode.arabic ? arabicCourse : quranCourse;
    final activeIcons =
        _mode == _LearningMode.arabic ? _arabicIcons : _quranIcons;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _StatsHeader(
                child: StatsRow(
                  streak: user.streak,
                  xp: user.xp,
                  level: user.level,
                  hearts: user.hearts,
                  energy: user.energy,
                  isPremium: user.isPremium,
                  onHeartsTap: () => _showHeartRestore(context),
                  onStreakTap: () => Navigator.pushNamed(context, '/streak'),
                ),
              ),
            ),
            if (AppInstallService.isWebInstallExperience &&
                !AppInstallService.isInstalled)
              SliverToBoxAdapter(
                child: _InstallBanner(
                  onTap: () => Navigator.pushNamed(context, '/install'),
                ),
              ),
            if (state.recommendedLesson != null)
              SliverToBoxAdapter(
                child: _DailyPlanCard(
                  lesson: state.recommendedLesson!,
                  focus: state.learningGoal?.dailyFocus ??
                      'Новый материал, повторение и короткая проверка',
                  recommendation: state.learningRecommendation,
                  isReview:
                      state.isLessonDue(state.recommendedLesson!.id),
                  onStart: () =>
                      _openLesson(context, state.recommendedLesson!),
                ),
              ),
            if (state.knowledgeStates.isNotEmpty)
              SliverToBoxAdapter(
                child: _MemoryStatus(
                  dueCount: state.dueReviewCount,
                  weakCount: state.weakKnowledgeCount,
                  nextReviewAt: state.nextReviewAt,
                ),
              ),
            SliverToBoxAdapter(
              child: _ModeSwitch(
                mode: _mode,
                nativeLanguage: state.nativeLanguage,
                onChanged: (mode) async {
                  HapticsService.tap();
                  setState(() => _mode = mode);
                  if (mode == _LearningMode.arabic &&
                      state.nativeLanguage == null) {
                    await _askNativeLanguage(context);
                  }
                },
              ),
            ),
            if (_mode == _LearningMode.quran && rulesCourse != null) ...[
              const SliverToBoxAdapter(
                child: _UnitHeader(
                  kicker: 'РАЗДЕЛ 1, ЧАСТЬ 1',
                  title: 'Основы ислама',
                  subtitle: '7 вводных уроков перед сурами',
                  color: AppColors.navy,
                  trailing: Icons.account_balance_rounded,
                ),
              ),
              SliverToBoxAdapter(
                child: _LessonPath(
                  lessons: rulesCourse.lessons,
                  icons: _rulesIcons,
                  onOpenLesson: _openLesson,
                ),
              ),
            ],
            if (activeCourse != null) ...[
              SliverToBoxAdapter(
                child: _UnitHeader(
                  kicker: _mode == _LearningMode.arabic
                      ? 'РАЗДЕЛ 2, ЧАСТЬ 1'
                      : 'РАЗДЕЛ 1, ЧАСТЬ 2',
                  title: _mode == _LearningMode.arabic
                      ? 'Арабский язык'
                      : 'Короткие суры',
                  subtitle: _mode == _LearningMode.arabic
                      ? 'Буквы, чтение и произношение'
                      : 'Слушай, повторяй и понимай смысл',
                  color: _mode == _LearningMode.arabic
                      ? AppColors.navy
                      : AppColors.sky,
                  trailing: _mode == _LearningMode.arabic
                      ? Icons.translate_rounded
                      : Icons.menu_book_rounded,
                ),
              ),
              SliverToBoxAdapter(
                child: _LessonPath(
                  lessons: activeCourse.lessons,
                  icons: activeIcons,
                  onOpenLesson: _openLesson,
                ),
              ),
            ],
            if (_mode == _LearningMode.arabic && rulesCourse != null) ...[
              const SliverToBoxAdapter(
                child: _UnitHeader(
                  kicker: 'РАЗДЕЛ 1, ЧАСТЬ 1',
                  title: 'Основы ислама',
                  subtitle: 'Главные правила шаг за шагом',
                  color: AppColors.navy,
                  trailing: Icons.account_balance_rounded,
                ),
              ),
              SliverToBoxAdapter(
                child: _LessonPath(
                  lessons: rulesCourse.lessons,
                  icons: _rulesIcons,
                  onOpenLesson: _openLesson,
                ),
              ),
            ],
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
                child: _DailyQuest(
                  completed: user.totalLessons == 0
                      ? 0
                      : ((user.totalLessons - 1) % 3) + 1,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showHeartRestore(BuildContext context) async {
    final state = context.read<AppState>();
    final user = state.user;
    if (user == null) return;
    HapticsService.tap();
    final shouldRestore = await showModalBottomSheet<bool>(
      context: context,
      showDragHandle: true,
      builder: (sheetContext) => _HeartRestoreSheet(
        hearts: user.hearts,
        energy: user.energy,
        isPremium: user.isPremium,
      ),
    );
    if (shouldRestore != true || !context.mounted) return;
    final restored = await context.read<AppState>().restoreHeart();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          restored
              ? 'Жизнь восстановлена за 20 энергии.'
              : context.read<AppState>().error ?? 'Не удалось восстановить жизнь.',
        ),
        backgroundColor: restored ? AppColors.navy : AppColors.error,
      ),
    );
  }

  Future<void> _openLesson(BuildContext context, Lesson lesson) async {
    final state = context.read<AppState>();
    final user = state.user;
    if (user == null) return;

    if (lesson.status == LessonStatus.locked) {
      _showLockedLessonDialog(context, lesson);
      return;
    }

    if (!user.isPremium && user.hearts <= 0) {
      final shouldRestore = await showModalBottomSheet<bool>(
        context: context,
        showDragHandle: true,
        builder: (sheetContext) => _HeartRestoreSheet(
          hearts: user.hearts,
          energy: user.energy,
          isPremium: user.isPremium,
        ),
      );
      if (shouldRestore == true && context.mounted) {
        final restored = await context.read<AppState>().restoreHeart();
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              restored
                  ? 'Жизнь восстановлена. Теперь можно начать урок.'
                  : context.read<AppState>().error ??
                      'Не удалось восстановить жизнь.',
            ),
            backgroundColor: restored ? AppColors.navy : AppColors.error,
          ),
        );
      }
      return;
    }

    if (context.mounted) {
      Navigator.pushNamed(context, '/lesson', arguments: lesson);
    }
  }

  Future<void> _askNativeLanguage(BuildContext context) async {
    if (_languagePromptOpen) return;
    _languagePromptOpen = true;
    try {
      await showModalBottomSheet<void>(
        context: context,
        isDismissible: false,
        enableDrag: false,
        backgroundColor: Colors.transparent,
        builder: (sheetContext) => _NativeLanguageSheet(
          onSelected: (language) async {
            HapticsService.reward();
            await context.read<AppState>().setNativeLanguage(language);
            if (sheetContext.mounted) Navigator.pop(sheetContext);
          },
        ),
      );
    } finally {
      _languagePromptOpen = false;
    }
  }
}

class _InstallBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _InstallBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: Material(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: const Padding(
            padding: EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Icon(Icons.install_mobile_rounded, color: Colors.white),
                SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Установить Muslingo',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        'Добавь приложение на главный экран',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DailyPlanCard extends StatelessWidget {
  final Lesson lesson;
  final String focus;
  final String? recommendation;
  final bool isReview;
  final VoidCallback onStart;

  const _DailyPlanCard({
    required this.lesson,
    required this.focus,
    required this.recommendation,
    required this.isReview,
    required this.onStart,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.sky, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                    isReview
                        ? Icons.replay_circle_filled_rounded
                        : Icons.auto_awesome_rounded,
                    color: AppColors.navy, size: 20),
                const SizedBox(width: 7),
                Text(
                  isReview ? 'ПОВТОРЕНИЕ ПО ПАМЯТИ' : 'ТВОЙ ПЛАН НА СЕГОДНЯ',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
                const Spacer(),
                const Icon(Icons.schedule_rounded,
                    color: AppColors.textGrey, size: 17),
                const SizedBox(width: 4),
                const Text(
                  '6 мин',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              lesson.title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              focus,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                height: 1.35,
                color: AppColors.textGrey,
              ),
            ),
            if (recommendation?.isNotEmpty == true) ...[
              const SizedBox(height: 9),
              Text(
                recommendation!,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.navy,
                ),
              ),
            ],
            const SizedBox(height: 14),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: onStart,
                icon: const Icon(Icons.play_arrow_rounded),
                label: Text(isReview ? 'Повторить сейчас' : 'Начать урок'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.sky,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MemoryStatus extends StatelessWidget {
  final int dueCount;
  final int weakCount;
  final DateTime? nextReviewAt;

  const _MemoryStatus({
    required this.dueCount,
    required this.weakCount,
    required this.nextReviewAt,
  });

  @override
  Widget build(BuildContext context) {
    final nextLabel = _reviewDateLabel(nextReviewAt);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 2),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.navy.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.navy.withValues(alpha: 0.14)),
        ),
        child: Row(
          children: [
            const Icon(Icons.psychology_alt_rounded,
                color: AppColors.navy, size: 24),
            const SizedBox(width: 11),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Память',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    dueCount > 0
                        ? 'Сегодня: $dueCount · слабых мест: $weakCount'
                        : 'Слабых мест: $weakCount · следующее: $nextLabel',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              dueCount > 0 ? Icons.priority_high_rounded : Icons.check_rounded,
              color: dueCount > 0 ? AppColors.coral : AppColors.pistachio,
              size: 21,
            ),
          ],
        ),
      ),
    );
  }
}

String _reviewDateLabel(DateTime? date) {
  if (date == null) return 'после урока';
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  final target = DateTime(date.year, date.month, date.day);
  final days = target.difference(today).inDays;
  if (days <= 0) return 'сегодня';
  if (days == 1) return 'завтра';
  return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}';
}

class _ModeSwitch extends StatelessWidget {
  final _LearningMode mode;
  final NativeLanguage? nativeLanguage;
  final ValueChanged<_LearningMode> onChanged;

  const _ModeSwitch({
    required this.mode,
    required this.nativeLanguage,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 8),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 1.5),
        ),
        child: Row(
          children: [
            _ModeSegment(
              selected: mode == _LearningMode.quran,
              label: 'Суры',
              icon: Icons.menu_book_rounded,
              onTap: () => onChanged(_LearningMode.quran),
            ),
            _ModeSegment(
              selected: mode == _LearningMode.arabic,
              label: nativeLanguage == null
                  ? 'Арабский'
                  : 'Арабский · ${nativeLanguage!.label}',
              icon: Icons.translate_rounded,
              onTap: () => onChanged(_LearningMode.arabic),
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeSegment extends StatelessWidget {
  final bool selected;
  final String label;
  final IconData icon;
  final VoidCallback onTap;

  const _ModeSegment({
    required this.selected,
    required this.label,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          height: 44,
          decoration: BoxDecoration(
            color: selected ? AppColors.sky : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 19,
                  color: selected ? Colors.white : AppColors.textGrey),
              const SizedBox(width: 7),
              Flexible(
                child: Text(
                  label,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: selected ? Colors.white : AppColors.textGrey,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NativeLanguageSheet extends StatelessWidget {
  final ValueChanged<NativeLanguage> onSelected;

  const _NativeLanguageSheet({required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 28),
      decoration: const BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(22)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.border,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          const SizedBox(height: 18),
          const Icon(Icons.language_rounded, color: AppColors.sky, size: 42),
          const SizedBox(height: 10),
          const Text(
            'Выбери родной язык',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Это нужно один раз, чтобы объяснения в арабском курсе были понятнее.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              height: 1.35,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 16),
          for (final language in NativeLanguage.values)
            Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _LanguageButton(
                language: language,
                onTap: () => onSelected(language),
              ),
            ),
        ],
      ),
    );
  }
}

class _HeartRestoreSheet extends StatelessWidget {
  final int hearts;
  final int energy;
  final bool isPremium;

  const _HeartRestoreSheet({
    required this.hearts,
    required this.energy,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final canRestore = !isPremium && hearts < 5 && energy >= 20;
    final subtitle = isPremium
        ? 'У тебя уже безлимитные жизни.'
        : hearts >= 5
            ? 'Жизни уже полные.'
            : energy >= 20
                ? 'Потрать 20 энергии и продолжай уроки без ожидания.'
                : 'Нужно 20 энергии. Проходи уроки, чтобы накопить её.';
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.favorite_rounded, color: AppColors.error, size: 46),
            const SizedBox(height: 8),
            const Text(
              'Восстановить жизнь',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                height: 1.35,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MiniResource(
                    icon: Icons.favorite_rounded,
                    label: 'Жизни',
                    value: isPremium ? 'MAX' : '$hearts/5',
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniResource(
                    icon: Icons.battery_charging_full_rounded,
                    label: 'Энергия',
                    value: '$energy',
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: canRestore
                  ? () => Navigator.pop(context, true)
                  : null,
              icon: const Icon(Icons.bolt_rounded),
              label: const Text('Восстановить за 20 энергии'),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniResource extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniResource({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final NativeLanguage language;
  final VoidCallback onTap;

  const _LanguageButton({required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Выбрать ${language.label}',
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.skyLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.sky.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const Icon(Icons.translate_rounded,
                  color: AppColors.navy, size: 23),
              const SizedBox(width: 12),
              Text(
                language.label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textGrey),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsHeader extends SliverPersistentHeaderDelegate {
  final Widget child;

  const _StatsHeader({required this.child});

  @override
  double get minExtent => 58;

  @override
  double get maxExtent => 58;

  @override
  Widget build(
      BuildContext context, double shrinkOffset, bool overlapsContent) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 6),
      child: child,
    );
  }

  @override
  bool shouldRebuild(covariant _StatsHeader oldDelegate) => false;
}

class _UnitHeader extends StatelessWidget {
  final String kicker;
  final String title;
  final String subtitle;
  final Color color;
  final IconData trailing;

  const _UnitHeader({
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 18),
      padding: const EdgeInsets.fromLTRB(18, 15, 16, 17),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: color.withValues(alpha: 0.45), offset: const Offset(0, 5))
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(kicker,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: Colors.white70)),
                const SizedBox(height: 3),
                Text(title,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 21,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                Text(subtitle,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: Colors.white)),
              ],
            ),
          ),
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12)),
            child: Icon(trailing, color: Colors.white, size: 27),
          ),
        ],
      ),
    );
  }
}

class _LessonPath extends StatelessWidget {
  final List<Lesson> lessons;
  final List<IconData> icons;
  final void Function(BuildContext context, Lesson lesson) onOpenLesson;

  const _LessonPath({
    required this.lessons,
    required this.icons,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 24),
      child: Column(
        children: List.generate(lessons.length, (index) {
          final lesson = lessons[index];
          const offsets = [-0.42, -0.1, 0.28, 0.02, -0.34];
          final nodeOffset = offsets[index % offsets.length];
          final compact = MediaQuery.sizeOf(context).width < 430;
          final mascotOffset = nodeOffset <= 0
              ? nodeOffset + (compact ? 0.82 : 0.72)
              : nodeOffset - (compact ? 0.82 : 0.72);
          final mascotSize = compact ? 82.0 : 94.0;
          final isCurrent = lesson.status == LessonStatus.available ||
              lesson.status == LessonStatus.inProgress;
          return SizedBox(
            height: isCurrent ? 126 : 104,
            child: Stack(
              alignment: Alignment.topCenter,
              children: [
                Align(
                  alignment: Alignment(nodeOffset, -0.65),
                  child: _PathNode(
                    lesson: lesson,
                    icon: icons[index % icons.length],
                    onTap: () => onOpenLesson(context, lesson),
                  ),
                ),
                if (isCurrent)
                  Align(
                    alignment: Alignment(mascotOffset, compact ? 0.55 : 0.72),
                    child: SizedBox(
                      width: mascotSize,
                      height: mascotSize,
                      child: CatCharacter(
                        mood: CatMood.greet,
                        size: mascotSize,
                      ),
                    ),
                  ),
              ],
            ),
          );
        }),
      ),
    );
  }
}

void _showLockedLessonDialog(BuildContext context, Lesson lesson) {
  showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (sheetContext) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 58,
              height: 58,
              decoration: const BoxDecoration(
                color: AppColors.backgroundGrey,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_rounded,
                color: AppColors.textGrey,
                size: 30,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              lesson.title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            const Text(
              'Заверши предыдущий урок, чтобы открыть этот шаг.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 18),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () => Navigator.pop(sheetContext),
                icon: const Icon(Icons.check_rounded),
                label: const Text('Понятно'),
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.navy,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class _PathNode extends StatelessWidget {
  final Lesson lesson;
  final IconData icon;
  final VoidCallback? onTap;

  const _PathNode({required this.lesson, required this.icon, this.onTap});

  @override
  Widget build(BuildContext context) {
    final locked = lesson.status == LessonStatus.locked;
    final completed = lesson.status == LessonStatus.completed;
    final color = locked
        ? AppColors.textLight
        : (completed ? AppColors.gold : AppColors.sky);
    final shadow = locked
        ? const Color(0xFF93A8B5)
        : (completed ? const Color(0xFFC88A25) : AppColors.navy);

    return Semantics(
      button: true,
      label: '${lesson.title}. ${locked ? 'Закрыто' : 'Открыть урок'}',
      child: GestureDetector(
        onTap: onTap,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 74,
              height: 70,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border:
                    Border.all(color: color.withValues(alpha: 0.85), width: 3),
                boxShadow: [
                  BoxShadow(color: shadow, offset: const Offset(0, 7))
                ],
              ),
              child: Icon(
                  locked
                      ? Icons.lock_rounded
                      : (completed ? Icons.check_rounded : icon),
                  color: Colors.white,
                  size: 34),
            ),
            const SizedBox(height: 12),
            Container(
              constraints: const BoxConstraints(maxWidth: 150),
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border)),
              child: Text(lesson.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark)),
            ),
          ],
        ),
      ),
    );
  }
}

class _DailyQuest extends StatelessWidget {
  final int completed;

  const _DailyQuest({required this.completed});

  @override
  Widget build(BuildContext context) {
    final progress = (completed / 3).clamp(0.0, 1.0);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border, width: 2)),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: AppColors.goldLight,
                borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.emoji_events_rounded,
                color: AppColors.gold, size: 29),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Учебная цель',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark)),
                Text('$completed из 3 уроков',
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGrey)),
                const SizedBox(height: 7),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 10,
                      backgroundColor: AppColors.backgroundGrey,
                      color: AppColors.gold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
