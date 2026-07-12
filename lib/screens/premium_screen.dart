import 'package:flutter/material.dart';

import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/custom_button.dart';

class PremiumScreen extends StatelessWidget {
  const PremiumScreen({super.key});

  static const _plannedFeatures = [
    (Icons.favorite_rounded, 'Дополнительные способы восстановить жизни'),
    (Icons.download_for_offline_rounded, 'Офлайн-доступ к выбранным урокам'),
    (Icons.insights_rounded, 'Расширенная статистика обучения'),
    (Icons.auto_awesome_rounded, 'Новые тематические курсы'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        title: const Text(
          'Muslingo+',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontWeight: FontWeight.w900,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        top: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
          children: [
            const CatCharacter(mood: CatMood.praise, size: 200),
            const SizedBox(height: 12),
            const Text(
              'Muslingo+ готовится',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Подписка и оплата пока не запущены. Здесь показаны только возможности, которые находятся в разработке.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                height: 1.45,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 24),
            ..._plannedFeatures.map(
              (feature) => Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: Row(
                  children: [
                    Icon(feature.$1, color: AppColors.navy, size: 25),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Text(
                        feature.$2,
                        style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.skyLight,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'В планах',
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          color: AppColors.navy,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
            CustomButton(
              text: 'Вернуться к обучению',
              icon: Icons.arrow_back_rounded,
              onPressed: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }
}
