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

part 'lesson/lesson_top_bar.dart';
part 'lesson/step_guide.dart';
part 'lesson/audio_step.dart';
part 'lesson/question_step.dart';
part 'lesson/matching_step.dart';
part 'lesson/word_order_step.dart';
part 'lesson/listen_choice_step.dart';
part 'lesson/speak_step.dart';
part 'lesson/lesson_bottom_bar.dart';

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
  final Future<SpeechEvaluationResult> Function(LessonStep step)?
      speechSimulator;

  const LessonScreen({
    super.key,
    required this.lesson,
    @visibleForTesting this.speechSimulator,
  });

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
  bool _audioReady = false;
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

  bool _isAudioReady(LessonStep step) => step.type != LessonStepType.audio;

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
    _audioReady = _isAudioReady(_step);
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
          _audioReady = _isAudioReady(_step);
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
      _audioReady = _isAudioReady(_step);
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
                  currentStep: _stepIndex + 1,
                  totalSteps: _activeSteps.length,
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
                      _StepGuide(
                        step: _step,
                        currentStep: _stepIndex + 1,
                        totalSteps: _activeSteps.length,
                        reviewingMistakes: _reviewingMistakes,
                      ),
                      const SizedBox(height: 16),
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 320),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeInCubic,
                        transitionBuilder: (child, animation) {
                          final offset = Tween<Offset>(
                            begin: const Offset(0.08, 0),
                            end: Offset.zero,
                          ).animate(animation);
                          return FadeTransition(
                            opacity: animation,
                            child: SlideTransition(
                              position: offset,
                              child: child,
                            ),
                          );
                        },
                        child: KeyedSubtree(
                          key: ValueKey(
                            '${widget.lesson.id}_${_stepIndex}_$_reviewingMistakes',
                          ),
                          child: _buildStepContent(),
                        ),
                      ),
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
                audioReady: _audioReady,
                matchingComplete: _matchingComplete,
                orderComplete: _orderComplete,
                reviewingMistakes: _reviewingMistakes,
                isCorrect: _answered && _lastAnswerCorrect,
                feedbackText: _feedbackText(state),
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

  String? _feedbackText(AppState state) {
    if (!_answered) return null;
    final explanation = _step.explanation?.trim();
    if (explanation != null && explanation.isNotEmpty) return explanation;

    if (!_lastAnswerCorrect &&
        (_step.type == LessonStepType.question ||
            _step.type == LessonStepType.listenChoice)) {
      final answers = _step.answers ?? const <String>[];
      final correct = _step.correctAnswerIndex;
      if (correct != null && correct >= 0 && correct < answers.length) {
        return state.tr(
          ru: 'Верный ответ: ${answers[correct]}',
          kk: 'Дұрыс жауап: ${answers[correct]}',
          en: 'Correct answer: ${answers[correct]}',
        );
      }
    }
    return _lastAnswerCorrect
        ? state.tr(
            ru: 'Отлично. Этот шаг можно считать закреплённым.',
            kk: 'Керемет. Бұл қадам бекітілді.',
            en: 'Great. This step is now reinforced.',
          )
        : state.tr(
            ru: 'Посмотри на правильный вариант и запомни отличие.',
            kk: 'Дұрыс нұсқаны қарап, айырмашылығын есте сақта.',
            en: 'Review the correct option and remember the difference.',
          );
  }

  Widget _buildStepContent() {
    switch (_step.type) {
      case LessonStepType.audio:
        return _AudioStep(
          step: _step,
          simulatePlayback: widget.speechSimulator != null,
          onListened: () {
            if (!_audioReady) setState(() => _audioReady = true);
          },
        );
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
          simulatePlayback: widget.speechSimulator != null,
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
          speechSimulator: widget.speechSimulator,
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
