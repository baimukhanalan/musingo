import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/learning_profile.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/language_pills.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Экран 1a (интро) показывается до диагностики. Кнопка «Начать» запускает
  // существующий поток: выбор цели → вопросы → результат → completePlacement.
  bool _started = false;
  String _lang = 'RU';

  LearningGoal? _goal;
  int _step = 0;
  final List<int> _answers = [];
  bool _saving = false;

  static const _questionCount = 5;

  List<_PlacementQuestion> _localizedQuestions(AppState state) => [
        _PlacementQuestion(
          state.tr(
            ru: 'Насколько хорошо ты узнаешь арабские буквы?',
            kk: 'Араб әріптерін қаншалықты жақсы танисың?',
            en: 'How well do you recognize Arabic letters?',
          ),
          [
            state.tr(
                ru: 'Пока не узнаю', kk: 'Әзірге танымаймын', en: 'Not yet'),
            state.tr(
                ru: 'Знаю некоторые',
                kk: 'Кейбірін білемін',
                en: 'I know some'),
            state.tr(
                ru: 'Узнаю почти все',
                kk: 'Барлығын дерлік танимын',
                en: 'I recognize almost all'),
          ],
        ),
        _PlacementQuestion(
          state.tr(
            ru: 'Как ты читаешь арабский текст?',
            kk: 'Араб мәтінін қалай оқисың?',
            en: 'How do you read Arabic text?',
          ),
          [
            state.tr(
                ru: 'Пока не читаю', kk: 'Әзірге оқымаймын', en: 'Not yet'),
            state.tr(
                ru: 'По слогам и медленно',
                kk: 'Буындап, баяу',
                en: 'Syllable by syllable, slowly'),
            state.tr(
                ru: 'Читаю самостоятельно',
                kk: 'Өз бетімше оқимын',
                en: 'I read on my own'),
          ],
        ),
        _PlacementQuestion(
          state.tr(
            ru: 'Насколько уверенно ты знаешь Аль-Фатиху?',
            kk: 'Әл-Фатиханы қаншалықты сенімді білесің?',
            en: 'How confidently do you know Al-Fatiha?',
          ),
          [
            state.tr(
                ru: 'Еще не учил',
                kk: 'Әлі жаттаған жоқпын',
                en: "Haven't learned it yet"),
            state.tr(
                ru: 'Знаю частично',
                kk: 'Ішінара білемін',
                en: 'I know it partially'),
            state.tr(
                ru: 'Знаю полностью',
                kk: 'Толық білемін',
                en: 'I know it fully'),
          ],
        ),
        _PlacementQuestion(
          state.tr(
            ru: 'Понимаешь ли ты смысл знакомых аятов?',
            kk: 'Таныс аяттардың мағынасын түсінесің бе?',
            en: 'Do you understand the meaning of familiar verses?',
          ),
          [
            state.tr(ru: 'Пока нет', kk: 'Әзірге жоқ', en: 'Not yet'),
            state.tr(
                ru: 'Некоторые слова', kk: 'Кейбір сөздерді', en: 'Some words'),
            state.tr(
                ru: 'Понимаю общий смысл',
                kk: 'Жалпы мағынасын түсінемін',
                en: 'I understand the general meaning'),
          ],
        ),
        _PlacementQuestion(
          state.tr(
            ru: 'Как ты оцениваешь свое произношение?',
            kk: 'Айтылымыңды қалай бағалайсың?',
            en: 'How would you rate your pronunciation?',
          ),
          [
            state.tr(
                ru: 'Нужна помощь с основами',
                kk: 'Негіздерге көмек керек',
                en: 'I need help with the basics'),
            state.tr(
                ru: 'Есть отдельные ошибки',
                kk: 'Жекелеген қателер бар',
                en: 'I have some mistakes'),
            state.tr(
                ru: 'Хочу улучшать таджвид',
                kk: 'Тәжуидті жетілдіргім келеді',
                en: 'I want to improve my tajwid'),
          ],
        ),
      ];

  bool get _choosingGoal => _step == 0;
  bool get _showingResult => _step > _questionCount;
  int get _questionIndex => _step - 1;
  int get _score => _answers.fold(0, (sum, value) => sum + value);
  int get _level => (_score / 3).floor().clamp(0, 7) + 1;

  String get _recommendation {
    final state = context.read<AppState>();
    final goal = _goal;
    if (goal == LearningGoal.arabicReading || _score <= 2) {
      return state.tr(
        ru: 'Начни с арабских букв и их звучания. Первый урок поможет увидеть различия и сразу потренировать слух.',
        kk: 'Араб әріптері мен олардың дыбысталуынан баста. Бірінші сабақ айырмашылықтарды көруге және есту қабілетін бірден жаттықтыруға көмектеседі.',
        en: 'Start with the Arabic letters and their sounds. The first lesson helps you see the differences and train your ear right away.',
      );
    }
    if (goal == LearningGoal.islamBasics) {
      return state.tr(
        ru: 'Начни с короткого вводного урока об исламе и Коране. После него маршрут добавит вопросы на понимание.',
        kk: 'Ислам мен Құран туралы қысқа кіріспе сабақтан баста. Одан кейін маршрут түсінуге арналған сұрақтар қосады.',
        en: 'Start with a short introductory lesson about Islam and the Quran. After it, the path will add comprehension questions.',
      );
    }
    if (goal == LearningGoal.pronunciation || _answers.last == 0) {
      return state.tr(
        ru: 'Сначала укрепим произношение знакомых фраз: образец, повторение и разбор вероятных ошибок.',
        kk: 'Алдымен таныс сөз тіркестерінің айтылуын бекітеміз: үлгі, қайталау және ықтимал қателерді талдау.',
        en: "First we'll strengthen the pronunciation of familiar phrases: a model, repetition and a review of likely mistakes.",
      );
    }
    if (goal == LearningGoal.quranMeaning) {
      return state.tr(
        ru: 'Начни с Аль-Фатихи: разберем смысл по частям и свяжем перевод с арабскими словами.',
        kk: 'Әл-Фатихадан баста: мағынасын бөліктеп талдап, аударманы араб сөздерімен байланыстырамыз.',
        en: "Start with Al-Fatiha: we'll break down the meaning part by part and link the translation to the Arabic words.",
      );
    }
    return state.tr(
      ru: 'Тебе подходит маршрут по коротким сурам. Начнем с Аль-Фатихи и будем добавлять новые аяты постепенно.',
      kk: 'Саған қысқа сүрелер бойынша маршрут сәйкес келеді. Әл-Фатихадан бастап, жаңа аяттарды біртіндеп қосамыз.',
      en: "A path through short surahs suits you. We'll start with Al-Fatiha and add new verses gradually.",
    );
  }

  void _selectAnswer(int answer) {
    _answers.add(answer);
    setState(() => _step++);
  }

  Future<void> _finish() async {
    if (_goal == null) return;
    setState(() => _saving = true);
    await context.read<AppState>().completePlacement(
          goal: _goal!,
          level: _level,
          recommendation: _recommendation,
        );
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: PremiumBackground(
        child: SafeArea(
          child: _started ? _buildFlow(state) : _buildIntro(state),
        ),
      ),
    );
  }

  // ── 1a Онбординг/интро ────────────────────────────────────────────────────
  Widget _buildIntro(AppState state) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 16, 4),
          child: Row(
            children: [
              const _Wordmark(),
              const Spacer(),
              LanguagePills(
                selected: _lang,
                onChanged: (lang) => setState(() => _lang = lang),
              ),
            ],
          ),
        ),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _MascotGlow(),
                    const SizedBox(height: 10),
                    Text(
                      state.tr(
                        ru: 'Твой путь к Корану',
                        kk: 'Құранға апарар жолың',
                        en: 'Your path to the Quran',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 30,
                        height: 1.12,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      state.tr(
                        ru: 'Личный AI-наставник: определит уровень, поведёт шаг '
                            'за шагом и услышит твоё произношение.',
                        kk: 'Жеке AI-ұстаз: деңгейіңді анықтайды, қадам-қадам '
                            'жетелейді және айтылымыңды тыңдайды.',
                        en: 'A personal AI mentor: it determines your level, guides '
                            'you step by step and listens to your pronunciation.',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14.5,
                        height: 1.55,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 40),
          child: Column(
            children: [
              PremiumButton(
                label: state.tr(
                  ru: 'Начать — 2 минуты',
                  kk: 'Бастау — 2 минут',
                  en: 'Start — 2 minutes',
                ),
                onPressed: () => setState(() => _started = true),
              ),
              const SizedBox(height: 6),
              TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, '/login'),
                style: TextButton.styleFrom(
                  foregroundColor: AppColors.navy,
                  minimumSize: const Size(0, 44),
                ),
                child: Text(
                  state.tr(
                    ru: 'У меня уже есть аккаунт',
                    kk: 'Менде аккаунт бар',
                    en: 'I already have an account',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: AppColors.navy,
                  ),
                ),
              ),
              const SizedBox(height: 2),
              Text(
                state.tr(
                  ru: 'Без регистрации · прогресс сохранится на устройстве',
                  kk: 'Тіркелусіз · прогресс құрылғыда сақталады',
                  en: 'No sign-up · progress is saved on your device',
                ),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textLight,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ── Диагностика (цель → вопросы → результат) ──────────────────────────────
  Widget _buildFlow(AppState state) {
    final questions = _localizedQuestions(state);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
          child: Row(
            children: [
              if (_step > 0 && !_showingResult)
                IconButton(
                  onPressed: () => setState(() {
                    _step--;
                    if (_answers.isNotEmpty) _answers.removeLast();
                  }),
                  color: AppColors.navy,
                  icon: const Icon(Icons.arrow_back_rounded),
                )
              else
                IconButton(
                  onPressed: () => setState(() => _started = false),
                  color: AppColors.navy,
                  icon: const Icon(Icons.arrow_back_rounded),
                ),
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: _showingResult ? 1 : _step / (_questionCount + 1),
                    minHeight: 10,
                    color: AppColors.sky,
                    backgroundColor: AppColors.border,
                  ),
                ),
              ),
              const SizedBox(width: 48),
            ],
          ),
        ),
        Expanded(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 240),
            child: _choosingGoal
                ? _GoalStep(
                    key: const ValueKey('goal'),
                    selected: _goal,
                    onSelected: (goal) => setState(() {
                      _goal = goal;
                      _step = 1;
                    }),
                  )
                : _showingResult
                    ? _ResultStep(
                        key: const ValueKey('result'),
                        level: _level,
                        recommendation: _recommendation,
                        saving: _saving,
                        onContinue: _finish,
                      )
                    : _QuestionStep(
                        key: ValueKey(_questionIndex),
                        number: _questionIndex + 1,
                        total: _questionCount,
                        question: questions[_questionIndex],
                        onSelected: _selectAnswer,
                      ),
          ),
        ),
      ],
    );
  }
}

