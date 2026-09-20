import 'package:flutter/material.dart';

import '../utils/colors.dart';

/// The original curriculum's approval does not cover newly generated wording.
class TranslationReviewNote extends StatelessWidget {
  final String locale;
  const TranslationReviewNote({super.key, required this.locale});

  @override
  Widget build(BuildContext context) {
    if (locale == 'ru') return const SizedBox.shrink();
    final text = locale == 'kk'
        ? 'Автоматты аударма · редактор тексеруі қажет'
        : 'Automatic translation · editorial review pending';
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: Tooltip(
        message: text,
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: const TextStyle(
              fontSize: 10, height: 1.3, color: AppColors.textGrey),
        ),
      ),
    );
  }
}
