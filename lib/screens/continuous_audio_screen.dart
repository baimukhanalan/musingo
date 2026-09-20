import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/curriculum_module.dart';
import '../services/app_state.dart';
import '../services/curriculum_repository.dart';
import '../services/lesson_content_localization.dart';
import '../services/speech_synthesizer.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_card.dart';

class ContinuousAudioScreen extends StatefulWidget {
  final CurriculumModule? startModule;
  final Future<List<CurriculumModule>>? modulesFuture;
  final SpeechSynthesizer? speechSynthesizer;

  const ContinuousAudioScreen({
    super.key,
    this.startModule,
    @visibleForTesting this.modulesFuture,
    @visibleForTesting this.speechSynthesizer,
  });

  @override
  State<ContinuousAudioScreen> createState() => _ContinuousAudioScreenState();
}

class _ContinuousAudioScreenState extends State<ContinuousAudioScreen>
    with WidgetsBindingObserver {
  late final SpeechSynthesizer _tts;
  List<CurriculumModule> _modules = const [];
  bool _loading = true;
  bool _playing = false;
  bool _paused = false;
  String? _error;
  int _index = 0;
  int _sessionMinutes = 10;
  int _runToken = 0;
  DateTime? _sessionDeadline;
  String? _languageCode;

  CurriculumModule? get _current =>
      _modules.isEmpty ? null : _modules[_index.clamp(0, _modules.length - 1)];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tts = widget.speechSynthesizer ?? SpeechSynthesizer();
    _tts.setErrorHandler((message) {
      if (!mounted) return;
      setState(() {
        _playing = false;
        _paused = false;
        _error = message;
      });
    });
    unawaited(_load());
  }

  Future<void> _load() async {
    try {
      final modules =
          await (widget.modulesFuture ?? CurriculumRepository.load());
      var index = 0;
      final requestedId = widget.startModule?.id;
      if (requestedId != null) {
        final found = modules.indexWhere((module) => module.id == requestedId);
        if (found >= 0) index = found;
      }
      if (!mounted) return;
      setState(() {
        _modules = modules;
        _index = index;
        _loading = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = 'library_unavailable';
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = context.watch<AppState>().locale.code;
    final changed = _languageCode != null && _languageCode != locale;
    _languageCode = locale;
    if (changed && _playing) {
      final token = ++_runToken;
      unawaited(_restartInSelectedLanguage(token));
    }
  }

  Future<void> _restartInSelectedLanguage(int token) async {
    await _tts.stop();
    if (!mounted || token != _runToken || !_playing || _paused) return;
    await _run(token);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.detached) unawaited(_stop());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _runToken++;
    unawaited(_tts.stop());
    super.dispose();
  }

  Future<void> _start() async {
    if (_current == null) return;
    final token = ++_runToken;
    _sessionDeadline = DateTime.now().add(Duration(minutes: _sessionMinutes));
    setState(() {
      _playing = true;
      _paused = false;
      _error = null;
    });
    await _run(token);
  }

  Future<void> _run(int token) async {
    while (mounted && token == _runToken && _playing && !_paused) {
      if (_sessionDeadline case final deadline?
          when DateTime.now().isAfter(deadline)) {
        await _stop();
        return;
      }
      final original = _current;
      if (original == null) return;
      try {
        final state = context.read<AppState>();
        final module = LessonContentLocalization.localizeModule(
            original, state.locale.code);
        await _tts.setLanguage(_voiceLocale(state));
        await _tts.setSpeechRate(0.42);
        await _tts.setPitch(1);
        await _tts.setVolume(1);
        await _tts.awaitSpeakCompletion(true);
        if (!mounted || token != _runToken || !_playing || _paused) return;
        final intro = state.tr(
          ru: 'Модуль ${module.id}. ${module.title}. Цель. ${module.objective}',
          kk: '${module.id} модулі. ${module.title}. Мақсат. ${module.objective}',
          en: 'Module ${module.id}. ${module.title}. Objective. ${module.objective}',
        );
        await _tts.speak(intro);
        if (!mounted || token != _runToken || !_playing || _paused) return;
        await Future<void>.delayed(const Duration(seconds: 2));
        if (!mounted || token != _runToken || !_playing || _paused) return;
        setState(() => _index = (_index + 1) % _modules.length);
      } catch (_) {
        if (!mounted || token != _runToken) return;
        setState(() {
          _playing = false;
          _error = 'playback_failed';
        });
        return;
      }
    }
  }

  String _voiceLocale(AppState state) {
    switch (state.locale.code) {
      case 'kk':
        return 'kk-KZ';
      case 'en':
        return 'en-US';
      default:
        return 'ru-RU';
    }
  }

  Future<void> _pause() async {
    _runToken++;
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _playing = false;
      _paused = true;
    });
  }

  Future<void> _resume() async {
    if (_current == null) return;
    final token = ++_runToken;
    setState(() {
      _playing = true;
      _paused = false;
      _error = null;
    });
    await _run(token);
  }

  Future<void> _stop() async {
    _runToken++;
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _playing = false;
      _paused = false;
      _sessionDeadline = null;
    });
  }

  Future<void> _move(int delta) async {
    if (_modules.isEmpty) return;
    final wasPlaying = _playing;
    _runToken++;
    await _tts.stop();
    if (!mounted) return;
    setState(() {
      _index = (_index + delta) % _modules.length;
      if (_index < 0) _index += _modules.length;
      _playing = false;
      _paused = wasPlaying || _paused;
    });
    if (wasPlaying) await _resume();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final original = _current;
    final current = original == null
        ? null
        : LessonContentLocalization.localizeModule(original, state.locale.code);
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 30),
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.maybePop(context),
                    tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                  Expanded(
                    child: Text(
                      state.tr(
                        ru: 'Непрерывный аудиорежим',
                        kk: 'Үздіксіз аудиорежим',
                        en: 'Continuous audio mode',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyDark,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              PremiumCard(
                padding: const EdgeInsets.all(18),
                child: Text(
                  state.tr(
                    ru: 'Muslingo автоматически читает модули по порядку, делает паузу между ними и продолжает без нажатий. Экран можно погасить на поддерживаемых устройствах; браузер может ограничить фоновое воспроизведение.',
                    kk: 'Muslingo модульдерді ретімен автоматты оқиды, арасында үзіліс жасайды және басусыз жалғастырады. Қолдайтын құрылғыларда экранды өшіруге болады; браузер фондық дыбысты шектеуі мүмкін.',
                    en: 'Muslingo reads modules in order, pauses between them, and continues hands-free. Supported devices may keep playing with the screen off; browsers can restrict background audio.',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                state.tr(ru: 'Длительность', kk: 'Ұзақтығы', en: 'Duration'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  color: AppColors.navy,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [
                  for (final minutes in const [5, 10, 15, 30])
                    ChoiceChip(
                      key: ValueKey('audio-duration-$minutes'),
                      selected: _sessionMinutes == minutes,
                      onSelected: _playing
                          ? null
                          : (_) => setState(() => _sessionMinutes = minutes),
                      label: Text(
                          '$minutes ${state.tr(ru: 'мин', kk: 'мин', en: 'min')}'),
                    ),
                ],
              ),
              const SizedBox(height: 20),
              if (_loading)
                const Center(child: CircularProgressIndicator())
              else if (current != null)
                PremiumCard(
                  padding: const EdgeInsets.all(22),
                  child: Column(
                    children: [
                      Container(
                        width: 76,
                        height: 76,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.skyLight,
                        ),
                        child: Icon(
                          _playing
                              ? Icons.graphic_eq_rounded
                              : Icons.headphones_rounded,
                          size: 38,
                          color: AppColors.navy,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        '${_index + 1} / ${_modules.length} · ${current.id}',
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w900,
                          color: AppColors.sky,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        current.title,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 20,
                          height: 1.25,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navyDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        current.objective,
                        maxLines: 5,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            onPressed: () => _move(-1),
                            tooltip: state.tr(
                                ru: 'Предыдущий',
                                kk: 'Алдыңғы',
                                en: 'Previous'),
                            icon: const Icon(Icons.skip_previous_rounded),
                          ),
                          const SizedBox(width: 14),
                          IconButton.filled(
                            key: const ValueKey('continuous-audio-toggle'),
                            iconSize: 34,
                            onPressed: _playing
                                ? _pause
                                : (_paused ? _resume : _start),
                            tooltip: _playing
                                ? state.tr(
                                    ru: 'Пауза', kk: 'Кідірту', en: 'Pause')
                                : state.tr(
                                    ru: 'Начать', kk: 'Бастау', en: 'Start'),
                            icon: Icon(_playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded),
                          ),
                          const SizedBox(width: 14),
                          IconButton.filledTonal(
                            onPressed: () => _move(1),
                            tooltip: state.tr(
                                ru: 'Следующий', kk: 'Келесі', en: 'Next'),
                            icon: const Icon(Icons.skip_next_rounded),
                          ),
                        ],
                      ),
                      if (_playing || _paused) ...[
                        const SizedBox(height: 12),
                        TextButton.icon(
                          onPressed: _stop,
                          icon: const Icon(Icons.stop_rounded),
                          label: Text(state.tr(
                            ru: 'Завершить сессию',
                            kk: 'Сессияны аяқтау',
                            en: 'End session',
                          )),
                        ),
                      ],
                    ],
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  state.tr(
                    ru: 'Не удалось продолжить воспроизведение. Проверь настройки озвучивания устройства.',
                    kk: 'Ойнатуды жалғастыру мүмкін болмады. Құрылғының дыбыстау баптауларын тексер.',
                    en: 'Playback could not continue. Check the device speech settings.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
