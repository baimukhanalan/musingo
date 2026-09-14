import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/curriculum_module.dart';
import '../models/curriculum_progress.dart';
import '../services/app_state.dart';
import '../services/curriculum_progress_service.dart';
import '../services/curriculum_repository.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';

@visibleForTesting
int curriculumCorrectAnswerIndex(CurriculumModule module) =>
    module.sequence % 4;

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
  options.insert(curriculumCorrectAnswerIndex(module), correct);
  return options;
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
  static const _stepCount = 5;

  List<CurriculumModule> _allModules = const [];
  CurriculumProgress _progress = const CurriculumProgress();
  bool _loading = true;
  bool _saving = false;
  bool _finished = false;
  int _step = 0;
  int _mistakes = 0;
  int? _selectedAnswer;
  bool _answerRevealed = false;
  final List<bool> _practiceChecks = [false, false, false];

  String get _learnerId =>
      context.read<AppState>().user?.id ?? 'anonymous-learner';

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
      _finished = progress.completedModuleIds.contains(widget.module.id);
      _step = _finished
          ? 0
          : (progress.stepByModuleId[widget.module.id] ?? 0).clamp(0, 4);
      _loading = false;
    });
  }

  List<String> get _objectiveOptions => curriculumChallengeOptions(
        module: widget.module,
        allModules: _allModules,
        valueOf: (module) => module.objective,
      );

  List<String> get _sourceOptions => curriculumChallengeOptions(
        module: widget.module,
        allModules: _allModules,
        valueOf: (module) => curriculumSourceSummary(module.sourceLocator),
      );

  int get _correctIndex => curriculumCorrectAnswerIndex(widget.module);

  Future<void> _advance() async {
    if (_saving) return;
    if (_step == 2 || _step == 4) {
      if (!_answerRevealed) {
        if (_selectedAnswer == null) return;
        final correct = _selectedAnswer == _correctIndex;
        setState(() {
          _answerRevealed = true;
          if (!correct) _mistakes++;
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
    }
    if (_step == 3 && !_practiceChecks.every((value) => value)) return;
    if (_step == _stepCount - 1) {
      await _complete();
      return;
    }
    final next = _step + 1;
    setState(() {
      _saving = true;
      _step = next;
      _selectedAnswer = null;
      _answerRevealed = false;
    });
    try {
      _progress = await CurriculumProgressService.recordStep(
        learnerId: _learnerId,
        moduleId: widget.module.id,
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
    final mastery = (100 - (_mistakes * 10)).clamp(70, 100);
    try {
      _progress = await CurriculumProgressService.complete(
        learnerId: _learnerId,
        moduleId: widget.module.id,
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
      _mistakes = 0;
      _selectedAnswer = null;
      _answerRevealed = false;
      for (var index = 0; index < _practiceChecks.length; index++) {
        _practiceChecks[index] = false;
      }
    });
  }

  CurriculumModule? get _nextModule {
    final index = _allModules.indexWhere((item) => item.id == widget.module.id);
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
              onPressed: () => Navigator.pop(context, _progress),
              tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
              icon: const Icon(Icons.close_rounded),
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${widget.module.id} · ${widget.module.strand}',
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
                    widget.module.title,
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
                arguments: widget.module,
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
                Text(
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
                const Spacer(),
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
            ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: LinearProgressIndicator(
                minHeight: 8,
                value: (_step + 1) / _stepCount,
                backgroundColor: AppColors.border,
                color: AppColors.sky,
              ),
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
        return _quizStage(
          state,
          title: state.tr(
            ru: 'Активное воспроизведение',
            kk: 'Белсенді еске түсіру',
            en: 'Active recall',
          ),
          prompt: state.tr(
            ru: 'Какой результат относится именно к этому модулю?',
            kk: 'Осы модульге қай нәтиже сәйкес келеді?',
            en: 'Which outcome belongs to this module?',
          ),
          options: _objectiveOptions,
        );
      case 3:
        return _practiceStage(state);
      default:
        return _quizStage(
          state,
          title: state.tr(
            ru: 'Проверка мастерства',
            kk: 'Меңгеруді тексеру',
            en: 'Mastery check',
          ),
          prompt: state.tr(
            ru: 'Какой источник закреплён за этим модулем?',
            kk: 'Осы модульге қай дереккөз бекітілген?',
            en: 'Which source is assigned to this module?',
          ),
          options: _sourceOptions,
        );
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
                    _pill(widget.module.track, AppColors.skyLight),
                    _pill(widget.module.difficulty, AppColors.goldLight),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  widget.module.objective,
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
            state.tr(ru: 'Перед стартом', kk: 'Бастамас бұрын', en: 'Before'),
            widget.module.prerequisite,
          ),
          _infoRow(
            Icons.timer_outlined,
            state.tr(ru: 'Формат', kk: 'Формат', en: 'Format'),
            state.tr(
              ru: '5 этапов · теория, источник, практика и 2 проверки',
              kk: '5 кезең · теория, дереккөз, тәжірибе және 2 тексеру',
              en: '5 stages · concept, source, practice, and 2 checks',
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
              ru: 'Не запоминай без опоры',
              kk: 'Дәлелсіз жаттама',
              en: 'Learn with evidence',
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
            widget.module.sourceLocator,
          ),
          const SizedBox(height: 12),
          _sourceCard(
            Icons.record_voice_over_rounded,
            state.tr(
                ru: 'Компетенция наставника',
                kk: 'Ұстаз құзыреті',
                en: 'Mentor expertise'),
            widget.module.speakerDomain,
          ),
          const SizedBox(height: 12),
          _sourceCard(
            Icons.verified_user_rounded,
            state.tr(
                ru: 'Статус проверки',
                kk: 'Тексеру мәртебесі',
                en: 'Review status'),
            widget.module.reviewStatus,
            color: AppColors.skyLight,
          ),
        ],
      );

  Widget _quizStage(
    AppState state, {
    required String title,
    required String prompt,
    required List<String> options,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _stageHeading(
            icon: _step == 2 ? Icons.psychology_rounded : Icons.school_rounded,
            eyebrow: _step == 2
                ? state.tr(ru: 'БЕЗ ПОДСКАЗКИ', kk: 'КӨМЕКСІЗ', en: 'NO HINTS')
                : state.tr(ru: 'ФИНАЛ', kk: 'ФИНАЛ', en: 'FINAL'),
            title: title,
            subtitle: prompt,
          ),
          const SizedBox(height: 18),
          for (var index = 0; index < options.length; index++)
            _answerCard(index, options[index]),
          if (_answerRevealed) ...[
            const SizedBox(height: 6),
            _feedbackCard(state, _selectedAnswer == _correctIndex),
          ],
        ],
      );

  Widget _practiceStage(AppState state) {
    final labels = [
      state.tr(
        ru: 'Я могу объяснить цель своими словами',
        kk: 'Мақсатты өз сөзіммен түсіндіре аламын',
        en: 'I can explain the outcome in my own words',
      ),
      state.tr(
        ru: 'Я знаю, где проверить первоисточник',
        kk: 'Негізгі дереккөзді қайдан тексеруді білемін',
        en: 'I know where to verify the primary source',
      ),
      state.tr(
        ru: 'Я понимаю границу и когда спросить наставника',
        kk: 'Шегін және ұстаздан қашан сұрауды түсінемін',
        en: 'I know the boundary and when to ask a mentor',
      ),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _stageHeading(
          icon: Icons.extension_rounded,
          eyebrow: state.tr(
              ru: 'ПЕРЕНОС В ПРАКТИКУ', kk: 'ТӘЖІРИБЕ', en: 'TRANSFER'),
          title: state.tr(
            ru: 'Собери понимание',
            kk: 'Түсінікті жинақта',
            en: 'Build understanding',
          ),
          subtitle: state.tr(
            ru: 'Отметь каждый пункт только после короткого объяснения вслух.',
            kk: 'Әр тармақты дауыстап қысқаша түсіндіргеннен кейін белгіле.',
            en: 'Check each item only after explaining it aloud.',
          ),
        ),
        const SizedBox(height: 18),
        for (var index = 0; index < labels.length; index++)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Material(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(18),
              child: CheckboxListTile(
                key: ValueKey('curriculum-practice-$index'),
                value: _practiceChecks[index],
                onChanged: (value) => setState(
                  () => _practiceChecks[index] = value ?? false,
                ),
                controlAffinity: ListTileControlAffinity.leading,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(18),
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
      ],
    );
  }

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
        child: Text(
          correct
              ? state.tr(
                  ru: 'Верно. Ты связал модуль с его точным результатом и источником.',
                  kk: 'Дұрыс. Модульді нақты нәтижесімен және дереккөзімен байланыстырдың.',
                  en: 'Correct. You connected the module to its exact outcome and source.',
                )
              : state.tr(
                  ru: 'Пока нет. Вернись к формулировке выше и попробуй ещё раз.',
                  kk: 'Әзірге дұрыс емес. Жоғарыдағы тұжырымға оралып, қайталап көр.',
                  en: 'Not yet. Revisit the wording above and try again.',
                ),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      );

  Widget _bottomAction(AppState state) {
    final needsAnswer = (_step == 2 || _step == 4) && _selectedAnswer == null;
    final needsPractice =
        _step == 3 && !_practiceChecks.every((value) => value);
    final isWrongRetry = _answerRevealed && _selectedAnswer != _correctIndex;
    String label;
    if ((_step == 2 || _step == 4) && !_answerRevealed) {
      label = state.tr(ru: 'Проверить', kk: 'Тексеру', en: 'Check');
    } else if (isWrongRetry) {
      label = state.tr(
          ru: 'Попробовать ещё раз', kk: 'Қайталап көру', en: 'Try again');
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
    final score = _progress.masteryByModuleId[widget.module.id] ??
        (100 - (_mistakes * 10)).clamp(70, 100);
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
            widget.module.title,
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
                _resultMetric('$score%',
                    state.tr(ru: 'мастерство', kk: 'меңгеру', en: 'mastery')),
                Container(width: 1, height: 42, color: AppColors.border),
                _resultMetric('${_progress.completedCount}/570',
                    state.tr(ru: 'пройдено', kk: 'аяқталды', en: 'complete')),
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
            onPressed: _replay,
            icon: const Icon(Icons.replay_rounded),
            label: Text(state.tr(
              ru: 'Повторить модуль',
              kk: 'Модульді қайталау',
              en: 'Repeat module',
            )),
          ),
          TextButton(
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
