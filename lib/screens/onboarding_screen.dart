import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/learning_profile.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/custom_button.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  LearningGoal? _goal;
  int _step = 0;
  final List<int> _answers = [];
  bool _saving = false;

  static const _questions = <_PlacementQuestion>[
    _PlacementQuestion(
      'Насколько хорошо ты узнаешь арабские буквы?',
      ['Пока не узнаю', 'Знаю некоторые', 'Узнаю почти все'],
    ),
    _PlacementQuestion(
      'Как ты читаешь арабский текст?',
      ['Пока не читаю', 'По слогам и медленно', 'Читаю самостоятельно'],
    ),
    _PlacementQuestion(
      'Насколько уверенно ты знаешь Аль-Фатиху?',
      ['Еще не учил', 'Знаю частично', 'Знаю полностью'],
    ),
    _PlacementQuestion(
      'Понимаешь ли ты смысл знакомых аятов?',
      ['Пока нет', 'Некоторые слова', 'Понимаю общий смысл'],
    ),
    _PlacementQuestion(
      'Как ты оцениваешь свое произношение?',
      ['Нужна помощь с основами', 'Есть отдельные ошибки', 'Хочу улучшать таджвид'],
    ),
  ];

  bool get _choosingGoal => _step == 0;
  bool get _showingResult => _step > _questions.length;
  int get _questionIndex => _step - 1;
  int get _score => _answers.fold(0, (sum, value) => sum + value);
  int get _level => (_score / 3).floor().clamp(0, 7) + 1;

  String get _recommendation {
    final goal = _goal;
    if (goal == LearningGoal.arabicReading || _score <= 2) {
      return 'Начни с арабских букв и их звучания. Первый урок поможет увидеть различия и сразу потренировать слух.';
    }
    if (goal == LearningGoal.islamBasics) {
      return 'Начни с короткого вводного урока об исламе и Коране. После него маршрут добавит вопросы на понимание.';
    }
    if (goal == LearningGoal.pronunciation || _answers.last == 0) {
      return 'Сначала укрепим произношение знакомых фраз: образец, повторение и разбор вероятных ошибок.';
    }
    if (goal == LearningGoal.quranMeaning) {
      return 'Начни с Аль-Фатихи: разберем смысл по частям и свяжем перевод с арабскими словами.';
    }
    return 'Тебе подходит маршрут по коротким сурам. Начнем с Аль-Фатихи и будем добавлять новые аяты постепенно.';
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
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
                      icon: const Icon(Icons.arrow_back_rounded),
                    )
                  else
                    const SizedBox(width: 48),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: _showingResult
                            ? 1
                            : _step / (_questions.length + 1),
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
                            total: _questions.length,
                            question: _questions[_questionIndex],
                            onSelected: _selectAnswer,
                          ),
              ),
            ),
          ],
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
        const Text(
          'Чему ты хочешь научиться?',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 25,
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Сначала определим цель, затем соберем твой маршрут.',
          textAlign: TextAlign.center,
          style: TextStyle(
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 32),
      children: [
        Text(
          'ДИАГНОСТИКА $number ИЗ $total',
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w900,
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
      children: [
        const CatCharacter(mood: CatMood.praise, size: 150),
        const SizedBox(height: 8),
        Text(
          'Твой стартовый уровень: $level',
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
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.sky),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Icon(Icons.auto_awesome_rounded, color: AppColors.navy),
                  SizedBox(width: 8),
                  Text(
                    'Рекомендация Muslingo',
                    style: TextStyle(
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
        CustomButton(
          text: 'Начать первый урок',
          onPressed: saving ? null : onContinue,
          isLoading: saving,
        ),
        const SizedBox(height: 10),
        const Text(
          'Прогресс сохранится на этом устройстве. Аккаунт можно создать после первого урока.',
          textAlign: TextAlign.center,
          style: TextStyle(
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
        borderRadius: BorderRadius.circular(8),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 15),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
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
