import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_card.dart';
import '../widgets/progress_ring.dart';
import '../widgets/section_label.dart';

/// Экран серии (страйк). Только визуальная подача из DESIGN_SPEC —
/// крупная цифра серии с огоньком, прогресс до бонуса, календарь недель
/// кружками, маскот. Все значения (серия, дата последнего занятия) берутся
/// из [AppState]/UserModel; навигация сохранена как была.
class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) return const SizedBox.shrink();

    final streak = user.streak;
    int nextBonus = 7;
    if (streak >= 7) nextBonus = 30;
    if (streak >= 30) nextBonus = 100;

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _TopBar(onBack: () => Navigator.of(context).maybePop()),
                const SizedBox(height: 4),
                _StreakHero(streak: streak),
                const SizedBox(height: 20),
                _BonusProgressCard(streak: streak, nextBonus: nextBonus),
                const SizedBox(height: 24),
                SectionLabel(
                    text: state.tr(
                        ru: 'Бонусы за страйк',
                        kk: 'Страйк бонустары',
                        en: 'Streak bonuses')),
                const SizedBox(height: 12),
                _StreakBonusList(streak: streak),
                const SizedBox(height: 24),
                SectionLabel(
                    text: state.tr(
                        ru: 'Последние 3 недели',
                        kk: 'Соңғы 3 апта',
                        en: 'Last 3 weeks')),
                const SizedBox(height: 12),
                _StreakCalendar(
                    streak: streak, lastStudyDate: user.lastStudyDate),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;
  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Row(
      children: [
        _CircleIconButton(
          icon: Icons.arrow_back_rounded,
          tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
          onTap: onBack,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            state.tr(ru: 'Мой страйк', kk: 'Менің страйкым', en: 'My streak'),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 22,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDark,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  const _CircleIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 0,
      shadowColor: Colors.transparent,
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 22, color: AppColors.navyDark),
          ),
        ),
      ),
    );
  }
}

/// Крупный герой-блок: маскот, огонёк и цифра серии в мягком круге-глоу.
class _StreakHero extends StatelessWidget {
  final int streak;
  const _StreakHero({required this.streak});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bool active = streak > 0;
    return PremiumCard(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      child: Column(
        children: [
          CatCharacter(
            mood: active ? CatMood.praise : CatMood.support,
            size: 132,
          ),
          const SizedBox(height: 12),
          // Огонёк + крупная цифра серии.
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                Icons.local_fire_department_rounded,
                size: 56,
                color: active ? AppColors.coral : AppColors.textLight,
              ),
              const SizedBox(width: 6),
              Text(
                '$streak',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 76,
                  height: 1.0,
                  fontWeight: FontWeight.w900,
                  color: active ? AppColors.coral : AppColors.textGrey,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            state.tr(
              ru: _daysLabel(streak),
              kk: 'күн қатарынан',
              en: streak == 1 ? 'day in a row' : 'days in a row',
            ),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey,
            ),
          ),
          const SizedBox(height: 14),
          Text(
            _motivation(state, streak),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14.5,
              height: 1.35,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  String _daysLabel(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'день подряд';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
      return 'дня подряд';
    }
    return 'дней подряд';
  }

  String _motivation(AppState state, int streak) {
    if (streak == 0) {
      return state.tr(
        ru: 'Начни сегодня — и твой огонёк загорится. Один урок в день творит чудеса.',
        kk: 'Бүгіннен баста — сонда отың жанады. Күніне бір сабақ ғажайып жасайды.',
        en: 'Start today — and your flame will light up. One lesson a day works wonders.',
      );
    }
    if (streak < 7) {
      return state.tr(
        ru: 'Отличное начало! Возвращайся каждый день, чтобы не потерять огонёк.',
        kk: 'Тамаша бастама! Отыңды жоғалтпау үшін күн сайын оралып отыр.',
        en: "Great start! Come back every day so you don't lose your flame.",
      );
    }
    if (streak < 30) {
      return state.tr(
        ru: 'Ты в ритме, маашаллах! Привычка формируется — так держать.',
        kk: 'Сен ырғақтасың, машаллаһ! Дағды қалыптасып келеді — осылай жалғастыр.',
        en: "You're in the rhythm, mashallah! The habit is forming — keep it up.",
      );
    }
    if (streak < 100) {
      return state.tr(
        ru: 'Впечатляющая дисциплина! Ты уже среди самых упорных учеников.',
        kk: 'Керемет тәртіп! Сен ең табанды оқушылардың қатарындасың.',
        en: "Impressive discipline! You're already among the most persistent learners.",
      );
    }
    return state.tr(
      ru: 'Невероятная серия! Твоё постоянство вдохновляет, баракаллаху фик.',
      kk: 'Керемет серия! Табандылығың шабыттандырады, бәракаллаһу фиқ.',
      en: 'Incredible streak! Your consistency is inspiring, barakallahu feek.',
    );
  }
}

/// Карточка прогресса до ближайшего бонуса с кольцом и полосой.
class _BonusProgressCard extends StatelessWidget {
  final int streak;
  final int nextBonus;
  const _BonusProgressCard({required this.streak, required this.nextBonus});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final double progress = (streak / nextBonus).clamp(0.0, 1.0);
    final int left = (nextBonus - streak).clamp(0, nextBonus);

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ProgressRing(
                percent: progress,
                size: 52,
                color: AppColors.gold,
                child: const Icon(
                  Icons.emoji_events_rounded,
                  size: 22,
                  color: AppColors.gold,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      state.tr(
                        ru: 'До бонуса · $nextBonus дней',
                        kk: 'Бонусқа дейін · $nextBonus күн',
                        en: 'To bonus · $nextBonus days',
                      ),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16.5,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      left > 0
                          ? state.tr(
                              ru: 'Осталось $left ${_daysWord(left)}',
                              kk: '$left күн қалды',
                              en: '$left ${left == 1 ? 'day' : 'days'} left')
                          : state.tr(
                              ru: 'Бонус разблокирован!',
                              kk: 'Бонус ашылды!',
                              en: 'Bonus unlocked!'),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '$streak/$nextBonus',
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.gold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.goldLight,
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.gold),
            ),
          ),
        ],
      ),
    );
  }

  String _daysWord(int n) {
    final mod10 = n % 10;
    final mod100 = n % 100;
    if (mod10 == 1 && mod100 != 11) return 'день';
    if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) return 'дня';
    return 'дней';
  }
}

