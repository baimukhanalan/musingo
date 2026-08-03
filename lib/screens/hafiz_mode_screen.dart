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

  static const _stageTitles = [
    'Прослушай образец',
    'Повтори вместе',
    'Повтори по частям',
    'Скрывай текст',
    'Вспомни без подсказки',
    'Запиши по памяти',
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
    if (!context.read<AppState>().soundEnabled) {
      _showMessage('Аудио выключено в настройках.');
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
    if (lastError != null) _showMessage('Аудио не загрузилось. Проверь интернет.');
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
      setState(() => _speechError = 'Сначала прослушай образец аята.');
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
            _speechError = 'Микрофон недоступен. Разреши доступ и повтори.';
          });
        },
      );
      if (!available) {
        await _speechEvaluation.cancel();
        if (mounted) {
          setState(() =>
              _speechError = 'Распознавание речи недоступно на этом устройстве.');
        }
        return;
      }
      if (!mounted) return;
      setState(() => _recording = true);
      await _speech.listen(
        onResult: _onSpeechResult,
        localeId: 'ar_SA',
        listenFor: const Duration(seconds: 25),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
      );
    } catch (_) {
      await _speechEvaluation.cancel();
      if (mounted) {
        setState(() {
          _recording = false;
          _speechError = 'Не удалось запустить микрофон. Попробуй ещё раз.';
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
        _speechError = 'Не удалось проверить запись. Попробуй ещё раз.';
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
    return showModalBottomSheet<void>(
      context: context,
      isDismissible: false,
      enableDrag: false,
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
                'Следующее повторение: ${_dateLabel(progress.nextReviewAt)}',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 18),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.pop(sheetContext),
                  child: const Text('Готово'),
                ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Text(
          'Hafiz · ${widget.chapter.latinName} ${widget.verse.numberInChapter}',
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 18,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(18, 4, 18, 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ШАГ ${_stage + 1} ИЗ ${_stageTitles.length}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                  const SizedBox(height: 6),
                  LinearProgressIndicator(
                    value: (_stage + 1) / _stageTitles.length,
                    minHeight: 7,
                    borderRadius: BorderRadius.circular(4),
                    backgroundColor: AppColors.border,
                    color: AppColors.sky,
                  ),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(18, 8, 18, 22),
                children: [
                  Text(
                    _stageTitles[_stage],
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 24,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 14),
                  _buildStage(),
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
    );
  }

  Widget _buildStage() {
    switch (_stage) {
      case 0:
        return Column(children: [_VerseText(verse: widget.verse), _audioButton()]);
      case 1:
        return Column(
          children: [
            _VerseText(verse: widget.verse),
            _audioButton(),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _guidedRepetitions >= 3
                    ? null
                    : () => setState(() => _guidedRepetitions++),
                icon: const Icon(Icons.record_voice_over_rounded),
                label: Text('Я повторил · $_guidedRepetitions/3'),
              ),
            ),
          ],
        );
      case 2:
        final chunk = _chunks[_chunkIndex];
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: Column(
                children: [
                  Text(
                    'Фрагмент ${_chunkIndex + 1} из ${_chunks.length}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 14),
                  Text(
                    chunk,
                    textDirection: TextDirection.rtl,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontFamily: 'Amiri',
                      fontSize: 31,
                      height: 1.8,
                      color: AppColors.textDark,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton.outlined(
                  tooltip: 'Предыдущий фрагмент',
                  onPressed: _chunkIndex == 0
                      ? null
                      : () => setState(() => _chunkIndex--),
                  icon: const Icon(Icons.chevron_left_rounded),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _practiceChunk,
                    icon: Icon(_practicedChunks.contains(_chunkIndex)
                        ? Icons.check_rounded
                        : Icons.mic_rounded),
                    label: Text(_practicedChunks.contains(_chunkIndex)
                        ? 'Освоено'
                        : 'Повторил фрагмент'),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.outlined(
                  tooltip: 'Следующий фрагмент',
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
            const SizedBox(height: 14),
            Slider(
              value: _hideLevel,
              divisions: 3,
              label: '${(_hideLevel * 100).round()}% скрыто',
              onChanged: (value) => setState(() => _hideLevel = value),
            ),
            Text(
              '${(_hideLevel * 100).round()}% текста скрыто',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w800,
                color: AppColors.textGrey,
              ),
            ),
          ],
        );
      case 4:
        return Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.border),
              ),
              child: _memoryTextRevealed
                  ? Text(
                      widget.verse.arabicText,
                      textDirection: TextDirection.rtl,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 30,
                        height: 1.8,
                      ),
                    )
                  : const Column(
                      children: [
                        Icon(Icons.visibility_off_rounded,
                            size: 42, color: AppColors.navy),
                        SizedBox(height: 8),
                        Text(
                          'Произнеси аят полностью, не открывая текст',
                          textAlign: TextAlign.center,
                          style: TextStyle(
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
              label: Text(_memoryTextRevealed ? 'Скрыть снова' : 'Проверить текст'),
            ),
            const SizedBox(height: 8),
            SegmentedButton<int>(
              segments: const [
                ButtonSegment(value: 1, label: Text('Трудно')),
                ButtonSegment(value: 2, label: Text('Почти')),
                ButtonSegment(value: 3, label: Text('Уверенно')),
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
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: AppColors.navy,
                borderRadius: BorderRadius.circular(8),
              ),
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
                        ? 'Говори аят полностью'
                        : _result == null
                            ? 'Текст скрыт. Запиши аят по памяти.'
                            : 'Оценка: ${_result!.score}%',
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
              title: const Text(
                'Разрешаю обработать запись для оценки',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              subtitle: const Text(
                'Запись удаляется после проверки и не используется для обучения моделей.',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed:
                    _evaluating || !_voiceConsent ? null : _toggleRecording,
                icon: _evaluating
                    ? const SizedBox.square(
                        dimension: 17,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white),
                      )
                    : Icon(_recording ? Icons.stop_rounded : Icons.mic_rounded),
                label: Text(_evaluating
                    ? 'Проверяем...'
                    : _recording
                        ? 'Остановить запись'
                        : _result == null
                            ? 'Начать запись'
                            : 'Записать ещё раз'),
              ),
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
                child: const Text('Сохранить без голосовой оценки'),
              ),
            ],
          ],
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _audioButton() {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: _audioLoading ? null : _playSample,
          icon: _audioLoading
              ? const SizedBox.square(
                  dimension: 17,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white),
                )
              : Icon(_audioPlaying
                  ? Icons.pause_rounded
                  : Icons.volume_up_rounded),
          label: Text(_audioPlaying
              ? 'Пауза'
              : _samplePlayed
                  ? 'Прослушать ещё раз'
                  : 'Прослушать правильный образец'),
        ),
      ),
    );
  }
}

class _VerseText extends StatelessWidget {
  final QuranVerse verse;

  const _VerseText({required this.verse});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          Text(
            verse.arabicText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 30,
              height: 1.9,
              color: AppColors.textDark,
            ),
          ),
          const Divider(height: 24),
          Text(
            verse.transliteration,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontStyle: FontStyle.italic,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _HiddenVerse extends StatelessWidget {
  final QuranVerse verse;
  final double level;

  const _HiddenVerse({required this.verse, required this.level});

  @override
  Widget build(BuildContext context) {
    final words = verse.arabicText.split(RegExp(r'\s+'));
    final hiddenEvery = level < 0.34
        ? 99
        : level < 0.67
            ? 3
            : level < 1
                ? 2
                : 1;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.border),
      ),
      child: Wrap(
        alignment: WrapAlignment.center,
        textDirection: TextDirection.rtl,
        spacing: 8,
        runSpacing: 8,
        children: words.indexed.map((item) {
          final hidden = hiddenEvery != 99 && item.$1 % hiddenEvery == 0;
          return Text(
            hidden ? 'ــــــ' : item.$2,
            textDirection: TextDirection.rtl,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 28,
              color: hidden ? AppColors.border : AppColors.textDark,
            ),
          );
        }).toList(growable: false),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 12),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SizedBox(
        width: double.infinity,
        child: FilledButton.icon(
          onPressed: enabled ? onContinue : null,
          icon: Icon(stage == 5 ? Icons.save_rounded : Icons.arrow_forward_rounded),
          label: Text(stage == 5
              ? result == null
                  ? 'Сначала запиши аят'
                  : 'Сохранить результат'
              : 'Продолжить'),
        ),
      ),
    );
  }
}

String _dateLabel(DateTime date) =>
    '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
