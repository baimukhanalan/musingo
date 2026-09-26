import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/curriculum_module.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import 'continuous_audio_screen.dart';
import 'curriculum_library_screen.dart';

/// Two ways into the same 570-topic catalogue. Switching modes never awards
/// completion: study requires practice, listening is a separate activity.
class AcademyModesScreen extends StatefulWidget {
  final Future<List<CurriculumModule>>? modulesFuture;

  const AcademyModesScreen({super.key, @visibleForTesting this.modulesFuture});

  @override
  State<AcademyModesScreen> createState() => _AcademyModesScreenState();
}

class _AcademyModesScreenState extends State<AcademyModesScreen> {
  int _mode = 0;

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(6, 6, 18, 6),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => Navigator.maybePop(context),
                      tooltip: state.tr(
                          ru: 'Назад', kk: 'Артқа', en: 'Back', ar: 'رجوع'),
                      icon: const Icon(Icons.arrow_back_rounded,
                          color: AppColors.navyDark),
                    ),
                    Expanded(
                      child: Text(
                        state.tr(
                            ru: 'Академия',
                            kk: 'Академия',
                            en: 'Academy',
                            ar: 'الأكاديمية'),
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navyDark),
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(18, 2, 18, 10),
                child: Row(
                  children: [
                    _modeButton(
                      index: 0,
                      icon: Icons.school_rounded,
                      label: state.tr(
                          ru: 'Учиться', kk: 'Оқу', en: 'Learn', ar: 'تعلّم'),
                    ),
                    const SizedBox(width: 10),
                    _modeButton(
                      index: 1,
                      icon: Icons.headphones_rounded,
                      label: state.tr(
                          ru: 'Слушать',
                          kk: 'Тыңдау',
                          en: 'Listen',
                          ar: 'استمع'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: _mode == 0
                    ? CurriculumLibraryScreen(
                        key: const ValueKey('academy-learn-mode'),
                        // Forward the test-only catalogue fixture unchanged.
                        // ignore: invalid_use_of_visible_for_testing_member
                        modulesFuture: widget.modulesFuture,
                        embedded: true)
                    : ContinuousAudioScreen(
                        key: const ValueKey('academy-listen-mode'),
                        // ignore: invalid_use_of_visible_for_testing_member
                        modulesFuture: widget.modulesFuture,
                        embedded: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _modeButton({
    required int index,
    required IconData icon,
    required String label,
  }) {
    final selected = _mode == index;
    return Expanded(
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        curve: Curves.easeOutCubic,
        decoration: BoxDecoration(
          color: selected
              ? AppColors.navyDark
              : Colors.white.withValues(alpha: 0.76),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
              color: selected ? AppColors.navyDark : AppColors.skyLight),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            key: ValueKey('academy-mode-$index'),
            borderRadius: BorderRadius.circular(18),
            onTap: () {
              if (_mode != index) setState(() => _mode = index);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(icon,
                      size: 20,
                      color: selected ? Colors.white : AppColors.navyDark),
                  const SizedBox(width: 7),
                  Flexible(
                    child: Text(label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontWeight: FontWeight.w900,
                            color:
                                selected ? Colors.white : AppColors.navyDark)),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
