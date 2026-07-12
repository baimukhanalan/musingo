import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/lesson.dart';
import '../models/speech_evaluation.dart';
import '../services/app_state.dart';
import '../services/backend_service.dart';
import '../services/haptics_service.dart';
import '../services/quran_audio_player.dart';
import '../services/speech_evaluation_service.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/custom_button.dart';

class LessonScreen extends StatefulWidget {
  final Lesson lesson;
  const LessonScreen({super.key, required this.lesson});

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  int _stepIndex = 0;
  CatMood _catMood = CatMood.greet;
  int? _selectedAnswer;
  bool _answered = false;
  bool _showHint = false;
  int _errors = 0;
  bool _speakPassed = false;
  bool _reviewingMistakes = false;
  final List<LessonStep> _mistakeSteps = [];
  List<LessonStep> _reviewSteps = [];

  List<LessonStep> get _activeSteps =>
      _reviewingMistakes ? _reviewSteps : widget.lesson.steps;
  LessonStep get _step => _activeSteps[_stepIndex];
  double get _progress => (_stepIndex) / _activeSteps.length;

  void _onCheck() {
    if (_step.type == LessonStepType.question) {
      if (_selectedAnswer == null) return;
      final isCorrect = _selectedAnswer == _step.correctAnswerIndex;
      if (isCorrect) {
        HapticsService.correct();
      } else {
        HapticsService.wrong();
      }
      setState(() {
        _answered = true;
        if (isCorrect) {
          _catMood = CatMood.success;
        } else {
          _catMood = CatMood.error;
          _errors++;
          if (!_mistakeSteps.contains(_step)) _mistakeSteps.add(_step);
          context.read<AppState>().loseHeart();
        }
      });
    } else {
      _nextStep();
    }
  }

  void _nextStep() {
    if (_stepIndex + 1 >= _activeSteps.length) {
      if (!_reviewingMistakes && _mistakeSteps.isNotEmpty) {
        HapticsService.reward();
        setState(() {
          _reviewSteps = List<LessonStep>.from(_mistakeSteps);
          _mistakeSteps.clear();
          _reviewingMistakes = true;
          _stepIndex = 0;
          _selectedAnswer = null;
          _answered = false;
          _showHint = false;
          _speakPassed = _step.type != LessonStepType.speak;
          _catMood = CatMood.support;
        });
        return;
      }
      _finishLesson();
      return;
    }
    HapticsService.tap();
    setState(() {
      _stepIndex++;
      _selectedAnswer = null;
      _answered = false;
      _showHint = false;
      _speakPassed = _step.type != LessonStepType.speak;
      _catMood = _stepIndex == 0 ? CatMood.greet : CatMood.support;
    });
  }

