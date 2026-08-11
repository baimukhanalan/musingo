import 'dart:async';
import 'dart:math';
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
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_label.dart';

/// Small-caps метка типа шага для премиум-заголовка (экран 1c). Только визуал —
/// строится из типа шага, не из демо-данных.
String _stepTypeLabel(LessonStep step, AppState state) {
  switch (step.type) {
    case LessonStepType.audio:
      return state.tr(ru: 'Новый аят', kk: 'Жаңа аят', en: 'New ayah');
    case LessonStepType.text:
      return state.tr(
          ru: 'Изучаем фразу',
          kk: 'Тіркесті үйренеміз',
          en: 'Learn the phrase');
    case LessonStepType.question:
      return state.tr(ru: 'Вопрос', kk: 'Сұрақ', en: 'Question');
    case LessonStepType.matching:
      return state.tr(
          ru: 'Соедини пары',
          kk: 'Жұптарды сәйкестендір',
          en: 'Match the pairs');
    case LessonStepType.speak:
      return state.tr(ru: 'Произношение', kk: 'Айтылым', en: 'Pronunciation');
    case LessonStepType.wordOrder:
      return state.tr(
          ru: 'Собери фразу', kk: 'Тіркесті құрастыр', en: 'Build the phrase');
    case LessonStepType.listenChoice:
      return state.tr(ru: 'Аудирование', kk: 'Тыңдалым', en: 'Listening');
  }
}

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

  /// Итог последней проверки — общий для всех оцениваемых типов шага
  /// (question / listenChoice / wordOrder). Раньше нижняя панель выводила
  /// правильность только из `_selectedAnswer`, что для wordOrder неприменимо.
  bool _lastAnswerCorrect = false;

  /// Слова, уже выставленные учеником в wordOrder-шаге: индексы в банке слов.
  List<int> _orderPicks = const [];
  bool _showHint = false;
  int _errors = 0;
  bool _speakPassed = false;
  bool _matchingComplete = false;
  bool _reviewingMistakes = false;
  final List<LessonStep> _mistakeSteps = [];
  final Set<String> _weakStepIds = {};
  List<LessonStep> _reviewSteps = [];

  List<LessonStep> get _activeSteps =>
      _reviewingMistakes ? _reviewSteps : widget.lesson.steps;
  LessonStep get _step => _activeSteps[_stepIndex];
  double get _progress => (_stepIndex) / _activeSteps.length;

  /// speak-шаг стартует «незачтённым» только если это действительно speak.
  bool _isSpeakPassed(LessonStep step) => step.type != LessonStepType.speak;

  /// matching-шаг считается пройденным сразу, если пар нет (пустой matchPairs):
  /// иначе onCompleted никогда не вызовется и «Продолжить» залочится (L2).
  bool _isMatchingComplete(LessonStep step) =>
      step.type != LessonStepType.matching || step.matchPairs.isEmpty;

  /// Гейт wordOrder: продолжить можно, когда выставлены все слова ответа.
  /// Шаг без orderTokens (данные неполны) не должен блокировать урок — как и
  /// пустой matching.
  bool get _orderComplete {
    if (_step.type != LessonStepType.wordOrder) return true;
    if (_step.orderTokens.isEmpty) return true;
    return _orderPicks.length == _step.orderTokens.length;
  }

  @override
  void initState() {
    super.initState();
    // Инициализируем гейты для стартового шага: если урок начинается с speak
    // или пустого matching, кнопка «Продолжить» не должна быть залочена.
    _speakPassed = _isSpeakPassed(_step);
    _matchingComplete = _isMatchingComplete(_step);
    _orderPicks = const [];
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AppState>().beginLessonAttempt(widget.lesson.id);
      }
    });
  }

  void _onCheck() {
    switch (_step.type) {
      case LessonStepType.question:
      case LessonStepType.listenChoice:
        if (_selectedAnswer == null) return;
        _registerAnswer(_selectedAnswer == _step.correctAnswerIndex);
      case LessonStepType.wordOrder:
        if (!_orderComplete) return;
        _registerAnswer(_builtOrderAnswer() == _step.orderedAnswer);
      case LessonStepType.audio:
      case LessonStepType.text:
      case LessonStepType.matching:
      case LessonStepType.speak:
        _nextStep();
    }
  }

  /// Фраза, собранная учеником в wordOrder-шаге (слова через пробел).
  String _builtOrderAnswer() {
    final bank = wordOrderBank(_step);
    return _orderPicks.map((index) => bank[index]).join(' ');
  }

  /// Общая обработка результата проверки: гаптика, настроение кота, списание
  /// жизни и попадание шага в разбор ошибок.
  void _registerAnswer(bool isCorrect) {
    if (isCorrect) {
      HapticsService.correct();
    } else {
      HapticsService.wrong();
    }
    setState(() {
      _answered = true;
      _lastAnswerCorrect = isCorrect;
      if (isCorrect) {
        _catMood = CatMood.success;
      } else {
        _catMood = CatMood.error;
        _errors++;
        if (!_mistakeSteps.contains(_step)) _mistakeSteps.add(_step);
        _weakStepIds.add(_stepId(_step));
        context.read<AppState>().loseHeart();
      }
    });
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
          _lastAnswerCorrect = false;
          _showHint = false;
          _speakPassed = _isSpeakPassed(_step);
          _matchingComplete = _isMatchingComplete(_step);
          _orderPicks = const [];
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
      _lastAnswerCorrect = false;
      _showHint = false;
      _speakPassed = _isSpeakPassed(_step);
      _matchingComplete = _isMatchingComplete(_step);
      _orderPicks = const [];
      _catMood = _stepIndex == 0 ? CatMood.greet : CatMood.support;
    });
  }

  Future<void> _finishLesson() async {
    final state = context.read<AppState>();
    final isPremium = state.user?.isPremium ?? false;
    Map<String, dynamic> result;
    try {
      result = await state.completeLesson(
        widget.lesson.id,
        _errors,
        weakStepIds: _weakStepIds,
      );
    } catch (_) {
      // Сеть/сервер отвалились в конце урока. Раньше исключение было
      // необработанным: экран замирал на последнем шаге, урок терялся.
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.tr(
              ru: 'Не удалось сохранить урок — проверь соединение. Попробуй ещё раз.',
              kk: 'Сабақты сақтау мүмкін болмады — байланысты тексеріп, қайта көр.',
              en: 'Could not save the lesson — check your connection and try again.',
            ),
          ),
        ),
      );
      return;
    }
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/lesson_review', arguments: {
        'lesson': widget.lesson,
        'xpEarned': result['xpEarned'] ?? 25,
        'streakBonus': result['streakBonus'] ?? 0,
        // Премиум жизни не теряет — не показываем ему списание.
        'heartsLost': isPremium ? 0 : _errors,
        'newStreak': result['newStreak'] ?? 0,
        'energyEarned': result['energyEarned'] ?? 0,
        'weakKnowledgeCount': result['weakKnowledgeCount'] ?? 0,
        'nextReviewAt': result['nextReviewAt'],
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final hearts = state.user?.hearts ?? 5;
    final isPremium = state.user?.isPremium ?? false;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
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
                      const SizedBox(height: 8),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 400),
                        child: CatCharacter(
                            key: ValueKey(_catMood), mood: _catMood, size: 132),
                      ),
                      const SizedBox(height: 12),
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
                matchingComplete: _matchingComplete,
                orderComplete: _orderComplete,
                reviewingMistakes: _reviewingMistakes,
                isCorrect: _answered && _lastAnswerCorrect,
                showHint: _showHint,
                onCheck: _onCheck,
                onContinue: _nextStep,
                onHint: () => setState(() => _showHint = true),
              ),
            ],
          ),
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
      case LessonStepType.listenChoice:
        return _ListenChoiceStep(
          // Ключ на индекс шага: у каждого аудирования свой проигрыватель и
          // счётчик прослушиваний — State не должен протекать на соседний шаг.
          key: ValueKey(
              'listen_${widget.lesson.id}_${_stepIndex}_$_reviewingMistakes'),
          step: _step,
          selectedAnswer: _selectedAnswer,
          answered: _answered,
          onSelect: _answered
              ? null
              : (i) {
                  HapticsService.tap();
                  setState(() => _selectedAnswer = i);
                },
        );
      case LessonStepType.wordOrder:
        return _WordOrderStep(
          step: _step,
          picks: _orderPicks,
          answered: _answered,
          isCorrect: _lastAnswerCorrect,
          onPick: _answered
              ? null
              : (bankIndex) {
                  HapticsService.tap();
                  setState(() => _orderPicks = [..._orderPicks, bankIndex]);
                },
          onUnpick: _answered
              ? null
              : (position) {
                  HapticsService.tap();
                  setState(
                      () => _orderPicks = [..._orderPicks]..removeAt(position));
                },
        );
      case LessonStepType.matching:
        return _MatchingStep(
          key:
              ValueKey('${widget.lesson.id}_${_stepIndex}_$_reviewingMistakes'),
          step: _step,
          onWrong: () {
            HapticsService.wrong();
            setState(() {
              _catMood = CatMood.error;
              _errors++;
              if (!_mistakeSteps.contains(_step)) _mistakeSteps.add(_step);
              _weakStepIds.add(_stepId(_step));
            });
            context.read<AppState>().loseHeart();
          },
          onCompleted: () {
            HapticsService.correct();
            setState(() {
              _matchingComplete = true;
              _catMood = CatMood.success;
            });
          },
        );
      case LessonStepType.speak:
        return _SpeakStep(
          // Ключ на индекс шага: несколько speak-шагов подряд (напр. 4 подряд в
          // q_review_5_surahs) не должны переиспользовать State друг друга —
          // иначе прослушанный образец, счётчик попыток и статус «принято»
          // протекли бы на следующий шаг.
          key: ValueKey(
              'speak_${widget.lesson.id}_${_stepIndex}_$_reviewingMistakes'),
          step: _step,
          onVerified: (passed) {
            if (passed) {
              HapticsService.speechPassed();
            } else {
              HapticsService.speechFailed();
            }
            setState(() => _speakPassed = passed);
            if (!passed) _weakStepIds.add(_stepId(_step));
          },
          // (H1-а) Распознавание речи недоступно на устройстве — это вина среды,
          // не пользователя: разрешаем мягкий проход (гейт открыт), НЕ засчитывая
          // ошибку и не добавляя шаг в разбор.
          onUnavailable: () {
            setState(() {
              _speakPassed = true;
              _catMood = CatMood.support;
            });
          },
          // (H1-б) Пользователь не смог набрать passScore и жмёт «Пропустить»:
          // открываем гейт, но засчитываем ошибку в разбор (errors++, шаг в
          // список ошибок и слабых), чтобы прогресс не блокировался.
          onSkip: () {
            HapticsService.speechFailed();
            setState(() {
              _speakPassed = true;
              _errors++;
              if (!_mistakeSteps.contains(_step)) _mistakeSteps.add(_step);
              _weakStepIds.add(_stepId(_step));
              _catMood = CatMood.support;
            });
          },
        );
    }
  }

  String _stepId(LessonStep step) {
    final index = widget.lesson.steps.indexOf(step);
    return step.id ?? '${widget.lesson.id}:$index';
  }

  void _showExitDialog(BuildContext context) {
    final state = context.read<AppState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
            state.tr(
                ru: 'Выйти из урока?',
                kk: 'Сабақтан шығасың ба?',
                en: 'Exit the lesson?'),
            style: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
        content: Text(
            state.tr(
                ru: 'Прогресс этого урока не сохранится',
                kk: 'Бұл сабақтың прогресі сақталмайды',
                en: 'This lesson\'s progress will not be saved'),
            style: const TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(state.tr(ru: 'Остаться', kk: 'Қалу', en: 'Stay'),
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    color: AppColors.pistachio,
                    fontWeight: FontWeight.w700)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final navigator = Navigator.of(context);
              if (navigator.canPop()) {
                navigator.pop();
              } else {
                navigator.pushReplacementNamed('/home');
              }
            },
            child: Text(state.tr(ru: 'Выйти', kk: 'Шығу', en: 'Exit'),
                style: const TextStyle(
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
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: Row(
        children: [
          // ✕ закрыть — в мягком круге в тон фона.
          Semantics(
            button: true,
            label: state.tr(
                ru: 'Закрыть урок', kk: 'Сабақты жабу', en: 'Close lesson'),
            child: GestureDetector(
              onTap: onClose,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.7),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.navyDark.withValues(alpha: 0.06),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(Icons.close_rounded,
                    size: 22, color: AppColors.textGrey),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Тонкий прогресс-бар шага — пилюля.
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(99),
              child: TweenAnimationBuilder<double>(
                tween: Tween(begin: 0, end: progress.clamp(0.0, 1.0)),
                duration: const Duration(milliseconds: 320),
                curve: Curves.easeOut,
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 9,
                  backgroundColor: AppColors.border.withValues(alpha: 0.6),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.sky),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          // Счётчик жизней справа (или ∞ для премиума).
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.white.withValues(alpha: 0.7),
              borderRadius: BorderRadius.circular(99),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyDark.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: isPremium
                ? const Icon(Icons.all_inclusive_rounded,
                    size: 20, color: AppColors.pistachio)
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.favorite_rounded,
                          size: 18, color: AppColors.error),
                      const SizedBox(width: 5),
                      Text(
                        '$hearts',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navyDark,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}

/// Источники аудио аята по порядку попыток: свой бэкенд (если настроен),
/// затем публичный CDN. Общие для «Нового аята» и шага аудирования.
List<String> quranAudioSources(int ayahNumber) => <String>[
      if (BackendService.hasConfiguredApiUrl)
        '${BackendService.apiBaseUrl}/api/muslingo/quran/audio/$ayahNumber',
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$ayahNumber.mp3',
    ];

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
    _tts.stop();
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
                ru: 'Изучи и запомни эту фразу',
                kk: 'Осы тіркесті үйреніп, есте сақта',
                en: 'Study and memorize this phrase'),
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
    final state = context.watch<AppState>();
    final displayOrder = _displayOrder;
    return Column(
      children: [
        SectionLabel(text: _stepTypeLabel(step, state)),
        const SizedBox(height: 10),
        Text(step.question ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark)),
        const SizedBox(height: 20),
        if (showHint) _buildHint(state),
        // Варианты показываются в детерминированно перемешанном порядке
        // (см. _displayOrder): правильный ответ не «прилипает» к позиции 0,
        // поэтому стратегия «жми первый» больше не проходит. Оригинальный
        // индекс варианта (i) сохраняется для onSelect и всех сверок с
        // correctAnswerIndex, так что подсчёт ошибок и разбор не меняются.
        ...List.generate(displayOrder.length, (displayPos) {
          final i = displayOrder[displayPos];
          return _AnswerOptionCard(
            text: step.answers![i],
            letter: String.fromCharCode(65 + displayPos),
            selected: selectedAnswer == i,
            answered: answered,
            isCorrectOption: i == step.correctAnswerIndex,
            onTap: () => onSelect?.call(i),
          );
        }),
      ],
    );
  }

  /// Порядок показа вариантов ответа. Детерминированно перемешан по seed от
  /// содержимого вопроса: стабилен между ре-рендерами одного шага (порядок не
  /// «прыгает»), но у каждого вопроса свой, поэтому правильный ответ не всегда
  /// на позиции 0. Возвращает исходные индексы вариантов в порядке показа.
  List<int> get _displayOrder =>
      questionAnswerOrder(step.answers?.length ?? 0, _shuffleSeed);

  /// Стабильный seed из содержимого вопроса: одинаков между перестроениями
  /// одного шага, но различается для разных вопросов.
  int get _shuffleSeed {
    final buffer = StringBuffer(step.id ?? step.question ?? 'question');
    final answers = step.answers ?? const <String>[];
    for (final answer in answers) {
      buffer
        ..write('|')
        ..write(answer);
    }
    return buffer.toString().hashCode;
  }

  /// Подсказка НЕ раскрывает правильный вариант: даёт контекст/значение
  /// (explanation → транслитерация → перевод → общий намёк), чтобы вопрос не
  /// становился тривиальным. Использование подсказки ничего не «ломает» в
  /// подсчёте ошибок — она просто помогает вспомнить материал.
  Widget _buildHint(AppState state) {
    return Container(
      padding: const EdgeInsets.all(14),
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.lightbulb_rounded, color: AppColors.gold, size: 20),
          const SizedBox(width: 10),
          Expanded(
              child: Text(_hintText(state),
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark))),
        ],
      ),
    );
  }

  String _hintText(AppState state) {
    final explanation = step.explanation?.trim();
    if (explanation != null && explanation.isNotEmpty) return explanation;
    final translit = step.transliteration?.trim();
    if (translit != null && translit.isNotEmpty) {
      return state.tr(
        ru: 'Вспомни звучание: $translit',
        kk: 'Дыбысталуын есіңе түсір: $translit',
        en: 'Recall the sound: $translit',
      );
    }
    final russian = step.russianText?.trim();
    if (russian != null && russian.isNotEmpty) {
      return state.tr(
        ru: 'Подумай о значении: $russian',
        kk: 'Мағынасын ойлан: $russian',
        en: 'Think about the meaning: $russian',
      );
    }
    return state.tr(
      ru: 'Подумай о смысле и вспомни материал урока.',
      kk: 'Мағынасын ойлап, сабақ материалын есіңе түсір.',
      en: 'Think about the meaning and recall the lesson material.',
    );
  }
}

