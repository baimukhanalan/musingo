part of '../profile_screen.dart';

/// Премиум-карточка для ГОСТЯ: мягко предлагает создать аккаунт ради облачной
/// синхронизации, чтобы прогресс не потерялся при смене или очистке устройства.
/// Ничего не навязывает — это опциональный апселл, гость остаётся на устройстве.
class _GuestSaveProgressCard extends StatelessWidget {
  final VoidCallback onTap;
  const _GuestSaveProgressCard({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 8),
      color: const Color(0xFFEEF8FD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.80),
                ),
                child: const Icon(Icons.cloud_upload_rounded,
                    color: AppColors.navy, size: 22),
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
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      state.tr(
                          ru: 'Новый прогресс — в облаке. Гостевые уроки и награды останутся здесь.',
                          kk: 'Жаңа прогресс бұлтта сақталады. Қонақ сабақтары мен марапаттары осында қалады.',
                          en: 'Sync new progress to the cloud. Guest lessons and rewards stay here.'),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerRight,
            child: TextButton.icon(
              onPressed: onTap,
              style: TextButton.styleFrom(foregroundColor: AppColors.navy),
              label: Text(state.tr(
                  ru: 'Создать аккаунт',
                  kk: 'Аккаунт жасау',
                  en: 'Create account')),
              icon: const Icon(Icons.arrow_forward_rounded, size: 18),
              iconAlignment: IconAlignment.end,
            ),
          ),
        ],
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
