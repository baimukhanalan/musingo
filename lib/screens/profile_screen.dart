import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/achievement.dart';
import '../models/lesson.dart';
import '../models/user.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../utils/flags.dart';
import '../widgets/cat_character.dart';
import '../widgets/language_pills.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_label.dart';
import '../widgets/stat_badge.dart';

/// Экран 1g «Профиль» из DESIGN_SPEC. Только визуальная подача — все значения
/// (имя, уровень, серия, XP, суры, точность, активность недели, ачивки,
/// premium-статус) берутся из [AppState]/[UserModel], навигация и logout
/// сохранены как были.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) return const SizedBox.shrink();

    // Суры — завершённые уроки в курсе Корана (реальный прогресс из AppState).
    final int suras = state.getCourse(CourseType.quran)?.completedLessons ?? 0;
    // Точность — средняя «сила» знаний по интервальному повторению.
    final int accuracy = _accuracyPercent(state);
    final List<bool> week = _weekActivity(user);

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _ProfileHeader(user: user),
                const SizedBox(height: 16),
                _StatsRow(
                  user: user,
                  suras: suras,
                  accuracy: accuracy,
                ),
                const SizedBox(height: 22),
                SectionLabel(
                    text: state.tr(
                        ru: 'Эта неделя',
                        kk: 'Осы апта',
                        en: 'This week')),
                const SizedBox(height: 10),
                _WeekStrip(
                  week: week,
                  onTap: () => Navigator.pushNamed(context, '/streak'),
                ),
                const SizedBox(height: 22),
                _AchievementsHeader(
                  onSeeAll: () =>
                      Navigator.pushNamed(context, '/achievements'),
                ),
                const SizedBox(height: 12),
                _AchievementsGrid(achievements: state.achievements),
                if (!user.isPremium) ...[
                  const SizedBox(height: 22),
                  _PremiumUpsell(
                    onTap: () => Navigator.pushNamed(context, '/premium'),
                  ),
                ],
                const SizedBox(height: 22),
                _MenuSection(
                  items: [
                    if (state.isGuest)
                      _MenuItem(
                        icon: Icons.cloud_upload_rounded,
                        label: state.tr(
                            ru: 'Сохранить прогресс',
                            kk: 'Прогресті сақтау',
                            en: 'Save progress'),
                        color: AppColors.navy,
                        onTap: () => Navigator.pushNamed(context, '/login'),
                      ),
                    _MenuItem(
                      icon: Icons.groups_rounded,
                      label: state.tr(
                          ru: 'Друзья', kk: 'Достар', en: 'Friends'),
                      color: AppColors.sky,
                      onTap: () => Navigator.pushNamed(context, '/friends'),
                    ),
                    _MenuItem(
                      icon: Icons.notifications_active_rounded,
                      label: state.tr(
                          ru: 'Напоминания',
                          kk: 'Еске салулар',
                          en: 'Reminders'),
                      color: AppColors.coral,
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    _MenuItem(
                      icon: Icons.record_voice_over_rounded,
                      label: state.tr(ru: 'Кари', kk: 'Қари', en: 'Qari'),
                      subtitle: state.tr(
                          ru: 'Выбор чтеца',
                          kk: 'Қари таңдау',
                          en: 'Choose reciter'),
                      color: AppColors.gold,
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuSection(
                  items: [
                    _MenuItem(
                      icon: Icons.settings_rounded,
                      label: state.tr(
                          ru: 'Настройки', kk: 'Баптаулар', en: 'Settings'),
                      color: AppColors.textGrey,
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    _MenuItem(
                      icon: Icons.help_outline_rounded,
                      label: state.tr(
                          ru: 'Помощь', kk: 'Көмек', en: 'Help'),
                      color: AppColors.textGrey,
                      onTap: () => Navigator.pushNamed(context, '/help'),
                    ),
                    _MenuItem(
                      icon: Icons.privacy_tip_rounded,
                      label: state.tr(
                          ru: 'Политика конфиденциальности',
                          kk: 'Құпиялылық саясаты',
                          en: 'Privacy Policy'),
                      color: AppColors.textGrey,
                      onTap: () => Navigator.pushNamed(context, '/settings'),
                    ),
                    // Виден только в сборке для ревью (MUSLINGO_DRAFT_CONTENT);
                    // в проде флаг выключен и пункта нет.
                    if (kDraftContentEnabled)
                      _MenuItem(
                        icon: Icons.rate_review_rounded,
                        label: state.tr(
                            ru: 'Таджвид — на проверке (черновик)',
                            kk: 'Тәжуид — тексерілуде (жоба)',
                            en: 'Tajwid — under review (draft)'),
                        color: AppColors.gold,
                        onTap: () =>
                            Navigator.pushNamed(context, '/review/tajwid'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                _MenuSection(
                  items: [
                    _MenuItem(
                      icon: Icons.logout_rounded,
                      label: state.isGuest
                          ? state.tr(
                              ru: 'Начать заново',
                              kk: 'Қайта бастау',
                              en: 'Start over')
                          : state.tr(
                              ru: 'Выйти из аккаунта',
                              kk: 'Аккаунттан шығу',
                              en: 'Log out'),
                      color: AppColors.error,
                      onTap: () => _confirmLogout(context, state),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  state.tr(
                    ru: 'Данные хранятся на твоём устройстве и синхронизируются '
                        'только с твоим аккаунтом. Мы не передаём их третьим лицам.',
                    kk: 'Деректер сіздің құрылғыңызда сақталады және тек сіздің '
                        'аккаунтыңызбен синхрондалады. Біз оларды үшінші тұлғаларға бермейміз.',
                    en: 'Your data is stored on your device and synced only with '
                        'your account. We do not share it with third parties.',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    height: 1.4,
                    color: AppColors.textLight,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  state.tr(
                    ru: 'muslingo v1.0 · Для ежедневного обучения',
                    kk: 'muslingo v1.0 · Күнделікті оқуға арналған',
                    en: 'muslingo v1.0 · For daily learning',
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Средняя точность (0..100) по состояниям знаний. Пусто → 0.
  int _accuracyPercent(AppState state) {
    final states = state.knowledgeStates;
    if (states.isEmpty) return 0;
    final avg =
        states.map((k) => k.strength).reduce((a, b) => a + b) / states.length;
    return (avg * 100).round().clamp(0, 100);
  }

  /// Активность текущей недели (Пн..Вс), выведенная из серии и даты последнего
  /// занятия: день активен, если попадает в непрерывный отрезок серии,
  /// заканчивающийся датой последнего занятия, и не в будущем.
  List<bool> _weekActivity(UserModel user) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final monday = today.subtract(Duration(days: today.weekday - 1));
    final last = user.lastStudyDate;
    final DateTime? lastDate =
        last == null ? null : DateTime(last.year, last.month, last.day);

    return List<bool>.generate(7, (i) {
      final day = monday.add(Duration(days: i));
      if (lastDate == null || user.streak <= 0) return false;
      if (day.isAfter(today) || day.isAfter(lastDate)) return false;
      return lastDate.difference(day).inDays < user.streak;
    });
  }

  void _confirmLogout(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(state.tr(ru: 'Выйти?', kk: 'Шығасыз ба?', en: 'Log out?'),
            style: const TextStyle(
                fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
        content: Text(
            state.tr(
                ru: 'Твой прогресс сохранится',
                kk: 'Прогресіңіз сақталады',
                en: 'Your progress will be saved'),
            style: const TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                  state.tr(ru: 'Отмена', kk: 'Болдырмау', en: 'Cancel'),
                  style: const TextStyle(
                      fontFamily: 'Nunito', color: AppColors.pistachio))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await state.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/onboarding');
              }
            },
            child: Text(state.tr(ru: 'Выйти', kk: 'Шығу', en: 'Log out'),
                style: const TextStyle(
                    fontFamily: 'Nunito', color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

/// Уровневый титул наставника (декоративная подпись, выводится из уровня).
String _levelTitle(AppState state, int level) {
  if (level >= 10) {
    return state.tr(
        ru: 'Хранитель аятов', kk: 'Аяттар сақшысы', en: 'Keeper of ayahs');
  }
  if (level >= 6) {
    return state.tr(ru: 'Знаток сур', kk: 'Сүре білгірі', en: 'Sura expert');
  }
  if (level >= 4) {
    return state.tr(
        ru: 'Ученик Аль-Фатихи',
        kk: 'Әл-Фатиха шәкірті',
        en: 'Al-Fatiha student');
  }
  if (level >= 2) {
    return state.tr(
        ru: 'Ученик Корана', kk: 'Құран шәкірті', en: 'Quran student');
  }
  return state.tr(ru: 'Первые шаги', kk: 'Алғашқы қадамдар', en: 'First steps');
}

/// Перевод целого числа в арабо-индийские цифры для декоративных бейджей.
String _toArabicDigits(int n) {
  const digits = ['٠', '١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩'];
  return n
      .toString()
      .split('')
      .map((c) => digits[int.tryParse(c) ?? 0])
      .join();
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _Avatar(isPremium: user.isPremium),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            user.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.navyDark,
                            ),
                          ),
                        ),
                        if (user.isPremium) const _PremiumChip(),
                      ],
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '${state.tr(ru: 'Уровень', kk: 'Деңгей', en: 'Level')} '
                      '${user.level} · ${_levelTitle(state, user.level)}',
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGrey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerLeft,
            child: LanguagePills(
              selected: _langCode(state.nativeLanguage),
            ),
          ),
        ],
      ),
    );
  }

  String _langCode(NativeLanguage? lang) {
    switch (lang) {
      case NativeLanguage.kazakh:
        return 'KZ';
      case NativeLanguage.russian:
      case NativeLanguage.uzbek:
      case null:
        return 'RU';
    }
  }
}

class _Avatar extends StatelessWidget {
  final bool isPremium;
  const _Avatar({required this.isPremium});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 74,
      height: 74,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Container(
            width: 74,
            height: 74,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.skyLight,
              boxShadow: [
                BoxShadow(
                  color: AppColors.sky.withValues(alpha: 0.28),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            alignment: Alignment.center,
            child: const CatCharacter(mood: CatMood.idle, size: 62),
          ),
          if (isPremium)
            Positioned(
              bottom: -2,
              right: -2,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.white, width: 2),
                ),
                child: const Icon(Icons.workspace_premium_rounded,
                    color: Colors.white, size: 13),
              ),
            ),
        ],
      ),
    );
  }
}

class _PremiumChip extends StatelessWidget {
  const _PremiumChip();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.goldLight,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.5)),
      ),
      child: const Text(
        'muslingo+',
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
          fontWeight: FontWeight.w900,
          color: AppColors.gold,
        ),
      ),
    );
  }
}