class _StreakBonusList extends StatelessWidget {
  final int streak;
  const _StreakBonusList({required this.streak});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final bonuses = [
      {'days': 7, 'xp': 10, 'icon': Icons.star_rounded},
      {'days': 30, 'xp': 50, 'icon': Icons.fitness_center_rounded},
      {'days': 100, 'xp': 200, 'icon': Icons.diamond_rounded},
    ];

    return Row(
      children: bonuses.map((b) {
        final int days = b['days'] as int;
        final bool unlocked = streak >= days;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: PremiumCard(
              radius: 18,
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
              shadow: [
                BoxShadow(
                  color: AppColors.navyDark.withValues(alpha: 0.05),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
              child: Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: unlocked
                          ? AppColors.gold.withValues(alpha: 0.16)
                          : AppColors.backgroundGrey,
                    ),
                    child: Icon(
                      unlocked
                          ? Icons.check_rounded
                          : b['icon'] as IconData,
                      color: unlocked ? AppColors.gold : AppColors.textLight,
                      size: 22,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.tr(
                        ru: '$days дн.', kk: '$days күн', en: '$days d.'),
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                      color:
                          unlocked ? AppColors.textDark : AppColors.textGrey,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '+${b['xp']} XP',
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: AppColors.sky,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _StreakCalendar extends StatelessWidget {
  final int streak;
  final DateTime? lastStudyDate;
  const _StreakCalendar({required this.streak, required this.lastStudyDate});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final weekdayLabels = <String>[
      state.tr(ru: 'Пн', kk: 'Дс', en: 'Mon'),
      state.tr(ru: 'Вт', kk: 'Сс', en: 'Tue'),
      state.tr(ru: 'Ср', kk: 'Ср', en: 'Wed'),
      state.tr(ru: 'Чт', kk: 'Бс', en: 'Thu'),
      state.tr(ru: 'Пт', kk: 'Жм', en: 'Fri'),
      state.tr(ru: 'Сб', kk: 'Сб', en: 'Sat'),
      state.tr(ru: 'Вс', kk: 'Жс', en: 'Sun'),
    ];
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDay = lastStudyDate == null
        ? null
        : DateTime(
            lastStudyDate!.year, lastStudyDate!.month, lastStudyDate!.day);
    const daysToShow = 21;

    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Подписи дней недели (Пн начинает окно из 21 дня, кратного неделе).
          Row(
            children: weekdayLabels
                .map((label) => Expanded(
                      child: Center(
                        child: Text(
                          label,
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textLight,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 10),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: 1,
            ),
            itemCount: daysToShow,
            itemBuilder: (ctx, i) {
              final daysAgo = daysToShow - 1 - i;
              final day = today.subtract(Duration(days: daysAgo));
              final isToday = daysAgo == 0;
              // День «изучен», только если он попадает в реальное окно стрика,
              // заканчивающееся на дне последнего занятия. Так сегодня получает
              // огонёк лишь когда занятие действительно было сегодня (а не
              // авансом), и мы не рисуем дни за пределами реального стрика.
              var isStudied = false;
              if (lastDay != null && streak > 0) {
                final offsetFromLast = lastDay.difference(day).inDays;
                isStudied = offsetFromLast >= 0 && offsetFromLast < streak;
              }

              return _CalendarCell(
                day: day.day,
                isStudied: isStudied,
                isToday: isToday,
              );
            },
          ),
        ],
      ),
    );
  }
}

class _CalendarCell extends StatelessWidget {
  final int day;
  final bool isStudied;
  final bool isToday;
  const _CalendarCell({
    required this.day,
    required this.isStudied,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    final Color bg = isStudied
        ? AppColors.coral
        : (isToday ? AppColors.skyLight : AppColors.backgroundGrey);

    return Container(
      decoration: BoxDecoration(
        color: bg,
        shape: BoxShape.circle,
        border: isToday && !isStudied
            ? Border.all(color: AppColors.sky, width: 2)
            : null,
        boxShadow: isStudied
            ? [
                BoxShadow(
                  color: AppColors.coral.withValues(alpha: 0.32),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ]
            : null,
      ),
      child: Center(
        child: isStudied
            ? const Icon(
                Icons.local_fire_department_rounded,
                color: Colors.white,
                size: 16,
              )
            : Text(
                '$day',
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: isToday ? AppColors.sky : AppColors.textGrey,
                ),
              ),
      ),
    );
  }
}