/// Карточка варианта ответа. Общая для обычного вопроса и аудирования —
/// цвета, буква-маркер и иконки итога здесь одни и те же.
class _AnswerOptionCard extends StatelessWidget {
  final String text;
  final String letter;
  final bool selected;
  final bool answered;
  final bool isCorrectOption;
  final VoidCallback? onTap;

  const _AnswerOptionCard({
    required this.text,
    required this.letter,
    required this.selected,
    required this.answered,
    required this.isCorrectOption,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bg = AppColors.white;
    Color border = AppColors.border;
    Color textColor = AppColors.textDark;

    if (selected) {
      if (answered) {
        if (isCorrectOption) {
          bg = AppColors.success.withValues(alpha: 0.12);
          border = AppColors.success;
          textColor = AppColors.pistachioDark;
        } else {
          bg = AppColors.error.withValues(alpha: 0.1);
          border = AppColors.error;
          textColor = AppColors.error;
        }
      } else {
        bg = AppColors.pistachioLight;
        border = AppColors.pistachio;
      }
    } else if (answered && isCorrectOption) {
      bg = AppColors.success.withValues(alpha: 0.1);
      border = AppColors.success;
    }

    final bool highlighted = selected || (answered && isCorrectOption);
    final bool hasArabic = containsArabicText(text);

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: 2),
          boxShadow: highlighted
              ? null
              : [
                  BoxShadow(
                    color: AppColors.navyDark.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ],
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
                  child: Text(letter,
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: border))),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(text,
                  textDirection: hasArabic ? TextDirection.rtl : null,
                  style: TextStyle(
                      fontFamily: hasArabic ? 'Amiri' : 'Nunito',
                      fontSize: hasArabic ? 22 : 17,
                      fontWeight: FontWeight.w700,
                      color: textColor)),
            ),
            if (answered && isCorrectOption)
              const Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 24),
            if (answered && selected && !isCorrectOption)
              const Icon(Icons.cancel_rounded,
                  color: AppColors.error, size: 24),
          ],
        ),
      ),
    );
  }
}

