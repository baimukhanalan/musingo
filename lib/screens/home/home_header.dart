part of '../home_screen.dart';

class _GreetingHeader extends StatelessWidget {
  final String name;

  const _GreetingHeader({required this.name});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final firstName = state.isGuest
        ? state.tr(ru: 'Гость', kk: 'Қонақ', en: 'Guest')
        : _firstName(name);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${state.tr(ru: 'Ассаляму алейкум,', kk: 'Ассаламу әлейкум,', en: 'Assalamu alaikum,')}\n$firstName',
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 27,
              height: 1.12,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDark,
            ),
          ),
        ],
      ),
    );
  }

  static String _firstName(String name) {
    final trimmed = name.trim();
    if (trimmed.isEmpty) return 'друг';
    return trimmed.split(RegExp(r'\s+')).first;
  }
}

/// Row of three stat badges (streak / XP / hearts). Streak and hearts keep the
/// existing tap behaviour (streak screen, heart-restore sheet).
class _StatBadgesRow extends StatelessWidget {
  final int streak;
  final int xp;
  final int hearts;
  final bool isPremium;
  final VoidCallback onStreakTap;
  final VoidCallback onHeartsTap;

  const _StatBadgesRow({
    required this.streak,
    required this.xp,
    required this.hearts,
    required this.isPremium,
    required this.onStreakTap,
    required this.onHeartsTap,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 14, 18, 0),
      child: Row(
        children: [
          Expanded(
            child: _TapStat(
              onTap: onStreakTap,
              semanticLabel: state.tr(
                ru: 'Дней подряд: $streak. Открыть серию.',
                kk: 'Қатарынан күн: $streak. Серияны ашу.',
                en: 'Day streak: $streak. Open streak.',
              ),
              child: _CompactStatCard(
                icon: Icons.local_fire_department_rounded,
                value: '$streak',
                label: state.tr(ru: 'серия', kk: 'серия', en: 'streak'),
                accent: AppColors.gold,
              ),
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _CompactStatCard(
              icon: Icons.auto_awesome_rounded,
              value: _formatXp(xp),
              label: 'XP',
              accent: AppColors.sky,
            ),
          ),
          const SizedBox(width: 9),
          Expanded(
            child: _TapStat(
              onTap: onHeartsTap,
              semanticLabel: isPremium
                  ? state.tr(
                      ru: 'Жизни: безлимит.',
                      kk: 'Жандар: шексіз.',
                      en: 'Lives: unlimited.')
                  : state.tr(
                      ru: 'Жизни: $hearts. Восстановить жизнь.',
                      kk: 'Жандар: $hearts. Жанды қалпына келтіру.',
                      en: 'Lives: $hearts. Restore a life.'),
              child: _CompactStatCard(
                icon: Icons.favorite_rounded,
                value: isPremium ? '∞' : '$hearts',
                label: state.tr(ru: 'жизни', kk: 'жандар', en: 'lives'),
                accent: AppColors.coral,
              ),
            ),
          ),
        ],
      ),
    );
  }

  static String _formatXp(int xp) {
    final digits = xp.toString();
    final buffer = StringBuffer();
    for (var i = 0; i < digits.length; i++) {
      if (i > 0 && (digits.length - i) % 3 == 0) {
        buffer.write(' '); // narrow no-break space
      }
      buffer.write(digits[i]);
    }
    return buffer.toString();
  }
}

class _CompactStatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const _CompactStatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height:
          72 + (MediaQuery.textScalerOf(context).scale(40) - 40).clamp(0, 60),
      padding: const EdgeInsets.symmetric(horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: accent, size: 21),
          const SizedBox(width: 7),
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: AlignmentDirectional.centerStart,
                  child: Text(
                    value,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16.5,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  label,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    height: 1.2,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _TapStat extends StatelessWidget {
  final VoidCallback onTap;
  final String semanticLabel;
  final Widget child;

  const _TapStat({
    required this.onTap,
    required this.semanticLabel,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        child: child,
      ),
    );
  }
}

class _AcademyEntryCard extends StatelessWidget {
  final VoidCallback onTap;

  const _AcademyEntryCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 2),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: PremiumCard(
            radius: 20,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            child: Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: AppColors.skyLight,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.school_rounded,
                      color: AppColors.navy, size: 26),
                ),
                const SizedBox(width: 13),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr(ru: 'Академия', kk: 'Академия', en: 'Academy'),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 16,
                          fontWeight: FontWeight.w900,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        state.tr(
                            ru: 'Готовые программы: суры, алфавит, основы ислама',
                            kk: 'Дайын бағдарламалар: сүрелер, әліпби, ислам негіздері',
                            en: 'Ready programs: surahs, alphabet, basics of Islam'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.5,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textGrey),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
