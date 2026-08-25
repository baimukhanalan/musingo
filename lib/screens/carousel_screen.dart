import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';

class CarouselScreen extends StatefulWidget {
  const CarouselScreen({super.key});

  @override
  State<CarouselScreen> createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  final _controller = PageController();
  int _current = 0;

  static const _pageCount = 4;

  List<_SlidePage> _buildPages(AppState state) => [
        _SlidePage(
          title: state.tr(
            ru: 'Учись Корану\nпо 5 минут в день',
            kk: 'Құранды күніне\n5 минуттан үйрен',
            en: 'Learn the Quran\n5 minutes a day',
          ),
          subtitle: state.tr(
            ru: 'Короткие игровые уроки помогут слушать, читать и запоминать аяты.',
            kk: 'Қысқа ойын сабақтары аяттарды тыңдауға, оқуға және жаттауға көмектеседі.',
            en: 'Short game-like lessons help you listen to, read and memorize verses.',
          ),
          mood: CatMood.learning,
          badge: state.tr(
            ru: 'АУДИО И ПОВТОРЕНИЕ',
            kk: 'АУДИО ЖӘНЕ ҚАЙТАЛАУ',
            en: 'AUDIO & REVIEW',
          ),
          icon: Icons.headphones_rounded,
        ),
        _SlidePage(
          title: state.tr(
            ru: 'Основы ислама\nшаг за шагом',
            kk: 'Ислам негіздері\nқадам-қадам',
            en: 'The basics of Islam\nstep by step',
          ),
          subtitle: state.tr(
            ru: 'Столпы ислама, намаз и дуа объясняются простыми карточками.',
            kk: 'Ислам тіректері, намаз және дұға қарапайым карточкалармен түсіндіріледі.',
            en: 'The pillars of Islam, prayer and dua are explained with simple cards.',
          ),
          mood: CatMood.prayer,
          badge: state.tr(
            ru: 'ПОНЯТНЫЕ КАРТОЧКИ',
            kk: 'ТҮСІНІКТІ КАРТОЧКАЛАР',
            en: 'CLEAR CARDS',
          ),
          icon: Icons.view_carousel_rounded,
        ),
        _SlidePage(
          title: state.tr(
            ru: 'Слушай аяты\nс переводом',
            kk: 'Аяттарды аудармасымен\nтыңда',
            en: 'Listen to verses\nwith translation',
          ),
          subtitle: state.tr(
            ru: 'Арабский текст, транслитерация и русский смысл всегда рядом.',
            kk: 'Араб мәтіні, транслитерация және мағынасы әрдайым қатар.',
            en: 'Arabic text, transliteration and meaning are always at hand.',
          ),
          mood: CatMood.idle,
          badge: state.tr(
            ru: 'КОРАН С ПЕРЕВОДОМ',
            kk: 'ҚҰРАН АУДАРМАСЫМЕН',
            en: 'QURAN WITH TRANSLATION',
          ),
          icon: Icons.graphic_eq_rounded,
        ),
        _SlidePage(
          title: state.tr(
            ru: 'Сохраняй страйк\nи получай награды',
            kk: 'Страйкті сақта\nжәне сыйлықтар ал',
            en: 'Keep your streak\nand earn rewards',
          ),
          subtitle: state.tr(
            ru: 'Зарабатывай XP, проходи лиги и поддерживай ежедневную привычку.',
            kk: 'XP жина, лигалардан өт және күнделікті әдетті сақта.',
            en: 'Earn XP, climb leagues and keep a daily habit.',
          ),
          mood: CatMood.praise,
          badge: state.tr(
            ru: 'ПРОГРЕСС И ЛИГИ',
            kk: 'ПРОГРЕСС ЖӘНЕ ЛИГАЛАР',
            en: 'PROGRESS & LEAGUES',
          ),
          icon: Icons.emoji_events_rounded,
        ),
      ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pageCount - 1) {
      _controller.nextPage(
          duration: const Duration(milliseconds: 320),
          curve: Curves.easeOutCubic);
    } else {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  void _back() {
    if (_current > 0) {
      _controller.previousPage(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final pages = _buildPages(state);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
                child: Row(
                  children: [
                    SizedBox(
                      width: 42,
                      child: _current == 0
                          ? null
                          : _RoundIconButton(
                              icon: Icons.arrow_back_rounded,
                              onPressed: _back,
                            ),
                    ),
                    Expanded(
                      child: _OnboardingProgress(
                        value: (_current + 1) / _pageCount,
                      ),
                    ),
                    SizedBox(
                      width: 108,
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () =>
                              Navigator.pushReplacementNamed(context, '/login'),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: Text(
                              state.tr(
                                ru: 'ПРОПУСТИТЬ',
                                kk: 'ӨТКІЗІП ЖІБЕРУ',
                                en: 'SKIP',
                              ),
                              style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                  color: AppColors.textLight)),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: PageView.builder(
                  controller: _controller,
                  onPageChanged: (index) => setState(() => _current = index),
                  itemCount: pages.length,
                  itemBuilder: (context, index) => pages[index],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 12),
                child: _Dots(count: _pageCount, current: _current),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 4, 24, 26),
                child: PremiumButton(
                  label: _current == _pageCount - 1
                      ? state.tr(
                          ru: 'НАЧАТЬ ОБУЧЕНИЕ',
                          kk: 'ОҚУДЫ БАСТАУ',
                          en: 'START LEARNING',
                        )
                      : state.tr(
                          ru: 'ПРОДОЛЖИТЬ',
                          kk: 'ЖАЛҒАСТЫРУ',
                          en: 'CONTINUE',
                        ),
                  onPressed: _next,
                  icon: _current == _pageCount - 1
                      ? Icons.rocket_launch_rounded
                      : Icons.arrow_forward_rounded,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Soft circular icon button matching the premium card surface.
class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onPressed;

  const _RoundIconButton({required this.icon, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onPressed,
        child: Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.navyDark.withValues(alpha: 0.08),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, color: AppColors.navy, size: 22),
        ),
      ),
    );
  }
}

/// Rounded sky progress track with a soft glow on the filled portion.
class _OnboardingProgress extends StatelessWidget {
  final double value;

  const _OnboardingProgress({required this.value});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final clamped = value.clamp(0.0, 1.0);
        return Container(
          height: 12,
          decoration: BoxDecoration(
            color: AppColors.skyLight,
            borderRadius: BorderRadius.circular(99),
          ),
          child: Align(
            alignment: Alignment.centerLeft,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 320),
              curve: Curves.easeOutCubic,
              width: constraints.maxWidth * clamped,
              height: 12,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF5FC3EE), Color(0xFF3FA9DC)],
                ),
                borderRadius: BorderRadius.circular(99),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.sky.withValues(alpha: 0.4),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Page-position dots: active dot elongates into a sky pill.
class _Dots extends StatelessWidget {
  final int count;
  final int current;

  const _Dots({required this.count, required this.current});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (i) {
        final active = i == current;
        return AnimatedContainer(
          duration: const Duration(milliseconds: 280),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: active ? 26 : 8,
          height: 8,
          decoration: BoxDecoration(
            color: active ? AppColors.sky : AppColors.border,
            borderRadius: BorderRadius.circular(99),
          ),
        );
      }),
    );
  }
}

