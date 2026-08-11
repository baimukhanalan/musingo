part of '../profile_screen.dart';

class _PremiumUpsell extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumUpsell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.navyDark, AppColors.navy, AppColors.navyDark],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.18),
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.gold, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Muslingo+',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.tr(
                        ru: 'Максимум от твоего наставника',
                        kk: 'Ұстазыңнан барынша пайда',
                        en: 'The most from your mentor'),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

/// Премиум-карточка для ГОСТЯ: мягко предлагает создать аккаунт ради облачной
/// синхронизации, чтобы прогресс не потерялся при смене или очистке устройства.
/// Ничего не навязывает — это опциональный апселл, гость остаётся на устройстве.
class _GuestSaveProgressCard extends StatelessWidget {
  final VoidCallback onTap;
  const _GuestSaveProgressCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF5FC3EE), Color(0xFF3FA9DC), AppColors.navy],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: AppColors.sky.withValues(alpha: 0.38),
              blurRadius: 24,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  child: const Icon(Icons.cloud_upload_rounded,
                      color: Colors.white, size: 26),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.tr(
                            ru: 'Сохрани прогресс',
                            kk: 'Прогресіңді сақта',
                            en: 'Save your progress'),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        state.tr(
                            ru: 'Создай аккаунт — данные синхронизируются в '
                                'облако, и ты не потеряешь их при смене или '
                                'очистке устройства.',
                            kk: 'Аккаунт жаса — деректер бұлтқа синхрондалады, '
                                'құрылғыны ауыстырғанда немесе тазалағанда '
                                'жоғалмайды.',
                            en: 'Create an account — your data syncs to the '
                                'cloud so you won\'t lose it if you switch or '
                                'wipe your device.'),
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12.5,
                          height: 1.35,
                          fontWeight: FontWeight.w600,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            PremiumButton(
              label: state.tr(
                  ru: 'Создать аккаунт',
                  kk: 'Аккаунт жасау',
                  en: 'Create account'),
              variant: PremiumButtonVariant.gold,
              icon: Icons.arrow_forward_rounded,
              onPressed: onTap,
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      radius: 18,
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final bool first = i == 0;
          final bool last = i == items.length - 1;
          return Column(
            children: [
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.vertical(
                    top: first ? const Radius.circular(18) : Radius.zero,
                    bottom: last ? const Radius.circular(18) : Radius.zero,
                  ),
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(item.icon, color: item.color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (item.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.subtitle!,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textLight),
                      ],
                    ),
                  ),
                ),
              ),
              if (!last)
                const Divider(height: 1, color: AppColors.border, indent: 68),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    this.subtitle,
    this.onTap,
  });
}
