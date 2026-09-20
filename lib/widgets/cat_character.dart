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

/// Original 2D Ayn artwork, with a quiet crossfade between emotions.
/// The character never bobs, shakes or changes its layout footprint.
class CatCharacter extends StatelessWidget {
  final CatMood mood;
  final double size;

  /// Identifies a new learner event even if it has the same emotional outcome.
  /// Kept for lesson feedback; identical 2D expressions do not need to replay.
  final Object? reactionId;

  const CatCharacter({
    super.key,
    this.mood = CatMood.idle,
    this.size = 180,
    this.reactionId,
  });

  @override
  Widget build(BuildContext context) {
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    final name = mood == CatMood.support ? 'thinking' : mood.name;
    final asset = 'assets/images/cat_${name}_real.webp';
    // Only bound the height so the original portrait artwork keeps its ratio.
    final extent =
        (size * MediaQuery.devicePixelRatioOf(context)).round().clamp(64, 600);
    Widget unavailable() => SizedBox.square(
          dimension: size,
          child: const Icon(Icons.pets_rounded, color: Color(0xFF315B75)),
        );
    Widget fallback() => Image.asset(
          'assets/images/cat_idle_real.webp',
          key: const ValueKey('ayn-2d-fallback'),
          width: size,
          height: size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
          cacheHeight: extent,
          excludeFromSemantics: true,
          errorBuilder: (_, error, stack) => unavailable(),
        );
    return Semantics(
      image: true,
      label: _labelForMood(mood, Localizations.localeOf(context).languageCode),
      child: RepaintBoundary(
        child: SizedBox.square(
          dimension: size,
          child: AnimatedSwitcher(
            duration: reducedMotion || !TickerMode.valuesOf(context).enabled
                ? Duration.zero
                : const Duration(milliseconds: 220),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeOutCubic,
            child: Image.asset(
              asset,
              key: ValueKey(asset),
              width: size,
              height: size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
              cacheHeight: extent,
              gaplessPlayback: true,
              excludeFromSemantics: true,
              errorBuilder: (_, error, stack) =>
                  mood == CatMood.idle ? unavailable() : fallback(),
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
