import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/coach.dart';
import '../models/lesson.dart';
import '../services/app_state.dart';
import '../services/coach_service.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/premium_background.dart';

class CoachScreen extends StatefulWidget {
  const CoachScreen({super.key});

  @override
  State<CoachScreen> createState() => _CoachScreenState();
}

class _CoachScreenState extends State<CoachScreen> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _coach = CoachService();
  final List<CoachMessage> _messages = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _addGreeting());
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
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
    return CoachContext(
      goal: state.learningGoal,
      placementLevel: state.placementLevel,
      recommendation: state.learningRecommendation,
      recommendedLessonId: lesson?.id,
      recommendedLessonTitle: lesson?.title,
      dueReviewCount: state.dueReviewCount,
      weakKnowledge: weak,
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

    await Future<void>.delayed(const Duration(milliseconds: 260));
    if (!mounted) return;
    final response = _coach.answer(
      question,
      _contextFrom(context.read<AppState>()),
    );
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
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
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
              const _CoachHeader(),
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
class _CoachHeader extends StatelessWidget {
  const _CoachHeader();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(18, 10, 18, 10),
      child: Row(
        children: [
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
                          message.actionType == CoachActionType.contactSpecialist
                              ? Icons.support_agent_rounded
                              : message.actionType == CoachActionType.openQuran
                                  ? Icons.menu_book_rounded
                                  : Icons.play_arrow_rounded,
                          size: 19,
                        ),
                        label: Text(message.actionLabel ??
                            state.tr(
                                ru: 'Открыть', kk: 'Ашу', en: 'Open')),
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

class _SourceRow extends StatelessWidget {
  final CoachSource source;
  final ValueChanged<String> onTap;

  const _SourceRow({required this.source, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: source.url == null ? null : () => onTap(source.url!),
      borderRadius: BorderRadius.circular(6),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              source.url == null
                  ? Icons.insights_rounded
                  : Icons.verified_outlined,
              size: 18,
              color: AppColors.success,
            ),
            const SizedBox(width: 7),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    source.title,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navy,
                    ),
                  ),
                  Text(
                    '${source.category} · ${source.verification}',
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 10,
                      height: 1.3,
                      color: AppColors.textGrey,
                    ),
                  ),
                ],
              ),
            ),
            if (source.url != null)
              const Icon(Icons.open_in_new_rounded,
                  size: 15, color: AppColors.textGrey),
          ],
        ),
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  const _TypingIndicator();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
          Container(
            padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
                bottomLeft: Radius.circular(6),
                bottomRight: Radius.circular(20),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyDark.withValues(alpha: 0.06),
                  blurRadius: 20,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                  strokeWidth: 2, color: AppColors.sky),
            ),
          ),
        ],
      ),
    );
  }
}

/// Question-suggestion pills sitting just above the input field.
class _SuggestionChips extends StatelessWidget {
  final bool enabled;
  final ValueChanged<String> onSelect;

  const _SuggestionChips({required this.enabled, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 42,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: CoachService.suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final text = CoachService.suggestions[index];
          return _SuggestionPill(
            text: text,
            onTap: enabled ? () => onSelect(text) : null,
          );
        },
      ),
    );
  }
}

class _SuggestionPill extends StatelessWidget {
  final String text;
  final VoidCallback? onTap;

  const _SuggestionPill({required this.text, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(30),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.white,
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: AppColors.border),
            boxShadow: [
              BoxShadow(
                color: AppColors.navyDark.withValues(alpha: 0.05),
                blurRadius: 8,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.auto_awesome_rounded,
                  size: 15, color: AppColors.sky),
              const SizedBox(width: 6),
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

/// Bottom banner routing a hard religious question to a human specialist.
class _SpecialistBanner extends StatelessWidget {
  final VoidCallback onTap;

  const _SpecialistBanner({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 10),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(16),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.gold.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppColors.gold.withValues(alpha: 0.35),
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.gold.withValues(alpha: 0.2),
                    ),
                    child: const Icon(Icons.support_agent_rounded,
                        size: 19, color: AppColors.warning),
                  ),
                  const SizedBox(width: 11),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          state.tr(
                              ru: 'Сложный религиозный вопрос?',
                              kk: 'Күрделі діни сұрақ па?',
                              en: 'A difficult religious question?'),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navyDark,
                          ),
                        ),
                        const SizedBox(height: 1),
                        Text(
                          state.tr(
                              ru: 'Спросить специалиста',
                              kk: 'Маманнан сұрау',
                              en: 'Ask a specialist'),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textGrey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded,
                      size: 18, color: AppColors.warning),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