  Future<void> _finishLesson() async {
    final result = await context
        .read<AppState>()
        .completeLesson(widget.lesson.id, _errors);
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/lesson_review', arguments: {
        'lesson': widget.lesson,
        'xpEarned': result['xpEarned'] ?? 25,
        'streakBonus': result['streakBonus'] ?? 0,
        'heartsLost': _errors,
        'newStreak': result['newStreak'] ?? 0,
        'energyEarned': result['energyEarned'] ?? 0,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final hearts = state.user?.hearts ?? 5;
    final isPremium = state.user?.isPremium ?? false;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _TopBar(
                progress: _progress,
                hearts: hearts,
                isPremium: isPremium,
                onClose: () => _showExitDialog(context)),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    const SizedBox(height: 12),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 400),
                      child: CatCharacter(
                          key: ValueKey(_catMood), mood: _catMood, size: 160),
                    ),
                    const SizedBox(height: 16),
                    _buildStepContent(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
            _BottomBar(
              step: _step,
              answered: _answered,
              selectedAnswer: _selectedAnswer,
              speakPassed: _speakPassed,
              reviewingMistakes: _reviewingMistakes,
              isCorrect:
                  _answered && _selectedAnswer == _step.correctAnswerIndex,
              showHint: _showHint,
              onCheck: _onCheck,
              onContinue: _nextStep,
              onHint: () => setState(() => _showHint = true),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepContent() {
    switch (_step.type) {
      case LessonStepType.audio:
        return _AudioStep(step: _step);
      case LessonStepType.text:
        return _TextStep(step: _step);
      case LessonStepType.question:
        return _QuestionStep(
          step: _step,
          selectedAnswer: _selectedAnswer,
          answered: _answered,
          onSelect: _answered
              ? null
              : (i) {
                  HapticsService.tap();
                  setState(() => _selectedAnswer = i);
                },
          showHint: _showHint,
        );
      case LessonStepType.speak:
        return _SpeakStep(
          step: _step,
          onVerified: (passed) {
            if (passed) {
              HapticsService.speechPassed();
            } else {
              HapticsService.speechFailed();
            }
            setState(() => _speakPassed = passed);
          },
        );
    }
  }

  void _showExitDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Выйти из урока?',
            style:
                TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
        content: const Text('Прогресс этого урока не сохранится',
            style: TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Остаться',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    color: AppColors.pistachio,
                    fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Выйти',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    color: AppColors.error,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final double progress;
  final int hearts;
  final bool isPremium;
  final VoidCallback onClose;

  const _TopBar(
      {required this.progress,
      required this.hearts,
      required this.isPremium,
      required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          GestureDetector(
            onTap: onClose,
            child: const Icon(Icons.close_rounded,
                size: 28, color: AppColors.textGrey),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 12,
                backgroundColor: AppColors.pistachioLight,
                valueColor:
                    const AlwaysStoppedAnimation<Color>(AppColors.pistachio),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Row(
            children: isPremium
                ? [
                    const Icon(Icons.all_inclusive_rounded,
                        size: 22, color: AppColors.pistachio)
                  ]
                : List.generate(
                    5,
                    (i) => Padding(
                          padding: const EdgeInsets.only(left: 2),
                          child: Icon(
                              i < hearts
                                  ? Icons.favorite
                                  : Icons.favorite_border,
                              color: i < hearts
                                  ? AppColors.error
                                  : AppColors.border,
                              size: 20),
                        )),
          ),
        ],
      ),
    );
  }
}

class _AudioStep extends StatefulWidget {
  final LessonStep step;
  const _AudioStep({required this.step});

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
    if (_speaking) {
      await _tts.stop();
      await _audioPlayer.stop();
      if (mounted) setState(() => _speaking = false);
      return;
    }

    final ayahNumber = widget.step.quranGlobalAyahNumber;
    if (ayahNumber != null) {
      await _playQuranAyah(ayahNumber);
      return;
    }

    final text = widget.step.arabicText;
    if (text == null || text.isEmpty) return;
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
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Озвучивание недоступно на этом устройстве.'),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  Future<void> _playQuranAyah(int ayahNumber) async {
    final sources = [
      '${BackendService.apiBaseUrl}/api/muslingo/quran/audio/$ayahNumber',
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$ayahNumber.mp3',
    ];

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
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Не удалось загрузить аудио аята $ayahNumber. $lastError',
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  void dispose() {
    _tts.stop();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Слушай и запоминай',
            style: TextStyle(
                fontFamily: 'Nunito', fontSize: 16, color: AppColors.textGrey)),
        const SizedBox(height: 16),
        Semantics(
          button: true,
          label: _speaking ? 'Остановить озвучивание' : 'Прослушать фразу',
          child: Listener(
            behavior: HitTestBehavior.opaque,
            onPointerDown: (_) => _toggleSpeech(),
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _played ? AppColors.pistachio : AppColors.pistachioLight,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: AppColors.pistachio.withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Icon(
                  _played
                      ? (_speaking ? Icons.stop_rounded : Icons.replay_rounded)
                      : Icons.play_circle_fill_rounded,
                  color: _played ? Colors.white : AppColors.pistachio,
                  size: 44),
            ),
          ),
        ),
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.pistachioLight.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.pistachioLight),
          ),
          child: Column(
            children: [
              if (widget.step.arabicText != null)
                Text(widget.step.arabicText!,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 28,
                        height: 1.6,
                        color: AppColors.textDark)),
              if (widget.step.transliteration != null) ...[
                const SizedBox(height: 8),
                Text(widget.step.transliteration!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        color: AppColors.textGrey,
                        fontStyle: FontStyle.italic)),
              ],
              if (widget.step.russianText != null) ...[
                const SizedBox(height: 10),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 10),
                Text(widget.step.russianText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600)),
              ],
            ],
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
    return Column(
      children: [
        const Text('Изучи эту фразу',
            style: TextStyle(
                fontFamily: 'Nunito', fontSize: 16, color: AppColors.textGrey)),
        const SizedBox(height: 16),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.border, width: 1.5),
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 2))
            ],
          ),
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
                      fontSize: 26,
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
                const SizedBox(height: 8),
                Text(step.transliteration!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textGrey,
                        fontStyle: FontStyle.italic)),
              ],
              if (step.russianText != null) ...[
                const SizedBox(height: 12),
                Container(height: 1, color: AppColors.border),
                const SizedBox(height: 12),
                Text(step.russianText!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        color: AppColors.textDark,
                        height: 1.5)),
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
        return Container(
          constraints: const BoxConstraints(minWidth: 58),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.skyLight.withValues(alpha: 0.45),
            borderRadius: BorderRadius.circular(8),
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
                  fontSize: 30,
                  height: 1.1,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 4),
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

