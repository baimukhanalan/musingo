part of '../lesson_screen.dart';

class _StepGuide extends StatelessWidget {
  final LessonStep step;
  final int currentStep;
  final int totalSteps;
  final bool reviewingMistakes;

  const _StepGuide({
    required this.step,
    required this.currentStep,
    required this.totalSteps,
    required this.reviewingMistakes,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final (icon, color, instruction) = _content(state);
    return Container(
      key: ValueKey('lesson-step-guide-$currentStep-$reviewingMistakes'),
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.32)),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 19, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  reviewingMistakes
                      ? state.tr(
                          ru: 'Разбор ошибки',
                          kk: 'Қатені талдау',
                          en: 'Mistake review',
                        )
                      : state.tr(
                          ru: 'Задача шага',
                          kk: 'Қадам тапсырмасы',
                          en: 'Step mission',
                        ),
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 11,
                    fontWeight: FontWeight.w900,
                    color: color,
                  ),
                ),
                Text(
                  instruction,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    height: 1.25,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Text(
            '$currentStep/$totalSteps',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  (IconData, Color, String) _content(AppState state) {
    switch (step.type) {
      case LessonStepType.audio:
        return (
          Icons.headphones_rounded,
          AppColors.sky,
          state.tr(
            ru: 'Нажми «Слушать» и проследи за словами.',
            kk: '«Тыңдау» түймесін басып, сөздерді бақыла.',
            en: 'Tap Listen and follow the words.',
          ),
        );
      case LessonStepType.text:
        return (
          Icons.lightbulb_rounded,
          AppColors.gold,
          state.tr(
            ru: step.arabicText == null
                ? 'Прочитай объяснение и найди главную мысль.'
                : 'Сравни текст, звучание и значение.',
            kk: step.arabicText == null
                ? 'Түсіндірмені оқып, негізгі ойды тап.'
                : 'Мәтінді, дыбысталуын және мағынасын салыстыр.',
            en: step.arabicText == null
                ? 'Read the explanation and find the main idea.'
                : 'Compare the text, sound, and meaning.',
          ),
        );
      case LessonStepType.question:
        return (
          Icons.psychology_alt_rounded,
          AppColors.navy,
          state.tr(
            ru: 'Подумай, затем выбери один ответ.',
            kk: 'Ойланып, бір жауапты таңда.',
            en: 'Think it through, then choose one answer.',
          ),
        );
      case LessonStepType.matching:
        return (
          Icons.compare_arrows_rounded,
          AppColors.coral,
          state.tr(
            ru: 'Нажми элемент слева, затем его пару справа.',
            kk: 'Сол жақтағы элементті, кейін оң жақтағы жұбын бас.',
            en: 'Tap an item on the left, then its pair on the right.',
          ),
        );
      case LessonStepType.speak:
        return (
          Icons.mic_rounded,
          AppColors.success,
          state.tr(
            ru: 'Сначала послушай образец, потом повтори в микрофон.',
            kk: 'Алдымен үлгіні тыңда, кейін микрофонға қайтала.',
            en: 'Listen to the sample first, then repeat into the mic.',
          ),
        );
      case LessonStepType.wordOrder:
        return (
          Icons.reorder_rounded,
          AppColors.gold,
          state.tr(
            ru: 'Собери фразу; слово сверху можно вернуть нажатием.',
            kk: 'Тіркесті құрастыр; үстіндегі сөзді басып қайтара аласың.',
            en: 'Build the phrase; tap a word above to return it.',
          ),
        );
      case LessonStepType.listenChoice:
        return (
          Icons.hearing_rounded,
          AppColors.sky,
          state.tr(
            ru: 'Прослушай фразу и только потом выбери ответ.',
            kk: 'Тіркесті тыңдап, содан кейін ғана жауапты таңда.',
            en: 'Listen to the phrase before choosing an answer.',
          ),
        );
    }
  }
}
