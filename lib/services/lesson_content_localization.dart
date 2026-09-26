import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/curriculum_module.dart';
import '../models/lesson.dart';
import '../models/lesson_video.dart';
import 'arabic_learning_localization.dart';
import 'learning_title_localization.dart';
import 'lessons/quran_curriculum_localization.dart';

/// Bundled translations of learning content. IDs, grading, Arabic recitation and
/// source URLs stay identical across languages; switching never resets progress.
class LessonContentLocalization {
  LessonContentLocalization._();

  static final Map<String, Map<String, String>> _strings = {};
  static const _bundledLocales = ['kk', 'en', 'ar'];
  static Future<void>? _loading;
  static final _courseCache = Expando<Map<String, Course>>();
  static final _lessonCache = Expando<Map<String, Lesson>>();
  static final _moduleCache = Expando<Map<String, CurriculumModule>>();
  static final _originalLessons = Expando<Lesson>();
  static final _originalModules = Expando<CurriculumModule>();
  static final _videoCache = Expando<Map<String, LessonVideo>>();

  static LessonVideo localizeVideo(LessonVideo video, String locale) {
    if (locale == video.languageCode ||
        locale == 'ru' ||
        !_strings.containsKey(locale)) {
      return video;
    }
    final cache = _videoCache[video] ??= {};
    return cache.putIfAbsent(
        locale,
        () => LessonVideo(
              id: video.id,
              lessonId: video.lessonId,
              title: translateText(video.title, locale),
              topic: translateText(video.topic, locale),
              languageCode: video.languageCode,
              provider: video.provider,
              embedUrl: video.embedUrl,
              transcript: translateText(video.transcript, locale),
              source: video.source,
              speaker: LessonVideoSpeaker(
                  name: video.speaker.name,
                  role: translateText(video.speaker.role, locale)),
              rights: video.rights,
              review: video.review,
            ));
  }

  static Future<void> load() {
    // Complete in the caller's zone once ready. Keeping a completed Future from
    // another test/widget zone can leave initialization awaiting fake time.
    if (_bundledLocales.every(_strings.containsKey)) {
      return Future<void>.value();
    }
    return _loading ??= _load().whenComplete(() => _loading = null);
  }

  static Future<void> _load() async {
    await Future.wait(_bundledLocales.map((locale) async {
      final bytes = await rootBundle.load('assets/data/learning_$locale.json');
      final document = jsonDecode(utf8.decode(bytes.buffer.asUint8List(
        bytes.offsetInBytes,
        bytes.lengthInBytes,
      ))) as Map<String, dynamic>;
      _strings[locale] =
          Map<String, String>.from(document['translations'] as Map);
    }));
  }

  static String translateText(String source, String locale) {
    if (locale == 'ru') return source;
    final quranReading = localizeQuranCurriculumText(source, locale);
    if (quranReading != null) return quranReading;
    final terminology = localizeArabicLearningText(source, locale);
    if (terminology != null) return terminology;
    // Reasoning questions embed the very same source facts used by the lesson.
    // Translate each fact independently, so a corrected letter name cannot
    // become "Dad"/"father" again inside a combined answer.
    final lines = source.split('\n');
    final numberedAnswer = RegExp(r'^(\d+ — )(.*)$');
    if (lines.length > 1 && lines.every(numberedAnswer.hasMatch)) {
      return lines.map((line) {
        final match = numberedAnswer.firstMatch(line)!;
        return '${match[1]}${translateText(match[2]!, locale)}';
      }).join('\n');
    }
    final letterPair = RegExp(r'^([\u0621-\u064a]) — (.+)$').firstMatch(source);
    if (letterPair != null) {
      final letterName = localizeArabicLearningText(letterPair[2]!, locale);
      if (letterName != null) return '${letterPair[1]} — $letterName';
    }
    return _strings[locale]?[source] ?? source;
  }

  static String trackTitle(String track, String locale) {
    const labels = {
      'Quran': ['Коран', 'Құран', 'Quran', 'القرآن'],
      'Arabic': ['Арабский язык', 'Араб тілі', 'Arabic', 'اللغة العربية'],
      'Tajwid': ['Таджвид', 'Тәжуид', 'Tajwid', 'التجويد'],
      'Foundations/Academy': [
        'Основы ислама',
        'Ислам негіздері',
        'Islamic foundations',
        'أسس الإسلام'
      ],
    };
    return labels[track]?[locale == 'kk'
            ? 1
            : locale == 'en'
                ? 2
                : locale == 'ar'
                    ? 3
                    : 0] ??
        track;
  }

