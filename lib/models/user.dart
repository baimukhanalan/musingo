class UserModel {
  final String id;
  final String name;
  final String email;
  final String? avatarUrl;
  final int xp;
  final int level;
  final int streak;
  final int hearts;
  final int energy;
  final bool isPremium;
  final DateTime? lastStudyDate;
  final int totalLessons;
  final int totalMinutes;
  final int learnedAyats;
  final int learnedDuas;
  final int dailyGoal;
  final int dailyProgress;
  final int lessonAttempts;
  final int speechAttempts;
  final int rewardChestsOpened;
  final List<String> rewardHistory;
  final List<int> downloadedAudioChapters;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.avatarUrl,
    this.xp = 0,
    this.level = 1,
    this.streak = 0,
    this.hearts = 5,
    this.energy = 0,
    this.isPremium = false,
    this.lastStudyDate,
    this.totalLessons = 0,
    this.totalMinutes = 0,
    this.learnedAyats = 0,
    this.learnedDuas = 0,
    this.dailyGoal = 3,
    this.dailyProgress = 0,
    this.lessonAttempts = 0,
    this.speechAttempts = 0,
    this.rewardChestsOpened = 0,
    this.rewardHistory = const [],
    this.downloadedAudioChapters = const [],
  });

  int get xpForNextLevel => (level * 500) - xp;
  double get levelProgress => (xp % 500) / 500.0;

  UserModel copyWith({
    String? name,
    String? email,
    String? avatarUrl,
    int? xp,
    int? level,
    int? streak,
    int? hearts,
    int? energy,
    bool? isPremium,
    DateTime? lastStudyDate,
    int? totalLessons,
    int? totalMinutes,
    int? learnedAyats,
    int? learnedDuas,
    int? dailyGoal,
    int? dailyProgress,
    int? lessonAttempts,
    int? speechAttempts,
    int? rewardChestsOpened,
    List<String>? rewardHistory,
    List<int>? downloadedAudioChapters,
  }) {
    return UserModel(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      xp: xp ?? this.xp,
      level: level ?? this.level,
      streak: streak ?? this.streak,
      hearts: hearts ?? this.hearts,
      energy: energy ?? this.energy,
      isPremium: isPremium ?? this.isPremium,
      lastStudyDate: lastStudyDate ?? this.lastStudyDate,
      totalLessons: totalLessons ?? this.totalLessons,
      totalMinutes: totalMinutes ?? this.totalMinutes,
      learnedAyats: learnedAyats ?? this.learnedAyats,
      learnedDuas: learnedDuas ?? this.learnedDuas,
      dailyGoal: dailyGoal ?? this.dailyGoal,
      dailyProgress: dailyProgress ?? this.dailyProgress,
      lessonAttempts: lessonAttempts ?? this.lessonAttempts,
      speechAttempts: speechAttempts ?? this.speechAttempts,
      rewardChestsOpened: rewardChestsOpened ?? this.rewardChestsOpened,
      rewardHistory: rewardHistory ?? this.rewardHistory,
      downloadedAudioChapters:
          downloadedAudioChapters ?? this.downloadedAudioChapters,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'avatarUrl': avatarUrl,
        'xp': xp,
        'level': level,
        'streak': streak,
        'hearts': hearts,
        'energy': energy,
        'isPremium': isPremium,
        'lastStudyDate': lastStudyDate?.toIso8601String(),
        'totalLessons': totalLessons,
        'totalMinutes': totalMinutes,
        'learnedAyats': learnedAyats,
        'learnedDuas': learnedDuas,
        'dailyGoal': dailyGoal,
        'dailyProgress': dailyProgress,
        'lessonAttempts': lessonAttempts,
        'speechAttempts': speechAttempts,
        'rewardChestsOpened': rewardChestsOpened,
        'rewardHistory': rewardHistory,
        'downloadedAudioChapters': downloadedAudioChapters,
      };

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        id: json['id'],
        name: json['name'],
        email: json['email'],
        avatarUrl: json['avatarUrl'],
        xp: json['xp'] ?? 0,
        level: json['level'] ?? 1,
        streak: json['streak'] ?? 0,
        hearts: json['hearts'] ?? 5,
        energy: json['energy'] ?? 0,
        isPremium: json['isPremium'] ?? false,
        lastStudyDate: json['lastStudyDate'] != null
            ? DateTime.parse(json['lastStudyDate'])
            : null,
        totalLessons: json['totalLessons'] ?? 0,
        totalMinutes: json['totalMinutes'] ?? 0,
        learnedAyats: json['learnedAyats'] ?? 0,
        learnedDuas: json['learnedDuas'] ?? 0,
        dailyGoal: json['dailyGoal'] ?? 3,
        dailyProgress: json['dailyProgress'] ?? 0,
        lessonAttempts: json['lessonAttempts'] ?? 0,
        speechAttempts: json['speechAttempts'] ?? 0,
        rewardChestsOpened: json['rewardChestsOpened'] ?? 0,
        rewardHistory: _stringList(json['rewardHistory']),
        downloadedAudioChapters: _intList(json['downloadedAudioChapters']),
      );

  static UserModel guest() => const UserModel(
        id: 'guest',
        name: 'Гость',
        email: '',
        xp: 0,
        level: 1,
        streak: 0,
        hearts: 3,
        energy: 0,
      );
}

List<String> _stringList(Object? value) {
  if (value is List) return value.whereType<String>().toList(growable: false);
  return const [];
}

List<int> _intList(Object? value) {
  if (value is List) {
    return value
        .map((item) => item is num ? item.toInt() : int.tryParse('$item'))
        .whereType<int>()
        .toList(growable: false);
  }
  return const [];
}
