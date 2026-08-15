import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/quran.dart';
import '../services/app_state.dart';
import '../services/quran_audio_player.dart';
import '../services/quran_repository.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_card.dart';
import '../widgets/progress_ring.dart';
import 'hafiz_mode_screen.dart';

part 'quran/chapter_screen.dart';
part 'quran/chapter_header.dart';
part 'quran/full_chapter_text_sheet.dart';
part 'quran/verse_card.dart';
part 'quran/quran_states.dart';

enum _QuranPlaybackMode { verse, chapter }

enum QuranSection { surahs, juz, hafiz }

@immutable
class QuranJuzStart {
  final int number;
  final int surahNumber;
  final int ayahNumber;

  const QuranJuzStart(this.number, this.surahNumber, this.ayahNumber);
}

const quranJuzStarts = <QuranJuzStart>[
  QuranJuzStart(1, 1, 1),
  QuranJuzStart(2, 2, 142),
  QuranJuzStart(3, 2, 253),
  QuranJuzStart(4, 3, 93),
  QuranJuzStart(5, 4, 24),
  QuranJuzStart(6, 4, 148),
  QuranJuzStart(7, 5, 82),
  QuranJuzStart(8, 6, 111),
  QuranJuzStart(9, 7, 88),
  QuranJuzStart(10, 8, 41),
  QuranJuzStart(11, 9, 93),
  QuranJuzStart(12, 11, 6),
  QuranJuzStart(13, 12, 53),
  QuranJuzStart(14, 15, 1),
  QuranJuzStart(15, 17, 1),
  QuranJuzStart(16, 18, 75),
  QuranJuzStart(17, 21, 1),
  QuranJuzStart(18, 23, 1),
  QuranJuzStart(19, 25, 21),
  QuranJuzStart(20, 27, 56),
  QuranJuzStart(21, 29, 46),
  QuranJuzStart(22, 33, 31),
  QuranJuzStart(23, 36, 28),
  QuranJuzStart(24, 39, 32),
  QuranJuzStart(25, 41, 47),
  QuranJuzStart(26, 46, 1),
  QuranJuzStart(27, 51, 31),
  QuranJuzStart(28, 58, 1),
  QuranJuzStart(29, 67, 1),
  QuranJuzStart(30, 78, 1),
];

class QuranScreen extends StatefulWidget {
  final VoidCallback? onOpenHafiz;

  const QuranScreen({super.key, this.onOpenHafiz});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late final QuranRepository _repository;
  late Future<List<QuranChapterSummary>> _chaptersFuture;
  final _searchController = TextEditingController();
  String _query = '';
  QuranSection _section = QuranSection.surahs;

  @override
  void initState() {
    super.initState();
    _repository = QuranRepository();
    _chaptersFuture = _repository.fetchChapters();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _repository.dispose();
    super.dispose();
  }

  Future<void> _refresh() async {
    final future = _repository.fetchChapters(forceRefresh: true);
    setState(() => _chaptersFuture = future);
    await future;
  }