class _StatsRow extends StatelessWidget {
  final UserModel user;
  final int suras;
  final int accuracy;

  const _StatsRow({
    required this.user,
    required this.suras,
    required this.accuracy,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: StatBadge(
              icon: Icons.local_fire_department_rounded,
              value: '${user.streak}',
              label: state.tr(ru: 'Серия', kk: 'Серия', en: 'Streak'),
              accent: AppColors.coral,
            ),
          ),
          Expanded(
            child: StatBadge(
              icon: Icons.bolt_rounded,
              value: '${user.xp}',
              label: 'XP',
              accent: AppColors.gold,
            ),
          ),
          Expanded(
            child: StatBadge(
              icon: Icons.menu_book_rounded,
              value: '$suras',
              label: state.tr(ru: 'Суры', kk: 'Сүрелер', en: 'Suras'),
              accent: AppColors.sky,
            ),
          ),
          Expanded(
            child: StatBadge(
              icon: Icons.track_changes_rounded,
              value: '$accuracy%',
              label: state.tr(ru: 'Точность', kk: 'Дәлдік', en: 'Accuracy'),
              accent: AppColors.success,
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  final List<bool> week;
  final VoidCallback onTap;

  const _WeekStrip({required this.week, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final labels = [
      state.tr(ru: 'Пн', kk: 'Дс', en: 'Mon'),
      state.tr(ru: 'Вт', kk: 'Сс', en: 'Tue'),
      state.tr(ru: 'Ср', kk: 'Ср', en: 'Wed'),
      state.tr(ru: 'Чт', kk: 'Бс', en: 'Thu'),
      state.tr(ru: 'Пт', kk: 'Жм', en: 'Fri'),
      state.tr(ru: 'Сб', kk: 'Сн', en: 'Sat'),
      state.tr(ru: 'Вс', kk: 'Жс', en: 'Sun'),
    ];
    final now = DateTime.now();
    final todayIndex = now.weekday - 1; // 0..6

    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: PremiumCard(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: List.generate(7, (i) {
            return _DayDot(
              label: labels[i],
              active: week[i],
              isToday: i == todayIndex,
            );
          }),
        ),
      ),
    );
  }
}

class _DayDot extends StatelessWidget {
  final String label;
  final bool active;
  final bool isToday;

  const _DayDot({
    required this.label,
    required this.active,
    required this.isToday,
  });

  @override
  Widget build(BuildContext context) {
    late final BoxDecoration decoration;
    late final Widget dotChild;

    if (active) {
      decoration = const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF5FC3EE), Color(0xFF3FA9DC)],
        ),
      );
      dotChild = const Icon(Icons.check_rounded, size: 20, color: Colors.white);
    } else {
      decoration = BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.backgroundGrey,
        border: Border.all(
          color: isToday ? AppColors.sky : AppColors.border,
          width: isToday ? 2 : 1,
        ),
      );
      dotChild = const SizedBox.shrink();
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 34,
          height: 34,
          alignment: Alignment.center,
          decoration: decoration,
          child: dotChild,
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 11,
            fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
            color: isToday ? AppColors.navyDark : AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

