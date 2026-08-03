import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/lesson.dart';
import '../models/achievement.dart';
import '../models/leaderboard.dart';
import '../models/reminder_message.dart';
import '../models/learning_profile.dart';
import '../models/knowledge_state.dart';
import '../models/hafiz_progress.dart';
import 'backend_service.dart';
import 'lesson_data.dart';
import 'notification_service.dart';

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

class AppState extends ChangeNotifier {
  static const _localAccountsKey = 'local_email_accounts';
  static const _leagueSeasonKey = 'local_league_season';
  static const _leagueXpPrefix = 'local_league_xp_';
  static const _notificationsEnabledKey = 'notifications_enabled';
  static const _reminderHourKey = 'reminder_hour';
  static const _reminderMinuteKey = 'reminder_minute';
  static const _learningGoalKey = 'learning_goal';
  static const _placementLevelKey = 'placement_level';
  static const _learningRecommendationKey = 'learning_recommendation';
  static const _memoryEnginePrefix = 'memory_engine_';
  static const _hafizProgressPrefix = 'hafiz_progress_';

  UserModel? _user;
  List<Course> _courses = [];
  final List<Achievement> _achievements = Achievement.defaults();
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  BackendService? _backend;
  bool _soundEnabled = true;
  NativeLanguage? _nativeLanguage;
  final NotificationService _notificationService = NotificationService();
  bool _notificationsEnabled = false;
  int _reminderHour = 19;
  int _reminderMinute = 30;
  NotificationPermissionState _notificationPermission =
      NotificationPermissionState.prompt;
  LearningGoal? _learningGoal;
  int _placementLevel = 1;
  String? _learningRecommendation;
  Map<String, KnowledgeState> _knowledgeStates = {};
  Map<String, HafizProgress> _hafizProgress = {};

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
  bool get soundEnabled => _soundEnabled;
  NativeLanguage? get nativeLanguage => _nativeLanguage;
  bool get notificationsEnabled => _notificationsEnabled;
  int get reminderHour => _reminderHour;
  int get reminderMinute => _reminderMinute;
  NotificationPermissionState get notificationPermission =>
      _notificationPermission;
  bool get notificationsRunInBackground =>
      _notificationService.supportsBackgroundScheduling;
  LearningGoal? get learningGoal => _learningGoal;
  int get placementLevel => _placementLevel;
  String? get learningRecommendation => _learningRecommendation;
  List<KnowledgeState> get knowledgeStates =>
      _knowledgeStates.values.toList(growable: false);
  List<HafizProgress> get hafizProgress {
    final items = _hafizProgress.values.toList(growable: false)
      ..sort((a, b) => b.lastReviewedAt.compareTo(a.lastReviewedAt));
    return items;
  }
  int get hafizDueCount =>
      _hafizProgress.values.where((item) => item.isDue()).length;
  int get memorizedVerseCount => _hafizProgress.values
      .where((item) => item.mastery >= 0.7)
      .length;

  HafizProgress? hafizProgressFor(int surahNumber, int verseNumber) =>
      _hafizProgress['$surahNumber:$verseNumber'];
  int get dueReviewCount => _knowledgeStates.values
      .where((knowledge) => knowledge.isDue())
      .length;
  int get weakKnowledgeCount => _knowledgeStates.values
      .where((knowledge) => knowledge.isWeak)
      .length;
  DateTime? get nextReviewAt {
    if (_knowledgeStates.isEmpty) return null;
    final dates = _knowledgeStates.values
        .map((knowledge) => knowledge.nextReviewAt)
        .toList()
      ..sort();
    return dates.first;
  }

  bool isLessonDue(String lessonId, [DateTime? now]) => _knowledgeStates.values
      .any((knowledge) => knowledge.lessonId == lessonId && knowledge.isDue(now));

