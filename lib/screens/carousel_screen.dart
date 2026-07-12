import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/custom_button.dart';

class CarouselScreen extends StatefulWidget {
  const CarouselScreen({super.key});

  @override
  State<CarouselScreen> createState() => _CarouselScreenState();
}

class _CarouselScreenState extends State<CarouselScreen> {
  final _controller = PageController();
  int _current = 0;

  final _pages = const [
    _SlidePage(
      title: 'Учись Корану\nпо 5 минут в день',
      subtitle:
          'Короткие игровые уроки помогут слушать, читать и запоминать аяты.',
      mood: CatMood.learning,
      badge: 'АУДИО И ПОВТОРЕНИЕ',
      icon: Icons.headphones_rounded,
    ),
    _SlidePage(
      title: 'Основы ислама\nшаг за шагом',
      subtitle: 'Столпы ислама, намаз и дуа объясняются простыми карточками.',
      mood: CatMood.prayer,
      badge: 'ПОНЯТНЫЕ КАРТОЧКИ',
      icon: Icons.view_carousel_rounded,
    ),
    _SlidePage(
      title: 'Слушай аяты\nс переводом',
      subtitle: 'Арабский текст, транслитерация и русский смысл всегда рядом.',
      mood: CatMood.idle,
      badge: 'КОРАН С ПЕРЕВОДОМ',
      icon: Icons.graphic_eq_rounded,
    ),
    _SlidePage(
      title: 'Сохраняй страйк\nи получай награды',
      subtitle:
          'Зарабатывай XP, проходи лиги и поддерживай ежедневную привычку.',
      mood: CatMood.praise,
      badge: 'ПРОГРЕСС И ЛИГИ',
      icon: Icons.emoji_events_rounded,
    ),
  ];

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _next() {
    if (_current < _pages.length - 1) {
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
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 12, 12, 4),
              child: Row(
                children: [
                  SizedBox(
                    width: 42,
                    child: _current == 0
                        ? null
                        : IconButton(
                            onPressed: _back,
                            icon: const Icon(Icons.arrow_back_rounded,
                                color: AppColors.textGrey)),
                  ),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: (_current + 1) / _pages.length,
                        minHeight: 12,
                        backgroundColor: AppColors.border,
                        color: AppColors.sky,
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 80,
                    child: TextButton(
                      onPressed: () =>
                          Navigator.pushReplacementNamed(context, '/login'),
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      child: const Text('ПРОПУСТИТЬ',
                          style: TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 10,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textGrey)),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (index) => setState(() => _current = index),
                itemCount: _pages.length,
                itemBuilder: (context, index) => _pages[index],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
              child: CustomButton(
                text: _current == _pages.length - 1
                    ? 'НАЧАТЬ ОБУЧЕНИЕ'
                    : 'ПРОДОЛЖИТЬ',
                onPressed: _next,
              ),
            ),
          ],
        ),
      ),
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
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CatCharacter(mood: mood, size: 230)
              .animate()
              .fadeIn(duration: 350.ms)
              .scale(begin: const Offset(0.9, 0.9), end: const Offset(1, 1)),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
                color: AppColors.skyLight,
                borderRadius: BorderRadius.circular(8)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.navy, size: 18),
                const SizedBox(width: 7),
                Text(badge,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy)),
              ],
            ),
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(18, 17, 18, 18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.border, width: 2),
            ),
            child: Column(
              children: [
                Text(title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 26,
                        height: 1.18,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark)),
                const SizedBox(height: 10),
                Text(subtitle,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        height: 1.4,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey)),
              ],
            ),
          ).animate().fadeIn(delay: 120.ms).moveY(begin: 8, end: 0),
        ],
      ),
    );
  }
}
