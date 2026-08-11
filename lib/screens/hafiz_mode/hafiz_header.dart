part of '../hafiz_mode_screen.dart';

class _Header extends StatelessWidget {
  final QuranChapterSummary chapter;
  final int memoryPercent;
  final VoidCallback onBack;

  const _Header({
    required this.chapter,
    required this.memoryPercent,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(6, 6, 16, 4),
      child: Row(
        children: [
          IconButton(
            onPressed: onBack,
            tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
            icon:
                const Icon(Icons.arrow_back_rounded, color: AppColors.navyDark),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hafiz Mode',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  state.tr(
                      ru: '${chapter.latinName} · заучивание',
                      kk: '${chapter.latinName} · жаттау',
                      en: '${chapter.latinName} · memorization'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProgressRing(
                percent: memoryPercent / 100,
                size: 52,
                color: AppColors.gold,
                child: Text(
                  '$memoryPercent%',
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark,
                  ),
                ),
              ),
              const SizedBox(height: 3),
              Text(
                state.tr(ru: 'В ПАМЯТИ', kk: 'ЖАТТАЛҒАН', en: 'MEMORIZED'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 8.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Reading-mode toggle pills. Visual reflection of the current [phase]
/// (0 Читаю / 1 Подсказки / 2 По памяти) — mirrors the flow, does not drive it.
class _ModePills extends StatelessWidget {
  final int phase;

  const _ModePills({required this.phase});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final labels = [
      state.tr(ru: 'Читаю', kk: 'Оқып жатырмын', en: 'Reading'),
      state.tr(ru: 'Подсказки', kk: 'Кеңестер', en: 'Hints'),
      state.tr(ru: 'По памяти', kk: 'Жатқа', en: 'From memory'),
    ];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.ivory.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        children: [
          for (var i = 0; i < labels.length; i++)
            Expanded(
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 9),
                decoration: BoxDecoration(
                  color: i == phase ? AppColors.navyDark : Colors.transparent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Text(
                  labels[i],
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w800,
                    color: i == phase ? AppColors.white : AppColors.textLight,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Arabic verse laid out as rounded word-chips (Amiri, RTL).
class _ArabicChips extends StatelessWidget {
  final String text;
  final double fontSize;

  const _ArabicChips({required this.text, this.fontSize = 28});

  @override
  Widget build(BuildContext context) {
    final words = text
        .split(RegExp(r'\s+'))
        .where((word) => word.isNotEmpty)
        .toList(growable: false);
    return Wrap(
      alignment: WrapAlignment.center,
      textDirection: TextDirection.rtl,
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final word in words)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.backgroundGrey,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border),
            ),
            child: Text(
              word,
              textDirection: TextDirection.rtl,
              style: TextStyle(
                fontFamily: 'Amiri',
                fontSize: fontSize,
                height: 1.6,
                color: AppColors.textDark,
              ),
            ),
          ),
      ],
    );
  }
}

class _VerseText extends StatelessWidget {
  final QuranVerse verse;

  const _VerseText({required this.verse});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      child: Column(
        children: [
          _ArabicChips(text: verse.arabicText, fontSize: 29),
          const Divider(height: 26, color: AppColors.border),
          Text(
            verse.transliteration,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

/// Hide-level word grid: words the level marks hidden render as `● ● ●` chips.
/// The hide computation from [level] is unchanged; tapping a hidden chip locally
/// reveals that single word (peek), which is display-only session state.
