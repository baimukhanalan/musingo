import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
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
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreConversation());
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
    final preferredName = state.mentorProfile.preferredName.trim();
    final birthday = state.mentorProfile.isBirthday(DateTime.now());
    final discovery = state.mentorProfile.memoryEnabled &&
            state.mentorProfile.proactiveQuestionsEnabled &&
            state.mentorProfile.motivation.isEmpty
        ? state.tr(
            ru: '\n\nЧтобы мои советы стали точнее: что для тебя самое важное в обучении сейчас? Отвечать необязательно.',
            kk: '\n\nКеңесім дәлірек болуы үшін: қазір оқуда сен үшін ең маңыздысы не? Жауап беру міндетті емес.',
            en: '\n\nTo make my guidance more useful: what matters most to you in learning right now? You do not have to answer.',
          )
        : '';
    setState(() {
      _messages.add(CoachMessage(
        id: 'greeting',
        role: CoachRole.coach,
        text: (birthday
                ? state.tr(
                    ru: '${preferredName.isEmpty ? '' : '$preferredName, '}с днём рождения! 🎉 Я рядом без обязательного плана: можем сделать лёгкое повторение или просто поговорить.',
                    kk: '${preferredName.isEmpty ? '' : '$preferredName, '}туған күніңмен! 🎉 Бүгін міндетті жоспарсыз: жеңіл қайталау жасаймыз немесе жай сөйлесеміз.',
                    en: '${preferredName.isEmpty ? '' : '$preferredName, '}happy birthday! 🎉 No pressure today: we can do a light review or simply talk.')
                : state.dueReviewCount > 0
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
                            'and show sources for religious materials.')) +
            discovery,
        createdAt: DateTime.now(),
      ));
    });
    _persistConversation();
  }

  String _conversationKey(AppState state) =>
      'coach_conversation_v1_${state.user?.id ?? 'guest'}';

  Future<void> _restoreConversation() async {
    if (!mounted) return;
    final state = context.read<AppState>();
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_conversationKey(state));
    if (raw != null && raw.isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is List) {
          final restored = decoded
              .whereType<Map>()
              .map((item) {
                final map = Map<String, dynamic>.from(item);
                return CoachMessage(
                  id: map['id']?.toString() ??
                      'saved_${DateTime.now().microsecondsSinceEpoch}',
                  role:
                      map['role'] == 'user' ? CoachRole.user : CoachRole.coach,
                  text: map['text']?.toString() ?? '',
                  createdAt:
                      DateTime.tryParse(map['createdAt']?.toString() ?? '') ??
                          DateTime.now(),
                );
              })
              .where((item) => item.text.trim().isNotEmpty)
              .take(30)
              .toList();
          if (mounted && restored.isNotEmpty) {
            setState(() => _messages.addAll(restored));
          }
        }
      } catch (_) {
        await prefs.remove(_conversationKey(state));
      }
    }
    _addGreeting();
    _scrollToBottom();
  }

  Future<void> _persistConversation() async {
    if (!mounted) return;
    final state = context.read<AppState>();
    final prefs = await SharedPreferences.getInstance();
    final items = _messages.reversed
        .take(30)
        .toList()
        .reversed
        .map((message) => {
              'id': message.id,
              'role': message.role.name,
              'text': message.text,
              'createdAt': message.createdAt.toIso8601String(),
            })
        .toList();
    await prefs.setString(_conversationKey(state), jsonEncode(items));
  }

  CoachContext _contextFrom(AppState state) {
    final now = DateTime.now();
    final due = state.knowledgeStates.where((item) => item.isDue(now)).toList()
      ..sort((a, b) => a.nextReviewAt.compareTo(b.nextReviewAt));
    final weak = state.knowledgeStates.where((item) => item.isWeak).toList()
      ..sort((a, b) {
        final dueOrder = (b.isDue(now) ? 1 : 0).compareTo(a.isDue(now) ? 1 : 0);
        if (dueOrder != 0) return dueOrder;
        final lapseOrder = b.lapses.compareTo(a.lapses);
        if (lapseOrder != 0) return lapseOrder;
        return a.strength.compareTo(b.strength);
      });
    final lesson = state.recommendedLesson;
    final quran = state.getCourse(CourseType.quran);
    final arabic = state.getCourse(CourseType.arabic);
    final basics = state.getCourse(CourseType.rules);
    final tajwid = state.getCourse(CourseType.tajwid);
    final allLessons =
        state.courses.expand((course) => course.lessons).toList();
    final completedTitles = allLessons
        .where((lesson) => lesson.status == LessonStatus.completed)
        .map((lesson) => lesson.title)
        .take(12)
        .toList(growable: false);
    final knownSurahs = (quran?.lessons ?? const <Lesson>[])
        .where((lesson) => lesson.status == LessonStatus.completed)
        .map((lesson) => lesson.title.replaceFirst('Закрепление: ', ''))
        .toSet()
        .take(50)
        .toList(growable: false);
    final memoryAccuracy = state.knowledgeStates.isEmpty
        ? 0.0
        : state.knowledgeStates
                .map((item) => item.strength)
                .reduce((a, b) => a + b) /
            state.knowledgeStates.length;
    return CoachContext(
      goal: state.learningGoal,
      skillProfile: state.learningSkillProfile,
      placementLevel: state.placementLevel,
      recommendation: state.learningRecommendation,
      recommendedLessonId: lesson?.id,
      recommendedLessonTitle: lesson?.title,
      dueReviewCount: state.dueReviewCount,
      dueKnowledge: due,
      weakKnowledge: weak,
      nextReviewAt: state.nextReviewAt,
      recommendedCourse: lesson?.course.name,
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
      tajwidCompleted: tajwid?.completedLessons ?? 0,
      memoryAccuracy: memoryAccuracy,
      completedLessonTitles: completedTitles,
      knownSurahs: knownSurahs,
      availableMinutes: state.mentorProfile.preferredSessionMinutes,
      hearts: state.user?.hearts ?? 5,
      energy: state.user?.energy ?? 0,
      lessonAttempts: state.user?.lessonAttempts ?? 0,
      speechAttempts: state.user?.speechAttempts ?? 0,
      learnedAyats: state.user?.learnedAyats ?? 0,
      learnedDuas: state.user?.learnedDuas ?? 0,
      lastStudyAt: state.user?.lastStudyDate,
      mentorProfile: state.mentorProfile,
      conversationHistory: _messages.reversed
          .take(10)
          .toList()
          .reversed
          .map((message) => {
                'role': message.role.name,
                'text': message.text,
              })
          .toList(growable: false),
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
    final memory = _explicitMemory(question, state);
    if (memory != null) await state.rememberForCoach(memory);

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
        text: _displayText(response, state),
        createdAt: DateTime.now(),
        sources: response.sources,
        reasoning: response.reasoning,
        dailyPlan: response.dailyPlan,
        nextAction: response.nextAction,
        actionType: response.actionType,
        actionLabel: response.actionLabel,
        lessonId: response.lessonId,
      ));
    });
    await _persistConversation();
    _scrollToBottom();
  }

  String? _explicitMemory(String question, AppState state) {
    if (!state.mentorProfile.memoryEnabled) return null;
    final match = RegExp(
      r'^(?:запомни(?:,|\s+что)?|есіңде сақта(?:,|\s+)?|remember(?:,|\s+that)?)\s+(.+)$',
      caseSensitive: false,
    ).firstMatch(question.trim());
    return match?.group(1)?.trim();
  }

  String _displayText(CoachResponse response, AppState state) {
    final sections = <String>[response.text];
    final reasoning = response.reasoning?.trim();
    if (reasoning?.isNotEmpty == true) {
      sections.add(
          '${state.tr(ru: 'Почему так', kk: 'Неліктен', en: 'Why this')}\n$reasoning');
    }
    if (response.dailyPlan.isNotEmpty) {
      final items = response.dailyPlan.asMap().entries.map((entry) {
        final item = entry.value;
        final detail = item.detail.trim().isEmpty ? '' : ': ${item.detail}';
        return '${entry.key + 1}. ${item.title}$detail';
      }).join('\n');
      sections.add(
          '${state.tr(ru: 'План на сегодня', kk: 'Бүгінгі жоспар', en: 'Today\'s plan')}\n$items');
    }
    final nextAction = response.nextAction?.trim();
    if (nextAction?.isNotEmpty == true) {
      sections.add(
          '${state.tr(ru: 'Следующий шаг', kk: 'Келесі қадам', en: 'Next step')}\n$nextAction');
    }
    return sections.join('\n\n');
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
                      onReport: message.role == CoachRole.coach &&
                              message.id != 'greeting'
                          ? () => _reportAnswer(message)
                          : null,
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

  Future<void> _reportAnswer(CoachMessage message) async {
    final uri = Uri(
      scheme: 'mailto',
      path: 'support@muslingo.app',
      queryParameters: {
        'subject': 'Muslingo Coach: content review request',
        'body':
            'Answer ID: ${message.id}\n\nDescribe the possible inaccuracy:\n',
      },
    );
    await _openUrl(uri.toString());
  }
}

/// 1d header: cat avatar + «Muslingo Coach» wordmark and a grounding subtitle.
