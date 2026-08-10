import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';

import '../models/hafiz_progress.dart';
import '../models/lesson.dart';
import '../models/quran.dart';
import '../models/speech_evaluation.dart';
import '../services/app_state.dart';
import '../services/quran_audio_player.dart';
import '../services/speech_evaluation_service.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/progress_ring.dart';

class HafizModeScreen extends StatefulWidget {
  final QuranChapterSummary chapter;
  final QuranVerse verse;

  const HafizModeScreen({
    super.key,
    required this.chapter,
    required this.verse,
  });

  @override
  State<HafizModeScreen> createState() => _HafizModeScreenState();
}

class _HafizModeScreenState extends State<HafizModeScreen> {
  late final QuranAudioPlayer _audioPlayer;
  late final SpeechEvaluationService _speechEvaluation;
  final SpeechToText _speech = SpeechToText();
  StreamSubscription<QuranAudioPlaybackState>? _audioSubscription;

  int _stage = 0;
  bool _samplePlayed = false;
  bool _audioLoading = false;
  bool _audioPlaying = false;
  int _guidedRepetitions = 0;
  int _chunkIndex = 0;
  final Set<int> _practicedChunks = {};
  double _hideLevel = 0;
  bool _memoryTextRevealed = false;
  int? _confidence;
  bool _recording = false;
  bool _evaluating = false;
  bool _gradingRequested = false;
  String _transcript = '';
  String? _speechError;
  Uint8List? _audioBytes;
  SpeechEvaluationResult? _result;
  bool _voiceConsent = false;

  List<String> _stageTitles(AppState state) => [
        state.tr(
            ru: 'Прослушай образец',
            kk: 'Үлгіні тыңда',
            en: 'Listen to the sample'),
        state.tr(
            ru: 'Повтори вместе', kk: 'Бірге қайтала', en: 'Repeat along'),
        state.tr(
            ru: 'Повтори по частям',
            kk: 'Бөліктеп қайтала',
            en: 'Repeat in parts'),
        state.tr(
            ru: 'Скрывай текст', kk: 'Мәтінді жасыр', en: 'Hide the text'),
        state.tr(
            ru: 'Вспомни без подсказки',
            kk: 'Кеңессіз есіңе түсір',
            en: 'Recall without hints'),
        state.tr(
            ru: 'Запиши по памяти',
            kk: 'Жатқа жазып ал',
            en: 'Record from memory'),
      ];

  @override
  void initState() {
    super.initState();
    _audioPlayer = QuranAudioPlayer();
    _speechEvaluation = SpeechEvaluationService();
    _audioSubscription = _audioPlayer.playbackStateStream.listen((state) {
      if (!mounted) return;
      setState(() {
        _audioPlaying = state.playing;
        if (state.completed) _audioLoading = false;
      });
    });
  }

  @override
  void dispose() {
    _audioSubscription?.cancel();
    _audioPlayer.dispose();
    _speech.cancel();
    _speechEvaluation.cancel();
    _speechEvaluation.dispose();
    super.dispose();
  }

  List<String> get _chunks {
    final words = widget.verse.arabicText
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    if (words.length <= 3) return words;
    final size = (words.length / 3).ceil();
    final chunks = <String>[];
    for (var index = 0; index < words.length; index += size) {
      chunks.add(words.skip(index).take(size).join(' '));
    }
    return chunks;
  }

  Future<void> _playSample() async {
    if (_audioPlaying) {
      await _audioPlayer.pause();
      return;
    }
    final state = context.read<AppState>();
    if (!state.soundEnabled) {
      _showMessage(state.tr(
          ru: 'Аудио выключено в настройках.',
          kk: 'Аудио баптауларда өшірілген.',
          en: 'Audio is turned off in settings.'));
      return;
    }
    setState(() {
      _audioLoading = true;
      _speechError = null;
    });
    final sources = [
      widget.verse.audioUrl,
      if (widget.verse.audioFallbackUrl != null)
        widget.verse.audioFallbackUrl!,
    ];
    Object? lastError;
    for (final source in sources) {
      try {
        await _audioPlayer.playUrl(source);
        lastError = null;
        if (mounted) {
          setState(() {
            _samplePlayed = true;
            _audioLoading = false;
          });
        }
        return;
      } catch (error) {
        lastError = error;
        await _audioPlayer.stop();
      }
    }
    if (!mounted) return;
    setState(() => _audioLoading = false);
    if (lastError != null) {
      _showMessage(state.tr(
          ru: 'Аудио не загрузилось. Проверь интернет.',
          kk: 'Аудио жүктелмеді. Интернетті тексер.',
          en: 'Audio failed to load. Check your connection.'));
    }
  }

