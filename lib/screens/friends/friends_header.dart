part of '../friends_screen.dart';

class _LeagueEntry extends StatelessWidget {
  final VoidCallback onTap;

  const _LeagueEntry({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Semantics(
      button: true,
      label: state.tr(
        ru: 'Открыть недельную лигу',
        kk: 'Апталық лиганы ашу',
        en: 'Open weekly league',
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: PremiumCard(
            radius: 18,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.gold.withValues(alpha: 0.18),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.emoji_events_rounded,
                      color: AppColors.gold, size: 27),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr(
                          ru: 'Недельная лига',
                          kk: 'Апталық лига',
                          en: 'Weekly league',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 17,
                          fontWeight: FontWeight.w900,
                          color: AppColors.navyDark,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        state.tr(
                          ru: 'Рейтинг реальных учеников по XP',
                          kk: 'Нақты оқушылардың XP рейтингі',
                          en: 'Real learners ranked by XP',
                        ),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.navy, size: 28),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Шапка экрана: крупный navy-заголовок «Друзья» + языковые пилюли справа.
class _FriendsHeader extends StatelessWidget {
  const _FriendsHeader();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          key: const Key('friends-back-button'),
          tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
          onPressed: () => Navigator.maybePop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded),
          color: AppColors.navyDark,
        ),
        Expanded(
          child: Text(state.tr(ru: 'Друзья', kk: 'Достар', en: 'Friends'),
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark)),
        ),
        const SizedBox(width: 12),
        const LanguagePills(),
      ],
    );
  }
}

/// Акцентная navy-градиентная карточка-приглашение к совместной учёбе.
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navyDark, AppColors.navy, AppColors.navyDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child:
                const Icon(Icons.groups_rounded, color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    state.tr(
                        ru: 'Учитесь вместе',
                        kk: 'Бірге үйреніңіз',
                        en: 'Learn together'),
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 5),
                Text(
                    state.tr(
                        ru: 'Пригласи друзей и соревнуйтесь по XP и страйку',
                        kk:
                            'Достарыңды шақырып, XP мен страйк бойынша жарысыңдар',
                        en: 'Invite friends and compete on XP and streak'),
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