/// Есть ли в строке арабские буквы — от этого зависят шрифт (Amiri) и
/// направление письма в карточках, чипах и банке слов.
bool containsArabicText(String value) {
  for (final rune in value.runes) {
    if (rune >= 0x0600 && rune <= 0x06ff) return true;
  }
  return false;
}

/// Банк слов для wordOrder-шага в порядке показа.
///
/// Правильные слова и дистракторы перемешаны детерминированно (seed от
/// содержимого шага — порядок стабилен между ре-рендерами), но заведомо не
/// совпадают с эталонной последовательностью: иначе задание решалось бы
/// нажатием слов слева направо без знания аята.
@visibleForTesting
List<String> wordOrderBank(LessonStep step) {
  final bank = step.wordBank;
  if (bank.length < 2) return bank;

  final buffer = StringBuffer(step.id ?? step.question ?? 'wordOrder');
  for (final token in bank) {
    buffer
      ..write('|')
      ..write(token);
  }
  final seed = buffer.toString().hashCode;

  for (var attempt = 0; attempt < 8; attempt++) {
    final shuffled = List<String>.of(bank)
      ..shuffle(Random(Object.hash(seed, attempt)));
    if (shuffled.join(' ') != step.orderedAnswer) return shuffled;
  }
  return List<String>.of(bank.reversed);
}

