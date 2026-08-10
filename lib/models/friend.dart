/// Друг из серверного списка. Идентификатор наружу — стабильный код-приглашение
/// (сырой UUID сервер не отдаёт), плюс публичные поля прогресса.
class Friend {
  final String code;
  final String displayName;
  final int xp;
  final int streak;

  const Friend({
    required this.code,
    required this.displayName,
    required this.xp,
    required this.streak,
  });

  factory Friend.fromJson(Map<String, dynamic> json) {
    return Friend(
      code: json['code'] as String? ?? '',
      displayName: json['displayName'] as String? ?? 'Ученик',
      xp: (json['xp'] as num?)?.toInt() ?? 0,
      streak: (json['streak'] as num?)?.toInt() ?? 0,
    );
  }
}
