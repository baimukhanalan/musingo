import '../models/lesson_video.dart';

class LessonVideoValidation {
  final List<String> errors;

  const LessonVideoValidation(this.errors);

  bool get canDisplay => errors.isEmpty;
}

class LessonVideoPolicy {
  static final RegExp _youtubeId = RegExp(r'^[A-Za-z0-9_-]{6,20}$');
  static final RegExp _vimeoId = RegExp(r'^\d{5,20}$');

  const LessonVideoPolicy();

  LessonVideoValidation validate(LessonVideo video, {DateTime? now}) {
    final errors = <String>[];
    final embed = Uri.tryParse(video.embedUrl);
    final source = Uri.tryParse(video.source.url);

    if (video.id.trim().isEmpty || video.lessonId.trim().isEmpty) {
      errors.add('Video and lesson identifiers are required.');
    }
    if (video.title.trim().isEmpty || video.title.length > 160) {
      errors.add('Video title is missing or too long.');
    }
    if (video.topic.trim().isEmpty || video.topic.length > 160) {
      errors.add('Video topic is missing or too long.');
    }
    if (!_isLanguageCode(video.languageCode)) {
      errors.add('Transcript language code is invalid.');
    }
    if (video.transcript.trim().length < 20 ||
        video.transcript.length > 100000) {
      errors.add('A usable text transcript is required.');
    }
    if (video.speaker.name.trim().isEmpty ||
        video.speaker.role.trim().isEmpty) {
      errors.add('Speaker metadata is incomplete.');
    }
    if (video.source.title.trim().isEmpty ||
        video.source.publisher.trim().isEmpty) {
      errors.add('Source metadata is incomplete.');
    }

    final embedId = _validatedEmbedId(video.provider, embed);
    if (embedId == null) {
      errors.add('Embed URL is not an allowlisted HTTPS provider URL.');
    }
    final sourceId = _validatedSourceId(video.provider, source);
    if (sourceId == null || sourceId != embedId) {
      errors.add('Source URL must match the allowlisted provider and video.');
    }

    if (video.rights.holder.trim().isEmpty ||
        video.rights.label.trim().isEmpty ||
        !_isPlainHttpsUrl(video.rights.evidenceUrl)) {
      errors.add('Rights metadata or evidence is incomplete.');
    }
    if (video.review.status != LessonVideoReviewStatus.approved ||
        video.review.reviewer.trim().isEmpty ||
        video.review.standard.trim().isEmpty) {
      errors.add('Video has not passed editorial review.');
    }

    final clock = now ?? DateTime.now();
    if (video.rights.confirmedAt.isAfter(clock.add(const Duration(days: 1)))) {
      errors.add('Rights confirmation date is invalid.');
    }
    if (video.review.reviewedAt.isAfter(clock.add(const Duration(days: 1)))) {
      errors.add('Review date is invalid.');
    }
    return LessonVideoValidation(List.unmodifiable(errors));
  }

  String? _validatedEmbedId(LessonVideoProvider provider, Uri? uri) {
    if (!_isStrictHttps(uri) || uri!.query.isNotEmpty) return null;
    final segments = uri.pathSegments;
    switch (provider) {
      case LessonVideoProvider.youtubeNoCookie:
        if (uri.host != 'www.youtube-nocookie.com' ||
            segments.length != 2 ||
            segments.first != 'embed' ||
            !_youtubeId.hasMatch(segments.last)) {
          return null;
        }
        return segments.last;
      case LessonVideoProvider.vimeo:
        if (uri.host != 'player.vimeo.com' ||
            segments.length != 2 ||
            segments.first != 'video' ||
            !_vimeoId.hasMatch(segments.last)) {
          return null;
        }
        return segments.last;
    }
  }

