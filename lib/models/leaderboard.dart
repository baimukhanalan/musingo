class LeaderboardEntry {
  final String userId;
  final String name;
  final String? avatarUrl;
  final int xp;
  final int position;
  final bool isCurrentUser;

  const LeaderboardEntry({
    required this.userId,
    required this.name,
    this.avatarUrl,
    required this.xp,
    required this.position,
    this.isCurrentUser = false,
  });
}
