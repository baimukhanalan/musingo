import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/premium_button.dart';

class PremiumScreen extends StatefulWidget {
  const PremiumScreen({super.key});

  @override
  State<PremiumScreen> createState() => _PremiumScreenState();
}

class _PremiumScreenState extends State<PremiumScreen> {
  // Purely visual plan highlight — no real billing happens here.
  // 0 = год (по умолчанию выделен), 1 = месяц.
  int _selectedPlan = 0;

  List<String> _features(AppState state) => [
        state.tr(
            ru: 'Безлимитная проверка произношения',
            kk: 'Айтылымды шексіз тексеру',
            en: 'Unlimited pronunciation checks'),
        state.tr(
            ru: 'Полный Hafiz Mode',
            kk: 'Толық Hafiz Mode',
            en: 'Full Hafiz Mode'),
        state.tr(
            ru: 'Офлайн-аудио и все кари',
            kk: 'Офлайн аудио және барлық қари',
            en: 'Offline audio and all reciters'),
        state.tr(
            ru: 'Подробная статистика и план недели',
            kk: 'Толық статистика және апталық жоспар',
            en: 'Detailed stats and weekly plan'),
      ];

  void _onTrialPressed() {
    // Реальных платежей в приложении пока нет — сохраняем поведение-заглушку.
    final state = context.read<AppState>();
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          behavior: SnackBarBehavior.floating,
          backgroundColor: AppColors.navyDark,
          content: Text(
            state.tr(
                ru: 'Подписка Muslingo+ скоро откроется. Оплата пока не запущена.',
                kk: 'Muslingo+ жазылымы жақында ашылады. Төлем әзірше іске қосылмаған.',
                en: 'Muslingo+ subscription is coming soon. Payments are not live yet.'),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w700,
              color: AppColors.white,
            ),
          ),
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.ivory,
      body: Column(
        children: [
          _buildHero(context, state),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 28),
              children: [
                ..._features(state).map(_buildFeatureRow),
                const SizedBox(height: 22),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: _PlanCard(
                        selected: _selectedPlan == 0,
                        title: state.tr(ru: 'ГОД', kk: 'ЖЫЛ', en: 'YEAR'),
                        price: '19 990 ₸',
                        subtitle:
                            '1 666 ₸/${state.tr(ru: 'мес', kk: 'ай', en: 'mo')}',
                        badge: '−44%',
                        onTap: () => setState(() => _selectedPlan = 0),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: _PlanCard(
                        selected: _selectedPlan == 1,
                        title: state.tr(ru: 'МЕСЯЦ', kk: 'АЙ', en: 'MONTH'),
                        price: '2 990 ₸',
                        subtitle: state.tr(
                            ru: 'в месяц', kk: 'айына', en: 'per month'),
                        onTap: () => setState(() => _selectedPlan = 1),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 22),
                PremiumButton(
                  label: state.tr(
                      ru: 'Попробовать 7 дней бесплатно',
                      kk: '7 күн тегін қолданып көру',
                      en: 'Try 7 days free'),
                  variant: PremiumButtonVariant.gold,
                  onPressed: _onTrialPressed,
                ),
                const SizedBox(height: 14),
                Text(
                  state.tr(
                    ru: 'Отмена в любой момент. Базовые уроки и Коран — '
                        'бесплатно навсегда.',
                    kk: 'Кез келген уақытта бас тартуға болады. Негізгі сабақтар '
                        'мен Құран — әрдайым тегін.',
                    en: 'Cancel anytime. Basic lessons and the Quran are '
                        'free forever.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    height: 1.45,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero(BuildContext context, AppState state) {
    return Container(
      decoration: const BoxDecoration(
        // linear-gradient(120deg, #123D5B, #155B88, #123D5B)
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.navyDark, AppColors.navy, AppColors.navyDark],
        ),
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(28)),
        boxShadow: [
          BoxShadow(
            color: Color(0x33123D5B),
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 8, 16, 26),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: Alignment.centerRight,
                child: Material(
                  color: Colors.white.withValues(alpha: 0.12),
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () => Navigator.of(context).maybePop(),
                    child: Padding(
                      padding: const EdgeInsets.all(8),
                      child: Icon(
                        Icons.close_rounded,
                        color: AppColors.white,
                        size: 22,
                        semanticLabel: state.tr(
                            ru: 'Закрыть', kk: 'Жабу', en: 'Close'),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Muslingo+',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                  color: AppColors.white,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                state.tr(
                    ru: 'Максимум от твоего наставника',
                    kk: 'Ұстазыңнан барынша пайда',
                    en: 'The most from your mentor'),
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15.5,
                  height: 1.4,
                  fontWeight: FontWeight.w600,
                  color: Colors.white.withValues(alpha: 0.82),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 26,
            height: 26,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [Color(0xFFF8CA6B), Color(0xFFEFAE2E)],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withValues(alpha: 0.35),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              size: 17,
              color: AppColors.white,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Tariff card. [selected] is a purely visual highlight — no billing.
class _PlanCard extends StatelessWidget {
  final bool selected;
  final String title;
  final String price;
  final String subtitle;
  final String? badge;
  final VoidCallback onTap;

  const _PlanCard({
    required this.selected,
    required this.title,
    required this.price,
    required this.subtitle,
    required this.onTap,
    this.badge,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      selected: selected,
      label: '$title, $price, $subtitle',
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AppColors.navy : AppColors.border,
                width: selected ? 2 : 1.4,
              ),
              boxShadow: selected
                  ? [
                      BoxShadow(
                        color: AppColors.navy.withValues(alpha: 0.14),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: AppColors.navyDark.withValues(alpha: 0.05),
                        blurRadius: 16,
                        offset: const Offset(0, 8),
                      ),
                    ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: AppColors.textLight,
                      ),
                    ),
                    const Spacer(),
                    if (badge != null)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 3,
                        ),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [Color(0xFFF8CA6B), Color(0xFFEFAE2E)],
                          ),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          badge!,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w900,
                            color: AppColors.white,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  price,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
