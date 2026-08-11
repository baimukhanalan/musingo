part of '../lesson_screen.dart';

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
