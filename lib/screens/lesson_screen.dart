import 'dart:async';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:speech_to_text/speech_recognition_result.dart';
import 'package:speech_to_text/speech_to_text.dart';
import '../models/lesson.dart';
import '../models/speech_evaluation.dart';
import '../services/app_state.dart';
import '../services/backend_service.dart';
import '../services/haptics_service.dart';
import '../services/lesson_video_catalog.dart';
import '../services/lesson_content_localization.dart';
import '../services/quran_audio_player.dart';
import '../services/speech_evaluation_service.dart';
import '../services/speech_synthesizer.dart';
import '../utils/colors.dart';
import '../utils/theme.dart';
import '../widgets/cat_character.dart';
import '../widgets/custom_button.dart';
import '../widgets/lesson_video_card.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/pressable_scale.dart';
import '../widgets/section_label.dart';
import '../widgets/semantic_switcher_layout.dart';
import '../widgets/translation_review_note.dart';

part 'lesson/lesson_top_bar.dart';
part 'lesson/step_guide.dart';
part 'lesson/audio_step.dart';
part 'lesson/question_step.dart';
part 'lesson/matching_step.dart';
part 'lesson/word_order_step.dart';
part 'lesson/listen_choice_step.dart';
part 'lesson/speak_step.dart';
part 'lesson/lesson_bottom_bar.dart';

const _lessonFontFallback = AppTheme.fontFallback;

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
  final Future<void> Function(LessonStep step)? audioPlaybackSimulator;
  final LessonVideoCatalog? videoCatalog;

  const LessonScreen({
    super.key,
    required this.lesson,
    @visibleForTesting this.speechSimulator,
    @visibleForTesting this.audioPlaybackSimulator,
    this.videoCatalog,
  });

  @override
  State<LessonScreen> createState() => _LessonScreenState();
}

class _LessonScreenState extends State<LessonScreen> {
  final ScrollController _contentScrollController = ScrollController();
  int _stepIndex = 0;
  CatMood _catMood = CatMood.greet;
  int _reactionIndex = 0;
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
  final Set<int> _reportedStepIndexes = {};
  List<LessonStep> _reviewSteps = [];
  bool _advancing = false;
  bool _exitDialogOpen = false;
  bool _capturedStartingHearts = false;
  int _startingHearts = 5;
  String? _contentLocale;
  Lesson? _previousLocalizedLesson;

  Lesson get _localizedLesson => LessonContentLocalization.localizeLesson(
      widget.lesson, context.read<AppState>().locale.code);

