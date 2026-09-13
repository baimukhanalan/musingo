part of '../quran_screen.dart';

class QuranChapterScreen extends StatefulWidget {
  final QuranChapterSummary chapter;
  final QuranRepository repository;
  final int? initialAyahNumber;
  final String localeCode;

  const QuranChapterScreen({
    super.key,
    required this.chapter,
    required this.repository,
    this.initialAyahNumber,
    this.localeCode = 'ru',
  });

  @override
  State<QuranChapterScreen> createState() => _QuranChapterScreenState();
}

class _QuranChapterScreenState extends State<QuranChapterScreen> {
  final GlobalKey _initialAyahSliverKey = GlobalKey();
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
  QuranVerse? _activeVerseData;
  bool _usingVerseFallback = false;
  bool _recoveringLateAudioError = false;

  @override
  void initState() {
    super.initState();
    _chapterFuture = widget.repository.fetchChapter(
      widget.chapter,
      localeCode: widget.localeCode,
    );
    _audioPlayer = QuranAudioPlayer();
    _stateSubscription = _audioPlayer.playbackStateStream.listen((state) {
      if (!mounted) return;
      if (state.error != null) {
        unawaited(_recoverFromLateAudioError(state.error!));
        return;
      }
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
        _chapterQueue = chapter.verses;
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
    for (var index = 0; index < sources.length; index++) {
      final source = sources[index];
      try {
        await _audioPlayer.playUrl(source);
        lastError = null;
        if (mounted) {
          setState(() {
            _activeVerse = verse.numberInChapter;
            _activeVerseData = verse;
            _usingVerseFallback = index > 0;
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
      _activeVerseData = null;
      _usingVerseFallback = false;
      _loadingVerse = null;
      _isChapterLoading = false;
      _chapterUsesVerseQueue = false;
    });
  }

  void _clearAudioState() {
    if (!mounted) return;
    setState(() {
      _activeVerse = null;
      _activeVerseData = null;
      _usingVerseFallback = false;
      _loadingVerse = null;
      _isPlaying = false;
      _isChapterLoading = false;
      _playbackMode = null;
      _chapterQueue = const [];
      _chapterQueueIndex = 0;
      _chapterUsesVerseQueue = false;
    });
  }

  Future<void> _recoverFromLateAudioError(Object error) async {
    if (_recoveringLateAudioError || !mounted || _playbackMode == null) return;
    _recoveringLateAudioError = true;
    try {
      await _audioPlayer.stop();
      if (!mounted) return;

      if (_playbackMode == _QuranPlaybackMode.chapter &&
          !_chapterUsesVerseQueue &&
          _chapterQueue.isNotEmpty) {
        final firstVerse = _chapterQueue.first;
        setState(() {
          _chapterUsesVerseQueue = true;
          _chapterQueueIndex = 0;
          _isChapterLoading = true;
          _loadingVerse = firstVerse.numberInChapter;
        });
        await _playVerse(firstVerse);
        return;
      }

      final verse = _activeVerseData;
      final fallback = verse?.audioFallbackUrl;
      if (verse != null &&
          !_usingVerseFallback &&
          fallback != null &&
          fallback.trim().isNotEmpty) {
        setState(() {
          _isChapterLoading = _playbackMode == _QuranPlaybackMode.chapter;
          _loadingVerse = verse.numberInChapter;
          _usingVerseFallback = true;
        });
        await _audioPlayer.playUrl(fallback);
        if (!mounted) return;
        setState(() {
          _activeVerse = verse.numberInChapter;
          _loadingVerse = null;
          _isChapterLoading = false;
        });
        return;
      }
      throw error;
    } catch (recoveryError) {
      debugPrint('Quran late audio recovery failed: $recoveryError');
      if (!mounted) return;
      _clearAudioState();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(context.read<AppState>().tr(
                ru: 'Воспроизведение остановилось. Проверь интернет и повтори.',
                kk: 'Ойнату тоқтады. Интернетті тексеріп, қайталап көріңіз.',
                en: 'Playback stopped. Check your connection and try again.',
              )),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      _recoveringLateAudioError = false;
    }
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

  Widget _chapterItem(
    AppState appState,
    QuranChapter chapter,
    int index,
  ) {
    if (index == 0) return _ChapterHeader(chapter: chapter.summary);
    if (index == 1) {
      return _ChapterAudioBar(
        chapter: chapter,
        isLoading: _isChapterLoading,
        isPlaying: _playbackMode == _QuranPlaybackMode.chapter && _isPlaying,
        activeVerse:
            _playbackMode == _QuranPlaybackMode.chapter ? _activeVerse : null,
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
        if (!mounted) return;
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
  }

  Widget _chapterSliver(
    AppState appState,
    QuranChapter chapter,
    int start,
    int end, {
    Key? key,
  }) {
    return SliverPadding(
      key: key,
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, localIndex) {
            final index = start + localIndex;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _chapterItem(appState, chapter, index),
            );
          },
          childCount: end - start,
        ),
      ),
    );
  }

  Widget _chapterList(AppState appState, QuranChapter chapter) {
    final itemCount = chapter.verses.length + 3;
    final initialVerseIndex = widget.initialAyahNumber == null
        ? -1
        : chapter.verses.indexWhere(
            (verse) => verse.numberInChapter == widget.initialAyahNumber,
          );

    if (initialVerseIndex < 0) {
      return CustomScrollView(
        slivers: [_chapterSliver(appState, chapter, 0, itemCount)],
      );
    }

    // A centered pair of slivers starts at the requested ayah without relying
    // on guessed pixel heights. Earlier ayahs and the chapter header remain
    // available by scrolling upward.
    final initialItemIndex = initialVerseIndex + 2;
    return CustomScrollView(
      center: _initialAyahSliverKey,
      slivers: [
        _chapterSliver(appState, chapter, 0, initialItemIndex),
        _chapterSliver(
          appState,
          chapter,
          initialItemIndex,
          itemCount,
          key: _initialAyahSliverKey,
        ),
      ],
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
          '${widget.chapter.number}. ${quranDisplayName(widget.chapter, appState.locale.code)}',
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
                  () => _chapterFuture = widget.repository.fetchChapter(
                    widget.chapter,
                    localeCode: widget.localeCode,
                  ),
                ),
              );
            }
            final chapter = snapshot.data!;
            return _chapterList(appState, chapter);
          },
        ),
      ),
    );
  }
}
