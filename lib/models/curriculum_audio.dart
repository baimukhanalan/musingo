import 'curriculum_module.dart';
import '../services/lesson_content_localization.dart';

/// A browsable queue of the published curriculum, not a completion tracker.
/// Search narrows the browser only; playback still follows the chosen course.
class CurriculumAudioCatalog {
  static const tracks = <String>[
    'Quran',
    'Arabic',
    'Tajwid',
    'Foundations/Academy',
  ];

  static List<CurriculumModule> queue(
    List<CurriculumModule> modules, {
    String track = 'all',
  }) =>
      List.unmodifiable(
        modules.where((module) => track == 'all' || module.track == track),
      );

  static List<CurriculumModule> search(
    List<CurriculumModule> modules, {
    required String query,
    required String locale,
  }) {
    final needle = query.trim().toLowerCase();
    if (needle.isEmpty) return modules;
    return modules.where((module) {
      final localized =
          LessonContentLocalization.localizeModule(module, locale);
      return [
        module.id,
        module.title,
        localized.title,
        localized.strand,
        localized.objective,
      ].any((value) => value.toLowerCase().contains(needle));
    }).toList(growable: false);
  }
}

/// An honest spoken outline of the material actually bundled in the app.
/// The curriculum asset contains learning objectives and source references,
/// not lecture manuscripts. Do not invent explanations or present this as a
/// Quran recitation, tafsir, teacher recording, or a completed interactive lesson.
class CurriculumAudioOutline {
  final List<String> sections;

  const CurriculumAudioOutline._(this.sections);

  factory CurriculumAudioOutline.fromModule(
    CurriculumModule original,
    String locale,
  ) {
    final module = LessonContentLocalization.localizeModule(original, locale);
    if (locale == 'ar') return _arabicOutline(module);
    String tr(String ru, String kk, String en) => locale == 'kk'
        ? kk
        : locale == 'en'
            ? en
            : ru;
    String spoken(String value) => value
        .replaceAll(RegExp(r'https?://\S+'), '')
        // Arabic learning targets/verses are deliberately not sent to a
        // Russian/Kazakh/English system voice. Recitation uses the Quran player.
        .replaceAll(
          RegExp(
              r'[\u0600-\u06ff\u0750-\u077f\u08a0-\u08ff\ufb50-\ufdff\ufe70-\ufeff]+'),
          tr('арабский текст в материале', 'материалдағы арабша мәтін',
              'Arabic text in the material'),
        )
        .replaceAll(RegExp(r'\(\s*\)'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    final source = spoken(module.sourceLocator.split(';').first);
    return CurriculumAudioOutline._(List.unmodifiable([
      tr(
        'Модуль ${module.id}. ${spoken(module.title)}. Цель. ${spoken(module.objective)}',
        '${module.id} модулі. ${spoken(module.title)}. Мақсат. ${spoken(module.objective)}',
        'Module ${module.id}. ${spoken(module.title)}. Objective. ${spoken(module.objective)}',
      ),
      tr(
        'Рекомендуемая подготовка: ${spoken(module.prerequisite)}. Это рекомендация по порядку изучения, а не ограничение доступа.',
        'Ұсынылатын дайындық: ${spoken(module.prerequisite)}. Бұл оқу реті туралы ұсыныс, қолжетімділік шектеуі емес.',
        'Suggested preparation: ${spoken(module.prerequisite)}. This recommends a learning order; it does not restrict access.',
      ),
      tr(
        'Опора, указанная в плане: $source. Это ссылка на источник, не его цитата и не толкование. Полный список показан в разделе источников этого аудиообзора.',
        'Жоспарда көрсетілген негіз: $source. Бұл дереккөзге сілтеме, оның дәйексөзі немесе тәпсірі емес. Толық тізім осы аудиошолудың дереккөздер бөлімінде берілген.',
        'Reference listed in the plan: $source. This is a source reference, not a quotation or interpretation. The full list appears in the sources section of this audio outline.',
      ),
      tr(
        'Вопрос для самопроверки: какой результат нужно показать в этом модуле и где его проверить? Вспомни цель и назови источник. Для практики и проверки знаний открой интерактивный модуль. Прослушивание само по себе не отмечает его пройденным.',
        'Өзіңді тексер: бұл модульде қандай нәтижені көрсету керек және оны қайдан тексеруге болады? Мақсатты еске түсіріп, дереккөзді ата. Жаттығу мен білімді тексеру үшін интерактивті модульді аш. Тыңдау модульді аяқталған деп белгілемейді.',
        'Self-check: what outcome should you demonstrate in this module, and where can you verify it? Recall the objective and name the source. Open the interactive module for practice and assessment. Listening alone does not mark it completed.',
      ),
    ]));
  }

  static CurriculumAudioOutline _arabicOutline(CurriculumModule module) {
    final metadata =
        '${module.title} ${module.objective} ${module.prerequisite}';
    if (RegExp(r'[А-Яа-яЁё]').hasMatch(metadata) ||
        !RegExp(r'[\u0600-\u06ff]').hasMatch(module.objective)) {
      // Never feed untranslated Russian material to an Arabic system voice.
      throw StateError('Arabic outline metadata is not available.');
    }
    // These Arabic strings are pedagogical metadata, not canonical verses.
    // Unlike the RU/KK/EN branch, do not strip Arabic letters from Arabic prose.
    // No Quran ayah asset, religious quotation or reciter recording enters TTS.
    String spoken(String text) => text
        .replaceAll(RegExp(r'https?://\S+'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return CurriculumAudioOutline._(List.unmodifiable([
      'الوحدة ${module.id}. ${spoken(module.title)}. الهدف: ${spoken(module.objective)}',
      'التحضير المقترح: ${spoken(module.prerequisite)}. هذا اقتراح لترتيب التعلّم، وليس قيدًا على الوصول.',
      'قائمة المصادر لهذا المخطط ظاهرة في قسم مصادر الملخص الصوتي. هذه إحالات إلى مصادر، وليست اقتباسًا منها أو تفسيرًا لها. تبقى أسماء المصادر وعناوينها الأصلية كما هي لتسهيل التحقق.',
      'اختبر نفسك: ما النتيجة التي ينبغي إظهارها في هذه الوحدة، وأين يمكن التحقق منها؟ تذكّر الهدف وسمّ المصدر. افتح الوحدة التفاعلية للتدريب والتقييم. الاستماع وحده لا يسجّل إكمال الوحدة.',
    ]));
  }
}