  bool get _canContinue {
    switch (_stage) {
      case 0:
        return _samplePlayed;
      case 1:
        return _guidedRepetitions >= 3;
      case 2:
        return _practicedChunks.length == _chunks.length;
      case 3:
        return _hideLevel >= 0.66;
      case 4:
        return _confidence != null;
      case 5:
        return _result != null;
      default:
        return false;
    }
  }

  void _continue() {
    if (!_canContinue || _stage >= 5) return;
    setState(() => _stage++);
  }

  void _practiceChunk() {
    setState(() {
      _practicedChunks.add(_chunkIndex);
      if (_chunkIndex + 1 < _chunks.length) _chunkIndex++;
    });
  }

  Future<void> _toggleRecording() async {
    if (!_samplePlayed) {
      final state = context.read<AppState>();
      setState(() => _speechError = state.tr(
          ru: 'Сначала прослушай образец аята.',
          kk: 'Алдымен аят үлгісін тыңда.',
          en: 'Listen to the verse sample first.'));
      return;
    }
    if (_recording) {
      await _speech.stop();
      _audioBytes = await _speechEvaluation.stop();
      if (mounted) setState(() => _recording = false);
      await _gradeSpeech();
      return;
    }

    setState(() {
      _speechError = null;
      _transcript = '';
      _result = null;
      _gradingRequested = false;
      _audioBytes = null;
    });
    try {
      await _speechEvaluation.record();
      final available = await _speech.initialize(
        onStatus: (status) {
          if (!mounted) return;
          if ((status == 'done' || status == 'notListening') && _recording) {
            unawaited(_gradeSpeech());
          }
        },
        onError: (_) {
          if (!mounted) return;
          setState(() {
            _recording = false;
            _speechError = context.read<AppState>().tr(
                ru: 'Микрофон недоступен. Разреши доступ и повтори.',
                kk: 'Микрофон қолжетімсіз. Рұқсат беріп, қайтала.',
                en: 'Microphone unavailable. Grant access and try again.');
          });
        },
      );
      if (!available) {
        await _speechEvaluation.cancel();
        if (mounted) {
          setState(() => _speechError = context.read<AppState>().tr(
              ru: 'Распознавание речи недоступно на этом устройстве.',
              kk: 'Бұл құрылғыда сөйлеуді тану қолжетімсіз.',
              en: 'Speech recognition is unavailable on this device.'));
        }
        return;
      }
      if (!mounted) return;
      setState(() => _recording = true);
      await _speech.listen(
        onResult: _onSpeechResult,
        listenOptions: SpeechListenOptions(
          localeId: 'ar_SA',
          listenFor: const Duration(seconds: 25),
          pauseFor: const Duration(seconds: 3),
          partialResults: true,
        ),
      );
    } catch (_) {
      await _speechEvaluation.cancel();
      if (mounted) {
        setState(() {
          _recording = false;
          _speechError = context.read<AppState>().tr(
              ru: 'Не удалось запустить микрофон. Попробуй ещё раз.',
              kk: 'Микрофонды іске қосу мүмкін болмады. Қайтадан көр.',
              en: 'Could not start the microphone. Try again.');
        });
      }
    }
  }

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() => _transcript = result.recognizedWords);
    if (result.finalResult) unawaited(_gradeSpeech());
  }

  Future<void> _gradeSpeech() async {
    if (!mounted || _evaluating || _gradingRequested) return;
    _gradingRequested = true;
    setState(() {
      _evaluating = true;
      _recording = false;
    });
    try {
      _audioBytes ??= await _speechEvaluation.stop();
      final result = await _speechEvaluation.evaluate(
        step: LessonStep(
          id: 'hafiz_${widget.chapter.number}_${widget.verse.numberInChapter}',
          type: LessonStepType.speak,
          quranGlobalAyahNumber: widget.verse.globalNumber,
          arabicText: widget.verse.arabicText,
          transliteration: widget.verse.transliteration,
          speechTarget: widget.verse.arabicText,
          speechMode: SpeechMode.quran,
          passScore: 70,
        ),
        transcript: _transcript,
        audioBytes: _audioBytes,
        lessonId:
            'hafiz:${widget.chapter.number}:${widget.verse.numberInChapter}',
      );
      if (!mounted) return;
      setState(() {
        _result = result;
        _evaluating = false;
        if (result.transcript.isNotEmpty) _transcript = result.transcript;
        _speechError = result.passed ? null : result.feedbackText;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _evaluating = false;
        _speechError = context.read<AppState>().tr(
            ru: 'Не удалось проверить запись. Попробуй ещё раз.',
            kk: 'Жазбаны тексеру мүмкін болмады. Қайтадан көр.',
            en: 'Could not check the recording. Try again.');
      });
    }
  }

  Future<void> _finish({int? fallbackScore}) async {
    final score = _result?.score ?? fallbackScore;
    if (score == null) return;
    final progress = await context.read<AppState>().recordHafizAttempt(
          surahNumber: widget.chapter.number,
          surahName: widget.chapter.latinName,
          verseNumber: widget.verse.numberInChapter,
          globalVerseNumber: widget.verse.globalNumber,
          score: score,
          repetitions: _guidedRepetitions + _practicedChunks.length,
        );
    if (!mounted || progress == null) return;
    await _showResult(progress, score);
    if (mounted) Navigator.pop(context);
  }

  Future<void> _showResult(HafizProgress progress, int score) {
    final state = context.read<AppState>();
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
      backgroundColor: AppColors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.workspace_premium_rounded,
                  size: 48, color: AppColors.gold),
              const SizedBox(height: 10),
              Text(
                '$score%',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${progress.masteryLabel} · mastery ${(progress.mastery * 100).round()}%',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.tr(
                    ru: 'Следующее повторение: ${_dateLabel(progress.nextReviewAt)}',
                    kk: 'Келесі қайталау: ${_dateLabel(progress.nextReviewAt)}',
                    en: 'Next review: ${_dateLabel(progress.nextReviewAt)}'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 18),
              PremiumButton(
                label: state.tr(ru: 'Готово', kk: 'Дайын', en: 'Done'),
                icon: Icons.check_rounded,
                onPressed: () => Navigator.pop(sheetContext),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showMessage(String text) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  }

  /// Reading phase derived from the linear stage (read-only reflection of the
  /// existing flow state — the mode pills mirror progress, they don't drive it):
  /// 0 = Читаю (listen/repeat), 1 = Подсказки (chunks/hide), 2 = По памяти.
  int get _phase => _stage <= 1 ? 0 : (_stage <= 3 ? 1 : 2);

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    // Real "% в памяти" from stored progress for this verse (read-only).
    final existing = state.hafizProgressFor(
          widget.chapter.number,
          widget.verse.numberInChapter,
        );
    final memoryPercent = ((existing?.mastery ?? 0) * 100).round();

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(
                chapter: widget.chapter,
                memoryPercent: memoryPercent,
                onBack: () => Navigator.pop(context),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 4),
                child: _ModePills(phase: _phase),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 6),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr(
                          ru: 'ШАГ ${_stage + 1} ИЗ ${_stageTitles(state).length}',
                          kk: '${_stageTitles(state).length} ҚАДАМНЫҢ ${_stage + 1}-і',
                          en: 'STEP ${_stage + 1} OF ${_stageTitles(state).length}'),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.1,
                        color: AppColors.textLight,
                      ),
                    ),
                    const SizedBox(height: 6),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: (_stage + 1) / _stageTitles(state).length,
                        minHeight: 7,
                        backgroundColor: AppColors.border,
                        color: AppColors.sky,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                  children: [
                    Text(
                      _stageTitles(state)[_stage],
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _buildStage(),
                    const SizedBox(height: 16),
                    _ReviewCard(progress: existing),
                  ],
                ),
              ),
              _BottomAction(
                stage: _stage,
                enabled: _canContinue,
                result: _result,
                onContinue: _stage == 5 ? () => _finish() : _continue,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStage() {
    final state = context.read<AppState>();
    switch (_stage) {
      case 0:
        return Column(children: [_VerseText(verse: widget.verse), _audioButton()]);
      case 1:
        return Column(
          children: [
            _VerseText(verse: widget.verse),
            _audioButton(),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _guidedRepetitions >= 3
                  ? null
                  : () => setState(() => _guidedRepetitions++),
              icon: const Icon(Icons.record_voice_over_rounded),
              label: Text(state.tr(
                  ru: 'Я повторил · $_guidedRepetitions/3',
                  kk: 'Қайталадым · $_guidedRepetitions/3',
                  en: 'I repeated · $_guidedRepetitions/3')),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(50),
                foregroundColor: AppColors.navy,
                side: const BorderSide(color: AppColors.border),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
            ),
          ],
        );
      case 2:
        final chunk = _chunks[_chunkIndex];
        return Column(
          children: [
            PremiumCard(
              child: Column(
                children: [
                  Text(
                    state.tr(
                        ru: 'Фрагмент ${_chunkIndex + 1} из ${_chunks.length}',
                        kk: '${_chunks.length} бөліктің ${_chunkIndex + 1}-і',
                        en: 'Fragment ${_chunkIndex + 1} of ${_chunks.length}'),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: AppColors.textLight,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _ArabicChips(text: chunk, fontSize: 30),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.outlined(
                  tooltip: state.tr(
                      ru: 'Предыдущий фрагмент',
                      kk: 'Алдыңғы бөлік',
                      en: 'Previous fragment'),
                  onPressed: _chunkIndex == 0
                      ? null
                      : () => setState(() => _chunkIndex--),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _practiceChunk,
                    style: FilledButton.styleFrom(
                      minimumSize: const Size.fromHeight(50),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(_practicedChunks.contains(_chunkIndex)
                        ? Icons.check_rounded
                        : Icons.mic_rounded),
                    label: Text(_practicedChunks.contains(_chunkIndex)
                        ? state.tr(
                            ru: 'Освоено', kk: 'Меңгерілді', en: 'Mastered')
                        : state.tr(
                            ru: 'Повторил фрагмент',
                            kk: 'Бөлікті қайталадым',
                            en: 'Repeated the fragment')),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: state.tr(
                      ru: 'Следующий фрагмент',
                      kk: 'Келесі бөлік',
                      en: 'Next fragment'),
                  onPressed: _chunkIndex + 1 >= _chunks.length
                      ? null
                      : () => setState(() => _chunkIndex++),
                  icon: const Icon(Icons.chevron_right_rounded),
                ),
              ],
            ),
          ],
        );
      case 3:
        return Column(
          children: [
            _HiddenVerse(verse: widget.verse, level: _hideLevel),
            const SizedBox(height: 6),
            Text(
              state.tr(
                  ru: 'Нажми на скрытое слово — оно откроется',
                  kk: 'Жасырылған сөзді бас — ол ашылады',
                  en: 'Tap a hidden word — it will reveal'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 10),
            Slider(
              value: _hideLevel,
              divisions: 3,
              label: state.tr(
                  ru: '${(_hideLevel * 100).round()}% скрыто',
                  kk: '${(_hideLevel * 100).round()}% жасырылды',
                  en: '${(_hideLevel * 100).round()}% hidden'),
              onChanged: (value) => setState(() => _hideLevel = value),
            ),
            Text(
              state.tr(
                  ru: '${(_hideLevel * 100).round()}% текста скрыто',
                  kk: 'Мәтіннің ${(_hideLevel * 100).round()}% жасырылды',
                  en: '${(_hideLevel * 100).round()}% of the text hidden'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 12),
            _PlusNote(
              text: state.tr(
                  ru: 'Постепенное автоскрытие по расписанию — в Muslingo+',
                  kk: 'Кесте бойынша біртіндеп авто-жасыру — Muslingo+ ішінде',
                  en: 'Gradual scheduled auto-hiding — in Muslingo+'),
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            PremiumCard(
              child: _memoryTextRevealed
                  ? _ArabicChips(text: widget.verse.arabicText, fontSize: 29)
                  : Column(
                      children: [
                        const Icon(Icons.visibility_off_rounded,
                            size: 42, color: AppColors.navy),
                        const SizedBox(height: 8),
                        Text(
                          state.tr(
                              ru: 'Произнеси аят полностью, не открывая текст',
                              kk: 'Аятты мәтінді ашпай толық айт',
                              en: 'Recite the verse in full without opening the text'),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
            ),
            TextButton.icon(
              onPressed: () =>
                  setState(() => _memoryTextRevealed = !_memoryTextRevealed),
              icon: Icon(_memoryTextRevealed
                  ? Icons.visibility_off_rounded
                  : Icons.visibility_rounded),
              label: Text(_memoryTextRevealed
                  ? state.tr(
                      ru: 'Скрыть снова', kk: 'Қайта жасыру', en: 'Hide again')
                  : state.tr(
                      ru: 'Проверить текст',
                      kk: 'Мәтінді тексеру',
                      en: 'Check the text')),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: [
                ButtonSegment(
                    value: 1,
                    label: Text(state.tr(
                        ru: 'Трудно', kk: 'Қиын', en: 'Hard'))),
                ButtonSegment(
                    value: 2,
                    label: Text(state.tr(
                        ru: 'Почти', kk: 'Шамалы', en: 'Almost'))),
                ButtonSegment(
                    value: 3,
                    label: Text(state.tr(
                        ru: 'Уверенно', kk: 'Сенімді', en: 'Confident'))),
              ],
              selected: _confidence == null ? const {} : {_confidence!},
              emptySelectionAllowed: true,
              onSelectionChanged: (value) =>
                  setState(() => _confidence = value.first),
            ),
          ],
        );
      case 5:
        return Column(
          children: [
            PremiumCard(
              color: AppColors.navyDark,
              child: Column(
                children: [
                  Icon(
                    _recording ? Icons.graphic_eq_rounded : Icons.mic_rounded,
                    size: 46,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _recording
                        ? state.tr(
                            ru: 'Говори аят полностью',
                            kk: 'Аятты толық айт',
                            en: 'Recite the verse in full')
                        : _result == null
                            ? state.tr(
                                ru: 'Текст скрыт. Запиши аят по памяти.',
                                kk: 'Мәтін жасырылған. Аятты жатқа жазып ал.',
                                en: 'Text is hidden. Record the verse from memory.')
                            : state.tr(
                                ru: 'Оценка: ${_result!.score}%',
                                kk: 'Баға: ${_result!.score}%',
                                en: 'Score: ${_result!.score}%'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            CheckboxListTile(
              value: _voiceConsent,
              onChanged: _recording || _evaluating
                  ? null
                  : (value) => setState(() => _voiceConsent = value ?? false),
              contentPadding: EdgeInsets.zero,
              controlAffinity: ListTileControlAffinity.leading,
              title: Text(
                state.tr(
                    ru: 'Разрешаю обработать запись для оценки',
                    kk: 'Бағалау үшін жазбаны өңдеуге рұқсат етемін',
                    en: 'I allow the recording to be processed for scoring'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              subtitle: Text(
                state.tr(
                    ru: 'Запись удаляется после проверки и не используется для обучения моделей.',
                    kk: 'Жазба тексерілгеннен кейін жойылады және модельдерді оқыту үшін пайдаланылмайды.',
                    en: 'The recording is deleted after checking and is not used to train models.'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            FilledButton.icon(
              onPressed: _evaluating || !_voiceConsent ? null : _toggleRecording,
              style: FilledButton.styleFrom(
                minimumSize: const Size.fromHeight(52),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              icon: _evaluating
                  ? const SizedBox.square(
                      dimension: 17,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white),
                    )
                  : Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded),
              label: Text(_evaluating
                  ? state.tr(
                      ru: 'Проверяем...',
                      kk: 'Тексерудеміз...',
                      en: 'Checking...')
                  : _recording
                      ? state.tr(
                          ru: 'Остановить запись',
                          kk: 'Жазбаны тоқтату',
                          en: 'Stop recording')
                      : _result == null
                          ? state.tr(
                              ru: 'Проверить по памяти',
                              kk: 'Жатқа тексеру',
                              en: 'Check from memory')
                          : state.tr(
                              ru: 'Записать ещё раз',
                              kk: 'Қайта жазу',
                              en: 'Record again')),
            ),
            if (_transcript.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                _transcript,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  color: AppColors.textGrey,
                ),
              ),
            ],
            if (_speechError != null) ...[
              const SizedBox(height: 10),
              Text(
                _speechError!,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            ],
            if (_result == null && _speechError != null) ...[
              const SizedBox(height: 6),
              TextButton(
                onPressed: () => _finish(
                  fallbackScore: switch (_confidence) {
                    3 => 72,
                    2 => 60,
                    _ => 45,
                  },
                ),
                child: Text(state.tr(
                    ru: 'Сохранить без голосовой оценки',
                    kk: 'Дауыстық бағалаусыз сақтау',
                    en: 'Save without voice scoring')),
              ),
            ],
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _audioButton() {
    final state = context.read<AppState>();
    return Padding(
      padding: const EdgeInsets.only(top: 14),
      child: PremiumButton(
        label: _audioPlaying
            ? state.tr(ru: 'Пауза', kk: 'Кідірту', en: 'Pause')
            : _samplePlayed
                ? state.tr(
                    ru: 'Прослушать ещё раз',
                    kk: 'Қайта тыңдау',
                    en: 'Listen again')
                : state.tr(
                    ru: 'Прослушать правильный образец',
                    kk: 'Дұрыс үлгіні тыңдау',
                    en: 'Listen to the correct sample'),
        icon: _audioLoading
            ? null
            : (_audioPlaying ? Icons.pause_rounded : Icons.volume_up_rounded),
        onPressed: _audioLoading ? null : _playSample,
      ),
    );
  }
}

/// Premium screen header: back control, title + sura subtitle and a mastery
/// ring showing "% в памяти" for this verse.
class _Header extends StatelessWidget {
  final QuranChapterSummary chapter;
  final int memoryPercent;
  final VoidCallback onBack;

  const _Header({
    required this.chapter,
    required this.memoryPercent,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
            icon: const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hafiz Mode',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.tr(
                      ru: '${chapter.latinName} · заучивание',
                      kk: '${chapter.latinName} · жаттау',
                      en: '${chapter.latinName} · memorization'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProgressRing(
                percent: memoryPercent / 100,
                size: 52,
                color: AppColors.gold,
                child: Text(
                  '$memoryPercent%',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                state.tr(ru: 'В ПАМЯТИ', kk: 'ЖАТТАЛҒАН', en: 'MEMORIZED'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reading-mode toggle pills. Visual reflection of the current [phase]
/// (0 Читаю / 1 Подсказки / 2 По памяти) — mirrors the flow, does not drive it.
class _ModePills extends StatelessWidget {
  final int phase;

  const _ModePills({required this.phase});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final labels = [
      state.tr(ru: 'Читаю', kk: 'Оқып жатырмын', en: 'Reading'),
      state.tr(ru: 'Подсказки', kk: 'Кеңестер', en: 'Hints'),
      state.tr(ru: 'По памяти', kk: 'Жатқа', en: 'From memory'),
    ];
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
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: i == phase ? AppColors.navyDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: i == phase ? AppColors.white : AppColors.textLight,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Arabic verse laid out as rounded word-chips (Amiri, RTL).
class _ArabicChips extends StatelessWidget {
  final String text;
  final double fontSize;

  const _ArabicChips({required this.text, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    final words = text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    return Wrap(
      alignment: WrapAlignment.center,
      textDirection: TextDirection.rtl,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final word in words)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              word,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: fontSize,
                height: 1.6,
                color: AppColors.textDark,
              ),
            ),
          ),
      ],
    );
  }
}

class _VerseText extends StatelessWidget {
  final QuranVerse verse;

  const _VerseText({required this.verse});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          _ArabicChips(text: verse.arabicText, fontSize: 29),
          const Divider(height: 26, color: AppColors.border),
          Text(
            verse.transliteration,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hide-level word grid: words the level marks hidden render as `● ● ●` chips.
/// The hide computation from [level] is unchanged; tapping a hidden chip locally
/// reveals that single word (peek), which is display-only session state.
class _HiddenVerse extends StatefulWidget {
  final QuranVerse verse;
  final double level;

  const _HiddenVerse({required this.verse, required this.level});

  @override
  State<_HiddenVerse> createState() => _HiddenVerseState();
}

class _HiddenVerseState extends State<_HiddenVerse> {
  final Set<int> _revealed = {};

  @override
  void didUpdateWidget(_HiddenVerse oldWidget) {
    super.didUpdateWidget(oldWidget);
    // A new hide level re-hides the words that were peeked.
    if (oldWidget.level != widget.level) _revealed.clear();
  }

  @override
  Widget build(BuildContext context) {
    final words = widget.verse.arabicText
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    final hiddenEvery = widget.level < 0.34
        ? 99
        : widget.level < 0.67
            ? 3
            : widget.level < 1
                ? 2
                : 1;
    return PremiumCard(
      child: Wrap(
        alignment: WrapAlignment.center,
        textDirection: TextDirection.rtl,
        spacing: 8,
        runSpacing: 8,
        children: words.indexed.map((item) {
          final hidden = hiddenEvery != 99 && item.$1 % hiddenEvery == 0;
          final peeked = _revealed.contains(item.$1);
          final showHidden = hidden && !peeked;
          return GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: hidden
                ? () => setState(() {
                      if (peeked) {
                        _revealed.remove(item.$1);
                      } else {
                        _revealed.add(item.$1);
                      }
                    })
                : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: showHidden ? AppColors.skyLight : AppColors.backgroundGrey,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: showHidden ? AppColors.sky : AppColors.border,
                ),
              ),
              child: showHidden
                  ? const Text(
                      '● ● ●',
                      style: TextStyle(
                        fontSize: 12,
                        letterSpacing: 1,
                        color: AppColors.sky,
                        fontWeight: FontWeight.w900,
                      ),
                    )
                  : Text(
                      item.$2,
                      textDirection: TextDirection.rtl,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 28,
                        height: 1.5,
                        color: AppColors.textDark,
                      ),
                    ),
            ),
          );
        }).toList(growable: false),
      ),
    );
  }
}

/// Data-driven review schedule card: shows the next spaced-repetition date from
/// stored progress (real AppState data — no fabricated plan).
class _ReviewCard extends StatelessWidget {
  final HafizProgress? progress;

  const _ReviewCard({required this.progress});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final progress = this.progress;
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            state.tr(
                ru: 'РАСПИСАНИЕ ПОВТОРЕНИЙ',
                kk: 'ҚАЙТАЛАУ КЕСТЕСІ',
                en: 'REVIEW SCHEDULE'),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.1,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          _row(
            icon: Icons.play_circle_fill_rounded,
            color: AppColors.sky,
            title: state.tr(ru: 'Сегодня', kk: 'Бүгін', en: 'Today'),
            trailing:
                state.tr(ru: 'заучивание', kk: 'жаттау', en: 'memorization'),
          ),
          const SizedBox(height: 10),
          if (progress == null)
            _row(
              icon: Icons.schedule_rounded,
              color: AppColors.textLight,
              title: state.tr(
                  ru: 'Следующее повторение',
                  kk: 'Келесі қайталау',
                  en: 'Next review'),
              trailing: state.tr(
                  ru: 'после проверки',
                  kk: 'тексеруден кейін',
                  en: 'after checking'),
            )
          else ...[
            _row(
              icon: Icons.event_repeat_rounded,
              color: AppColors.gold,
              title: state.tr(
                  ru: 'Следующее повторение',
                  kk: 'Келесі қайталау',
                  en: 'Next review'),
              trailing: _dateLabel(progress.nextReviewAt),
            ),
            const SizedBox(height: 10),
            _row(
              icon: Icons.verified_rounded,
              color: AppColors.success,
              title: progress.masteryLabel,
              trailing: 'mastery ${(progress.mastery * 100).round()}%',
            ),
          ],
        ],
      ),
    );
  }

  Widget _row({
    required IconData icon,
    required Color color,
    required String title,
    required String trailing,
  }) {
    return Row(
      children: [
        Container(
          width: 30,
          height: 30,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.14),
          ),
          child: Icon(icon, size: 17, color: color),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
        ),
        Text(
          trailing,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12.5,
            fontWeight: FontWeight.w700,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}

/// Small Muslingo+ upsell note.
class _PlusNote extends StatelessWidget {
  final String text;

  const _PlusNote({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
      decoration: BoxDecoration(
        color: AppColors.goldLight.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.workspace_premium_rounded,
              size: 18, color: AppColors.gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomAction extends StatelessWidget {
  final int stage;
  final bool enabled;
  final SpeechEvaluationResult? result;
  final VoidCallback onContinue;

  const _BottomAction({
    required this.stage,
    required this.enabled,
    required this.result,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 14),
      decoration: BoxDecoration(
        color: AppColors.white.withValues(alpha: 0.92),
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: PremiumButton(
        label: stage == 5
            ? result == null
                ? state.tr(
                    ru: 'Сначала запиши аят',
                    kk: 'Алдымен аятты жаз',
                    en: 'Record the verse first')
                : state.tr(
                    ru: 'Сохранить результат',
                    kk: 'Нәтижені сақтау',
                    en: 'Save the result')
            : state.tr(ru: 'Продолжить', kk: 'Жалғастыру', en: 'Continue'),
        icon: stage == 5 ? Icons.save_rounded : Icons.arrow_forward_rounded,
        onPressed: enabled ? onContinue : null,
      ),
    );
  }
}

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