  List<LessonStep> get _activeSteps =>
      _reviewingMistakes ? _reviewSteps : _localizedLesson.steps;
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.watch<AppState>().locale.code;
    final localized = _localizedLesson;
    if (_contentLocale != null && _contentLocale != locale) {
      final previousSteps = _previousLocalizedLesson!.steps;
      LessonStep relocalize(LessonStep step) {
        final index = previousSteps.indexOf(step);
        return index < 0 ? step : localized.steps[index];
      }

      final mistakes = _mistakeSteps.map(relocalize).toList();
      _mistakeSteps
        ..clear()
        ..addAll(mistakes);
      _reviewSteps = _reviewSteps.map(relocalize).toList();
      // Choices are re-presented in the new language. Recorded results and
      // progress remain intact; stale matching/order widgets must not grade.
      _selectedAnswer = null;
      _orderPicks = const [];
      _answered = false;
      _showHint = false;
      _speakPassed = _isSpeakPassed(_step);
      _audioReady = _isAudioReady(_step);
      _matchingComplete = _isMatchingComplete(_step);
    }
    _contentLocale = locale;
    _previousLocalizedLesson = localized;
    if (!_capturedStartingHearts) {
      _startingHearts = context.read<AppState>().user?.hearts ?? 5;
      _capturedStartingHearts = true;
    }
  }

  void _onCheck() {
    if (_answered || _advancing) return;
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
      _reactionIndex += 1;
      if (isCorrect) {
        _catMood = CatMood.success;
      } else {
        _catMood = CatMood.error;
        _errors = (_errors + 1).clamp(0, 5);
        if (!_mistakeSteps.contains(_step)) _mistakeSteps.add(_step);
        _weakStepIds.add(_stepId(_step));
        context.read<AppState>().loseHeart();
      }
    });
  }

  Future<void> _nextStep() async {
    if (_advancing) return;
    setState(() => _advancing = true);
    try {
      if (!_reviewingMistakes && _reportedStepIndexes.add(_stepIndex)) {
        try {
          await context
              .read<AppState>()
              .recordLessonStep(widget.lesson.id, _stepIndex);
        } catch (_) {
          _reportedStepIndexes.remove(_stepIndex);
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(context.read<AppState>().tr(
                    ru: 'Шаг не сохранился. Проверь соединение и повтори.',
                    kk: 'Қадам сақталмады. Байланысты тексеріп, қайтала.',
                    en: 'The step was not saved. Check your connection and retry.',
                  )),
              backgroundColor: AppColors.error,
            ),
          );
          return;
        }
      }
      if (!mounted) return;
      if (_stepIndex + 1 >= _activeSteps.length) {
        // A review is complete only after the learner answers the repeated
        // step cleanly. Mistakes made during review are queued for another
        // pass instead of silently finishing the lesson.
        if (_mistakeSteps.isNotEmpty) {
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
          _scrollToStepStart();
          return;
        }
        await _finishLesson();
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
      _scrollToStepStart();
    } finally {
      if (mounted) setState(() => _advancing = false);
    }
  }

  void _scrollToStepStart() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_contentScrollController.hasClients) return;
      _contentScrollController.jumpTo(0);
    });
  }

  @override
  void dispose() {
    _contentScrollController.dispose();
    super.dispose();
  }

  Future<void> _finishLesson() async {
    final state = context.read<AppState>();
    final isPremium = state.user?.isPremium ?? false;
    Map<String, dynamic> result;
    try {
      result = await state.completeLesson(
        widget.lesson.id,
        _errors.clamp(0, 5),
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
        'lesson': _localizedLesson,
        'xpEarned': result['xpEarned'] ?? 25,
        'streakBonus': result['streakBonus'] ?? 0,
        // Премиум жизни не теряет — не показываем ему списание.
        'heartsLost': isPremium
            ? 0
            : (_startingHearts - (state.user?.hearts ?? 0)).clamp(0, 5),
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
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final compactHeight = viewportHeight < 900;
    final veryCompactHeight = viewportHeight < 600;
    final lessonVideos =
        (widget.videoCatalog ?? LessonVideoCatalog.curated).forLesson(
      widget.lesson.id,
      languageCode: widget.videoCatalog == null
          ? state.nativeLanguage?.code ?? 'ru'
          : null,
    );
    final bottomBar = _BottomBar(
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
      busy: _advancing,
      onCheck: _onCheck,
      onContinue: _nextStep,
      onHint: () => setState(() => _showHint = true),
    );

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _showExitDialog(context);
      },
      child: Scaffold(
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
                    controller: _contentScrollController,
                    child: Column(
                      children: [
                        TranslationReviewNote(locale: state.locale.code),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: Column(
                            children: [
                              SizedBox(height: compactHeight ? 2 : 8),
                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 400),
                                layoutBuilder: semanticSwitcherLayout,
                                child: CatCharacter(
                                  key: ValueKey(_catMood),
                                  mood: _catMood,
                                  reactionId: _reactionIndex,
                                  size: veryCompactHeight
                                      ? 68
                                      : compactHeight
                                          ? 96
                                          : 132,
                                ),
                              ),
                              SizedBox(height: compactHeight ? 4 : 12),
                              _StepGuide(
                                step: _step,
                                currentStep: _stepIndex + 1,
                                totalSteps: _activeSteps.length,
                                reviewingMistakes: _reviewingMistakes,
                              ),
                              if (!_reviewingMistakes &&
                                  _stepIndex == 0 &&
                                  lessonVideos.isNotEmpty) ...[
                                SizedBox(height: compactHeight ? 10 : 16),
                                for (final video in lessonVideos) ...[
                                  LessonVideoCard(video: video),
                                  const SizedBox(height: 12),
                                ],
                              ],
                              SizedBox(height: compactHeight ? 10 : 16),
                              TweenAnimationBuilder<double>(
                                key: ValueKey(
                                  '${widget.lesson.id}_${_stepIndex}_${_reviewingMistakes}_$_contentLocale',
                                ),
                                tween: Tween(begin: 0, end: 1),
                                duration:
                                    MediaQuery.of(context).disableAnimations
                                        ? Duration.zero
                                        : const Duration(milliseconds: 280),
                                curve: Curves.easeOutCubic,
                                child: _buildStepContent(),
                                builder: (context, value, child) {
                                  return Opacity(
                                    opacity: value,
                                    child: Transform.translate(
                                      offset: Offset(18 * (1 - value), 0),
                                      child: child,
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: compactHeight ? 8 : 28),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Keep the primary action in a dedicated, always-visible region.
                // The lesson body remains independently scrollable on short
                // phones and landscape viewports, so reaching a long answer never
                // pushes the action itself beyond the viewport.
                bottomBar,
              ],
            ),
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
          playbackSimulator: widget.audioPlaybackSimulator,
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
              'listen_${widget.lesson.id}_${_stepIndex}_${_reviewingMistakes}_$_contentLocale'),
          step: _step,
          simulatePlayback: widget.speechSimulator != null,
          playbackSimulator: widget.audioPlaybackSimulator,
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
          key: ValueKey(
              '${widget.lesson.id}_${_stepIndex}_${_reviewingMistakes}_$_contentLocale'),
          step: _step,
          onWrong: () {
            HapticsService.wrong();
            setState(() {
              _catMood = CatMood.error;
              _reactionIndex += 1;
              _errors = (_errors + 1).clamp(0, 5);
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
              _reactionIndex += 1;
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
              'speak_${widget.lesson.id}_${_stepIndex}_${_reviewingMistakes}_$_contentLocale'),
          step: _step,
          speechSimulator: widget.speechSimulator,
          onVerified: (passed) {
            if (passed) {
              HapticsService.speechPassed();
            } else {
              HapticsService.speechFailed();
            }
            setState(() {
              _speakPassed = passed;
              _catMood = passed ? CatMood.success : CatMood.error;
              _reactionIndex += 1;
            });
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
            if (_speakPassed) return;
            HapticsService.speechFailed();
            setState(() {
              _speakPassed = true;
              _errors = (_errors + 1).clamp(0, 5);
              if (!_mistakeSteps.contains(_step)) _mistakeSteps.add(_step);
              _weakStepIds.add(_stepId(_step));
              _catMood = CatMood.support;
            });
            context.read<AppState>().loseHeart();
          },
        );
    }
  }

  String _stepId(LessonStep step) {
    final index = _localizedLesson.steps.indexOf(step);
    return step.id ?? '${widget.lesson.id}:$index';
  }

  Future<void> _showExitDialog(BuildContext context) async {
    if (_exitDialogOpen) return;
    _exitDialogOpen = true;
    final state = context.read<AppState>();
    try {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    } finally {
      _exitDialogOpen = false;
    }
  }
}