class _QuestionStep extends StatelessWidget {
  final LessonStep step;
  final int? selectedAnswer;
  final bool answered;
  final void Function(int)? onSelect;
  final bool showHint;

  const _QuestionStep(
      {required this.step,
      this.selectedAnswer,
      required this.answered,
      this.onSelect,
      required this.showHint});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(step.question ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
        const SizedBox(height: 20),
        if (showHint && step.correctAnswerIndex != null)
          Container(
            padding: const EdgeInsets.all(12),
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: AppColors.goldLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
            ),
            child: Row(
              children: [
                const Icon(Icons.lightbulb_rounded,
                    color: AppColors.gold, size: 20),
                const SizedBox(width: 8),
                Expanded(
                    child: Text(
                        'Правильный ответ: ${step.answers![step.correctAnswerIndex!]}',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark))),
              ],
            ),
          ),
        ...List.generate(step.answers?.length ?? 0, (i) {
          Color bg = AppColors.white;
          Color border = AppColors.border;
          Color text = AppColors.textDark;

          if (selectedAnswer == i) {
            if (answered) {
              if (i == step.correctAnswerIndex) {
                bg = AppColors.success.withValues(alpha: 0.12);
                border = AppColors.success;
                text = AppColors.pistachioDark;
              } else {
                bg = AppColors.error.withValues(alpha: 0.1);
                border = AppColors.error;
                text = AppColors.error;
              }
            } else {
              bg = AppColors.pistachioLight;
              border = AppColors.pistachio;
            }
          } else if (answered && i == step.correctAnswerIndex) {
            bg = AppColors.success.withValues(alpha: 0.1);
            border = AppColors.success;
          }

          return GestureDetector(
            onTap: () => onSelect?.call(i),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
              decoration: BoxDecoration(
                color: bg,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: border, width: 2),
              ),
              child: Row(
                children: [
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: border.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: border, width: 1.5),
                    ),
                    child: Center(
                        child: Text(String.fromCharCode(65 + i),
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: border))),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(step.answers![i],
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: text)),
                  ),
                  if (answered && i == step.correctAnswerIndex)
                    const Icon(Icons.check_circle_rounded,
                        color: AppColors.success, size: 24),
                  if (answered &&
                      selectedAnswer == i &&
                      i != step.correctAnswerIndex)
                    const Icon(Icons.cancel_rounded,
                        color: AppColors.error, size: 24),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }
}

