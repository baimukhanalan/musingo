part of '../quran_screen.dart';

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
                    isPlaying: _playbackMode == _QuranPlaybackMode.chapter &&
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
                  isPlaying:
                      _activeVerse == verse.numberInChapter && _isPlaying,
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
