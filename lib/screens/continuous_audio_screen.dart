import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/curriculum_audio.dart';
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
  final bool embedded;

  const ContinuousAudioScreen({
    super.key,
    this.startModule,
    @visibleForTesting this.modulesFuture,
    @visibleForTesting this.speechSynthesizer,
    this.embedded = false,
  });

  @override
  State<ContinuousAudioScreen> createState() => _ContinuousAudioScreenState();
}

class _ContinuousAudioScreenState extends State<ContinuousAudioScreen>
    with WidgetsBindingObserver {
  late final SpeechSynthesizer _tts;
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();
  List<CurriculumModule> _modules = const [];
  List<CurriculumModule> _queue = const [];
  String _query = '';
  String _track = 'all';
  bool _loading = true;
  bool _playing = false;
  bool _paused = false;
  bool _speechActive = false;
  Future<bool>? _pendingSpeechStop;
  String? _error;
  int _index = 0;
  int _sectionIndex = 0;
  int _sessionMinutes = 10;
  int _runToken = 0;
  DateTime? _sessionDeadline;
  Duration? _remaining;
  Timer? _sessionTimer;
  String? _languageCode;

  CurriculumModule? get _current =>
      _queue.isEmpty ? null : _queue[_index.clamp(0, _queue.length - 1)];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _tts = widget.speechSynthesizer ?? SpeechSynthesizer();
    _tts.setErrorHandler((message) {
      if (!mounted || !_playing) return;
      _runToken++;
      _speechActive = false;
      _freezeTimer();
      setState(() {
        _playing = false;
        _paused = true;
        _error = 'playback_failed';
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
        _queue = CurriculumAudioCatalog.queue(modules);
        _index = index;
        _loading = false;
        _error = modules.isEmpty ? 'library_unavailable' : null;
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
    final stopped = await _stopSpeech();
    if (!stopped) {
      _freezeTimer();
      if (mounted && token == _runToken) {
        setState(() {
          _playing = false;
          _paused = true;
        });
      }
      return;
    }
    if (!mounted || token != _runToken || !_playing || _paused) return;
    _armTimer(token);
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
    _sessionTimer?.cancel();
    unawaited(_stopSpeech(reportError: false));
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<bool> _stopSpeech({bool reportError = true}) {
    if (_pendingSpeechStop case final pending?) return pending;
    // Browsing a library or leaving before the first utterance must not invoke
    // a native speech plugin. Some platforms have no TTS engine configured.
    if (!_speechActive) return Future.value(true);
    final pending = Future<void>.sync(_tts.stop).then<bool>((_) {
      _speechActive = false;
      return true;
    }, onError: (Object error, StackTrace stack) {
      // Keep the uncertain active state so a retry must stop the prior
      // utterance successfully before starting another one.
      _speechActive = true;
      // An unavailable/failed engine is a recoverable UI state, not an
      // unhandled asynchronous exception after navigating away.
      if (mounted && reportError) {
        setState(() => _error = 'playback_failed');
      }
      return false;
    }).whenComplete(() => _pendingSpeechStop = null);
    _pendingSpeechStop = pending;
    return pending;
  }

  void _freezeTimer() {
    _sessionTimer?.cancel();
    if (_sessionDeadline case final deadline?) {
      final left = deadline.difference(DateTime.now());
      _remaining = left.isNegative ? Duration.zero : left;
    }
    _sessionDeadline = null;
  }

  void _armTimer(int token) {
    _sessionTimer?.cancel();
    final duration = _sessionDeadline?.difference(DateTime.now()) ??
        _remaining ??
        Duration(minutes: _sessionMinutes);
    _sessionDeadline = DateTime.now().add(duration);
    _sessionTimer = Timer(duration.isNegative ? Duration.zero : duration, () {
      if (mounted && token == _runToken && _playing) unawaited(_stop());
    });
  }

  Future<void> _start() async {
    if (_current == null) return;
    final token = ++_runToken;
    if ((_speechActive || _pendingSpeechStop != null) && !await _stopSpeech()) {
      return;
    }
    if (!mounted || token != _runToken) return;
    _remaining = Duration(minutes: _sessionMinutes);
    _sessionDeadline = null;
    setState(() {
      _sectionIndex = 0;
      _playing = true;
      _paused = false;
      _error = null;
    });
    _armTimer(token);
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
        final outline =
            CurriculumAudioOutline.fromModule(original, state.locale.code);
        await _tts.setLanguage(_voiceLocale(state));
        await _tts.setSpeechRate(0.42);
        await _tts.setPitch(1);
        await _tts.setVolume(1);
        await _tts.awaitSpeakCompletion(true);
        if (!mounted || token != _runToken || !_playing || _paused) return;
        while (_sectionIndex < outline.sections.length) {
          _speechActive = true;
          final result = await _tts.speak(outline.sections[_sectionIndex]);
          if (!mounted || token != _runToken || !_playing || _paused) return;
          _speechActive = false;
          if (result != 1) throw StateError('Speech did not start.');
          setState(() => _sectionIndex++);
          if (_sectionIndex < outline.sections.length) {
            await Future<void>.delayed(const Duration(milliseconds: 700));
            if (!mounted || token != _runToken || !_playing || _paused) return;
          }
        }
        await Future<void>.delayed(const Duration(seconds: 2));
        if (!mounted || token != _runToken || !_playing || _paused) return;
        if (_index + 1 >= _queue.length) {
          await _stop();
          return;
        }
        setState(() {
          _index++;
          _sectionIndex = 0;
        });
      } catch (_) {
        if (!mounted || token != _runToken) return;
        await _stopSpeech(reportError: false);
        if (!mounted || token != _runToken) return;
        _freezeTimer();
        setState(() {
          _playing = false;
          _paused = true;
          _error = 'playback_failed';
        });
        return;
      }
    }
  }

  String _voiceLocale(AppState state) {
    switch (state.locale.code) {
      case 'ar':
        return 'ar-SA';
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
    _freezeTimer();
    setState(() {
      _playing = false;
      _paused = true;
    });
    await _stopSpeech();
  }

  Future<void> _resume() async {
    if (_current == null) return;
    final token = ++_runToken;
    if ((_speechActive || _pendingSpeechStop != null) && !await _stopSpeech()) {
      return;
    }
    if (!mounted || token != _runToken) return;
    if (_remaining == Duration.zero) return _start();
    setState(() {
      _playing = true;
      _paused = false;
      _error = null;
    });
    _armTimer(token);
    await _run(token);
  }

  Future<void> _stop() async {
    _runToken++;
    _sessionTimer?.cancel();
    _remaining = null;
    if (mounted) {
      setState(() {
        _playing = false;
        _paused = false;
        _sessionDeadline = null;
        _sectionIndex = 0;
      });
    }
    await _stopSpeech();
  }

  Future<void> _selectModule(int index, {bool revealPlayer = false}) async {
    if (index < 0 || index >= _queue.length) return;
    final wasPlaying = _playing;
    final token = ++_runToken;
    _freezeTimer();
    setState(() {
      _index = index;
      _sectionIndex = 0;
      _playing = false;
      _paused = wasPlaying || _paused;
      _error = null;
    });
    final stopped = await _stopSpeech();
    if (!mounted || token != _runToken) return;
    if (revealPlayer && _scrollController.hasClients) {
      unawaited(_scrollController.animateTo(0,
          duration: const Duration(milliseconds: 240), curve: Curves.easeOut));
    }
    if (wasPlaying && stopped) unawaited(_resume());
  }

  Future<void> _selectTrack(String track) async {
    if (_track == track) return;
    final currentId = _current?.id;
    final stopped = _stop();
    setState(() {
      _track = track;
      _queue = CurriculumAudioCatalog.queue(_modules, track: track);
      final found = _queue.indexWhere((module) => module.id == currentId);
      _index = found < 0 ? 0 : found;
      _query = '';
      _searchController.clear();
      _error = null;
    });
    await stopped;
  }

  Future<void> _openInteractive() async {
    final module = _current;
    if (module == null) return;
    await _stop();
    if (!mounted) return;
    await Navigator.pushNamed(context, '/curriculum-module', arguments: module);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final original = _current;
    final current = original == null
        ? null
        : LessonContentLocalization.localizeModule(original, state.locale.code);
    final filtered = CurriculumAudioCatalog.search(_queue,
        query: _query, locale: state.locale.code);
    final content = CustomScrollView(
      key: const ValueKey('continuous-audio-scroll'),
      controller: _scrollController,
      slivers: [
        SliverPadding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 0),
            sliver: SliverList.list(children: [
              if (!widget.embedded)
                Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      tooltip: state.tr(
                          ru: 'Назад', kk: 'Артқа', en: 'Back', ar: 'رجوع'),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        state.tr(
                          ru: 'Непрерывный аудиорежим',
                          kk: 'Үздіксіз аудиорежим',
                          en: 'Continuous audio mode',
                          ar: 'الاستماع المتواصل',
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
              Text(
                  state.tr(
                    ru: 'Аудиообзоры ${_modules.length} тем · синтезированный голос',
                    kk: '${_modules.length} тақырыптың аудиошолуы · синтезделген дауыс',
                    en: '${_modules.length} topic outlines · synthetic voice',
                    ar: 'ملخصات ${_modules.length} موضوعًا · صوت آلي',
                  ),
                  style: const TextStyle(
                      fontWeight: FontWeight.w800, color: AppColors.textGrey)),
              Material(
                type: MaterialType.transparency,
                child: ExpansionTile(
                  key: const ValueKey('audio-library-about'),
                  tilePadding: EdgeInsets.zero,
                  title: Text(state.tr(
                      ru: 'Что здесь можно слушать',
                      kk: 'Мұнда не тыңдауға болады',
                      en: 'About these audio outlines',
                      ar: 'ما الذي يمكن الاستماع إليه؟')),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Text(
                          state.tr(
                            ru: 'Цель, подготовка, источник и самопроверка из плана модуля. Это не полная лекция, не тафсир и не запись чтеца. Арабский текст здесь не озвучивается: для чтения Корана используй плеер в разделе «Коран». Темы выбранного курса идут по порядку. После паузы текущий фрагмент начинается заново; прослушивание не начисляет баллы и не завершает урок. Фоновая работа зависит от устройства и браузера.',
                            kk: 'Модуль жоспарындағы мақсат, дайындық, дереккөз және өзін-өзі тексеру. Бұл толық дәріс, тәпсір немесе қаридың жазбасы емес. Арабша мәтін мұнда дыбысталмайды: Құранды тыңдау үшін «Құран» бөліміндегі плеерді қолдан. Таңдалған курс ретімен ойнатылады. Кідірістен кейін ағымдағы үзінді басынан басталады; тыңдау ұпай қоспайды, сабақты аяқтамайды. Фондық жұмыс құрылғы мен браузерге байланысты.',
                            en: 'The objective, preparation, source reference, and self-check from each module plan. These are not full lectures, tafsir, or reciter recordings. Arabic text is not synthesized here; use the Quran player for recitation. Your selected course plays in order. Resume restarts the current section; listening does not award points or complete a lesson. Background playback depends on your device and browser.',
                            ar: 'الهدف والتحضير والمصادر والتقييم الذاتي من خطة كل وحدة. هذه ليست محاضرات كاملة أو تفسيرًا أو تسجيلات لقارئ. لا تُقرأ الآيات بصوت آلي هنا؛ استمع إلى التلاوة في قسم القرآن. تُشغّل موضوعات الدورة بالترتيب. بعد التوقف المؤقت يبدأ المقطع الحالي من جديد؛ ولا يمنح الاستماع نقاطًا أو يسجّل إكمال الدرس. يعتمد التشغيل في الخلفية على الجهاز والمتصفح.',
                          ),
                          style: const TextStyle(
                              height: 1.4, color: AppColors.textGrey)),
                    )
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Text(
                state.tr(
                    ru: 'Длительность',
                    kk: 'Ұзақтығы',
                    en: 'Duration',
                    ar: 'المدة'),
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
                      onSelected: _playing || _paused
                          ? null
                          : (_) => setState(() => _sessionMinutes = minutes),
                      label: Text(
                          '$minutes ${state.tr(ru: 'мин', kk: 'мин', en: 'min', ar: 'د')}'),
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
                        '${_index + 1} / ${_queue.length} · ${current.id}',
                        key: const ValueKey('audio-current-position'),
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
                      Text(
                          state.tr(
                              ru:
                                  'Фрагмент ${(_sectionIndex + 1).clamp(1, 4)} из 4',
                              kk:
                                  '4 үзіндінің ${(_sectionIndex + 1).clamp(1, 4)}-сі',
                              en:
                                  'Section ${(_sectionIndex + 1).clamp(1, 4)} of 4',
                              ar:
                                  'المقطع ${(_sectionIndex + 1).clamp(1, 4)} من 4'),
                          style: const TextStyle(
                              fontSize: 12, color: AppColors.textGrey)),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          IconButton.filledTonal(
                            key: const ValueKey('continuous-audio-previous'),
                            onPressed: _index > 0
                                ? () => _selectModule(_index - 1)
                                : null,
                            tooltip: state.tr(
                                ru: 'Предыдущий',
                                kk: 'Алдыңғы',
                                en: 'Previous',
                                ar: 'السابق'),
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
                                    ru: 'Пауза',
                                    kk: 'Кідірту',
                                    en: 'Pause',
                                    ar: 'إيقاف مؤقت')
                                : state.tr(
                                    ru: 'Начать',
                                    kk: 'Бастау',
                                    en: 'Start',
                                    ar: 'ابدأ'),
                            icon: Icon(_playing
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded),
                          ),
                          const SizedBox(width: 14),
                          IconButton.filledTonal(
                            key: const ValueKey('continuous-audio-next'),
                            onPressed: _index + 1 < _queue.length
                                ? () => _selectModule(_index + 1)
                                : null,
                            tooltip: state.tr(
                                ru: 'Следующий',
                                kk: 'Келесі',
                                en: 'Next',
                                ar: 'التالي'),
                            icon: const Icon(Icons.skip_next_rounded),
                          ),
                        ],
                      ),
                      if (_playing || _paused) ...[
                        const SizedBox(height: 12),
                        TextButton.icon(
                          key: const ValueKey('continuous-audio-stop'),
                          onPressed: _stop,
                          icon: const Icon(Icons.stop_rounded),
                          label: Text(state.tr(
                            ru: 'Завершить сессию',
                            kk: 'Сессияны аяқтау',
                            en: 'End session',
                            ar: 'إنهاء الجلسة',
                          )),
                        ),
                      ],
                      TextButton.icon(
                        key: const ValueKey('audio-open-module'),
                        onPressed: _openInteractive,
                        icon: const Icon(Icons.school_outlined),
                        label: Text(state.tr(
                            ru: 'Открыть интерактивный модуль',
                            kk: 'Интерактивті модульді ашу',
                            en: 'Open interactive module',
                            ar: 'فتح الوحدة التفاعلية')),
                      ),
                      Material(
                        type: MaterialType.transparency,
                        child: ExpansionTile(
                          key: const ValueKey('audio-outline-sources'),
                          tilePadding: EdgeInsets.zero,
                          title: Text(
                              state.tr(
                                  ru: 'Источники этого обзора',
                                  kk: 'Осы шолудың дереккөздері',
                                  en: 'Sources for this outline',
                                  ar: 'مصادر هذا الملخص'),
                              style: const TextStyle(fontSize: 13)),
                          children: [
                            SelectableText(current.sourceLocator,
                                style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.4,
                                    color: AppColors.textGrey))
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(
                  _error == 'library_unavailable'
                      ? state.tr(
                          ru: 'Не удалось загрузить список тем.',
                          kk: 'Тақырыптар тізімі жүктелмеді.',
                          en: 'Could not load the topic library.',
                          ar: 'تعذّر تحميل مكتبة الموضوعات.')
                      : state.tr(
                          ru: 'Не удалось продолжить воспроизведение. Проверь настройки озвучивания устройства.',
                          kk: 'Ойнатуды жалғастыру мүмкін болмады. Құрылғының дыбыстау баптауларын тексер.',
                          en: 'Playback could not continue. Check the device speech settings.',
                          ar: 'تعذّر متابعة التشغيل. تحقّق من إعدادات الصوت على الجهاز.',
                        ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: AppColors.error),
                ),
              ],
              const SizedBox(height: 24),
              Text(
                  state.tr(
                      ru: 'Выбери тему',
                      kk: 'Тақырыпты таңда',
                      en: 'Choose a topic',
                      ar: 'اختر موضوعًا'),
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 20,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyDark)),
              const SizedBox(height: 10),
              TextField(
                key: const ValueKey('audio-library-search'),
                controller: _searchController,
                onChanged: (value) => setState(() => _query = value),
                decoration: InputDecoration(
                  hintText: state.tr(
                      ru: 'Название или номер темы',
                      kk: 'Тақырып атауы немесе нөмірі',
                      en: 'Topic title or number',
                      ar: 'عنوان الموضوع أو رقمه'),
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _query.isEmpty
                      ? null
                      : IconButton(
                          tooltip: state.tr(
                              ru: 'Очистить поиск',
                              kk: 'Іздеуді тазарту',
                              en: 'Clear search',
                              ar: 'مسح البحث'),
                          onPressed: () {
                            _searchController.clear();
                            setState(() => _query = '');
                          },
                          icon: const Icon(Icons.close_rounded),
                        ),
                ),
              ),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(children: [
                  for (final track in ['all', ...CurriculumAudioCatalog.tracks])
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        key: ValueKey('audio-track-$track'),
                        selected: _track == track,
                        onSelected: (_) => _selectTrack(track),
                        label: Text(track == 'all'
                            ? state.tr(
                                ru: 'Все ${_modules.length}',
                                kk: 'Барлық ${_modules.length}',
                                en: 'All ${_modules.length}',
                                ar: 'الكل ${_modules.length}')
                            : '${LessonContentLocalization.trackTitle(track, state.locale.code)} · ${_modules.where((module) => module.track == track).length}'),
                      ),
                    ),
                ]),
              ),
              const SizedBox(height: 10),
              Text(
                  state.tr(
                      ru:
                          'Найдено: ${filtered.length} · В очереди: ${_queue.length}',
                      kk:
                          'Табылды: ${filtered.length} · Кезекте: ${_queue.length}',
                      en: 'Found: ${filtered.length} · Queue: ${_queue.length}',
                      ar:
                          'النتائج: ${filtered.length} · قائمة التشغيل: ${_queue.length}'),
                  key: const ValueKey('audio-library-count'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, color: AppColors.textGrey)),
              if (filtered.isEmpty && !_loading)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(state.tr(
                      ru: 'Темы не найдены. Попробуй другое название.',
                      kk: 'Тақырып табылмады. Басқа атауды іздеп көр.',
                      en: 'No matching topics. Try another title.',
                      ar: 'لم يُعثر على موضوعات مطابقة. جرّب عنوانًا آخر.')),
                ),
              const SizedBox(height: 8),
            ])),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(18, 0, 18, 30),
          sliver: SliverList.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final original = filtered[index];
              final module = LessonContentLocalization.localizeModule(
                  original, state.locale.code);
              final selected = original.id == _current?.id;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: selected
                      ? AppColors.skyLight
                      : Colors.white.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(16),
                  child: ListTile(
                    key: ValueKey('audio-topic-${original.id}'),
                    selected: selected,
                    leading: Icon(
                        selected && _playing
                            ? Icons.graphic_eq_rounded
                            : Icons.headphones_rounded,
                        color: AppColors.navy),
                    title: Text('${module.id} · ${module.title}',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w800,
                            color: AppColors.navyDark)),
                    subtitle: Text(LessonContentLocalization.trackTitle(
                        module.track, state.locale.code)),
                    trailing: selected
                        ? const Icon(Icons.check_circle_rounded,
                            color: AppColors.navy)
                        : null,
                    onTap: () => _selectModule(
                        _queue.indexWhere((item) => item.id == original.id),
                        revealPlayer: true),
                  ),
                ),
              );
            },
          ),
        )
      ],
    );
    if (widget.embedded) return content;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(child: content),
      ),
    );
  }
}
