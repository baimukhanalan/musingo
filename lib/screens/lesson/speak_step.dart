part of '../lesson_screen.dart';

class _SpeakStep extends StatefulWidget {
  final LessonStep step;
  final ValueChanged<bool> onVerified;

  /// Распознавание речи недоступно на устройстве (и нет удалённой проверки):
  /// мягкий проход без ошибки — среда виновата, не пользователь.
  final VoidCallback onUnavailable;

  /// Пользователь жмёт «Пропустить» после нескольких неудачных попыток:
  /// проход засчитывается, но с ошибкой в разбор.
  final VoidCallback onSkip;

  const _SpeakStep({
    super.key,
    required this.step,
    required this.onVerified,
    required this.onUnavailable,
    required this.onSkip,
  });

  @override
  State<_SpeakStep> createState() => _SpeakStepState();
}

class _SpeakStepState extends State<_SpeakStep> {
  final SpeechToText _speech = SpeechToText();
  late final SpeechEvaluationService _speechEvaluation;
  late final FlutterTts _tts;
  late final QuranAudioPlayer _audioPlayer;
  bool _recording = false;
  bool _done = false;
  bool _passed = false;
  bool _initializing = false;
  bool _evaluating = false;
  bool _gradingRequested = false;
  bool _speechAvailable = false;
  bool _samplePlayed = false;
  bool _samplePlaying = false;
  String _recognizedWords = '';
  String? _speechError;
  double _score = 0;
  bool _fallbackUsed = false;
  Uint8List? _recordedAudio;
  // Счётчик неудачных попыток произношения. После 2 неудач показываем кнопку
  // «Пропустить» (H1-б), чтобы непроходимое произношение не блокировало урок.
  int _failedAttempts = 0;
  // Распознавание недоступно на устройстве (H1-а): пользователь уже получил
  // мягкий проход, кнопка «Пропустить» тут не нужна.
  bool _speechUnavailable = false;
  // Пользователь воспользовался «Пропустить» — шаг уже открыт для прохода.
  bool _skipped = false;

