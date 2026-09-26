import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/curriculum_module.dart';
import '../models/curriculum_progress.dart';
import '../services/app_state.dart';
import '../services/curriculum_progress_service.dart';
import '../services/curriculum_repository.dart';
import '../services/lesson_content_localization.dart';
import '../utils/colors.dart';
import '../utils/arabic_ui_strings.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/translation_review_note.dart';

@visibleForTesting
int curriculumCorrectAnswerIndex(CurriculumModule module) =>
    module.sequence % 4;

@visibleForTesting
int curriculumCorrectAnswerIndexFor(CurriculumModule module, int salt) =>
    (module.sequence + salt) % 4;

@visibleForTesting
int curriculumAssessmentScore(int mistakes) =>
    (100 - (mistakes * 20)).clamp(0, 100);

@visibleForTesting
bool curriculumAssessmentPassed(int mistakes) =>
    curriculumAssessmentScore(mistakes) >= 80;

class CurriculumChallenge {
  final String level;
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const CurriculumChallenge({
    required this.level,
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

@visibleForTesting
String curriculumSourceSummary(String source) {
  final first = source.split(';').first.trim();
  if (first.length <= 115) return first;
  return '${first.substring(0, 112)}…';
}

@visibleForTesting
List<String> curriculumChallengeOptions({
  required CurriculumModule module,
  required List<CurriculumModule> allModules,
  required String Function(CurriculumModule) valueOf,
  int salt = 0,
}) {
  final correct = valueOf(module);
  final peers = allModules
      .where((item) => item.id != module.id && item.track == module.track)
      .toList(growable: false);
  final values = <String>[];
  if (peers.isNotEmpty) {
    for (final offset in const [7, 29, 61, 103, 151]) {
      final candidate =
          valueOf(peers[(module.sequence + offset) % peers.length]);
      if (candidate != correct && !values.contains(candidate)) {
        values.add(candidate);
      }
      if (values.length == 3) break;
    }
  }
  for (final candidateModule in allModules) {
    if (values.length == 3) break;
    if (candidateModule.id == module.id) continue;
    final candidate = valueOf(candidateModule);
    if (candidate != correct && !values.contains(candidate)) {
      values.add(candidate);
    }
  }
  if (values.length != 3) {
    throw StateError('Could not build four unique options for ${module.id}.');
  }
  final options = values.toList(growable: true);
  options.insert(curriculumCorrectAnswerIndexFor(module, salt), correct);
  return options;
}

@visibleForTesting
List<CurriculumChallenge> buildCurriculumChallenges({
  required CurriculumModule module,
  required List<CurriculumModule> allModules,
  String locale = 'ru',
}) {
  String tr(String ru, String kk, String en) => locale == 'ar'
      ? translateArabicUi(ru: ru, en: en)
      : locale == 'kk'
          ? kk
          : locale == 'en'
              ? en
              : ru;
  List<String> options(
    int salt,
    String Function(CurriculumModule) valueOf,
  ) =>
      curriculumChallengeOptions(
        module: module,
        allModules: allModules,
        valueOf: valueOf,
        salt: salt,
      );

  String evidencePlan(CurriculumModule item) =>
      '${tr('Опора', 'Дереккөз', 'Evidence')}: ${curriculumSourceSummary(item.sourceLocator)}\n'
      '${tr('Доказательство результата', 'Нәтиженің дәлелі', 'Proof of the outcome')}: ${item.objective}';
  String transferPlan(CurriculumModule item) =>
      '1. ${tr('Учесть', 'Ескер', 'Consider')}: ${item.prerequisite}\n'
      '2. ${tr('Проверить', 'Тексер', 'Verify')}: ${curriculumSourceSummary(item.sourceLocator)}\n'
      '3. ${tr('Показать навык', 'Дағдыны көрсет', 'Demonstrate the skill')}: ${item.objective}';
  String auditDecision(CurriculumModule item) =>
      '${item.title}\n${tr('Сверить источник, затем подтвердить навык', 'Дереккөзді тексеріп, дағдыны раста', 'Check the source, then demonstrate the skill')}: ${item.objective}';

  return [
    CurriculumChallenge(
      level: tr('ПОНИМАНИЕ', 'ТҮСІНУ', 'UNDERSTANDING'),
      prompt: tr(
          'Ученик изучил «${module.title}». Какой наблюдаемый результат действительно доказывает понимание?',
          'Оқушы «${module.title}» тақырыбын оқыды. Түсінгенін қандай нақты нәтиже дәлелдейді?',
          'A learner has studied “${module.title}”. Which observable outcome demonstrates understanding?'),
      options: options(0, (item) => item.objective),
      correctIndex: curriculumCorrectAnswerIndexFor(module, 0),
      explanation: tr(
          'Результат должен совпадать с заявленной целью модуля, а не только быть похожим по теме.',
          'Нәтиже тақырыпқа ұқсас болып қана қоймай, модульдің мақсатына сәйкес келуі керек.',
          'The outcome must match the module’s stated objective, rather than simply relate to a similar topic.'),
    ),
    CurriculumChallenge(
      level: tr('РАБОТА С ДОКАЗАТЕЛЬСТВОМ', 'ДӘЛЕЛМЕН ЖҰМЫС', 'USING EVIDENCE'),
      prompt: tr(
          'Нужно проверить вывод по модулю, не полагаясь на память. Какая опора относится именно к этой теме?',
          'Модуль бойынша қорытындыны есте сақтағанға сүйенбей тексеру керек. Осы тақырыпқа қай дереккөз қатысты?',
          'Verify the module’s conclusion without relying on memory. Which source belongs to this topic?'),
      options:
          options(1, (item) => curriculumSourceSummary(item.sourceLocator)),
      correctIndex: curriculumCorrectAnswerIndexFor(module, 1),
      explanation: tr(
          'Сильный ответ связывает вывод с источником, указанным в материале этого модуля.',
          'Негізді жауап қорытындыны осы модульде көрсетілген дереккөзбен байланыстырады.',
          'A well-supported answer connects the conclusion to the source given in this module.'),
    ),
    CurriculumChallenge(
      level: tr('АНАЛИЗ', 'ТАЛДАУ', 'ANALYSIS'),
      prompt: tr(
          'В четырёх планах одна цепочка не содержит подмены темы или источника. Найди её.',
          'Төрт жоспардың бірінде тақырып та, дереккөз де дұрыс берілген. Сол жоспарды тап.',
          'Only one of these four plans keeps both the topic and source consistent. Find it.'),
      options: options(2, evidencePlan),
      correctIndex: curriculumCorrectAnswerIndexFor(module, 2),
      explanation: tr(
          'Проверь два звена отдельно: источник должен относиться к теме, а результат — следовать из цели.',
          'Екі бөлікті жеке тексер: дереккөз тақырыпқа қатысты, ал нәтиже мақсатқа сәйкес болуы керек.',
          'Check each link separately: the source must fit the topic, and the outcome must follow from the objective.'),
    ),
    CurriculumChallenge(
      level: tr('ПЕРЕНОС', 'ҚОЛДАНУ', 'APPLICATION'),
      prompt: tr(
          'Какой порядок действий позволит применить материал и обосновать результат наставнику?',
          'Материалды қолданып, нәтижені тәлімгерге негіздеу үшін қай әрекет реті дұрыс?',
          'Which sequence lets you apply the material and justify the outcome to your mentor?'),
      options: options(3, transferPlan),
      correctIndex: curriculumCorrectAnswerIndexFor(module, 3),
      explanation: tr(
          'Надёжная цепочка начинается с входного условия, проходит через проверяемую опору и заканчивается демонстрацией навыка.',
          'Дұрыс тізбек бастапқы шарттан басталып, дереккөзді тексеру арқылы өтіп, дағдыны көрсетумен аяқталады.',
          'A reliable sequence starts with the prerequisite, checks the evidence, and ends by demonstrating the skill.'),
    ),
    CurriculumChallenge(
      level: tr('ИТОГОВАЯ АТТЕСТАЦИЯ', 'ҚОРЫТЫНДЫ БАҒАЛАУ', 'FINAL ASSESSMENT'),
      prompt: tr(
          'Ученик допустил ошибку и должен проверить рассуждение заново. Какой маршрут относится к текущему модулю целиком?',
          'Оқушы қателесіп, ойын қайта тексеруі керек. Қай бағыт осы модульге толығымен сәйкес келеді?',
          'A learner made a mistake and needs to check their reasoning again. Which route fully matches this module?'),
      options: options(4, auditDecision),
      correctIndex: curriculumCorrectAnswerIndexFor(module, 4),
      explanation: tr(
          'Название, источник и проверяемый навык должны образовывать одну непротиворечивую цепочку.',
          'Атау, дереккөз және тексерілетін дағды бір-біріне қайшы келмейтін тізбек құруы керек.',
          'The title, source, and assessed skill must form a consistent chain.'),
    ),
  ];
}

class CurriculumModuleScreen extends StatefulWidget {
  final CurriculumModule module;
  final Future<List<CurriculumModule>>? modulesFuture;

  const CurriculumModuleScreen({
    super.key,
    required this.module,
    @visibleForTesting this.modulesFuture,
  });

  @override
  State<CurriculumModuleScreen> createState() => _CurriculumModuleScreenState();
}

class _CurriculumModuleScreenState extends State<CurriculumModuleScreen> {
  CurriculumModule get _module => LessonContentLocalization.localizeModule(
      widget.module, context.read<AppState>().locale.code);
  static const _stepCount = 5;

  List<CurriculumModule> _allModules = const [];
  CurriculumProgress _progress = const CurriculumProgress();
  bool _loading = true;
  bool _saving = false;
  bool _finished = false;
  int _step = 0;
  int? _selectedAnswer;
  bool _answerRevealed = false;
  int _quizIndex = 0;
  int _finalMistakes = 0;
  bool _assessmentFailed = false;
  final List<int> _practiceOrder = [];
  String? _contentLocale;
  String? _challengeLocale;
  List<CurriculumChallenge>? _challengeCache;

  String get _learnerId =>
      context.read<AppState>().user?.id ?? 'anonymous-learner';

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.watch<AppState>().locale.code;
    if (_contentLocale != null && _contentLocale != locale) {
      // Localized source summaries can select a different distractor after
      // deduplication. Re-present the question instead of retaining its choice.
      _selectedAnswer = null;
      _answerRevealed = false;
      _practiceOrder.clear();
    }
    _contentLocale = locale;
  }

  @override
  void initState() {
    super.initState();
    unawaited(_load());
  }

  Future<void> _load() async {
    final results = await Future.wait<dynamic>([
      widget.modulesFuture ?? CurriculumRepository.load(),
      CurriculumProgressService.load(_learnerId),
    ]);
    if (!mounted) return;
    final modules = results[0] as List<CurriculumModule>;
    final localProgress = results[1] as CurriculumProgress;
    final remoteProgress = CurriculumProgress.fromJson(
      context.read<AppState>().curriculumProgress,
    );
    final progress = localProgress.mergedWith(remoteProgress);
    await CurriculumProgressService.persist(_learnerId, progress);
    if (!mounted) return;
    setState(() {
      _allModules = modules;
      _progress = progress;
      _finished = progress.completedModuleIds.contains(_module.id);
      _step = _finished
          ? 0
          : (progress.stepByModuleId[_module.id] ?? 0).clamp(0, 4);
      _loading = false;
    });
  }

  List<CurriculumChallenge> get _challenges {
    final locale = context.read<AppState>().locale.code;
    if (_challengeCache != null && _challengeLocale == locale) {
      return _challengeCache!;
    }
    _challengeLocale = locale;
    // Answer selection must not rebuild five tasks from 570 modules for every
    // answer card, button and feedback frame. The source set is fixed per route;
    // only a language change requires a fresh set of localized challenges.
    return _challengeCache = buildCurriculumChallenges(
      module: _module,
      allModules: _allModules
          .map((module) =>
              LessonContentLocalization.localizeModule(module, locale))
          .toList(growable: false),
      locale: locale,
    );
  }

  List<CurriculumChallenge> get _activeChallenges =>
      _step == 2 ? _challenges.take(2).toList() : _challenges.skip(2).toList();

  CurriculumChallenge get _activeChallenge => _activeChallenges[_quizIndex];

  int get _correctIndex => _activeChallenge.correctIndex;

  Future<void> _advance() async {
    if (_saving) return;
    if (_step == 2 || _step == 4) {
      if (!_answerRevealed) {
        if (_selectedAnswer == null) return;
        final correct = _selectedAnswer == _correctIndex;
        setState(() {
          _answerRevealed = true;
          if (!correct) {
            if (_step == 4) _finalMistakes++;
          }
        });
        return;
      }
      if (_selectedAnswer != _correctIndex) {
        setState(() {
          _selectedAnswer = null;
          _answerRevealed = false;
        });
        return;
      }
      if (_quizIndex + 1 < _activeChallenges.length) {
        setState(() {
          _quizIndex++;
          _selectedAnswer = null;
          _answerRevealed = false;
        });
        return;
      }
    }
    if (_step == 3 && !_practiceComplete) return;
    if (_step == _stepCount - 1) {
      if (!curriculumAssessmentPassed(_finalMistakes)) {
        setState(() => _assessmentFailed = true);
        return;
      }
      await _complete();
      return;
    }
    final next = _step + 1;
    setState(() {
      _saving = true;
      _step = next;
      _selectedAnswer = null;
      _answerRevealed = false;
      _quizIndex = 0;
    });
    try {
      _progress = await CurriculumProgressService.recordStep(
        learnerId: _learnerId,
        moduleId: _module.id,
        step: next,
      );
      if (!mounted) return;
      context.read<AppState>().updateCurriculumProgress(_progress.toJson());
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _complete() async {
    setState(() => _saving = true);
    final mastery = curriculumAssessmentScore(_finalMistakes);
    try {
      _progress = await CurriculumProgressService.complete(
        learnerId: _learnerId,
        moduleId: _module.id,
        mastery: mastery,
      );
      if (!mounted) return;
      context.read<AppState>().updateCurriculumProgress(_progress.toJson());
      setState(() => _finished = true);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  void _replay() {
    setState(() {
      _finished = false;
      _step = 0;
      _finalMistakes = 0;
      _quizIndex = 0;
      _assessmentFailed = false;
      _selectedAnswer = null;
      _answerRevealed = false;
      _practiceOrder.clear();
    });
  }

  bool get _practiceComplete =>
      _practiceOrder.length == 3 &&
      _practiceOrder[0] == 0 &&
      _practiceOrder[1] == 1 &&
      _practiceOrder[2] == 2;

  void _selectPracticeStep(int value) {
    if (_practiceOrder.contains(value) || _practiceOrder.length == 3) return;
    setState(() => _practiceOrder.add(value));
  }

  void _resetPractice() => setState(_practiceOrder.clear);

  void _retryAssessment() {
    setState(() {
      _assessmentFailed = false;
      _finalMistakes = 0;
      _quizIndex = 0;
      _selectedAnswer = null;
      _answerRevealed = false;
    });
  }

  CurriculumModule? get _nextModule {
    final index = _allModules.indexWhere((item) => item.id == _module.id);
    if (index < 0 || index + 1 >= _allModules.length) return null;
    return _allModules[index + 1];
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                  children: [
                    _header(state),
                    TranslationReviewNote(locale: state.locale.code),
                    if (!_finished) _progressHeader(state),
                    Expanded(
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 260),
                        child: _finished
                            ? _completionView(state)
                            : SingleChildScrollView(
                                key: ValueKey('curriculum-stage-$_step'),
                                padding:
                                    const EdgeInsets.fromLTRB(18, 12, 18, 22),
                                child: _stageBody(state),
                              ),
                      ),
                    ),
                    if (!_finished) _bottomAction(state),
                  ],
                ),
        ),
      ),
    );
  }

