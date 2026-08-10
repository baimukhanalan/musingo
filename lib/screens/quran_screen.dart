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

enum _QuranPlaybackMode { verse, chapter }

class QuranScreen extends StatefulWidget {
  const QuranScreen({super.key});

  @override
  State<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends State<QuranScreen> {
  late final QuranRepository _repository;
  late Future<List<QuranChapterSummary>> _chaptersFuture;
  final _searchController = TextEditingController();
  String _query = '';

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

              return RefreshIndicator(
                onRefresh: _refresh,
                color: AppColors.sky,
                child: ListView.builder(
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                  itemCount: filtered.length + 2,
                  itemBuilder: (context, index) {
                    if (index == 0) {
                      return _QuranHeader(
                        controller: _searchController,
                        onChanged: (value) => setState(() => _query = value),
                        memorizedCount: appState.memorizedVerseCount,
                        dueCount: appState.hafizDueCount,
                        onSources: _openSources,
                      );
                    }
                    if (index == filtered.length + 1) {
                      return const _AttributionFooter();
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

  const _QuranHeader({
    required this.controller,
    required this.onChanged,
    required this.memorizedCount,
    required this.dueCount,
    required this.onSources,
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
                    _HafizChip(memorizedCount: memorizedCount, dueCount: dueCount),
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
        // Табы-пилюли (визуальные): активна вкладка «Суры».
        const _QuranTabs(),
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
                  tooltip: state.tr(
                      ru: 'Очистить', kk: 'Тазалау', en: 'Clear'),
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

/// Пилюльный контейнер вкладок раздела Корана. Оформление совпадает с
/// LanguagePills (bg ivory .72, pill navy). Визуальный элемент по прототипу 1e:
/// активна вкладка «Суры» (единственный реализованный список экрана).
class _QuranTabs extends StatelessWidget {
  const _QuranTabs();

  static const List<String> _tabs = ['Суры', 'Джузы', 'Hafiz'];

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
          for (final tab in _tabs)
            Expanded(
                child: _tab(_tabLabel(state, tab), active: tab == 'Суры')),
        ],
      ),
    );
  }

  // Локализуем только видимую подпись вкладки; исходные значения _tabs
  // остаются ключами (используются для сравнения активной вкладки).
  String _tabLabel(AppState state, String tab) {
    switch (tab) {
      case 'Суры':
        return state.tr(ru: 'Суры', kk: 'Сүрелер', en: 'Surahs');
      case 'Джузы':
        return state.tr(ru: 'Джузы', kk: 'Жүздер', en: 'Juz');
      default:
        return tab;
    }
  }

  Widget _tab(String label, {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: active ? AppColors.navyDark : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: active ? AppColors.white : AppColors.textLight,
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

class QuranChapterScreen extends StatefulWidget {
  final QuranChapterSummary chapter;
  final QuranRepository repository;

  const QuranChapterScreen({
    super.key,
    required this.chapter,
    required this.repository,
  });

  @override
  State<QuranChapterScreen> createState() => _QuranChapterScreenState();
}

class _QuranChapterScreenState extends State<QuranChapterScreen> {
  late Future<QuranChapter> _chapterFuture;
  late final QuranAudioPlayer _audioPlayer;
  StreamSubscription<QuranAudioPlaybackState>? _stateSubscription;
  bool _isPlaying = false;
  int? _activeVerse;
  int? _loadingVerse;
  bool _isChapterLoading = false;
  _QuranPlaybackMode? _playbackMode;
  List<QuranVerse> _chapterQueue = const [];
  int _chapterQueueIndex = 0;
  bool _chapterUsesVerseQueue = false;

  @override
  void initState() {
    super.initState();
    _chapterFuture = widget.repository.fetchChapter(widget.chapter);
    _audioPlayer = QuranAudioPlayer();
    _stateSubscription = _audioPlayer.playbackStateStream.listen((state) {
      if (!mounted) return;
      if (state.completed &&
          _playbackMode == _QuranPlaybackMode.chapter &&
          _chapterUsesVerseQueue) {
        unawaited(_playNextChapterVerse());
        return;
      }
      setState(() {
        _isPlaying = state.playing;
        if (state.completed) {
          _activeVerse = null;
          _loadingVerse = null;
          _isChapterLoading = false;
          _playbackMode = null;
        }
      });
    });
  }

  @override
  void dispose() {
    _stateSubscription?.cancel();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _toggleAudio(QuranVerse verse) async {
    if (!context.read<AppState>().soundEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AppState>().tr(
            ru: 'Аудио выключено в настройках.',
            kk: 'Аудио баптауларда өшірілген.',
            en: 'Audio is turned off in settings.',
          )),
          backgroundColor: AppColors.navy,
        ),
      );
      return;
    }
    try {
      if (_activeVerse == verse.numberInChapter) {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          _resumePlayback(verse.numberInChapter);
        }
        return;
      }

      setState(() {
        _playbackMode = _QuranPlaybackMode.verse;
        _chapterQueue = const [];
        _chapterQueueIndex = 0;
        _chapterUsesVerseQueue = false;
        _isChapterLoading = false;
        _loadingVerse = verse.numberInChapter;
      });
      await _playVerse(verse);
    } catch (error) {
      debugPrint('Quran audio playback failed: $error');
      if (!mounted) return;
      _clearAudioState();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AppState>().tr(
            ru: 'Аудио не загрузилось. Проверьте интернет.',
            kk: 'Аудио жүктелмеді. Интернетті тексеріңіз.',
            en: 'Audio failed to load. Check your internet.',
          )),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleChapterAudio(QuranChapter chapter) async {
    if (!context.read<AppState>().soundEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AppState>().tr(
            ru: 'Аудио выключено в настройках.',
            kk: 'Аудио баптауларда өшірілген.',
            en: 'Audio is turned off in settings.',
          )),
          backgroundColor: AppColors.navy,
        ),
      );
      return;
    }

    try {
      if (_playbackMode == _QuranPlaybackMode.chapter) {
        if (_isPlaying) {
          await _audioPlayer.pause();
        } else {
          await _audioPlayer.play();
        }
        return;
      }

      setState(() {
        _playbackMode = _QuranPlaybackMode.chapter;
        _chapterQueue = const [];
        _chapterQueueIndex = 0;
        _chapterUsesVerseQueue = false;
        _isChapterLoading = true;
        _activeVerse = null;
        _loadingVerse = null;
      });
      try {
        await _playFullChapter(chapter);
      } catch (error) {
        debugPrint('Full Quran chapter audio failed, falling back: $error');
        final firstVerse = chapter.verses.first;
        if (!mounted) return;
        setState(() {
          _chapterQueue = chapter.verses;
          _chapterQueueIndex = 0;
          _chapterUsesVerseQueue = true;
          _loadingVerse = firstVerse.numberInChapter;
        });
        await _playVerse(firstVerse);
      }
    } catch (error) {
      debugPrint('Quran chapter audio playback failed: $error');
      if (!mounted) return;
      _clearAudioState();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AppState>().tr(
            ru: 'Сура не запустилась. Проверьте интернет.',
            kk: 'Сүре іске қосылмады. Интернетті тексеріңіз.',
            en: 'The surah did not start. Check your internet.',
          )),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _playNextChapterVerse() async {
    if (_playbackMode != _QuranPlaybackMode.chapter ||
        _chapterQueue.isEmpty ||
        !mounted) {
      return;
    }

    final nextIndex = _chapterQueueIndex + 1;
    if (nextIndex >= _chapterQueue.length) {
      _clearAudioState();
      return;
    }

    final nextVerse = _chapterQueue[nextIndex];
    setState(() {
      _isPlaying = false;
      _isChapterLoading = true;
      _chapterQueueIndex = nextIndex;
      _loadingVerse = nextVerse.numberInChapter;
    });

    try {
      await _playVerse(nextVerse);
    } catch (error) {
      debugPrint('Quran chapter next verse failed: $error');
      if (!mounted) return;
      _clearAudioState();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AppState>().tr(
            ru: 'Воспроизведение суры остановилось. Повтори позже.',
            kk: 'Сүренің ойнатылуы тоқтады. Кейінірек қайталаңыз.',
            en: 'Surah playback stopped. Try again later.',
          )),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _playVerse(QuranVerse verse) async {
    final sources = <String>[
      verse.audioUrl,
      if (verse.audioFallbackUrl != null) verse.audioFallbackUrl!,
    ];
    Object? lastError;
    for (final source in sources) {
      try {
        await _audioPlayer.playUrl(source);
        lastError = null;
        if (mounted) {
          setState(() {
            _activeVerse = verse.numberInChapter;
            _loadingVerse = null;
            _isChapterLoading = false;
          });
        }
        return;
      } catch (error) {
        lastError = error;
        debugPrint('Quran audio source failed: $source $error');
        await _audioPlayer.stop();
      }
    }
    if (lastError != null) throw lastError;
  }

  Future<void> _playFullChapter(QuranChapter chapter) async {
    await _audioPlayer.playUrl(chapter.fullAudioUrl);
    if (!mounted) return;
    setState(() {
      _activeVerse = null;
      _loadingVerse = null;
      _isChapterLoading = false;
      _chapterUsesVerseQueue = false;
    });
  }

  void _clearAudioState() {
    if (!mounted) return;
    setState(() {
      _activeVerse = null;
      _loadingVerse = null;
      _isPlaying = false;
      _isChapterLoading = false;
      _playbackMode = null;
      _chapterQueue = const [];
      _chapterQueueIndex = 0;
      _chapterUsesVerseQueue = false;
    });
  }

  void _resumePlayback(int verseNumber) {
    _audioPlayer.play().catchError((_) {
      if (!mounted) return;
      setState(() {
        if (_activeVerse == verseNumber) _activeVerse = null;
        _loadingVerse = null;
        _isChapterLoading = false;
        _playbackMode = null;
      });
    });
  }

  void _showFullChapterText(QuranChapter chapter) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: AppColors.background,
      builder: (_) => _FullChapterTextSheet(chapter: chapter),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.ivory,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: AppColors.textDark,
        elevation: 0,
        title: Text(
          '${widget.chapter.number}. ${widget.chapter.latinName}',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: PremiumBackground(
        floatingLetters: false,
        child: FutureBuilder<QuranChapter>(
          future: _chapterFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const _LoadingView();
            }
            if (snapshot.hasError) {
              return _ErrorView(
                message: snapshot.error.toString(),
                onRetry: () => setState(
                  () => _chapterFuture =
                      widget.repository.fetchChapter(widget.chapter),
                ),
              );
            }
            final chapter = snapshot.data!;
            return ListView.separated(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
              itemCount: chapter.verses.length + 3,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                if (index == 0) return _ChapterHeader(chapter: chapter.summary);
                if (index == 1) {
                  return _ChapterAudioBar(
                    chapter: chapter,
                    isLoading: _isChapterLoading,
                    isPlaying:
                        _playbackMode == _QuranPlaybackMode.chapter &&
                            _isPlaying,
                    activeVerse: _playbackMode == _QuranPlaybackMode.chapter
                        ? _activeVerse
                        : null,
                    onPlay: () => _toggleChapterAudio(chapter),
                    onOpenText: () => _showFullChapterText(chapter),
                  );
                }
                if (index == chapter.verses.length + 2) {
                  return const _AttributionFooter();
                }
                final verse = chapter.verses[index - 2];
                final hafizProgress = appState.hafizProgressFor(
                  chapter.summary.number,
                  verse.numberInChapter,
                );
                return _VerseCard(
                  verse: verse,
                  isLoading: _loadingVerse == verse.numberInChapter,
                  isActive: _activeVerse == verse.numberInChapter,
                  isPlaying: _activeVerse == verse.numberInChapter && _isPlaying,
                  onPlay: () => _toggleAudio(verse),
                  masteryLabel: hafizProgress?.masteryLabel,
                  mastery: hafizProgress?.mastery,
                  onHafiz: () async {
                    await _audioPlayer.stop();
                    if (!context.mounted) return;
                    await Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => HafizModeScreen(
                          chapter: chapter.summary,
                          verse: verse,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          },
        ),
      ),
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  final QuranChapterSummary chapter;

  const _ChapterHeader({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(20),
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
      child: Column(
        children: [
          Text(
            chapter.arabicName,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${chapter.revelationLabel} • ${chapter.ayahCount} ${state.tr(ru: 'аятов', kk: 'аят', en: 'verses')}',
            style: const TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterAudioBar extends StatelessWidget {
  final QuranChapter chapter;
  final bool isLoading;
  final bool isPlaying;
  final int? activeVerse;
  final VoidCallback onPlay;
  final VoidCallback onOpenText;

  const _ChapterAudioBar({
    required this.chapter,
    required this.isLoading,
    required this.isPlaying,
    required this.activeVerse,
    required this.onPlay,
    required this.onOpenText,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final progress = isLoading
        ? state.tr(
            ru: 'Загрузка цельной суры',
            kk: 'Тұтас сүре жүктелуде',
            en: 'Loading the full surah')
        : activeVerse == null
            ? (isPlaying
                ? state.tr(
                    ru: 'Цельное аудио без пауз',
                    kk: 'Үзіліссіз тұтас аудио',
                    en: 'Full audio without pauses')
                : state.tr(
                    ru: 'Слушать с начала',
                    kk: 'Басынан тыңдау',
                    en: 'Listen from the start'))
            : state.tr(
                ru: 'Аят $activeVerse из ${chapter.summary.ayahCount}',
                kk: 'Аят $activeVerse / ${chapter.summary.ayahCount}',
                en: 'Verse $activeVerse of ${chapter.summary.ayahCount}');
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: isPlaying
                    ? state.tr(
                        ru: 'Пауза суры',
                        kk: 'Сүрені кідірту',
                        en: 'Pause surah')
                    : state.tr(
                        ru: 'Слушать всю суру',
                        kk: 'Барлық сүрені тыңдау',
                        en: 'Listen to the whole surah'),
                child: Tooltip(
                  message: isPlaying
                      ? state.tr(
                          ru: 'Пауза суры',
                          kk: 'Сүрені кідірту',
                          en: 'Pause surah')
                      : state.tr(
                          ru: 'Слушать всю суру',
                          kk: 'Барлық сүрені тыңдау',
                          en: 'Listen to the whole surah'),
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (_) => onPlay(),
                    child: Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.skyLight,
                        shape: BoxShape.circle,
                      ),
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.3),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.navy,
                              size: 30,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr(
                          ru: 'Слушать всю суру',
                          kk: 'Барлық сүрені тыңдау',
                          en: 'Listen to the whole surah'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progress,
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
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onOpenText,
            icon: const Icon(Icons.menu_book_rounded, size: 18),
            label: Text(state.tr(
                ru: 'Открыть полный текст',
                kk: 'Толық мәтінді ашу',
                en: 'Open full text')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FullChapterTextSheet extends StatefulWidget {
  final QuranChapter chapter;

  const _FullChapterTextSheet({required this.chapter});

  @override
  State<_FullChapterTextSheet> createState() => _FullChapterTextSheetState();
}

class _FullChapterTextSheetState extends State<_FullChapterTextSheet> {
  bool _showArabic = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final chapter = widget.chapter;
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${chapter.summary.number}. ${chapter.summary.latinName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: true,
                      icon: const Icon(Icons.language_rounded),
                      label: Text(state.tr(
                          ru: 'Арабский', kk: 'Араб', en: 'Arabic')),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      icon: const Icon(Icons.translate_rounded),
                      label: Text(state.tr(
                          ru: 'Русский', kk: 'Орыс', en: 'Russian')),
                    ),
                  ],
                  selected: {_showArabic},
                  onSelectionChanged: (selection) {
                    setState(() => _showArabic = selection.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    foregroundColor:
                        WidgetStateProperty.all<Color>(AppColors.navy),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    // L18: длинные суры (Аль-Бакара — 286 аятов) раньше
                    // склеивались в один гигантский Text и разом проходили
                    // layout. Ленивый ListView.builder рисует только видимые
                    // аяты. Стиль (Amiri/Nunito) и разделители сохранены.
                    child: ListView.separated(
                      controller: controller,
                      itemCount: chapter.verses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final verse = chapter.verses[index];
                        final content = _showArabic
                            ? '${verse.numberInChapter}. ${verse.arabicText}'
                            : '${verse.numberInChapter}. ${verse.translation}';
                        return SelectableText(
                          content,
                          textDirection: _showArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          textAlign:
                              _showArabic ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            fontFamily: _showArabic ? 'Amiri' : 'Nunito',
                            fontSize: _showArabic ? 25 : 16,
                            height: _showArabic ? 1.9 : 1.55,
                            color: AppColors.textDark,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _VerseCard extends StatelessWidget {
  final QuranVerse verse;
  final bool isLoading;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onHafiz;
  final String? masteryLabel;
  final double? mastery;

  const _VerseCard({
    required this.verse,
    required this.isLoading,
    required this.isActive,
    required this.isPlaying,
    required this.onPlay,
    required this.onHafiz,
    required this.masteryLabel,
    required this.mastery,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive ? AppColors.sky : Colors.transparent,
          width: isActive ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.05),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.skyLight,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${verse.numberInChapter}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                enabled: !isLoading,
                label: isPlaying
                    ? state.tr(ru: 'Пауза', kk: 'Кідірту', en: 'Pause')
                    : state.tr(
                        ru: 'Слушать аят',
                        kk: 'Аятты тыңдау',
                        en: 'Listen to verse'),
                child: Tooltip(
                  message: isPlaying
                      ? state.tr(ru: 'Пауза', kk: 'Кідірту', en: 'Pause')
                      : state.tr(
                          ru: 'Слушать аят',
                          kk: 'Аятты тыңдау',
                          en: 'Listen to verse'),
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: isLoading ? null : (_) => onPlay(),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.sky : AppColors.skyLight,
                        shape: BoxShape.circle,
                      ),
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: isActive ? Colors.white : AppColors.navy,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            verse.arabicText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 27,
              height: 1.9,
              color: AppColors.textDark,
            ),
          ),
          const Divider(height: 26),
          Text(
            verse.transliteration,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            verse.translation,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.tr(
              ru: 'Джуз ${verse.juz} • страница ${verse.page}',
              kk: 'Жүз ${verse.juz} • бет ${verse.page}',
              en: 'Juz ${verse.juz} • page ${verse.page}',
            ),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onHafiz,
            icon: Icon(
              mastery == null
                  ? Icons.psychology_alt_rounded
                  : Icons.replay_rounded,
            ),
            label: Text(
              mastery == null
                  ? state.tr(
                      ru: 'Учить наизусть', kk: 'Жаттау', en: 'Memorize')
                  : '$masteryLabel · ${(mastery! * 100).round()}%',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              side: const BorderSide(color: AppColors.sky),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(color: AppColors.sky),
          const SizedBox(height: 14),
          Text(
            state.tr(
                ru: 'Загружаем проверенный текст…',
                kk: 'Тексерілген мәтін жүктелуде…',
                en: 'Loading verified text…'),
            style: const TextStyle(
                fontFamily: 'Nunito', color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.cloud_off_rounded,
                size: 48, color: AppColors.textLight),
            const SizedBox(height: 14),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: Text(state.tr(
                  ru: 'Повторить', kk: 'Қайталау', en: 'Retry')),
            ),
          ],
        ),
      ),
    );
  }
}

class _AttributionFooter extends StatelessWidget {
  const _AttributionFooter();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.only(top: 18),
      child: Column(
        children: [
          // Заметка-футер по прототипу 1e.
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyDark.withValues(alpha: 0.05),
                  blurRadius: 14,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.16),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.cloud_download_rounded,
                      size: 18, color: AppColors.gold),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    state.tr(
                        ru: '114 сур · аудио офлайн — в Muslingo+',
                        kk: '114 сүре · аудио офлайн — Muslingo+ ішінде',
                        en: '114 surahs · offline audio — in Muslingo+'),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          const Icon(Icons.verified_rounded, color: AppColors.navy, size: 22),
          const SizedBox(height: 6),
          const Text(
            'Арабский текст: Tanzil Project, CC BY 3.0.\n'
            'Перевод смыслов: Эльмир Кулиев. '
            'Аудио: Мишари Рашид Аль-Афаси.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              height: 1.5,
              color: AppColors.textGrey,
            ),
          ),
          TextButton(
            onPressed: () =>
                _openSource('https://tanzil.net/docs/Text_License'),
            child: Text(state.tr(
                ru: 'Лицензия и источник',
                kk: 'Лицензия және дереккөз',
                en: 'License and source')),
          ),
        ],
      ),
    );
  }
}

class _SourceSheet extends StatelessWidget {
  const _SourceSheet();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              state.tr(
                  ru: 'Источники Корана',
                  kk: 'Құран дереккөздері',
                  en: 'Quran sources'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.tr(
                ru: 'Арабский Uthmani-текст встроен в приложение как неизменённая '
                    'копия Tanzil Project. Al Quran Cloud используется для '
                    'метаданных, транслитерации, перевода смыслов и аудио. '
                    'Русский текст — перевод смыслов, а не сам Коран.',
                kk: 'Араб Usmani мәтіні қосымшаға Tanzil Project-тің өзгертілмеген '
                    'көшірмесі ретінде енгізілген. Al Quran Cloud метадеректер, '
                    'транслитерация, мағына аудармасы және аудио үшін қолданылады. '
                    'Орыс мәтіні — мағына аудармасы, Құранның өзі емес.',
                en: 'The Arabic Uthmani text is embedded in the app as an '
                    'unchanged copy of the Tanzil Project. Al Quran Cloud is used '
                    'for metadata, transliteration, meaning translation and audio. '
                    'The Russian text is a translation of meanings, not the Quran itself.',
              ),
              style: const TextStyle(
                fontFamily: 'Nunito',
                height: 1.5,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 12),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading:
                  const Icon(Icons.description_outlined, color: AppColors.navy),
              title: const Text('Tanzil Project'),
              subtitle: Text(state.tr(
                  ru: 'Арабский Uthmani-текст, CC BY 3.0',
                  kk: 'Араб Usmani мәтіні, CC BY 3.0',
                  en: 'Arabic Uthmani text, CC BY 3.0')),
              onTap: () => _openSource('https://tanzil.net/docs/Text_License'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_outlined, color: AppColors.navy),
              title: const Text('Al Quran Cloud'),
              subtitle: Text(state.tr(
                  ru: 'Каталог, перевод, транслитерация и аудио',
                  kk: 'Каталог, аударма, транслитерация және аудио',
                  en: 'Catalog, translation, transliteration and audio')),
              onTap: () => _openSource('https://alquran.cloud/api'),
            ),
          ],
        ),
      ),
    );
  }
}

Future<void> _openSource(String url) async {
  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
}
