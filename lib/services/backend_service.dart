import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/coach.dart';
import '../models/friend.dart';
import '../models/leaderboard.dart';
import '../models/user.dart';
import '../utils/runtime_environment.dart';

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

class EmailActionResult {
  final bool accepted;
  final String delivery;

  const EmailActionResult({required this.accepted, required this.delivery});

  bool get canDeliver => delivery == 'provider_configured';
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
  final FlutterSecureStorage _secureStorage;
  final bool _secureStorageAvailable;
  String? _token;
  String? _lastEmailDelivery;

  BackendService._(
    this._client,
    this._preferences,
    this._secureStorage,
    this._secureStorageAvailable,
    this._token,
  );

  static bool get _usesSecureStorage =>
      !kIsWeb &&
      !isFlutterTest &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);

  static Future<BackendService> create({http.Client? client}) async {
    final preferences = await SharedPreferences.getInstance();
    const secureStorage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(
        accessibility: KeychainAccessibility.first_unlock_this_device,
      ),
    );
    String? token;
    var secureStorageAvailable = false;
    if (_usesSecureStorage) {
      try {
        token = await secureStorage.read(key: _authStorageKey);
        secureStorageAvailable = true;
        final legacyToken = preferences.getString(_authStorageKey);
        if ((token == null || token.isEmpty) &&
            legacyToken?.isNotEmpty == true) {
          token = legacyToken;
          await secureStorage.write(key: _authStorageKey, value: legacyToken);
        }
        await preferences.remove(_authStorageKey);
      } catch (_) {
        token = preferences.getString(_authStorageKey);
      }
    } else {
      token = preferences.getString(_authStorageKey);
    }
    return BackendService._(
      client ?? http.Client(),
      preferences,
      secureStorage,
      secureStorageAvailable,
      token,
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

  /// Local email accounts are a native development fallback only. Web builds
  /// always have a same-origin API endpoint, even when no dart-define is set;
  /// silently creating a device-only account there would hide server outages.
  static bool shouldUseLocalAccountFallback({
    required bool isWeb,
    required String configuredApiUrl,
  }) =>
      !isWeb && configuredApiUrl.trim().isEmpty;

  static bool get allowsLocalAccountFallback => shouldUseLocalAccountFallback(
        isWeb: kIsWeb,
        configuredApiUrl: const String.fromEnvironment('MUSLINGO_API_URL'),
      );

  bool get isAuthenticated => _token?.isNotEmpty == true;
  String? get authToken => _token;
  String? get lastEmailDelivery => _lastEmailDelivery;

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
    _lastEmailDelivery = response['delivery'] as String?;
    return login(email: email, password: password);
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
    if (isAuthenticated) {
      try {
        await _request('POST', '/api/auth/logout', allowEmpty: true);
      } catch (_) {
        // Local cleanup must still complete when the session is already
        // expired or the network is unavailable.
      }
    }
    _token = null;
    await _clearStoredToken();
  }

  Future<void> deleteAccount() async {
    await _request('DELETE', '/api/account', allowEmpty: true);
    _token = null;
    await _clearStoredToken();
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _request(
      'POST',
      '/api/auth/password',
      body: {
        'currentPassword': currentPassword,
        'newPassword': newPassword,
      },
    );
    await _storeToken(response['token'] as String?);
  }

  Future<EmailActionResult> requestPasswordReset(String email) async {
    final response = await _request(
      'POST',
      '/api/auth/password/forgot',
      authenticated: false,
      body: {'email': email.trim()},
    );
    return EmailActionResult(
      accepted: response['accepted'] == true,
      delivery: response['delivery'] as String? ?? 'unknown',
    );
  }

  Future<void> resetPassword({
    required String token,
    required String newPassword,
  }) async {
    await _request(
      'POST',
      '/api/auth/password/reset',
      authenticated: false,
      body: {'token': token, 'newPassword': newPassword},
    );
  }

  Future<EmailActionResult> requestEmailVerification(String email) async {
    final response = await _request(
      'POST',
      '/api/auth/verification/request',
      authenticated: false,
      body: {'email': email.trim()},
    );
    return EmailActionResult(
      accepted: response['accepted'] == true,
      delivery: response['delivery'] as String? ?? 'unknown',
    );
  }

  Future<void> confirmEmailVerification(String token) async {
    await _request(
      'POST',
      '/api/auth/verification/confirm',
      authenticated: false,
      body: {'token': token},
    );
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

  Future<String> startLessonAttempt(String lessonId) async {
    final response = await _request(
      'POST',
      '/api/progress/attempt',
      body: {'lessonId': lessonId},
    );
    final token = response['attemptToken'] as String?;
    if (token == null || token.isEmpty) {
      throw const BackendException(
        502,
        'invalid_lesson_attempt',
        'The server did not return a lesson attempt.',
      );
    }
    return token;
  }

  Future<LessonCompletionResult> completeLesson(
    String lessonId,
    int errors,
    int speechAttempts,
    String attemptToken,
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
        'attemptToken': attemptToken,
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

  Future<void> recordLessonStep(
    String lessonId,
    int stepIndex,
    String attemptToken,
  ) async {
    await _request(
      'POST',
      '/api/progress/step',
      body: {
        'lessonId': lessonId,
        'stepIndex': stepIndex,
        'attemptToken': attemptToken,
      },
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
    return Friend.fromJson(
        Map<String, dynamic>.from(response['friend'] as Map));
  }

  Future<void> removeFriend(String code) async {
    await _request(
      'POST',
      '/api/friends',
      body: {'action': 'remove', 'code': code},
      allowEmpty: true,
    );
  }

  Future<List<LeaderboardEntry>> getLeaderboard() async {
    final response = await _send('GET', '/api/leaderboard');
    final decoded = jsonDecode(response.body);
    if (decoded is! List) {
      throw const BackendException(
        500,
        'invalid_response',
        'Invalid leaderboard response.',
      );
    }
    return decoded.indexed.map((indexed) {
      final index = indexed.$1;
      final raw = indexed.$2;
      if (raw is! Map) {
        throw const BackendException(
          500,
          'invalid_response',
          'Invalid leaderboard entry.',
        );
      }
      final item = Map<String, dynamic>.from(raw);
      return LeaderboardEntry(
        userId: 'leaderboard-${item['position'] ?? index + 1}',
        name: (item['displayName'] as String?)?.trim().isNotEmpty == true
            ? (item['displayName'] as String).trim()
            : 'Ученик',
        xp: (item['xp'] as num?)?.toInt() ?? 0,
        position: (item['position'] as num?)?.toInt() ?? index + 1,
        isCurrentUser: item['isCurrentUser'] == true,
      );
    }).toList(growable: false);
  }

  /// Спрашивает серверного AI-коуча. JWT добавляется автоматически, если
  /// пользователь залогинен (иначе анонимный запрос). Никогда не бросает
  /// наружу: при 503 `coach_unavailable`, любой другой ошибке, таймауте или
  /// недоступности сервера возвращает `null` — вызывающий откатывается на
  /// локальный движок.
  Future<CoachResponse?> askCoach({
    required String question,
    required String locale,
    required Map<String, dynamic> context,
    List<Map<String, dynamic>>? catalog,
  }) async {
    try {
      final response = await _request(
        'POST',
        '/api/coach',
        body: {
          'question': question,
          'locale': locale,
          'context': context,
          if (catalog != null) 'catalog': catalog,
        },
      );
      return _coachResponseFromJson(response);
    } catch (_) {
      // 503/сеть/парсинг/недоступность — тихий откат на локальный движок.
      return null;
    }
  }

  CoachResponse? _coachResponseFromJson(Map<String, dynamic> json) {
    final text = (json['text'] as String?)?.trim();
    if (text == null || text.isEmpty) return null;

    // action может прийти как строка ("startLesson") или объектом
    // {type, lessonId, label} — поддерживаем оба варианта.
    CoachActionType? actionType;
    String? lessonId = json['lessonId'] as String?;
    String? actionLabel = json['actionLabel'] as String?;
    final rawAction = json['action'];
    if (rawAction is String) {
      actionType = _coachActionFromString(rawAction);
    } else if (rawAction is Map) {
      final action = Map<String, dynamic>.from(rawAction);
      actionType = _coachActionFromString(action['type'] as String?);
      lessonId = (action['lessonId'] as String?) ?? lessonId;
      actionLabel = (action['label'] as String?) ??
          (action['actionLabel'] as String?) ??
          actionLabel;
    }

    final rawSources = json['sources'];
    final sources = <CoachSource>[];
    if (rawSources is List) {
      for (final item in rawSources) {
        if (item is! Map) continue;
        final source = Map<String, dynamic>.from(item);
        final title = (source['title'] as String?)?.trim();
        if (title == null || title.isEmpty) continue;
        final url = (source['url'] as String?)?.trim();
        sources.add(CoachSource(
          title: title,
          category: (source['category'] as String?)?.trim() ?? '',
          verification: (source['verification'] as String?)?.trim() ?? '',
          url: (url == null || url.isEmpty) ? null : url,
        ));
      }
    }

    return CoachResponse(
      text: text,
      sources: sources,
      actionType: actionType,
      actionLabel: actionLabel,
      lessonId: lessonId,
    );
  }

  CoachActionType? _coachActionFromString(String? raw) {
    switch (raw?.trim()) {
      case 'startLesson':
        return CoachActionType.startLesson;
      case 'openQuran':
        return CoachActionType.openQuran;
      case 'openHafiz':
        return CoachActionType.openHafiz;
      case 'contactSpecialist':
        return CoachActionType.contactSpecialist;
      default:
        return null;
    }
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
      throw const BackendException(
          500, 'invalid_response', 'Invalid server response.');
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
      throw const BackendException(
          500, 'invalid_response', 'Authentication token is missing.');
    }
    _token = token;
    if (_usesSecureStorage && _secureStorageAvailable) {
      await _secureStorage.write(key: _authStorageKey, value: token);
      await _preferences.remove(_authStorageKey);
    } else {
      await _preferences.setString(_authStorageKey, token);
    }
  }

  Future<void> _clearStoredToken() async {
    await _preferences.remove(_authStorageKey);
    if (_usesSecureStorage && _secureStorageAvailable) {
      await _secureStorage.delete(key: _authStorageKey);
    }
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
        rewardHistory: (progress['rewardHistory'] as List<dynamic>? ?? const [])
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
      case 'invalid_current_password':
        return 'Текущий пароль указан неверно.';
      case 'password_reuse':
        return 'Новый пароль должен отличаться от текущего.';
      case 'password_changed':
        return 'Пароль уже изменён в другой сессии. Войди снова.';
      case 'invalid_or_expired_token':
        return 'Ссылка недействительна или уже использована. Запроси новую.';
      case 'email_not_verified':
        return 'Подтверди email по ссылке из письма, затем войди снова.';
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