  Widget _header(AppState state) => Padding(
        padding: const EdgeInsets.fromLTRB(6, 6, 10, 4),
        child: Row(
          children: [
            IconButton(
              key: const ValueKey('curriculum-close'),
              onPressed: () => Navigator.pop(context, _progress),
              tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
              icon: const Icon(Icons.close_rounded),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_module.id} · ${_module.strand}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.sky,
                    ),
                  ),
                  Text(
                    _module.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyDark,
                    ),
                  ),
                ],
              ),
            ),
            IconButton.filledTonal(
              onPressed: () => Navigator.pushNamed(
                context,
                '/audio-session',
                arguments: _module,
              ),
              tooltip: state.tr(ru: 'Слушать', kk: 'Тыңдау', en: 'Listen'),
              icon: const Icon(Icons.headphones_rounded),
            ),
          ],
        ),
      );

  Widget _progressHeader(AppState state) => Padding(
        padding: const EdgeInsets.fromLTRB(18, 5, 18, 5),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    state.tr(
                      ru: 'Этап ${_step + 1} из $_stepCount',
                      kk: '${_step + 1}/$_stepCount кезең',
                      en: 'Stage ${_step + 1} of $_stepCount',
                    ),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textGrey,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${((_step + 1) / _stepCount * 100).round()}%',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 7),
            Row(
              children: [
                for (var index = 0; index < _stepCount; index++) ...[
                  Expanded(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 240),
                      height: index == _step ? 8 : 5,
                      decoration: BoxDecoration(
                        color:
                            index <= _step ? AppColors.sky : AppColors.border,
                        borderRadius: BorderRadius.circular(99),
                        boxShadow: index == _step
                            ? [
                                BoxShadow(
                                  color: AppColors.sky.withValues(alpha: 0.28),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                )
                              ]
                            : null,
                      ),
                    ),
                  ),
                  if (index + 1 < _stepCount) const SizedBox(width: 6),
                ],
              ],
            ),
          ],
        ),
      );

  Widget _stageBody(AppState state) {
    switch (_step) {
      case 0:
        return _orientationStage(state);
      case 1:
        return _evidenceStage(state);
      case 2:
        return _quizStage(state, isFinal: false);
      case 3:
        return _practiceStage(state);
      default:
        return _quizStage(state, isFinal: true);
    }
  }

  Widget _orientationStage(AppState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stageHeading(
            icon: Icons.explore_rounded,
            eyebrow:
                state.tr(ru: 'ОРИЕНТАЦИЯ', kk: 'БАҒДАР', en: 'ORIENTATION'),
            title: state.tr(
              ru: 'Сначала пойми результат',
              kk: 'Алдымен нәтижені түсін',
              en: 'Start with the outcome',
            ),
            subtitle: state.tr(
              ru: 'Ты заранее знаешь, чему научишься и как это будет проверено.',
              kk: 'Нені үйренетінің және қалай тексерілетіні алдын ала белгілі.',
              en: 'Know what you will learn and how it will be checked.',
            ),
          ),
          const SizedBox(height: 18),
          PremiumCard(
            color: AppColors.navyDark,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _pill(
                        LessonContentLocalization.trackTitle(
                            _module.track, state.locale.code),
                        AppColors.skyLight),
                    _pill(_module.difficulty, AppColors.goldLight),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  _module.objective,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 18,
                    height: 1.4,
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          _infoRow(
            Icons.route_rounded,
            state.tr(
                ru: 'Рекомендуемая подготовка',
                kk: 'Ұсынылатын дайындық',
                en: 'Suggested preparation'),
            _module.prerequisite,
          ),
          _infoRow(
            Icons.timer_outlined,
            state.tr(ru: 'Формат', kk: 'Формат', en: 'Format'),
            state.tr(
              ru: '5 этапов · 5 задач · аттестация от 80%',
              kk: '5 кезең · 5 тапсырма · аттестация 80%-дан',
              en: '5 stages · 5 challenges · 80% pass mark',
            ),
          ),
        ],
      );

  Widget _evidenceStage(AppState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stageHeading(
            icon: Icons.fact_check_rounded,
            eyebrow: state.tr(
                ru: 'РАБОТА С ИСТОЧНИКОМ',
                kk: 'ДЕРЕККӨЗБЕН ЖҰМЫС',
                en: 'SOURCE WORK'),
            title: state.tr(
              ru: 'Собери карту доказательств',
              kk: 'Дәлелдер картасын құр',
              en: 'Build an evidence map',
            ),
            subtitle: state.tr(
              ru: 'Отделяй первоисточник, объяснение и границы автоматической проверки.',
              kk: 'Негізгі дереккөзді, түсіндірмені және автоматты тексеру шегін ажырат.',
              en: 'Separate primary source, explanation, and automated-check limits.',
            ),
          ),
          const SizedBox(height: 18),
          _sourceCard(
            Icons.menu_book_rounded,
            state.tr(
                ru: 'Источник модуля',
                kk: 'Модуль дереккөзі',
                en: 'Module source'),
            curriculumSourceSummary(_module.sourceLocator),
          ),
          const SizedBox(height: 12),
          _sourceCard(
            Icons.flag_rounded,
            state.tr(
                ru: 'Что нужно доказать',
                kk: 'Нені дәлелдеу керек',
                en: 'What you must prove'),
            _module.objective,
            color: AppColors.goldLight.withValues(alpha: 0.55),
          ),
          const SizedBox(height: 12),
          _sourceCard(
            Icons.record_voice_over_rounded,
            state.tr(
                ru: 'Компетенция наставника',
                kk: 'Ұстаз құзыреті',
                en: 'Mentor expertise'),
            _module.speakerDomain,
          ),
          if (_module.videoNeed.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            _sourceCard(
              Icons.ondemand_video_rounded,
              state.tr(
                ru: 'Видео-практика',
                kk: 'Видео тәжірибе',
                en: 'Video practice',
              ),
              _module.videoNeed,
              color: AppColors.pistachio.withValues(alpha: 0.12),
            ),
          ],
          const SizedBox(height: 12),
          _sourceCard(
            Icons.verified_user_rounded,
            state.tr(
                ru: 'Статус проверки',
                kk: 'Тексеру мәртебесі',
                en: 'Review status'),
            _module.reviewStatus,
            color: AppColors.skyLight,
          ),
        ],
      );

  Widget _quizStage(AppState state, {required bool isFinal}) {
    final challenge = _activeChallenge;
    final total = _activeChallenges.length;
    if (_assessmentFailed) {
      return _assessmentRetry(state);
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stageHeading(
          icon: _step == 2 ? Icons.psychology_rounded : Icons.school_rounded,
          eyebrow: '${challenge.level} · ${_quizIndex + 1}/$total',
          title: isFinal
              ? state.tr(
                  ru: 'Итоговая аттестация',
                  kk: 'Қорытынды аттестация',
                  en: 'Final assessment')
              : state.tr(
                  ru: 'Лаборатория понимания',
                  kk: 'Түсіну зертханасы',
                  en: 'Understanding lab'),
          subtitle: challenge.prompt,
        ),
        if (isFinal) ...[
          const SizedBox(height: 12),
          _assessmentRule(state),
        ],
        const SizedBox(height: 18),
        for (var index = 0; index < challenge.options.length; index++)
          _answerCard(index, challenge.options[index]),
        if (_answerRevealed) ...[
          const SizedBox(height: 6),
          _feedbackCard(state, _selectedAnswer == _correctIndex),
        ],
      ],
    );
  }

  Widget _practiceStage(AppState state) {
    final labels = [
      '${state.tr(ru: 'Учесть входное условие', kk: 'Бастапқы шартты ескеру', en: 'Check the prerequisite')}\n${_module.prerequisite}',
      '${state.tr(ru: 'Проверить по опоре', kk: 'Дереккөзбен тексеру', en: 'Verify with evidence')}\n${curriculumSourceSummary(_module.sourceLocator)}',
      '${state.tr(ru: 'Продемонстрировать результат', kk: 'Нәтижені көрсету', en: 'Demonstrate the outcome')}\n${_module.objective}',
    ];
    final displayOrder = [1, 2, 0];
    final attempted = _practiceOrder.length == 3;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stageHeading(
          icon: Icons.extension_rounded,
          eyebrow: state.tr(
              ru: 'ПЕРЕНОС В ПРАКТИКУ', kk: 'ТӘЖІРИБЕ', en: 'TRANSFER'),
          title: state.tr(
            ru: 'Построй цепочку решения',
            kk: 'Шешім тізбегін құр',
            en: 'Build the reasoning chain',
          ),
          subtitle: state.tr(
            ru: 'Выбери три шага в правильном порядке: от условия к доказательству результата.',
            kk: 'Үш қадамды дұрыс ретпен таңда: шарттан нәтижені дәлелдеуге дейін.',
            en: 'Select the three steps in order, from prerequisite to proof.',
          ),
        ),
        const SizedBox(height: 18),
        if (_practiceOrder.isNotEmpty) ...[
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (var index = 0; index < _practiceOrder.length; index++)
                _pill('${index + 1}', AppColors.goldLight),
            ],
          ),
          const SizedBox(height: 12),
        ],
        for (final index in displayOrder)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: _practiceOrder.contains(index)
                  ? AppColors.skyLight
                  : AppColors.white,
              borderRadius: BorderRadius.circular(18),
              child: ListTile(
                key: ValueKey('curriculum-practice-$index'),
                onTap: attempted ? null : () => _selectPracticeStep(index),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
                ),
                leading: CircleAvatar(
                  backgroundColor: AppColors.navy,
                  foregroundColor: AppColors.white,
                  child: Text(
                    _practiceOrder.contains(index)
                        ? '${_practiceOrder.indexOf(index) + 1}'
                        : '?',
                  ),
                ),
                title: Text(
                  labels[index],
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
              ),
            ),
          ),
        if (attempted && !_practiceComplete) ...[
          _practiceFeedback(state, correct: false),
          const SizedBox(height: 8),
          TextButton.icon(
            key: const ValueKey('curriculum-practice-reset'),
            onPressed: _resetPractice,
            icon: const Icon(Icons.refresh_rounded),
            label: Text(state.tr(
              ru: 'Собрать цепочку заново',
              kk: 'Тізбекті қайта құру',
              en: 'Rebuild the chain',
            )),
          ),
        ] else if (_practiceComplete)
          _practiceFeedback(state, correct: true),
      ],
    );
  }

  Widget _practiceFeedback(AppState state, {required bool correct}) =>
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: correct
              ? AppColors.success.withValues(alpha: 0.12)
              : AppColors.errorLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(
          correct
              ? state.tr(
                  ru:
                      'Цепочка обоснована: условие → источник → демонстрация навыка.',
                  kk: 'Тізбек негізделді: шарт → дереккөз → дағдыны көрсету.',
                  en:
                      'Reasoning confirmed: prerequisite → evidence → demonstration.')
              : state.tr(
                  ru: 'В цепочке нарушена логика. Сначала проверь условие, затем опору и только потом результат.',
                  kk: 'Тізбектің логикасы бұзылған. Алдымен шартты, кейін дереккөзді, соңында нәтижені тексер.',
                  en: 'The chain is broken. Check the prerequisite, then evidence, then the outcome.'),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      );

  Widget _stageHeading({
    required IconData icon,
    required String eyebrow,
    required String title,
    required String subtitle,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.skyLight,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: AppColors.navy),
          ),
          const SizedBox(height: 13),
          Text(
            eyebrow,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              letterSpacing: 1.1,
              fontWeight: FontWeight.w900,
              color: AppColors.sky,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 27,
              height: 1.15,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              height: 1.45,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
        ],
      );

  Widget _pill(String label, Color color) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(99),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: FontWeight.w900,
            color: AppColors.navyDark,
          ),
        ),
      );

  Widget _infoRow(IconData icon, String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: PremiumCard(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 20, color: AppColors.navy),
              const SizedBox(width: 11),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      value,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );

  Widget _sourceCard(
    IconData icon,
    String label,
    String value, {
    Color color = AppColors.white,
  }) =>
      PremiumCard(
        color: color,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 19, color: AppColors.navy),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 9),
            Text(
              value,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                height: 1.45,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      );

  Widget _answerCard(int index, String text) {
    final selected = _selectedAnswer == index;
    final correct = index == _correctIndex;
    Color border = selected ? AppColors.sky : AppColors.border;
    Color background = selected ? AppColors.skyLight : AppColors.white;
    IconData? trailing;
    if (_answerRevealed && selected) {
      border = correct ? AppColors.success : AppColors.error;
      background = correct
          ? AppColors.success.withValues(alpha: 0.12)
          : AppColors.errorLight;
      trailing = correct ? Icons.check_circle_rounded : Icons.cancel_rounded;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: background,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: BorderSide(color: border, width: selected ? 2 : 1),
        ),
        child: InkWell(
          key: ValueKey('curriculum-answer-$index'),
          onTap: _answerRevealed
              ? null
              : () => setState(() => _selectedAnswer = index),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 28,
                  height: 28,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selected ? AppColors.navy : AppColors.backgroundGrey,
                  ),
                  child: Text(
                    String.fromCharCode(65 + index),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w900,
                      color: selected ? AppColors.white : AppColors.navy,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    text,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 13,
                      height: 1.38,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                if (trailing != null) ...[
                  const SizedBox(width: 8),
                  Icon(trailing, color: border),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _feedbackCard(AppState state, bool correct) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: correct
              ? AppColors.success.withValues(alpha: 0.12)
              : AppColors.errorLight,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              correct
                  ? state.tr(
                      ru: 'Логика верна',
                      kk: 'Логика дұрыс',
                      en: 'Reasoning confirmed')
                  : state.tr(
                      ru: 'В рассуждении есть разрыв',
                      kk: 'Ойлау тізбегінде үзіліс бар',
                      en: 'There is a gap in the reasoning'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              _activeChallenge.explanation,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w700,
                height: 1.35,
                color: AppColors.textDark,
              ),
            ),
          ],
        ),
      );

  Widget _assessmentRule(AppState state) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.navyDark,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            const Icon(Icons.workspace_premium_rounded,
                color: AppColors.gold, size: 20),
            const SizedBox(width: 9),
            Expanded(
              child: Text(
                state.tr(
                  ru: 'Порог мастерства: 80%. Ошибки нужно разобрать и исправить.',
                  kk: 'Меңгеру шегі: 80%. Қателерді талдап, түзету керек.',
                  en: 'Mastery threshold: 80%. Mistakes must be reviewed and corrected.',
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      );

  Widget _assessmentRetry(AppState state) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stageHeading(
            icon: Icons.insights_rounded,
            eyebrow: state.tr(
              ru: 'РАЗБОР РЕЗУЛЬТАТА',
              kk: 'НӘТИЖЕНІ ТАЛДАУ',
              en: 'RESULT REVIEW',
            ),
            title: state.tr(
              ru: 'Понимание ещё не устойчиво',
              kk: 'Түсінік әлі тұрақты емес',
              en: 'Understanding is not stable yet',
            ),
            subtitle: state.tr(
              ru: 'Набрано меньше 80%. Пересобери связи между условием, источником и результатом — затем пройди новый вариант.',
              kk: '80%-дан төмен. Шарт, дереккөз және нәтиже байланысын қайта құр да, жаңа нұсқаны өт.',
              en: 'Below 80%. Rebuild the prerequisite-evidence-outcome chain, then take a fresh attempt.',
            ),
          ),
          const SizedBox(height: 18),
          PremiumCard(
            color: AppColors.navyDark,
            child: Row(
              children: [
                const Icon(Icons.analytics_rounded,
                    color: AppColors.gold, size: 34),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    '${curriculumAssessmentScore(_finalMistakes)}% · '
                    '${state.tr(ru: 'нужно 80%', kk: '80% қажет', en: '80% required')}',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: AppColors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          PremiumButton(
            key: const ValueKey('curriculum-assessment-retry'),
            label: state.tr(
              ru: 'Повторить аттестацию',
              kk: 'Аттестацияны қайталау',
              en: 'Retry assessment',
            ),
            icon: Icons.refresh_rounded,
            onPressed: _retryAssessment,
          ),
        ],
      );

  Widget _bottomAction(AppState state) {
    final needsAnswer = (_step == 2 || _step == 4) && _selectedAnswer == null;
    final needsPractice = _step == 3 && !_practiceComplete;
    final isWrongRetry = _answerRevealed && _selectedAnswer != _correctIndex;
    String label;
    if (_assessmentFailed) {
      return const SizedBox.shrink();
    } else if ((_step == 2 || _step == 4) && !_answerRevealed) {
      label = state.tr(ru: 'Проверить', kk: 'Тексеру', en: 'Check');
    } else if (isWrongRetry) {
      label = state.tr(
          ru: 'Попробовать ещё раз', kk: 'Қайталап көру', en: 'Try again');
    } else if ((_step == 2 || _step == 4) &&
        _quizIndex + 1 < _activeChallenges.length) {
      label = state.tr(
        ru: 'Следующая задача',
        kk: 'Келесі тапсырма',
        en: 'Next challenge',
      );
    } else if (_step == _stepCount - 1) {
      label = state.tr(
          ru: 'Завершить модуль', kk: 'Модульді аяқтау', en: 'Complete module');
    } else {
      label = state.tr(ru: 'Продолжить', kk: 'Жалғастыру', en: 'Continue');
    }
    return Container(
      padding: const EdgeInsets.fromLTRB(18, 12, 18, 16),
      decoration: BoxDecoration(
        color: AppColors.ivory.withValues(alpha: 0.97),
        border: const Border(top: BorderSide(color: AppColors.border)),
      ),
      child: PremiumButton(
        key: const ValueKey('curriculum-primary-action'),
        label: _saving ? '…' : label,
        icon: isWrongRetry
            ? Icons.refresh_rounded
            : (_step == _stepCount - 1
                ? Icons.verified_rounded
                : Icons.arrow_forward_rounded),
        onPressed: _saving || needsAnswer || needsPractice ? null : _advance,
      ),
    );
  }

  Widget _completionView(AppState state) {
    final score = _progress.masteryByModuleId[_module.id] ??
        curriculumAssessmentScore(_finalMistakes);
    final next = _nextModule;
    return SingleChildScrollView(
      key: const ValueKey('curriculum-complete'),
      padding: const EdgeInsets.fromLTRB(18, 28, 18, 30),
      child: Column(
        children: [
          Container(
            width: 92,
            height: 92,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.success.withValues(alpha: 0.15),
            ),
            child: const Icon(
              Icons.verified_rounded,
              size: 50,
              color: AppColors.success,
            ),
          ),
          const SizedBox(height: 18),
          Text(
            state.tr(
              ru: 'Модуль освоен',
              kk: 'Модуль меңгерілді',
              en: 'Module mastered',
            ),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 29,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _module.title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 16,
              height: 1.35,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 20),
          PremiumCard(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Expanded(
                  child: _resultMetric('$score%',
                      state.tr(ru: 'мастерство', kk: 'меңгеру', en: 'mastery')),
                ),
                Container(width: 1, height: 42, color: AppColors.border),
                Expanded(
                  child: _resultMetric('${_progress.completedCount}/570',
                      state.tr(ru: 'пройдено', kk: 'аяқталды', en: 'complete')),
                ),
              ],
            ),
          ),
          const SizedBox(height: 18),
          if (next != null)
            PremiumButton(
              key: const ValueKey('curriculum-next-module'),
              label: state.tr(
                ru: 'Следующий модуль',
                kk: 'Келесі модуль',
                en: 'Next module',
              ),
              icon: Icons.arrow_forward_rounded,
              onPressed: () => Navigator.pushReplacementNamed(
                context,
                '/curriculum-module',
                arguments: next,
              ),
            ),
          const SizedBox(height: 10),
          TextButton.icon(
            key: const ValueKey('curriculum-repeat-module'),
            onPressed: _replay,
            icon: const Icon(Icons.replay_rounded),
            label: Text(state.tr(
              ru: 'Повторить модуль',
              kk: 'Модульді қайталау',
              en: 'Repeat module',
            )),
          ),
          TextButton(
            key: const ValueKey('curriculum-back-to-library'),
            onPressed: () => Navigator.pop(context, _progress),
            child: Text(state.tr(
              ru: 'Вернуться в библиотеку',
              kk: 'Кітапханаға оралу',
              en: 'Back to library',
            )),
          ),
        ],
      ),
    );
  }

  Widget _resultMetric(String value, String label) => Column(
        children: [
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.textGrey,
            ),
          ),
        ],
      );
}
