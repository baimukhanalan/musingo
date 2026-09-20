import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

export '../models/daily_ayah.dart';

import '../models/daily_ayah.dart';
import '../services/app_state.dart';
import '../services/backend_service.dart';
import '../services/haptics_service.dart';
import '../services/quran_audio_player.dart';
import '../utils/colors.dart';
import '../utils/runtime_environment.dart';
import 'translation_review_note.dart';

/// Карточка «Аят дня» для главного экрана. Показывает один и тот же аят в
/// течение календарного дня, с прослушиванием через существующий
/// QuranAudioPlayer (тот же источник аудио, что и в уроках).
class DailyAyahCard extends StatefulWidget {
  /// Дата для выбора аята. По умолчанию — сегодня; параметр нужен для тестов.
  final DateTime? date;
  final DateTime Function()? now;
  final QuranAudioPlayer Function()? audioPlayerFactory;

  const DailyAyahCard({
    super.key,
    this.date,
    this.now,
    this.audioPlayerFactory,
  });

  @override
  State<DailyAyahCard> createState() => _DailyAyahCardState();
}

class _DailyAyahCardState extends State<DailyAyahCard>
    with WidgetsBindingObserver {
  QuranAudioPlayer? _audioPlayer;
  StreamSubscription<QuranAudioPlaybackState>? _playbackSubscription;
  Future<void>? _preparation;
  int? _preparedAyah;
  int _request = 0;
  Timer? _dayChangeTimer;
  bool _playing = false;
  bool _loading = false;
  // Пул строим один раз (список фиксирован на время жизни виджета), а сам
  // «аят дня» выбираем по ТЕКУЩЕЙ дате при каждом build — так карточка не
  // залипает на вчерашнем аяте, если приложение было открыто через полночь.
  late final List<AyahOfDay> _pool = DailyAyahData.buildPool();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _scheduleDayChange();
    // Warm only today's short recitation after the first frame; never autoplay.
    WidgetsBinding.instance.addPostFrameCallback((_) => _prepareToday());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _dayChangeTimer?.cancel();
    _request++;
    _playbackSubscription?.cancel();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant DailyAyahCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.date != widget.date || oldWidget.now != widget.now) {
      _scheduleDayChange();
      _prepareToday();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // При возврате на передний план (в т.ч. после полуночи) пересобираем
    // карточку, чтобы «аят дня» пересчитался под новую дату.
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
      _scheduleDayChange();
      _prepareToday();
    }
  }

  DateTime _currentDate() =>
      widget.date ?? widget.now?.call() ?? DateTime.now();

  void _scheduleDayChange() {
    _dayChangeTimer?.cancel();
    if (widget.date != null) return;

    final now = _currentDate();
    final delay = DailyAyahData.untilNextLocalDay(now) +
        const Duration(milliseconds: 100);
    _dayChangeTimer = Timer(delay, () {
      if (!mounted) return;
      setState(() {});
      _prepareToday();
      _scheduleDayChange();
    });
  }

  /// Аят на текущий календарный день (или на дату из теста).
  AyahOfDay? get _ayah => DailyAyahData.ofDay(_currentDate(), pool: _pool);

  String _cdnSource(AyahOfDay ayah) =>
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/'
      '${ayah.globalAyahNumber}.mp3';

  QuranAudioPlayer get _player {
    if (_audioPlayer case final player?) return player;
    final player = widget.audioPlayerFactory?.call() ?? QuranAudioPlayer();
    _audioPlayer = player;
    _playbackSubscription = player.playbackStateStream.listen((event) {
      if (!mounted || (!_loading && !_playing)) return;
      // Initial source errors are handled by the bounded fallback below.
      if (event.error != null && _loading) return;
      if (event.completed || event.error != null) {
        setState(() {
          _playing = false;
          _loading = false;
        });
        if (event.error != null) _showAudioError();
      } else if (event.playing || event.buffering) {
        setState(() {
          _loading = event.buffering;
          _playing = event.playing && !event.buffering;
        });
      }
    });
    return player;
  }

  void _prepareToday() {
    if (!mounted || (isFlutterTest && widget.audioPlayerFactory == null)) {
      return;
    }
    final ayah = _ayah;
    if (ayah == null || _preparedAyah == ayah.globalAyahNumber) return;
    _request++;
    _playing = false;
    _loading = false;
    _preparedAyah = ayah.globalAyahNumber;
    final number = _preparedAyah;
    _preparation = _player
        .setUrl(_cdnSource(ayah))
        .timeout(const Duration(seconds: 8))
        .catchError((Object _) {
      if (_preparedAyah == number) _preparedAyah = null;
    });
  }

  Future<void> _toggleListen() async {
    final ayah = _ayah;
    if (ayah == null) return;
    HapticsService.tap();
    final player = _player;

    if (_playing || _loading) {
      _request++;
      setState(() {
        _playing = false;
        _loading = false;
      });
      await player.stop();
      return;
    }

    // Start the already warmed CDN directly. The proxy is a fallback, so a
    // server cold start is no longer on the normal playback path.
    final sources = <String>[
      _cdnSource(ayah),
      if (BackendService.hasConfiguredApiUrl)
        '${BackendService.apiBaseUrl}/api/muslingo/quran/audio/${ayah.globalAyahNumber}',
    ];

    final request = ++_request;
    setState(() => _loading = true);
    for (var index = 0; index < sources.length; index++) {
      try {
        if (index == 0 && _preparedAyah == ayah.globalAyahNumber) {
          await _preparation;
          if (!mounted || request != _request) return;
        }
        if (index == 0 && _preparedAyah == ayah.globalAyahNumber) {
          await player.play().timeout(const Duration(seconds: 8));
        } else {
          await player
              .playUrl(sources[index])
              .timeout(const Duration(seconds: 8));
          if (!mounted || request != _request) return;
          _preparedAyah = ayah.globalAyahNumber;
        }
        if (!mounted || request != _request) return;
        setState(() {
          _loading = false;
          _playing = true;
        });
        return;
      } catch (_) {
        if (!mounted || request != _request) return;
        await player.stop();
        if (!mounted || request != _request) return;
        _preparedAyah = null;
      }
    }

    if (!mounted || request != _request) return;
    setState(() {
      _playing = false;
      _loading = false;
    });
    _showAudioError();
  }

  void _showAudioError() {
    final state = context.read<AppState>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.tr(
          ru: 'Не удалось загрузить аудио. Проверьте соединение и попробуйте ещё раз.',
          kk: 'Аудио жүктелмеді. Интернет байланысын тексеріп, қайталап көріңіз.',
          en: 'Audio could not load. Check your connection and try again.',
        )),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final ayah = _ayah;
    if (ayah == null) return const SizedBox.shrink();
    final state = context.watch<AppState>();

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 2),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.sky, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny_rounded,
                    color: AppColors.gold, size: 20),
                const SizedBox(width: 7),
                Expanded(
                    child: Text(
                  state.tr(
                    ru: 'АЯТ ДНЯ',
                    kk: 'КҮН АЯТЫ',
                    en: 'AYAH OF THE DAY',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                )),
                const SizedBox(width: 8),
                Flexible(
                    child: Text(
                  state.tr(
                    ru: 'аят №${ayah.globalAyahNumber}',
                    kk: '${ayah.globalAyahNumber}-аят',
                    en: 'verse #${ayah.globalAyahNumber}',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textGrey,
                  ),
                )),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              ayah.arabic,
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: const TextStyle(
                fontFamily: 'Amiri',
                fontSize: 26,
                height: 1.7,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              ayah.transliterationFor(state.locale),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textGrey,
              ),
            ),
            if (ayah.translationFor(state.locale) case final translation?) ...[
              const SizedBox(height: 10),
              Container(height: 1, color: AppColors.border),
              const SizedBox(height: 10),
              Text(
                translation,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14,
                  height: 1.4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              TranslationReviewNote(locale: state.locale.code),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: _toggleListen,
                icon: _loading
                    ? const SizedBox.square(
                        dimension: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(
                        _playing ? Icons.stop_rounded : Icons.volume_up_rounded,
                        size: 20,
                      ),
                label: Text(_loading
                    ? state.tr(
                        ru: 'Загрузка · отменить',
                        kk: 'Жүктелуде · тоқтату',
                        en: 'Loading · cancel')
                    : _playing
                        ? state.tr(ru: 'Остановить', kk: 'Тоқтату', en: 'Stop')
                        : state.tr(
                            ru: 'Прослушать', kk: 'Тыңдау', en: 'Listen')),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  textStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