  Lesson? get recommendedLesson {
    final dueLessons = _knowledgeStates.values
        .where((knowledge) => knowledge.isDue())
        .toList()
      ..sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
    for (final knowledge in dueLessons) {
      final lesson = _findLesson(knowledge.lessonId);
      if (lesson != null) return lesson;
    }

    final preferredType = switch (_learningGoal) {
      LearningGoal.arabicReading => CourseType.arabic,
      LearningGoal.islamBasics => CourseType.rules,
      _ => CourseType.quran,
    };
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

  AppState() {
    _init();
  }

  Future<void> _init() async {
    try {
      _courses = LessonData.getCourses();
      final preferences = await SharedPreferences.getInstance();
      _soundEnabled = preferences.getBool('sound_enabled') ?? true;
      _nativeLanguage =
          NativeLanguage.fromCode(preferences.getString('native_language'));
      _notificationsEnabled =
          preferences.getBool(_notificationsEnabledKey) ?? false;
      _reminderHour = preferences.getInt(_reminderHourKey) ?? 19;
      _reminderMinute = preferences.getInt(_reminderMinuteKey) ?? 30;
      _learningGoal = LearningGoalDetails.fromStorage(
        preferences.getString(_learningGoalKey),
      );
      _placementLevel = preferences.getInt(_placementLevelKey) ?? 1;
      _learningRecommendation =
          preferences.getString(_learningRecommendationKey);
      try {
        await _notificationService.initialize();
        _notificationPermission =
            await _notificationService.permissionState();
        if (_notificationsEnabled &&
            _notificationPermission == NotificationPermissionState.granted) {
          await _scheduleLearningReminders();
        }
      } catch (_) {
        _notificationPermission = NotificationPermissionState.unsupported;
        _notificationsEnabled = false;
      }
      _backend = await BackendService.create();
      final profile = await _backend!.restoreSession();
      if (profile != null) {
        _applyBackendProfile(profile);
        await _cacheCurrentState();
      } else {
        await _loadUser();
        await _restoreCourseProgress();
        await _loadKnowledgeStates();
        await _loadHafizProgress();
        _checkAchievements();
      }
    } catch (error) {
      _error = error.toString();
    } finally {
      _isInitialized = true;
      notifyListeners();
    }
  }

  Future<void> _loadUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString('user');
    if (userJson != null) {
      try {
        final restored = UserModel.fromJson(jsonDecode(userJson));
        _user = restored;
      } catch (_) {
        await prefs.remove('user');
      }
    }
    await _checkAndUpdateStreak();
  }

