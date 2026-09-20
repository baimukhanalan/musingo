import 'dart:async';

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

  /// Identifies a new learner event even if it has the same emotional outcome.
  final Object? reactionId;

  const CatCharacter({
    super.key,
    this.mood = CatMood.idle,
    this.size = 180,
    this.reactionId,
  });

  @override
  State<CatCharacter> createState() => _CatCharacterState();
}

class _CatCharacterState extends State<CatCharacter>
    with WidgetsBindingObserver {
  bool _foreground = true;
  Object _performance = Object();
  ImageProvider? _reactionImage;

  bool get _isReaction => const {
        CatMood.greet,
        CatMood.success,
        CatMood.error,
        CatMood.praise,
      }.contains(widget.mood);

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
  void didUpdateWidget(CatCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.mood != widget.mood ||
        oldWidget.reactionId != widget.reactionId) {
      _releaseReaction();
      _performance = Object();
    }
  }

  void _releaseReaction() {
    final image = _reactionImage;
    _reactionImage = null;
    if (image != null) unawaited(image.evict());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _releaseReaction();
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
    // Finite WebP reactions need their own playback stream. Sharing the global
    // AssetImage key would show a previous performance's cached final frame.
    final provider = ResizeImage.resizeIfNeeded(
      extent,
      null,
      animate && _isReaction
          ? _ReactionAssetImage(asset, performance: _performance)
          : AssetImage(asset),
    );
    if (animate && _isReaction && _reactionImage != provider) {
      _releaseReaction();
      _reactionImage = provider;
    }
    Widget unavailablePoster() => SizedBox.square(
          dimension: widget.size,
          child: const Icon(Icons.pets_rounded, color: Color(0xFF315B75)),
        );
    Widget poster() => Image.asset(
          'assets/images/ayn_${mood}_still.webp',
          key: ValueKey('ayn-loading-poster-$mood'),
          width: widget.size,
          height: widget.size,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.medium,
          cacheWidth: extent,
          excludeFromSemantics: true,
          // A missing poster must terminate the fallback chain.
          errorBuilder: (_, error, stack) => unavailablePoster(),
        );
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
            child: Image(
              image: provider,
              key: widget.reactionId == null
                  ? ValueKey(asset)
                  : ValueKey((asset, widget.reactionId)),
              width: widget.size,
              height: widget.size,
              fit: BoxFit.contain,
              filterQuality: FilterQuality.medium,
              gaplessPlayback: true,
              excludeFromSemantics: true,
              frameBuilder: animate
                  ? (context, child, frame, synchronous) => AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOutCubic,
                        switchOutCurve: Curves.easeOutCubic,
                        // Once decoded, RawImage retains its type/key: later
                        // animation frames update directly without crossfades.
                        child: frame == null ? poster() : child,
                      )
                  : null,
              errorBuilder: (_, error, stack) =>
                  animate ? poster() : unavailablePoster(),
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

/// Reuses bundled bytes while isolating the finite decoder for each reaction.
class _ReactionAssetImage extends AssetImage {
  const _ReactionAssetImage(super.assetName, {required this.performance});

  final Object performance;

  @override
  Future<AssetBundleImageKey> obtainKey(ImageConfiguration configuration) {
    return super.obtainKey(configuration).then((key) => _ReactionImageKey(
          bundle: key.bundle,
          name: key.name,
          scale: key.scale,
          performance: performance,
        ));
  }

  @override
  bool operator ==(Object other) =>
      other is _ReactionAssetImage &&
      other.assetName == assetName &&
      other.performance == performance;

  @override
  int get hashCode => Object.hash(assetName, performance);
}

class _ReactionImageKey extends AssetBundleImageKey {
  const _ReactionImageKey({
    required super.bundle,
    required super.name,
    required super.scale,
    required this.performance,
  });

  final Object performance;

  @override
  bool operator ==(Object other) =>
      other is _ReactionImageKey &&
      other.bundle == bundle &&
      other.name == name &&
      other.scale == scale &&
      other.performance == performance;

  @override
  int get hashCode => Object.hash(bundle, name, scale, performance);
}