  void _openSources() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _SourceSheet(),
    );
  }

  void _selectSection(QuranSection section) {
    if (section == QuranSection.hafiz) {
      final callback = widget.onOpenHafiz;
      if (callback != null) {
        callback();
      } else {
        Navigator.pushNamed(context, '/hafiz');
      }
      return;
    }
    if (_section == section) return;
    _searchController.clear();
    setState(() {
      _section = section;
      _query = '';
    });
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    // Реальный прогресс заучивания по сурам из AppState (без демо-данных):
    // считаем один раз за build количество закреплённых аятов (mastery >= 0.7)
    // на каждую суру, чтобы кольцо/% в строках отражали фактическое состояние.
    final Map<int, int> memorizedBySurah = <int, int>{};
    for (final item in appState.hafizProgress) {
      if (item.mastery >= 0.7) {
        memorizedBySurah[item.surahNumber] =
            (memorizedBySurah[item.surahNumber] ?? 0) + 1;
      }
    }

    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: PremiumBackground(
        child: SafeArea(
          bottom: false,
          child: FutureBuilder<List<QuranChapterSummary>>(
            future: _chaptersFuture,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const _LoadingView();
              }
              if (snapshot.hasError) {
                return _ErrorView(
                  message: snapshot.error.toString(),
                  onRetry: () => setState(
                    () => _chaptersFuture = _repository.fetchChapters(),
                  ),
                );
              }

              final chapters = snapshot.data ?? const <QuranChapterSummary>[];
              final normalizedQuery = _query.trim().toLowerCase();
              final filtered = normalizedQuery.isEmpty
                  ? chapters
                  : chapters.where((chapter) {
                      return chapter.number.toString() == normalizedQuery ||
                          chapter.latinName
                              .toLowerCase()
                              .contains(normalizedQuery) ||
                          chapter.arabicName.contains(_query.trim());
                    }).toList(growable: false);
              final visibleJuz = normalizedQuery.isEmpty
                  ? quranJuzStarts
                  : quranJuzStarts.where((entry) {
                      final chapter = chapters[entry.surahNumber - 1];
                      return entry.number.toString() == normalizedQuery ||
                          chapter.latinName
                              .toLowerCase()
                              .contains(normalizedQuery) ||
                          chapter.arabicName.contains(_query.trim());
                    }).toList(growable: false);
              final contentCount = _section == QuranSection.surahs
                  ? filtered.length
                  : visibleJuz.length;

              return RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.sky,
                child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                  itemCount: contentCount + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _QuranHeader(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        memorizedCount: appState.memorizedVerseCount,
                        dueCount: appState.hafizDueCount,
                        onSources: _openSources,
                        selectedSection: _section,
                        onSectionSelected: _selectSection,
                      );
                    }
                    if (index == contentCount + 1) {
                      return const _AttributionFooter();
                    }
                    if (_section == QuranSection.juz) {
                      final entry = visibleJuz[index - 1];
                      final chapter = chapters[entry.surahNumber - 1];
                      return _JuzTile(
                        entry: entry,
                        chapter: chapter,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => QuranChapterScreen(
                              chapter: chapter,
                              repository: _repository,
                            ),
                          ),
                        ),
                      );
                    }
                    final chapter = filtered[index - 1];
                    final memorized = memorizedBySurah[chapter.number] ?? 0;
                    final progress = chapter.ayahCount == 0
                        ? 0.0
                        : (memorized / chapter.ayahCount).clamp(0.0, 1.0);
                    return _ChapterTile(
                      chapter: chapter,
                      progress: progress,
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => QuranChapterScreen(
                            chapter: chapter,
                            repository: _repository,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _QuranHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final int memorizedCount;
  final int dueCount;
  final VoidCallback onSources;
  final QuranSection selectedSection;
  final ValueChanged<QuranSection> onSectionSelected;

  const _QuranHeader({
    required this.controller,
    required this.onChanged,
    required this.memorizedCount,
    required this.dueCount,
    required this.onSources,
    required this.selectedSection,
    required this.onSectionSelected,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Заголовок экрана + кнопка «об источниках».
        Padding(
          padding: const EdgeInsets.fromLTRB(2, 6, 0, 14),
          child: Row(
            children: [
              Expanded(
                child: Text(
                  state.tr(ru: 'Коран', kk: 'Құран', en: 'Quran'),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark,
                  ),
                ),
              ),
              _RoundIconButton(
                icon: Icons.verified_outlined,
                tooltip: state.tr(
                    ru: 'Об источниках',
                    kk: 'Дереккөздер туралы',
                    en: 'About sources'),
                onTap: onSources,
              ),
            ],
          ),
        ),
        // НавИ-хиро карточка с реальными данными Hafiz из AppState.
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [AppColors.navyDark, AppColors.navy, AppColors.navyDark],
            ),
            borderRadius: BorderRadius.circular(22),
            boxShadow: [
              BoxShadow(
                color: AppColors.navy.withValues(alpha: 0.28),
                blurRadius: 24,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            children: [
              const SizedBox(
                width: 58,
                height: 58,
                child: CatCharacter(mood: CatMood.learning, size: 58),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr(
                          ru: '114 сур • 6236 аятов',
                          kk: '114 сүре • 6236 аят',
                          en: '114 surahs • 6236 verses'),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      state.tr(
                          ru: 'Арабский текст, перевод смыслов и аудио',
                          kk: 'Араб мәтіні, мағына аудармасы және аудио',
                          en: 'Arabic text, meaning translation and audio'),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                    const SizedBox(height: 8),
                    _HafizChip(
                        memorizedCount: memorizedCount, dueCount: dueCount),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        // Премиум-строка поиска.
        _SearchField(controller: controller, onChanged: onChanged),
        const SizedBox(height: 14),
        QuranSectionTabs(
          selected: selectedSection,
          onSelected: onSectionSelected,
        ),
        const SizedBox(height: 16),
      ],
    );
  }
}

class _HafizChip extends StatelessWidget {
  final int memorizedCount;
  final int dueCount;

  const _HafizChip({required this.memorizedCount, required this.dueCount});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        state.tr(
          ru: 'Hafiz: $memorizedCount · к повторению: $dueCount',
          kk: 'Hafiz: $memorizedCount · қайталауға: $dueCount',
          en: 'Hafiz: $memorizedCount · to review: $dueCount',
        ),
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: AppColors.goldLight,
        ),
      ),
    );
  }
}

