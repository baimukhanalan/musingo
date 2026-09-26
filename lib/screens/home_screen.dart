import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson.dart';
import '../models/learning_profile.dart';
import '../services/app_state.dart';
import '../services/haptics_service.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/daily_ayah.dart';
import '../widgets/mentor_tip_card.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_label.dart';

part 'home/home_header.dart';
part 'home/daily_cards.dart';
part 'home/learning_path_panel.dart';
part 'home/home_sheets.dart';
part 'home/lesson_path.dart';

enum _LearningMode { basics, quran, arabic, tajwid }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  _LearningMode _mode = _LearningMode.quran;

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

  static const _tajwidIcons = [
    Icons.hearing_rounded,
    Icons.record_voice_over_rounded,
    Icons.graphic_eq_rounded,
    Icons.air_rounded,
    Icons.multiline_chart_rounded,
    Icons.pause_circle_rounded,
  ];

  void _openCourse(_LearningMode mode) {
    HapticsService.tap();
    setState(() => _mode = mode);
    Navigator.of(context).push<void>(
      MaterialPageRoute(
        // Fullscreen is a home view; refreshing its URL remains a valid entry.
        settings: const RouteSettings(name: '/home'),
        fullscreenDialog: true,
        builder: (context) => _CoursePathScreen(
          mode: mode,
          onOpenLesson: _openLesson,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) return const SizedBox.shrink();

    // recommendedLesson делает where().toList()..sort() и проходы по курсам —
    // считаем его один раз за build и переиспользуем во всех местах ниже,
    // чтобы не гонять расчёт 4 раза и исключить рассинхрон между вызовами.
    final recommendedLesson = state.recommendedLesson;

    final memory = state.knowledgeStates;
    final double memoryAccuracy = memory.isEmpty
        ? 0
        : memory.map((k) => k.strength).reduce((a, b) => a + b) / memory.length;

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: PremiumBackground(
        floatingLetters: false,
        child: SafeArea(
          bottom: false,
          // CustomScrollView только со SliverList/SliverToBoxAdapter — без
          // SliverPersistentHeader: раньше делегат с extent, не совпадающим с
          // реальной высотой, ронял геометрию скролла (чёрный экран). Здесь все
          // слайверы самоизмеряемые, поэтому такой проблемы нет.
          child: CustomScrollView(
            slivers: [
              // Keep the greeting; language selection lives in Settings.
              SliverToBoxAdapter(
                child: _GreetingHeader(name: user.name),
              ),
              // (2) Ряд из 3 статов: стрик, XP, жизни — значения из AppState.
              SliverToBoxAdapter(
                child: _StatBadgesRow(
                  streak: user.streak,
                  xp: user.xp,
                  hearts: user.hearts,
                  isPremium: user.isPremium,
                  onStreakTap: () => Navigator.pushNamed(context, '/streak'),
                  onHeartsTap: () => _showHeartRestore(context),
                ),
              ),
              // (3) Карточка «СЕГОДНЯ · N МИНУТ» с рекомендованным уроком.
              if (recommendedLesson != null)
                SliverToBoxAdapter(
                  child: _DailyPlanCard(
                    lesson: recommendedLesson,
                    focus: state.learningGoal?.dailyFocusFor(state.locale) ??
                        state.tr(
                          ru: 'Новый материал, повторение и короткая проверка',
                          kk: 'Жаңа материал, қайталау және қысқа тексеру',
                          en: 'New material, review and a short check',
                        ),
                    isReview: state.isLessonDue(recommendedLesson.id),
                    onStart: () => _openLesson(context, recommendedLesson),
                  ),
                ),
              // (4) MEMORY ENGINE — кольцо точности + «Повторить». Скрыта, если
              // память ещё пуста (нет данных для повторения).
              if (memory.isNotEmpty)
                SliverToBoxAdapter(
                  child: _MemoryEngineCard(
                    accuracy: memoryAccuracy,
                    dueCount: state.dueReviewCount,
                    weakCount: state.weakKnowledgeCount,
                    nextReviewAt: state.nextReviewAt,
                    onReview: recommendedLesson == null
                        ? null
                        : () => _openLesson(context, recommendedLesson),
                  ),
                ),
              const SliverToBoxAdapter(child: DailyAyahCard()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                  child: _ModeSwitch(mode: _mode, onChanged: _openCourse),
                ),
              ),
              SliverToBoxAdapter(
                child: _AcademyEntryCard(
                  onTap: () => Navigator.pushNamed(context, '/academy'),
                ),
              ),
              SliverToBoxAdapter(
                child: MentorTipCard(
                  onTap: () => Navigator.pushNamed(context, '/coach'),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                      20, 12, 20, 32 + MediaQuery.paddingOf(context).bottom),
                  child: _DailyQuest(
                    completed: state.todayProgress,
                    goal: state.dailyGoal,
                  ),
                ),
              ),
            ],
          ),
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
    final messenger = context.read<AppState>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          restored
              ? messenger.tr(
                  ru: 'Жизнь восстановлена за 20 энергии.',
                  kk: 'Жан 20 энергияға қалпына келтірілді.',
                  en: 'Life restored for 20 energy.')
              : messenger.error ??
                  messenger.tr(
                      ru: 'Не удалось восстановить жизнь.',
                      kk: 'Жанды қалпына келтіру мүмкін болмады.',
                      en: 'Could not restore a life.'),
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
        final messenger = context.read<AppState>();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              restored
                  ? messenger.tr(
                      ru: 'Жизнь восстановлена. Теперь можно начать урок.',
                      kk:
                          'Жан қалпына келтірілді. Енді сабақты бастауға болады.',
                      en: 'Life restored. You can start the lesson now.')
                  : messenger.error ??
                      messenger.tr(
                          ru: 'Не удалось восстановить жизнь.',
                          kk: 'Жанды қалпына келтіру мүмкін болмады.',
                          en: 'Could not restore a life.'),
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
}
