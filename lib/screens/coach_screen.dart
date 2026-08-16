import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/coach.dart';
import '../models/lesson.dart';
import '../services/app_state.dart';
import '../services/backend_service.dart';
import '../services/coach_service.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/premium_background.dart';

part 'coach/coach_messages.dart';
part 'coach/coach_sources.dart';
part 'coach/coach_input.dart';

class CoachScreen extends StatefulWidget {
  final bool showBackButton;

  const CoachScreen({super.key, this.showBackButton = false});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _coach = CoachService();
  final List<CoachMessage> _messages = [];
  bool _sending = false;
  // Свой экземпляр backend создаём лениво: он читает JWT из SharedPreferences,
  // поэтому одинаково работает и для залогиненного (Bearer), и для анонима.
  BackendService? _backend;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _addGreeting());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    _backend?.dispose();
    super.dispose();
  }

  void _addGreeting() {
    if (!mounted || _messages.isNotEmpty) return;
    final state = context.read<AppState>();
    final lesson = state.recommendedLesson;
    final lessonTitle = lesson?.title ??
        state.tr(ru: 'короткий урок', kk: 'қысқа сабақ', en: 'a short lesson');
    setState(() {
      _messages.add(CoachMessage(
        id: 'greeting',
        role: CoachRole.coach,
        text: state.dueReviewCount > 0
            ? state.tr(
                ru: 'У тебя ${state.dueReviewCount} назначенных повторений. '
                    'Сначала закрепим их, затем вернёмся к новому материалу.',
                kk: 'Сенде ${state.dueReviewCount} тағайындалған қайталау бар. '
                    'Алдымен соларды бекітейік, содан кейін жаңа материалға ораламыз.',
                en: 'You have ${state.dueReviewCount} scheduled reviews. '
                    'Let\'s reinforce them first, then return to new material.')
            : state.tr(
                ru: 'Сегодня подходящий следующий шаг — '
                    '«$lessonTitle». Я отвечаю по твоему '
                    'прогрессу и показываю источники для религиозных материалов.',
                kk: 'Бүгінгі қолайлы келесі қадам — '
                    '«$lessonTitle». Мен сенің прогресіңе қарай жауап беремін '
                    'және діни материалдар үшін дереккөздерді көрсетемін.',
                en: 'A good next step today is '
                    '“$lessonTitle”. I answer based on your progress '
                    'and show sources for religious materials.'),
        createdAt: DateTime.now(),
      ));
    });
  }

  CoachContext _contextFrom(AppState state) {
    final weak = state.knowledgeStates.where((item) => item.isWeak).toList()
      ..sort((a, b) => a.strength.compareTo(b.strength));
    final lesson = state.recommendedLesson;
    final quran = state.getCourse(CourseType.quran);
    final arabic = state.getCourse(CourseType.arabic);
    final basics = state.getCourse(CourseType.rules);
    final allLessons =
        state.courses.expand((course) => course.lessons).toList();
    final completedTitles = allLessons
        .where((lesson) => lesson.status == LessonStatus.completed)
        .map((lesson) => lesson.title)
        .take(12)
        .toList(growable: false);
    final memoryAccuracy = state.knowledgeStates.isEmpty
        ? 0.0
        : state.knowledgeStates
                .map((item) => item.strength)
                .reduce((a, b) => a + b) /
            state.knowledgeStates.length;
    return CoachContext(
      goal: state.learningGoal,
      placementLevel: state.placementLevel,
      recommendation: state.learningRecommendation,
      recommendedLessonId: lesson?.id,
      recommendedLessonTitle: lesson?.title,
      dueReviewCount: state.dueReviewCount,
      weakKnowledge: weak,
      xp: state.user?.xp ?? 0,
      streak: state.user?.streak ?? 0,
      totalLessons: state.user?.totalLessons ?? 0,
      totalCatalogLessons: allLessons.length,
      todayProgress: state.todayProgress,
      dailyGoal: state.dailyGoal,
      memorizedVerseCount: state.memorizedVerseCount,
      hafizDueCount: state.hafizDueCount,
      quranCompleted: quran?.completedLessons ?? 0,
      arabicCompleted: arabic?.completedLessons ?? 0,
      basicsCompleted: basics?.completedLessons ?? 0,
      memoryAccuracy: memoryAccuracy,
      completedLessonTitles: completedTitles,
    );
  }

  Future<void> _send([String? preset]) async {
    final question = (preset ?? _controller.text).trim();
    if (question.isEmpty || _sending) return;
    FocusScope.of(context).unfocus();
    _controller.clear();
    setState(() {
      _sending = true;
      _messages.add(CoachMessage(
        id: 'user_${DateTime.now().microsecondsSinceEpoch}',
        role: CoachRole.user,
        text: question,
        createdAt: DateTime.now(),
      ));
    });
    _scrollToBottom();

    final state = context.read<AppState>();
    final coachContext = _contextFrom(state);
    // Индикатор «печатает…» держится, пока ждём ответ (сеть или локальный
    // движок). Backend передаём только если он сконфигурирован — иначе
    // answerSmart сразу вернёт локальный ответ.
    BackendService? backend;
    if (kIsWeb || BackendService.hasConfiguredApiUrl) {
      backend = await _ensureBackend();
      if (!mounted) return;
    }

    final response = await _coach.answerSmart(
      question,
      coachContext,
      backend: backend,
      locale: state.locale.code,
      catalog: _catalogFrom(state),
      xp: state.user?.xp ?? 0,
      streak: state.user?.streak ?? 0,
      completedLessonIds: _completedLessonIds(state),
    );
    if (!mounted) return;
    setState(() {
      _sending = false;
      _messages.add(CoachMessage(
        id: 'coach_${DateTime.now().microsecondsSinceEpoch}',
        role: CoachRole.coach,
        text: response.text,
        createdAt: DateTime.now(),
        sources: response.sources,
        actionType: response.actionType,
        actionLabel: response.actionLabel,
        lessonId: response.lessonId,
      ));
    });
    _scrollToBottom();
  }

  Future<BackendService> _ensureBackend() async =>
      _backend ??= await BackendService.create();

  /// Каталог уроков для серверного коуча: id, заголовок, тип курса, порядок и
  /// пройден ли урок. Позволяет модели ссылаться на реальные lessonId.
  List<Map<String, dynamic>> _catalogFrom(AppState state) {
    final catalog = <Map<String, dynamic>>[];
    for (final course in state.courses) {
      for (final lesson in course.lessons) {
        catalog.add({
          'id': lesson.id,
          'title': lesson.title,
          'subtitle': lesson.subtitle,
          'course': course.type.name,
          'order': lesson.order,
          'completed': lesson.status == LessonStatus.completed,
        });
      }
    }
    return catalog;
  }

  List<String> _completedLessonIds(AppState state) {
    final ids = <String>[];
    for (final course in state.courses) {
      for (final lesson in course.lessons) {
        if (lesson.status == LessonStatus.completed) ids.add(lesson.id);
      }
    }
    return ids;
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_scrollController.hasClients) return;
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOut,
      );
    });
  }

  Future<void> _runAction(CoachMessage message) async {
    switch (message.actionType) {
      case CoachActionType.startLesson:
        final state = context.read<AppState>();
        Lesson? lesson;
        for (final course in state.courses) {
          for (final candidate in course.lessons) {
            if (candidate.id == message.lessonId) lesson = candidate;
          }
        }
        if (lesson == null) return;
        if (!state.isPremium && (state.user?.hearts ?? 0) <= 0) {
          _showMessage(state.tr(
              ru: 'Жизни закончились. Восстанови одну на главном экране.',
              kk: 'Жандар бітті. Басты экраннан біреуін қалпына келтір.',
              en: 'You are out of lives. Restore one on the home screen.'));
          return;
        }
        if (mounted) Navigator.pushNamed(context, '/lesson', arguments: lesson);
        return;
      case CoachActionType.openQuran:
        CoachSource? source;
        for (final candidate in message.sources) {
          if (candidate.url != null) {
            source = candidate;
            break;
          }
        }
        if (source != null) await _openUrl(source.url!);
        return;
      case CoachActionType.openHafiz:
        if (mounted) Navigator.pushNamed(context, '/hafiz');
        return;
      case CoachActionType.contactSpecialist:
        await _openUrl(CoachService.specialistUrl);
        return;
      case null:
        return;
    }
  }

  Future<void> _openUrl(String rawUrl) async {
    final opened = await launchUrl(
      Uri.parse(rawUrl),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      _showMessage(context.read<AppState>().tr(
          ru: 'Не удалось открыть источник.',
          kk: 'Дереккөзді ашу мүмкін болмады.',
          en: 'Could not open the source.'));
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void _returnHome() {
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: PremiumBackground(
        floatingLetters: false,
        child: SafeArea(
          bottom: false,
          child: Column(
            children: [
              _CoachHeader(
                showBackButton: widget.showBackButton,
                onBack: _returnHome,
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 6, 16, 18),
                  itemCount: _messages.length + (_sending ? 1 : 0),
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      return const _TypingIndicator();
                    }
                    final message = _messages[index];
                    return _MessageView(
                      message: message,
                      onAction: message.actionType == null
                          ? null
                          : () => _runAction(message),
                      onSource: _openUrl,
                    );
                  },
                ),
              ),
              _SuggestionChips(
                enabled: !_sending,
                onSelect: (text) => _send(text),
              ),
              _CoachInput(
                controller: _controller,
                enabled: !_sending,
                onSend: () => _send(),
              ),
              _SpecialistBanner(
                onTap: () => _openUrl(CoachService.specialistUrl),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// 1d header: cat avatar + «Muslingo Coach» wordmark and a grounding subtitle.