/// Вордмарк «muslingo.» — navy w900, точка sky.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: AppColors.navyDark,
        ),
        children: [
          TextSpan(text: 'muslingo'),
          TextSpan(text: '.', style: TextStyle(color: AppColors.sky)),
        ],
      ),
    );
  }
}

/// Exact intro composition from the premium reference: two concentric sky
/// rings, a soft radial glow and the greeting mascot at 212pt.
class _MascotGlow extends StatefulWidget {
  const _MascotGlow();

  @override
  State<_MascotGlow> createState() => _MascotGlowState();
}

class _MascotGlowState extends State<_MascotGlow>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ringController;

  @override
  void initState() {
    super.initState();
    _ringController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _ringController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final int cache = (212 * MediaQuery.of(context).devicePixelRatio).round();
    return SizedBox.square(
      dimension: 236,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 192,
            height: 192,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.skyLight.withValues(alpha: 0.9),
                  AppColors.skyLight.withValues(alpha: 0),
                ],
                stops: const [0, 0.7],
              ),
            ),
          ),
          _PingRing(animation: _ringController, phase: 0),
          _PingRing(animation: _ringController, phase: 0.65),
          Image.asset(
            'assets/images/cat_greet_real.png',
            key: const ValueKey('premium-intro-mascot'),
            width: 212,
            height: 212,
            fit: BoxFit.contain,
            cacheWidth: cache,
            cacheHeight: cache,
          ),
        ],
      ),
    );
  }
}

