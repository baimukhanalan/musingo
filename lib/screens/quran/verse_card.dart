part of '../quran_screen.dart';

class _VerseCard extends StatelessWidget {
  final QuranVerse verse;
  final bool isLoading;
  final bool isActive;
  final bool isPlaying;
  final VoidCallback onPlay;
  final VoidCallback onHafiz;
  final String? masteryLabel;
  final double? mastery;

  const _VerseCard({
    required this.verse,
    required this.isLoading,
    required this.isActive,
    required this.isPlaying,
    required this.onPlay,
    required this.onHafiz,
    required this.masteryLabel,
    required this.mastery,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: isActive ? AppColors.sky : Colors.transparent,
          width: isActive ? 2 : 0,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.05),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  color: AppColors.skyLight,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '${verse.numberInChapter}',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const Spacer(),
              Semantics(
                button: true,
                enabled: !isLoading,
                label: isPlaying
                    ? state.tr(ru: 'Пауза', kk: 'Кідірту', en: 'Pause')
                    : state.tr(
                        ru: 'Слушать аят',
                        kk: 'Аятты тыңдау',
                        en: 'Listen to verse'),
                child: Tooltip(
                  message: isPlaying
                      ? state.tr(ru: 'Пауза', kk: 'Кідірту', en: 'Pause')
                      : state.tr(
                          ru: 'Слушать аят',
                          kk: 'Аятты тыңдау',
                          en: 'Listen to verse'),
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: isLoading ? null : (_) => onPlay(),
                    child: Container(
                      width: 48,
                      height: 48,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: isActive ? AppColors.sky : AppColors.skyLight,
                        shape: BoxShape.circle,
                      ),
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: isActive ? Colors.white : AppColors.navy,
                            ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SelectableText(
            verse.arabicText,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.right,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 27,
              height: 1.9,
              color: AppColors.textDark,
            ),
          ),
          const Divider(height: 26),
          Text(
            verse.transliteration,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              height: 1.5,
              fontStyle: FontStyle.italic,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            verse.translation,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 15,
              height: 1.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            state.tr(
              ru: 'Джуз ${verse.juz} • страница ${verse.page}',
              kk: 'Жүз ${verse.juz} • бет ${verse.page}',
              en: 'Juz ${verse.juz} • page ${verse.page}',
            ),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: AppColors.textLight,
            ),
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onHafiz,
            icon: Icon(
              mastery == null
                  ? Icons.psychology_alt_rounded
                  : Icons.replay_rounded,
            ),
            label: Text(
              mastery == null
                  ? state.tr(ru: 'Учить наизусть', kk: 'Жаттау', en: 'Memorize')
                  : '$masteryLabel · ${(mastery! * 100).round()}%',
            ),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              side: const BorderSide(color: AppColors.sky),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
