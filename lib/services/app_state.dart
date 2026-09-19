import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/lesson.dart';
import '../models/achievement.dart';
import '../models/reminder_message.dart';
import '../models/learning_profile.dart';
import '../models/knowledge_state.dart';
import '../models/hafiz_progress.dart';
import '../models/daily_ayah.dart';
import '../models/mentor_profile.dart';
import '../utils/app_locale.dart';
import 'backend_service.dart';
import 'lesson_data.dart';
import 'notification_service.dart';
import 'home_widget_service.dart';

enum NativeLanguage {
  russian('ru', 'Русский'),
  kazakh('kk', 'Казахский'),
  uzbek('uz', 'Узбекский');

  final String code;
  final String label;

  const NativeLanguage(this.code, this.label);

  static NativeLanguage? fromCode(String? code) {
    for (final language in values) {
      if (language.code == code) return language;
    }
    return null;
  }
}

class PortableImportResult {
  final int completedLessons;
  final int knowledgeItems;
  final int hafizItems;

  const PortableImportResult({
    required this.completedLessons,
    required this.knowledgeItems,
    required this.hafizItems,
  });
}

class AppState extends ChangeNotifier {
  static const _localAccountsKey = 'local_email_accounts';
  static const _leagueSeasonKey = 'local_league_season';
  static const _leagueXpPrefix = 'local_league_xp_';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _reminderHourKey = 'reminder_hour';
  static const _reminderMinuteKey = 'reminder_minute';
  static const _dailyAyahNotificationsKey = 'daily_ayah_notifications_enabled';
  static const _dailyAyahHourKey = 'daily_ayah_hour';
  static const _dailyAyahMinuteKey = 'daily_ayah_minute';
  static const _lockScreenPreviewKey = 'lock_screen_preview_enabled';
  static const _homeWidgetEnabledKey = 'home_widget_enabled';
  static const _learningGoalKey = 'learning_goal';
  static const _placementLevelKey = 'placement_level';
  static const _learningRecommendationKey = 'learning_recommendation';
  static const _learningSkillProfileKey = 'learning_skill_profile';
  static const _learningProfilePrefix = 'learning_profile_';
  static const _memoryEnginePrefix = 'memory_engine_';
  static const _hafizProgressPrefix = 'hafiz_progress_';
  static const _curriculumProgressPrefix = 'curriculum_570_progress_v2_';
  static const _mentorProfilePrefix = 'mentor_profile_v1_';
  static const _coachConversationPrefix = 'coach_conversation_v1_';
  static const _localeKey = 'locale';
  static const _pendingSyncImportKey = 'pending_sync_import';
  static const _pendingSyncUserKey = 'pending_sync_user';
  static const _pendingSyncGuestKey = 'pending_sync_is_guest';

  /// За сколько восстанавливается одна жизнь и потолок жизней локального
  /// аккаунта. FAQ обещает восстановление, но механики не было — здесь она.
  static const _heartRegenInterval = Duration(minutes: 30);
  static const _maxLocalHearts = 5;

  final Random _secureRandom = Random.secure();

  UserModel? _user;
  List<Course> _courses = [];
  final List<Achievement> _achievements = Achievement.defaults();
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  BackendService? _backend;
  bool _soundEnabled = true;
  AppLocale _locale = AppLocale.ru;
  NativeLanguage? _nativeLanguage;
  final NotificationService _notificationService;
  final HomeWidgetService _homeWidgetService = HomeWidgetService();
  bool _notificationsEnabled = false;
  int _reminderHour = 19;
  int _reminderMinute = 30;
  bool _dailyAyahNotificationsEnabled = false;
  int _dailyAyahHour = 8;
  int _dailyAyahMinute = 15;
  bool _lockScreenPreviewEnabled = false;
  bool _homeWidgetEnabled = false;
  NotificationPermissionState _notificationPermission =
      NotificationPermissionState.prompt;
  LearningGoal? _learningGoal;
  int _placementLevel = 1;
  String? _learningRecommendation;
  LearningSkillProfile? _learningSkillProfile;
  Map<String, KnowledgeState> _knowledgeStates = {};
  Map<String, HafizProgress> _hafizProgress = {};
  Map<String, dynamic> _curriculumProgress = {};
  MentorProfile _mentorProfile = const MentorProfile();
  final Map<String, Future<String>> _lessonAttempts = {};

  /// Слепок локального/гостевого прогресса, который не удалось влить на сервер
  /// в момент входа/регистрации (сеть упала на syncLearningData). Держим его,
  /// чтобы следующий успешный sync доимпортировал данные и НИЧЕГО не потерялось.
  /// [_pendingImportIsGuest] сохраняет флаг слияния (гостевой импорт мержит по
  /// принципу «серверное новее не перетираем»).
  Map<String, dynamic>? _pendingSyncImport;
  bool _pendingImportIsGuest = false;
  String? _pendingSyncUserId;

  UserModel? get user => _user;
  List<Course> get courses => _courses;
  List<Achievement> get achievements => _achievements;
  bool get isLoading => _isLoading;
  bool get isInitialized => _isInitialized;
  String? get error => _error;
  bool get isLoggedIn => _user != null;
  bool get isPremium => _user?.isPremium ?? false;
  bool get isGuest => _user?.id == 'guest';
  bool get isBackendUser => _backend?.isAuthenticated == true && !isGuest;
  bool get canChangePassword =>
      isBackendUser ||
      (BackendService.allowsLocalAccountFallback &&
          (_user?.id.startsWith('local_') ?? false));
  String? get backendAuthToken => isBackendUser ? _backend?.authToken : null;
  String? get lastEmailDelivery => _backend?.lastEmailDelivery;
  bool get soundEnabled => _soundEnabled;
  Map<String, dynamic> get curriculumProgress =>
      Map<String, dynamic>.unmodifiable(_curriculumProgress);
  MentorProfile get mentorProfile => _mentorProfile;

  Future<void> updateMentorProfile(MentorProfile profile) async {
    _mentorProfile = profile;
    await _saveMentorProfile();
    if (_notificationsEnabled) {
      try {
        await _scheduleLearningReminders();
      } catch (_) {
        _error = tr(
          ru: 'Профиль сохранён, но напоминания обновятся при следующем запуске.',
          kk: 'Профиль сақталды, еске салулар келесі іске қосылғанда жаңарады.',
          en: 'Profile saved; reminders will refresh on the next launch.',
        );
      }
    }
    await refreshHomeWidget();
    await _syncBackendProgress();
    notifyListeners();
  }

  Future<void> rememberForCoach(String text) async {
    if (!_mentorProfile.memoryEnabled) return;
    final clean = text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (clean.isEmpty) return;
    final normalized = clean.toLowerCase();
    if (_mentorProfile.memories
        .any((item) => item.text.trim().toLowerCase() == normalized)) {
      return;
    }
    final memory = MentorMemory(
      id: 'memory_${DateTime.now().microsecondsSinceEpoch}',
      text: clean.length <= 240 ? clean : clean.substring(0, 240),
      createdAt: DateTime.now(),
    );
    await updateMentorProfile(_mentorProfile.copyWith(
      memories:
          [memory, ..._mentorProfile.memories].take(20).toList(growable: false),
    ));
  }

  Future<void> forgetCoachMemory(String id) => updateMentorProfile(
        _mentorProfile.copyWith(
          memories: _mentorProfile.memories
              .where((item) => item.id != id)
              .toList(growable: false),
        ),
      );

  Future<void> clearCoachMemories() => updateMentorProfile(
        _mentorProfile.copyWith(memories: const []),
      );

  Future<void> resetMentorPersonalization() async {
    _mentorProfile = const MentorProfile();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('$_coachConversationPrefix${_user?.id ?? 'guest'}');
    await _saveMentorProfile();
    if (_notificationsEnabled) {
      try {
        await _scheduleLearningReminders();
      } catch (_) {}
    }
    await refreshHomeWidget();
    await _syncBackendProgress();
    notifyListeners();
  }

  String get _mentorProfileKey =>
      '$_mentorProfilePrefix${_user?.id ?? 'guest'}';

  Future<void> _loadMentorProfile(SharedPreferences prefs) async {
    final raw = prefs.getString(_mentorProfileKey);
    if (raw == null || raw.isEmpty) {
      _mentorProfile = const MentorProfile();
      return;
    }
    try {
      _mentorProfile = MentorProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      _mentorProfile = const MentorProfile();
    }
  }

