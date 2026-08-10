import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Signature screen background: radial sky→ivory gradient with soft glow
/// blobs and low-opacity floating Arabic letters in the corners.
///
/// Use as the body wrapper of a screen:
/// `PremiumBackground(child: SafeArea(child: ...))`.
class PremiumBackground extends StatelessWidget {
  final Widget child;
  final bool floatingLetters;

  const PremiumBackground({
    super.key,
    required this.child,
    this.floatingLetters = true,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      // radial-gradient(130% 62% at 50% -8%, #DDF4FF 0%, #FFFBF4 62%)
      decoration: const BoxDecoration(
        gradient: RadialGradient(
          center: Alignment(0, -1.16),
          radius: 1.3,
          colors: [AppColors.skyLight, AppColors.ivory],
          stops: [0.0, 0.62],
        ),
      ),
      child: Stack(
        children: [
          // Soft sky glow — top right.
          const Positioned(
            top: -120,
            right: -110,
            child: _GlowBlob(
              size: 320,
              color: Color(0x5262C5EE), // rgba(98,197,238,.32)
            ),
          ),
          // Soft gold glow — bottom left.
          const Positioned(
            bottom: -140,
            left: -120,
            child: _GlowBlob(
              size: 300,
              color: Color(0x42F3B948), // rgba(243,185,72,.26)
            ),
          ),
          if (floatingLetters) ...const [
            Positioned(
              top: 44,
              left: 22,
              child: _FloatingLetter('ق', color: AppColors.sky, size: 34),
            ),
            Positioned(
              top: 120,
              right: 26,
              child: _FloatingLetter('ر', color: AppColors.gold, size: 30),
            ),
            Positioned(
              bottom: 150,
              left: 28,
              child: _FloatingLetter('آ', color: AppColors.gold, size: 32),
            ),
            Positioned(
              bottom: 70,
              right: 30,
              child: _FloatingLetter('ن', color: AppColors.sky, size: 36),
            ),
          ],
          // Foreground content.
          Positioned.fill(child: child),
        ],
      ),
    );
  }
}

class _GlowBlob extends StatelessWidget {
  final double size;
  final Color color;

  const _GlowBlob({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [color, color.withValues(alpha: 0)],
          ),
        ),
      ),
    );
  }
}

class _FloatingLetter extends StatelessWidget {
  final String letter;
  final Color color;
  final double size;

  const _FloatingLetter(this.letter, {required this.color, required this.size});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Text(
        letter,
        style: TextStyle(
          fontFamily: 'Amiri',
          fontSize: size,
          fontWeight: FontWeight.w700,
          color: color.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}
