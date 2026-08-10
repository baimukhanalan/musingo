import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Soft white premium card: radius 22, low-contrast navy-tinted shadow.
class PremiumCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets? padding;
  final Color? color;
  final double radius;
  final List<BoxShadow>? shadow;

  const PremiumCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.radius = 22,
    this.shadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? AppColors.white,
        borderRadius: BorderRadius.circular(radius),
        boxShadow: shadow ??
            [
              // rgba(18,61,91,.05) blur 26 y12
              BoxShadow(
                color: AppColors.navyDark.withValues(alpha: 0.05),
                blurRadius: 26,
                offset: const Offset(0, 12),
              ),
            ],
      ),
      child: child,
    );
  }
}
