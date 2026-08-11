part of '../home_screen.dart';

class _HeartRestoreSheet extends StatelessWidget {
  final int hearts;
  final int energy;
  final bool isPremium;

  const _HeartRestoreSheet({
    required this.hearts,
    required this.energy,
    required this.isPremium,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final canRestore = !isPremium && hearts < 5 && energy >= 20;
    final subtitle = isPremium
        ? state.tr(
            ru: 'У тебя уже безлимитные жизни.',
            kk: 'Сенде қазірдің өзінде шексіз жандар бар.',
            en: 'You already have unlimited lives.')
        : hearts >= 5
            ? state.tr(
                ru: 'Жизни уже полные.',
                kk: 'Жандар толық.',
                en: 'Lives are already full.')
            : energy >= 20
                ? state.tr(
                    ru: 'Потрать 20 энергии и продолжай уроки без ожидания.',
                    kk: '20 энергия жұмсап, сабақтарды күтпей жалғастыр.',
                    en: 'Spend 20 energy and keep learning without waiting.')
                : state.tr(
                    ru: 'Нужно 20 энергии. Проходи уроки, чтобы накопить её.',
                    kk: '20 энергия қажет. Оны жинау үшін сабақтардан өт.',
                    en: 'You need 20 energy. Complete lessons to earn it.');
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Icon(Icons.favorite_rounded,
                color: AppColors.error, size: 46),
            const SizedBox(height: 8),
            Text(
              state.tr(
                  ru: 'Восстановить жизнь',
                  kk: 'Жанды қалпына келтіру',
                  en: 'Restore a life'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14,
                height: 1.35,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _MiniResource(
                    icon: Icons.favorite_rounded,
                    label: state.tr(ru: 'Жизни', kk: 'Жандар', en: 'Lives'),
                    value: isPremium ? 'MAX' : '$hearts/5',
                    color: AppColors.error,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _MiniResource(
                    icon: Icons.battery_charging_full_rounded,
                    label: state.tr(ru: 'Энергия', kk: 'Энергия', en: 'Energy'),
                    value: '$energy',
                    color: AppColors.navy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: canRestore ? () => Navigator.pop(context, true) : null,
              icon: const Icon(Icons.bolt_rounded),
              label: Text(state.tr(
                  ru: 'Восстановить за 20 энергии',
                  kk: '20 энергияға қалпына келтіру',
                  en: 'Restore for 20 energy')),
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.navy,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.border,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MiniResource extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _MiniResource({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: color,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final NativeLanguage language;
  final VoidCallback onTap;

  const _LanguageButton({required this.language, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Semantics(
      button: true,
      label: state.tr(
          ru: 'Выбрать ${language.label}',
          kk: '${language.label} таңдау',
          en: 'Choose ${language.label}'),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          decoration: BoxDecoration(
            color: AppColors.skyLight,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.sky.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const Icon(Icons.translate_rounded,
                  color: AppColors.navy, size: 23),
              const SizedBox(width: 12),
              Text(
                language.label,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const Spacer(),
              const Icon(Icons.chevron_right_rounded,
                  color: AppColors.textGrey),
            ],
          ),
        ),
      ),
    );
  }
}
