import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/achievement.dart';
import '../models/lesson.dart';
import '../models/user.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/language_pills.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_label.dart';
import '../widgets/stat_badge.dart';

part 'profile/profile_header.dart';
part 'profile/profile_achievements.dart';
part 'profile/profile_actions.dart';

/// Экран 1g «Профиль» из DESIGN_SPEC. Только визуальная подача — все значения
/// (имя, уровень, серия, XP, суры, точность, активность недели, ачивки,
/// premium-статус) берутся из [AppState]/[UserModel], навигация и logout
/// сохранены как были.
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final state = context.read<AppState>();
    final opened = await launchUrl(
      Uri.parse('https://muslingo-mobile.vercel.app/privacy'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr(
            ru: 'Не удалось открыть политику конфиденциальности',
            kk: 'Құпиялылық саясатын ашу мүмкін болмады',
            en: 'Could not open the privacy policy',
          )),
        ),
      );
    }
  }

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
                // Гостю показываем заметную премиум-карточку «Сохрани прогресс»:
                // аккаунт нужен только чтобы синхронизировать облако и не потерять
                // данные при смене/очистке устройства. Аккаунт не навязываем —
                // гость продолжает жить на устройстве. Залогиненным не показываем.
                if (state.isGuest) ...[
                  const SizedBox(height: 16),
                  _GuestSaveProgressCard(
                    onTap: () => Navigator.pushNamed(context, '/login'),
                  ),
                ],
                const SizedBox(height: 22),
                SectionLabel(
                    text: state.tr(
                        ru: 'Эта неделя', kk: 'Осы апта', en: 'This week')),
                const SizedBox(height: 10),
                _WeekStrip(
                  week: week,
                  onTap: () => Navigator.pushNamed(context, '/streak'),
                ),
                const SizedBox(height: 22),
                _AchievementsHeader(
                  onSeeAll: () => Navigator.pushNamed(context, '/achievements'),
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
                      label:
                          state.tr(ru: 'Друзья', kk: 'Достар', en: 'Friends'),
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
                      label: state.tr(
                        ru: 'Мишари Аль-Афаси',
                        kk: 'Мишари Әл-Афаси',
                        en: 'Mishary Alafasy',
                      ),
                      subtitle: state.tr(
                          ru: 'Аудио в Quran Reader',
                          kk: 'Quran Reader аудиосы',
                          en: 'Audio in Quran Reader'),
                      color: AppColors.gold,
                      onTap: () => Navigator.pushNamed(context, '/quran'),
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
                      label: state.tr(ru: 'Помощь', kk: 'Көмек', en: 'Help'),
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
                      onTap: () => _openPrivacyPolicy(context),
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
              child: Text(state.tr(ru: 'Отмена', kk: 'Болдырмау', en: 'Cancel'),
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
  return n.toString().split('').map((c) => digits[int.tryParse(c) ?? 0]).join();
}