/// Детерминированная перестановка вариантов ответа вопроса.
///
/// Возвращает исходные индексы вариантов в порядке показа. Перемешивание
/// детерминировано по [seed] (стабильно между ре-рендерами одного шага), но у
/// каждого вопроса свой seed — правильный ответ не «прилипает» к позиции 0.
@visibleForTesting
List<int> questionAnswerOrder(int count, int seed) {
  final order = List<int>.generate(count, (index) => index);
  if (count < 2) return order;
  order.shuffle(Random(seed));
  return order;
}

/// Детерминированная перестановка правой колонки matching-задания.
///
/// Возвращает порядок индексов пар для показа ответов: правая колонка реально
/// перемешана (не сдвинута на один элемент, как было раньше), стабильна в
/// пределах одного показа (за счёт [seed] от содержимого шага) и без
/// тривиальных совпадений — ответ i не стоит напротив своего prompt i, иначе
/// задание решалось бы без знания. Соответствие пар сохраняется: перемешивается
/// только порядок отображения, а не связь prompt↔answer.
@visibleForTesting
List<int> matchingAnswerOrder(int count, int seed) {
  final order = List<int>.generate(count, (index) => index);
  if (count < 2) return order;
  for (var attempt = 0; attempt < 8; attempt++) {
    // Мешаем seed с номером попытки хешем, а не сложением: иначе соседние
    // seed'ы разных шагов могли бы дать одинаковую перестановку через retry.
    final shuffled = List<int>.of(order)
      ..shuffle(Random(Object.hash(seed, attempt)));
    var hasFixedPoint = false;
    for (var i = 0; i < count; i++) {
      if (shuffled[i] == i) {
        hasFixedPoint = true;
        break;
      }
    }
    if (!hasFixedPoint) return shuffled;
  }
  // Крайне маловероятный фолбэк: циклический сдвиг — гарантированная
  // перестановка без совпадений (для count >= 2).
  return [for (var i = 0; i < count; i++) (i + 1) % count];
}