class _SpeakStep extends StatefulWidget {
  final LessonStep step;
  final ValueChanged<bool> onVerified;

  const _SpeakStep({required this.step, required this.onVerified});

  @override
  State<_SpeakStep> createState() => _SpeakStepState();
}

class _SpeakStepState extends State<_SpeakStep> {
  final SpeechToText _speech = SpeechToText();
  late final SpeechEvaluationService _speechEvaluation;
  bool _recording = false;
  bool _done = false;
  bool _passed = false;
  bool _initializing = false;
  bool _evaluating = false;
  String _recognizedWords = '';
  String? _speechError;
  double _score = 0;
  bool _fallbackUsed = false;
  Uint8List? _recordedAudio;

  @override
  void initState() {
    super.initState();
    _speechEvaluation = SpeechEvaluationService();
  }

  Future<void> _toggleListening() async {
    if (_recording) {
      await _speech.stop();
      _recordedAudio = await _speechEvaluation.stop();
      if (mounted) setState(() => _recording = false);
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
      _recordedAudio = null;
    });
    widget.onVerified(false);
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
          setState(() {
            _recording = false;
            _speechError = 'Не удалось распознать речь. Попробуй ещё раз.';
          });
        },
      );
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _initializing = false;
        _recording = false;
        _speechError = 'Микрофон недоступен. Разреши доступ и попробуй ещё раз.';
      });
      return;
    }
    if (!mounted) return;
    if (!available) {
      await _speechEvaluation.cancel();
      setState(() {
        _initializing = false;
        _speechError = 'Распознавание речи недоступно на этом устройстве.';
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

  void _onSpeechResult(SpeechRecognitionResult result) {
    if (!mounted) return;
    setState(() => _recognizedWords = result.recognizedWords);
    if (result.finalResult) _gradeSpeech();
  }

  Future<void> _gradeSpeech() async {
    if (!mounted) return;
    if (_evaluating) return;
    setState(() => _evaluating = true);
    _recordedAudio ??= await _speechEvaluation.stop();
    final result = await _speechEvaluation.evaluate(
      step: widget.step,
      transcript: _recognizedWords,
      audioBytes: _recordedAudio,
    );
    if (!mounted) return;
    setState(() {
      _recording = false;
      _done = _recognizedWords.trim().isNotEmpty;
      _evaluating = false;
      _score = result.score / 100;
      _passed = result.passed;
      _fallbackUsed = result.engine == SpeechEvaluationEngine.localFallback ||
          result.fallbackUsed;
      _speechError = result.passed ? null : result.feedbackText;
    });
    widget.onVerified(result.passed);
  }

  @override
  void dispose() {
    _speech.cancel();
    _speechEvaluation.cancel();
    _speechEvaluation.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text('Повтори вслух',
            style: TextStyle(
                fontFamily: 'Nunito', fontSize: 16, color: AppColors.textGrey)),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.pistachioLight.withValues(alpha: 0.4),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            children: [
              if (widget.step.arabicText != null)
                Text(widget.step.arabicText!,
                    textAlign: TextAlign.center,
                    textDirection: TextDirection.rtl,
                    style: const TextStyle(
                        fontFamily: 'Amiri',
                        fontSize: 26,
                        height: 1.8,
                        color: AppColors.textDark)),
              if (widget.step.transliteration != null)
                Text(widget.step.transliteration!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textGrey,
                        fontStyle: FontStyle.italic)),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Semantics(
          button: true,
          label: _recording ? 'Остановить запись' : 'Начать распознавание речи',
          child: GestureDetector(
            onTap: _initializing || _evaluating ? null : _toggleListening,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: _recording
                    ? AppColors.error
                    : (_passed
                        ? AppColors.pistachio
                        : AppColors.pistachioLight),
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color:
                          (_recording ? AppColors.error : AppColors.pistachio)
                              .withValues(alpha: 0.3),
                      blurRadius: 16,
                      offset: const Offset(0, 4))
                ],
              ),
              child: Icon(
                _initializing
                    ? Icons.hourglass_top_rounded
                    : _evaluating
                        ? Icons.hourglass_bottom_rounded
                    : _recording
                        ? Icons.stop_rounded
                        : (_passed ? Icons.check_rounded : Icons.mic_rounded),
                color:
                    _recording || _passed ? Colors.white : AppColors.pistachio,
                size: 40,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _initializing
              ? 'Подключаю микрофон...'
              : _evaluating
                  ? 'Проверяю произношение...'
              : _recording
                  ? 'Говори...'
                  : (_passed
                      ? 'Произношение принято'
                      : (_done ? 'Нужно повторить' : 'Нажми и говори')),
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: _recording
                ? AppColors.error
                : (_passed ? AppColors.pistachio : AppColors.textGrey),
          ),
        ),
        if (_recognizedWords.isNotEmpty) ...[
          const SizedBox(height: 8),
          Text(
            'Распознано: $_recognizedWords',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Совпадение: ${(_score * 100).round()}%',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: _passed ? AppColors.pistachio : AppColors.error,
            ),
          ),
        ],
        if (_fallbackUsed) ...[
          const SizedBox(height: 6),
          const Text(
            'Упрощенная проверка на устройстве',
            textAlign: TextAlign.center,
            style: TextStyle(
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
      ],
    );
  }
}

