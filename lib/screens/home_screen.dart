import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/lesson.dart';
import '../models/learning_profile.dart';
import '../services/app_state.dart';
import '../services/app_install_service.dart';
import '../services/haptics_service.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/daily_ayah.dart';
import '../widgets/language_pills.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_label.dart';
import '../widgets/stat_badge.dart';

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
        child: SafeArea(
          bottom: false,
          // CustomScrollView только со SliverList/SliverToBoxAdapter — без
          // SliverPersistentHeader: раньше делегат с extent, не совпадающим с
          // реальной высотой, ронял геометрию скролла (чёрный экран). Здесь все
          // слайверы самоизмеряемые, поэтому такой проблемы нет.
          child: CustomScrollView(
            slivers: [
              // (1) Топ: дата + приветствие по имени из AppState + языковые пилюли.
              SliverToBoxAdapter(
                child: _GreetingHeader(name: user.name),
              ),
              if (AppInstallService.isWebInstallExperience &&
                  !AppInstallService.isInstalled)
                SliverToBoxAdapter(
                  child: _InstallBanner(
                    onTap: () => Navigator.pushNamed(context, '/install'),
                  ),
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
                    focus: state.learningGoal?.dailyFocus ??
                        state.tr(
                          ru: 'Новый материал, повторение и короткая проверка',
                          kk: 'Жаңа материал, қайталау және қысқа тексеру',
                          en: 'New material, review and a short check',
                        ),
                    recommendation: state.learningRecommendation,
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
              // (5) Совет наставника.
              SliverToBoxAdapter(
                child: _MentorTipCard(
                  onTap: () => Navigator.pushNamed(context, '/coach'),
                ),
              ),
              // Переключатель курса (суры / арабский) — существующая логика.
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
              // (6) РАЗДЕЛ 1 · ОСНОВЫ — путь курса rules (всегда доступен).
              if (rulesCourse != null) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    kicker: state.tr(
                        ru: 'Раздел 1 · Основы',
                        kk: 'Бөлім 1 · Негіздер',
                        en: 'Section 1 · Basics'),
                    title: state.tr(
                        ru: 'Основы ислама',
                        kk: 'Ислам негіздері',
                        en: 'Basics of Islam'),
                    subtitle: state.tr(
                        ru: 'Вера, Коран и пять столпов',
                        kk: 'Иман, Құран және бес парыз',
                        en: 'Faith, Quran and the five pillars'),
                  ),
                ),
                _LessonPath(
                  lessons: rulesCourse.lessons,
                  icons: _rulesIcons,
                  onOpenLesson: _openLesson,
                ),
              ],
              // (7) РАЗДЕЛ 2 · СУРЫ / АРАБСКИЙ — активный курс с кольцом прогресса.
              if (activeCourse != null) ...[
                SliverToBoxAdapter(
                  child: _SectionHeader(
                    kicker: _mode == _LearningMode.arabic
                        ? state.tr(
                            ru: 'Раздел 2 · Арабский',
                            kk: 'Бөлім 2 · Араб тілі',
                            en: 'Section 2 · Arabic')
                        : state.tr(
                            ru: 'Раздел 2 · Суры',
                            kk: 'Бөлім 2 · Сүрелер',
                            en: 'Section 2 · Surahs'),
                    title: _mode == _LearningMode.arabic
                        ? state.tr(
                            ru: 'Арабский язык',
                            kk: 'Араб тілі',
                            en: 'Arabic language')
                        : state.tr(
                            ru: 'Короткие суры',
                            kk: 'Қысқа сүрелер',
                            en: 'Short surahs'),
                    subtitle: _mode == _LearningMode.arabic
                        ? state.tr(
                            ru: 'Буквы, чтение и произношение',
                            kk: 'Әріптер, оқу және айтылым',
                            en: 'Letters, reading and pronunciation')
                        : state.tr(
                            ru: 'Слушай, повторяй и понимай смысл',
                            kk: 'Тыңда, қайтала және мағынасын түсін',
                            en: 'Listen, repeat and understand the meaning'),
                    progress: activeCourse.progress,
                  ),
                ),
                _LessonPath(
                  lessons: activeCourse.lessons,
                  icons: activeIcons,
                  onOpenLesson: _openLesson,
                ),
              ],
              SliverToBoxAdapter(
                child: _AcademyEntryCard(
                  onTap: () => Navigator.pushNamed(context, '/academy'),
                ),
              ),
              // (8) Аят дня. У карточки собственные внешние отступы (16px),
              // поэтому дополнительный Padding не оборачиваем.
              const SliverToBoxAdapter(child: DailyAyahCard()),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
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
                      kk: 'Жан қалпына келтірілді. Енді сабақты бастауға болады.',
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

/// Top block: small date label, «Ассаляму алейкум, {имя}» headline and the
/// RU/KZ/EN language pills.
class _GreetingHeader extends StatelessWidget {
  final String name;

  const _GreetingHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final firstName = _firstName(name);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    _todayLabel(state.locale.code),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              const LanguagePills(),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '${state.tr(ru: 'Ассаляму алейкум,', kk: 'Ассаламу әлейкум,', en: 'Assalamu alaikum,')}\n$firstName',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 27,
              height: 1.12,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDark,
            ),
          ),
        ],
      ),
    );
  }

  static String _firstName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'друг';
    return trimmed.split(RegExp(r'\s+')).first;
  }

  static String _todayLabel(String localeCode) {
    const weekdaysByLocale = {
      'ru': ['понедельник', 'вторник', 'среда', 'четверг', 'пятница', 'суббота', 'воскресенье'],
      'kk': ['дүйсенбі', 'сейсенбі', 'сәрсенбі', 'бейсенбі', 'жұма', 'сенбі', 'жексенбі'],
      'en': ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'],
    };
    const monthsByLocale = {
      'ru': ['января', 'февраля', 'марта', 'апреля', 'мая', 'июня', 'июля', 'августа', 'сентября', 'октября', 'ноября', 'декабря'],
      'kk': ['қаңтар', 'ақпан', 'наурыз', 'сәуір', 'мамыр', 'маусым', 'шілде', 'тамыз', 'қыркүйек', 'қазан', 'қараша', 'желтоқсан'],
      'en': ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'],
    };
    final weekdays = weekdaysByLocale[localeCode] ?? weekdaysByLocale['ru']!;
    final months = monthsByLocale[localeCode] ?? monthsByLocale['ru']!;
    final now = DateTime.now();
    return '${weekdays[now.weekday - 1]} · ${now.day} ${months[now.month - 1]}';
  }
}

