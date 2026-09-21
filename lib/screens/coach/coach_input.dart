part of '../coach_screen.dart';

class _CoachInput extends StatelessWidget {
  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSend;

  const _CoachInput({
    required this.controller,
    required this.enabled,
    required this.onSend,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(26),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.navyDark.withValues(alpha: 0.05),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 4,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
                decoration: InputDecoration(
                  hintText: state.tr(
                      ru: 'Спроси об уроке или повторении',
                      kk: 'Сабақ немесе қайталау туралы сұра',
                      en: 'Ask about a lesson or review'),
                  hintStyle: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textLight,
                  ),
                  filled: false,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 13),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          _SendButton(onTap: enabled ? onSend : null),
        ],
      ),
    );
  }
}

/// Round premium send button with an upward arrow (↑).
class _SendButton extends StatelessWidget {
  final VoidCallback? onTap;

  const _SendButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bool enabled = onTap != null;
    return Semantics(
      label: state.tr(
          ru: 'Отправить сообщение',
          kk: 'Хабарлама жіберу',
          en: 'Send message'),
      button: true,
      child: Tooltip(
        message: state.tr(ru: 'Отправить', kk: 'Жіберу', en: 'Send'),
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: enabled
                ? [
                    BoxShadow(
                      color: AppColors.sky.withValues(alpha: 0.4),
                      blurRadius: 16,
                      offset: const Offset(0, 8),
                    ),
                  ]
                : null,
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: onTap,
              customBorder: const CircleBorder(),
              child: Ink(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: enabled
                      ? const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF5FC3EE), Color(0xFF3FA9DC)],
                        )
                      : null,
                  color: enabled ? null : AppColors.buttonDisabled,
                ),
                child: const Icon(Icons.arrow_upward_rounded,
                    color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
