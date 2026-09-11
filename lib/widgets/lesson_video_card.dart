import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/lesson_video.dart';
import '../services/app_state.dart';
import '../services/lesson_video_catalog.dart';
import '../utils/colors.dart';
import 'premium_card.dart';

typedef LessonVideoOpener = Future<bool> Function(Uri uri);

class LessonVideoCard extends StatefulWidget {
  final LessonVideo video;
  final LessonVideoOpener? opener;

  const LessonVideoCard({
    super.key,
    required this.video,
    this.opener,
  });

  @override
  State<LessonVideoCard> createState() => _LessonVideoCardState();
}

class _LessonVideoCardState extends State<LessonVideoCard> {
  bool _transcriptExpanded = false;
  bool _opening = false;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final video = widget.video;
    if (!const LessonVideoPolicy().validate(video).canDisplay) {
      return const SizedBox.shrink();
    }

    return Semantics(
      container: true,
      explicitChildNodes: true,
      label: '${video.title}. ${video.topic}',
      child: PremiumCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: AppColors.navyDark,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Semantics(
                    button: true,
                    label: state.tr(
                      ru: 'Открыть видео',
                      kk: 'Видеоны ашу',
                      en: 'Open video',
                    ),
                    child: ExcludeSemantics(
                      child: IconButton.filled(
                        key: const Key('lesson-video-play'),
                        onPressed:
                            _opening ? null : () => _open(video.embedUrl),
                        icon: _opening
                            ? const SizedBox.square(
                                dimension: 24,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.5,
                                  color: AppColors.navyDark,
                                ),
                              )
                            : const Icon(Icons.play_arrow_rounded, size: 34),
                        style: IconButton.styleFrom(
                          backgroundColor: AppColors.white,
                          foregroundColor: AppColors.navyDark,
                          minimumSize: const Size.square(58),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              video.title,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              video.topic,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 12),
            _MetadataLine(
              icon: Icons.record_voice_over_outlined,
              text: '${video.speaker.name} · ${video.speaker.role}',
            ),
            const SizedBox(height: 7),
            _MetadataLine(
              icon: Icons.verified_outlined,
              text: '${video.source.publisher} · ${video.rights.label}',
            ),
            const SizedBox(height: 16),
            Text(
              state.tr(
                ru: 'Текстовая альтернатива',
                kk: 'Мәтіндік балама',
                en: 'Text alternative',
              ),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            SelectableText(
              video.transcript,
              key: const Key('lesson-video-transcript'),
              maxLines: _transcriptExpanded ? null : 5,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: [
                TextButton.icon(
                  key: const Key('lesson-video-transcript-toggle'),
                  onPressed: () => setState(
                    () => _transcriptExpanded = !_transcriptExpanded,
                  ),
                  icon: Icon(
                    _transcriptExpanded
                        ? Icons.expand_less_rounded
                        : Icons.expand_more_rounded,
                  ),
                  label: Text(
                    _transcriptExpanded
                        ? state.tr(ru: 'Свернуть', kk: 'Жию', en: 'Show less')
                        : state.tr(
                            ru: 'Весь транскрипт',
                            kk: 'Толық транскрипт',
                            en: 'Full transcript'),
                  ),
                ),
                TextButton.icon(
                  key: const Key('lesson-video-source'),
                  onPressed: _opening ? null : () => _open(video.source.url),
                  icon: const Icon(Icons.open_in_new_rounded, size: 18),
                  label: Text(state.tr(
                    ru: 'Источник',
                    kk: 'Дереккөз',
                    en: 'Source',
                  )),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _open(String value) async {
    setState(() => _opening = true);
    final uri = Uri.parse(value);
    final opened = await (widget.opener ?? _openExternally)(uri);
    if (!mounted) return;
    setState(() => _opening = false);
    if (opened) return;
    final state = context.read<AppState>();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.tr(
          ru: 'Не удалось открыть видео. Попробуй позже.',
          kk: 'Видеоны ашу мүмкін болмады. Кейінірек қайталап көр.',
          en: 'Could not open the video. Try again later.',
        )),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<bool> _openExternally(Uri uri) =>
      launchUrl(uri, mode: LaunchMode.externalApplication);
}

class _MetadataLine extends StatelessWidget {
  final IconData icon;
  final String text;

  const _MetadataLine({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 17, color: AppColors.pistachio),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            text,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12.5,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
              height: 1.3,
            ),
          ),
        ),
      ],
    );
  }
}
