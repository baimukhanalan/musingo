import 'package:flutter/foundation.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/leaderboard.dart';
import '../models/user.dart';

class BackendProfile {
  final UserModel user;
  final Set<String> completedLessons;

  const BackendProfile({
    required this.user,
    required this.completedLessons,
  });
}

class LessonCompletionResult {
  final BackendProfile profile;
  final int xpEarned;
  final int streakBonus;

  const LessonCompletionResult({
    required this.profile,
    required this.xpEarned,
    required this.streakBonus,
  });
}

class BackendService {
  static const _authStorageKey = 'pocketbase_auth';

  final PocketBase _client;

  BackendService._(this._client);

  static Future<BackendService> create() async {
    final preferences = await SharedPreferences.getInstance();
    final authStore = AsyncAuthStore(
      save: (data) async => preferences.setString(_authStorageKey, data),
      clear: () async => preferences.remove(_authStorageKey),
      initial: preferences.getString(_authStorageKey),
    );

    return BackendService._(
      PocketBase(
        apiBaseUrl,
        authStore: authStore,
        lang: 'ru-RU',
        reuseHTTPClient: true,
      ),
    );
  }

  static String get apiBaseUrl {
    const configured = String.fromEnvironment('MUSLINGO_API_URL');
    if (configured.isNotEmpty) return configured;
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8090';
    }
    return 'http://127.0.0.1:8090';
  }

  bool get isAuthenticated => _client.authStore.isValid;

  Future<BackendProfile?> restoreSession() async {
    if (!isAuthenticated) return null;
    try {
      await _client.collection('users').authRefresh();
      return await _fetchProfile();
    } catch (_) {
      _client.authStore.clear();
      return null;
    }
  }

  Future<BackendProfile> register({
    required String name,
    required String email,
    required String password,
  }) async {
    await _client.collection('users').create(body: {
      'name': name,
      'email': email,
      'password': password,
      'passwordConfirm': password,
    });
    await _client.collection('users').authWithPassword(email, password);
    return _fetchProfile();
  }

  Future<BackendProfile> login({
    required String email,
    required String password,
  }) async {
    await _client.collection('users').authWithPassword(email, password);
    return _fetchProfile();
  }

  Future<void> logout() async => _client.authStore.clear();

  Future<void> deleteAccount() async {
    await _client.send<void>(
      '/api/muslingo/account',
      method: 'DELETE',
    );
    _client.authStore.clear();
  }

  Future<LessonCompletionResult> completeLesson(
    String lessonId,
    int errors,
    int speechAttempts,
    String rewardToken,
  ) async {
    final response = await _client.send<Map<String, dynamic>>(
      '/api/muslingo/progress/complete',
      method: 'POST',
      body: {
        'lessonId': lessonId,
        'errors': errors,
        'speechAttempts': speechAttempts,
        'rewardToken': rewardToken,
      },
    );
    return LessonCompletionResult(
      profile: _profileFromProgress(
        Map<String, dynamic>.from(response['progress'] as Map),
      ),
      xpEarned: (response['xpEarned'] as num?)?.toInt() ?? 0,
      streakBonus: (response['streakBonus'] as num?)?.toInt() ?? 0,
    );
  }

  Future<BackendProfile> restoreHeart() async {
    final response = await _client.send<Map<String, dynamic>>(
      '/api/muslingo/progress/restore-heart',
      method: 'POST',
    );
    return _profileFromProgress(response);
  }

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final response = await _client.send<List<dynamic>>(
      '/api/muslingo/leaderboard',
    );
    final currentUserId = _client.authStore.record?.id;
    return response.indexed.map((item) {
      final index = item.$1;
      final data = Map<String, dynamic>.from(item.$2 as Map);
      final userId = data['user'] as String? ?? '';
      return LeaderboardEntry(
        userId: userId,
        name: data['displayName'] as String? ?? 'Ученик',
        xp: (data['xp'] as num?)?.toInt() ?? 0,
        position: index + 1,
        isCurrentUser: userId == currentUserId,
      );
    }).toList(growable: false);
  }

  Future<BackendProfile> _fetchProfile() async {
    final response = await _client.send<Map<String, dynamic>>(
      '/api/muslingo/me',
    );
    return _profileFromProgress(response);
  }

  BackendProfile _profileFromProgress(Map<String, dynamic> progress) {
    final authRecord = _client.authStore.record;
    final lastStudyDay = progress['lastStudyDay'] as String? ?? '';
    final completed =
        (progress['completedLessons'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toSet();
    return BackendProfile(
      user: UserModel(
        id: progress['user'] as String? ?? authRecord?.id ?? '',
        name: progress['displayName'] as String? ?? 'Ученик',
        email: authRecord?.data['email'] as String? ?? '',
        xp: (progress['xp'] as num?)?.toInt() ?? 0,
        level: (progress['level'] as num?)?.toInt() ?? 1,
        streak: (progress['streak'] as num?)?.toInt() ?? 0,
        hearts: (progress['hearts'] as num?)?.toInt() ?? 5,
        energy: (progress['energy'] as num?)?.toInt() ?? 0,
        isPremium: progress['isPremium'] as bool? ?? false,
        lastStudyDate:
            lastStudyDay.isEmpty ? null : DateTime.tryParse(lastStudyDay),
        totalLessons: (progress['totalLessons'] as num?)?.toInt() ?? 0,
        totalMinutes: (progress['totalMinutes'] as num?)?.toInt() ?? 0,
        learnedAyats: (progress['learnedAyats'] as num?)?.toInt() ?? 0,
        learnedDuas: (progress['learnedDuas'] as num?)?.toInt() ?? 0,
        dailyGoal: (progress['dailyGoal'] as num?)?.toInt() ?? 3,
        dailyProgress: (progress['dailyProgress'] as num?)?.toInt() ?? 0,
        lessonAttempts: (progress['lessonAttempts'] as num?)?.toInt() ?? 0,
        speechAttempts: (progress['speechAttempts'] as num?)?.toInt() ?? 0,
        rewardChestsOpened:
            (progress['rewardChestsOpened'] as num?)?.toInt() ?? 0,
        rewardHistory:
            (progress['rewardHistory'] as List<dynamic>? ?? const [])
                .whereType<String>()
                .toList(growable: false),
      ),
      completedLessons: completed,
    );
  }

  void dispose() => _client.close();
}

String readableBackendError(Object error) {
  if (error is ClientException) {
    final data = error.response['data'];
    if (data is Map) {
      for (final value in data.values) {
        if (value is Map && value['message'] is String) {
          final fieldMessage = value['message'] as String;
          if (_isUniqueConstraintMessage(fieldMessage)) {
            return 'Аккаунт с таким email уже есть. Войди через email и пароль.';
          }
          return fieldMessage;
        }
      }
    }
    final message = error.response['message'];
    if (message is String && message.isNotEmpty) {
      if (_isUniqueConstraintMessage(message)) {
        return 'Аккаунт с таким email уже есть. Войди через email и пароль.';
      }
      if (message.toLowerCase().contains('failed to authenticate')) {
        return 'Неверный email или пароль.';
      }
      if (message.toLowerCase().contains('not enough energy')) {
        return 'Нужно 20 энергии, чтобы восстановить жизнь.';
      }
      if (message.toLowerCase().contains('hearts are already full')) {
        return 'Жизни уже полные.';
      }
      return message;
    }
    if (error.statusCode == 0) {
      return 'Сервер недоступен. Проверь подключение и повтори.';
    }
  }
  return 'Не удалось выполнить действие. Попробуй ещё раз.';
}

bool _isUniqueConstraintMessage(String message) {
  final normalized = message.toLowerCase();
  return normalized.contains('value must be unique') ||
      normalized.contains('must be unique') ||
      normalized.contains('already exists') ||
      normalized.contains('уже существует');
}
