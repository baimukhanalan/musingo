part of '../lesson_screen.dart';

class _BottomBar extends StatelessWidget {
  final LessonStep step;
  final bool answered;
  final int? selectedAnswer;
  final bool speakPassed;
  final bool audioReady;
  final bool matchingComplete;
  final bool orderComplete;
  final bool reviewingMistakes;
  final bool isCorrect;
  final String? feedbackText;
  final bool showHint;
  final VoidCallback onCheck;
  final VoidCallback onContinue;
  final VoidCallback onHint;

  const _BottomBar({
    required this.step,
    required this.answered,
    required this.selectedAnswer,
    required this.speakPassed,
    required this.audioReady,
    required this.matchingComplete,
    required this.orderComplete,
    required this.reviewingMistakes,
    required this.isCorrect,
    required this.feedbackText,
    required this.showHint,
    required this.onCheck,
    required this.onContinue,
    required this.onHint,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    Color bgColor = Colors.transparent;
    if (answered && isCorrect) {
      bgColor = AppColors.success.withValues(alpha: 0.08);
    }
    if (answered && !isCorrect) {
      bgColor = AppColors.error.withValues(alpha: 0.07);
    }

    // Резолвим целевой колбэк ровно по прежней логике гейтов: null → кнопка
    // залочена (PremiumButton отрисует disabled-состояние).
    final VoidCallback? resolvedAction =
        answered ? onContinue : (_gateOpen ? onCheck : null);
    final String actionLabel = answered
        ? (reviewingMistakes
            ? state.tr(ru: 'Закрепить', kk: 'Бекіту', en: 'Reinforce')
            : state.tr(ru: 'Продолжить', kk: 'Жалғастыру', en: 'Continue'))
        : _checkLabel(state);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: bgColor,
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (answered) ...[
            AnimatedSize(
              duration: const Duration(milliseconds: 220),
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
                decoration: BoxDecoration(
                  color: (isCorrect ? AppColors.success : AppColors.error)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                        isCorrect
                            ? Icons.check_circle_rounded
                            : Icons.cancel_rounded,
                        color: isCorrect ? AppColors.success : AppColors.error,
                        size: 26),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isCorrect
                                ? state.tr(
                                    ru: 'Верно!', kk: 'Дұрыс!', en: 'Correct!')
                                : state.tr(
                                    ru: 'Разберём ответ',
                                    kk: 'Жауапты талдайық',
                                    en: 'Let’s review it'),
                            style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: isCorrect
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                          ),
                          if (feedbackText != null &&
                              feedbackText!.trim().isNotEmpty) ...[
                            const SizedBox(height: 3),
                            Text(
                              feedbackText!,
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 13,
                                height: 1.3,
                                fontWeight: FontWeight.w700,
                                color: AppColors.textDark,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Row(
            children: [
              if (!answered &&
                  !showHint &&
                  step.type == LessonStepType.question)
                Expanded(
                  flex: 1,
                  child: CustomButton(
                    text: '',
                    icon: Icons.lightbulb_rounded,
                    isOutlined: true,
                    onPressed: onHint,
                    height: 54,
                  ),
                ),
              if (!answered &&
                  !showHint &&
                  step.type == LessonStepType.question)
                const SizedBox(width: 10),
              Expanded(
                flex: 3,
                child: PremiumButton(
                  key: const ValueKey('lesson_primary_action'),
                  label: actionLabel,
                  onPressed: resolvedAction,
                  variant: answered && !isCorrect
                      ? PremiumButtonVariant.navy
                      : PremiumButtonVariant.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Открыт ли гейт «Проверить/Продолжить» до ответа: у каждого
  /// интерактивного типа шага своё условие готовности.
  bool get _gateOpen {
    switch (step.type) {
      case LessonStepType.question:
      case LessonStepType.listenChoice:
        return selectedAnswer != null;
      case LessonStepType.matching:
        return matchingComplete;
      case LessonStepType.wordOrder:
        return orderComplete;
      case LessonStepType.speak:
        return speakPassed;
      case LessonStepType.audio:
        return audioReady;
      case LessonStepType.text:
        return true;
    }
  }

  String _checkLabel(AppState state) {
    switch (step.type) {
      case LessonStepType.audio:
        return state.tr(ru: 'Дальше', kk: 'Әрі қарай', en: 'Next');
      case LessonStepType.text:
        return state.tr(ru: 'Понятно!', kk: 'Түсінікті!', en: 'Got it!');
      case LessonStepType.question:
        return state.tr(ru: 'Проверить', kk: 'Тексеру', en: 'Check');
      case LessonStepType.listenChoice:
        return state.tr(ru: 'Проверить', kk: 'Тексеру', en: 'Check');
      case LessonStepType.wordOrder:
        return state.tr(ru: 'Проверить', kk: 'Тексеру', en: 'Check');
      case LessonStepType.matching:
        return state.tr(ru: 'Продолжить', kk: 'Жалғастыру', en: 'Continue');
      case LessonStepType.speak:
        return state.tr(ru: 'Продолжить', kk: 'Жалғастыру', en: 'Continue');
    }
  }
}
