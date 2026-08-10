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
import '../utils/app_locale.dart';
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
  static const _localeKey = 'locale';

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

  /// Слепок локального/гостевого прогресса, который не удалось влить на сервер
  /// в момент входа/регистрации (сеть упала на syncLearningData). Держим его,
  /// чтобы следующий успешный sync доимпортировал данные и НИЧЕГО не потерялось.
  /// [_pendingImportIsGuest] сохраняет флаг слияния (гостевой импорт мержит по
  /// принципу «серверное новее не перетираем»).
  Map<String, dynamic>? _pendingSyncImport;
  bool _pendingImportIsGuest = false;

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

  /// Текущий язык интерфейса. Экраны читают его через
  /// `context.watch<AppState>().locale`, поэтому смена перестраивает подписчиков.
  AppLocale get locale => _locale;
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
    return _calendarDaysBetween(last, DateTime.now()) == 0 ? u.dailyProgress : 0;
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

  static const _pbkdf2Iterations = 12000;

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
    // Легаси: пароль лежал открытым текстом. Сверяем и вызывающий код
    // тут же перезапишет запись хешем.
    return stored == password;
  }

  Future<void> _init() async {
    try {
      _courses = LessonData.getCourses();
      final preferences = await SharedPreferences.getInstance();
      _soundEnabled = preferences.getBool('sound_enabled') ?? true;
      _locale = AppLocale.fromCode(preferences.getString(_localeKey));
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
    _applyHeartRegen();
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
          _pendingSyncImport = null;
        } catch (_) {
          // Сессия валидна, но импорт локального/гостевого прогресса не прошёл.
          // Сохраняем ИМЕННО этот слепок (а не пересобранный из серверного
          // состояния, которое ниже перетрёт память) — следующий _syncBackendProgress
          // повторит импорт с тем же importGuest и данные не потеряются.
          _pendingSyncImport = localState;
          _pendingImportIsGuest = importGuest;
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
        // Раньше пароль лежал в SharedPreferences открытым текстом.
        'passwordHash': _hashLocalPassword(password),
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
      final stored = (account['passwordHash'] ?? account['password']) as String?;
      if (stored == null || !_verifyLocalPassword(password, stored)) {
        _error = 'Неверный email или пароль.';
        return false;
      }
      // Миграция: аккаунт с паролем в открытом виде пересохраняем хешем.
      if (account['passwordHash'] == null) {
        final migrated = Map<String, dynamic>.from(account as Map)
          ..remove('password')
          ..['passwordHash'] = _hashLocalPassword(password);
        accounts[normalizedEmail] = migrated;
        await preferences.setString(_localAccountsKey, jsonEncode(accounts));
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
    await prefs.remove('$_leagueXpPrefix$userId');
  }

  /// Сбрасывает общий (не привязанный к id) учебный профиль: цель, уровень и
  /// персональную рекомендацию — и в памяти, и в prefs. Без этого следующий
  /// гость на устройстве видел бы чужой план и рекомендацию.
  Future<void> _clearLearningProfile(SharedPreferences prefs) async {
    _learningGoal = null;
    _placementLevel = 1;
    _learningRecommendation = null;
    await prefs.remove(_learningGoalKey);
    await prefs.remove(_placementLevelKey);
    await prefs.remove(_learningRecommendationKey);
  }

  Future<void> logout() async {
    final currentUser = _user;
    await _backend?.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    // Чистим данные завершаемого пользователя (для гостя — именно guest-ключи,
    // чтобы «Начать заново» реально начинало с чистого листа) и общий учебный
    // профиль. Данные других локальных аккаунтов остаются нетронутыми.
    if (currentUser != null) {
      await _clearUserScopedData(prefs, currentUser.id);
    }
    await _clearLearningProfile(prefs);
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

  Future<void> _scheduleLearningReminders() {
    final name = _user?.name ?? '';
    final streak = _user?.streak ?? 0;
    final due = dueReviewCount + hafizDueCount;
    final goal = _learningGoal?.storageValue ?? '';
    return _notificationService.scheduleDaily(
      hour: _reminderHour,
      minute: _reminderMinute,
      messages: buildReminders(
        name: name,
        streak: streak,
        dueCount: due,
        learningGoal: goal,
        locale: _locale,
      ),
      dueCount: due,
      learningGoal: goal,
      name: name,
      streak: streak,
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
        return lesson.course == CourseType.rules
            ? KnowledgeKind.rule
            : KnowledgeKind.meaning;
      // Сборка фразы из слов — это память на порядок слов аята: тот же тип
      // знания, что у matching-заданий.
      case LessonStepType.wordOrder:
        return KnowledgeKind.matching;
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
    // Сначала добиваем незавершённый импорт локального/гостевого прогресса.
    // Отправляем сохранённый слепок, а не текущее состояние: после неудачного
    // входа память уже равна серверной, и пересбор потерял бы гостевые данные.
    final pendingImport = _pendingSyncImport;
    try {
      final profile = pendingImport != null
          ? await _backend!.syncLearningData(
              pendingImport,
              importGuest: _pendingImportIsGuest,
            )
          : await _backend!.syncLearningData(_buildSyncState());
      _pendingSyncImport = null;
      _applyBackendProfile(profile);
      await _cacheCurrentState();
    } catch (_) {
      // Local data stays available and is merged on the next successful sync;
      // отложенный импорт остаётся в _pendingSyncImport до следующей попытки.
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