class _AchievementsHeader extends StatelessWidget {
  final VoidCallback onSeeAll;
  const _AchievementsHeader({required this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        SectionLabel(
            text: state.tr(
                ru: 'Достижения',
                kk: 'Жетістіктер',
                en: 'Achievements')),
        GestureDetector(
          onTap: onSeeAll,
          behavior: HitTestBehavior.opaque,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                state.tr(ru: 'Все', kk: 'Барлығы', en: 'All'),
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  color: AppColors.sky,
                ),
              ),
              const Icon(Icons.chevron_right_rounded,
                  size: 18, color: AppColors.sky),
            ],
          ),
        ),
      ],
    );
  }
}

class _AchievementsGrid extends StatelessWidget {
  final List<Achievement> achievements;
  const _AchievementsGrid({required this.achievements});

  @override
  Widget build(BuildContext context) {
    if (achievements.isEmpty) {
      final state = context.watch<AppState>();
      return PremiumCard(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Text(
          state.tr(
              ru: 'Первые достижения появятся после нескольких уроков',
              kk: 'Алғашқы жетістіктер бірнеше сабақтан кейін пайда болады',
              en: 'Your first achievements will appear after a few lessons'),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppColors.textGrey,
          ),
        ),
      );
    }

    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 18),
      child: GridView.count(
        crossAxisCount: 4,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        mainAxisSpacing: 16,
        crossAxisSpacing: 8,
        childAspectRatio: 0.72,
        children: [
          for (final a in achievements) _AchievementBadge(achievement: a),
        ],
      ),
    );
  }
}

