import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

enum CatMood {
  idle,
  success,
  error,
  greet,
  support,
  praise,
  learning,
  prayer,
}

class CatCharacter extends StatefulWidget {
  final CatMood mood;
  final double size;

  const CatCharacter({
    super.key,
    this.mood = CatMood.idle,
    this.size = 180,
  });

  @override
  State<CatCharacter> createState() => _CatCharacterState();
}

class _CatCharacterState extends State<CatCharacter>
    with SingleTickerProviderStateMixin {
  late AnimationController _bobController;
  late Animation<double> _bobAnim;

  @override
  void initState() {
    super.initState();
    _bobController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat(reverse: true);
    _bobAnim = Tween<double>(begin: -4, end: 4).animate(
      CurvedAnimation(parent: _bobController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _bobController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final asset = _assetForMood(widget.mood);
    final cat = Semantics(
      image: true,
      label: _labelForMood(widget.mood),
      child: SizedBox.square(
        dimension: widget.size,
        child: ClipRect(
          child: Image.asset(
            asset,
            fit: BoxFit.contain,
            alignment: Alignment.center,
            filterQuality: FilterQuality.high,
            gaplessPlayback: true,
          ),
        ),
      ),
    );

    switch (widget.mood) {
      case CatMood.success:
        return cat
            .animate()
            .moveY(begin: 0, end: -20, duration: 300.ms, curve: Curves.easeOut)
            .then()
            .moveY(
                begin: -20, end: 0, duration: 400.ms, curve: Curves.bounceOut);
      case CatMood.error:
        return cat.animate().shakeX(amount: 6, duration: 500.ms);
      case CatMood.praise:
        return cat
            .animate(onPlay: (c) => c.repeat(period: 1.2.seconds))
            .moveY(begin: 0, end: -16, duration: 400.ms, curve: Curves.easeOut)
            .then()
            .moveY(
                begin: -16, end: 0, duration: 400.ms, curve: Curves.bounceOut);
      case CatMood.greet:
        return cat
            .animate()
            .fadeIn(duration: 400.ms)
            .scale(begin: const Offset(0.85, 0.85), end: const Offset(1, 1));
      default:
        return AnimatedBuilder(
          animation: _bobAnim,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(0, _bobAnim.value),
              child: child,
            );
          },
          child: cat,
        );
    }
  }

  String _assetForMood(CatMood mood) {
    switch (mood) {
      case CatMood.idle:
        return 'assets/images/cat_idle_real.png';
      case CatMood.success:
        return 'assets/images/cat_success_real.png';
      case CatMood.error:
        return 'assets/images/cat_error_real.png';
      case CatMood.greet:
        return 'assets/images/cat_greet_real.png';
      case CatMood.support:
        return 'assets/images/cat_thinking_real.png';
      case CatMood.praise:
        return 'assets/images/cat_praise_real.png';
      case CatMood.learning:
        return 'assets/images/cat_learning_real.png';
      case CatMood.prayer:
        return 'assets/images/cat_prayer_real.png';
    }
  }

  String _labelForMood(CatMood mood) {
    switch (mood) {
      case CatMood.idle:
        return 'Кот Muslingo спокойно ждёт';
      case CatMood.success:
        return 'Кот Muslingo поздравляет с правильным ответом';
      case CatMood.error:
        return 'Кот Muslingo поддерживает после ошибки';
      case CatMood.greet:
        return 'Кот Muslingo приветствует';
      case CatMood.support:
        return 'Кот Muslingo обдумывает подсказку';
      case CatMood.praise:
        return 'Кот Muslingo объясняет новый материал';
      case CatMood.learning:
        return 'Кот Muslingo читает и учится';
      case CatMood.prayer:
        return 'Кот Muslingo молится';
    }
  }
}
