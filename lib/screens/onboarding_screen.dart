import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/learning_profile.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/language_pills.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/semantic_switcher_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  // Экран 1a (интро) показывается до диагностики. Кнопка «Начать» запускает
  // существующий поток: выбор цели → вопросы → результат → completePlacement.
  bool _started = false;

  LearningGoal? _goal;
  int _step = 0;
  final List<int> _answers = [];
  bool _saving = false;

  static const _questionCount = 5;

  List<_PlacementQuestion> _localizedQuestions(AppState state) => [
        _PlacementQuestion(
          state.tr(
              ru: 'Найди арабскую букву ح',
              kk: 'ح араб әрпін тап',
              en: 'Find the Arabic letter ح'),
          const ['ه', 'خ', 'ح'],
          skill: LearningSkill.letters,
          optionScores: const [25, 40, 100],
        ),
        _PlacementQuestion(
          state.tr(
              ru: 'Как читается بَ ?',
              kk: 'بَ қалай оқылады?',
              en: 'How is بَ read?'),
          [
            state.tr(ru: 'би', kk: 'би', en: 'bi'),
            state.tr(ru: 'ба', kk: 'ба', en: 'ba'),
            state.tr(ru: 'бу', kk: 'бу', en: 'bu'),
          ],
          skill: LearningSkill.reading,
          optionScores: const [20, 100, 20],
        ),
        _PlacementQuestion(
          state.tr(
              ru: 'Продолжи: قُلْ هُوَ ٱللَّهُ ...',
              kk: 'Жалғастыр: قُلْ هُوَ ٱللَّهُ ...',
              en: 'Continue: قُلْ هُوَ ٱللَّهُ ...'),
          const ['ٱلْفَلَقِ', 'أَحَدٌ', 'ٱلصَّمَدُ'],
          skill: LearningSkill.surahRecall,
          optionScores: const [0, 100, 45],
        ),
        _PlacementQuestion(
          state.tr(
            ru: 'Что означает «بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ»?',
            kk: '«بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ» нені білдіреді?',
            en: 'What does “بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ” mean?',
          ),
          [
            state.tr(
                ru: 'Хвала Аллаху, Господу миров',
                kk: 'Әлемдердің Раббысы Аллаға мадақ',
                en: 'Praise belongs to Allah, Lord of the worlds'),
            state.tr(
                ru: 'Веди нас прямым путём',
                kk: 'Бізді тура жолға сала гөр',
                en: 'Guide us to the straight path'),
            state.tr(
                ru: 'Во имя Аллаха, Милостивого, Милосердного',
                kk: 'Аса қамқор, ерекше мейірімді Алланың атымен',
                en: 'In the name of Allah, the Most Compassionate, the Most Merciful'),
          ],
          skill: LearningSkill.meaning,
          optionScores: const [25, 15, 100],
        ),
        _PlacementQuestion(
          state.tr(
              ru: 'Что показывает знак шадда ّ ?',
              kk: 'Шадда ّ белгісі нені көрсетеді?',
              en: 'What does the shadda sign ّ indicate?'),
          [
            state.tr(
                ru: 'Остановку в конце слова',
                kk: 'Сөз соңындағы тоқтауды',
                en: 'A stop at the end of a word'),
            state.tr(
                ru: 'Удвоение согласного звука',
                kk: 'Дауыссыз дыбыстың қосарлануын',
                en: 'Doubling a consonant sound'),
            state.tr(
                ru: 'Только долгую гласную',
                kk: 'Тек созылыңқы дауыстыны',
                en: 'Only a long vowel'),
          ],
          skill: LearningSkill.tajwid,
          optionScores: const [15, 100, 35],
        ),
      ];

  bool get _choosingGoal => _step == 0;
  bool get _showingResult => _step > _questionCount;
  int get _questionIndex => _step - 1;
  LearningSkillProfile get _skillProfile {
    final questions = _localizedQuestions(context.read<AppState>());
    return LearningSkillProfile({
      for (var index = 0; index < _answers.length; index++)
        questions[index].skill: questions[index].scoreFor(_answers[index]),
    });
  }

  int get _level => _skillProfile.placementLevel;

  String get _recommendation {
    final state = context.read<AppState>();
    final goal = _goal;
    final profile = _skillProfile;
    final weakest = profile.weakestSkill;
    if ((weakest == LearningSkill.letters &&
            profile.scoreFor(LearningSkill.letters) < 60) ||
        (goal == LearningGoal.arabicReading && profile.overallScore < 45)) {
      return state.tr(
        ru: 'Начни с арабских букв и их звучания. Первый урок поможет увидеть различия и сразу потренировать слух.',
        kk: 'Араб әріптері мен олардың дыбысталуынан баста. Бірінші сабақ айырмашылықтарды көруге және есту қабілетін бірден жаттықтыруға көмектеседі.',
        en: 'Start with the Arabic letters and their sounds. The first lesson helps you see the differences and train your ear right away.',
      );
    }
    if ((weakest == LearningSkill.reading &&
            profile.scoreFor(LearningSkill.reading) < 60) ||
        goal == LearningGoal.arabicReading) {
      if (_level <= 4) {
        return state.tr(
          ru: 'Ты узнаёшь буквы. Начни со сборки слогов и чтения коротких сочетаний, не повторяя весь алфавит с нуля.',
          kk: 'Әріптерді танисың. Әліпбиді қайта бастамай, буындар мен қысқа тіркестерді оқудан баста.',
          en: 'You recognize the letters. Start with syllables and short combinations instead of repeating the whole alphabet.',
        );
      }
      if (_level >= 7) {
        return state.tr(
          ru: 'У тебя уверенная база. Пропускаем алфавит: начнем с коранических слов и чтения аятов.',
          kk: 'Негізің сенімді. Әліпбиді өткізіп, Құран сөздері мен аяттарды оқудан бастаймыз.',
          en: 'You have a strong foundation. We will skip the alphabet and begin with Quranic words and verse reading.',
        );
      }
      return state.tr(
        ru: 'Базовое чтение уже есть. Маршрут начнётся с огласовок, сложных букв и коранических слов.',
        kk: 'Негізгі оқу қалыптасқан. Бағыт харакаттардан, күрделі әріптерден және Құран сөздерінен басталады.',
        en: 'Your basic reading is in place. The path will start with vowel marks, difficult letters, and Quranic words.',
      );
    }
    if (goal == LearningGoal.islamBasics) {
      return state.tr(
        ru: 'Начни с короткого вводного урока об исламе и Коране. После него маршрут добавит вопросы на понимание.',
        kk: 'Ислам мен Құран туралы қысқа кіріспе сабақтан баста. Одан кейін маршрут түсінуге арналған сұрақтар қосады.',
        en: 'Start with a short introductory lesson about Islam and the Quran. After it, the path will add comprehension questions.',
      );
    }
    if (weakest == LearningSkill.tajwid || goal == LearningGoal.pronunciation) {
      return state.tr(
        ru: 'Сначала укрепим произношение знакомых фраз: образец, повторение и разбор вероятных ошибок.',
        kk: 'Алдымен таныс сөз тіркестерінің айтылуын бекітеміз: үлгі, қайталау және ықтимал қателерді талдау.',
        en: "First we'll strengthen the pronunciation of familiar phrases: a model, repetition and a review of likely mistakes.",
      );
    }
    if (weakest == LearningSkill.meaning || goal == LearningGoal.quranMeaning) {
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
    final state = context.read<AppState>();
    await state.completePlacement(
      goal: _goal!,
      level: _level,
      recommendation: _recommendation,
      skillProfile: _skillProfile,
    );
    if (!mounted) return;
    final firstLesson = state.recommendedLesson;
    if (firstLesson != null) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        '/lesson',
        (route) => false,
        arguments: firstLesson,
      );
    } else {
      Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
    }
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
        const Padding(
          padding: EdgeInsets.fromLTRB(20, 12, 16, 4),
          child: Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 12,
            runSpacing: 8,
            children: [
              _Wordmark(),
              LanguagePills(),
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
            layoutBuilder: semanticSwitcherLayout,
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
                        skillProfile: _skillProfile,
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
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context) ||
        !TickerMode.valuesOf(context).enabled) {
      _ringController.stop();
    } else if (!_ringController.isAnimating) {
      _ringController.repeat();
    }
  }

  @override
  Widget build(BuildContext context) {
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
          if (!MediaQuery.disableAnimationsOf(context)) ...[
            _PingRing(animation: _ringController, phase: 0),
            _PingRing(animation: _ringController, phase: 0.65),
          ],
          const CatCharacter(
            key: ValueKey('premium-intro-mascot'),
            mood: CatMood.greet,
            size: 212,
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
            label: goal.titleFor(state.locale),
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
  final LearningSkillProfile skillProfile;
  final String recommendation;
  final bool saving;
  final VoidCallback onContinue;

  const _ResultStep({
    super.key,
    required this.level,
    required this.skillProfile,
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
        _SkillProfileCard(profile: skillProfile),
        const SizedBox(height: 14),
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
                  Expanded(
                    child: Text(
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

class _SkillProfileCard extends StatelessWidget {
  final LearningSkillProfile profile;

  const _SkillProfileCard({required this.profile});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    String label(LearningSkill skill) => switch (skill) {
          LearningSkill.letters =>
            state.tr(ru: 'Буквы', kk: 'Әріптер', en: 'Letters'),
          LearningSkill.reading =>
            state.tr(ru: 'Чтение', kk: 'Оқу', en: 'Reading'),
          LearningSkill.surahRecall =>
            state.tr(ru: 'Суры', kk: 'Сүрелер', en: 'Surahs'),
          LearningSkill.meaning =>
            state.tr(ru: 'Смысл', kk: 'Мағына', en: 'Meaning'),
          LearningSkill.tajwid =>
            state.tr(ru: 'Таджвид', kk: 'Тәжуид', en: 'Tajwid'),
        };

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: [
          for (final skill in LearningSkill.values) ...[
            Row(
              children: [
                SizedBox(
                  width: 76,
                  child: Text(
                    label(skill),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                Expanded(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(5),
                    child: LinearProgressIndicator(
                      minHeight: 8,
                      value: profile.scoreFor(skill) / 100,
                      backgroundColor: AppColors.border,
                      color: skill == profile.weakestSkill
                          ? AppColors.coral
                          : AppColors.sky,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                SizedBox(
                  width: 34,
                  child: Text(
                    '${profile.scoreFor(skill)}%',
                    textAlign: TextAlign.right,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                ),
              ],
            ),
            if (skill != LearningSkill.values.last) const SizedBox(height: 10),
          ],
        ],
      ),
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
  final LearningSkill skill;
  final List<int> optionScores;

  const _PlacementQuestion(
    this.title,
    this.options, {
    required this.skill,
    required this.optionScores,
  });

  int scoreFor(int optionIndex) => optionScores[optionIndex].clamp(0, 100);
}
