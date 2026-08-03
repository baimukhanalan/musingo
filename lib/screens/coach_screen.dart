import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/coach.dart';
import '../models/lesson.dart';
import '../services/app_state.dart';
import '../services/coach_service.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';

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
    setState(() {
      _messages.add(CoachMessage(
        id: 'greeting',
        role: CoachRole.coach,
        text: state.dueReviewCount > 0
            ? 'У тебя ${state.dueReviewCount} назначенных повторений. '
                'Сначала закрепим их, затем вернёмся к новому материалу.'
            : 'Сегодня подходящий следующий шаг — '
                '«${lesson?.title ?? 'короткий урок'}». Я отвечаю по твоему '
                'прогрессу и показываю источники для религиозных материалов.',
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
          _showMessage('Жизни закончились. Восстанови одну на главном экране.');
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
    if (!opened && mounted) _showMessage('Не удалось открыть источник.');
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.background,
        elevation: 0,
        titleSpacing: 16,
        title: const Row(
          children: [
            Text(
              'AI Coach',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(width: 8),
            _GroundedBadge(),
          ],
        ),
      ),
      body: Column(
        children: [
          SizedBox(
            height: 46,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: CoachService.suggestions.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (context, index) => ActionChip(
                avatar: const Icon(Icons.auto_awesome_rounded, size: 16),
                label: Text(CoachService.suggestions[index]),
                onPressed: () => _send(CoachService.suggestions[index]),
                side: const BorderSide(color: AppColors.border),
                backgroundColor: AppColors.white,
                labelStyle: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.navy,
                ),
              ),
            ),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 18),
              itemCount: _messages.length + (_sending ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == _messages.length) return const _TypingIndicator();
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
          _CoachInput(
            controller: _controller,
            enabled: !_sending,
            onSend: () => _send(),
          ),
        ],
      ),
    );
  }
}

class _GroundedBadge extends StatelessWidget {
  const _GroundedBadge();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.success.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.verified_rounded, size: 13, color: AppColors.success),
          SizedBox(width: 4),
          Text(
            'ИСТОЧНИКИ',
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 9,
              fontWeight: FontWeight.w900,
              color: AppColors.success,
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
    final isUser = message.role == CoachRole.user;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment:
            isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isUser) ...[
            const SizedBox(
              width: 38,
              height: 38,
              child: CatCharacter(mood: CatMood.support, size: 38),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: const BoxConstraints(maxWidth: 470),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: isUser ? AppColors.navy : AppColors.white,
                borderRadius: BorderRadius.circular(8),
                border: isUser ? null : Border.all(color: AppColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.text,
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      height: 1.45,
                      fontWeight: FontWeight.w600,
                      color: isUser ? Colors.white : AppColors.textDark,
                    ),
                  ),
                  if (message.sources.isNotEmpty) ...[
                    const SizedBox(height: 11),
                    const Divider(height: 1, color: AppColors.border),
                    const SizedBox(height: 8),
                    for (final source in message.sources)
                      _SourceRow(source: source, onTap: onSource),
                  ],
                  if (onAction != null) ...[
                    const SizedBox(height: 10),
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
                        label: Text(message.actionLabel ?? 'Открыть'),
                        style: FilledButton.styleFrom(
                          backgroundColor: AppColors.sky,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
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
    return const Padding(
      padding: EdgeInsets.only(left: 46, bottom: 14),
      child: Align(
        alignment: Alignment.centerLeft,
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.sky),
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
    return Container(
      padding: const EdgeInsets.fromLTRB(12, 9, 12, 10),
      decoration: const BoxDecoration(
        color: AppColors.white,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: controller,
                enabled: enabled,
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.send,
                onSubmitted: (_) => onSend(),
                decoration: InputDecoration(
                  hintText: 'Спроси об уроке или повторении',
                  filled: true,
                  fillColor: AppColors.backgroundGrey,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Semantics(
              label: 'Отправить сообщение',
              button: true,
              child: Tooltip(
                message: 'Отправить',
                child: ExcludeSemantics(
                  child: IconButton.filled(
                    onPressed: enabled ? () => onSend() : null,
                    icon: const Icon(Icons.send_rounded),
                    style: IconButton.styleFrom(
                      backgroundColor: AppColors.navy,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: AppColors.buttonDisabled,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
