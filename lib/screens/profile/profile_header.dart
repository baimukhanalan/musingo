part of '../profile_screen.dart';

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(isPremium: user.isPremium),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.navyDark,
                            ),
                          ),
                        ),
                        if (user.isPremium) const _PremiumChip(),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${state.tr(ru: 'Уровень', kk: 'Деңгей', en: 'Level')} '
                      '${user.level} · ${_levelTitle(state, user.level)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: LanguagePills(
              selected: _langCode(state.nativeLanguage),
            ),
          ),
        ],
      ),
    );
  }

  String _langCode(NativeLanguage? lang) {
    switch (lang) {
      case NativeLanguage.kazakh:
        return 'KZ';
      case NativeLanguage.russian:
      case NativeLanguage.uzbek:
      case null:
        return 'RU';
    }
  }
}

class _Avatar extends StatelessWidget {
  final bool isPremium;
  const _Avatar({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.skyLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.sky.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const CatCharacter(mood: CatMood.idle, size: 62),
          ),
          if (isPremium)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _PremiumChip extends StatelessWidget {
  const _PremiumChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: const Text(
        'muslingo+',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserModel user;
  final int suras;
  final int accuracy;

  const _StatsRow({
    required this.user,
    required this.suras,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StatBadge(
              icon: Icons.local_fire_department_rounded,
              value: '${user.streak}',
              label: state.tr(ru: 'Серия', kk: 'Серия', en: 'Streak'),
              accent: AppColors.coral,
            ),
          ),
          Expanded(
            child: StatBadge(
              icon: Icons.bolt_rounded,
              value: '${user.xp}',
              label: 'XP',
              accent: AppColors.gold,
            ),
          ),
          Expanded(
            child: StatBadge(
              icon: Icons.menu_book_rounded,
              value: '$suras',
              label: state.tr(ru: 'Суры', kk: 'Сүрелер', en: 'Suras'),
              accent: AppColors.sky,
            ),
          ),
          Expanded(
            child: StatBadge(
              icon: Icons.track_changes_rounded,
              value: '$accuracy%',
              label: state.tr(ru: 'Точность', kk: 'Дәлдік', en: 'Accuracy'),
              accent: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final List<bool> week;
  final VoidCallback onTap;

  const _WeekStrip({required this.week, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final labels = [
      state.tr(ru: 'Пн', kk: 'Дс', en: 'Mon'),
      state.tr(ru: 'Вт', kk: 'Сс', en: 'Tue'),
      state.tr(ru: 'Ср', kk: 'Ср', en: 'Wed'),
      state.tr(ru: 'Чт', kk: 'Бс', en: 'Thu'),
      state.tr(ru: 'Пт', kk: 'Жм', en: 'Fri'),
      state.tr(ru: 'Сб', kk: 'Сн', en: 'Sat'),
      state.tr(ru: 'Вс', kk: 'Жс', en: 'Sun'),
    ];
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0..6

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: PremiumCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            return _DayDot(
              label: labels[i],
              active: week[i],
              isToday: i == todayIndex,
            );
          }),
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String label;
  final bool active;
  final bool isToday;

  const _DayDot({
    required this.label,
    required this.active,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    late final BoxDecoration decoration;
    late final Widget dotChild;

    if (active) {
      decoration = const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5FC3EE), Color(0xFF3FA9DC)],
        ),
      );
      dotChild = const Icon(Icons.check_rounded, size: 20, color: Colors.white);
    } else {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundGrey,
        border: Border.all(
          color: isToday ? AppColors.sky : AppColors.border,
          width: isToday ? 2 : 1,
        ),
      );
      dotChild = const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: decoration,
          child: dotChild,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
            color: isToday ? AppColors.navyDark : AppColors.textLight,
          ),
        ),
      ],
    );
  }
}
