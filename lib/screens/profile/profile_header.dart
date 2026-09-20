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
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            state.isGuest
                                ? state.tr(
                                    ru: 'Гость', kk: 'Қонақ', en: 'Guest')
                                : user.name,
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
      case NativeLanguage.english:
        return 'EN';
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
      width: 96,
      height: 108,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 96,
            height: 108,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(28),
              color: AppColors.skyLight.withValues(alpha: 0.6),
            ),
            alignment: Alignment.center,
            child: const CatCharacter(mood: CatMood.idle, size: 96),
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
      child: LayoutBuilder(builder: (context, constraints) {
        final useTwoColumns = constraints.maxWidth < 300 ||
            MediaQuery.textScalerOf(context).scale(14) > 18 ||
            user.xp > 99999;
        final stats = <Widget>[
          _ProfileStat(
            icon: Icons.local_fire_department_rounded,
            value: '${user.streak}',
            label: state.tr(ru: 'Серия', kk: 'Серия', en: 'Streak'),
            accent: AppColors.coral,
          ),
          _ProfileStat(
            icon: Icons.bolt_rounded,
            value: '${user.xp}',
            label: 'XP',
            accent: AppColors.gold,
          ),
          _ProfileStat(
            icon: Icons.menu_book_rounded,
            value: '$suras',
            label: state.tr(
                ru: 'Уроки Корана', kk: 'Құран сабақтары', en: 'Quran lessons'),
            accent: AppColors.sky,
          ),
          _ProfileStat(
            icon: Icons.track_changes_rounded,
            value: '$accuracy%',
            label:
                state.tr(ru: 'Запоминание', kk: 'Есте сақтау', en: 'Retention'),
            accent: AppColors.success,
          ),
        ];
        return useTwoColumns
            ? Wrap(
                runSpacing: 20,
                children: [
                  for (final stat in stats)
                    SizedBox(width: constraints.maxWidth / 2, child: stat),
                ],
              )
            : Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [for (final stat in stats) Expanded(child: stat)],
              );
      }),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const _ProfileStat({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(icon, color: accent, size: 23),
          ),
          const SizedBox(height: 8),
          Text(value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark,
              )),
          const SizedBox(height: 3),
          Text(label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: AppColors.textGrey,
              )),
        ],
      );
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

    return PremiumCard(
      padding: EdgeInsets.zero,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          key: const ValueKey('profile-week-details'),
          onTap: onTap,
          borderRadius: BorderRadius.circular(22),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(
                      7,
                      (i) => Expanded(
                            child: _DayDot(
                              key: ValueKey('profile-week-day-$i'),
                              label: labels[i],
                              active: week[i],
                              isToday: i == todayIndex,
                              isFuture: i > todayIndex,
                            ),
                          )),
                ),
                const SizedBox(height: 14),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(Icons.local_fire_department_rounded,
                        size: 17, color: AppColors.navy),
                    const SizedBox(width: 7),
                    Expanded(
                      child: Text(
                        state.tr(
                          ru: 'Цветом — дни текущей серии',
                          kk: 'Түспен — ағымдағы серия күндері',
                          en: 'Colour marks your current streak',
                        ),
                        style: const TextStyle(
                          fontSize: 12,
                          height: 1.35,
                          color: AppColors.textGrey,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded,
                        size: 18, color: AppColors.textGrey),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String label;
  final bool active;
  final bool isToday;
  final bool isFuture;

  const _DayDot({
    super.key,
    required this.label,
    required this.active,
    required this.isToday,
    required this.isFuture,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    late final BoxDecoration decoration;
    late final IconData icon;

    if (active) {
      decoration = const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF479BC2), AppColors.navy],
        ),
      );
      icon = Icons.local_fire_department_rounded;
    } else {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: isToday ? AppColors.skyLight : AppColors.backgroundGrey,
        border: Border.all(
          color: isToday ? AppColors.sky : AppColors.border,
          width: isToday ? 2 : 1,
        ),
      );
      icon = isToday
          ? Icons.play_arrow_rounded
          : (isFuture ? Icons.schedule_rounded : Icons.remove_rounded);
    }

    final status = active
        ? state.tr(
            ru: 'В текущей серии',
            kk: 'Ағымдағы серияда',
            en: 'In current streak')
        : isToday
            ? state.tr(
                ru: 'Сегодня, урок ещё не завершён',
                kk: 'Бүгін сабақ әлі аяқталмады',
                en: 'Today, lesson not yet completed')
            : isFuture
                ? state.tr(ru: 'Впереди', kk: 'Алда', en: 'Upcoming')
                : state.tr(
                    ru: 'Вне текущей серии',
                    kk: 'Ағымдағы сериядан тыс',
                    en: 'Outside current streak');
    return Semantics(
      label: '$label, $status',
      excludeSemantics: true,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: decoration,
            child: Icon(icon,
                size: 19,
                color: active
                    ? Colors.white
                    : (isToday ? AppColors.navy : AppColors.textGrey)),
          ),
          const SizedBox(height: 6),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 10.5,
              fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
              color: isToday ? AppColors.navyDark : AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
