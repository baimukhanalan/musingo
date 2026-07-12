import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/user.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    if (user == null) return const SizedBox.shrink();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.white,
            elevation: 0,
            title: const Text('Профиль',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark)),
            actions: [
              IconButton(
                icon: const Icon(Icons.settings_rounded,
                    color: AppColors.textGrey),
                onPressed: () => Navigator.pushNamed(context, '/settings'),
              ),
            ],
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _ProfileHeader(user: user),
                  const SizedBox(height: 16),
                  _StatsGrid(user: user),
                  const SizedBox(height: 16),
                  if (!user.isPremium)
                    _PremiumBannerProfile(
                      onTap: () => Navigator.pushNamed(context, '/premium'),
                    ),
                  if (!user.isPremium) const SizedBox(height: 16),
                  _MenuSection(
                    items: [
                      _MenuItem(
                          icon: Icons.emoji_events_rounded,
                          label: 'Достижения',
                          color: AppColors.gold,
                          onTap: () =>
                              Navigator.pushNamed(context, '/achievements')),
                      _MenuItem(
                          icon: Icons.leaderboard_rounded,
                          label: 'Таблица лидеров',
                          color: AppColors.pistachio,
                          onTap: () =>
                              Navigator.pushNamed(context, '/leaderboard')),
                      _MenuItem(
                          icon: Icons.local_fire_department_rounded,
                          label: 'Мой страйк',
                          color: AppColors.coral,
                          onTap: () => Navigator.pushNamed(context, '/streak')),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _MenuSection(
                    items: [
                      _MenuItem(
                          icon: Icons.settings_rounded,
                          label: 'Настройки',
                          color: AppColors.textGrey,
                          onTap: () =>
                              Navigator.pushNamed(context, '/settings')),
                      _MenuItem(
                          icon: Icons.help_outline_rounded,
                          label: 'Помощь',
                          color: AppColors.textGrey,
                          onTap: () => Navigator.pushNamed(context, '/help')),
                      _MenuItem(
                          icon: Icons.logout_rounded,
                          label: 'Выйти из аккаунта',
                          color: AppColors.error,
                          onTap: () => _confirmLogout(context, state)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text('muslingo v1.0 • Для ежедневного обучения',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: AppColors.textGrey)),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _confirmLogout(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Выйти?',
            style:
                TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
        content: const Text('Твой прогресс сохранится',
            style: TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена',
                  style: TextStyle(
                      fontFamily: 'Nunito', color: AppColors.pistachio))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await state.logout();
              if (context.mounted) {
                Navigator.pushReplacementNamed(context, '/carousel');
              }
            },
            child: const Text('Выйти',
                style: TextStyle(fontFamily: 'Nunito', color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  final UserModel user;
  const _ProfileHeader({required this.user});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 8,
              offset: const Offset(0, 3))
        ],
      ),
      child: Row(
        children: [
          Stack(
            children: [
              Container(
                width: 70,
                height: 70,
                decoration: const BoxDecoration(
                    color: AppColors.pistachioLight, shape: BoxShape.circle),
                child: const CatCharacter(mood: CatMood.idle, size: 60),
              ),
              if (user.isPremium)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: const BoxDecoration(
                        color: AppColors.gold, shape: BoxShape.circle),
                    child: const Icon(Icons.workspace_premium_rounded,
                        color: Colors.white, size: 13),
                  ),
                ),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                        child: Text(user.name,
                            style: const TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 20,
                                fontWeight: FontWeight.w800,
                                color: AppColors.textDark))),
                    if (user.isPremium)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 3),
                        decoration: BoxDecoration(
                            color: AppColors.goldLight,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                                color: AppColors.gold.withValues(alpha: 0.5))),
                        child: const Text('muslingo+',
                            style: TextStyle(
                                fontFamily: 'Nunito',
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                color: AppColors.gold)),
                      ),
                  ],
                ),
                Text(user.email.isEmpty ? 'Email не указан' : user.email,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: AppColors.textGrey)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _Badge(
                        icon: Icons.military_tech_rounded,
                        text: 'Ур. ${user.level}',
                        color: AppColors.pistachio),
                    const SizedBox(width: 8),
                    _Badge(
                        icon: Icons.bolt_rounded,
                        text: '${user.xp} XP',
                        color: AppColors.gold),
                    const SizedBox(width: 8),
                    _Badge(
                        icon: Icons.local_fire_department_rounded,
                        text: '${user.streak} дн.',
                        color: AppColors.coral),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _Badge({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
      decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 13),
          const SizedBox(width: 3),
          Text(text,
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: color)),
        ],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  final UserModel user;
  const _StatsGrid({required this.user});

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 10,
      crossAxisSpacing: 10,
      childAspectRatio: 2.2,
      children: [
        _StatTile(
            icon: Icons.school_rounded,
            label: 'Всего уроков',
            value: '${user.totalLessons}'),
        _StatTile(
            icon: Icons.local_fire_department_rounded,
            label: 'Страйк',
            value: '${user.streak} дней'),
        _StatTile(
            icon: Icons.menu_book_rounded,
            label: 'Аятов изучено',
            value: '${user.learnedAyats}'),
        _StatTile(
            icon: Icons.volunteer_activism_rounded,
            label: 'Дуа изучено',
            value: '${user.learnedDuas}'),
      ],
    );
  }
}

class _StatTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatTile(
      {required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.pistachio, size: 24),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(value,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
                Text(label,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 11,
                        color: AppColors.textGrey)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _PremiumBannerProfile extends StatelessWidget {
  final VoidCallback onTap;
  const _PremiumBannerProfile({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [AppColors.sky, AppColors.navy],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: AppColors.pistachio.withValues(alpha: 0.35),
                blurRadius: 10,
                offset: const Offset(0, 4))
          ],
        ),
        child: const Row(
          children: [
            Icon(Icons.workspace_premium_rounded,
                color: Colors.white, size: 34),
            SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('muslingo+',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Colors.white)),
                  Text('Новые возможности готовятся к запуску',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 12,
                          color: Colors.white70)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded,
                color: Colors.white, size: 16),
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
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        children: List.generate(
            items.length,
            (i) => Column(
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.only(
                        topLeft:
                            i == 0 ? const Radius.circular(16) : Radius.zero,
                        topRight:
                            i == 0 ? const Radius.circular(16) : Radius.zero,
                        bottomLeft: i == items.length - 1
                            ? const Radius.circular(16)
                            : Radius.zero,
                        bottomRight: i == items.length - 1
                            ? const Radius.circular(16)
                            : Radius.zero,
                      ),
                      onTap: items[i].onTap,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 14),
                        child: Row(
                          children: [
                            Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                  color: items[i].color.withValues(alpha: 0.12),
                                  shape: BoxShape.circle),
                              child: Icon(items[i].icon,
                                  color: items[i].color, size: 20),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                                child: Text(items[i].label,
                                    style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.textDark))),
                            const Icon(Icons.chevron_right_rounded,
                                color: AppColors.textGrey),
                          ],
                        ),
                      ),
                    ),
                    if (i < items.length - 1)
                      const Divider(
                          height: 1, color: AppColors.border, indent: 66),
                  ],
                )),
      ),
    );
  }
}

class _MenuItem {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;

  const _MenuItem(
      {required this.icon,
      required this.label,
      required this.color,
      this.onTap});
}
