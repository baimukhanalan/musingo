part of '../quran_screen.dart';

class _ChapterHeader extends StatelessWidget {
  final QuranChapterSummary chapter;

  const _ChapterHeader({required this.chapter});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, AppColors.navy, AppColors.navyDark],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.28),
            blurRadius: 24,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            chapter.arabicName,
            textDirection: TextDirection.rtl,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Amiri',
              fontSize: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${chapter.revelationLabel} • ${chapter.ayahCount} ${state.tr(ru: 'аятов', kk: 'аят', en: 'verses')}',
            style: const TextStyle(
              fontFamily: 'Nunito',
              color: Colors.white70,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _ChapterAudioBar extends StatelessWidget {
  final QuranChapter chapter;
  final bool isLoading;
  final bool isPlaying;
  final int? activeVerse;
  final VoidCallback onPlay;
  final VoidCallback onOpenText;

  const _ChapterAudioBar({
    required this.chapter,
    required this.isLoading,
    required this.isPlaying,
    required this.activeVerse,
    required this.onPlay,
    required this.onOpenText,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final progress = isLoading
        ? state.tr(
            ru: 'Загрузка цельной суры',
            kk: 'Тұтас сүре жүктелуде',
            en: 'Loading the full surah')
        : activeVerse == null
            ? (isPlaying
                ? state.tr(
                    ru: 'Цельное аудио без пауз',
                    kk: 'Үзіліссіз тұтас аудио',
                    en: 'Full audio without pauses')
                : state.tr(
                    ru: 'Слушать с начала',
                    kk: 'Басынан тыңдау',
                    en: 'Listen from the start'))
            : state.tr(
                ru: 'Аят $activeVerse из ${chapter.summary.ayahCount}',
                kk: 'Аят $activeVerse / ${chapter.summary.ayahCount}',
                en: 'Verse $activeVerse of ${chapter.summary.ayahCount}');
    return PremiumCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Semantics(
                button: true,
                label: isPlaying
                    ? state.tr(
                        ru: 'Пауза суры',
                        kk: 'Сүрені кідірту',
                        en: 'Pause surah')
                    : state.tr(
                        ru: 'Слушать всю суру',
                        kk: 'Барлық сүрені тыңдау',
                        en: 'Listen to the whole surah'),
                child: Tooltip(
                  message: isPlaying
                      ? state.tr(
                          ru: 'Пауза суры',
                          kk: 'Сүрені кідірту',
                          en: 'Pause surah')
                      : state.tr(
                          ru: 'Слушать всю суру',
                          kk: 'Барлық сүрені тыңдау',
                          en: 'Listen to the whole surah'),
                  child: Listener(
                    behavior: HitTestBehavior.opaque,
                    onPointerDown: (_) => onPlay(),
                    child: Container(
                      width: 54,
                      height: 54,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: AppColors.skyLight,
                        shape: BoxShape.circle,
                      ),
                      child: isLoading
                          ? const SizedBox.square(
                              dimension: 20,
                              child:
                                  CircularProgressIndicator(strokeWidth: 2.3),
                            )
                          : Icon(
                              isPlaying
                                  ? Icons.pause_rounded
                                  : Icons.play_arrow_rounded,
                              color: AppColors.navy,
                              size: 30,
                            ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr(
                          ru: 'Слушать всю суру',
                          kk: 'Барлық сүрені тыңдау',
                          en: 'Listen to the whole surah'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      progress,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          OutlinedButton.icon(
            onPressed: onOpenText,
            icon: const Icon(Icons.menu_book_rounded, size: 18),
            label: Text(state.tr(
                ru: 'Открыть полный текст',
                kk: 'Толық мәтінді ашу',
                en: 'Open full text')),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.navy,
              side: const BorderSide(color: AppColors.border),
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