class _PingRing extends StatelessWidget {
  final Animation<double> animation;
  final double phase;

  const _PingRing({required this.animation, required this.phase});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final progress = (animation.value + phase) % 1;
        final scale = 0.9 + 1.3 * Curves.easeOut.transform(progress);
        return Opacity(
          opacity: 0.55 * (1 - progress),
          child: Transform.scale(scale: scale, child: child),
        );
      },
      child: Container(
        width: 192,
        height: 192,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.sky, width: 1.5),
        ),
      ),
    );
  }
}

class _GoalStep extends StatelessWidget {
  final LearningGoal? selected;
  final ValueChanged<LearningGoal> onSelected;

  const _GoalStep({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    const icons = [
      Icons.translate_rounded,
      Icons.menu_book_rounded,
      Icons.record_voice_over_rounded,
      Icons.lightbulb_rounded,
      Icons.account_balance_rounded,
    ];
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
      children: [
        const CatCharacter(mood: CatMood.greet, size: 120),
        const SizedBox(height: 8),
        Text(
          state.tr(
            ru: 'Чему ты хочешь научиться?',
            kk: 'Нені үйренгің келеді?',
            en: 'What do you want to learn?',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          state.tr(
            ru: 'Сначала определим цель, затем соберем твой маршрут.',
            kk: 'Алдымен мақсатты анықтаймыз, содан кейін маршрутыңды құрамыз.',
            en: "First we'll define the goal, then build your path.",
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            color: AppColors.textGrey,
          ),
        ),
        const SizedBox(height: 20),
        ...LearningGoal.values.asMap().entries.map((entry) {
          final goal = entry.value;
          return _ChoiceTile(
            icon: icons[entry.key],
            label: goal.title,
            selected: selected == goal,
            onTap: () => onSelected(goal),
          );
        }),
      ],
    );
  }
}

class _QuestionStep extends StatelessWidget {
  final int number;
  final int total;
  final _PlacementQuestion question;
  final ValueChanged<int> onSelected;

