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
      _LearningMode.tajwid => (
          state.tr(ru: 'Таджвид', kk: 'Тәжуид', en: 'Tajwid'),
          state.tr(
              ru: 'Правила чтения',
              kk: 'Оқу ережелері',
              en: 'Rules of recitation'),
          state.tr(
              ru: 'Махрадж, гунна, мадд и вакф',
              kk: 'Махраж, ғұнна, мадд және уақф',
              en: 'Makharij, ghunnah, madd and waqf'),
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
                      Wrap(
                        spacing: 8,
                        runSpacing: 2,
                        children: [
                          SectionLabel(text: kicker),
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
                        maxLines: 2,
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
                        maxLines: 2,
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
                // The selected language can wrap with larger system text.
                child: OutlinedButton.icon(
                  key: const ValueKey('choose-native-language'),
                  onPressed: onChooseNativeLanguage,
                  icon: const Icon(Icons.language_rounded, size: 17),
                  label: Text(state.tr(
                    ru: 'Язык обучения: ${_languageName(nativeLanguage ?? NativeLanguage.russian)}',
                    kk: 'Оқу тілі: ${_languageName(nativeLanguage ?? NativeLanguage.kazakh)}',
                    en: 'Learning language: ${_languageName(nativeLanguage ?? NativeLanguage.english)}',
                  )),
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
            child: Stack(
              children: [
                Positioned.fill(
                  child: _LearningPathWorld(
                    mode: mode,
                    controller: controller,
                  ),
                ),
                AnimatedSwitcher(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 240),
                  layoutBuilder: semanticSwitcherLayout,
                  switchInCurve: Curves.easeOutCubic,
                  switchOutCurve: Curves.easeInCubic,
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(
                      scale: Tween<double>(begin: 0.985, end: 1).animate(
                        animation,
                      ),
                      child: child,
                    ),
                  ),
                  child: Scrollbar(
                    key: ValueKey('course-scrollbar-${course.id}'),
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
          ),
        ],
      ),
    );
  }
}

class _LearningPathWorld extends StatelessWidget {
  final _LearningMode mode;
  final ScrollController controller;

  const _LearningPathWorld({required this.mode, required this.controller});

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return ExcludeSemantics(
      child: IgnorePointer(
        child: RepaintBoundary(
          child: LayoutBuilder(builder: (context, constraints) {
            // A single compressed painting per course. Scroll reveals its
            // ground-to-sky journey; no idle animation or per-lesson bitmaps.
            final canvasHeight = (constraints.maxWidth * 2)
                .clamp(constraints.maxHeight * 1.65, double.infinity);
            final image = Image.asset(
              'assets/images/world_${mode.name}.webp',
              key: ValueKey('learning-world-${mode.name}'),
              width: constraints.maxWidth,
              height: canvasHeight,
              fit: BoxFit.cover,
              cacheWidth: (constraints.maxWidth *
                      MediaQuery.devicePixelRatioOf(context))
                  .round()
                  .clamp(384, 768),
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, error, stack) => const ColoredBox(
                color: AppColors.skyLight,
              ),
            );
            return AnimatedBuilder(
              animation: controller,
              child: image,
              builder: (context, child) {
                // Expansion may briefly retain the outgoing scrollable during
                // its crossfade. The latest attached viewport owns the scene.
                final position = controller.positions.isNotEmpty
                    ? controller.positions.last
                    : null;
                final progress = !reducedMotion &&
                        position != null &&
                        position.hasContentDimensions &&
                        position.maxScrollExtent > 0
                    ? (position.pixels / position.maxScrollExtent)
                        .clamp(0.0, 1.0)
                    : 0.0;
                return Stack(
                  key: const ValueKey('learning-path-world'),
                  clipBehavior: Clip.hardEdge,
                  fit: StackFit.expand,
                  children: [
                    Positioned(
                      top: -(canvasHeight - constraints.maxHeight) *
                          (1 - progress),
                      left: 0,
                      right: 0,
                      height: canvasHeight,
                      child: child!,
                    ),
                    const ColoredBox(color: Color(0x22FFFFFF)),
                  ],
                );
              },
            );
          }),
        ),
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
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
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
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              _ModeSegment(
                key: const ValueKey('course-mode-arabic'),
                selected: mode == _LearningMode.arabic,
                label: state.tr(ru: 'Арабский', kk: 'Араб тілі', en: 'Arabic'),
                icon: Icons.translate_rounded,
                onTap: () => onChanged(_LearningMode.arabic),
              ),
              _ModeSegment(
                key: const ValueKey('course-mode-tajwid'),
                selected: mode == _LearningMode.tajwid,
                label: state.tr(ru: 'Таджвид', kk: 'Тәжуид', en: 'Tajwid'),
                icon: Icons.graphic_eq_rounded,
                onTap: () => onChanged(_LearningMode.tajwid),
              ),
            ],
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
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(26),
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
    return SingleChildScrollView(
      child: Container(
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
                  ru: 'Язык обучения', kk: 'Оқу тілі', en: 'Learning language'),
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
                  ru: 'Этот язык используется во всём приложении, уроках и общении с Айном.',
                  kk: 'Бұл тіл бүкіл қолданбада, сабақтарда және Айнмен сөйлесуде қолданылады.',
                  en: 'This language is used throughout the app, lessons and conversations with Ayn.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                height: 1.35,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            for (final language in const [
              NativeLanguage.russian,
              NativeLanguage.kazakh,
              NativeLanguage.english
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _LanguageButton(
                  language: language,
                  onTap: () => onSelected(language),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
