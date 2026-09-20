import 'package:flutter/material.dart';

const String muslingoMascotName = 'Айн';

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

/// Articulated Blender character with independent eye, ear, head and paw motion.
/// Its position in the surrounding layout stays stable.
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
    with WidgetsBindingObserver {
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final foreground = state == AppLifecycleState.resumed;
    if (_foreground != foreground) {
      setState(() => _foreground = foreground);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    // Tiny repeated chat avatars stay still: their motion is not readable and
    // decoding one animation for every message wastes battery and frame time.
    final animate = widget.size >= 64 &&
        !reducedMotion &&
        _foreground &&
        TickerMode.valuesOf(context).enabled;
    final mood = widget.mood == CatMood.support ? 'thinking' : widget.mood.name;
    final asset = 'assets/images/ayn_$mood${animate ? '' : '_still'}.webp';
    final extent = (widget.size * MediaQuery.devicePixelRatioOf(context))
        .round()
        .clamp(64, 384);
    return Semantics(
      image: true,
      label: _labelForMood(
          widget.mood, Localizations.localeOf(context).languageCode),
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: widget.size,
          child: AnimatedSwitcher(
            duration: reducedMotion
                ? Duration.zero
                : const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: Image.asset(
              asset,
              key: ValueKey(asset),
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              cacheWidth: extent,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    );
  }

  String _labelForMood(CatMood mood, String language) {
    final descriptions = switch (language) {
      'kk' => const [
          'Айн сабырмен күтіп тұр',
          'Айн дұрыс жауаппен құттықтайды',
          'Айн қателіктен кейін қолдайды',
          'Айн амандасады',
          'Айн кеңесті ойластырады',
          'Айн жетістігіңе қуанады',
          'Айн оқып, үйреніп жатыр',
          'Айн дұға жасап тұр',
        ],
      'en' => const [
          'Ayn is waiting patiently',
          'Ayn celebrates your correct answer',
          'Ayn encourages you after a mistake',
          'Ayn says hello',
          'Ayn is thinking of a hint',
          'Ayn celebrates your progress',
          'Ayn is reading and learning',
          'Ayn is praying',
        ],
      _ => const [
          'Айн спокойно ждёт',
          'Айн поздравляет с правильным ответом',
          'Айн поддерживает после ошибки',
          'Айн приветствует',
          'Айн обдумывает подсказку',
          'Айн радуется твоим успехам',
          'Айн читает и учится',
          'Айн молится',
        ],
    };
    return descriptions[mood.index];
  }
}