class _SearchField extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _SearchField({required this.controller, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        onChanged: onChanged,
        textInputAction: TextInputAction.search,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        decoration: InputDecoration(
          isDense: true,
          contentPadding: const EdgeInsets.symmetric(vertical: 15),
          hintText: state.tr(
              ru: 'Сура, аят или слово…',
              kk: 'Сүре, аят немесе сөз…',
              en: 'Surah, verse or word…'),
          hintStyle: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: AppColors.textLight,
          ),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.navy),
          suffixIcon: controller.text.isEmpty
              ? null
              : IconButton(
                  tooltip: state.tr(ru: 'Очистить', kk: 'Тазалау', en: 'Clear'),
                  onPressed: () {
                    controller.clear();
                    onChanged('');
                  },
                  icon: const Icon(Icons.close_rounded,
                      color: AppColors.textGrey),
                ),
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.sky, width: 1.5),
          ),
        ),
      ),
    );
  }
}

class QuranSectionTabs extends StatelessWidget {
  final QuranSection selected;
  final ValueChanged<QuranSection> onSelected;

  const QuranSectionTabs({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.ivory.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          for (final section in QuranSection.values)
            Expanded(
              child: _tab(
                _tabLabel(state, section),
                section: section,
                active: section == selected,
              ),
            ),
        ],
      ),
    );
  }

  // Локализуем только видимую подпись вкладки; исходные значения _tabs
  // остаются ключами (используются для сравнения активной вкладки).
  String _tabLabel(AppState state, QuranSection section) {
    switch (section) {
      case QuranSection.surahs:
        return state.tr(ru: 'Суры', kk: 'Сүрелер', en: 'Surahs');
      case QuranSection.juz:
        return state.tr(ru: 'Джузы', kk: 'Жүздер', en: 'Juz');
      case QuranSection.hafiz:
        return 'Hafiz';
    }
  }

  Widget _tab(
    String label, {
    required QuranSection section,
    required bool active,
  }) {
    return Semantics(
      button: true,
      selected: active,
      child: Material(
        color: active ? AppColors.navyDark : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        child: InkWell(
          key: ValueKey('quran-tab-${section.name}'),
          onTap: () => onSelected(section),
          borderRadius: BorderRadius.circular(30),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                fontWeight: FontWeight.w800,
                color: active ? AppColors.white : AppColors.textLight,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _JuzTile extends StatelessWidget {
  final QuranJuzStart entry;
  final QuranChapterSummary chapter;
  final VoidCallback onTap;

  const _JuzTile({
    required this.entry,
    required this.chapter,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      key: ValueKey('quran-juz-${entry.number}'),
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.skyLight,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${entry.number}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr(
                          ru: 'Джуз ${entry.number}',
                          kk: '${entry.number}-жүз',
                          en: 'Juz ${entry.number}',
                        ),
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
                          ru: '${chapter.latinName}, аят ${entry.ayahNumber}',
                          kk: '${chapter.latinName}, ${entry.ayahNumber}-аят',
                          en: '${chapter.latinName}, verse ${entry.ayahNumber}',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  chapter.arabicName,
                  textDirection: TextDirection.rtl,
                  style: const TextStyle(
                    fontFamily: 'Amiri',
                    fontSize: 18,
                    color: AppColors.navy,
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(
                  Icons.chevron_right_rounded,
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

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  const _RoundIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.white,
        shape: const CircleBorder(),
        elevation: 0,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: Semantics(
            button: true,
            label: tooltip,
            child: Container(
              width: 42,
              height: 42,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.border),
              ),
              child: Icon(icon, color: AppColors.navy, size: 20),
            ),
          ),
        ),
      ),
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final QuranChapterSummary chapter;
  final double progress;
  final VoidCallback onTap;

  const _ChapterTile({
    required this.chapter,
    required this.progress,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bool hasProgress = progress > 0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: AppColors.navyDark.withValues(alpha: 0.05),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: Row(
                children: [
                  // Слева: кольцо прогресса с номером суры, либо простой бейдж
                  // с номером, если заучивания ещё нет.
                  hasProgress
                      ? ProgressRing(
                          percent: progress,
                          size: 46,
                          color: AppColors.sky,
                          child: Text(
                            '${chapter.number}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 13,
                              fontWeight: FontWeight.w900,
                              color: AppColors.navy,
                            ),
                          ),
                        )
                      : Container(
                          width: 46,
                          height: 46,
                          alignment: Alignment.center,
                          decoration: const BoxDecoration(
                            color: AppColors.skyLight,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            '${chapter.number}',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              color: AppColors.navy,
                            ),
                          ),
                        ),
                  const SizedBox(width: 13),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          chapter.latinName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 16,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${chapter.revelationLabel} · ${chapter.ayahCount} ${state.tr(ru: 'аятов', kk: 'аят', en: 'verses')}',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        chapter.arabicName,
                        textAlign: TextAlign.right,
                        textDirection: TextDirection.rtl,
                        style: const TextStyle(
                          fontFamily: 'Amiri',
                          fontSize: 19,
                          color: AppColors.navy,
                        ),
                      ),
                      if (hasProgress) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${(progress * 100).round()}%',
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.sky,
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(width: 2),
                  const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textLight),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