class _MatchingStep extends StatefulWidget {
  final LessonStep step;
  final VoidCallback onWrong;
  final VoidCallback onCompleted;

  const _MatchingStep({
    super.key,
    required this.step,
    required this.onWrong,
    required this.onCompleted,
  });

  @override
  State<_MatchingStep> createState() => _MatchingStepState();
}

class _MatchingStepState extends State<_MatchingStep> {
  int? _selectedPrompt;
  int? _selectedAnswer;
  final Set<int> _matchedPrompts = {};

  List<LessonMatchPair> get _pairs => widget.step.matchPairs;

  /// Порядок отображения правой колонки (ответов). Реально перемешан, но
  /// детерминирован в пределах одного показа шага — seed берётся из содержимого
  /// шага, поэтому на каждый rebuild порядок не «прыгает».
  List<int> get _answerOrder =>
      matchingAnswerOrder(_pairs.length, _shuffleSeed);

  /// Стабильный seed от содержимого шага: одинаков между перестроениями одного
  /// и того же шага, но различается для разных шагов.
  int get _shuffleSeed {
    final buffer =
        StringBuffer(widget.step.id ?? widget.step.question ?? 'matching');
    for (final pair in _pairs) {
      buffer
        ..write('|')
        ..write(pair.prompt)
        ..write('>')
        ..write(pair.answer);
    }
    return buffer.toString().hashCode;
  }