  Future<void> _saveUser() async {
    if (_user == null) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_user!.toJson()));
    if (_user!.id.startsWith('local_') && _user!.email.isNotEmpty) {
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

    final diff = now.difference(last).inDays;
    if (diff > 1) {
      _user = _user!.copyWith(streak: 0);
      await _saveUser();
    }
  }

  Future<void> loginAsGuest() async {
    await _backend?.logout();
    _error = null;
    _user = UserModel.guest();
    await _restoreCourseProgress();
    await _loadKnowledgeStates();
    await _loadHafizProgress();
    await _saveUser();
    notifyListeners();
  }

  Future<bool> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    final localState = _user == null ? null : _buildSyncState();
    final serverSuccess = await _authenticate(() => _backend!.register(
          name: name,
          email: email,
          password: password,
        ),
        localState: localState,
        importGuest: localState != null);
    if (serverSuccess) return true;
    if (!BackendService.hasConfiguredApiUrl) {
      return _registerLocalAccount(name, email, password);
    }
    return false;
  }

  Future<bool> loginWithPassword(String email, String password) async {
    final localState = _user == null ? null : _buildSyncState();
    final serverSuccess = await _authenticate(() => _backend!.login(
          email: email,
          password: password,
        ),
        localState: localState,
        importGuest: isGuest);
    if (serverSuccess) return true;
    if (!BackendService.hasConfiguredApiUrl) {
      return _loginLocalAccount(email, password);
    }
    return false;
  }

  Future<bool> _authenticate(
    Future<BackendProfile> Function() operation,
    {
    Map<String, dynamic>? localState,
    bool importGuest = false,
    }
  ) async {
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
        } catch (_) {
          // The authenticated session remains valid; local data will sync later.
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
        _error =
            'Аккаунт с таким email уже есть. Войди через email и пароль.';
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
        'password': password,
        'user': user.toJson(),
      };
      await preferences.setString(_localAccountsKey, jsonEncode(accounts));
      final guestLessons = preferences.getString('completed_lessons_guest');
      if (guestLessons != null) {
        await preferences.setString(
          'completed_lessons_$userId',
          guestLessons,
        );
      }
      final guestMemory = preferences.getString('${_memoryEnginePrefix}guest');
      if (guestMemory != null) {
        await preferences.setString('$_memoryEnginePrefix$userId', guestMemory);
      }
      final guestHafiz =
          preferences.getString('${_hafizProgressPrefix}guest');
      if (guestHafiz != null) {
        await preferences.setString(
          '$_hafizProgressPrefix$userId',
          guestHafiz,
        );
      }
      await _backend?.logout();
      _user = user;
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
      if (account['password'] != password) {
        _error = 'Неверный email или пароль.';
        return false;
      }

      final userData = Map<String, dynamic>.from(account['user'] as Map);
      _user = UserModel.fromJson(userData);
      await _backend?.logout();
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

  String _localUserId(String email) =>
      'local_${base64Url.encode(utf8.encode(email)).replaceAll('=', '')}';

  Future<void> logout() async {
    await _backend?.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _user = null;
    _courses = LessonData.getCourses();
    _knowledgeStates = {};
    _hafizProgress = {};
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final currentUser = _user;
      if (isBackendUser) await _backend!.deleteAccount();
      final preferences = await SharedPreferences.getInstance();
      if (currentUser != null) {
        await preferences.remove('completed_lessons_${currentUser.id}');
        await preferences.remove('$_memoryEnginePrefix${currentUser.id}');
        await preferences.remove('$_hafizProgressPrefix${currentUser.id}');
        if (currentUser.id.startsWith('local_') &&
            currentUser.email.isNotEmpty) {
          final accounts = _decodeLocalAccounts(
            preferences.getString(_localAccountsKey),
          );
          accounts.remove(_normalizeEmail(currentUser.email));
          await preferences.setString(_localAccountsKey, jsonEncode(accounts));
        }
      }
      await preferences.remove('user');
      _user = null;
      _courses = LessonData.getCourses();
      _knowledgeStates = {};
      _hafizProgress = {};
      return true;
    } catch (error) {
      _error = readableBackendError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
  }) async {
    if (_user == null) await loginAsGuest();
    _learningGoal = goal;
    _placementLevel = level.clamp(1, 8).toInt();
    _learningRecommendation = recommendation;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(_learningGoalKey, goal.storageValue);
    await preferences.setInt(_placementLevelKey, _placementLevel);
    await preferences.setString(
      _learningRecommendationKey,
      recommendation,
    );
    await _syncBackendProgress();
    notifyListeners();
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
      _notificationsEnabled = true;
      await _scheduleLearningReminders();
    } else {
      _notificationsEnabled = false;
      await _notificationService.cancelAll();
    }
    final preferences = await SharedPreferences.getInstance();
    await preferences.setBool(
      _notificationsEnabledKey,
      _notificationsEnabled,
    );
    notifyListeners();
    return true;
  }

  Future<void> setReminderTime(int hour, int minute) async {
    _reminderHour = hour.clamp(0, 23).toInt();
    _reminderMinute = minute.clamp(0, 59).toInt();
    final preferences = await SharedPreferences.getInstance();
    await preferences.setInt(_reminderHourKey, _reminderHour);
    await preferences.setInt(_reminderMinuteKey, _reminderMinute);
    if (_notificationsEnabled) await _scheduleLearningReminders();
    notifyListeners();
  }

  Future<bool> sendTestNotification() async {
    if (!_notificationsEnabled) {
      final enabled = await setNotificationsEnabled(true);
      if (!enabled) return false;
    }
    return _notificationService.showTest(ReminderMessages.test);
  }

  Future<void> _scheduleLearningReminders() =>
      _notificationService.scheduleDaily(
        hour: _reminderHour,
        minute: _reminderMinute,
        messages: ReminderMessages.weekly,
        dueCount: dueReviewCount + hafizDueCount,
        learningGoal: _learningGoal?.storageValue ?? '',
      );

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
        final rewardToken = _rewardTokenFor(completedLesson, errors);
        final speechAttempts = completedLesson?.steps
                .where((step) => step.type == LessonStepType.speak)
                .length ??
            0;
        final result = await _backend!.completeLesson(
          lessonId,
          errors,
          speechAttempts,
          rewardToken,
        );
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
          'rewardToken': rewardToken,
          'weakKnowledgeCount': weakKnowledgeCount,
          'nextReviewAt': nextReviewAt,
        };
      } catch (error) {
        _error = readableBackendError(error);
        notifyListeners();
        rethrow;
      }
    }

    final now = completedAt ?? DateTime.now();
    final last = _user!.lastStudyDate;

    int newStreak = _user!.streak;
    bool streakBroken = false;
    if (last != null) {
      final diff = now.difference(last).inDays;
      if (diff == 1) {
        newStreak++;
      } else if (diff == 0) {
        // same day, keep streak
      } else {
        newStreak = 1;
        streakBroken = true;
      }
    } else {
      newStreak = 1;
    }

    int streakBonus = 0;
    if (newStreak == 7) {
      streakBonus = 10;
    } else if (newStreak == 30) {
      streakBonus = 50;
    } else if (newStreak == 100) {
      streakBonus = 200;
    }

    final completedLesson = _findLesson(lessonId);
    final xpEarned = completedLesson?.xpReward ?? 25;
    final newXp = _user!.xp + xpEarned + streakBonus;
    final newLevel = (newXp ~/ 500) + 1;
    final newHearts = _user!.hearts;
    final learnedAyats = completedLesson?.course == CourseType.quran
        ? completedLesson!.steps
            .where((step) => step.arabicText?.isNotEmpty ?? false)
            .length
        : 0;
    final learnedDuas = lessonId == 'r4' ? 2 : 0;
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
      dailyProgress:
          (_user!.dailyProgress + 1).clamp(0, _user!.dailyGoal).toInt(),
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
    await _updateMemoryForLesson(completedLesson, weakStepIds, now);
    await _saveCourseProgress();
    await _addLocalLeagueXp(xpEarned + streakBonus);
    await _saveUser();
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
    _user =
        _user!.copyWith(hearts: (_user!.hearts - 1).clamp(0, 5).toInt());
    _saveUser();
    notifyListeners();
  }

  Future<bool> spendEnergy(int amount, String rewardToken) async {
    if (_user == null || amount <= 0 || _user!.energy < amount) return false;
    _user = _user!.copyWith(
      energy: _user!.energy - amount,
      rewardHistory: [..._user!.rewardHistory, rewardToken],
    );
    await _saveUser();
    notifyListeners();
    return true;
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
    _user = _user!.copyWith(
      hearts: (_user!.hearts + 1).clamp(0, 5).toInt(),
      energy: (_user!.energy - 20).clamp(0, 999).toInt(),
    );
    await _saveUser();
    notifyListeners();
    return true;
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    if (!isBackendUser) return _localLeaderboard();
    try {
      return await _backend!.getLeaderboard();
    } catch (error) {
      _error = readableBackendError(error);
      notifyListeners();
      return _localLeaderboard();
    }
  }

  Future<List<LeaderboardEntry>> _localLeaderboard() async {
    final user = _user;
    if (user == null) return const [];
    final weeklyXp = await _localLeagueXp();
    final botSeed = _leagueSeasonId(DateTime.now()).hashCode.abs() % 90;
    final entries = <LeaderboardEntry>[
      LeaderboardEntry(
        userId: user.id,
        name: user.name.isEmpty ? 'Ты' : user.name,
        xp: weeklyXp,
        position: 0,
        isCurrentUser: true,
      ),
      LeaderboardEntry(
        userId: 'local_aisha',
        name: 'Аиша',
        xp: 620 + botSeed,
        position: 0,
      ),
      LeaderboardEntry(
        userId: 'local_umar',
        name: 'Умар',
        xp: 470 + (botSeed ~/ 2),
        position: 0,
      ),
      LeaderboardEntry(
        userId: 'local_mariam',
        name: 'Марьям',
        xp: 320 + (botSeed ~/ 3),
        position: 0,
      ),
      LeaderboardEntry(
        userId: 'local_yusuf',
        name: 'Юсуф',
        xp: 180 + (botSeed ~/ 4),
        position: 0,
      ),
    ]..sort((a, b) => b.xp.compareTo(a.xp));

    return entries.indexed.map((item) {
      final entry = item.$2;
      return LeaderboardEntry(
        userId: entry.userId,
        name: entry.name,
        avatarUrl: entry.avatarUrl,
        xp: entry.xp,
        position: item.$1 + 1,
        isCurrentUser: entry.isCurrentUser,
      );
    }).toList(growable: false);
  }

  Future<int> _localLeagueXp() async {
    final user = _user;
    if (user == null) return 0;
    final preferences = await SharedPreferences.getInstance();
    await _resetLeagueSeasonIfNeeded(preferences);
    return preferences.getInt('$_leagueXpPrefix${user.id}') ?? 0;
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
    if (_user == null) return;
    for (int i = 0; i < _achievements.length; i++) {
      final a = _achievements[i];
      if (a.isUnlocked) continue;
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
        _achievements[i] =
            a.copyWith(isUnlocked: true, unlockedAt: DateTime.now());
      }
    }
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
    await _saveHafizProgress();
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
        return lesson.course == CourseType.rules
            ? KnowledgeKind.rule
            : KnowledgeKind.meaning;
      case LessonStepType.audio:
      case LessonStepType.text:
        if (lesson.course == CourseType.quran) return KnowledgeKind.ayah;
        if (lesson.course == CourseType.rules) return KnowledgeKind.rule;
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
      'learningGoal': _learningGoal?.storageValue,
      'placementLevel': _placementLevel,
      'learningRecommendation': _learningRecommendation,
      'nativeLanguage': _nativeLanguage?.code,
      'soundEnabled': _soundEnabled,
    };
  }

  Future<void> _syncBackendProgress() async {
    if (!isBackendUser) return;
    try {
      final profile = await _backend!.syncLearningData(_buildSyncState());
      _applyBackendProfile(profile);
      await _cacheCurrentState();
    } catch (_) {
      // Local data stays available and is merged on the next successful sync.
    }
  }

  Future<void> _cacheCurrentState() async {
    await _saveUser();
    await _saveCourseProgress();
    await _saveKnowledgeStates();
    await _saveHafizProgress();
    final preferences = await SharedPreferences.getInstance();
    if (_learningGoal != null) {
      await preferences.setString(_learningGoalKey, _learningGoal!.storageValue);
    }
    await preferences.setInt(_placementLevelKey, _placementLevel);
    if (_learningRecommendation != null) {
      await preferences.setString(
        _learningRecommendationKey,
        _learningRecommendation!,
      );
    }
    if (_nativeLanguage != null) {
      await preferences.setString('native_language', _nativeLanguage!.code);
    }
    await preferences.setBool('sound_enabled', _soundEnabled);
  }

  @override
  void dispose() {
    _backend?.dispose();
    super.dispose();
  }
}
