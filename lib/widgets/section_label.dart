import 'package:flutter/material.dart';
import '../utils/colors.dart';

/// Small-caps section label: uppercase, wide letter-spacing, muted text.
/// Optional [trailing] sits on the right of the same row.
class SectionLabel extends StatelessWidget {
  final String text;
  final String? trailing;

  const SectionLabel({
    super.key,
    required this.text,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontFamily: 'Nunito',
      fontSize: 11,
      fontWeight: FontWeight.w800,
      color: AppColors.textLight,
      letterSpacing: 1.2,
    );

    final label = Text(text.toUpperCase(), style: style);

    if (trailing == null) return label;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Flexible(child: label),
        const SizedBox(width: 8),
        Text(trailing!.toUpperCase(), style: style),
      ],
    );
  }
}