class _BottomBar extends StatelessWidget {
  final LessonStep step;
  final bool answered;
  final int? selectedAnswer;
  final bool speakPassed;
  final bool reviewingMistakes;
  final bool isCorrect;
  final bool showHint;
  final VoidCallback onCheck;
  final VoidCallback onContinue;
  final VoidCallback onHint;

  const _BottomBar({
    required this.step,
    required this.answered,
    required this.selectedAnswer,
    required this.speakPassed,
    required this.reviewingMistakes,
    required this.isCorrect,
    required this.showHint,
    required this.onCheck,
    required this.onContinue,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = AppColors.background;
    if (answered && isCorrect) {
      bgColor = AppColors.success.withValues(alpha: 0.08);
    }
    if (answered && !isCorrect) {
      bgColor = AppColors.error.withValues(alpha: 0.07);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: bgColor,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (answered) ...[
            Row(
              children: [
                Icon(
                    isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: isCorrect ? AppColors.success : AppColors.error,
                    size: 28),
                const SizedBox(width: 8),
                Text(
                  isCorrect ? 'Правильно!' : 'Неправильно. Попробуй ещё раз!',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: isCorrect ? AppColors.success : AppColors.error,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              if (!answered &&
                  !showHint &&
                  step.type == LessonStepType.question)
                Expanded(
                  flex: 1,
                  child: CustomButton(
                    text: '',
                    icon: Icons.lightbulb_rounded,
                    isOutlined: true,
                    onPressed: onHint,
                    height: 52,
                  ),
                ),
              if (!answered &&
                  !showHint &&
                  step.type == LessonStepType.question)
                const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: CustomButton(
                  text: answered
                      ? (reviewingMistakes ? 'Закрепить' : 'Продолжить')
                      : _checkLabel,
                  onPressed: answered
                      ? onContinue
                      : (step.type == LessonStepType.question &&
                              selectedAnswer == null
                          ? null
                          : (step.type == LessonStepType.speak && !speakPassed
                              ? null
                              : onCheck)),
                  color: answered
                      ? (isCorrect ? AppColors.success : AppColors.error)
                      : AppColors.pistachio,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String get _checkLabel {
    switch (step.type) {
      case LessonStepType.audio:
        return 'Продолжить';
      case LessonStepType.text:
        return 'Понятно!';
      case LessonStepType.question:
        return 'Проверить';
      case LessonStepType.speak:
        return 'Продолжить';
    }
  }
}