class _AchievementBadge extends StatelessWidget {
  final Achievement achievement;
  const _AchievementBadge({required this.achievement});

  @override
  Widget build(BuildContext context) {
    final bool unlocked = achievement.isUnlocked;
    final String glyph = achievement.category == AchievementCategory.quran
        ? 'ق'
        : _toArabicDigits(achievement.requiredValue);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: unlocked
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFFF8CA6B), Color(0xFFEFAE2E)],
                  )
                : null,
            color: unlocked ? null : AppColors.backgroundGrey,
            border: unlocked
                ? null
                : Border.all(color: AppColors.border, width: 1.5),
            boxShadow: unlocked
                ? [
                    BoxShadow(
                      color: AppColors.gold.withValues(alpha: 0.35),
                      blurRadius: 12,
                      offset: const Offset(0, 5),
                    ),
                  ]
                : null,
          ),
          child: Text(
            glyph,
            style: TextStyle(
              fontFamily: 'Amiri',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              color: unlocked ? Colors.white : AppColors.textLight,
            ),
          ),
        ),
        const SizedBox(height: 6),
        Text(
          achievement.title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 10,
            height: 1.1,
            fontWeight: FontWeight.w700,
            color: unlocked ? AppColors.textDark : AppColors.textLight,
          ),
        ),
      ],
    );
  }
}

class _PremiumUpsell extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumUpsell({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [AppColors.navyDark, AppColors.navy, AppColors.navyDark],
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: AppColors.navy.withValues(alpha: 0.35),
              blurRadius: 22,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 46,
              height: 46,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.gold.withValues(alpha: 0.18),
              ),
              child: const Icon(Icons.workspace_premium_rounded,
                  color: AppColors.gold, size: 26),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Muslingo+',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    state.tr(
                        ru: 'Максимум от твоего наставника',
                        kk: 'Ұстазыңнан барынша пайда',
                        en: 'The most from your mentor'),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: Colors.white70,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Colors.white, size: 22),
          ],
        ),
      ),
    );
  }
}

class _MenuSection extends StatelessWidget {
  final List<_MenuItem> items;
  const _MenuSection({required this.items});

  @override
  Widget build(BuildContext context) {
    return PremiumCard(
      padding: EdgeInsets.zero,
      radius: 18,
      child: Column(
        children: List.generate(items.length, (i) {
          final item = items[i];
          final bool first = i == 0;
          final bool last = i == items.length - 1;
          return Column(
            children: [
              Material(
                type: MaterialType.transparency,
                child: InkWell(
                  borderRadius: BorderRadius.vertical(
                    top: first ? const Radius.circular(18) : Radius.zero,
                    bottom: last ? const Radius.circular(18) : Radius.zero,
                  ),
                  onTap: item.onTap,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: item.color.withValues(alpha: 0.12),
                            shape: BoxShape.circle,
                          ),
                          child:
                              Icon(item.icon, color: item.color, size: 20),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                item.label,
                                style: const TextStyle(
                                  fontFamily: 'Nunito',
                                  fontSize: 15.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textDark,
                                ),
                              ),
                              if (item.subtitle != null) ...[
                                const SizedBox(height: 2),
                                Text(
                                  item.subtitle!,
                                  style: const TextStyle(
                                    fontFamily: 'Nunito',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.textLight,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                        const Icon(Icons.chevron_right_rounded,
                            color: AppColors.textLight),
                      ],
                    ),
                  ),
                ),
              ),
              if (!last)
                const Divider(
                    height: 1, color: AppColors.border, indent: 68),
            ],
          );
        }),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final VoidCallback? onTap;

  const _MenuItem({
    required this.icon,
    required this.label,
    required this.color,
    this.subtitle,
    this.onTap,
  });
}
