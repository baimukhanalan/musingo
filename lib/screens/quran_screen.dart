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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Коран',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 23,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Об источниках',
            onPressed: () => showModalBottomSheet<void>(
              context: context,
              showDragHandle: true,
              builder: (_) => const _SourceSheet(),
            ),
            icon: const Icon(Icons.verified_outlined),
          ),
        ],
      ),
      body: FutureBuilder<List<QuranChapterSummary>>(
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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
              itemCount: filtered.length + 2,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return _QuranHeader(
                    controller: _searchController,
                    onChanged: (value) => setState(() => _query = value),
                  );
                }
                if (index == filtered.length + 1) {
                  return const _AttributionFooter();
                }
                final chapter = filtered[index - 1];
                return _ChapterTile(
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
              },
            ),
          );
        },
      ),
    );
  }
}

class _QuranHeader extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _QuranHeader({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.navy,
            borderRadius: BorderRadius.circular(8),
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: CatCharacter(mood: CatMood.learning, size: 58),
              ),
              SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '114 сур • 6236 аятов',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w900,
                        fontSize: 17,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Арабский текст, перевод смыслов и аудио',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: controller,
          onChanged: onChanged,
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: 'Номер или название суры',
            prefixIcon: const Icon(Icons.search_rounded),
            suffixIcon: controller.text.isEmpty
                ? null
                : IconButton(
                    tooltip: 'Очистить',
                    onPressed: () {
                      controller.clear();
                      onChanged('');
                    },
                    icon: const Icon(Icons.close_rounded),
                  ),
            filled: true,
            fillColor: AppColors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.border),
            ),
          ),
        ),
        const SizedBox(height: 12),
      ],
    );
  }
}

class _ChapterTile extends StatelessWidget {
  final QuranChapterSummary chapter;
  final VoidCallback onTap;

  const _ChapterTile({required this.chapter, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: const BorderSide(color: AppColors.border),
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
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
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        chapter.latinName,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        '${chapter.revelationLabel} • ${chapter.ayahCount} аятов',
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
                Flexible(
                  child: Text(
                    chapter.arabicName,
                    textAlign: TextAlign.right,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 18,
                      color: AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 4),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textLight),
              ],
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
        const SnackBar(
          content: Text('Аудио выключено в настройках.'),
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
        const SnackBar(
          content: Text('Аудио не загрузилось. Проверьте интернет.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _toggleChapterAudio(QuranChapter chapter) async {
    if (!context.read<AppState>().soundEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Аудио выключено в настройках.'),
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
        const SnackBar(
          content: Text('Сура не запустилась. Проверьте интернет.'),
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
        const SnackBar(
          content: Text('Воспроизведение суры остановилось. Повтори позже.'),
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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textDark,
        title: Text(
          '${widget.chapter.number}. ${widget.chapter.latinName}',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: FutureBuilder<QuranChapter>(
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
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
            itemCount: chapter.verses.length + 3,
            separatorBuilder: (_, __) => const SizedBox(height: 10),
            itemBuilder: (context, index) {
              if (index == 0) return _ChapterHeader(chapter: chapter.summary);
              if (index == 1) {
                return _ChapterAudioBar(
                  chapter: chapter,
                  isLoading: _isChapterLoading,
                  isPlaying:
                      _playbackMode == _QuranPlaybackMode.chapter && _isPlaying,
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
              return _VerseCard(
                verse: verse,
                isLoading: _loadingVerse == verse.numberInChapter,
                isActive: _activeVerse == verse.numberInChapter,
                isPlaying: _activeVerse == verse.numberInChapter && _isPlaying,
                onPlay: () => _toggleAudio(verse),
              );
            },
          );
        },
      ),
    );
  }
}

class _ChapterHeader extends StatelessWidget {
  final QuranChapterSummary chapter;

  const _ChapterHeader({required this.chapter});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.navy,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        children: [
          Text(
            chapter.arabicName,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${chapter.revelationLabel} • ${chapter.ayahCount} аятов',
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
    final progress = isLoading
        ? 'Загрузка цельной суры'
        : activeVerse == null
            ? (isPlaying
                ? 'Цельное аудио без пауз'
                : 'Слушать с начала')
            : 'Аят $activeVerse из ${chapter.summary.ayahCount}';
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: isPlaying ? 'Пауза суры' : 'Слушать всю суру',
                child: Tooltip(
                  message: isPlaying ? 'Пауза суры' : 'Слушать всю суру',
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
                    const Text(
                      'Слушать всю суру',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
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
            label: const Text('Открыть полный текст'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              side: const BorderSide(color: AppColors.border),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
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
    final chapter = widget.chapter;
    final text = _showArabic
        ? chapter.verses
            .map((verse) => '${verse.numberInChapter}. ${verse.arabicText}')
            .join('\n\n')
        : chapter.verses
            .map((verse) => '${verse.numberInChapter}. ${verse.translation}')
            .join('\n\n');
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
                  segments: const [
                    ButtonSegment<bool>(
                      value: true,
                      icon: Icon(Icons.language_rounded),
                      label: Text('Арабский'),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      icon: Icon(Icons.translate_rounded),
                      label: Text('Русский'),
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
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.border),
                    ),
                    child: SingleChildScrollView(
                      controller: controller,
                      child: SelectableText(
                        text,
                        textDirection:
                            _showArabic ? TextDirection.rtl : TextDirection.ltr,
                        textAlign:
                            _showArabic ? TextAlign.right : TextAlign.left,
                        style: TextStyle(
                          fontFamily: _showArabic ? 'Amiri' : 'Nunito',
                          fontSize: _showArabic ? 25 : 16,
                          height: _showArabic ? 1.9 : 1.55,
                          color: AppColors.textDark,
                        ),
                      ),
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

  const _VerseCard({
    required this.verse,
    required this.isLoading,
    required this.isActive,
    required this.isPlaying,
    required this.onPlay,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? AppColors.sky : AppColors.border,
          width: isActive ? 2 : 1,
        ),
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
                label: isPlaying ? 'Пауза' : 'Слушать аят',
                child: Tooltip(
                  message: isPlaying ? 'Пауза' : 'Слушать аят',
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
            'Джуз ${verse.juz} • страница ${verse.page}',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: AppColors.textLight,
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
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(color: AppColors.sky),
          SizedBox(height: 14),
          Text(
            'Загружаем проверенный текст…',
            style: TextStyle(fontFamily: 'Nunito', color: AppColors.textGrey),
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
              label: const Text('Повторить'),
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
    return Padding(
      padding: const EdgeInsets.only(top: 16),
      child: Column(
        children: [
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
            child: const Text('Лицензия и источник'),
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
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(24, 4, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Источники Корана',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Арабский Uthmani-текст встроен в приложение как неизменённая '
              'копия Tanzil Project. Al Quran Cloud используется для '
              'метаданных, транслитерации, перевода смыслов и аудио. '
              'Русский текст — перевод смыслов, а не сам Коран.',
              style: TextStyle(
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
              subtitle: const Text('Арабский Uthmani-текст, CC BY 3.0'),
              onTap: () => _openSource('https://tanzil.net/docs/Text_License'),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.cloud_outlined, color: AppColors.navy),
              title: const Text('Al Quran Cloud'),
              subtitle: const Text('Каталог, перевод, транслитерация и аудио'),
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