  void _selectPrompt(int index) {
    if (_matchedPrompts.contains(index)) return;
    setState(() => _selectedPrompt = index);
    _tryMatch();
  }

  void _selectAnswer(int pairIndex) {
    if (_matchedPrompts.contains(pairIndex)) return;
    setState(() => _selectedAnswer = pairIndex);
    _tryMatch();
  }

  void _tryMatch() {
    final prompt = _selectedPrompt;
    final answer = _selectedAnswer;
    if (prompt == null || answer == null) return;

    if (prompt == answer) {
      setState(() {
        _matchedPrompts.add(prompt);
        _selectedPrompt = null;
        _selectedAnswer = null;
      });
      if (_matchedPrompts.length == _pairs.length) {
        widget.onCompleted();
      } else {
        HapticsService.correct();
      }
      return;
    }

    widget.onWrong();
    setState(() {
      _selectedPrompt = null;
      _selectedAnswer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      children: [
        SectionLabel(text: _stepTypeLabel(widget.step, state)),
        const SizedBox(height: 10),
        Text(
            widget.step.question ??
                state.tr(
                    ru: 'Соедини пары по смыслу',
                    kk: 'Жұптарды мағынасына қарай сәйкестендір',
                    en: 'Match the pairs by meaning'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark)),
        if (widget.step.russianText != null) ...[
          const SizedBox(height: 8),
          Text(widget.step.russianText!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.textGrey)),
        ],
        const SizedBox(height: 18),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                children: List.generate(_pairs.length, (index) {
                  return _MatchCard(
                    text: _pairs[index].prompt,
                    selected: _selectedPrompt == index,
                    matched: _matchedPrompts.contains(index),
                    onTap: () => _selectPrompt(index),
                  );
                }),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                children: _answerOrder.map((pairIndex) {
                  return _MatchCard(
                    text: _pairs[pairIndex].answer,
                    selected: _selectedAnswer == pairIndex,
                    matched: _matchedPrompts.contains(pairIndex),
                    onTap: () => _selectAnswer(pairIndex),
                  );
                }).toList(growable: false),
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _MatchCard extends StatelessWidget {
  final String text;
  final bool selected;
  final bool matched;
  final VoidCallback onTap;

  const _MatchCard({
    required this.text,
    required this.selected,
    required this.matched,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final hasArabic = containsArabicText(text);
    final border = matched
        ? AppColors.success
        : (selected ? AppColors.pistachio : AppColors.border);
    final background = matched
        ? AppColors.success.withValues(alpha: 0.1)
        : (selected ? AppColors.pistachioLight : AppColors.white);

    return GestureDetector(
      onTap: matched ? null : onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        width: double.infinity,
        constraints: const BoxConstraints(minHeight: 62),
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: border, width: selected || matched ? 2 : 1),
          boxShadow: (selected || matched)
              ? null
              : [
                  BoxShadow(
                    color: AppColors.navyDark.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Center(
          child: Text(
            text,
            textAlign: TextAlign.center,
            textDirection: hasArabic ? TextDirection.rtl : null,
            style: TextStyle(
              fontFamily: hasArabic ? 'Amiri' : 'Nunito',
              fontSize: hasArabic ? 22 : 14,
              fontWeight: FontWeight.w800,
              color: matched ? AppColors.pistachioDark : AppColors.textDark,
            ),
          ),
        ),
      ),
    );
  }
}

/// Шаг «Собери фразу»: слова банка нажимаются в правильном порядке.
///
/// Состояние сборки живёт в _LessonScreenState (как и выбранный вариант
/// вопроса) — иначе оно терялось бы при ре-рендере и не было бы доступно
/// проверке в `_onCheck`.
class _WordOrderStep extends StatelessWidget {
  final LessonStep step;
  final List<int> picks;
  final bool answered;
  final bool isCorrect;
  final void Function(int bankIndex)? onPick;
  final void Function(int position)? onUnpick;

  const _WordOrderStep({
    required this.step,
    required this.picks,
    required this.answered,
    required this.isCorrect,
    this.onPick,
    this.onUnpick,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bank = wordOrderBank(step);
    final used = picks.toSet();
    final rtl = step.orderTokens.any(containsArabicText);

    return Column(
      children: [
        SectionLabel(text: _stepTypeLabel(step, state)),
        const SizedBox(height: 10),
        Text(
            step.question ??
                state.tr(
                    ru: 'Собери фразу в правильном порядке',
                    kk: 'Тіркесті дұрыс ретпен құрастыр',
                    en: 'Put the words in the right order'),
            textAlign: TextAlign.center,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 21,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark)),
        if (step.russianText != null) ...[
          const SizedBox(height: 8),
          Text(step.russianText!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.35,
                  color: AppColors.textGrey)),
        ],
        const SizedBox(height: 18),
        // Строка ответа: нажатие на слово возвращает его в банк.
        PremiumCard(
          child: Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 72),
            alignment: Alignment.center,
            child: picks.isEmpty
                ? Text(
                    state.tr(
                        ru: 'Нажимай слова ниже',
                        kk: 'Төмендегі сөздерді бас',
                        en: 'Tap the words below'),
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        color: AppColors.textLight))
                : Wrap(
                    alignment: WrapAlignment.center,
                    textDirection: rtl ? TextDirection.rtl : null,
                    spacing: 8,
                    runSpacing: 8,
                    children: List.generate(picks.length, (position) {
                      return _WordChip(
                        text: bank[picks[position]],
                        tone: answered
                            ? (isCorrect
                                ? _WordChipTone.correct
                                : _WordChipTone.wrong)
                            : _WordChipTone.picked,
                        onTap:
                            onUnpick == null ? null : () => onUnpick!(position),
                      );
                    }),
                  ),
          ),
        ),
        const SizedBox(height: 16),
        // Банк слов: уже использованные гаснут, но место сохраняют.
        Wrap(
          alignment: WrapAlignment.center,
          textDirection: rtl ? TextDirection.rtl : null,
          spacing: 8,
          runSpacing: 8,
          children: List.generate(bank.length, (bankIndex) {
            final isUsed = used.contains(bankIndex);
            return _WordChip(
              text: bank[bankIndex],
              tone: isUsed ? _WordChipTone.used : _WordChipTone.bank,
              onTap: isUsed || onPick == null ? null : () => onPick!(bankIndex),
            );
          }),
        ),
        if (answered && !isCorrect) ...[
          const SizedBox(height: 16),
          Text(
              state.tr(
                  ru: 'Верный порядок: ${step.orderedAnswer}',
                  kk: 'Дұрыс реті: ${step.orderedAnswer}',
                  en: 'Correct order: ${step.orderedAnswer}'),
              textAlign: TextAlign.center,
              textDirection: rtl ? TextDirection.rtl : null,
              style: TextStyle(
                  fontFamily: containsArabicText(step.orderedAnswer)
                      ? 'Amiri'
                      : 'Nunito',
                  fontSize: containsArabicText(step.orderedAnswer) ? 22 : 15,
                  height: 1.6,
                  fontWeight: FontWeight.w700,
                  color: AppColors.pistachioDark)),
        ],
      ],
    );
  }
}

enum _WordChipTone { bank, used, picked, correct, wrong }

class _WordChip extends StatelessWidget {
  final String text;
  final _WordChipTone tone;
  final VoidCallback? onTap;

