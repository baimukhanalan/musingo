import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../utils/app_locale.dart';
import '../utils/colors.dart';

/// Pill toggle for RU / KZ / EN. Self-contained by default: it reads the active
/// UI language from [AppState.locale] (highlighting) and calls
/// [AppState.setLocale] on tap, so switching actually re-localizes subscribed
/// screens.
///
/// [selected] / [onChanged] stay optional for backward compatibility. When
/// [selected] is passed it drives the highlight instead of AppState; when
/// [onChanged] is passed it receives the tapped label instead of calling
/// setLocale. The selected pill is navy with white text.
class LanguagePills extends StatelessWidget {
  /// Optional explicit highlight (pill label "RU"/"KZ"/"EN"). When null the
  /// widget follows `context.watch<AppState>().locale`.
  final String? selected;

  /// Optional tap callback receiving the pill label. When null the widget
  /// drives `context.read<AppState>().setLocale(...)` itself.
  final ValueChanged<String>? onChanged;

  const LanguagePills({
    super.key,
    this.selected,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Follow AppState only when the caller hasn't pinned an explicit selection.
    final String activeLabel =
        selected ?? context.watch<AppState>().locale.label;
    return Container(
      padding: const EdgeInsets.all(3),
      decoration: BoxDecoration(
        // rgba(255,251,244,.72)
        color: AppColors.ivory.withValues(alpha: 0.72),
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.06),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (final locale in AppLocale.values)
            _pill(context, locale, activeLabel),
        ],
      ),
    );
  }

  Widget _pill(BuildContext context, AppLocale locale, String activeLabel) {
    final bool active = locale.label == activeLabel;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () {
        if (onChanged != null) {
          onChanged!(locale.label);
        } else {
          context.read<AppState>().setLocale(locale);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: active ? AppColors.navyDark : Colors.transparent,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          locale.label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 0.5,
            color: active ? AppColors.white : AppColors.textLight,
          ),
        ),
      ),
    );
  }
}
