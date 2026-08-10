import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/friend.dart';
import '../models/user.dart';

class BackendProfile {
  final UserModel user;
  final Set<String> completedLessons;
  final Map<String, dynamic> learningState;

  const BackendProfile({
    required this.user,
    required this.completedLessons,
    this.learningState = const {},
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

class BackendException implements Exception {
  final int statusCode;
  final String code;
  final String message;

  const BackendException(this.statusCode, this.code, this.message);

  @override
  String toString() => 'BackendException($statusCode, $code, $message)';
}

class BackendService {
  static const _authStorageKey = 'muslingo_auth_token';

  final http.Client _client;
  final SharedPreferences _preferences;
  String? _token;

  BackendService._(this._client, this._preferences, this._token);

  static Future<BackendService> create({http.Client? client}) async {
    final preferences = await SharedPreferences.getInstance();
    return BackendService._(
      client ?? http.Client(),
      preferences,
      preferences.getString(_authStorageKey),
    );
  }

  static String get apiBaseUrl {
    const configured = String.fromEnvironment('MUSLINGO_API_URL');
    if (configured.isNotEmpty) return configured.replaceAll(RegExp(r'/$'), '');
    if (kIsWeb) return Uri.base.origin;
    if (defaultTargetPlatform == TargetPlatform.android) {
      return 'http://10.0.2.2:8090';
    }
    return 'http://127.0.0.1:8090';
  }

  static bool get hasConfiguredApiUrl =>
      const String.fromEnvironment('MUSLINGO_API_URL').isNotEmpty;

  bool get isAuthenticated => _token?.isNotEmpty == true;
  String? get authToken => _token;

  Future<BackendProfile?> restoreSession() async {
    if (!isAuthenticated) return null;
    try {
      final response = await _request('GET', '/api/auth/me');
      return _profileFromProgress(response);
    } catch (_) {
      await logout();
      return null;
    }
  }

  Future<BackendProfile> register({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _request(
      'POST',
      '/api/auth/register',
      authenticated: false,
      body: {'name': name, 'email': email, 'password': password},
    );
    await _storeToken(response['token'] as String?);
    return _profileFromProgress(
      Map<String, dynamic>.from(response['profile'] as Map),
    );
  }

  Future<BackendProfile> login({
    required String email,
    required String password,
  }) async {
    final response = await _request(
      'POST',
      '/api/auth/login',
      authenticated: false,
      body: {'email': email, 'password': password},
    );
    await _storeToken(response['token'] as String?);
    return _profileFromProgress(
      Map<String, dynamic>.from(response['profile'] as Map),
    );
  }

  Future<void> logout() async {
    _token = null;
    await _preferences.remove(_authStorageKey);
  }

  Future<void> deleteAccount() async {
    await _request('DELETE', '/api/account', allowEmpty: true);
    await logout();
  }

  Future<BackendProfile> syncLearningData(
    Map<String, dynamic> state, {
    bool importGuest = false,
  }) async {
    final response = await _request(
      'POST',
      '/api/progress/sync',
      body: {'state': state, 'importGuest': importGuest},
    );
    return _profileFromProgress(
      Map<String, dynamic>.from(response['profile'] as Map),
    );
  }

  Future<LessonCompletionResult> completeLesson(
    String lessonId,
    int errors,
    int speechAttempts,
    String rewardToken,
  ) async {
    final now = DateTime.now();
    final localDate =
        '${now.year.toString().padLeft(4, '0')}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
    // Сервер валидирует errors как {min:0,max:5} и бросает 400 при >5
    // (server/lib/http.js integer()). matching растит счётчик на каждый неверный
    // тап, так что 6+ ошибок набирается легко и раньше отклоняло completion —
    // прогресс залогиненного уходил «в никуда». Клампим у самой точки отправки.
    final safeErrors = errors.clamp(0, 5).toInt();
    final safeSpeechAttempts = speechAttempts.clamp(0, 50).toInt();
    final response = await _request(
      'POST',
      '/api/progress/complete',
      body: {
        'lessonId': lessonId,
        'errors': safeErrors,
        'speechAttempts': safeSpeechAttempts,
        'rewardToken': rewardToken,
        'localDate': localDate,
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
    final response = await _request('POST', '/api/progress/restore-heart');
    return _profileFromProgress(response);
  }

  /// Собственный код-приглашение (детерминированно выведен сервером из id) и
  /// display_name. Одним GET сервер отдаёт и код, и список друзей.
  Future<({String code, String displayName})> myFriendCode() async {
    final response = await _request('GET', '/api/friends');
    return (
      code: response['code'] as String? ?? '',
      displayName: response['displayName'] as String? ?? '',
    );
  }

  Future<List<Friend>> listFriends() async {
    final response = await _request('GET', '/api/friends');
    final list = response['friends'] as List<dynamic>? ?? const [];
    return list
        .whereType<Map>()
        .map((item) => Friend.fromJson(Map<String, dynamic>.from(item)))
        .toList(growable: false);
  }

  Future<Friend> addFriend(String code) async {
    final response = await _request(
      'POST',
      '/api/friends',
      body: {'action': 'add', 'code': code},
    );
    return Friend.fromJson(Map<String, dynamic>.from(response['friend'] as Map));
  }

  Future<void> removeFriend(String code) async {
    await _request(
      'POST',
      '/api/friends',
      body: {'action': 'remove', 'code': code},
      allowEmpty: true,
    );
  }

  Future<Map<String, dynamic>> _request(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
    bool allowEmpty = false,
  }) async {
    final response = await _send(
      method,
      path,
      body: body,
      authenticated: authenticated,
    );
    if (response.body.isEmpty && allowEmpty) return const {};
    final decoded = jsonDecode(response.body);
    if (decoded is! Map) {
      throw const BackendException(500, 'invalid_response', 'Invalid server response.');
    }
    return Map<String, dynamic>.from(decoded);
  }

  Future<http.Response> _send(
    String method,
    String path, {
    Map<String, dynamic>? body,
    bool authenticated = true,
  }) async {
    final headers = <String, String>{
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    };
    if (authenticated && _token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    final uri = Uri.parse('$apiBaseUrl$path');
    try {
      final request = switch (method) {
        'GET' => _client.get(uri, headers: headers),
        'POST' => _client.post(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          ),
        'DELETE' => _client.delete(
            uri,
            headers: headers,
            body: body == null ? null : jsonEncode(body),
          ),
        _ => throw ArgumentError('Unsupported HTTP method: $method'),
      };
      final response = await request.timeout(const Duration(seconds: 8));
      if (response.statusCode < 200 || response.statusCode >= 300) {
        var code = 'request_failed';
        var message = 'Request failed.';
        try {
          final error = jsonDecode(response.body);
          if (error is Map) {
            code = error['error'] as String? ?? code;
            message = error['message'] as String? ?? message;
          }
        } catch (_) {}
        throw BackendException(response.statusCode, code, message);
      }
      return response;
    } on BackendException {
      rethrow;
    } catch (_) {
      throw const BackendException(0, 'network_error', 'Server unavailable.');
    }
  }

  Future<void> _storeToken(String? token) async {
    if (token == null || token.isEmpty) {
      throw const BackendException(500, 'invalid_response', 'Authentication token is missing.');
    }
    _token = token;
    await _preferences.setString(_authStorageKey, token);
  }

  BackendProfile _profileFromProgress(Map<String, dynamic> progress) {
    final lastStudyDay = progress['lastStudyDay'] as String? ?? '';
    final completed =
        (progress['completedLessons'] as List<dynamic>? ?? const [])
            .whereType<String>()
            .toSet();
    return BackendProfile(
      user: UserModel(
        id: progress['user'] as String? ?? '',
        name: progress['displayName'] as String? ?? 'Ученик',
        email: progress['email'] as String? ?? '',
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
      learningState: Map<String, dynamic>.from(progress),
    );
  }

  void dispose() => _client.close();
}

String readableBackendError(Object error) {
  if (error is BackendException) {
    switch (error.code) {
      case 'network_error':
        return 'Сервер недоступен. Проверь подключение и повтори.';
      case 'already_exists':
        return 'Аккаунт с таким email уже есть. Войди через email и пароль.';
      case 'invalid_credentials':
        return 'Неверный email или пароль.';
      case 'not_enough_energy':
        return 'Нужно 20 энергии, чтобы восстановить жизнь.';
      case 'hearts_full':
        return 'Жизни уже полные.';
      case 'too_many_attempts':
        return 'Слишком много попыток входа. Попробуй через 15 минут.';
      case 'expired_session':
      case 'invalid_session':
        return 'Сессия истекла. Войди в аккаунт снова.';
      case 'invalid_code':
        return 'Неверный код-приглашение. Проверь и попробуй ещё раз.';
      case 'cannot_add_self':
        return 'Нельзя добавить самого себя.';
      case 'friend_not_found':
        return 'Друг с таким кодом не найден.';
      default:
        if (error.statusCode == 0) {
          return 'Сервер недоступен. Проверь подключение и повтори.';
        }
        return error.message.isEmpty
            ? 'Не удалось выполнить действие. Попробуй ещё раз.'
            : error.message;
    }
  }
  return 'Не удалось выполнить действие. Попробуй ещё раз.';
}
