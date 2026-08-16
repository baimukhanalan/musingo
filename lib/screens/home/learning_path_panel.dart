part of '../home_screen.dart';

class _LearningPathPanel extends StatelessWidget {
  final _LearningMode mode;
  final Course course;
  final List<IconData> icons;
  final NativeLanguage? nativeLanguage;
  final ScrollController controller;
  final bool expanded;
  final VoidCallback onToggleExpanded;
  final ValueChanged<_LearningMode> onModeChanged;
  final VoidCallback onChooseNativeLanguage;
  final void Function(BuildContext context, Lesson lesson) onOpenLesson;

  const _LearningPathPanel({
    required this.mode,
    required this.course,
    required this.icons,
    required this.nativeLanguage,
    required this.controller,
    required this.expanded,
    required this.onToggleExpanded,
    required this.onModeChanged,
    required this.onChooseNativeLanguage,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final panelHeight = expanded
        ? double.infinity
        : (MediaQuery.sizeOf(context).height * 0.59)
            .clamp(460.0, 550.0)
            .toDouble();
    final (kicker, title, subtitle) = switch (mode) {
      _LearningMode.basics => (
          state.tr(ru: 'Основы', kk: 'Негіздер', en: 'Basics'),
          state.tr(
              ru: 'Основы ислама',
              kk: 'Ислам негіздері',
              en: 'Basics of Islam'),
          state.tr(
              ru: 'Вера, Коран и пять столпов',
              kk: 'Иман, Құран және бес парыз',
              en: 'Faith, Quran and the five pillars'),
        ),
      _LearningMode.quran => (
          state.tr(ru: 'Коран', kk: 'Құран', en: 'Quran'),
          state.tr(
              ru: 'Путь по сурам',
              kk: 'Сүрелер жолы',
              en: 'Surah learning path'),
          state.tr(
              ru: 'Слушай, понимай и повторяй',
              kk: 'Тыңда, түсін және қайтала',
              en: 'Listen, understand and repeat'),
        ),
      _LearningMode.arabic => (
          state.tr(ru: 'Арабский', kk: 'Араб тілі', en: 'Arabic'),
          state.tr(
              ru: 'Арабское чтение', kk: 'Арабша оқу', en: 'Arabic reading'),
          state.tr(
              ru: 'От букв к кораническим фразам',
              kk: 'Әріптен Құран сөз тіркестеріне дейін',
              en: 'From letters to Quranic phrases'),
        ),
    };

    return Container(
      key: ValueKey(
        expanded ? 'learning-path-panel-expanded' : 'learning-path-panel',
      ),
      height: panelHeight,
      margin: expanded
          ? const EdgeInsets.fromLTRB(10, 8, 10, 8)
          : const EdgeInsets.fromLTRB(20, 16, 20, 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(expanded ? 14 : 20),
        border: Border.all(color: AppColors.border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.07),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
            child: _ModeSwitch(
              mode: mode,
              onChanged: onModeChanged,
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          SectionLabel(text: kicker),
                          const SizedBox(width: 8),
                          Text(
                            state.tr(
                              ru: _lessonCountRu(course.lessons.length),
                              kk: '${course.lessons.length} сабақ',
                              en: '${course.lessons.length} lessons',
                            ),
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 11,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textGrey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navyDark,
                        ),
                      ),
                      Text(
                        subtitle,
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
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  key: ValueKey(
                    expanded
                        ? 'collapse-learning-path'
                        : 'expand-learning-path',
                  ),
                  tooltip: expanded
                      ? state.tr(
                          ru: 'Свернуть путь',
                          kk: 'Жолды кішірейту',
                          en: 'Collapse path',
                        )
                      : state.tr(
                          ru: 'Развернуть путь',
                          kk: 'Жолды кеңейту',
                          en: 'Expand path',
                        ),
                  onPressed: onToggleExpanded,
                  icon: Icon(
                    expanded
                        ? Icons.fullscreen_exit_rounded
                        : Icons.fullscreen_rounded,
                  ),
                  color: AppColors.navy,
                ),
                const SizedBox(width: 2),
                ProgressRing(
                  percent: course.progress,
                  size: 46,
                  color: AppColors.sky,
                  child: Text(
                    '${(course.progress * 100).round()}%',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (mode == _LearningMode.arabic)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: SizedBox(
                width: double.infinity,
                height: 34,
                child: OutlinedButton.icon(
                  key: const ValueKey('choose-native-language'),
                  onPressed: onChooseNativeLanguage,
                  icon: const Icon(Icons.language_rounded, size: 17),
                  label: Text(
                    nativeLanguage == null
                        ? state.tr(
                            ru: 'Выбрать язык объяснений',
                            kk: 'Түсіндіру тілін таңдау',
                            en: 'Choose explanation language')
                        : state.tr(
                            ru: 'Язык объяснений: ${nativeLanguage!.label}',
                            kk: 'Түсіндіру тілі: ${nativeLanguage!.label}',
                            en: 'Explanation language: ${nativeLanguage!.label}'),
                  ),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.navy,
                    side: const BorderSide(color: AppColors.border),
                    textStyle: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ),
            ),
          const Divider(height: 1, color: AppColors.border),
          Expanded(
            child: Scrollbar(
              controller: controller,
              thumbVisibility: true,
              radius: const Radius.circular(8),
              child: CustomScrollView(
                key: ValueKey('course-path-${course.id}'),
                controller: controller,
                primary: false,
                slivers: [
                  _LessonPath(
                    lessons: course.lessons,
                    icons: icons,
                    onOpenLesson: onOpenLesson,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ModeSwitch extends StatelessWidget {
  final _LearningMode mode;
  final ValueChanged<_LearningMode> onChanged;

  const _ModeSwitch({
    required this.mode,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
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
            key: const ValueKey('course-mode-basics'),
            selected: mode == _LearningMode.basics,
            label: state.tr(ru: 'Основы', kk: 'Негіздер', en: 'Basics'),
            icon: Icons.account_balance_rounded,
            onTap: () => onChanged(_LearningMode.basics),
          ),
          _ModeSegment(
            key: const ValueKey('course-mode-quran'),
            selected: mode == _LearningMode.quran,
            label: state.tr(ru: 'Коран', kk: 'Құран', en: 'Quran'),
            icon: Icons.menu_book_rounded,
            onTap: () => onChanged(_LearningMode.quran),
          ),
          _ModeSegment(
            key: const ValueKey('course-mode-arabic'),
            selected: mode == _LearningMode.arabic,
            label: state.tr(ru: 'Арабский', kk: 'Араб тілі', en: 'Arabic'),
            icon: Icons.translate_rounded,
            onTap: () => onChanged(_LearningMode.arabic),
          ),
        ],
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
    super.key,
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
                    fontSize: 11,
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