class _SlidePage extends StatelessWidget {
  final String title;
  final String subtitle;
  final CatMood mood;
  final String badge;
  final IconData icon;

  const _SlidePage({
    required this.title,
    required this.subtitle,
    required this.mood,
    required this.badge,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 26),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 8),
          CatCharacter(mood: mood, size: 220)
              .animate()
              .fadeIn(duration: 350.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          const SizedBox(height: 4),
          // Navy tag-chip: bg navy, radius 10, white 900 label.
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.navy,
              borderRadius: BorderRadius.circular(10),
              boxShadow: [
                BoxShadow(
                  color: AppColors.navyDark.withValues(alpha: 0.18),
                  blurRadius: 12,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.white, size: 16),
                const SizedBox(width: 7),
                Text(badge,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                        color: AppColors.white)),
              ],
            ),
          ).animate().fadeIn(delay: 90.ms).moveY(begin: 6, end: 0),
          const SizedBox(height: 20),
          PremiumCard(
            padding: const EdgeInsets.fromLTRB(22, 22, 22, 24),
            child: Column(
              children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 27,
                        height: 1.16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy)),
                const SizedBox(height: 12),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        height: 1.45,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey)),
              ],
            ),
          ).animate().fadeIn(delay: 140.ms).moveY(begin: 10, end: 0),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}
