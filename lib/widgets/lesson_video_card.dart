import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/lesson_video.dart';
import '../services/app_state.dart';
import '../services/lesson_video_catalog.dart';
import '../services/lesson_content_localization.dart';
import '../utils/colors.dart';
import 'premium_card.dart';

typedef LessonVideoOpener = Future<bool> Function(Uri uri);

class LessonVideoKnowledgeChallenge {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final String explanation;

  const LessonVideoKnowledgeChallenge({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.explanation,
  });
}

@visibleForTesting
List<LessonVideoKnowledgeChallenge> buildLessonVideoChallenges(
  LessonVideo video, {
  List<LessonVideo>? catalog,
  String locale = 'ru',
}) {
  String tr(String ru, String kk, String en) => locale == 'kk'
      ? kk
      : locale == 'en'
          ? en
          : ru;
  video = LessonContentLocalization.localizeVideo(video, locale);
  final peers = (catalog ?? LessonVideoCatalog.curated.entries)
      .map((item) => LessonContentLocalization.localizeVideo(item, locale))
      .where((item) =>
          item.id != video.id && item.languageCode == video.languageCode)
      .toList(growable: false);
  final salt = video.id.codeUnits.fold<int>(0, (sum, value) => sum + value);

  List<String> buildOptions(
    String correct,
    String Function(LessonVideo) fromPeer,
    List<String> fallbacks,
    int offset,
  ) {
    final distractors = <String>[];
    for (final peer in peers) {
      final candidate = fromPeer(peer);
      if (candidate != correct && !distractors.contains(candidate)) {
        distractors.add(candidate);
      }
      if (distractors.length == 3) break;
    }
    for (final fallback in fallbacks) {
      if (distractors.length == 3) break;
      if (fallback != correct && !distractors.contains(fallback)) {
        distractors.add(fallback);
      }
    }
    final result = distractors.take(3).toList(growable: true);
    result.insert((salt + offset) % 4, correct);
    return result;
  }

  final concept = buildOptions(
    video.topic,
    (peer) => peer.topic,
    [
      tr(
          'Общая мотивация без разбора правила',
          'Ережені талдамайтын жалпы ынталандыру',
          'General motivation without explaining the rule'),
      tr(
          'История автора без учебного вывода',
          'Оқу қорытындысы жоқ автордың әңгімесі',
          'The author’s story without a learning takeaway'),
      tr('Тема, не связанная с текущим уроком',
          'Осы сабаққа қатысы жоқ тақырып', 'A topic unrelated to this lesson'),
    ],
    0,
  );
  String application(String topic) => tr(
      'Выделить принцип «$topic», проверить его по текстовой опоре и применить в упражнении Muslingo.',
      '«$topic» қағидасын анықтап, мәтінмен тексеріп, Muslingo жаттығуында қолдану.',
      'Identify the principle “$topic”, check it against the text, and apply it in a Muslingo exercise.');
  final transfer = buildOptions(
    application(video.topic),
    (peer) => application(peer.topic),
    [
      tr(
          'Считать просмотр достаточным и пропустить практику.',
          'Көруді жеткілікті деп санап, жаттығуды өткізіп жіберу.',
          'Treat watching as sufficient and skip the practice.'),
      tr(
          'Сделать вывод, которого нет в материале, не проверяя источник.',
          'Дереккөзді тексермей, материалда жоқ қорытынды жасау.',
          'Draw a conclusion absent from the material without checking the source.'),
      tr(
          'Запомнить отдельные слова, не связывая их с правилом урока.',
          'Жеке сөздерді сабақ ережесімен байланыстырмай жаттау.',
          'Memorize isolated words without connecting them to the lesson’s rule.'),
    ],
    1,
  );

  return [
    LessonVideoKnowledgeChallenge(
      prompt: tr(
          'После просмотра нужно назвать центральную идею без подсказки. Какая формулировка точнее?',
          'Көргеннен кейін негізгі ойды көмексіз атау керек. Қай тұжырым дәлірек?',
          'After watching, recall the central idea without a hint. Which wording is most accurate?'),
      options: concept,
      correctIndex: concept.indexOf(video.topic),
      explanation: tr(
          'Ответ берётся из заявленной темы видео, а не из похожего материала соседнего урока.',
          'Жауап басқа сабақтағы ұқсас материалдан емес, осы видеоның тақырыбынан алынады.',
          'The answer comes from this video’s stated topic, rather than similar material from another lesson.'),
    ),
    LessonVideoKnowledgeChallenge(
      prompt: tr(
          'Какой следующий шаг превращает просмотр в проверяемый навык?',
          'Қай келесі қадам көргеніңді тексерілетін дағдыға айналдырады?',
          'Which next step turns watching into a demonstrable skill?'),
      options: transfer,
      correctIndex: transfer.indexOf(application(video.topic)),
      explanation: tr(
          'Нужно связать идею видео с текстовой опорой и затем применить её в интерактивной практике.',
          'Видеоның идеясын мәтінмен байланыстырып, интерактивті жаттығуда қолдану керек.',
          'Connect the video’s idea to the text and then apply it in interactive practice.'),
    ),
  ];
}

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
  bool _checkStarted = false;
  bool _checkRevealed = false;
  bool _checkMastered = false;
  int _checkIndex = 0;
  int? _checkAnswer;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final video = LessonContentLocalization.localizeVideo(
        widget.video, state.locale.code);
    if (!const LessonVideoPolicy().validate(widget.video).canDisplay) {
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
                            _opening ? null : () => _open(video.source.url),
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
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: AppColors.pistachio.withValues(alpha: 0.16),
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                state.tr(
                  ru: 'Дополнительный урок эксперта · без XP',
                  kk: 'Қосымша сарапшы сабағы · XP берілмейді',
                  en: 'Optional expert lesson · no XP',
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11.5,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark,
                ),
              ),
            ),
            const SizedBox(height: 10),
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
              text:
                  '${video.source.publisher} · ${LessonContentLocalization.translateText(video.rights.label, state.locale.code)}',
            ),
            const SizedBox(height: 16),
            Text(
              state.tr(
                ru: 'Конспект и текстовая опора',
                kk: 'Конспект және мәтіндік тірек',
                en: 'Study notes and text support',
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
                            ru: 'Весь конспект',
                            kk: 'Толық конспект',
                            en: 'Full study notes'),
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
            const SizedBox(height: 10),
            _knowledgeCheck(state, video),
          ],
        ),
      ),
    );
  }

  Widget _knowledgeCheck(AppState state, LessonVideo video) {
    final challenges =
        buildLessonVideoChallenges(widget.video, locale: state.locale.code);
    final challenge = challenges[_checkIndex];
    if (_checkMastered) {
      return Container(
        key: const Key('lesson-video-check-mastered'),
        width: double.infinity,
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppColors.success.withValues(alpha: 0.12),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            const Icon(Icons.verified_rounded, color: AppColors.success),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                state.tr(
                  ru: 'Видео осмыслено: 2 из 2 выводов подтверждены.',
                  kk: 'Видео түсінілді: 2/2 қорытынды расталды.',
                  en: 'Video mastered: 2 of 2 conclusions confirmed.',
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      key: const Key('lesson-video-knowledge-check'),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.navyDark,
        borderRadius: BorderRadius.circular(18),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.psychology_alt_rounded,
                  color: AppColors.gold, size: 22),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  state.tr(
                    ru: 'Проверка понимания · ${_checkStarted ? '${_checkIndex + 1}/2' : '2 задачи'}',
                    kk: 'Түсінуді тексеру · ${_checkStarted ? '${_checkIndex + 1}/2' : '2 тапсырма'}',
                    en: 'Understanding check · ${_checkStarted ? '${_checkIndex + 1}/2' : '2 challenges'}',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w900,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (!_checkStarted)
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                key: const Key('lesson-video-check-start'),
                onPressed: () => setState(() => _checkStarted = true),
                icon: const Icon(Icons.arrow_forward_rounded),
                label: Text(state.tr(
                  ru: 'Начать мини-аттестацию',
                  kk: 'Мини-аттестацияны бастау',
                  en: 'Start the mini-assessment',
                )),
              ),
            )
          else ...[
            Text(
              challenge.prompt,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                height: 1.35,
                fontWeight: FontWeight.w800,
                color: AppColors.white,
              ),
            ),
            const SizedBox(height: 12),
            for (var index = 0; index < challenge.options.length; index++)
              Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Material(
                  color: _checkAnswer == index
                      ? AppColors.sky.withValues(alpha: 0.28)
                      : AppColors.white.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(13),
                  child: InkWell(
                    key: ValueKey('lesson-video-check-answer-$index'),
                    onTap: _checkRevealed
                        ? null
                        : () => setState(() => _checkAnswer = index),
                    borderRadius: BorderRadius.circular(13),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${String.fromCharCode(65 + index)}.',
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              challenge.options[index],
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 12.5,
                                height: 1.35,
                                fontWeight: FontWeight.w700,
                                color: AppColors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            if (_checkRevealed) ...[
              Text(
                challenge.explanation,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  height: 1.35,
                  fontWeight: FontWeight.w700,
                  color: AppColors.skyLight,
                ),
              ),
              const SizedBox(height: 8),
            ],
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                key: const Key('lesson-video-check-submit'),
                onPressed: _checkAnswer == null ? null : _advanceKnowledgeCheck,
                child: Text(
                  _checkRevealed && _checkAnswer != challenge.correctIndex
                      ? state.tr(
                          ru: 'Исправить ответ',
                          kk: 'Жауапты түзету',
                          en: 'Correct the answer')
                      : state.tr(
                          ru: 'Проверить вывод',
                          kk: 'Қорытындыны тексеру',
                          en: 'Check conclusion'),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _advanceKnowledgeCheck() {
    final challenge = buildLessonVideoChallenges(widget.video,
        locale: context.read<AppState>().locale.code)[_checkIndex];
    if (!_checkRevealed) {
      setState(() => _checkRevealed = true);
      return;
    }
    if (_checkAnswer != challenge.correctIndex) {
      setState(() {
        _checkAnswer = null;
        _checkRevealed = false;
      });
      return;
    }
    if (_checkIndex == 0) {
      setState(() {
        _checkIndex = 1;
        _checkAnswer = null;
        _checkRevealed = false;
      });
    } else {
      setState(() => _checkMastered = true);
    }
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
