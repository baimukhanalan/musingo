import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/backend_service.dart';
import '../services/haptics_service.dart';
import '../services/lesson_data.dart';
import '../services/quran_audio_player.dart';
import '../utils/colors.dart';

/// Один проверенный аят для карточки «Аят дня». Собирается ТОЛЬКО из уже
/// существующих уроков LessonData — без новой генерации религиозного текста.
class AyahOfDay {
  final int globalAyahNumber;
  final String arabic;
  final String transliteration;
  final String translation;

  const AyahOfDay({
    required this.globalAyahNumber,
    required this.arabic,
    required this.transliteration,
    required this.translation,
  });
}

/// Пул аятов и детерминированный выбор одного на календарный день.
class DailyAyahData {
  /// Собирает уникальные аяты из курса «Коран»: берём шаги, у которых есть
  /// арабский текст, транслитерация, перевод и глобальный номер аята. Номер
  /// нужен, чтобы кнопка прослушивания работала через тот же CDN, что и уроки.
  /// Дедуп по номеру аята, сортировка — для стабильного порядка на всех днях.
  static List<AyahOfDay> buildPool() {
    final byNumber = <int, AyahOfDay>{};
    for (final lesson in LessonData.quranCourse.lessons) {
      for (final step in lesson.steps) {
        final number = step.quranGlobalAyahNumber;
        final arabic = step.arabicText?.trim();
        final translit = step.transliteration?.trim();
        final russian = step.russianText?.trim();
        if (number == null ||
            arabic == null ||
            arabic.isEmpty ||
            translit == null ||
            translit.isEmpty ||
            russian == null ||
            russian.isEmpty) {
          continue;
        }
        byNumber.putIfAbsent(
          number,
          () => AyahOfDay(
            globalAyahNumber: number,
            arabic: arabic,
            transliteration: translit,
            translation: russian,
          ),
        );
      }
    }
    return byNumber.values.toList(growable: false)
      ..sort((a, b) => a.globalAyahNumber.compareTo(b.globalAyahNumber));
  }

  /// Порядковый номер дня в году (0-based) — основа стабильного выбора.
  static int dayOfYearIndex(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final today = DateTime(date.year, date.month, date.day);
    return today.difference(startOfYear).inDays;
  }

  /// Детерминированный аят на конкретный календарный день:
  /// индекс = день года % число аятов в пуле.
  static AyahOfDay? ofDay(DateTime date, {List<AyahOfDay>? pool}) {
    final ayahs = pool ?? buildPool();
    if (ayahs.isEmpty) return null;
    return ayahs[dayOfYearIndex(date) % ayahs.length];
  }
}

/// Карточка «Аят дня» для главного экрана. Показывает один и тот же аят в
/// течение календарного дня, с прослушиванием через существующий
/// QuranAudioPlayer (тот же источник аудио, что и в уроках).
class DailyAyahCard extends StatefulWidget {
  /// Дата для выбора аята. По умолчанию — сегодня; параметр нужен для тестов.
  final DateTime? date;

  const DailyAyahCard({super.key, this.date});

  @override
  State<DailyAyahCard> createState() => _DailyAyahCardState();
}

class _DailyAyahCardState extends State<DailyAyahCard>
    with WidgetsBindingObserver {
  // Плеер создаём лениво — только при первом нажатии «Прослушать», чтобы не
  // держать аудиоресурс на каждом рендере главной (важно и для виджет-тестов).
  QuranAudioPlayer? _audioPlayer;
  bool _playing = false;
  // Пул строим один раз (список фиксирован на время жизни виджета), а сам
  // «аят дня» выбираем по ТЕКУЩЕЙ дате при каждом build — так карточка не
  // залипает на вчерашнем аяте, если приложение было открыто через полночь.
  late final List<AyahOfDay> _pool = DailyAyahData.buildPool();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // При возврате на передний план (в т.ч. после полуночи) пересобираем
    // карточку, чтобы «аят дня» пересчитался под новую дату.
    if (state == AppLifecycleState.resumed && mounted) {
      setState(() {});
    }
  }

  /// Аят на текущий календарный день (или на дату из теста).
  AyahOfDay? get _ayah =>
      DailyAyahData.ofDay(widget.date ?? DateTime.now(), pool: _pool);

  Future<void> _toggleListen() async {
    final ayah = _ayah;
    if (ayah == null) return;
    HapticsService.tap();
    final player = _audioPlayer ??= QuranAudioPlayer();

    if (_playing) {
      await player.stop();
      if (mounted) setState(() => _playing = false);
      return;
    }

    // Тот же порядок источников, что и в уроках: сначала прокси бэкенда
    // (если настроен), затем публичный CDN с чтением Аль-Афаси.
    final sources = <String>[
      if (BackendService.hasConfiguredApiUrl)
        '${BackendService.apiBaseUrl}/api/muslingo/quran/audio/${ayah.globalAyahNumber}',
      'https://cdn.islamic.network/quran/audio/128/ar.alafasy/'
          '${ayah.globalAyahNumber}.mp3',
    ];

    setState(() => _playing = true);
    Object? lastError;
    for (final source in sources) {
      try {
        await player.playUrl(source);
        if (mounted) setState(() => _playing = false);
        return;
      } catch (error) {
        lastError = error;
        await player.stop();
      }
    }

    if (!mounted) return;
    setState(() => _playing = false);
    final state = context.read<AppState>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.tr(
          ru: 'Не удалось загрузить аудио аята. $lastError',
          kk: 'Аят аудиосын жүктеу мүмкін болмады. $lastError',
          en: 'Could not load ayah audio. $lastError',
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
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.sky, width: 1.5),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.wb_sunny_rounded,
                    color: AppColors.gold, size: 20),
                const SizedBox(width: 7),
                Text(
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
                ),
                const Spacer(),
                Text(
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
                ),
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
              ayah.transliteration,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontStyle: FontStyle.italic,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 10),
            Container(height: 1, color: AppColors.border),
            const SizedBox(height: 10),
            Text(
              ayah.translation,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                height: 1.4,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.center,
              child: TextButton.icon(
                onPressed: _toggleListen,
                icon: Icon(
                  _playing ? Icons.stop_rounded : Icons.volume_up_rounded,
                  size: 20,
                ),
                label: Text(_playing
                    ? state.tr(ru: 'Остановить', kk: 'Тоқтату', en: 'Stop')
                    : state.tr(ru: 'Прослушать', kk: 'Тыңдау', en: 'Listen')),
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