  const _QuestionStep({
    super.key,
    required this.number,
    required this.total,
    required this.question,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      children: [
        Text(
          state.tr(
            ru: 'ДИАГНОСТИКА $number ИЗ $total',
            kk: 'ДИАГНОСТИКА $number / $total',
            en: 'DIAGNOSTIC $number OF $total',
          ),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w900,
            letterSpacing: 1.2,
            color: AppColors.navy,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          question.title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 25,
            height: 1.2,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 26),
        ...question.options.asMap().entries.map(
              (entry) => _ChoiceTile(
                icon: [
                  Icons.explore_rounded,
                  Icons.trending_up_rounded,
                  Icons.workspace_premium_rounded,
                ][entry.key],
                label: entry.value,
                selected: false,
                onTap: () => onSelected(entry.key),
              ),
            ),
      ],
    );
  }
}

class _ResultStep extends StatelessWidget {
  final int level;
  final String recommendation;
  final bool saving;
  final VoidCallback onContinue;

  const _ResultStep({
    super.key,
    required this.level,
    required this.recommendation,
    required this.saving,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const CatCharacter(mood: CatMood.praise, size: 150),
        const SizedBox(height: 8),
        Text(
          state.tr(
            ru: 'Твой стартовый уровень: $level',
            kk: 'Сенің бастапқы деңгейің: $level',
            en: 'Your starting level: $level',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: AppColors.skyLight,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.sky),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.auto_awesome_rounded, color: AppColors.navy),
                  const SizedBox(width: 8),
                  Text(
                    state.tr(
                      ru: 'Рекомендация Muslingo',
                      kk: 'Muslingo ұсынысы',
                      en: 'Muslingo recommendation',
                    ),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                recommendation,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  height: 1.45,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 22),
        PremiumButton(
          label: state.tr(
            ru: 'Начать первый урок',
            kk: 'Бірінші сабақты бастау',
            en: 'Start the first lesson',
          ),
          onPressed: saving ? null : onContinue,
        ),
        const SizedBox(height: 10),
        Text(
          state.tr(
            ru: 'Прогресс сохранится на этом устройстве. Аккаунт можно создать после первого урока.',
            kk: 'Прогресс осы құрылғыда сақталады. Аккаунтты бірінші сабақтан кейін жасауға болады.',
            en: 'Progress is saved on this device. You can create an account after the first lesson.',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            color: AppColors.textGrey,
          ),
        ),
      ],
    );
  }
}

class _ChoiceTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _ChoiceTile({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: selected ? AppColors.skyLight : AppColors.white,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: selected ? AppColors.sky : AppColors.border,
                width: selected ? 2 : 1.5,
              ),
            ),
            child: Row(
              children: [
                Icon(icon, color: AppColors.navy),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    label,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
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

class _PlacementQuestion {
  final String title;
  final List<String> options;

  const _PlacementQuestion(this.title, this.options);
}
