part of '../home_screen.dart';

/// A route above the tab shell: the map owns the entire viewport and back
/// returns to the same home scroll position. Opening a lesson preserves it.
class _CoursePathScreen extends StatelessWidget {
  final _LearningMode mode;
  final ScrollController controller;
  final void Function(BuildContext context, Lesson lesson) onOpenLesson;

  const _CoursePathScreen({
    required this.mode,
    required this.controller,
    required this.onOpenLesson,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final type = switch (mode) {
      _LearningMode.basics => CourseType.rules,
      _LearningMode.quran => CourseType.quran,
      _LearningMode.arabic => CourseType.arabic,
      _LearningMode.tajwid => CourseType.tajwid,
    };
    final course = state.getCourse(type);
    final title = switch (mode) {
      _LearningMode.basics => state.tr(
          ru: 'Основы ислама', kk: 'Ислам негіздері', en: 'Basics of Islam'),
      _LearningMode.quran => state.tr(ru: 'Коран', kk: 'Құран', en: 'Quran'),
      _LearningMode.arabic =>
        state.tr(ru: 'Арабский язык', kk: 'Араб тілі', en: 'Arabic'),
      _LearningMode.tajwid =>
        state.tr(ru: 'Таджвид', kk: 'Тәжуид', en: 'Tajwid'),
    };
    final icons = switch (mode) {
      _LearningMode.basics => _HomeScreenState._rulesIcons,
      _LearningMode.quran => _HomeScreenState._quranIcons,
      _LearningMode.arabic => _HomeScreenState._arabicIcons,
      _LearningMode.tajwid => _HomeScreenState._tajwidIcons,
    };
    return Scaffold(
      key: const ValueKey('course-fullscreen'),
      backgroundColor: AppColors.ivory,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 6, 8, 6),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      title,
                      key: const ValueKey('course-fullscreen-title'),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyDark,
                      ),
                    ),
                  ),
                  IconButton(
                    key: const ValueKey('collapse-learning-path'),
                    tooltip: state.tr(
                        ru: 'Выйти из полноэкранного режима',
                        kk: 'Толық экраннан шығу',
                        en: 'Exit full screen'),
                    constraints:
                        const BoxConstraints(minWidth: 48, minHeight: 48),
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.fullscreen_exit_rounded),
                    color: AppColors.navy,
                  ),
                ],
              ),
            ),
            if (course != null)
              Expanded(
                child: Stack(
                  key: const ValueKey('learning-path-panel-expanded'),
                  children: [
                    Positioned.fill(
                        child: _LearningPathWorld(
                            mode: mode, controller: controller)),
                    Scrollbar(
                      controller: controller,
                      radius: const Radius.circular(8),
                      child: CustomScrollView(
                        key: PageStorageKey('course-path-${course.id}'),
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
                  ],
                ),
              ),
          ],
        ),
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
