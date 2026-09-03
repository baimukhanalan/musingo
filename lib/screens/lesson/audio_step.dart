part of '../lesson_screen.dart';

class _AudioStep extends StatefulWidget {
  final LessonStep step;
  final bool simulatePlayback;
  final VoidCallback onListened;

  const _AudioStep({
    required this.step,
    required this.simulatePlayback,
    required this.onListened,
  });

  @override
  State<_AudioStep> createState() => _AudioStepState();
}

class _AudioStepState extends State<_AudioStep> {
  late final FlutterTts _tts;
  late final QuranAudioPlayer _audioPlayer;
  bool _played = false;
  bool _speaking = false;

  @override
  void initState() {
    super.initState();
    _audioPlayer = QuranAudioPlayer();
    _tts = FlutterTts();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _speaking = false);
    });
    _tts.setErrorHandler((_) {
      if (mounted) setState(() => _speaking = false);
    });
  }

  Future<void> _toggleSpeech() async {
    HapticsService.tap();
    if (widget.simulatePlayback) {
      widget.onListened();
      setState(() {
        _played = true;
        _speaking = false;
      });
      return;
    }
    if (_speaking) {
      await _tts.stop();
      await _audioPlayer.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }

    final ayahNumber = widget.step.quranGlobalAyahNumber;
    if (ayahNumber != null) {
      widget.onListened();
      await _playQuranAyah(ayahNumber);
      return;
    }

    final text = widget.step.arabicText;
    if (text == null || text.isEmpty) return;
    widget.onListened();
    try {
      await _tts.setLanguage('ar-SA');
      await _tts.setSpeechRate(0.38);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      if (mounted) {
        setState(() {
          _played = true;
          _speaking = true;
        });
      }
      await _tts.speak(text);
    } catch (_) {
      if (!mounted) return;
      setState(() => _speaking = false);
      final state = context.read<AppState>();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr(
            ru: 'Озвучивание недоступно на этом устройстве.',
            kk: 'Бұл құрылғыда дыбыстау қолжетімсіз.',
            en: 'Audio playback is unavailable on this device.',
          )),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _playQuranAyah(int ayahNumber) async {
    final sources = quranAudioSources(ayahNumber);

    if (mounted) {
      setState(() {
        _played = true;
        _speaking = true;
      });
    }

    Object? lastError;
    for (final source in sources) {
      try {
        await _audioPlayer.playUrl(source);
        if (mounted) setState(() => _speaking = false);
        return;
      } catch (error) {
        lastError = error;
        await _audioPlayer.stop();
      }
    }

    if (!mounted) return;
    setState(() => _speaking = false);
    final state = context.read<AppState>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.tr(
            ru: 'Не удалось загрузить аудио аята $ayahNumber. $lastError',
            kk: '$ayahNumber-аяттың аудиосын жүктеу мүмкін болмады. $lastError',
            en: 'Could not load audio for ayah $ayahNumber. $lastError',
          ),
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  void dispose() {
    if (!widget.simulatePlayback) _tts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        SectionLabel(
            text: state.tr(
          ru: '${_stepTypeLabel(widget.step, state)} · Слушай',
          kk: '${_stepTypeLabel(widget.step, state)} · Тыңда',
          en: '${_stepTypeLabel(widget.step, state)} · Listen',
        )),
        const SizedBox(height: 6),
        Text(
            state.tr(
                ru: 'Прослушай и следи за словами',
                kk: 'Тыңдап, сөздерді қадағала',
                en: 'Listen and follow the words'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey)),
        const SizedBox(height: 16),
        // Аят словами-чипами в премиум-карточке.
        PremiumCard(
          child: Column(
            children: [
              if (widget.step.arabicText != null)
                _AlignedArabicHint(
                  arabicText: widget.step.arabicText!,
                  transliteration: widget.step.transliteration,
                  fallback: Text(
                    widget.step.arabicText!,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 30,
                        height: 1.7,
                        color: AppColors.textDark),
                  ),
                ),
              if (widget.step.transliteration != null &&
                  !_AlignedArabicHint.canAlign(
                    widget.step.arabicText,
                    widget.step.transliteration,
                  )) ...[
                const SizedBox(height: 10),
                Text(widget.step.transliteration!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        color: AppColors.textGrey,
                        fontStyle: FontStyle.italic)),
              ],
              if (widget.step.russianText != null) ...[
                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 14),
                Text(widget.step.russianText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w700)),
              ],
            ],
          ),
        ),
        const SizedBox(height: 18),
        // Аудио-кнопка «Нажми и слушай» (пилюля).
        Semantics(
          button: true,
          label: _speaking
              ? state.tr(
                  ru: 'Остановить озвучивание',
                  kk: 'Дыбыстауды тоқтату',
                  en: 'Stop playback')
              : state.tr(
                  ru: 'Прослушать фразу',
                  kk: 'Тіркесті тыңдау',
                  en: 'Listen to the phrase'),
          child: Listener(
            key: const ValueKey('lesson_audio_play'),
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => _toggleSpeech(),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 15),
              decoration: BoxDecoration(
                color: _played
                    ? AppColors.pistachioLight.withValues(alpha: 0.8)
                    : AppColors.skyLight.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(99),
                border: Border.all(
                    color: _played ? AppColors.pistachio : AppColors.sky,
                    width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sky.withValues(alpha: 0.25),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _played
                        ? (_speaking
                            ? Icons.stop_rounded
                            : Icons.replay_rounded)
                        : Icons.volume_up_rounded,
                    color: AppColors.navy,
                    size: 24,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    _speaking
                        ? state.tr(
                            ru: 'Слушаю...',
                            kk: 'Тыңдап тұрмын...',
                            en: 'Playing...')
                        : (_played
                            ? state.tr(
                                ru: 'Слушать ещё раз',
                                kk: 'Қайта тыңдау',
                                en: 'Listen again')
                            : state.tr(
                                ru: 'Нажми и слушай',
                                kk: 'Басып тыңда',
                                en: 'Tap to listen')),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TextStep extends StatelessWidget {
  final LessonStep step;
  const _TextStep({required this.step});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        SectionLabel(text: _stepTypeLabel(step, state)),
        const SizedBox(height: 6),
        Text(
            state.tr(
                ru: step.arabicText == null
                    ? 'Прочитай объяснение и выдели главное'
                    : 'Сравни написание, звучание и смысл',
                kk: step.arabicText == null
                    ? 'Түсіндірмені оқып, негізгісін белгіле'
                    : 'Жазылуын, дыбысталуын және мағынасын салыстыр',
                en: step.arabicText == null
                    ? 'Read the explanation and identify the key idea'
                    : 'Compare the writing, sound, and meaning'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey)),
        const SizedBox(height: 16),
        PremiumCard(
          child: Column(
            children: [
              if (step.arabicText != null)
                _AlignedArabicHint(
                  arabicText: step.arabicText!,
                  transliteration: step.transliteration,
                  fallback: Text(
                    step.arabicText!,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 28,
                      height: 1.8,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
              if (step.transliteration != null &&
                  !_AlignedArabicHint.canAlign(
                    step.arabicText,
                    step.transliteration,
                  )) ...[
                const SizedBox(height: 10),
                Text(step.transliteration!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textGrey,
                        fontStyle: FontStyle.italic)),
              ],
              if (step.russianText != null) ...[
                const SizedBox(height: 14),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 14),
                Text(step.russianText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        color: AppColors.textDark,
                        height: 1.5)),
              ] else if (step.explanation != null) ...[
                const SizedBox(height: 14),
                Text(
                  step.explanation!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    color: AppColors.textDark,
                    height: 1.5,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AlignedArabicHint extends StatelessWidget {
  final String arabicText;
  final String? transliteration;
  final Widget fallback;

  const _AlignedArabicHint({
    required this.arabicText,
    required this.transliteration,
    required this.fallback,
  });

  static bool canAlign(String? arabicText, String? transliteration) {
    if (arabicText == null || transliteration == null) return false;
    return _tokens(arabicText).length == _tokens(transliteration).length &&
        _tokens(arabicText).length > 1;
  }

  static List<String> _tokens(String value) => value
      .replaceAll(',', ' ')
      .replaceAll('،', ' ')
      .trim()
      .split(RegExp(r'\s+'))
      .where((token) => token.isNotEmpty)
      .toList(growable: false);

  @override
  Widget build(BuildContext context) {
    if (!canAlign(arabicText, transliteration)) return fallback;
    final arabicTokens = _tokens(arabicText);
    final phoneticTokens = _tokens(transliteration!);
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 10,
      runSpacing: 10,
      textDirection: TextDirection.rtl,
      children: List.generate(arabicTokens.length, (index) {
        // Крупные арабские word-chips — скруглённые «таблетки» (экран 1c).
        return Container(
          constraints: const BoxConstraints(minWidth: 66),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.sky.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: AppColors.navyDark.withValues(alpha: 0.06),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                arabicTokens[index],
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                style: const TextStyle(
                  fontFamily: 'Amiri',
                  fontSize: 32,
                  height: 1.1,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                phoneticTokens[index],
                textAlign: TextAlign.center,
                textDirection: TextDirection.ltr,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
