part of '../lesson_screen.dart';

class _BottomBar extends StatelessWidget {
  final LessonStep step;
  final bool answered;
  final int? selectedAnswer;
  final bool speakPassed;
  final bool matchingComplete;
  final bool orderComplete;
  final bool reviewingMistakes;
  final bool isCorrect;
  final bool showHint;
  final VoidCallback onCheck;
  final VoidCallback onContinue;
  final VoidCallback onHint;

  const _BottomBar({
    required this.step,
    required this.answered,
    required this.selectedAnswer,
    required this.speakPassed,
    required this.matchingComplete,
    required this.orderComplete,
    required this.reviewingMistakes,
    required this.isCorrect,
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
            Row(
              children: [
                Icon(
                    isCorrect
                        ? Icons.check_circle_rounded
                        : Icons.cancel_rounded,
                    color: isCorrect ? AppColors.success : AppColors.error,
                    size: 28),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    isCorrect
                        ? state.tr(
                            ru: 'Правильно!', kk: 'Дұрыс!', en: 'Correct!')
                        : state.tr(
                            ru: 'Неправильно. Верный ответ показан ниже',
                            kk: 'Қате. Дұрыс жауап төменде көрсетілген',
                            en: 'Wrong. The correct answer is shown below'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: isCorrect ? AppColors.success : AppColors.error,
                    ),
                  ),
                ),
              ],
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