  @override
  void initState() {
    super.initState();
    _speechEvaluation = SpeechEvaluationService();
    _audioPlayer = QuranAudioPlayer();
    _tts = FlutterTts();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _samplePlaying = false);
    });
    _tts.setErrorHandler((_) {
      if (mounted) setState(() => _samplePlaying = false);
    });
  }

  Future<void> _toggleListening() async {
    final state = context.read<AppState>();
    if (_recording) {
      try {
        await _speech.stop();
      } catch (_) {}
      _recordedAudio = await _speechEvaluation.stop();
      if (mounted) setState(() => _recording = false);
      await _gradeSpeech();
      return;
    }

    if (!_samplePlayed) {
      HapticsService.wrong();
      setState(() {
        _speechError = state.tr(
          ru: 'Сначала прослушай образец, затем запиши свой голос.',
          kk: 'Алдымен үлгіні тыңда, содан кейін дауысыңды жаз.',
          en: 'First listen to the sample, then record your voice.',
        );
      });
      return;
    }

    setState(() {
      _initializing = true;
      _evaluating = false;
      _speechError = null;
      _recognizedWords = '';
      _done = false;
      _passed = false;
      _score = 0;
      _fallbackUsed = false;
      _gradingRequested = false;
      _recordedAudio = null;
    });
    late final bool available;
    try {
      await _speechEvaluation.record();
      available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if (status == 'done' || status == 'notListening') {
            _gradeSpeech();
          }
        },
        onError: (error) {
          if (!mounted) return;
          if (_speechEvaluation.hasRemoteEvaluator && _recording) {
            setState(() {
              _speechAvailable = false;
              _speechError = state.tr(
                ru: 'Распознавание на устройстве не сработало. Запиши голос, я отправлю аудио на проверку.',
                kk: 'Құрылғыдағы тану жұмыс істемеді. Дауысыңды жаз, аудионы тексеруге жіберемін.',
                en: 'On-device recognition failed. Record your voice and I will send the audio for review.',
              );
            });
            return;
          }
          setState(() {
            _recording = false;
            _speechError = state.tr(
              ru: 'Не удалось распознать речь. Попробуй ещё раз.',
              kk: 'Сөзді тану мүмкін болмады. Қайта көр.',
              en: 'Could not recognize speech. Please try again.',
            );
          });
          unawaited(_speechEvaluation.cancel());
        },
      );
    } catch (_) {
      await _speechEvaluation.cancel();
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _recording = false;
        _speechError = state.tr(
          ru: 'Микрофон недоступен. Разреши доступ и попробуй ещё раз.',
          kk: 'Микрофон қолжетімсіз. Рұқсат беріп, қайта көр.',
          en: 'Microphone is unavailable. Grant access and try again.',
        );
      });
      return;
    }
    if (!mounted) return;
    if (!available) {
      if (!_speechEvaluation.hasRemoteEvaluator) {
        await _speechEvaluation.cancel();
        setState(() {
          _initializing = false;
          _speechUnavailable = true;
          _speechError = state.tr(
            ru: 'Распознавание речи недоступно на этом устройстве. Можешь продолжить.',
            kk: 'Бұл құрылғыда сөзді тану қолжетімсіз. Жалғастыра бересің.',
            en: 'Speech recognition is unavailable on this device. You can continue.',
          );
        });
        // Мягкий проход: гейт открывается, ошибка не засчитывается (H1-а).
        widget.onUnavailable();
        return;
      }
      setState(() {
        _initializing = false;
        _recording = true;
        _speechAvailable = false;
        _speechError = state.tr(
          ru: 'Распознавание на устройстве недоступно. Говори, аудио уйдет на проверку.',
          kk: 'Құрылғыдағы тану қолжетімсіз. Сөйле, аудио тексеруге кетеді.',
          en: 'On-device recognition is unavailable. Speak, and the audio will be sent for review.',
        );
      });
      return;
    }

    final locales = await _speech.locales();
    final arabicLocales = locales.where(
      (locale) => locale.localeId.toLowerCase().startsWith('ar'),
    );
    final localeId =
        arabicLocales.isEmpty ? null : arabicLocales.first.localeId;
    setState(() {
      _initializing = false;
      _recording = true;
      _speechAvailable = true;
    });
    await _speech.listen(
      onResult: _onSpeechResult,
      listenOptions: SpeechListenOptions(
        localeId: localeId,
        listenFor: const Duration(seconds: 12),
        pauseFor: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _toggleSample() async {
    HapticsService.tap();
    if (_recording || _evaluating || _initializing) return;
    final state = context.read<AppState>();

    if (_samplePlaying) {
      await _tts.stop();
      await _audioPlayer.stop();
      if (mounted) setState(() => _samplePlaying = false);
      return;
    }

    final ayahNumber = widget.step.quranGlobalAyahNumber;
    if (ayahNumber != null) {
      await _playQuranSample(ayahNumber);
      return;
    }

    final text = widget.step.arabicText ?? widget.step.transliteration;
    if (text == null || text.trim().isEmpty) return;

    try {
      await _tts.setLanguage('ar-SA');
      await _tts.setSpeechRate(0.36);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      if (mounted) {
        setState(() {
          _samplePlayed = true;
          _samplePlaying = true;
          _speechError = null;
        });
      }
      await _tts.speak(text);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _samplePlaying = false;
        _speechError = state.tr(
          ru: 'Не удалось включить образец. Попробуй ещё раз.',
          kk: 'Үлгіні қосу мүмкін болмады. Қайта көр.',
          en: 'Could not play the sample. Please try again.',
        );
      });
    }
  }

  Future<void> _playQuranSample(int ayahNumber) async {
    final state = context.read<AppState>();
    final sources = <String>[
      if (BackendService.hasConfiguredApiUrl)
        '${BackendService.apiBaseUrl}/api/muslingo/quran/audio/$ayahNumber',
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$ayahNumber.mp3',
    ];

    if (mounted) {
      setState(() {
        _samplePlayed = true;
        _samplePlaying = true;
        _speechError = null;
      });
    }

    Object? lastError;
    for (final source in sources) {
      try {
        await _audioPlayer.playUrl(source);
        if (mounted) setState(() => _samplePlaying = false);
        return;
      } catch (error) {
        lastError = error;
        await _audioPlayer.stop();
      }
    }

    if (!mounted) return;
    setState(() {
      _samplePlaying = false;
      _samplePlayed = false;
      _speechError = state.tr(
        ru: 'Не удалось загрузить образец. $lastError',
        kk: 'Үлгіні жүктеу мүмкін болмады. $lastError',
        en: 'Could not load the sample. $lastError',
      );
    });
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() => _recognizedWords = result.recognizedWords);
    if (result.finalResult) _gradeSpeech();
  }

  Future<void> _gradeSpeech() async {
    if (!mounted) return;
    if (_evaluating || _gradingRequested) return;
    final state = context.read<AppState>();
    _gradingRequested = true;
    setState(() => _evaluating = true);
    try {
      _recordedAudio ??= await _speechEvaluation.stop();
      final result = await _speechEvaluation.evaluate(
        step: widget.step,
        transcript: _recognizedWords,
        audioBytes: _recordedAudio,
      );
      if (!mounted) return;
      setState(() {
        if (result.transcript.trim().isNotEmpty) {
          _recognizedWords = result.transcript;
        }
        _recording = false;
        _done = _recognizedWords.trim().isNotEmpty ||
            (_recordedAudio?.isNotEmpty ?? false);
        _evaluating = false;
        _gradingRequested = false;
        _score = result.score / 100;
        _passed = result.passed;
        if (!result.passed) _failedAttempts++;
        _fallbackUsed = result.engine == SpeechEvaluationEngine.localFallback ||
            result.fallbackUsed;
        _speechError = result.passed ? null : result.feedbackText;
      });
      widget.onVerified(result.passed);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _recording = false;
        _evaluating = false;
        _gradingRequested = false;
        _failedAttempts++;
        _speechError = state.tr(
          ru: 'Не удалось проверить произношение. Попробуй ещё раз.',
          kk: 'Айтылымды тексеру мүмкін болмады. Қайта көр.',
          en: 'Could not check pronunciation. Please try again.',
        );
      });
      widget.onVerified(false);
    }
  }

  @override
  void dispose() {
    _speech.cancel();
    _tts.stop();
    _audioPlayer.dispose();
    _speechEvaluation.cancel();
    _speechEvaluation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        SectionLabel(text: _stepTypeLabel(widget.step, state)),
        const SizedBox(height: 6),
        Text(
            state.tr(
                ru: 'Повтори вслух за образцом',
                kk: 'Үлгіден кейін дауыстап қайтала',
                en: 'Repeat aloud after the sample'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey)),
        const SizedBox(height: 14),
        PremiumCard(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              if (widget.step.arabicText != null)
                Text(widget.step.arabicText!,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 28,
                        height: 1.8,
                        color: AppColors.textDark)),
              if (widget.step.transliteration != null) ...[
                const SizedBox(height: 6),
                Text(widget.step.transliteration!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textGrey,
                        fontStyle: FontStyle.italic)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        Semantics(
          button: true,
          label: _samplePlaying
              ? state.tr(
                  ru: 'Остановить образец произношения',
                  kk: 'Айтылым үлгісін тоқтату',
                  en: 'Stop the pronunciation sample')
              : state.tr(
                  ru: 'Прослушать образец произношения',
                  kk: 'Айтылым үлгісін тыңдау',
                  en: 'Listen to the pronunciation sample'),
          child: GestureDetector(
            onTap: _recording || _evaluating || _initializing
                ? null
                : _toggleSample,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: _samplePlayed
                    ? AppColors.pistachioLight.withValues(alpha: 0.7)
                    : AppColors.skyLight.withValues(alpha: 0.8),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: _samplePlayed ? AppColors.pistachio : AppColors.sky,
                  width: 1.5,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _samplePlaying
                        ? Icons.stop_circle_rounded
                        : (_samplePlayed
                            ? Icons.check_circle_rounded
                            : Icons.volume_up_rounded),
                    color: _samplePlayed
                        ? AppColors.pistachioDark
                        : AppColors.navy,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      _samplePlaying
                          ? state.tr(
                              ru: 'Слушай правильное произношение',
                              kk: 'Дұрыс айтылымды тыңда',
                              en: 'Listen to the correct pronunciation')
                          : (_samplePlayed
                              ? state.tr(
                                  ru: 'Образец прослушан. Можно записывать.',
                                  kk: 'Үлгі тыңдалды. Жазуға болады.',
                                  en: 'Sample played. You can record now.')
                              : state.tr(
                                  ru: 'Сначала прослушай образец',
                                  kk: 'Алдымен үлгіні тыңда',
                                  en: 'First listen to the sample')),
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: _samplePlayed
                            ? AppColors.pistachioDark
                            : AppColors.navy,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 18),
        Semantics(
          button: true,
          label: _recording
              ? state.tr(
                  ru: 'Остановить запись',
                  kk: 'Жазуды тоқтату',
                  en: 'Stop recording')
              : state.tr(
                  ru: 'Начать распознавание речи',
                  kk: 'Сөзді тануды бастау',
                  en: 'Start speech recognition'),
          child: GestureDetector(
            onTap: _initializing || _evaluating ? null : _toggleListening,
            child: Container(
              width: 84,
              height: 84,
              decoration: BoxDecoration(
                color: _recording
                    ? AppColors.error
                    : (_passed
                        ? AppColors.pistachio
                        : (_samplePlayed
                            ? AppColors.pistachioLight
                            : AppColors.border)),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color:
                          (_recording ? AppColors.error : AppColors.pistachio)
                              .withValues(alpha: 0.32),
                      blurRadius: 20,
                      offset: const Offset(0, 8))
                ],
              ),
              child: Icon(
                _initializing
                    ? Icons.hourglass_top_rounded
                    : _evaluating
                        ? Icons.hourglass_bottom_rounded
                        : _recording
                            ? Icons.stop_rounded
                            : (_passed
                                ? Icons.check_rounded
                                : Icons.mic_rounded),
                color: _recording || _passed
                    ? Colors.white
                    : (_samplePlayed
                        ? AppColors.pistachio
                        : AppColors.textGrey),
                size: 42,
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          _initializing
              ? state.tr(
                  ru: 'Подключаю микрофон...',
                  kk: 'Микрофонды қосудамын...',
                  en: 'Connecting the microphone...')
              : _evaluating
                  ? state.tr(
                      ru: 'Проверяю произношение...',
                      kk: 'Айтылымды тексерудемін...',
                      en: 'Checking pronunciation...')
                  : _recording
                      ? (_speechAvailable
                          ? state.tr(
                              ru: 'Говори...', kk: 'Сөйле...', en: 'Speak...')
                          : state.tr(
                              ru: 'Записываю голос...',
                              kk: 'Дауысты жазудамын...',
                              en: 'Recording your voice...'))
                      : (_passed
                          ? state.tr(
                              ru: 'Произношение принято',
                              kk: 'Айтылым қабылданды',
                              en: 'Pronunciation accepted')
                          : (_done
                              ? state.tr(
                                  ru: 'Нужно повторить',
                                  kk: 'Қайталау керек',
                                  en: 'Needs another try')
                              : (_samplePlayed
                                  ? state.tr(
                                      ru: 'Нажми и говори',
                                      kk: 'Басып сөйле',
                                      en: 'Tap and speak')
                                  : state.tr(
                                      ru: 'Прослушай образец перед записью',
                                      kk: 'Жазудан бұрын үлгіні тыңда',
                                      en: 'Listen to the sample before recording')))),
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _recording
                ? AppColors.error
                : (_passed ? AppColors.pistachio : AppColors.textGrey),
          ),
        ),
        if (_recognizedWords.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            state.tr(
              ru: 'Распознано: $_recognizedWords',
              kk: 'Танылды: $_recognizedWords',
              en: 'Recognized: $_recognizedWords',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 8),
          // Крупный %-бейдж совпадения произношения.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: (_passed ? AppColors.pistachio : AppColors.error)
                  .withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Text(
              state.tr(
                ru: 'Совпадение: ${(_score * 100).round()}%',
                kk: 'Сәйкестік: ${(_score * 100).round()}%',
                en: 'Match: ${(_score * 100).round()}%',
              ),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: _passed ? AppColors.pistachioDark : AppColors.error,
              ),
            ),
          ),
        ],
        if (_fallbackUsed) ...[
          const SizedBox(height: 8),
          Text(
            state.tr(
              ru: 'Упрощенная проверка на устройстве',
              kk: 'Құрылғыдағы жеңілдетілген тексеру',
              en: 'Simplified on-device check',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              color: AppColors.textGrey,
            ),
          ),
        ],
        if (_speechError != null) ...[
          const SizedBox(height: 8),
          Text(
            _speechError!,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              color: AppColors.error,
            ),
          ),
        ],
        // (H1-б) После 2 неудачных попыток даём «Пропустить»: произношение может
        // не проходить (акцент/микрофон), но урок не должен упираться в это.
        // Проход засчитывается ошибкой в разбор (см. onSkip у родителя).
        if (_failedAttempts >= 2 &&
            !_passed &&
            !_skipped &&
            !_speechUnavailable) ...[
          const SizedBox(height: 16),
          Semantics(
            button: true,
            label: state.tr(
                ru: 'Пропустить шаг произношения',
                kk: 'Айтылым қадамын өткізіп жіберу',
                en: 'Skip the pronunciation step'),
            child: GestureDetector(
              onTap: () {
                HapticsService.tap();
                setState(() {
                  _skipped = true;
                  _speechError = null;
                });
                widget.onSkip();
              },
              child: Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.goldLight,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: AppColors.gold.withValues(alpha: 0.5), width: 1.5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.skip_next_rounded,
                        color: AppColors.gold, size: 22),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text(
                        state.tr(
                          ru: 'Пропустить (засчитается ошибкой)',
                          kk: 'Өткізіп жіберу (қате болып саналады)',
                          en: 'Skip (counts as a mistake)',
                        ),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
        if (_skipped) ...[
          const SizedBox(height: 10),
          Text(
            state.tr(
              ru: 'Шаг пропущен. Нажми «Продолжить».',
              kk: 'Қадам өткізілді. «Жалғастыру» түймесін бас.',
              en: 'Step skipped. Tap "Continue".',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ],
    );
  }
}