  String? _validatedSourceId(LessonVideoProvider provider, Uri? uri) {
    if (!_isStrictHttps(uri)) return null;
    switch (provider) {
      case LessonVideoProvider.youtubeNoCookie:
        if (uri!.host == 'youtu.be' &&
            uri.pathSegments.length == 1 &&
            uri.query.isEmpty &&
            _youtubeId.hasMatch(uri.pathSegments.single)) {
          return uri.pathSegments.single;
        }
        if ((uri.host == 'www.youtube.com' || uri.host == 'youtube.com') &&
            uri.path == '/watch' &&
            uri.queryParameters.length == 1) {
          final id = uri.queryParameters['v'];
          return id != null && _youtubeId.hasMatch(id) ? id : null;
        }
        return null;
      case LessonVideoProvider.vimeo:
        if ((uri!.host == 'vimeo.com' || uri.host == 'www.vimeo.com') &&
            uri.pathSegments.length == 1 &&
            uri.query.isEmpty &&
            _vimeoId.hasMatch(uri.pathSegments.single)) {
          return uri.pathSegments.single;
        }
        return null;
    }
  }

  bool _isStrictHttps(Uri? uri) {
    return uri != null &&
        uri.scheme == 'https' &&
        uri.host.isNotEmpty &&
        uri.userInfo.isEmpty &&
        (!uri.hasPort || uri.port == 443) &&
        uri.fragment.isEmpty;
  }

  bool _isPlainHttpsUrl(String value) {
    final uri = Uri.tryParse(value);
    return _isStrictHttps(uri);
  }

  bool _isLanguageCode(String value) =>
      RegExp(r'^[a-z]{2,3}(-[A-Z]{2})?$').hasMatch(value);
}

/// A caller can inject CMS records, while [curated] contains the reviewed
/// optional external resources shipped with the app. Only records that pass
/// [LessonVideoPolicy] are exposed to lesson screens.
class LessonVideoCatalog {
  final List<LessonVideo> entries;
  final LessonVideoPolicy policy;

  static final LessonVideoCatalog curated = LessonVideoCatalog(
    entries: _curatedLessonVideos,
  );

  const LessonVideoCatalog({
    this.entries = const [],
    this.policy = const LessonVideoPolicy(),
  });

  List<LessonVideo> forLesson(
    String lessonId, {
    String? languageCode,
  }) =>
      entries
          .where((video) =>
              video.lessonId == lessonId &&
              (languageCode == null || video.languageCode == languageCode) &&
              policy.validate(video).canDisplay)
          .toList(growable: false);
}

