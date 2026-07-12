import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../models/lesson.dart';
import '../models/achievement.dart';
import '../models/leaderboard.dart';
import 'backend_service.dart';
import 'lesson_data.dart';

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
  UserModel? _user;
  List<Course> _courses = [];
  final List<Achievement> _achievements = Achievement.defaults();
  bool _isLoading = false;
  bool _isInitialized = false;
  String? _error;
  BackendService? _backend;
  bool _soundEnabled = true;
  NativeLanguage? _nativeLanguage;

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
      _backend = await BackendService.create();
      final profile = await _backend!.restoreSession();
      if (profile != null) {
        _applyBackendProfile(profile);
      } else {
        await _loadUser();
        await _restoreCourseProgress();
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
        if (restored.id == 'guest') {
          await prefs.remove('user');
        } else {
          _user = restored;
        }
      } catch (_) {
        await prefs.remove('user');
      }
    }
    await _checkAndUpdateStreak();
  }

  Future<void> _saveUser() async {
    if (_user == null || isBackendUser) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user', jsonEncode(_user!.toJson()));
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
    await _saveUser();
    notifyListeners();
  }

  Future<bool> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    return _authenticate(() => _backend!.register(
          name: name,
          email: email,
          password: password,
        ));
  }

  Future<bool> loginWithPassword(String email, String password) async {
    return _authenticate(() => _backend!.login(
          email: email,
          password: password,
        ));
  }

  Future<bool> _authenticate(
    Future<BackendProfile> Function() operation,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _backend ??= await BackendService.create();
      final profile = await operation();
      _applyBackendProfile(profile);
      final preferences = await SharedPreferences.getInstance();
      await preferences.remove('user');
      return true;
    } catch (error) {
      _error = readableBackendError(error);
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _backend?.logout();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user');
    _user = null;
    _courses = LessonData.getCourses();
    notifyListeners();
  }

  Future<bool> deleteAccount() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (isBackendUser) await _backend!.deleteAccount();
      final preferences = await SharedPreferences.getInstance();
      if (_user != null) {
        await preferences.remove('completed_lessons_${_user!.id}');
      }
      await preferences.remove('user');
      _user = null;
      _courses = LessonData.getCourses();
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
    notifyListeners();
  }

  Future<void> setNativeLanguage(NativeLanguage language) async {
    _nativeLanguage = language;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('native_language', language.code);
    notifyListeners();
  }

  Future<Map<String, dynamic>> completeLesson(
      String lessonId, int errors) async {
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
        };
      } catch (error) {
        _error = readableBackendError(error);
        notifyListeners();
        rethrow;
      }
    }

    final now = DateTime.now();
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
    await _saveCourseProgress();
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

  Future<void> markAudioChapterDownloaded(int chapterNumber) async {
    if (_user == null) return;
    if (isBackendUser) {
      try {
        _applyBackendProfile(
          await _backend!.markAudioChapterDownloaded(chapterNumber),
        );
        notifyListeners();
        return;
      } catch (error) {
        _error = readableBackendError(error);
      }
    }
    final chapters = _user!.downloadedAudioChapters.toSet()..add(chapterNumber);
    _user = _user!.copyWith(
      downloadedAudioChapters: chapters.toList()..sort(),
    );
    await _saveUser();
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
    _user = _user!.copyWith(
      hearts: (_user!.hearts + 1).clamp(0, 5).toInt(),
      energy: (_user!.energy - 20).clamp(0, 999).toInt(),
    );
    await _saveUser();
    notifyListeners();
    return true;
  }

  Future<List<LeaderboardEntry>> fetchLeaderboard() async {
    if (!isBackendUser) return const [];
    try {
      return await _backend!.getLeaderboard();
    } catch (error) {
      _error = readableBackendError(error);
      notifyListeners();
      rethrow;
    }
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
    if (isBackendUser) return;
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

  @override
  void dispose() {
    _backend?.dispose();
    super.dispose();
  }
}