  const _WordChip({required this.text, required this.tone, this.onTap});

  @override
  Widget build(BuildContext context) {
    final hasArabic = containsArabicText(text);
    late final Color background;
    late final Color border;
    late final Color textColor;

    switch (tone) {
      case _WordChipTone.bank:
        background = AppColors.white;
        border = AppColors.border;
        textColor = AppColors.textDark;
      case _WordChipTone.used:
        background = AppColors.border.withValues(alpha: 0.35);
        border = AppColors.border;
        textColor = Colors.transparent;
      case _WordChipTone.picked:
        background = AppColors.pistachioLight;
        border = AppColors.pistachio;
        textColor = AppColors.textDark;
      case _WordChipTone.correct:
        background = AppColors.success.withValues(alpha: 0.12);
        border = AppColors.success;
        textColor = AppColors.pistachioDark;
      case _WordChipTone.wrong:
        background = AppColors.error.withValues(alpha: 0.1);
        border = AppColors.error;
        textColor = AppColors.error;
    }

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border, width: 1.5),
          boxShadow: tone == _WordChipTone.bank
              ? [
                  BoxShadow(
                    color: AppColors.navyDark.withValues(alpha: 0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Text(text,
            textDirection: hasArabic ? TextDirection.rtl : null,
            style: TextStyle(
                fontFamily: hasArabic ? 'Amiri' : 'Nunito',
                fontSize: hasArabic ? 22 : 15,
                fontWeight: FontWeight.w800,
                color: textColor)),
      ),
    );
  }
}

/// Шаг «Аудирование»: сначала звучит аят или фраза, потом ученик выбирает
/// подходящий вариант. Текст аята намеренно не показывается — иначе задание
/// превращается в обычный вопрос.
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

class _BottomBar extends StatelessWidget {
  final LessonStep step;
  final bool answered;
  final int? selectedAnswer;
  final bool speakPassed;
  final bool matchingComplete;
  final bool orderComplete;
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
    required this.matchingComplete,
    required this.orderComplete,
    required this.reviewingMistakes,
    required this.isCorrect,
    required this.showHint,
    required this.onCheck,
    required this.onContinue,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    Color bgColor = Colors.transparent;
    if (answered && isCorrect) {
      bgColor = AppColors.success.withValues(alpha: 0.08);
    }
    if (answered && !isCorrect) {
      bgColor = AppColors.error.withValues(alpha: 0.07);
    }