final List<LessonVideo> _curatedLessonVideos = [
  _ruslanVideo(
    id: 'ruslan-arabic-alphabet',
    lessonId: 'a1',
    youtubeId: 'o4oRsk4BIMU',
    title: 'Арабский алфавит',
    topic: 'Обзор букв перед практикой в Muslingo',
    accessibilityText:
        'Руслан Маликов знакомит ученика с арабским алфавитом. Это дополнительный внешний материал: после просмотра вернись к упражнениям Muslingo на распознавание, звук и форму букв.',
  ),
  _erlanVideo(
    id: 'erlan-quran-alippesi-01',
    lessonId: 'a1',
    youtubeId: 'uTET-AdANac',
    title: 'Құран әліппесі — 1-дәріс',
    topic: 'Қазақ тіліндегі әліппе курсының бастауы',
    accessibilityText:
        'Ерлан Базарбайұлы Құран әліппесі курсын бастайды. Бұл қосымша сыртқы материал: көргеннен кейін Muslingo-дағы әріптің дыбысы мен пішініне арналған жаттығуларға орал.',
  ),
  _ruslanVideo(
    id: 'ruslan-harakat',
    lessonId: 'a2',
    youtubeId: 'HxLbaC9shRg',
    title: 'Харакаты-огласовки',
    topic: 'Фатха, касра, дамма и сукун',
    accessibilityText:
        'Внешний урок объясняет, как фатха, касра и дамма обозначают короткие гласные, а сукун показывает отсутствие гласного. Затем навык закрепляется в интерактивных заданиях Muslingo.',
  ),
  _ruslanVideo(
    id: 'ruslan-letter-ayn',
    lessonId: 'a10',
    youtubeId: 'sukS_YYlWrY',
    title: 'Буква Айн — ع',
    topic: 'Звук и место образования буквы ع',
    accessibilityText:
        'Руслан Маликов показывает звук буквы ع и описывает его образование в средней части горла. Видео дополняет урок Muslingo о буквах ط, ظ, ع и غ.',
  ),
  _ruslanVideo(
    id: 'ruslan-tanwin',
    lessonId: 'a13',
    youtubeId: 'WjMRN7MBSPA',
    title: 'Танвин',
    topic: 'Окончания -ан, -ин и -ун',
    accessibilityText:
        'Внешний урок вводит танвин и его три формы. После объяснения ученик возвращается к заданиям Muslingo, чтобы услышать и распознать окончания -ан, -ин и -ун.',
  ),
  _ruslanVideo(
    id: 'ruslan-tashdid',
    lessonId: 'a14',
    youtubeId: '2MqOtDfrTu8',
    title: 'Ташдид — удвоение',
    topic: 'Чтение буквы со знаком шадда',
    accessibilityText:
        'Внешний урок объясняет знак ташдида и удвоение согласной. Интерактивная часть Muslingo после видео тренирует чтение и распознавание шадды.',
  ),
  _ruslanVideo(
    id: 'ruslan-madd',
    lessonId: 'a15',
    youtubeId: '0TVrAdsTrrs',
    title: 'Мадд — протяжение гласных',
    topic: 'Базовое удлинение через ا, و и ي',
    accessibilityText:
        'Руслан Маликов объясняет базовое протяжение гласных. Видео используется как дополнительное объяснение перед практикой Muslingo с буквами мадда ا, و и ي.',
  ),
  _ruslanVideo(
    id: 'ruslan-tajwid-intro',
    lessonId: 'tj01',
    youtubeId: 'N4ni0llsOj8',
    title: 'Что такое таджвид?',
    topic: 'Цель правильного чтения Корана',
    accessibilityText:
        'Внешний вводный урок раскрывает понятие таджвида. Он не заменяет проверку чтения квалифицированным преподавателем; практические задания и границы автоматической оценки остаются в Muslingo.',
  ),
  _ruslanVideo(
    id: 'ruslan-izhar',
    lessonId: 'tj22',
    youtubeId: 'w27dNJuzHVc',
    title: 'Изхар — ясное чтение',
    topic: 'Первое правило нун сакина и танвина',
    accessibilityText:
        'Внешний урок объясняет изхар как ясное произнесение нун сакина и танвина перед соответствующими буквами. В Muslingo правило закрепляется на слух и в чтении.',
  ),
  _ruslanVideo(
    id: 'ruslan-idgham-with-ghunnah',
    lessonId: 'tj23',
    youtubeId: 'YfSXw0Bg2fw',
    title: 'Идгам — слитное чтение',
    topic: 'Правило нун сакина и танвина',
    accessibilityText:
        'Внешний урок знакомит со слитным чтением при идгаме. Урок Muslingo отдельно тренирует вариант с гунной перед ي, ن, م и و.',
  ),
  _ruslanVideo(
    id: 'ruslan-idgham-without-ghunnah',
    lessonId: 'tj24',
    youtubeId: 'YfSXw0Bg2fw',
    title: 'Идгам — слитное чтение',
    topic: 'Вариант без гунны перед ل и ر',
    accessibilityText:
        'Это же внешнее объяснение идгама используется как ввод к отдельной практике Muslingo: слитное чтение без гунны перед буквами ل и ر.',
  ),
  _ruslanVideo(
    id: 'ruslan-iqlab',
    lessonId: 'tj25',
    youtubeId: '9BLi8ZzDQDw',
    title: 'Икляб — замена',
    topic: 'Нун сакина или танвин перед ب',
    accessibilityText:
        'Внешний урок объясняет икляб: изменение звучания нун сакина или танвина перед буквой ب. После просмотра Muslingo дает задания на распознавание и перенос правила в чтение.',
  ),
  _ruslanVideo(
    id: 'ruslan-mim-sakinah',
    lessonId: 'tj27',
    youtubeId: 'YwU0x1F-po8',
    title: 'Правила мим сакина',
    topic: 'Три варианта чтения مْ',
    accessibilityText:
        'Внешний урок знакомит с правилами мим сакина. В Muslingo ученик затем различает три варианта на примерах и отрабатывает чтение.',
  ),
];

