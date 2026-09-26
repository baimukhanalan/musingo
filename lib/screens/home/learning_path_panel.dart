part of '../home_screen.dart';

/// A route above the tab shell: the map owns the entire viewport and back
/// starts each visit at the top. Opening a lesson preserves the active map.
class _CoursePathScreen extends StatefulWidget {
  final _LearningMode mode;
  final void Function(BuildContext context, Lesson lesson) onOpenLesson;

  const _CoursePathScreen({
    required this.mode,
    required this.onOpenLesson,
  });

  @override
  State<_CoursePathScreen> createState() => _CoursePathScreenState();
}

class _CoursePathScreenState extends State<_CoursePathScreen> {
  final controller = ScrollController(keepScrollOffset: false);
  ImageProvider? _worldImage;
  bool _worldReady = false;
  bool _worldFailed = false;
  int _imageGeneration = 0;
  Timer? _worldTimeout;
  bool _fullQuranOnly = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final width = (MediaQuery.sizeOf(context).width *
            MediaQuery.devicePixelRatioOf(context))
        .round()
        .clamp(384, 768);
    final provider = ResizeImage.resizeIfNeeded(
      width,
      null,
      AssetImage('assets/images/world_${widget.mode.name}.webp'),
    );
    if (_worldImage == provider) return;
    _worldImage = provider;
    _worldReady = false;
    _worldFailed = false;
    final generation = ++_imageGeneration;
    // Decode just the selected world, at the same bounded resolution as the
    // visible image. No course nodes are shown before that first frame is ready.
    var failed = false;
    _worldTimeout?.cancel();
    _worldTimeout = Timer(const Duration(seconds: 6), () {
      _finishWorld(generation, true);
    });
    precacheImage(provider, context, onError: (_, __) => failed = true)
        .then((_) => _finishWorld(generation, failed), onError: (_) {
      _finishWorld(generation, true);
    });
  }

  void _finishWorld(int generation, bool failed) {
    if (!mounted || generation != _imageGeneration || _worldReady) return;
    _worldTimeout?.cancel();
    setState(() {
      _worldReady = true;
      _worldFailed = failed;
    });
  }

  @override
  void dispose() {
    _worldTimeout?.cancel();
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mode = widget.mode;
    final state = context.watch<AppState>();
    final type = switch (mode) {
      _LearningMode.basics => CourseType.rules,
      _LearningMode.quran => CourseType.quran,
      _LearningMode.arabic => CourseType.arabic,
      _LearningMode.tajwid => CourseType.tajwid,
    };
    final course = state.getCourse(type);
    final hasFullQuran = mode == _LearningMode.quran &&
        (course?.lessons.any((lesson) => lesson.id.startsWith('q_full_')) ??
            false);
    final lessons = hasFullQuran
        ? course!.lessons
            .where(
                (lesson) => lesson.id.startsWith('q_full_') == _fullQuranOnly)
            .toList(growable: false)
        : course?.lessons ?? <Lesson>[];
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
                child: !_worldReady
                    ? Center(
                        child: Text(
                          state.tr(
                            ru: 'Готовим курс…',
                            kk: 'Курс дайындалуда…',
                            en: 'Preparing your course…',
                          ),
                          key: const ValueKey('course-world-loading'),
                          style: const TextStyle(color: AppColors.textGrey),
                        ),
                      )
                    : Stack(
                        key: const ValueKey('learning-path-panel-expanded'),
                        children: [
                          Positioned.fill(
                              child: _worldFailed
                                  ? const DecoratedBox(
                                      key: ValueKey('course-world-fallback'),
                                      decoration: BoxDecoration(
                                        gradient: LinearGradient(
                                          begin: Alignment.bottomCenter,
                                          end: Alignment.topCenter,
                                          colors: [
                                            AppColors.ivory,
                                            AppColors.skyLight
                                          ],
                                        ),
                                      ),
                                    )
                                  : _LearningPathWorld(
                                      mode: mode,
                                      image: _worldImage!,
                                      controller: controller)),
                          Scrollbar(
                            controller: controller,
                            radius: const Radius.circular(8),
                            child: CustomScrollView(
                              key: PageStorageKey('course-path-${course.id}'),
                              controller: controller,
                              primary: false,
                              slivers: [
                                if (hasFullQuran)
                                  SliverToBoxAdapter(
                                    child: Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 8, 20, 8),
                                      child: FilledButton.tonalIcon(
                                        key: const ValueKey(
                                            'quran-path-section-toggle'),
                                        onPressed: () {
                                          controller.jumpTo(0);
                                          setState(() =>
                                              _fullQuranOnly = !_fullQuranOnly);
                                        },
                                        icon: Icon(_fullQuranOnly
                                            ? Icons.school_outlined
                                            : Icons.menu_book_rounded),
                                        label: Text(_fullQuranOnly
                                            ? state.tr(
                                                ru: 'Вводные уроки',
                                                kk: 'Кіріспе сабақтар',
                                                en: 'Introductory lessons')
                                            : state.tr(
                                                ru: 'Весь Коран · 114 сур',
                                                kk: 'Толық Құран · 114 сүре',
                                                en: 'Full Quran · 114 surahs')),
                                      ),
                                    ),
                                  ),
                                _LessonPath(
                                  lessons: lessons,
                                  icons: icons,
                                  onOpenLesson: widget.onOpenLesson,
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
  final ImageProvider image;

  const _LearningPathWorld({
    required this.mode,
    required this.controller,
    required this.image,
  });

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
            final painting = Image(
              image: image,
              key: ValueKey('learning-world-${mode.name}'),
              width: constraints.maxWidth,
              height: canvasHeight,
              fit: BoxFit.cover,
              filterQuality: FilterQuality.medium,
              errorBuilder: (_, error, stack) => const ColoredBox(
                color: AppColors.skyLight,
              ),
            );
            return AnimatedBuilder(
              animation: controller,
              child: painting,
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