  /// Phonetic reading aid, not a translation of the Arabic learning target.
  /// Cyrillic phonetic spelling stays readable for ru/kk; English uses Latin.
  static String? transliterationFor(String? source, String locale) {
    // Arabic readers already have the unchanged Arabic target. A Cyrillic or
    // Latin phonetic helper is neither an Arabic translation nor useful here.
    if (locale == 'ar') return null;
    if (source == null || locale != 'en') return source;
    const alphabet = {
      'а': 'a',
      'б': 'b',
      'в': 'v',
      'г': 'g',
      'д': 'd',
      'е': 'e',
      'ё': 'yo',
      'ж': 'zh',
      'з': 'z',
      'и': 'i',
      'й': 'y',
      'к': 'k',
      'л': 'l',
      'м': 'm',
      'н': 'n',
      'о': 'o',
      'п': 'p',
      'р': 'r',
      'с': 's',
      'т': 't',
      'у': 'u',
      'ф': 'f',
      'х': 'kh',
      'ц': 'ts',
      'ч': 'ch',
      'ш': 'sh',
      'щ': 'shch',
      'ъ': 'ʿ',
      'ы': 'y',
      'ь': '',
      'э': 'e',
      'ю': 'yu',
      'я': 'ya',
    };
    return source.split('').map((letter) {
      final replacement = alphabet[letter.toLowerCase()];
      if (replacement == null) return letter;
      return letter == letter.toUpperCase() && replacement.isNotEmpty
          ? '${replacement[0].toUpperCase()}${replacement.substring(1)}'
          : replacement;
    }).join();
  }

  static List<Course> localizeCourses(List<Course> courses, String locale) =>
      courses
          .map((course) => localizeCourse(course, locale))
          .toList(growable: false);

  static Course localizeCourse(Course course, String locale) {
    if (locale == 'ru' || !_strings.containsKey(locale)) return course;
    final cache = _courseCache[course] ??= {};
    return cache.putIfAbsent(
        locale,
        () => Course(
              id: course.id,
              title: translateText(course.title, locale),
              description: translateText(course.description, locale),
              type: course.type,
              lessons: course.lessons
                  .map((lesson) => localizeLesson(lesson, locale))
                  .toList(growable: false),
            ));
  }

  static Lesson localizeLesson(Lesson lesson, String locale) {
    final original = _originalLessons[lesson] ?? lesson;
    if (locale == 'ru' || !_strings.containsKey(locale)) return original;
    final cache = _lessonCache[original] ??= {};
    return cache.putIfAbsent(locale, () {
      final localized = Lesson(
        id: original.id,
        title: localizeLearningTitle(original.title, original.course, locale) ??
            translateText(original.title, locale),
        subtitle: translateText(original.subtitle, locale),
        course: original.course,
        order: original.order,
        status: original.status,
        xpReward: original.xpReward,
        sourceUrl: original.sourceUrl,
        steps: original.steps
            .map((step) => localizeStep(step, locale))
            .toList(growable: false),
      );
      _originalLessons[localized] = original;
      return localized;
    });
  }

  /// Controlled Quran reading units are fully localized. Arabic legacy lesson
  /// prose is not yet a complete reviewed translation; keep this explicit for
  /// surfaces that offer or label the lesson's content language.
  static bool hasCompleteLessonTranslation(Lesson lesson, String locale) =>
      locale != 'ar' || lesson.id.startsWith('q_full_');

  static LessonStep localizeStep(LessonStep step, String locale) {
    String? text(String? source) =>
        source == null ? null : translateText(source, locale);
    return LessonStep(
      id: step.id,
      type: step.type,
      audioPath: step.audioPath,
      quranGlobalAyahNumber: step.quranGlobalAyahNumber,
      arabicText: step.arabicText,
      transliteration: transliterationFor(step.transliteration, locale),
      russianText: text(step.russianText),
      question: text(step.question),
      answers: step.answers
          ?.map((value) => translateText(value, locale))
          .toList(growable: false),
      correctAnswerIndex: step.correctAnswerIndex,
      matchPairs: step.matchPairs
          .map((pair) => LessonMatchPair(
                prompt: translateText(pair.prompt, locale),
                answer: translateText(pair.answer, locale),
              ))
          .toList(growable: false),
      speechTarget: step.effectiveSpeechTarget,
      speechMode: step.speechMode,
      passScore: step.passScore,
      explanation: text(step.explanation),
      sourceRefs: step.sourceRefs,
      orderTokens: step.orderTokens
          .map((value) => translateText(value, locale))
          .toList(growable: false),
      extraTokens: step.extraTokens
          .map((value) => translateText(value, locale))
          .toList(growable: false),
    );
  }

  static CurriculumModule localizeModule(
      CurriculumModule module, String locale) {
    final original = _originalModules[module] ?? module;
    if (locale == 'ru' || !_strings.containsKey(locale)) return original;
    final cache = _moduleCache[original] ??= {};
    return cache.putIfAbsent(locale, () {
      String text(String value) => translateText(value, locale);
      final localized = CurriculumModule(
        id: original.id,
        track: original.track,
        strand: text(original.strand),
        sequence: original.sequence,
        title: text(original.title),
        objective: text(original.objective),
        difficulty: text(original.difficulty),
        prerequisite: text(original.prerequisite),
        sourceLocator: text(original.sourceLocator),
        rightsStatus: original.rightsStatus,
        reviewStatus: text(original.reviewStatus),
        publicationStatus: original.publicationStatus,
        videoNeed: text(original.videoNeed),
        speakerDomain: text(original.speakerDomain),
      );
      _originalModules[localized] = original;
      return localized;
    });
  }
}
