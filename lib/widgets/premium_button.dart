import 'package:flutter/material.dart';
import '../utils/colors.dart';

enum PremiumButtonVariant { primary, gold, navy }

/// Duolingo-style volumetric button: gradient face, soft colored glow and an
/// emulated darker bottom edge (inset) for a "pressable" 3D look.
///
/// Pass `onPressed: null` to render the disabled state.
class PremiumButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final PremiumButtonVariant variant;
  final IconData? icon;
  final bool expand;

  const PremiumButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = PremiumButtonVariant.primary,
    this.icon,
    this.expand = true,
  });

  @override
  Widget build(BuildContext context) {
    final bool enabled = onPressed != null;

    final content = Row(
      mainAxisSize: expand ? MainAxisSize.max : MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, size: 20, color: AppColors.white),
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            label,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 17,
              fontWeight: FontWeight.w900,
              color: AppColors.white,
            ),
          ),
        ),
      ],
    );

    final _ButtonPalette palette = _paletteFor(variant, enabled);

    Widget button = DecoratedBox(
      // The darker under-layer that peeks below the face → inset bottom edge.
      decoration: BoxDecoration(
        color: palette.edge,
        borderRadius: BorderRadius.circular(14),
        boxShadow: enabled
            ? [
                BoxShadow(
                  color: palette.glow,
                  blurRadius: 26,
                  offset: const Offset(0, 12),
                ),
              ]
            : null,
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              height: 54,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: palette.face,
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: content,
                ),
              ),
            ),
          ),
        ),
      ),
    );

    if (expand) {
      button = SizedBox(width: double.infinity, child: button);
    }
    return button;
  }

  _ButtonPalette _paletteFor(PremiumButtonVariant variant, bool enabled) {
    if (!enabled) {
      return _ButtonPalette(
        face: const [AppColors.buttonDisabled, AppColors.buttonDisabled],
        edge: Color.lerp(AppColors.buttonDisabled, Colors.black, 0.18)!,
        glow: Colors.transparent,
      );
    }
    switch (variant) {
      case PremiumButtonVariant.gold:
        return _ButtonPalette(
          face: const [Color(0xFFF8CA6B), Color(0xFFEFAE2E)],
          edge: Color.lerp(const Color(0xFFEFAE2E), AppColors.navyDark, 0.28)!,
          glow: AppColors.gold.withValues(alpha: 0.4),
        );
      case PremiumButtonVariant.navy:
        return _ButtonPalette(
          face: const [AppColors.navyDark, AppColors.navy],
          edge: Color.lerp(AppColors.navyDark, Colors.black, 0.35)!,
          glow: AppColors.navy.withValues(alpha: 0.4),
        );
      case PremiumButtonVariant.primary:
        return _ButtonPalette(
          face: const [Color(0xFF5FC3EE), Color(0xFF3FA9DC)],
          edge: AppColors.navyDark.withValues(alpha: 0.55),
          glow: AppColors.sky.withValues(alpha: 0.4),
        );
    }
  }
}

class _ButtonPalette {
  final List<Color> face;
  final Color edge;
  final Color glow;

  const _ButtonPalette({
    required this.face,
    required this.edge,
    required this.glow,
  });
}
