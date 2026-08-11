part of '../quran_screen.dart';

class _FullChapterTextSheet extends StatefulWidget {
  final QuranChapter chapter;

  const _FullChapterTextSheet({required this.chapter});

  @override
  State<_FullChapterTextSheet> createState() => _FullChapterTextSheetState();
}

class _FullChapterTextSheetState extends State<_FullChapterTextSheet> {
  bool _showArabic = true;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final chapter = widget.chapter;
    return SafeArea(
      child: DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.86,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, controller) {
          return Padding(
            padding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  '${chapter.summary.number}. ${chapter.summary.latinName}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 12),
                SegmentedButton<bool>(
                  segments: [
                    ButtonSegment<bool>(
                      value: true,
                      icon: const Icon(Icons.language_rounded),
                      label: Text(
                          state.tr(ru: 'Арабский', kk: 'Араб', en: 'Arabic')),
                    ),
                    ButtonSegment<bool>(
                      value: false,
                      icon: const Icon(Icons.translate_rounded),
                      label: Text(
                          state.tr(ru: 'Русский', kk: 'Орыс', en: 'Russian')),
                    ),
                  ],
                  selected: {_showArabic},
                  onSelectionChanged: (selection) {
                    setState(() => _showArabic = selection.first);
                  },
                  style: ButtonStyle(
                    visualDensity: VisualDensity.compact,
                    foregroundColor:
                        WidgetStateProperty.all<Color>(AppColors.navy),
                  ),
                ),
                const SizedBox(height: 14),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: AppColors.border),
                    ),
                    // L18: длинные суры (Аль-Бакара — 286 аятов) раньше
                    // склеивались в один гигантский Text и разом проходили
                    // layout. Ленивый ListView.builder рисует только видимые
                    // аяты. Стиль (Amiri/Nunito) и разделители сохранены.
                    child: ListView.separated(
                      controller: controller,
                      itemCount: chapter.verses.length,
                      separatorBuilder: (_, __) => const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final verse = chapter.verses[index];
                        final content = _showArabic
                            ? '${verse.numberInChapter}. ${verse.arabicText}'
                            : '${verse.numberInChapter}. ${verse.translation}';
                        return SelectableText(
                          content,
                          textDirection: _showArabic
                              ? TextDirection.rtl
                              : TextDirection.ltr,
                          textAlign:
                              _showArabic ? TextAlign.right : TextAlign.left,
                          style: TextStyle(
                            fontFamily: _showArabic ? 'Amiri' : 'Nunito',
                            fontSize: _showArabic ? 25 : 16,
                            height: _showArabic ? 1.9 : 1.55,
                            color: AppColors.textDark,
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