/// Row of three stat badges (streak / XP / hearts). Streak and hearts keep the
/// existing tap behaviour (streak screen, heart-restore sheet).
class _StatBadgesRow extends StatelessWidget {
  final int streak;
  final int xp;
  final int hearts;
  final bool isPremium;
  final VoidCallback onStreakTap;
  final VoidCallback onHeartsTap;

  const _StatBadgesRow({
    required this.streak,
    required this.xp,
    required this.hearts,
    required this.isPremium,
    required this.onStreakTap,
    required this.onHeartsTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: PremiumCard(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        radius: 20,
        child: Row(
          children: [
            Expanded(
              child: _TapStat(
                onTap: onStreakTap,
                semanticLabel: state.tr(
                  ru: 'Дней подряд: $streak. Открыть серию.',
                  kk: 'Қатарынан күн: $streak. Серияны ашу.',
                  en: 'Day streak: $streak. Open streak.',
                ),
                child: StatBadge(
                  icon: Icons.local_fire_department_rounded,
                  value: '$streak',
                  label: state.tr(
                      ru: 'дней подряд', kk: 'қатарынан күн', en: 'day streak'),
                  accent: AppColors.gold,
                ),
              ),
            ),
            Expanded(
              child: StatBadge(
                icon: Icons.bolt_rounded,
                value: _formatXp(xp),
                label: 'XP',
                accent: AppColors.sky,
              ),
            ),
            Expanded(
              child: _TapStat(
                onTap: onHeartsTap,
                semanticLabel: isPremium
                    ? state.tr(
                        ru: 'Жизни: безлимит.',
                        kk: 'Жандар: шексіз.',
                        en: 'Lives: unlimited.')
                    : state.tr(
                        ru: 'Жизни: $hearts. Восстановить жизнь.',
                        kk: 'Жандар: $hearts. Жанды қалпына келтіру.',
                        en: 'Lives: $hearts. Restore a life.'),
                child: StatBadge(
                  icon: Icons.favorite_rounded,
                  value: isPremium ? '∞' : '$hearts',
                  label: state.tr(ru: 'жизни', kk: 'жандар', en: 'lives'),
                  accent: AppColors.coral,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _formatXp(int xp) {
    final digits = xp.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(' '); // narrow no-break space
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class _TapStat extends StatelessWidget {
  final VoidCallback onTap;
  final String semanticLabel;
  final Widget child;

  const _TapStat({
    required this.onTap,
    required this.semanticLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _InstallBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _InstallBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Material(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
            child: Row(
              children: [
                const Icon(Icons.install_mobile_rounded, color: Colors.white),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr(
                            ru: 'Установить Muslingo',
                            kk: 'Muslingo орнату',
                            en: 'Install Muslingo'),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      Text(
                        state.tr(
                            ru: 'Добавь приложение на главный экран',
                            kk: 'Қолданбаны негізгі экранға қосыңыз',
                            en: 'Add the app to your home screen'),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded, color: Colors.white),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _AcademyEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AcademyEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: PremiumCard(
            radius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.skyLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: AppColors.navy, size: 26),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr(
                            ru: 'Академия', kk: 'Академия', en: 'Academy'),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.tr(
                            ru: 'Готовые программы: суры, алфавит, основы ислама',
                            kk: 'Дайын бағдарламалар: сүрелер, әліпби, ислам негіздері',
                            en: 'Ready programs: surahs, alphabet, basics of Islam'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textGrey),
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
    final state = context.watch<AppState>();
    final minutes = _estimatedMinutes(lesson.steps.length);
    final minLabel = state.tr(ru: 'мин', kk: 'мин', en: 'min');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 6),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                    isReview
                        ? Icons.replay_circle_filled_rounded
                        : Icons.auto_awesome_rounded,
                    color: AppColors.navy,
                    size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: SectionLabel(
                    text: isReview
                        ? '${state.tr(ru: 'Повторение', kk: 'Қайталау', en: 'Review')} · $minutes $minLabel'
                        : '${state.tr(ru: 'Сегодня', kk: 'Бүгін', en: 'Today')} · $minutes $minLabel',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              lesson.title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              focus,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13.5,
                height: 1.35,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
              ),
            ),
            if (recommendation?.isNotEmpty == true) ...[
              const SizedBox(height: 10),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                decoration: BoxDecoration(
                  color: AppColors.skyLight.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  recommendation!,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12.5,
                    height: 1.35,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            PremiumButton(
              label: isReview
                  ? state.tr(
                      ru: 'Повторить сейчас',
                      kk: 'Қазір қайталау',
                      en: 'Review now')
                  : state.tr(
                      ru: 'Начать урок',
                      kk: 'Сабақты бастау',
                      en: 'Start lesson'),
              icon: Icons.play_arrow_rounded,
              onPressed: onStart,
            ),
          ],
        ),
      ),
    );
  }

  static int _estimatedMinutes(int stepCount) {
    final minutes = (stepCount / 2).ceil();
    if (minutes < 3) return 3;
    if (minutes > 15) return 15;
    return minutes;
  }
}

/// MEMORY ENGINE card: accuracy ring + review call-to-action driven by the
/// spaced-repetition state in [AppState].
class _MemoryEngineCard extends StatelessWidget {
  final double accuracy;
  final int dueCount;
  final int weakCount;
  final DateTime? nextReviewAt;
  final VoidCallback? onReview;

  const _MemoryEngineCard({
    required this.accuracy,
    required this.dueCount,
    required this.weakCount,
    required this.nextReviewAt,
    required this.onReview,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bool hasReview = (dueCount > 0 || weakCount > 0) && onReview != null;
    final int accuracyPct = (accuracy * 100).round();
    final ringColor = accuracyPct >= 80
        ? AppColors.success
        : (accuracyPct >= 60 ? AppColors.sky : AppColors.coral);

    final String description = dueCount > 0
        ? state.tr(
            ru: 'Сегодня к повторению: $dueCount · слабых мест: $weakCount',
            kk: 'Бүгін қайталауға: $dueCount · әлсіз жерлер: $weakCount',
            en: 'Due today: $dueCount · weak spots: $weakCount')
        : weakCount > 0
            ? state.tr(
                ru: 'Слабых мест: $weakCount — закрепим, пока не забылось',
                kk: 'Әлсіз жерлер: $weakCount — ұмытылмай тұрып бекітеміз',
                en: "Weak spots: $weakCount — let's reinforce before you forget")
            : '${state.tr(ru: 'Всё под контролем · следующее повторение: ', kk: 'Барлығы бақылауда · келесі қайталау: ', en: 'All under control · next review: ')}'
                '${_reviewDateLabel(nextReviewAt)}';

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: PremiumCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SectionLabel(text: 'Memory Engine'),
            const SizedBox(height: 14),
            Row(
              children: [
                ProgressRing(
                  percent: accuracy,
                  size: 62,
                  color: ringColor,
                  child: Text(
                    '$accuracyPct%',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: ringColor,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr(
                            ru: 'Точность по памяти',
                            kk: 'Есте сақтау дәлдігі',
                            en: 'Memory accuracy'),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        description,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasReview) ...[
              const SizedBox(height: 16),
              PremiumButton(
                label: state.tr(
                    ru: 'Повторить', kk: 'Қайталау', en: 'Review'),
                icon: Icons.replay_rounded,
                variant: PremiumButtonVariant.navy,
                onPressed: onReview,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Mentor tip card with the mascot and a link into the AI Coach.
class _MentorTipCard extends StatelessWidget {
  final VoidCallback onTap;

  const _MentorTipCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: PremiumCard(
            padding: const EdgeInsets.fromLTRB(12, 12, 14, 12),
            child: Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: AppColors.skyLight,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  clipBehavior: Clip.antiAlias,
                  child: const CatCharacter(mood: CatMood.support, size: 58),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SectionLabel(
                          text: state.tr(
                              ru: 'Совет наставника',
                              kk: 'Ұстаз кеңесі',
                              en: 'Mentor tip')),
                      const SizedBox(height: 5),
                      Text(
                        state.tr(
                          ru: 'Учись понемногу каждый день — пять минут регулярно '
                              'работают лучше часа раз в неделю.',
                          kk: 'Күн сайын аз-аздан үйрен — тұрақты бес минут '
                              'аптасына бір сағаттан тиімдірек.',
                          en: 'Learn a little every day — five regular minutes '
                              'beat an hour once a week.',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          height: 1.32,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 6),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textGrey),
              ],
            ),
          ),
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
    final state = context.watch<AppState>();
    final arabicLabel =
        state.tr(ru: 'Арабский', kk: 'Араб тілі', en: 'Arabic');
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 4),
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(30),
          border: Border.all(color: AppColors.border, width: 1.5),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyDark.withValues(alpha: 0.05),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            _ModeSegment(
              selected: mode == _LearningMode.quran,
              label: state.tr(ru: 'Суры', kk: 'Сүрелер', en: 'Surahs'),
              icon: Icons.menu_book_rounded,
              onTap: () => onChanged(_LearningMode.quran),
            ),
            _ModeSegment(
              selected: mode == _LearningMode.arabic,
              label: nativeLanguage == null
                  ? arabicLabel
                  : '$arabicLabel · ${nativeLanguage!.label}',
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
            color: selected ? AppColors.navyDark : Colors.transparent,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon,
                  size: 19,
                  color: selected ? Colors.white : AppColors.textLight),
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
                    color: selected ? Colors.white : AppColors.textLight,
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
    final state = context.watch<AppState>();
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
          Text(
            state.tr(
                ru: 'Выбери родной язык',
                kk: 'Ана тіліңді таңда',
                en: 'Choose your native language'),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            state.tr(
                ru: 'Это нужно один раз, чтобы объяснения в арабском курсе были понятнее.',
                kk: 'Бұл араб курсындағы түсіндірмелер түсінікті болу үшін бір рет қажет.',
                en: 'This is needed once so explanations in the Arabic course are clearer.'),
            textAlign: TextAlign.center,
            style: const TextStyle(
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
    final state = context.watch<AppState>();
    final canRestore = !isPremium && hearts < 5 && energy >= 20;
    final subtitle = isPremium
        ? state.tr(
            ru: 'У тебя уже безлимитные жизни.',
            kk: 'Сенде қазірдің өзінде шексіз жандар бар.',
            en: 'You already have unlimited lives.')
        : hearts >= 5
            ? state.tr(
                ru: 'Жизни уже полные.',
                kk: 'Жандар толық.',
                en: 'Lives are already full.')
            : energy >= 20
                ? state.tr(
                    ru: 'Потрать 20 энергии и продолжай уроки без ожидания.',
                    kk: '20 энергия жұмсап, сабақтарды күтпей жалғастыр.',
                    en: 'Spend 20 energy and keep learning without waiting.')
                : state.tr(
                    ru: 'Нужно 20 энергии. Проходи уроки, чтобы накопить её.',
                    kk: '20 энергия қажет. Оны жинау үшін сабақтардан өт.',
                    en: 'You need 20 energy. Complete lessons to earn it.');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.favorite_rounded, color: AppColors.error, size: 46),
            const SizedBox(height: 8),
            Text(
              state.tr(
                  ru: 'Восстановить жизнь',
                  kk: 'Жанды қалпына келтіру',
                  en: 'Restore a life'),
              textAlign: TextAlign.center,
              style: const TextStyle(
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
                    label: state.tr(ru: 'Жизни', kk: 'Жандар', en: 'Lives'),
                    value: isPremium ? 'MAX' : '$hearts/5',
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniResource(
                    icon: Icons.battery_charging_full_rounded,
                    label:
                        state.tr(ru: 'Энергия', kk: 'Энергия', en: 'Energy'),
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
              label: Text(state.tr(
                  ru: 'Восстановить за 20 энергии',
                  kk: '20 энергияға қалпына келтіру',
                  en: 'Restore for 20 energy')),
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
    final state = context.watch<AppState>();
    return Semantics(
      button: true,
      label: state.tr(
          ru: 'Выбрать ${language.label}',
          kk: '${language.label} таңдау',
          en: 'Choose ${language.label}'),
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

/// Small-caps section header (kicker + title + subtitle) with an optional
/// course-progress ring on the right.
class _SectionHeader extends StatelessWidget {
  final String kicker;
  final String title;
  final String subtitle;
  final double? progress;

  const _SectionHeader({
    required this.kicker,
    required this.title,
    required this.subtitle,
    this.progress,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SectionLabel(text: kicker),
                const SizedBox(height: 6),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          if (progress != null) ...[
            const SizedBox(width: 12),
            ProgressRing(
              percent: progress!,
              size: 54,
              color: AppColors.sky,
              child: Text(
                '${(progress! * 100).round()}%',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
            ),
          ],
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
    // Ленивый путь уроков: SliverList строит только видимые узлы, а не весь
    // курс сразу (как было в Column внутри SliverToBoxAdapter), сохраняя
    // ленивость CustomScrollView. Геометрия змейки держится на фиксированной
    // высоте узла и горизонтальном сдвиге по индексу (offsets[index % ...]) —
    // каждый узел самодостаточен, соединителей между соседями нет, поэтому
    // ленивое построение не меняет верстку.
    return SliverPadding(
      padding: const EdgeInsets.only(bottom: 24),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            final lesson = lessons[index];
            const offsets = [-0.42, -0.1, 0.28, 0.02, -0.34];
            final nodeOffset = offsets[index % offsets.length];
            final compact = MediaQuery.sizeOf(context).width < 430;
            final mascotOffset = nodeOffset <= 0
                ? nodeOffset + (compact ? 1.08 : 0.8)
                : nodeOffset - (compact ? 1.08 : 0.8);
            final mascotSize = compact ? 82.0 : 94.0;
            final isCurrent = lesson.status == LessonStatus.available ||
                lesson.status == LessonStatus.inProgress;
            return SizedBox(
              // Узел урока (круг 70 + отступ 12 + плашка названия ~29 ≈ 111px)
              // не влезал в 104 → Column переполнялся на 7px. Даём запас.
              height: isCurrent ? 134 : 116,
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
          },
          childCount: lessons.length,
        ),
      ),
    );
  }
}

void _showLockedLessonDialog(BuildContext context, Lesson lesson) {
  final state = context.read<AppState>();
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
            Text(
              state.tr(
                  ru: 'Заверши предыдущий урок, чтобы открыть этот шаг.',
                  kk: 'Осы қадамды ашу үшін алдыңғы сабақты аяқта.',
                  en: 'Finish the previous lesson to unlock this step.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
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
                label: Text(state.tr(
                    ru: 'Понятно', kk: 'Түсінікті', en: 'Got it')),
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
    final state = context.watch<AppState>();
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
      label: '${lesson.title}. ${locked ? state.tr(ru: 'Закрыто', kk: 'Жабық', en: 'Locked') : state.tr(ru: 'Открыть урок', kk: 'Сабақты ашу', en: 'Open lesson')}',
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
  final int goal;

  const _DailyQuest({required this.completed, required this.goal});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final safeGoal = goal <= 0 ? 3 : goal;
    final progress = (completed / safeGoal).clamp(0.0, 1.0);
    return PremiumCard(
      radius: 20,
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
                color: AppColors.goldLight,
                borderRadius: BorderRadius.circular(14)),
            child: const Icon(Icons.emoji_events_rounded,
                color: AppColors.gold, size: 29),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    state.tr(
                        ru: 'Учебная цель',
                        kk: 'Оқу мақсаты',
                        en: 'Learning goal'),
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark)),
                Text(
                    '$completed ${state.tr(ru: 'из', kk: 'ішінен', en: 'of')} $safeGoal ${state.tr(ru: 'уроков', kk: 'сабақ', en: 'lessons')}',
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
