part of '../lesson_screen.dart';

class _ListenChoiceStep extends StatefulWidget {
  final LessonStep step;
  final int? selectedAnswer;
  final bool answered;
  final void Function(int)? onSelect;

  const _ListenChoiceStep({
    super.key,
    required this.step,
    required this.selectedAnswer,
    required this.answered,
    this.onSelect,
  });

  @override
  State<_ListenChoiceStep> createState() => _ListenChoiceStepState();
}

class _ListenChoiceStepState extends State<_ListenChoiceStep> {
  late final FlutterTts _tts;
  late final QuranAudioPlayer _audioPlayer;
  bool _playing = false;
  int _plays = 0;

  @override
  void initState() {
    super.initState();
    _audioPlayer = QuranAudioPlayer();
    _tts = FlutterTts();
    _tts.setCompletionHandler(() {
      if (mounted) setState(() => _playing = false);
    });
    _tts.setErrorHandler((_) {
      if (mounted) setState(() => _playing = false);
    });
  }

  @override
  void dispose() {
    _tts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  Future<void> _play() async {
    HapticsService.tap();
    if (_playing) {
      await _tts.stop();
      await _audioPlayer.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }

    setState(() {
      _playing = true;
      _plays++;
    });

    final ayahNumber = widget.step.quranGlobalAyahNumber;
    if (ayahNumber != null) {
      Object? lastError;
      for (final source in quranAudioSources(ayahNumber)) {
        try {
          await _audioPlayer.playUrl(source);
          if (mounted) setState(() => _playing = false);
          return;
        } catch (error) {
          lastError = error;
          await _audioPlayer.stop();
        }
      }
      if (!mounted) return;
      setState(() => _playing = false);
      _showUnavailable('$lastError');
      return;
    }

    final text = widget.step.arabicText ?? widget.step.speechTarget;
    if (text == null || text.isEmpty) {
      if (mounted) setState(() => _playing = false);
      return;
    }
    try {
      await _tts.setLanguage('ar-SA');
      await _tts.setSpeechRate(0.38);
      await _tts.setPitch(1.0);
      await _tts.setVolume(1.0);
      await _tts.awaitSpeakCompletion(true);
      await _tts.speak(text);
      if (mounted) setState(() => _playing = false);
    } catch (_) {
      if (!mounted) return;
      setState(() => _playing = false);
      _showUnavailable(null);
    }
  }

  void _showUnavailable(String? details) {
    final state = context.read<AppState>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.tr(
          ru: 'Не удалось воспроизвести аудио.${details == null ? '' : ' $details'}',
          kk: 'Аудионы ойнату мүмкін болмады.${details == null ? '' : ' $details'}',
          en: 'Could not play the audio.${details == null ? '' : ' $details'}',
        )),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final step = widget.step;
    final answers = step.answers ?? const <String>[];
    final displayOrder =
        questionAnswerOrder(answers.length, _shuffleSeed(step));

    return Column(
      children: [
        SectionLabel(text: _stepTypeLabel(step, state)),
        const SizedBox(height: 10),
        Text(
            step.question ??
                state.tr(
                    ru: 'Прослушай и выбери верный вариант',
                    kk: 'Тыңдап, дұрыс нұсқаны таңда',
                    en: 'Listen and pick the right option'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark)),
        const SizedBox(height: 18),
        Semantics(
          button: true,
          label: state.tr(ru: 'Прослушать', kk: 'Тыңдау', en: 'Play the audio'),
          child: GestureDetector(
            onTap: _play,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: _playing ? AppColors.pistachio : AppColors.sky,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navyDark.withValues(alpha: 0.18),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(
                  _playing ? Icons.stop_rounded : Icons.volume_up_rounded,
                  size: 44,
                  color: AppColors.white),
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
            _plays == 0
                ? state.tr(
                    ru: 'Нажми, чтобы прослушать',
                    kk: 'Тыңдау үшін бас',
                    en: 'Tap to listen')
                : state.tr(
                    ru: 'Можно слушать сколько нужно',
                    kk: 'Қалағаныңша тыңдай аласың',
                    en: 'Listen as many times as you need'),
            style: const TextStyle(
                fontFamily: 'Nunito', fontSize: 13, color: AppColors.textGrey)),
        const SizedBox(height: 18),
        ...List.generate(displayOrder.length, (displayPos) {
          final i = displayOrder[displayPos];
          return _AnswerOptionCard(
            key: ValueKey('lesson_answer_$i'),
            text: answers[i],
            letter: String.fromCharCode(65 + displayPos),
            selected: widget.selectedAnswer == i,
            answered: widget.answered,
            isCorrectOption: i == step.correctAnswerIndex,
            onTap: () => widget.onSelect?.call(i),
          );
        }),
      ],
    );
  }

  int _shuffleSeed(LessonStep step) {
    final buffer = StringBuffer(step.id ?? step.question ?? 'listen');
    for (final answer in step.answers ?? const <String>[]) {
      buffer
        ..write('|')
        ..write(answer);
    }
    return buffer.toString().hashCode;
  }
}