    // Резолвим целевой колбэк ровно по прежней логике гейтов: null → кнопка
    // залочена (PremiumButton отрисует disabled-состояние).
    final VoidCallback? resolvedAction =
        answered ? onContinue : (_gateOpen ? onCheck : null);
    final String actionLabel = answered
        ? (reviewingMistakes
            ? state.tr(ru: 'Закрепить', kk: 'Бекіту', en: 'Reinforce')
            : state.tr(ru: 'Продолжить', kk: 'Жалғастыру', en: 'Continue'))
        : _checkLabel(state);

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
                Expanded(
                  child: Text(
                    isCorrect
                        ? state.tr(
                            ru: 'Правильно!', kk: 'Дұрыс!', en: 'Correct!')
                        : state.tr(
                            ru: 'Неправильно. Верный ответ показан ниже',
                            kk: 'Қате. Дұрыс жауап төменде көрсетілген',
                            en: 'Wrong. The correct answer is shown below'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isCorrect ? AppColors.success : AppColors.error,
                    ),
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
                    height: 54,
                  ),
                ),
              if (!answered &&
                  !showHint &&
                  step.type == LessonStepType.question)
                const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: PremiumButton(
                  label: actionLabel,
                  onPressed: resolvedAction,
                  variant: answered && !isCorrect
                      ? PremiumButtonVariant.navy
                      : PremiumButtonVariant.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Открыт ли гейт «Проверить/Продолжить» до ответа: у каждого
  /// интерактивного типа шага своё условие готовности.
  bool get _gateOpen {
    switch (step.type) {
      case LessonStepType.question:
      case LessonStepType.listenChoice:
        return selectedAnswer != null;
      case LessonStepType.matching:
        return matchingComplete;
      case LessonStepType.wordOrder:
        return orderComplete;
      case LessonStepType.speak:
        return speakPassed;
      case LessonStepType.audio:
      case LessonStepType.text:
        return true;
    }
  }

  String _checkLabel(AppState state) {
    switch (step.type) {
      case LessonStepType.audio:
        return state.tr(ru: 'Дальше', kk: 'Әрі қарай', en: 'Next');
      case LessonStepType.text:
        return state.tr(ru: 'Понятно!', kk: 'Түсінікті!', en: 'Got it!');
      case LessonStepType.question:
        return state.tr(ru: 'Проверить', kk: 'Тексеру', en: 'Check');
      case LessonStepType.listenChoice:
        return state.tr(ru: 'Проверить', kk: 'Тексеру', en: 'Check');
      case LessonStepType.wordOrder:
        return state.tr(ru: 'Проверить', kk: 'Тексеру', en: 'Check');
      case LessonStepType.matching:
        return state.tr(ru: 'Продолжить', kk: 'Жалғастыру', en: 'Continue');
      case LessonStepType.speak:
        return state.tr(ru: 'Продолжить', kk: 'Жалғастыру', en: 'Continue');
    }
  }
}
