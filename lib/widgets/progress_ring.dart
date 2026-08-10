import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Circular progress ring drawn with [CustomPaint]: a muted background ring
/// and a foreground arc for [percent] (0..1). Optional [child] sits centered
/// (e.g. a sura number or a "%" label).
class ProgressRing extends StatelessWidget {
  final double percent;
  final double size;
  final Widget? child;
  final Color? color;

  const ProgressRing({
    super.key,
    required this.percent,
    this.size = 44,
    this.child,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final double clamped = percent.clamp(0.0, 1.0);
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RingPainter(
          percent: clamped,
          color: color ?? AppColors.sky,
          strokeWidth: size < 40 ? 4 : 5,
        ),
        child: child == null ? null : Center(child: child),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double percent;
  final Color color;
  final double strokeWidth;

  _RingPainter({
    required this.percent,
    required this.color,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (math.min(size.width, size.height) - strokeWidth) / 2;

    final bgPaint = Paint()
      ..color = AppColors.border
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth;
    canvas.drawCircle(center, radius, bgPaint);

    if (percent <= 0) return;

    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = strokeWidth;
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      -math.pi / 2, // start at top
      2 * math.pi * percent,
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(_RingPainter old) =>
      old.percent != percent ||
      old.color != color ||
      old.strokeWidth != strokeWidth;
}