LessonVideo _ruslanVideo({
  required String id,
  required String lessonId,
  required String youtubeId,
  required String title,
  required String topic,
  required String accessibilityText,
}) =>
    _youtubeVideo(
      id: id,
      lessonId: lessonId,
      youtubeId: youtubeId,
      title: title,
      topic: topic,
      languageCode: 'ru',
      accessibilityText: accessibilityText,
      publisher: 'Исламские уроки | Абу Ясин Руслан Маликов',
      speakerName: 'Руслан Маликов',
      speakerRole: 'автор внешнего русскоязычного урока',
      rightsLabel: 'Официальная ссылка · без скачивания и перемонтажа',
      rightsEvidenceUrl: 'https://abu-yasin.com/about/',
    );

LessonVideo _erlanVideo({
  required String id,
  required String lessonId,
  required String youtubeId,
  required String title,
  required String topic,
  required String accessibilityText,
}) =>
    _youtubeVideo(
      id: id,
      lessonId: lessonId,
      youtubeId: youtubeId,
      title: title,
      topic: topic,
      languageCode: 'kk',
      accessibilityText: accessibilityText,
      publisher: 'Әзірет Сұлтан мешіті / Muslim.kz',
      speakerName: 'Ерлан Базарбайұлы',
      speakerRole: 'қазақ тіліндегі сыртқы сабақтың ұстазы',
      rightsLabel: 'Ресми сілтеме · жүктеусіз және монтажсыз',
      rightsEvidenceUrl:
          'https://muslim.kz/news/quran-alippesi-video-sabaqtary-bastaldy',
    );

LessonVideo _youtubeVideo({
  required String id,
  required String lessonId,
  required String youtubeId,
  required String title,
  required String topic,
  required String languageCode,
  required String accessibilityText,
  required String publisher,
  required String speakerName,
  required String speakerRole,
  required String rightsLabel,
  required String rightsEvidenceUrl,
}) =>
    LessonVideo(
      id: id,
      lessonId: lessonId,
      title: title,
      topic: topic,
      languageCode: languageCode,
      provider: LessonVideoProvider.youtubeNoCookie,
      embedUrl: 'https://www.youtube-nocookie.com/embed/$youtubeId',
      transcript: accessibilityText,
      source: LessonVideoSource(
        title: title,
        publisher: publisher,
        url: 'https://www.youtube.com/watch?v=$youtubeId',
      ),
      speaker: LessonVideoSpeaker(name: speakerName, role: speakerRole),
      rights: LessonVideoRights(
        holder: publisher,
        basis: LessonVideoRightsBasis.permissionGranted,
        label: rightsLabel,
        evidenceUrl: rightsEvidenceUrl,
        confirmedAt: DateTime.utc(2026, 9, 12),
      ),
      review: LessonVideoReview(
        status: LessonVideoReviewStatus.approved,
        reviewer: 'Muslingo source-to-lesson mapping review',
        standard:
            'Optional external resource; exact topic match; no XP, offline copy, editing, endorsement claim, or religious ruling by Muslingo',
        reviewedAt: DateTime.utc(2026, 9, 12),
      ),
    );
