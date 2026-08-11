part of '../friends_screen.dart';

class _FriendTile extends StatelessWidget {
  final Friend friend;
  final VoidCallback onRemove;

  const _FriendTile({required this.friend, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final trimmed = friend.displayName.trim();
    final initial =
        trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 18,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.skyLight,
                  AppColors.sky.withValues(alpha: 0.35),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Text(initial,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.bolt_rounded,
                      label: '${friend.xp} XP',
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.local_fire_department_rounded,
                      label: '${friend.streak}',
                      color: AppColors.coral,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.person_remove_alt_1_rounded,
                color: AppColors.textLight, size: 22),
            tooltip: state.tr(
                ru: 'Удалить из друзей',
                kk: 'Достардан өшіру',
                en: 'Remove from friends'),
          ),
        ],
      ),
    );
  }
}

/// Маленький «пилюльный» чип статы друга (XP/страйк).
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color.lerp(color, AppColors.navyDark, 0.35))),
        ],
      ),
    );
  }
}

/// Ошибка загрузки списка друзей (обычно оффлайн). Код-приглашение при этом
/// всё равно показан из локального фолбэка, а список можно перезапросить.
class _LoadErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.textLight.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded,
                color: AppColors.textGrey, size: 28),
          ),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                  height: 1.45)),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onRetry,
            child: Text(state.tr(ru: 'Повторить', kk: 'Қайталау', en: 'Retry'),
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy)),
          ),
        ],
      ),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.sky.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_add_alt_1_rounded,
                color: AppColors.navy, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
              state.tr(
                  ru: 'Пока никого', kk: 'Әзірге ешкім жоқ', en: 'No one yet'),
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark)),
          const SizedBox(height: 8),
          Text(
              state.tr(
                  ru:
                      'Пригласи друзей по коду выше. Когда они присоединятся, здесь '
                      'появится их прогресс, и вы сможете соревноваться.',
                  kk:
                      'Жоғарыдағы код арқылы достарыңды шақыр. Олар қосылғанда, '
                      'осында олардың прогресі пайда болып, жарыса аласыңдар.',
                  en:
                      'Invite friends with the code above. When they join, their '
                      'progress will appear here and you can compete.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                  height: 1.45)),
        ],
      ),
    );
  }
}
