part of '../friends_screen.dart';

class _GuestPrompt extends StatelessWidget {
  final VoidCallback onTap;
  const _GuestPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.sky.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: AppColors.navy, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
              state.tr(
                  ru: 'Соревнование доступно с аккаунтом',
                  kk: 'Жарыс аккаунтпен қолжетімді',
                  en: 'Competition is available with an account'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark)),
          const SizedBox(height: 8),
          Text(
              state.tr(
                  ru:
                      'Создай аккаунт, чтобы получить код-приглашение, добавлять друзей '
                      'и сравнивать прогресс на любом устройстве.',
                  kk: 'Шақыру кодын алу, дос қосу және кез келген құрылғыда '
                      'прогресті салыстыру үшін аккаунт жаса.',
                  en: 'Create an account to get an invite code, add friends '
                      'and compare progress on any device.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                  height: 1.45)),
          const SizedBox(height: 18),
          PremiumButton(
            label: state.tr(
                ru: 'Создать аккаунт',
                kk: 'Аккаунт жасау',
                en: 'Create account'),
            icon: Icons.person_add_alt_1_rounded,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  final String code;
  final String name;
  const _InviteCard({required this.code, required this.name});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
              text: state.tr(
                  ru: 'Твой код-приглашение',
                  kk: 'Сенің шақыру кодың',
                  en: 'Your invite code')),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.skyLight.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.sky.withValues(alpha: 0.4)),
            ),
            child: Text(code,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: AppColors.navyDark)),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (ctx) => PremiumButton(
              label: state.tr(
                  ru: 'Поделиться приглашением',
                  kk: 'Шақыруды бөлісу',
                  en: 'Share invitation'),
              icon: Icons.share_rounded,
              variant: PremiumButtonVariant.gold,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(
                  text: state.tr(
                      ru: 'Учу Коран в Muslingo — присоединяйся и посоревнуемся! '
                          'Мой код-приглашение: $code',
                      kk: 'Muslingo-да Құран үйреніп жүрмін — қосыл, жарысайық! '
                          'Менің шақыру кодым: $code',
                      en: "I'm learning Quran on Muslingo — join and let's compete! "
                          'My invite code: $code'),
                ));
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                      content: Text(state.tr(
                          ru: 'Приглашение скопировано — отправь другу',
                          kk: 'Шақыру көшірілді — досыңа жібер',
                          en: 'Invitation copied — send it to a friend'))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Поле ввода кода друга + кнопка «Добавить» (только для backend-пользователя).
class _AddFriendField extends StatelessWidget {
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSubmit;

  const _AddFriendField({
    required this.controller,
    required this.busy,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              maxLength: 12,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                counterText: '',
                hintText: state.tr(
                    ru: 'Код друга', kk: 'Достың коды', en: "Friend's code"),
                hintStyle: const TextStyle(
                    fontFamily: 'Nunito', color: AppColors.textLight),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 10),
          _AddButton(busy: busy, onSubmit: onSubmit),
        ],
      ),
    );
  }
}

/// Объёмная sky-кнопка «Добавить» с состоянием загрузки — под премиум-подачу,
/// но с busy-спиннером, которого нет у общего [PremiumButton].
class _AddButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onSubmit;

  const _AddButton({required this.busy, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: busy
            ? Color.lerp(AppColors.buttonDisabled, Colors.black, 0.18)
            : AppColors.navyDark.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        boxShadow: busy
            ? null
            : [
                BoxShadow(
                  color: AppColors.sky.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: busy ? null : onSubmit,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: busy
                      ? const [
                          AppColors.buttonDisabled,
                          AppColors.buttonDisabled
                        ]
                      : const [Color(0xFF5FC3EE), Color(0xFF3FA9DC)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(state.tr(ru: 'Добавить', kk: 'Қосу', en: 'Add'),
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Карточка друга: аватар-инициал, имя, его XP и страйк, кнопка удалить.