  Future<void> _saveMentorProfile() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
        _mentorProfileKey, jsonEncode(_mentorProfile.toJson()));
  }

  void updateCurriculumProgress(Map<String, dynamic> progress) {
    _curriculumProgress = Map<String, dynamic>.from(progress);
    if (isBackendUser) unawaited(_syncBackendProgress());
  }

  bool _isExpiredSession(Object error) =>
      error is BackendException &&
      (error.code == 'expired_session' ||
          error.code == 'invalid_session' ||
          error.code == 'authentication_required' ||
          error.code == 'password_changed');

  /// Clears a profile that can no longer authenticate. Screens that use their
  /// own BackendService instance call this too, so a revoked session cannot
  /// leave the rest of the app looking signed in.
  Future<bool> handleBackendSessionError(Object error) async {
    if (!_isExpiredSession(error)) return false;
    final message = readableBackendError(error);
    await logout();
    _error = message;
    notifyListeners();
    return true;
  }

  Future<EmailActionResult> requestPasswordReset(String email) async {
    final backend = _backend ??= await BackendService.create();
    return backend.requestPasswordReset(email);
  }

  Future<void> resetPassword(String token, String newPassword) async {
    final backend = _backend ??= await BackendService.create();
    await backend.resetPassword(token: token, newPassword: newPassword);
  }

  Future<void> confirmEmailVerification(String token) async {
    final backend = _backend ??= await BackendService.create();
    await backend.confirmEmailVerification(token);
  }

  Future<EmailActionResult> requestEmailVerification(String email) async {
    final backend = _backend ??= await BackendService.create();
    return backend.requestEmailVerification(email);
  }

  Future<PortableImportResult> importPortableProgress(
    Map<String, dynamic> snapshot,
  ) async {
    if (isBackendUser) {
      throw StateError(
        'Импорт в синхронизированный аккаунт требует серверной проверки.',
      );
    }
    final progress = snapshot['progress'];
    if (progress is! Map) {
      throw const FormatException('В файле отсутствует раздел прогресса.');
    }

    // Сначала полностью разбираем и валидируем снимок. До конца
    // этой фазы ни одно поле AppState не меняется.
    List<dynamic> listField(String key) {
      final value = progress[key];
      if (value == null) return const [];
      if (value is! List) {
        throw FormatException('Поле $key должно быть списком.');
      }
      return value;
    }

    final knownLessonIds = _courses
        .expand((course) => course.lessons)
        .map((lesson) => lesson.id)
        .toSet();
    final importedCompleted = listField('completedLessonIds')
        .whereType<String>()
        .where(knownLessonIds.contains)
        .toSet();

    final importedKnowledge = <KnowledgeState>[];
    for (final raw in listField('knowledgeStates')) {
      if (raw is! Map || !knownLessonIds.contains(raw['lessonId'])) continue;
      try {
        importedKnowledge.add(
          KnowledgeState.fromJson(Map<String, dynamic>.from(raw)),
        );
      } catch (_) {
        // A malformed item is skipped without invalidating the whole snapshot.
      }
    }

    final importedHafiz = <HafizProgress>[];
    for (final raw in listField('hafizProgress')) {
      if (raw is! Map) {
        throw const FormatException('Некорректная запись Hafiz.');
      }
      importedHafiz.add(
        HafizProgress.fromJson(Map<String, dynamic>.from(raw)),
      );
    }

    var nextLearningGoal = _learningGoal;
    var nextPlacementLevel = _placementLevel;
    var nextLearningRecommendation = _learningRecommendation;
    var nextLearningSkillProfile = _learningSkillProfile;
    final learning = snapshot['learningProfile'];
    if (learning != null && learning is! Map) {
      throw const FormatException('Некорректный учебный профиль.');
    }
    if (learning is Map) {
      final rawGoal = learning['goal'];
      if (rawGoal != null && rawGoal is! String) {
        throw const FormatException('Некорректная цель обучения.');
      }
      nextLearningGoal = LearningGoalDetails.fromStorage(rawGoal as String?) ??
          nextLearningGoal;
      final rawPlacement = learning['placementLevel'];
      if (rawPlacement != null) {
        if (rawPlacement is! num ||
            !rawPlacement.isFinite ||
            rawPlacement % 1 != 0 ||
            rawPlacement < 1 ||
            rawPlacement > 8) {
          throw const FormatException('Некорректный уровень обучения.');
        }
        nextPlacementLevel = rawPlacement.toInt();
      }
      final recommendation = learning['recommendation'];
      if (recommendation != null && recommendation is! String) {
        throw const FormatException('Некорректная рекомендация.');
      }
      if (recommendation is String && recommendation.trim().isNotEmpty) {
        nextLearningRecommendation = recommendation.trim().length <= 500
            ? recommendation.trim()
            : recommendation.trim().substring(0, 500);
      }
      final scores = learning['skillScores'];
      if (scores != null && scores is! Map) {
        throw const FormatException('Некорректные оценки навыков.');
      }
      if (scores is Map) {
        nextLearningSkillProfile = LearningSkillProfile.fromJson(
          Map<String, dynamic>.from(scores),
        );
      }
    }

    if (_user == null) await loginAsGuest();
    final currentCompleted = _courses
        .expand((course) => course.lessons)
        .where((lesson) => lesson.status == LessonStatus.completed)
        .map((lesson) => lesson.id)
        .toSet();
    final nextKnowledgeStates =
        Map<String, KnowledgeState>.of(_knowledgeStates);
    for (final imported in importedKnowledge) {
      final existing = nextKnowledgeStates[imported.id];
      if (existing == null ||
          imported.lastReviewedAt.isAfter(existing.lastReviewedAt)) {
        nextKnowledgeStates[imported.id] = imported;
      }
    }
    final nextHafizProgress = Map<String, HafizProgress>.of(_hafizProgress);
    for (final imported in importedHafiz) {
      final existing = nextHafizProgress[imported.id];
      if (existing == null ||
          imported.lastReviewedAt.isAfter(existing.lastReviewedAt)) {
        nextHafizProgress[imported.id] = imported;
      }
    }

    final previousCourses = _courses;
    final previousKnowledgeStates = _knowledgeStates;
    final previousHafizProgress = _hafizProgress;
    final previousLearningGoal = _learningGoal;
    final previousPlacementLevel = _placementLevel;
    final previousLearningRecommendation = _learningRecommendation;
    final previousLearningSkillProfile = _learningSkillProfile;
    _applyCourseProgress({...currentCompleted, ...importedCompleted});
    _knowledgeStates = nextKnowledgeStates;
    _hafizProgress = nextHafizProgress;
    _learningGoal = nextLearningGoal;
    _placementLevel = nextPlacementLevel;
    _learningRecommendation = nextLearningRecommendation;
    _learningSkillProfile = nextLearningSkillProfile;
    try {
      await _cacheCurrentState();
    } catch (_) {
      _courses = previousCourses;
      _knowledgeStates = previousKnowledgeStates;
      _hafizProgress = previousHafizProgress;
      _learningGoal = previousLearningGoal;
      _placementLevel = previousPlacementLevel;
      _learningRecommendation = previousLearningRecommendation;
      _learningSkillProfile = previousLearningSkillProfile;
      try {
        await _cacheCurrentState();
      } catch (_) {
        // Best effort: SharedPreferences has no multi-key transaction.
      }
      rethrow;
    }
    notifyListeners();
    return PortableImportResult(
      completedLessons: importedCompleted.length,
      knowledgeItems: importedKnowledge.length,
      hafizItems: importedHafiz.length,
    );
  }

  /// Текущий язык интерфейса. Экраны читают его через
  /// `context.watch<AppState>().locale`, поэтому смена перестраивает подписчиков.
  AppLocale get locale => _locale;
  NativeLanguage? get nativeLanguage => _nativeLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  bool get dailyAyahNotificationsEnabled => _dailyAyahNotificationsEnabled;
  int get dailyAyahHour => _dailyAyahHour;
  int get dailyAyahMinute => _dailyAyahMinute;
  bool get lockScreenPreviewEnabled => _lockScreenPreviewEnabled;
  bool get homeWidgetEnabled => _homeWidgetEnabled;
  bool get homeWidgetSupported => _homeWidgetService.isSupported;
  NotificationPermissionState get notificationPermission =>
      _notificationPermission;
  bool get notificationsRunInBackground =>
      _notificationService.supportsBackgroundScheduling;
  bool get nativeNotificationSurfacesSupported =>
      _notificationService.supportsNativeSurfaces;

  void setNotificationOpenHandler(void Function(String route) callback) {
    _notificationService.setOnOpenRoute(callback);
  }

  LearningGoal? get learningGoal => _learningGoal;
  int get placementLevel => _placementLevel;
  String? get learningRecommendation => _learningRecommendation;
  LearningSkillProfile? get learningSkillProfile => _learningSkillProfile;

  /// Дневная цель пользователя (сколько уроков за день). Дефолт — 3.
  int get dailyGoal => _user?.dailyGoal ?? 3;

  /// Прогресс дневной цели именно за СЕГОДНЯ. Поле dailyProgress в модели
  /// копится и само по себе в полночь не сбрасывается, поэтому показываем его
  /// только если последнее занятие было сегодня — иначе новый день начинается
  /// с нуля. Работает и для гостя, и для backend-профиля: оба берут
  /// dailyProgress и lastStudyDate из одного и того же UserModel.
  int get todayProgress {
    final u = _user;
    if (u == null) return 0;
    final last = u.lastStudyDate;
    if (last == null) return 0;
    return _calendarDaysBetween(last, DateTime.now()) == 0
        ? u.dailyProgress
        : 0;
  }

  List<KnowledgeState> get knowledgeStates =>
      _knowledgeStates.values.toList(growable: false);
  List<HafizProgress> get hafizProgress {
    final items = _hafizProgress.values.toList(growable: false)
      ..sort((a, b) => b.lastReviewedAt.compareTo(a.lastReviewedAt));
    return items;
  }

  int get hafizDueCount =>
      _hafizProgress.values.where((item) => item.isDue()).length;
  int get memorizedVerseCount =>
      _hafizProgress.values.where((item) => item.mastery >= 0.7).length;

  HafizProgress? hafizProgressFor(int surahNumber, int verseNumber) =>
      _hafizProgress['$surahNumber:$verseNumber'];
  int get dueReviewCount =>
      _knowledgeStates.values.where((knowledge) => knowledge.isDue()).length;
  int get weakKnowledgeCount =>
      _knowledgeStates.values.where((knowledge) => knowledge.isWeak).length;
  DateTime? get nextReviewAt {
    if (_knowledgeStates.isEmpty) return null;
    final dates = _knowledgeStates.values
        .map((knowledge) => knowledge.nextReviewAt)
        .toList()
      ..sort();
    return dates.first;
  }

  bool isLessonDue(String lessonId, [DateTime? now]) =>
      _knowledgeStates.values.any((knowledge) =>
          knowledge.lessonId == lessonId && knowledge.isDue(now));

  Lesson? get recommendedLesson {
    // Приоритет 1 — просроченные интервальные повторения. Внутри due-очереди
    // адаптивно поднимаем СЛАБЫЕ места (низкая сила/лапсы) вперёд сильных:
    // сначала закрываем то, что хуже усвоено. При равной слабости — по силе
    // (слабее раньше), затем по «просроченности» (кто дольше ждёт повторения —
    // раньше). Так подбор учитывает и knowledgeStates.isWeak, и точность
    // (strength), и интервальные повторения (isDue/nextReviewAt).
    final now = DateTime.now();
    final dueLessons = _knowledgeStates.values
        .where((knowledge) => knowledge.isDue(now))
        .toList()
      ..sort((a, b) {
        if (a.isWeak != b.isWeak) return a.isWeak ? -1 : 1;
        final byStrength = a.strength.compareTo(b.strength);
        if (byStrength != 0) return byStrength;
        return a.nextReviewAt.compareTo(b.nextReviewAt);
      });
    for (final knowledge in dueLessons) {
      final lesson = _findLesson(knowledge.lessonId);
      if (lesson != null) return lesson;
    }

    // Приоритет 2 — следующий незакрытый урок. Сначала по цели пользователя,
    // затем любой доступный/в процессе. null только когда всё пройдено и нет
    // просроченных повторений — инвариант, на который опираются тесты и хоум.
    final preferredType = _preferredCourseType;
    final preferred = getCourse(preferredType)?.lessons;
    if (preferred != null) {
      for (final lesson in preferred) {
        if (lesson.status == LessonStatus.available ||
            lesson.status == LessonStatus.inProgress) {
          return lesson;
        }
      }
    }
    for (final course in _courses) {
      for (final lesson in course.lessons) {
        if (lesson.status == LessonStatus.available ||
            lesson.status == LessonStatus.inProgress) {
          return lesson;
        }
      }
    }
    return null;
  }

  AppState({NotificationService? notificationService})
      : _notificationService = notificationService ?? NotificationService() {
    _init();
  }

  // --------------------------------------------------------- жизни по времени

  /// Когда восстановится следующая жизнь, либо null если восстанавливать
  /// нечего (жизни полны или premium).
  DateTime? get nextHeartAt {
    final u = _user;
    if (u == null || u.isPremium || u.hearts >= _maxLocalHearts) return null;
    return (u.heartsUpdatedAt ?? DateTime.now()).add(_heartRegenInterval);
  }

  /// Чистый расчёт восстановления жизней — вынесен для тестируемости
  /// (в _applyHeartRegen подставляется реальное время).
  /// `clearAnchor` = true означает «таймер больше не нужен» (жизни полны).
  @visibleForTesting
  static ({int hearts, DateTime? anchor, bool clearAnchor}) computeHeartRegen({
    required int hearts,
    required DateTime? anchor,
    required DateTime now,
    required bool isPremium,
    int maxHearts = _maxLocalHearts,
    Duration interval = _heartRegenInterval,
  }) {
    if (isPremium) return (hearts: hearts, anchor: anchor, clearAnchor: false);
    if (hearts >= maxHearts) {
      return (hearts: hearts, anchor: null, clearAnchor: anchor != null);
    }
    if (anchor == null) {
      return (hearts: hearts, anchor: now, clearAnchor: false);
    }
    final gained = now.difference(anchor).inSeconds ~/ interval.inSeconds;
    if (gained <= 0) {
      return (hearts: hearts, anchor: anchor, clearAnchor: false);
    }
    final newHearts = (hearts + gained).clamp(0, maxHearts).toInt();
    if (newHearts >= maxHearts) {
      return (hearts: newHearts, anchor: null, clearAnchor: true);
    }
    return (
      hearts: newHearts,
      anchor: anchor.add(interval * gained),
      clearAnchor: false,
    );
  }

  /// Начисляет накопившиеся по времени жизни. Только для локального/гостевого
  /// пути — у backend-пользователя источник истины сервер.
  void _applyHeartRegen() {
    final u = _user;
    if (u == null || u.isPremium || isBackendUser) return;
    final result = computeHeartRegen(
      hearts: u.hearts,
      anchor: u.heartsUpdatedAt,
      now: DateTime.now(),
      isPremium: u.isPremium,
    );
    if (result.hearts == u.hearts &&
        result.anchor == u.heartsUpdatedAt &&
        !result.clearAnchor) {
      return;
    }
    _user = u.copyWith(
      hearts: result.hearts,
      heartsUpdatedAt: result.anchor,
      clearHeartsUpdatedAt: result.clearAnchor,
    );
  }

  /// Пересчитывает жизни и сохраняет, если что-то изменилось. UI может вызвать
  /// это при возврате на экран, чтобы показать восстановленные жизни.
  Future<void> refreshHearts() async {
    final before = _user?.hearts;
    final beforeAnchor = _user?.heartsUpdatedAt;
    _applyHeartRegen();
    if (_user?.hearts != before || _user?.heartsUpdatedAt != beforeAnchor) {
      await _saveUser();
      notifyListeners();
    }
  }

  // ------------------------------------------------- календарные дни и пароли

  /// Разница в календарных днях, а не в 24-часовых интервалах: занятие в 23:00
  /// и в 08:00 следующего дня — два разных дня, хотя прошло 9 часов.
  static int _calendarDaysBetween(DateTime from, DateTime to) {
    final a = DateTime(from.year, from.month, from.day);
    final b = DateTime(to.year, to.month, to.day);
    return b.difference(a).inDays;
  }

  /// Число РАЗЛИЧНЫХ аятов урока по quranGlobalAyahNumber. Совпадает с серверными
  /// ayatRewards (число аятов суры) и авто-масштабируется на новый контент, в
  /// отличие от подсчёта уникальных строк. Один аят проходит через audio/text/
  /// speak, поэтому дедуп по номеру аята.
  static int _distinctAyahCount(Lesson lesson) => lesson.steps
      .map((step) => step.quranGlobalAyahNumber)
      .whereType<int>()
      .toSet()
      .length;

  /// PBKDF2-HMAC-SHA256, один выходной блок (32 байта). Заменяет хранение
  /// паролей локальных аккаунтов открытым текстом.
  List<int> _pbkdf2(List<int> password, List<int> salt, int iterations) {
    final hmac = Hmac(sha256, password);
    final block = <int>[...salt, 0, 0, 0, 1];
    var u = hmac.convert(block).bytes;
    final result = List<int>.from(u);
    for (var i = 1; i < iterations; i += 1) {
      u = hmac.convert(u).bytes;
      for (var j = 0; j < result.length; j += 1) {
        result[j] ^= u[j];
      }
    }
    return result;
  }

  static const _pbkdf2Iterations = 120000;

  String _hashLocalPassword(String password, {String? saltB64}) {
    final salt = saltB64 != null
        ? base64Url.decode(saltB64)
        : List<int>.generate(16, (_) => _secureRandom.nextInt(256));
    final dk = _pbkdf2(utf8.encode(password), salt, _pbkdf2Iterations);
    return 'pbkdf2\$$_pbkdf2Iterations\$${base64Url.encode(salt)}'
        '\$${base64Url.encode(dk)}';
  }

  bool _verifyLocalPassword(String password, String stored) {
    if (stored.startsWith('pbkdf2\$')) {
      final parts = stored.split('\$');
      if (parts.length != 4) return false;
      final iterations = int.tryParse(parts[1]) ?? 0;
      if (iterations <= 0) return false;
      final salt = base64Url.decode(parts[2]);
      final expected = base64Url.decode(parts[3]);
      final dk = _pbkdf2(utf8.encode(password), salt, iterations);
      if (dk.length != expected.length) return false;
      var diff = 0;
      for (var i = 0; i < dk.length; i += 1) {
        diff |= dk[i] ^ expected[i];
      }
      return diff == 0;
    }
    // Plaintext legacy credentials are intentionally invalidated. Accepting
    // them even once keeps recoverable passwords in device backups.
    return false;
  }

  bool _localPasswordNeedsUpgrade(String stored) {
    if (!stored.startsWith('pbkdf2\$')) return true;
    final parts = stored.split('\$');
    return parts.length != 4 ||
        (int.tryParse(parts[1]) ?? 0) < _pbkdf2Iterations;
  }

  Future<void> _init() async {
    try {
      _courses = LessonData.getCourses();
      final preferences = await SharedPreferences.getInstance();
      await _removeLegacyPlaintextAccounts(preferences);
      _soundEnabled = preferences.getBool('sound_enabled') ?? true;
      _locale = AppLocale.fromCode(preferences.getString(_localeKey));
      _nativeLanguage =
          NativeLanguage.fromCode(preferences.getString('native_language'));
      _notificationsEnabled =
          preferences.getBool(_notificationsEnabledKey) ?? false;
      _reminderHour = preferences.getInt(_reminderHourKey) ?? 19;
      _reminderMinute = preferences.getInt(_reminderMinuteKey) ?? 30;
      _dailyAyahNotificationsEnabled =
          preferences.getBool(_dailyAyahNotificationsKey) ?? false;
      _dailyAyahHour = preferences.getInt(_dailyAyahHourKey) ?? 8;
      _dailyAyahMinute = preferences.getInt(_dailyAyahMinuteKey) ?? 15;
      _lockScreenPreviewEnabled =
          preferences.getBool(_lockScreenPreviewKey) ?? false;
      _homeWidgetEnabled = preferences.getBool(_homeWidgetEnabledKey) ?? false;
      _learningGoal = LearningGoalDetails.fromStorage(
        preferences.getString(_learningGoalKey),
      );
      _placementLevel = preferences.getInt(_placementLevelKey) ?? 1;
      _learningRecommendation =
          preferences.getString(_learningRecommendationKey);
      _learningSkillProfile = _decodeLearningSkillProfile(
        preferences.getString(_learningSkillProfileKey),
      );
      _backend = await BackendService.create();
      final profile = await _backend!.restoreSession();
      if (profile != null) {
        _applyBackendProfile(profile);
        await _restorePendingSync(preferences, profile.user.id);
        await _cacheCurrentState();
      } else {
        await _loadUser();
        await _loadMentorProfile(preferences);
        await _restoreCourseProgress();
        await _loadKnowledgeStates();
        await _loadHafizProgress();
        _checkAchievements();
      }
      try {
        await _notificationService.initialize();
        _notificationPermission = await _notificationService.permissionState();
        if (_notificationsEnabled &&
            _notificationPermission == NotificationPermissionState.granted) {
          await _scheduleLearningReminders();
        } else if (_notificationsEnabled) {
          // Разрешение могло быть отозвано в настройках ОС между запусками.
          // Не показываем включённый тумблер, если доставлять напоминания уже
          // невозможно.
          _notificationsEnabled = false;
          await preferences.setBool(_notificationsEnabledKey, false);
        }
      } catch (_) {
        _notificationPermission = NotificationPermissionState.unsupported;
        _notificationsEnabled = false;
        await preferences.setBool(_notificationsEnabledKey, false);
      }
      if (_homeWidgetEnabled) {
        try {
          await refreshHomeWidget();
        } catch (_) {
          // Виджет — дополнительная поверхность и не должен блокировать запуск.
        }
      }
    } catch (error) {
      _error = error.toString();
      if (kDebugMode) debugPrint('AppState initialization failed: $error');
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _removeLegacyPlaintextAccounts(
    SharedPreferences preferences,
  ) async {
    final accounts = _decodeLocalAccounts(
      preferences.getString(_localAccountsKey),
    );
    final unsafeEmails = accounts.entries
        .where((entry) =>
            entry.value is Map && (entry.value as Map).containsKey('password'))
        .map((entry) => entry.key)
        .toList(growable: false);
    if (unsafeEmails.isEmpty) return;
    for (final email in unsafeEmails) {
      accounts.remove(email);
    }
    await preferences.setString(_localAccountsKey, jsonEncode(accounts));
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        final restored = UserModel.fromJson(jsonDecode(userJson));
        _user = restored;
        if (restored.id.startsWith('local_')) {
          await _restoreLearningProfileForUser(
            prefs,
            restored.id,
            migrateGlobalProfile: true,
          );
        }
      } catch (_) {
        await prefs.remove('user');
      }
    }
    await _checkAndUpdateStreak();
    _applyHeartRegen();
    await _saveUser();
  }

  /// Изолирует одну запись в SharedPreferences: durability одного среза не
  /// должна ронять сохранение остальных и уведомление UI. Прогресс уже лежит в
  /// памяти, поэтому упавший ключ переедет в persistence на следующем save.
  Future<void> _guardedSave(Future<void> Function() save) async {
    try {
      await save();
    } catch (_) {
      // Намеренно глушим: критичные срезы пишутся независимо друг от друга.
    }
  }

  Future<void> _saveUser() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_user!.toJson()));
    if (_user!.id.startsWith('local_') && _user!.email.isNotEmpty) {
      await _saveLearningProfileForUser(prefs, _user!.id);
      final accounts = _decodeLocalAccounts(prefs.getString(_localAccountsKey));
      final account = accounts[_normalizeEmail(_user!.email)];
      if (account is Map) {
        accounts[_normalizeEmail(_user!.email)] = {
          ...Map<String, dynamic>.from(account),
          'user': _user!.toJson(),
        };
        await prefs.setString(_localAccountsKey, jsonEncode(accounts));
      }
    }
  }

  Future<void> _checkAndUpdateStreak() async {
    if (_user == null) return;
    final now = DateTime.now();
    final last = _user!.lastStudyDate;
    if (last == null) return;

    final diff = _calendarDaysBetween(last, now);
    if (diff > 1) {
      _user = _user!.copyWith(streak: 0);
      await _saveUser();
    }
  }

  Future<void> loginAsGuest() async {
    await _backend?.logout();
    _error = null;
    _user = UserModel.guest();
    await _loadMentorProfile(await SharedPreferences.getInstance());
    _applyHeartRegen();
    await _restoreCourseProgress();
    await _loadKnowledgeStates();
    await _loadHafizProgress();
    _checkAchievements();
    await _saveUser();
    notifyListeners();
  }

  Future<bool> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    final localState = _user == null ? null : _buildSyncState();
    final serverSuccess = await _authenticate(
        () => _backend!.register(
              name: name,
              email: email,
              password: password,
            ),
        localState: localState,
        importGuest: localState != null);
    if (serverSuccess) return true;
    if (BackendService.allowsLocalAccountFallback) {
      return _registerLocalAccount(name, email, password);
    }
    return false;
  }

  Future<bool> loginWithPassword(String email, String password) async {
    final localState = _user == null ? null : _buildSyncState();
    final serverSuccess = await _authenticate(
        () => _backend!.login(
              email: email,
              password: password,
            ),
        localState: localState,
        importGuest: isGuest);
    if (serverSuccess) return true;
    if (BackendService.allowsLocalAccountFallback) {
      return _loginLocalAccount(email, password);
    }
    return false;
  }

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_user == null || isGuest) {
      _error = tr(
        ru: 'Войди в аккаунт, чтобы изменить пароль.',
        kk: 'Құпиясөзді өзгерту үшін аккаунтқа кір.',
        en: 'Log in to change your password.',
      );
      notifyListeners();
      return false;
    }
    if (currentPassword.isEmpty ||
        newPassword.length < 8 ||
        newPassword.length > 128) {
      _error = tr(
        ru: 'Новый пароль должен содержать от 8 до 128 символов.',
        kk: 'Жаңа құпиясөз 8-ден 128 таңбаға дейін болуы керек.',
        en: 'The new password must be 8 to 128 characters long.',
      );
      notifyListeners();
      return false;
    }
    if (currentPassword == newPassword) {
      _error = tr(
        ru: 'Новый пароль должен отличаться от текущего.',
        kk: 'Жаңа құпиясөз ағымдағы құпиясөзден өзгеше болуы керек.',
        en: 'The new password must be different from the current password.',
      );
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (isBackendUser) {
        await _backend!.changePassword(
          currentPassword: currentPassword,
          newPassword: newPassword,
        );
      } else if (_user!.id.startsWith('local_')) {
        final preferences = await SharedPreferences.getInstance();
        final accounts = _decodeLocalAccounts(
          preferences.getString(_localAccountsKey),
        );
        final email = _normalizeEmail(_user!.email);
        final rawAccount = accounts[email];
        if (rawAccount is! Map) {
          _error = tr(
            ru: 'Локальный аккаунт не найден.',
            kk: 'Жергілікті аккаунт табылмады.',
            en: 'Local account was not found.',
          );
          return false;
        }
        final account = Map<String, dynamic>.from(rawAccount);
        final storedHash = account['passwordHash'] as String?;
        if (storedHash == null ||
            !_verifyLocalPassword(currentPassword, storedHash)) {
          _error = tr(
            ru: 'Текущий пароль указан неверно.',
            kk: 'Ағымдағы құпиясөз қате.',
            en: 'The current password is incorrect.',
          );
          return false;
        }
        account['passwordHash'] = _hashLocalPassword(newPassword);
        accounts[email] = account;
        await preferences.setString(_localAccountsKey, jsonEncode(accounts));
      } else {
        _error = tr(
          ru: 'Для этого аккаунта смена пароля недоступна.',
          kk: 'Бұл аккаунт үшін құпиясөзді өзгерту қолжетімсіз.',
          en: 'Password changes are unavailable for this account.',
        );
        return false;
      }
      return true;
    } catch (error) {
      final message = readableBackendError(error);
      final sessionExpired = error is BackendException &&
          (error.code == 'expired_session' ||
              error.code == 'invalid_session' ||
              error.code == 'authentication_required');
      if (sessionExpired) {
        // A cached profile must not keep looking signed in after the server has
        // rejected its session. Clear the local session so the password screen
        // can take the user back through authentication instead of trapping
        // them in a form that can never succeed.
        await logout();
      }
      _error = message;
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _authenticate(
    Future<BackendProfile> Function() operation, {
    Map<String, dynamic>? localState,
    bool importGuest = false,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _backend ??= await BackendService.create();
      var profile = await operation();
      if (localState != null) {
        try {
          profile = await _backend!.syncLearningData(
            localState,
            importGuest: importGuest,
          );
          await _clearPendingSync();
        } catch (_) {
          // Сессия валидна, но импорт локального/гостевого прогресса не прошёл.
          // Сохраняем ИМЕННО этот слепок (а не пересобранный из серверного
          // состояния, которое ниже перетрёт память) — следующий _syncBackendProgress
          // повторит импорт с тем же importGuest и данные не потеряются.
          _pendingSyncImport = localState;
          _pendingImportIsGuest = importGuest;
          _pendingSyncUserId = profile.user.id;
          await _persistPendingSync();
        }
      }
      _applyBackendProfile(profile);
      await _cacheCurrentState();
      final preferences = await SharedPreferences.getInstance();
      await preferences.setString('user', jsonEncode(_user!.toJson()));
      return true;
    } catch (error) {
      _error = readableBackendError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _registerLocalAccount(
    String name,
    String email,
    String password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final normalizedEmail = _normalizeEmail(email);
      final preferences = await SharedPreferences.getInstance();
      final accounts = _decodeLocalAccounts(
        preferences.getString(_localAccountsKey),
      );
      if (accounts.containsKey(normalizedEmail)) {
        _error = 'Аккаунт с таким email уже есть. Войди через email и пароль.';
        return false;
      }

      final userId = _localUserId(normalizedEmail);
      final guestProgress = isGuest ? _user! : null;
      final user = guestProgress == null
          ? UserModel(
              id: userId,
              name: name.trim(),
              email: normalizedEmail,
              hearts: 5,
            )
          : guestProgress.copyWith(
              id: userId,
              name: name.trim(),
              email: normalizedEmail,
              hearts: guestProgress.hearts.clamp(1, 5).toInt(),
            );
      accounts[normalizedEmail] = {
        // Раньше пароль лежал в SharedPreferences открытым текстом.
        'passwordHash': _hashLocalPassword(password),
        'user': user.toJson(),
      };
      await preferences.setString(_localAccountsKey, jsonEncode(accounts));
      final guestLessons = preferences.getStringList('completed_lessons_guest');
      if (guestLessons != null) {
        await preferences.setStringList(
          'completed_lessons_$userId',
          guestLessons,
        );
      }
      final guestMemory = preferences.getString('${_memoryEnginePrefix}guest');
      if (guestMemory != null) {
        await preferences.setString('$_memoryEnginePrefix$userId', guestMemory);
      }
      final guestHafiz = preferences.getString('${_hafizProgressPrefix}guest');
      if (guestHafiz != null) {
        await preferences.setString(
          '$_hafizProgressPrefix$userId',
          guestHafiz,
        );
      }
      final guestLeagueXp = preferences.getInt('${_leagueXpPrefix}guest');
      if (guestLeagueXp != null) {
        await preferences.setInt('$_leagueXpPrefix$userId', guestLeagueXp);
      }
      final guestMentor = preferences.getString('${_mentorProfilePrefix}guest');
      if (guestMentor != null) {
        await preferences.setString(
            '$_mentorProfilePrefix$userId', guestMentor);
      }
      await _backend?.logout();
      _user = user;
      await _loadMentorProfile(preferences);
      await _restoreCourseProgress();
      await _loadKnowledgeStates();
      await _loadHafizProgress();
      await _saveUser();
      _checkAchievements();
      return true;
    } catch (_) {
      _error = 'Не удалось создать локальный аккаунт. Попробуй ещё раз.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> _loginLocalAccount(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final normalizedEmail = _normalizeEmail(email);
      final preferences = await SharedPreferences.getInstance();
      final accounts = _decodeLocalAccounts(
        preferences.getString(_localAccountsKey),
      );
      final account = accounts[normalizedEmail];
      if (account == null) {
        _error =
            'Аккаунт не найден. Зарегистрируйся на этом устройстве или подключи сервер.';
        return false;
      }
      final stored = account['passwordHash'] as String?;
      if (stored == null || !_verifyLocalPassword(password, stored)) {
        _error = 'Неверный email или пароль.';
        return false;
      }
      // Upgrade only older hashes. Plaintext records are removed at startup.
      if (_localPasswordNeedsUpgrade(stored)) {
        final migrated = Map<String, dynamic>.from(account as Map)
          ..['passwordHash'] = _hashLocalPassword(password);
        accounts[normalizedEmail] = migrated;
        await preferences.setString(_localAccountsKey, jsonEncode(accounts));
      }

      final userData = Map<String, dynamic>.from(account['user'] as Map);
      _user = UserModel.fromJson(userData);
      await _loadMentorProfile(preferences);
      await _backend?.logout();
      await _restoreLearningProfileForUser(preferences, _user!.id);
      await _restoreCourseProgress();
      await _loadKnowledgeStates();
      await _loadHafizProgress();
      await _saveUser();
      _checkAchievements();
      return true;
    } catch (_) {
      _error = 'Не удалось войти в локальный аккаунт. Попробуй ещё раз.';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Map<String, dynamic> _decodeLocalAccounts(String? raw) {
    if (raw == null || raw.isEmpty) return <String, dynamic>{};
    try {
      return Map<String, dynamic>.from(jsonDecode(raw) as Map);
    } catch (_) {
      return <String, dynamic>{};
    }
  }

  String _normalizeEmail(String email) => email.trim().toLowerCase();

  LearningSkillProfile? _decodeLearningSkillProfile(String? raw) {
    if (raw == null || raw.isEmpty) return null;
    try {
      return LearningSkillProfile.fromJson(
        Map<String, dynamic>.from(jsonDecode(raw) as Map),
      );
    } catch (_) {
      return null;
    }
  }

  String _localUserId(String email) =>
      'local_${base64Url.encode(utf8.encode(email)).replaceAll('=', '')}';

  String _scopedLearningKey(String userId, String field) =>
      '$_learningProfilePrefix${userId}_$field';

  Future<void> _saveLearningProfileForUser(
    SharedPreferences prefs,
    String userId,
  ) async {
    final goalKey = _scopedLearningKey(userId, 'goal');
    final recommendationKey = _scopedLearningKey(userId, 'recommendation');
    final skillProfileKey = _scopedLearningKey(userId, 'skill_profile');
    if (_learningGoal == null) {
      await prefs.remove(goalKey);
    } else {
      await prefs.setString(goalKey, _learningGoal!.storageValue);
    }
    await prefs.setInt(
      _scopedLearningKey(userId, 'placement_level'),
      _placementLevel,
    );
    if (_learningRecommendation == null) {
      await prefs.remove(recommendationKey);
    } else {
      await prefs.setString(recommendationKey, _learningRecommendation!);
    }
    if (_learningSkillProfile == null) {
      await prefs.remove(skillProfileKey);
    } else {
      await prefs.setString(
        skillProfileKey,
        jsonEncode(_learningSkillProfile!.toJson()),
      );
    }
  }

  Future<void> _restoreLearningProfileForUser(
    SharedPreferences prefs,
    String userId, {
    bool migrateGlobalProfile = false,
  }) async {
    final goalKey = _scopedLearningKey(userId, 'goal');
    final levelKey = _scopedLearningKey(userId, 'placement_level');
    final recommendationKey = _scopedLearningKey(userId, 'recommendation');
    final skillProfileKey = _scopedLearningKey(userId, 'skill_profile');
    final hasScopedProfile = prefs.containsKey(goalKey) ||
        prefs.containsKey(levelKey) ||
        prefs.containsKey(recommendationKey) ||
        prefs.containsKey(skillProfileKey);
    if (!hasScopedProfile && migrateGlobalProfile) {
      await _saveLearningProfileForUser(prefs, userId);
      return;
    }
    _learningGoal = LearningGoalDetails.fromStorage(prefs.getString(goalKey));
    _placementLevel = prefs.getInt(levelKey) ?? 1;
    _learningRecommendation = prefs.getString(recommendationKey);
    _learningSkillProfile =
        _decodeLearningSkillProfile(prefs.getString(skillProfileKey));
  }

  /// Удаляет учебные данные КОНКРЕТНОГО пользователя из SharedPreferences.
  /// Ключи неймспейснуты по id, поэтому данные других локальных аккаунтов
  /// на этом устройстве не затрагиваются.
  Future<void> _clearUserScopedData(
    SharedPreferences prefs,
    String userId,
  ) async {
    await prefs.remove('completed_lessons_$userId');
    await prefs.remove('$_memoryEnginePrefix$userId');
    await prefs.remove('$_hafizProgressPrefix$userId');
    await prefs.remove('$_curriculumProgressPrefix$userId');
    await prefs.remove('$_mentorProfilePrefix$userId');
    await prefs.remove('$_coachConversationPrefix$userId');
    await prefs.remove('$_leagueXpPrefix$userId');
    await prefs.remove(_scopedLearningKey(userId, 'goal'));
    await prefs.remove(_scopedLearningKey(userId, 'placement_level'));
    await prefs.remove(_scopedLearningKey(userId, 'recommendation'));
    await prefs.remove(_scopedLearningKey(userId, 'skill_profile'));
  }

  /// Сбрасывает общий (не привязанный к id) учебный профиль: цель, уровень и
  /// персональную рекомендацию — и в памяти, и в prefs. Без этого следующий
  /// гость на устройстве видел бы чужой план и рекомендацию.
  Future<void> _clearLearningProfile(SharedPreferences prefs) async {
    _learningGoal = null;
    _placementLevel = 1;
    _learningRecommendation = null;
    _learningSkillProfile = null;
    await prefs.remove(_learningGoalKey);
    await prefs.remove(_placementLevelKey);
    await prefs.remove(_learningRecommendationKey);
    await prefs.remove(_learningSkillProfileKey);
  }

  Future<void> logout() async {
    final currentUser = _user;
    if (_notificationsEnabled) {
      try {
        await _notificationService.cancelAll(
          authToken: _backend?.authToken ?? '',
        );
      } catch (_) {
        // Signing out must still finish when notification cleanup cannot reach
        // the server or the session has already expired. Server-side account
        // deletion separately removes subscriptions owned by that user.
      }
      _notificationsEnabled = false;
    }
    await _backend?.logout();
    final prefs = await SharedPreferences.getInstance();
    await _clearPendingSync(preferences: prefs);
    // Master notification state is device-persistent. Leaving it true here
    // re-enabled reminders on the next launch, even though the user had signed
    // out and the in-memory switch was off.
    await prefs.setBool(_notificationsEnabledKey, false);
    if (currentUser?.id.startsWith('local_') == true) {
      await _saveLearningProfileForUser(prefs, currentUser!.id);
    }
    await prefs.remove('user');
    // Чистим данные завершаемого пользователя (для гостя — именно guest-ключи,
    // чтобы «Начать заново» реально начинало с чистого листа) и общий учебный
    // профиль. Данные других локальных аккаунтов остаются нетронутыми.
    if (currentUser != null && !currentUser.id.startsWith('local_')) {
      await _clearUserScopedData(prefs, currentUser.id);
    }
    await _clearLearningProfile(prefs);
    _user = null;
    _courses = LessonData.getCourses();
    _knowledgeStates = {};
    _hafizProgress = {};
    _curriculumProgress = {};
    _mentorProfile = const MentorProfile();
    _checkAchievements();
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final currentUser = _user;
      try {
        await _notificationService.cancelAll(
          authToken: _backend?.authToken ?? '',
        );
      } catch (_) {
        // Account deletion remains authoritative on the server, which also
        // removes user-owned push rows. A platform plugin failure must not
        // block the user's deletion request.
      }
      _notificationsEnabled = false;
      if (isBackendUser) await _backend!.deleteAccount();
      final preferences = await SharedPreferences.getInstance();
      await _clearPendingSync(preferences: preferences);
      await preferences.setBool(_notificationsEnabledKey, false);
      if (currentUser != null) {
        await _clearUserScopedData(preferences, currentUser.id);
        if (currentUser.id.startsWith('local_') &&
            currentUser.email.isNotEmpty) {
          final accounts = _decodeLocalAccounts(
            preferences.getString(_localAccountsKey),
          );
          accounts.remove(_normalizeEmail(currentUser.email));
          await preferences.setString(_localAccountsKey, jsonEncode(accounts));
        }
      }
      await _clearLearningProfile(preferences);
      await preferences.remove('user');
      _user = null;
      _courses = LessonData.getCourses();
      _knowledgeStates = {};
      _hafizProgress = {};
      _curriculumProgress = {};
      _mentorProfile = const MentorProfile();
      _checkAchievements();
      return true;
    } catch (error) {
      _error = readableBackendError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Меняет язык интерфейса, сохраняет код в SharedPreferences и уведомляет
  /// подписчиков, чтобы экраны, читающие [locale]/[tr], перестроились.
  Future<void> setLocale(AppLocale value) async {
    if (_locale == value) return;
    _locale = value;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_localeKey, value.code);
    if (_homeWidgetEnabled) {
      await refreshHomeWidget();
    }
    notifyListeners();
  }

  /// Возвращает строку под текущий язык интерфейса. [ru] обязателен и служит
  /// фолбэком, если перевод на текущий язык не передан.
  String tr({required String ru, String? kk, String? en}) {
    switch (_locale) {
      case AppLocale.ru:
        return ru;
      case AppLocale.kk:
        return kk ?? ru;
      case AppLocale.en:
        return en ?? ru;
    }
  }

  Future<void> setSoundEnabled(bool enabled) async {
    _soundEnabled = enabled;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool('sound_enabled', enabled);
    await _syncBackendProgress();
    notifyListeners();
  }

  Future<void> setNativeLanguage(NativeLanguage language) async {
    _nativeLanguage = language;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('native_language', language.code);
    await _syncBackendProgress();
    notifyListeners();
  }

  Future<void> completePlacement({
    required LearningGoal goal,
    required int level,
    required String recommendation,
    LearningSkillProfile? skillProfile,
  }) async {
    if (_user == null) await loginAsGuest();
    _learningGoal = goal;
    _placementLevel = level.clamp(1, 8).toInt();
    _learningRecommendation = recommendation;
    _learningSkillProfile = skillProfile;
    _applyPlacementCourseStart();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_learningGoalKey, goal.storageValue);
    await preferences.setInt(_placementLevelKey, _placementLevel);
    await preferences.setString(
      _learningRecommendationKey,
      recommendation,
    );
    if (skillProfile == null) {
      await preferences.remove(_learningSkillProfileKey);
    } else {
      await preferences.setString(
        _learningSkillProfileKey,
        jsonEncode(skillProfile.toJson()),
      );
    }
    if (_user?.id.startsWith('local_') == true) {
      await _saveLearningProfileForUser(preferences, _user!.id);
    }
    await _saveCourseProgress();
    await _syncBackendProgress();
    notifyListeners();
  }

  CourseType get _preferredCourseType {
    if (_learningGoal == LearningGoal.islamBasics) return CourseType.rules;
    if (_learningGoal == LearningGoal.pronunciation) return CourseType.tajwid;
    final profile = _learningSkillProfile;
    if (profile != null) {
      final weakest = profile.weakestSkill;
      final score = profile.scoreFor(weakest);
      if (score < 60 &&
          (weakest == LearningSkill.letters ||
              weakest == LearningSkill.reading)) {
        return CourseType.arabic;
      }
      if (score < 50 && weakest == LearningSkill.tajwid) {
        return CourseType.tajwid;
      }
    }
    return _learningGoal == LearningGoal.arabicReading
        ? CourseType.arabic
        : CourseType.quran;
  }

  void _applyPlacementCourseStart() {
    if (_preferredCourseType != CourseType.arabic) return;
    final courseIndex = _courses.indexWhere(
      (course) => course.type == CourseType.arabic,
    );
    if (courseIndex < 0) return;
    final course = _courses[courseIndex];
    if (course.lessons.any((lesson) =>
        lesson.status == LessonStatus.completed ||
        lesson.status == LessonStatus.inProgress)) {
      return;
    }

    const startIndexByLevel = <int>[0, 0, 2, 4, 6, 8, 12, 15];
    final startIndex = startIndexByLevel[_placementLevel - 1]
        .clamp(0, course.lessons.length - 1)
        .toInt();
    if (startIndex == 0) return;
    final lessons = <Lesson>[];
    for (var index = 0; index < course.lessons.length; index += 1) {
      final status = index < startIndex
          ? LessonStatus.completed
          : index == startIndex
              ? LessonStatus.available
              : LessonStatus.locked;
      lessons.add(course.lessons[index].copyWith(status: status));
    }
    _courses[courseIndex] = Course(
      id: course.id,
      title: course.title,
      description: course.description,
      type: course.type,
      lessons: lessons,
    );
  }

  Future<bool> setNotificationsEnabled(bool enabled) async {
    if (enabled) {
      final granted = await _notificationService.requestPermission();
      _notificationPermission = granted
          ? NotificationPermissionState.granted
          : await _notificationService.permissionState();
      if (!granted) {
        _notificationsEnabled = false;
        notifyListeners();
        return false;
      }
      try {
        await _scheduleLearningReminders();
      } catch (_) {
        // Подписка (web push) или планирование могли упасть. Раньше StateError
        // не ловился: setBool/notifyListeners не выполнялись, и тумблер молча
        // откатывался без объяснения. Теперь честно сообщаем о сбое, а не
        // оставляем «включённое» состояние без реальной подписки.
        _notificationsEnabled = false;
        _error =
            'Не удалось включить уведомления. Проверь разрешения и соединение, затем попробуй ещё раз.';
        final preferences = await SharedPreferences.getInstance();
        await preferences.setBool(_notificationsEnabledKey, false);
        notifyListeners();
        return false;
      }
      _notificationsEnabled = true;
    } else {
      try {
        await _notificationService.cancelAll(
          authToken: _backend?.authToken ?? '',
        );
      } catch (_) {
        _error = 'Не удалось отключить уведомления: подписка всё ещё активна.';
        notifyListeners();
        return false;
      }
      _notificationsEnabled = false;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      _notificationsEnabledKey,
      _notificationsEnabled,
    );
    notifyListeners();
    return true;
  }

  Future<bool> setReminderTime(int hour, int minute) async {
    final previousHour = _reminderHour;
    final previousMinute = _reminderMinute;
    _reminderHour = hour.clamp(0, 23).toInt();
    _reminderMinute = minute.clamp(0, 59).toInt();
    try {
      if (_notificationsEnabled) await _scheduleLearningReminders();
    } catch (_) {
      _reminderHour = previousHour;
      _reminderMinute = previousMinute;
      _error =
          'Новое время не сохранено: уведомление не удалось запланировать.';
      notifyListeners();
      return false;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_reminderHourKey, _reminderHour);
    await preferences.setInt(_reminderMinuteKey, _reminderMinute);
    notifyListeners();
    return true;
  }

  Future<bool> setDailyAyahNotificationsEnabled(bool enabled) async {
    if (enabled && !_notificationsEnabled) {
      final permissionGranted = await setNotificationsEnabled(true);
      if (!permissionGranted) return false;
    }
    final previous = _dailyAyahNotificationsEnabled;
    _dailyAyahNotificationsEnabled = enabled;
    try {
      if (_notificationsEnabled) await _scheduleLearningReminders();
    } catch (_) {
      _dailyAyahNotificationsEnabled = previous;
      _error = 'Настройка аята дня не сохранена: планирование недоступно.';
      notifyListeners();
      return false;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_dailyAyahNotificationsKey, enabled);
    notifyListeners();
    return true;
  }

  Future<bool> setDailyAyahTime(int hour, int minute) async {
    final previousHour = _dailyAyahHour;
    final previousMinute = _dailyAyahMinute;
    _dailyAyahHour = hour.clamp(0, 23).toInt();
    _dailyAyahMinute = minute.clamp(0, 59).toInt();
    try {
      if (_notificationsEnabled && _dailyAyahNotificationsEnabled) {
        await _scheduleLearningReminders();
      }
    } catch (_) {
      _dailyAyahHour = previousHour;
      _dailyAyahMinute = previousMinute;
      _error = 'Новое время аята не сохранено: планирование недоступно.';
      notifyListeners();
      return false;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_dailyAyahHourKey, _dailyAyahHour);
    await preferences.setInt(_dailyAyahMinuteKey, _dailyAyahMinute);
    notifyListeners();
    return true;
  }

  Future<bool> setLockScreenPreviewEnabled(bool enabled) async {
    final previous = _lockScreenPreviewEnabled;
    _lockScreenPreviewEnabled = enabled;
    try {
      if (_notificationsEnabled) await _scheduleLearningReminders();
    } catch (_) {
      _lockScreenPreviewEnabled = previous;
      _error = 'Настройка экрана блокировки не сохранена.';
      notifyListeners();
      return false;
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(_lockScreenPreviewKey, enabled);
    notifyListeners();
    return true;
  }

  Future<bool> setHomeWidgetEnabled(bool enabled) async {
    if (!_homeWidgetService.isSupported) return false;
    try {
      if (enabled) {
        await _homeWidgetService.update(
          localeCode: _locale.code,
          coachLine: _widgetCoachLine(),
        );
      } else {
        await _homeWidgetService.clear();
      }
      _homeWidgetEnabled = enabled;
      final preferences = await SharedPreferences.getInstance();
      await preferences.setBool(_homeWidgetEnabledKey, enabled);
      notifyListeners();
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> requestHomeWidget() async {
    final enabled = await setHomeWidgetEnabled(true);
    if (!enabled) return false;
    return _homeWidgetService.requestPin();
  }

  Future<void> refreshHomeWidget() async {
    if (!_homeWidgetEnabled) return;
    try {
      await _homeWidgetService.update(
        localeCode: _locale.code,
        coachLine: _widgetCoachLine(),
      );
    } catch (_) {
      // Системный виджет не должен мешать возвращению в приложение.
    }
  }

  Future<bool> sendTestNotification() async {
    if (!_notificationsEnabled) {
      final enabled = await setNotificationsEnabled(true);
      if (!enabled) return false;
    }
    return _notificationService.showTest(ReminderMessages.test);
  }

  Future<void> _scheduleLearningReminders() {
    final personalized = _mentorProfile.personalizedRemindersEnabled;
    final name = personalized && _mentorProfile.preferredName.isNotEmpty
        ? _mentorProfile.preferredName
        : _user?.name ?? '';
    final streak = _user?.streak ?? 0;
    final due = dueReviewCount + hafizDueCount;
    final goal = _learningGoal?.storageValue ?? '';
    final now = DateTime.now();
    final todayAtAyahTime = DateTime(
      now.year,
      now.month,
      now.day,
      _dailyAyahHour,
      _dailyAyahMinute,
    );
    final ayahStart = todayAtAyahTime.isAfter(now)
        ? todayAtAyahTime
        : todayAtAyahTime.add(const Duration(days: 1));
    return _notificationService.scheduleDaily(
      hour: _reminderHour,
      minute: _reminderMinute,
      messages: buildReminders(
        name: name,
        streak: streak,
        dueCount: due,
        learningGoal: goal,
        locale: _locale,
        personalized: personalized,
        isBirthday: _mentorProfile.isBirthday(now),
        currentFocus: _mentorProfile.currentFocus,
        nextLessonTitle: recommendedLesson?.title ?? '',
        preferredMinutes: _mentorProfile.preferredSessionMinutes,
        tone: _mentorProfile.tone.name,
      ),
      dueCount: due,
      learningGoal: goal,
      name: name,
      streak: streak,
      authToken: _backend?.authToken ?? '',
      ayahMessages: _dailyAyahNotificationsEnabled
          ? DailyAyahData.notificationMessages(
              start: ayahStart,
              count: 28,
              locale: _locale,
            )
          : const [],
      ayahHour: _dailyAyahHour,
      ayahMinute: _dailyAyahMinute,
      showOnLockScreen: _lockScreenPreviewEnabled,
    );
  }

  String _widgetCoachLine() {
    final name = _mentorProfile.preferredName.trim();
    if (_mentorProfile.isBirthday(DateTime.now())) {
      return tr(
        ru: '${name.isEmpty ? 'С днём рождения' : '$name, с днём рождения'} 🎉',
        kk: '${name.isEmpty ? 'Туған күніңмен' : '$name, туған күніңмен'} 🎉',
        en: '${name.isEmpty ? 'Happy birthday' : 'Happy birthday, $name'} 🎉',
      );
    }
    if (!_mentorProfile.personalizedRemindersEnabled) return '';
    if (dueReviewCount > 0) {
      return tr(
        ru: 'Айн: сегодня $dueReviewCount повторений',
        kk: 'Айн: бүгін $dueReviewCount қайталау',
        en: 'Ayn: $dueReviewCount reviews today',
      );
    }
    final title = recommendedLesson?.title;
    if (title == null) return '';
    return tr(
      ru: 'Дальше: $title',
      kk: 'Келесі: $title',
      en: 'Next: $title',
    );
  }

  Future<Map<String, dynamic>> completeLesson(
    String lessonId,
    int errors, {
    Set<String> weakStepIds = const {},
    DateTime? completedAt,
  }) async {
    if (_user == null) return {};

    if (isBackendUser) {
      try {
        final completedLesson = _findLesson(lessonId);
        final attemptFuture = _lessonAttempts.putIfAbsent(
          lessonId,
          () => _backend!.startLessonAttempt(lessonId),
        );
        late final String attemptToken;
        try {
          attemptToken = await attemptFuture;
        } catch (_) {
          _lessonAttempts.remove(lessonId);
          rethrow;
        }
        final speechAttempts = completedLesson?.steps
                .where((step) => step.type == LessonStepType.speak)
                .length ??
            0;
        final result = await _backend!.completeLesson(
          lessonId,
          errors,
          speechAttempts,
          attemptToken,
        );
        _lessonAttempts.remove(lessonId);
        final energyEarned = (12 - (errors * 2)).clamp(4, 12).toInt();
        _applyBackendProfile(result.profile);
        await _updateMemoryForLesson(
          completedLesson,
          weakStepIds,
          completedAt ?? DateTime.now(),
        );
        await _saveCourseProgress();
        await _saveUser();
        await _syncBackendProgress();
        _checkAchievements();
        notifyListeners();
        return {
          'xpEarned': result.xpEarned,
          'streakBonus': result.streakBonus,
          'newStreak': _user!.streak,
          'streakBroken': false,
          'newLevel': _user!.level,
          'heartsLost': errors,
          'energyEarned': energyEarned,
          'rewardToken': attemptToken,
          'weakKnowledgeCount': weakKnowledgeCount,
          'nextReviewAt': nextReviewAt,
        };
      } catch (error) {
        final message = readableBackendError(error);
        if (_isExpiredSession(error)) await logout();
        _error = message;
        notifyListeners();
        rethrow;
      }
    }

    final now = completedAt ?? DateTime.now();
    final last = _user!.lastStudyDate;
    final previousStreak = _user!.streak;

    // Тот же календарный день, что и прошлое занятие. Управляет и стриком (в тот
    // же день не растёт), и дневным прогрессом (копится за день, в новый день
    // начинается заново) — согласовано с геттером todayProgress.
    final bool sameCalendarDay =
        last != null && _calendarDaysBetween(last, now) == 0;

    int newStreak = previousStreak;
    bool streakBroken = false;
    if (last != null) {
      final diff = _calendarDaysBetween(last, now);
      if (diff == 1) {
        newStreak++;
      } else if (diff == 0) {
        // тот же календарный день — стрик не меняем
        if (newStreak == 0) newStreak = 1;
      } else {
        newStreak = 1;
        streakBroken = true;
      }
    } else {
      newStreak = 1;
    }

    // Стрик-бонус (+10/+50/+200 на 7/30/100) начисляем ТОЛЬКО когда стрик реально
    // вырос сегодня (newStreak > previousStreak), т.е. один раз в день. Повторный
    // урок в тот же день-milestone оставляет newStreak прежним и бонуса не даёт.
    int streakBonus = 0;
    if (newStreak > previousStreak) {
      if (newStreak == 7) {
        streakBonus = 10;
      } else if (newStreak == 30) {
        streakBonus = 50;
      } else if (newStreak == 100) {
        streakBonus = 200;
      }
    }

    final completedLesson = _findLesson(lessonId);
    // Повтор уже пройденного урока даёт фиксированные 5 XP — как сервер
    // (server/routes/progress-complete.js: firstCompletion ? 25 : 5). Раньше
    // клиент за повтор начислял полный lesson.xpReward, что накручивало XP
    // переигрыванием. Первое прохождение сохраняет lesson.xpReward.
    final bool isRepeat = completedLesson?.status == LessonStatus.completed;
    final xpEarned = isRepeat ? 5 : (completedLesson?.xpReward ?? 25);
    final newXp = _user!.xp + xpEarned + streakBonus;
    final newLevel = (newXp ~/ 500) + 1;
    final newHearts = _user!.hearts;
    // Начисляем learnedAyats/learnedDuas ТОЛЬКО при первом прохождении урока —
    // как сервер (firstCompletion). Повтор даёт +0, иначе гость накручивал
    // счётчики переигрыванием и расходился с сервером. Аяты — число РАЗЛИЧНЫХ
    // quranGlobalAyahNumber (совпадает с серверными ayatRewards = число аятов
    // суры). Дуа — фиксированные +2 только за первый проход r4 (как сервер:
    // firstCompletion && lessonId === 'r4' ? 2 : 0).
    final learnedAyats =
        (!isRepeat && completedLesson?.course == CourseType.quran)
            ? _distinctAyahCount(completedLesson!)
            : 0;
    final learnedDuas = (!isRepeat && completedLesson?.id == 'r4') ? 2 : 0;
    final energyEarned = (12 - (errors * 2)).clamp(4, 12).toInt();
    final rewardToken = _rewardTokenFor(completedLesson, errors);

    _user = _user!.copyWith(
      xp: newXp,
      level: newLevel,
      streak: newStreak,
      hearts: newHearts,
      energy: (_user!.energy + energyEarned).clamp(0, 999).toInt(),
      lastStudyDate: now,
      totalLessons: _user!.totalLessons + 1,
      totalMinutes: _user!.totalMinutes + 5,
      learnedAyats: _user!.learnedAyats + learnedAyats,
      learnedDuas: _user!.learnedDuas + learnedDuas,
      // Дневной прогресс считает СЕГОДНЯ: в новый календарный день начинается
      // заново с 1, внутри одного дня растёт с потолком dailyGoal. Раньше рос
      // монотонно и в полночь не обнулялся. Согласовано с todayProgress.
      dailyProgress: sameCalendarDay
          ? (_user!.dailyProgress + 1).clamp(0, _user!.dailyGoal).toInt()
          : 1.clamp(0, _user!.dailyGoal).toInt(),
      lessonAttempts: _user!.lessonAttempts + 1,
      speechAttempts: _user!.speechAttempts +
          (completedLesson?.steps
                  .where((step) => step.type == LessonStepType.speak)
                  .length ??
              0),
      rewardChestsOpened: _user!.rewardChestsOpened + 3,
      rewardHistory: [
        ..._user!.rewardHistory,
        rewardToken,
      ],
    );

    // Update lesson status
    for (int i = 0; i < _courses.length; i++) {
      final lessons = List<Lesson>.from(_courses[i].lessons);
      for (int j = 0; j < lessons.length; j++) {
        if (lessons[j].id == lessonId) {
          lessons[j] = lessons[j].copyWith(status: LessonStatus.completed);
          if (j + 1 < lessons.length) {
            lessons[j + 1] =
                lessons[j + 1].copyWith(status: LessonStatus.available);
          }
        }
      }
      _courses[i] = Course(
        id: _courses[i].id,
        title: _courses[i].title,
        description: _courses[i].description,
        type: _courses[i].type,
        lessons: lessons,
      );
    }

    _checkAchievements();
    // Durability: user (XP/сердца/стрик) — источник истины, пишем его первым и
    // без глушения. Остальные срезы (память, прогресс курса, лиговый XP) пишем
    // независимо через _guardedSave: SharedPreferences не даёт мульти-ключевой
    // атомарности, поэтому сбой одного ключа не должен терять остальные и не
    // должен мешать notifyListeners. Всё уже применено в памяти выше.
    await _saveUser();
    await _guardedSave(
      () => _updateMemoryForLesson(completedLesson, weakStepIds, now),
    );
    await _guardedSave(_saveCourseProgress);
    await _guardedSave(() => _addLocalLeagueXp(xpEarned + streakBonus));
    notifyListeners();

    return {
      'xpEarned': xpEarned,
      'streakBonus': streakBonus,
      'newStreak': newStreak,
      'streakBroken': streakBroken,
      'newLevel': newLevel,
      'heartsLost': errors,
      'energyEarned': energyEarned,
      'rewardToken': rewardToken,
      'weakKnowledgeCount': weakKnowledgeCount,
      'nextReviewAt': nextReviewAt,
    };
  }

  Future<void> beginLessonAttempt(String lessonId) async {
    if (!isBackendUser || _lessonAttempts.containsKey(lessonId)) return;
    final attempt = _backend!.startLessonAttempt(lessonId);
    _lessonAttempts[lessonId] = attempt;
    try {
      await attempt;
    } catch (_) {
      _lessonAttempts.remove(lessonId);
    }
  }

  Future<void> recordLessonStep(String lessonId, int stepIndex) async {
    if (!isBackendUser) return;
    try {
      final attempt = _lessonAttempts.putIfAbsent(
        lessonId,
        () => _backend!.startLessonAttempt(lessonId),
      );
      await _backend!.recordLessonStep(lessonId, stepIndex, await attempt);
    } catch (error) {
      await handleBackendSessionError(error);
      rethrow;
    }
  }

  void addXp(int amount) {
    if (_user == null) return;
    _user = _user!.copyWith(
      xp: _user!.xp + amount,
      level: ((_user!.xp + amount) ~/ 500) + 1,
    );
    _saveUser();
    notifyListeners();
  }

  void loseHeart() {
    if (_user == null || _user!.isPremium) return;
    _user = _user!.copyWith(
      hearts: (_user!.hearts - 1).clamp(0, 5).toInt(),
      // Запускаем отсчёт восстановления, если он ещё не идёт.
      heartsUpdatedAt: _user!.heartsUpdatedAt ?? DateTime.now(),
    );
    _saveUser();
    notifyListeners();
  }

  Future<bool> restoreHeart() async {
    if (_user == null) return false;
    if (_user!.isPremium || _user!.hearts >= 5) {
      _error = 'Жизни уже полные.';
      notifyListeners();
      return false;
    }
    if (_user!.energy < 20) {
      _error = 'Нужно 20 энергии, чтобы восстановить жизнь.';
      notifyListeners();
      return false;
    }
    if (isBackendUser) {
      try {
        _applyBackendProfile(await _backend!.restoreHeart());
        notifyListeners();
        return true;
      } catch (error) {
        _error = readableBackendError(error);
        notifyListeners();
        return false;
      }
    }
    final restored = (_user!.hearts + 1).clamp(0, 5).toInt();
    _user = _user!.copyWith(
      hearts: restored,
      energy: (_user!.energy - 20).clamp(0, 999).toInt(),
      // Ручное восстановление сбрасывает таймер: жизни полны — часы не нужны,
      // иначе отсчёт до следующей жизни начинается заново.
      heartsUpdatedAt: restored >= _maxLocalHearts ? null : DateTime.now(),
      clearHeartsUpdatedAt: restored >= _maxLocalHearts,
    );
    await _saveUser();
    notifyListeners();
    return true;
  }

  Future<void> _addLocalLeagueXp(int amount) async {
    final user = _user;
    if (user == null || isBackendUser || amount <= 0) return;
    final preferences = await SharedPreferences.getInstance();
    await _resetLeagueSeasonIfNeeded(preferences);
    final key = '$_leagueXpPrefix${user.id}';
    await preferences.setInt(key, (preferences.getInt(key) ?? 0) + amount);
  }

  Future<void> _resetLeagueSeasonIfNeeded(SharedPreferences preferences) async {
    final season = _leagueSeasonId(DateTime.now());
    if (preferences.getString(_leagueSeasonKey) == season) return;
    final keys = preferences
        .getKeys()
        .where((key) => key.startsWith(_leagueXpPrefix))
        .toList(growable: false);
    for (final key in keys) {
      await preferences.remove(key);
    }
    await preferences.setString(_leagueSeasonKey, season);
  }

  String _leagueSeasonId(DateTime date) {
    final monday = DateTime(date.year, date.month, date.day)
        .subtract(Duration(days: date.weekday - DateTime.monday));
    return '${monday.year}-${monday.month.toString().padLeft(2, '0')}-${monday.day.toString().padLeft(2, '0')}';
  }

  void _checkAchievements() {
    final previous = {for (final item in _achievements) item.id: item};
    final rebuilt = Achievement.defaults();
    if (_user == null) {
      _achievements
        ..clear()
        ..addAll(rebuilt);
      return;
    }
    final now = DateTime.now();
    for (int i = 0; i < rebuilt.length; i++) {
      final a = rebuilt[i];
      bool unlock = false;
      switch (a.category) {
        case AchievementCategory.lessons:
          unlock = _user!.totalLessons >= a.requiredValue;
          break;
        case AchievementCategory.quran:
          unlock = _user!.learnedAyats >= a.requiredValue;
          break;
        case AchievementCategory.rules:
          unlock = (_courses
                  .where((course) => course.type == CourseType.rules)
                  .expand((course) => course.lessons)
                  .where((lesson) => lesson.status == LessonStatus.completed)
                  .length) >=
              a.requiredValue;
          break;
        case AchievementCategory.streak:
          unlock = _user!.streak >= a.requiredValue;
          break;
      }
      if (unlock) {
        final old = previous[a.id];
        rebuilt[i] = a.copyWith(
          isUnlocked: true,
          unlockedAt: old?.isUnlocked == true ? old!.unlockedAt : now,
        );
      }
    }
    _achievements
      ..clear()
      ..addAll(rebuilt);
  }

  Course? getCourse(CourseType type) {
    try {
      return _courses.firstWhere((c) => c.type == type);
    } catch (_) {
      return null;
    }
  }

  Lesson? _findLesson(String lessonId) {
    for (final course in _courses) {
      for (final lesson in course.lessons) {
        if (lesson.id == lessonId) return lesson;
      }
    }
    return null;
  }

  String _rewardTokenFor(Lesson? lesson, int errors) {
    final course = lesson?.course.name ?? 'lesson';
    final accuracy = errors == 0 ? 'perfect' : 'practice';
    return '$course:$accuracy:${DateTime.now().millisecondsSinceEpoch}';
  }

  String? get _completedLessonsKey =>
      _user == null ? null : 'completed_lessons_${_user!.id}';

  String? get _memoryEngineKey =>
      _user == null ? null : '$_memoryEnginePrefix${_user!.id}';

  Future<void> _loadKnowledgeStates() async {
    final key = _memoryEngineKey;
    if (key == null) {
      _knowledgeStates = {};
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(key);
    if (raw == null || raw.isEmpty) {
      _knowledgeStates = {};
      return;
    }
    try {
      final items = (jsonDecode(raw) as List)
          .map((item) => KnowledgeState.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false);
      _knowledgeStates = {for (final item in items) item.id: item};
    } catch (_) {
      _knowledgeStates = {};
      await preferences.remove(key);
    }
  }

  Future<void> _saveKnowledgeStates() async {
    final key = _memoryEngineKey;
    if (key == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      key,
      jsonEncode(
        _knowledgeStates.values
            .map((knowledge) => knowledge.toJson())
            .toList(growable: false),
      ),
    );
  }

  String? get _hafizProgressKey =>
      _user == null ? null : '$_hafizProgressPrefix${_user!.id}';

  Future<void> _loadHafizProgress() async {
    final key = _hafizProgressKey;
    if (key == null) {
      _hafizProgress = {};
      return;
    }
    final preferences = await SharedPreferences.getInstance();
    final raw = preferences.getString(key);
    if (raw == null || raw.isEmpty) {
      _hafizProgress = {};
      return;
    }
    try {
      final items = (jsonDecode(raw) as List)
          .map((item) => HafizProgress.fromJson(
                Map<String, dynamic>.from(item as Map),
              ))
          .toList(growable: false);
      _hafizProgress = {for (final item in items) item.id: item};
    } catch (_) {
      _hafizProgress = {};
      await preferences.remove(key);
    }
  }

  Future<void> _saveHafizProgress() async {
    final key = _hafizProgressKey;
    if (key == null) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(
      key,
      jsonEncode(
        _hafizProgress.values
            .map((progress) => progress.toJson())
            .toList(growable: false),
      ),
    );
  }

  Future<HafizProgress?> recordHafizAttempt({
    required int surahNumber,
    required String surahName,
    required int verseNumber,
    required int globalVerseNumber,
    required int score,
    required int repetitions,
    DateTime? reviewedAt,
  }) async {
    if (_user == null) return null;
    final now = reviewedAt ?? DateTime.now();
    final id = '$surahNumber:$verseNumber';
    final existing = _hafizProgress[id];
    final progress = existing == null
        ? HafizProgress.initial(
            surahNumber: surahNumber,
            surahName: surahName,
            verseNumber: verseNumber,
            globalVerseNumber: globalVerseNumber,
            score: score,
            repetitions: repetitions,
            reviewedAt: now,
          )
        : existing.reviewed(
            score: score,
            addedRepetitions: repetitions,
            reviewedAt: now,
          );
    _hafizProgress[id] = progress;
    // Durability: попытка уже применена в памяти; сбой записи не должен ронять
    // возврат результата и уведомление UI — доедет на следующем сохранении/sync.
    await _guardedSave(_saveHafizProgress);
    await _syncBackendProgress();
    notifyListeners();
    return progress;
  }

  Future<void> _updateMemoryForLesson(
    Lesson? lesson,
    Set<String> weakStepIds,
    DateTime reviewedAt,
  ) async {
    if (lesson == null) return;
    for (final indexedStep in lesson.steps.indexed) {
      final step = indexedStep.$2;
      final stepId = step.id ?? '${lesson.id}:${indexedStep.$1}';
      final wasWeak = weakStepIds.contains(stepId);
      final existing = _knowledgeStates[stepId];
      _knowledgeStates[stepId] = existing == null
          ? KnowledgeState.initial(
              id: stepId,
              lessonId: lesson.id,
              label: _knowledgeLabel(step),
              kind: _knowledgeKind(lesson, step),
              reviewedAt: reviewedAt,
              wasWeak: wasWeak,
            )
          : existing.reviewed(wasWeak: wasWeak, reviewedAt: reviewedAt);
    }
    await _saveKnowledgeStates();
  }

  String _knowledgeLabel(LessonStep step) {
    final label = step.question ??
        step.russianText ??
        step.transliteration ??
        step.arabicText ??
        'Учебный элемент';
    return label.length <= 72 ? label : '${label.substring(0, 69)}...';
  }

  KnowledgeKind _knowledgeKind(Lesson lesson, LessonStep step) {
    switch (step.type) {
      case LessonStepType.speak:
        return KnowledgeKind.pronunciation;
      case LessonStepType.matching:
        return KnowledgeKind.matching;
      case LessonStepType.question:
      case LessonStepType.listenChoice:
        return lesson.course == CourseType.rules ||
                lesson.course == CourseType.tajwid
            ? KnowledgeKind.rule
            : KnowledgeKind.meaning;
      // Сборка фразы из слов — это память на порядок слов аята: тот же тип
      // знания, что у matching-заданий.
      case LessonStepType.wordOrder:
        return KnowledgeKind.matching;
      case LessonStepType.audio:
      case LessonStepType.text:
        if (lesson.course == CourseType.quran) return KnowledgeKind.ayah;
        if (lesson.course == CourseType.rules ||
            lesson.course == CourseType.tajwid) {
          return KnowledgeKind.rule;
        }
        final text = step.arabicText ?? '';
        return text.runes.length <= 2
            ? KnowledgeKind.letter
            : KnowledgeKind.word;
    }
  }

  Future<void> _restoreCourseProgress() async {
    _courses = LessonData.getCourses();
    final key = _completedLessonsKey;
    if (key == null) return;
    final preferences = await SharedPreferences.getInstance();
    final completed = preferences.getStringList(key)?.toSet() ?? <String>{};

    _applyCourseProgress(completed);
  }

  void _applyBackendProfile(BackendProfile profile) {
    _user = profile.user;
    _applyCourseProgress(profile.completedLessons);
    final state = profile.learningState;
    _learningGoal = LearningGoalDetails.fromStorage(
          state['learningGoal'] as String?,
        ) ??
        _learningGoal;
    _placementLevel =
        ((state['placementLevel'] as num?)?.toInt() ?? _placementLevel)
            .clamp(1, 8)
            .toInt();
    _learningRecommendation =
        state['learningRecommendation'] as String? ?? _learningRecommendation;
    final skillProfile = state['learningSkillProfile'];
    if (skillProfile is Map) {
      _learningSkillProfile = LearningSkillProfile.fromJson(
        Map<String, dynamic>.from(skillProfile),
      );
    }
    _nativeLanguage = NativeLanguage.fromCode(
          state['nativeLanguage'] as String?,
        ) ??
        _nativeLanguage;
    _soundEnabled = state['soundEnabled'] as bool? ?? _soundEnabled;
    final knowledge = state['knowledgeStates'];
    if (knowledge is List) {
      final items = knowledge
          .whereType<Map>()
          .map((item) => KnowledgeState.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(growable: false);
      _knowledgeStates = {for (final item in items) item.id: item};
    }
    final hafiz = state['hafizProgress'];
    if (hafiz is List) {
      final items = hafiz
          .whereType<Map>()
          .map((item) => HafizProgress.fromJson(
                Map<String, dynamic>.from(item),
              ))
          .toList(growable: false);
      _hafizProgress = {for (final item in items) item.id: item};
    }
    final curriculum = state['curriculumProgress'];
    if (curriculum is Map) {
      _curriculumProgress = Map<String, dynamic>.from(curriculum);
    }
    final mentor = state['mentorProfile'];
    if (mentor is Map) {
      _mentorProfile = MentorProfile.fromJson(
        Map<String, dynamic>.from(mentor),
      );
    }
    _checkAchievements();
  }

  void _applyCourseProgress(Set<String> completed) {
    _courses = LessonData.getCourses();
    _courses = _courses.map((course) {
      var previousCompleted = true;
      final lessons = <Lesson>[];
      for (final lesson in course.lessons) {
        final isCompleted = completed.contains(lesson.id);
        final status = isCompleted
            ? LessonStatus.completed
            : previousCompleted
                ? LessonStatus.available
                : LessonStatus.locked;
        lessons.add(lesson.copyWith(status: status));
        previousCompleted = isCompleted;
      }
      return Course(
        id: course.id,
        title: course.title,
        description: course.description,
        type: course.type,
        lessons: lessons,
      );
    }).toList(growable: false);
  }

  Future<void> _saveCourseProgress() async {
    final key = _completedLessonsKey;
    if (key == null) return;
    final completed = _courses
        .expand((course) => course.lessons)
        .where((lesson) => lesson.status == LessonStatus.completed)
        .map((lesson) => lesson.id)
        .toList(growable: false);
    final preferences = await SharedPreferences.getInstance();
    await preferences.setStringList(key, completed);
  }

  Map<String, dynamic> _buildSyncState() {
    final user = _user;
    final completed = _courses
        .expand((course) => course.lessons)
        .where((lesson) => lesson.status == LessonStatus.completed)
        .map((lesson) => lesson.id)
        .toList(growable: false);
    return {
      if (user != null) ...user.toJson(),
      'lastStudyDay': user?.lastStudyDate == null
          ? ''
          : '${user!.lastStudyDate!.year.toString().padLeft(4, '0')}-${user.lastStudyDate!.month.toString().padLeft(2, '0')}-${user.lastStudyDate!.day.toString().padLeft(2, '0')}',
      'completedLessons': completed,
      'knowledgeStates': _knowledgeStates.values
          .map((knowledge) => knowledge.toJson())
          .toList(growable: false),
      'hafizProgress': _hafizProgress.values
          .map((progress) => progress.toJson())
          .toList(growable: false),
      'curriculumProgress': _curriculumProgress,
      'learningGoal': _learningGoal?.storageValue,
      'placementLevel': _placementLevel,
      'learningRecommendation': _learningRecommendation,
      'learningSkillProfile': _learningSkillProfile?.toJson(),
      'nativeLanguage': _nativeLanguage?.code,
      'soundEnabled': _soundEnabled,
      'mentorProfile': _mentorProfile.toJson(),
    };
  }

  Future<void> _syncBackendProgress() async {
    if (!isBackendUser) return;
    // Сначала добиваем незавершённый импорт локального/гостевого прогресса.
    // Отправляем сохранённый слепок, а не текущее состояние: после неудачного
    // входа память уже равна серверной, и пересбор потерял бы гостевые данные.
    if (_pendingSyncImport != null && _pendingSyncUserId != _user?.id) {
      await _clearPendingSync();
    }
    final pendingImport = _pendingSyncImport;
    try {
      final profile = pendingImport != null
          ? await _backend!.syncLearningData(
              pendingImport,
              importGuest: _pendingImportIsGuest,
            )
          : await _backend!.syncLearningData(_buildSyncState());
      await _clearPendingSync();
      _applyBackendProfile(profile);
      await _cacheCurrentState();
    } catch (error) {
      if (_isExpiredSession(error)) {
        await handleBackendSessionError(error);
      }
      // Local data stays available and is merged on the next successful sync;
      // отложенный импорт остаётся в _pendingSyncImport до следующей попытки.
    }
  }

  Future<void> _persistPendingSync() async {
    final snapshot = _pendingSyncImport;
    final userId = _pendingSyncUserId;
    if (snapshot == null || userId == null || userId.isEmpty) return;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_pendingSyncImportKey, jsonEncode(snapshot));
    await preferences.setString(_pendingSyncUserKey, userId);
    await preferences.setBool(_pendingSyncGuestKey, _pendingImportIsGuest);
  }

  Future<void> _restorePendingSync(
    SharedPreferences preferences,
    String userId,
  ) async {
    final targetUserId = preferences.getString(_pendingSyncUserKey);
    final raw = preferences.getString(_pendingSyncImportKey);
    if (targetUserId != userId || raw == null || raw.isEmpty) {
      await _clearPendingSync(preferences: preferences);
      return;
    }
    try {
      _pendingSyncImport = Map<String, dynamic>.from(jsonDecode(raw) as Map);
      _pendingImportIsGuest =
          preferences.getBool(_pendingSyncGuestKey) ?? false;
      _pendingSyncUserId = targetUserId;
    } catch (_) {
      await _clearPendingSync(preferences: preferences);
    }
  }

  Future<void> _clearPendingSync({SharedPreferences? preferences}) async {
    _pendingSyncImport = null;
    _pendingImportIsGuest = false;
    _pendingSyncUserId = null;
    final prefs = preferences ?? await SharedPreferences.getInstance();
    await prefs.remove(_pendingSyncImportKey);
    await prefs.remove(_pendingSyncUserKey);
    await prefs.remove(_pendingSyncGuestKey);
  }

  Future<void> _cacheCurrentState() async {
    await _saveUser();
    await _saveCourseProgress();
    await _saveKnowledgeStates();
    await _saveHafizProgress();
    final preferences = await SharedPreferences.getInstance();
    if (_learningGoal != null) {
      await preferences.setString(
          _learningGoalKey, _learningGoal!.storageValue);
    }
    await preferences.setInt(_placementLevelKey, _placementLevel);
    if (_learningRecommendation != null) {
      await preferences.setString(
        _learningRecommendationKey,
        _learningRecommendation!,
      );
    }
    if (_learningSkillProfile != null) {
      await preferences.setString(
        _learningSkillProfileKey,
        jsonEncode(_learningSkillProfile!.toJson()),
      );
    }
    if (_nativeLanguage != null) {
      await preferences.setString('native_language', _nativeLanguage!.code);
    }
    await preferences.setBool('sound_enabled', _soundEnabled);
    await _saveMentorProfile();
  }

  @override
  void dispose() {
    _backend?.dispose();
    super.dispose();
  }
}
