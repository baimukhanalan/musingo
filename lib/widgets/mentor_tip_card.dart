import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/mentor_tip.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import 'cat_character.dart';
import 'premium_card.dart';
import 'section_label.dart';

class MentorTipCard extends StatefulWidget {
  final VoidCallback onTap;
  final DateTime Function()? now;

  const MentorTipCard({super.key, required this.onTap, this.now});

  @override
  State<MentorTipCard> createState() => _MentorTipCardState();
}

class _MentorTipCardState extends State<MentorTipCard>
    with WidgetsBindingObserver {
  Timer? _refreshTimer;
  DateTime get _now => widget.now?.call() ?? DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  void _schedule() {
    _refreshTimer?.cancel();
    final current = _now;
    final interval = MentorTip.cadence.inMilliseconds;
    final next = (current.millisecondsSinceEpoch ~/ interval + 1) * interval;
    _refreshTimer = Timer(
        Duration(milliseconds: next - current.millisecondsSinceEpoch), () {
      if (!mounted) return;
      setState(() {});
      _schedule();
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      setState(() {});
      _schedule();
    }
  }

  @override
  void didUpdateWidget(covariant MentorTipCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.now != widget.now) _schedule();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final tip = state.mentorTipAt(_now);
    final mood = switch (tip.mood) {
      MentorTipMood.welcome => CatMood.greet,
      MentorTipMood.focus => CatMood.learning,
      MentorTipMood.encourage => CatMood.support,
      MentorTipMood.celebrate => CatMood.praise,
    };
    return Padding(
      key: const ValueKey('mentor-tip-card'),
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 6),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(22),
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: BorderRadius.circular(22),
          child: PremiumCard(
            padding: const EdgeInsets.fromLTRB(10, 16, 16, 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CatCharacter(mood: mood, size: 82, reactionId: tip.id),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SectionLabel(
                        text: state.tr(
                            ru: 'Совет Айна',
                            kk: 'Айн кеңесі',
                            en: 'Ayn’s tip')),
                    const SizedBox(height: 7),
                    Text(
                      tip.text,
                      key: const ValueKey('mentor-tip-message'),
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          height: 1.4,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark),
                    ),
                  ],
                )),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
