import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Compact stat: round icon badge on a light tint, a large [value] number and
/// a small-caps [label] beneath. Designed to sit in a row of stats.
class StatBadge extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color? accent;

  const StatBadge({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    this.accent,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = accent ?? AppColors.sky;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: color.withValues(alpha: 0.14),
          ),
          child: Icon(icon, size: 22, color: color),
        ),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 22,
            fontWeight: FontWeight.w900,
            color: AppColors.navyDark,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10,
            fontWeight: FontWeight.w800,
            color: AppColors.textLight,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }
}
