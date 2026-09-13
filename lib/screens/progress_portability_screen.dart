import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/progress_portability_service.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_card.dart';

class ProgressPortabilityScreen extends StatefulWidget {
  const ProgressPortabilityScreen({super.key});

  @override
  State<ProgressPortabilityScreen> createState() =>
      _ProgressPortabilityScreenState();
}

class _ProgressPortabilityScreenState extends State<ProgressPortabilityScreen> {
  static const _service = ProgressPortabilityService();
  final _importController = TextEditingController();
  String? _exportedJson;
  PortableProgressPreview? _importPreview;

  @override
  void dispose() {
    _importController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final completedLessons = state.courses
        .expand((course) => course.lessons)
        .where((lesson) => lesson.status.name == 'completed')
        .length;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: IconButton.filled(
                  tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
                  onPressed: () => Navigator.of(context).maybePop(),
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.white,
                    foregroundColor: AppColors.navyDark,
                  ),
                ),
              ),
              const SizedBox(height: 14),
              Text(
                state.tr(
                  ru: 'Перенос прогресса',
                  kk: 'Прогресті тасымалдау',
                  en: 'Progress portability',
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                state.tr(
                  ru: 'Сохрани учебную историю в понятном JSON-файле.',
                  kk: 'Оқу тарихын түсінікті JSON форматында сақта.',
                  en: 'Keep your learning history in a readable JSON format.',
                ),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 20),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionIcon(
                      icon: Icons.file_download_outlined,
                      color: AppColors.pistachio,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.tr(
                        ru: 'Экспортировать прогресс',
                        kk: 'Прогресті экспорттау',
                        en: 'Export progress',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.tr(
                        ru: '$completedLessons завершённых уроков, память повторений, Hafiz и учебная статистика. Имя, email, пароль, токены и голосовые записи не включаются.',
                        kk: '$completedLessons аяқталған сабақ, қайталау жады, Hafiz және оқу статистикасы. Аты-жөн, email, құпиясөз, токендер және дауыс жазбалары қосылмайды.',
                        en: '$completedLessons completed lessons, review memory, Hafiz, and study stats. Name, email, password, tokens, and voice recordings are excluded.',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                        height: 1.45,
                      ),
                    ),
                    const SizedBox(height: 18),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        key: const Key('progress-export-button'),
                        onPressed: () => _export(state),
                        icon: const Icon(Icons.copy_all_rounded),
                        label: Text(state.tr(
                          ru: 'Создать и скопировать JSON',
                          kk: 'JSON жасап, көшіру',
                          en: 'Create and copy JSON',
                        )),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.navy,
                          foregroundColor: AppColors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          textStyle: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 15,
                            fontWeight: FontWeight.w900,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    if (_exportedJson != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        key: const Key('progress-export-preview'),
                        constraints: const BoxConstraints(maxHeight: 220),
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.backgroundGrey,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: SingleChildScrollView(
                          child: SelectableText(
                            _exportedJson!,
                            style: const TextStyle(
                              fontFamily: 'monospace',
                              fontSize: 11.5,
                              color: AppColors.textDark,
                              height: 1.35,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 16),
              PremiumCard(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const _SectionIcon(
                      icon: Icons.file_upload_outlined,
                      color: AppColors.textGrey,
                    ),
                    const SizedBox(height: 14),
                    Text(
                      state.tr(
                        ru: 'Импортировать прогресс',
                        kk: 'Прогресті импорттау',
                        en: 'Import progress',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      state.tr(
                        ru: state.isBackendUser
                            ? 'Для защиты наград импорт в синхронизированный аккаунт пока закрыт. Выйди в локальный режим, импортируй файл, затем создай аккаунт для безопасного объединения.'
                            : 'Вставь JSON Muslingo. Сначала увидишь безопасный предпросмотр. XP, серия, аккаунт и голосовые данные не импортируются.',
                        kk: state.isBackendUser
                            ? 'Марапаттарды қорғау үшін синхрондалған аккаунтқа импорт әзірге жабық. Жергілікті режимде импорттап, содан кейін аккаунтпен біріктір.'
                            : 'Muslingo JSON файлын енгіз. Алдымен қауіпсіз алдын ала қарау көрсетіледі. XP, серия, аккаунт және дауыс деректері импортталмайды.',
                        en: state.isBackendUser
                            ? 'To protect rewards, importing into a synced account is disabled. Import in local mode, then create an account for a safe merge.'
                            : 'Paste a Muslingo JSON file. You will see a safe preview first. XP, streak, account data, and voice data are not imported.',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                        height: 1.45,
                      ),
                    ),
                    if (!state.isBackendUser) ...[
                      const SizedBox(height: 16),
                      TextField(
                        key: const Key('progress-import-field'),
                        controller: _importController,
                        minLines: 4,
                        maxLines: 8,
                        onChanged: (_) => setState(() => _importPreview = null),
                        decoration: InputDecoration(
                          hintText: '{ "format": "muslingo-progress", ... }',
                          filled: true,
                          fillColor: AppColors.backgroundGrey,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide:
                                const BorderSide(color: AppColors.border),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          key: const Key('progress-import-preview-button'),
                          onPressed: () => _previewImport(state),
                          icon: const Icon(Icons.fact_check_outlined),
                          label: Text(state.tr(
                            ru: 'Проверить файл',
                            kk: 'Файлды тексеру',
                            en: 'Check file',
                          )),
                        ),
                      ),
                      if (_importPreview case final preview?) ...[
                        const SizedBox(height: 14),
                        Text(
                          state.tr(
                            ru: 'Будет объединено: ${preview.completedLessons} уроков, ${preview.knowledgeItems} элементов памяти, ${preview.hafizItems} записей Hafiz.',
                            kk: 'Біріктіріледі: ${preview.completedLessons} сабақ, ${preview.knowledgeItems} жад элементі, ${preview.hafizItems} Hafiz жазбасы.',
                            en: 'Will merge: ${preview.completedLessons} lessons, ${preview.knowledgeItems} memory items, and ${preview.hafizItems} Hafiz records.',
                          ),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: FilledButton.icon(
                            key: const Key('progress-import-confirm-button'),
                            onPressed: () => _confirmImport(state, preview),
                            icon: const Icon(Icons.merge_rounded),
                            label: Text(state.tr(
                              ru: 'Объединить прогресс',
                              kk: 'Прогресті біріктіру',
                              en: 'Merge progress',
                            )),
                          ),
                        ),
                      ],
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _export(AppState state) async {
    final json = _service.encodeSnapshot(state);
    if (!mounted) return;
    setState(() => _exportedJson = json);
    var copied = true;
    try {
      await Clipboard.setData(ClipboardData(text: json));
    } catch (_) {
      copied = false;
    }
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        SnackBar(
          content: Text(state.tr(
            ru: copied
                ? 'JSON скопирован. Предпросмотр открыт ниже.'
                : 'Предпросмотр открыт ниже. Буфер обмена недоступен — скопируй JSON вручную.',
            kk: copied
                ? 'JSON көшірілді. Алдын ала қарау төменде ашылды.'
                : 'Алдын ала қарау төменде ашылды. Алмасу буфері қолжетімсіз — JSON-ды қолмен көшір.',
            en: copied
                ? 'JSON copied. The preview is open below.'
                : 'The preview is open below. Clipboard access failed, so copy the JSON manually.',
          )),
          backgroundColor: copied ? AppColors.success : AppColors.warning,
        ),
      );
  }

  void _previewImport(AppState state) {
    try {
      final preview = _service.decodeAndPreview(_importController.text, state);
      setState(() => _importPreview = preview);
    } on FormatException catch (error) {
      _showMessage(error.message, error: true);
    } catch (_) {
      _showMessage(
        state.tr(
          ru: 'Не удалось прочитать файл прогресса.',
          kk: 'Прогресс файлын оқу мүмкін болмады.',
          en: 'Could not read the progress file.',
        ),
        error: true,
      );
    }
  }

  Future<void> _confirmImport(
    AppState state,
    PortableProgressPreview preview,
  ) async {
    try {
      await state.importPortableProgress(preview.snapshot);
      if (!mounted) return;
      setState(() {
        _importPreview = null;
        _importController.clear();
      });
      _showMessage(state.tr(
        ru: 'Прогресс безопасно объединён.',
        kk: 'Прогресс қауіпсіз біріктірілді.',
        en: 'Progress merged safely.',
      ));
    } catch (_) {
      if (!mounted) return;
      _showMessage(
        state.tr(
          ru: 'Импорт не выполнен. Исходный прогресс не изменён.',
          kk: 'Импорт орындалмады. Бастапқы прогресс өзгерген жоқ.',
          en: 'Import failed. Existing progress was not changed.',
        ),
        error: true,
      );
    }
  }

  void _showMessage(String message, {bool error = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        backgroundColor: error ? AppColors.error : AppColors.success,
      ));
  }
}

class _SectionIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _SectionIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(icon, color: color, size: 23),
    );
  }
}
