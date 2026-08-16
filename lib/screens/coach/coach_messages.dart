part of '../coach_screen.dart';

class _CoachHeader extends StatelessWidget {
  final bool showBackButton;
  final VoidCallback onBack;

  const _CoachHeader({required this.showBackButton, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: Row(
        children: [
          if (showBackButton) ...[
            IconButton(
              key: const Key('coach-back-button'),
              tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
              onPressed: onBack,
              icon: const Icon(Icons.arrow_back_ios_new_rounded),
              color: AppColors.navyDark,
            ),
            const SizedBox(width: 4),
          ],
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.sky.withValues(alpha: 0.16),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyDark.withValues(alpha: 0.06),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CatCharacter(mood: CatMood.support, size: 40),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Muslingo Coach',
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    const Icon(Icons.verified_rounded,
                        size: 13, color: AppColors.success),
                    const SizedBox(width: 4),
                    Flexible(
                      child: Text(
                        state.tr(
                            ru: 'знает твой прогресс · отвечает по источникам',
                            kk: 'сенің прогресіңді біледі · дереккөздер бойынша жауап береді',
                            en: 'knows your progress · answers from sources'),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11.5,
                          height: 1.25,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textGrey,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MessageView extends StatelessWidget {
  final CoachMessage message;
  final VoidCallback? onAction;
  final ValueChanged<String> onSource;

  const _MessageView({
    required this.message,
    required this.onAction,
    required this.onSource,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final isUser = message.role == CoachRole.user;
    final isGreeting = message.id == 'greeting';
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            Container(
              width: 36,
              height: 36,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.sky.withValues(alpha: 0.16),
              ),
              child: const CatCharacter(mood: CatMood.support, size: 30),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 470),
              padding: const EdgeInsets.fromLTRB(15, 13, 15, 14),
              decoration: BoxDecoration(
                gradient: isUser
                    ? const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF5FC3EE), Color(0xFF3FA9DC)],
                      )
                    : null,
                color: isUser ? null : AppColors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: Radius.circular(isUser ? 20 : 6),
                  bottomRight: Radius.circular(isUser ? 6 : 20),
                ),
                boxShadow: [
                  BoxShadow(
                    color: (isUser ? AppColors.sky : AppColors.navyDark)
                        .withValues(alpha: isUser ? 0.28 : 0.06),
                    blurRadius: isUser ? 18 : 20,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14.5,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: isUser ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  if (isGreeting) const _ProgressSummary(),
                  if (message.sources.isNotEmpty) ...[
                    const SizedBox(height: 11),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 8),
                    for (final source in message.sources)
                      _SourceRow(source: source, onTap: onSource),
                  ],
                  if (onAction != null) ...[
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed: onAction,
                        icon: Icon(
                          message.actionType ==
                                  CoachActionType.contactSpecialist
                              ? Icons.support_agent_rounded
                              : message.actionType == CoachActionType.openHafiz
                                  ? Icons.self_improvement_rounded
                                  : message.actionType ==
                                          CoachActionType.openQuran
                                      ? Icons.menu_book_rounded
                                      : Icons.play_arrow_rounded,
                          size: 19,
                        ),
                        label: Text(message.actionLabel ??
                            state.tr(ru: 'Открыть', kk: 'Ашу', en: 'Open')),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.sky,
                          foregroundColor: Colors.white,
                          textStyle: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress snapshot inside the welcome bubble — streak, suras in progress and
/// memory accuracy, all read from [AppState]. Metrics render only when
/// meaningful data is available.
class _ProgressSummary extends StatelessWidget {
  const _ProgressSummary();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final streak = state.user?.streak ?? 0;
    final suras = state.courses
        .where((c) => c.type == CourseType.quran && c.completedLessons > 0)
        .length;
    final memory = state.knowledgeStates;
    final int? accuracyPct = memory.isEmpty
        ? null
        : (memory.map((k) => k.strength).reduce((a, b) => a + b) /
                memory.length *
                100)
            .round();

    final chips = <Widget>[
      if (streak > 0)
        _StatChip(
          icon: Icons.local_fire_department_rounded,
          value: '$streak',
          label: state.tr(ru: 'серия', kk: 'серия', en: 'streak'),
          accent: AppColors.gold,
        ),
      if (suras > 0)
        _StatChip(
          icon: Icons.menu_book_rounded,
          value: '$suras',
          label: state.tr(ru: 'суры', kk: 'сүрелер', en: 'surahs'),
          accent: AppColors.sky,
        ),
      if (accuracyPct != null)
        _StatChip(
          icon: Icons.insights_rounded,
          value: '$accuracyPct%',
          label: state.tr(ru: 'точность', kk: 'дәлдік', en: 'accuracy'),
          accent: accuracyPct >= 80
              ? AppColors.success
              : (accuracyPct >= 60 ? AppColors.sky : AppColors.coral),
        ),
    ];

    if (chips.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: chips,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color accent;

  const _StatChip({
    required this.icon,
    required this.value,
    required this.label,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: accent),
          const SizedBox(width: 6),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(width: 5),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.6,
              color: AppColors.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
