import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import 'home_screen.dart';
import 'quran_screen.dart';
import 'rules_screen.dart';
import 'leaderboard_screen.dart';
import 'profile_screen.dart';
import 'login_screen.dart';

class MainTabScreen extends StatefulWidget {
  final int initialIndex;
  const MainTabScreen({super.key, this.initialIndex = 0});

  @override
  State<MainTabScreen> createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  late int _current;

  @override
  void initState() {
    super.initState();
    _current = widget.initialIndex;
  }

  final _screens = const [
    HomeScreen(),
    QuranScreen(),
    RulesScreen(),
    LeaderboardScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<AppState>();
    if (!appState.isInitialized) {
      return const Scaffold(
        backgroundColor: AppColors.background,
        body: Center(child: CircularProgressIndicator(color: AppColors.sky)),
      );
    }
    if (!appState.isLoggedIn) return const LoginScreen();

    return Scaffold(
      body: IndexedStack(index: _current, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: AppColors.white,
          border:
              const Border(top: BorderSide(color: AppColors.border, width: 1)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, -2))
          ],
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
            child: Row(
              children: [
                _NavItem(
                    icon: Icons.school_rounded,
                    label: 'Уроки',
                    index: 0,
                    current: _current,
                    onTap: _onTap),
                _NavItem(
                    icon: Icons.menu_book_rounded,
                    label: 'Коран',
                    index: 1,
                    current: _current,
                    onTap: _onTap),
                _NavItem(
                    icon: Icons.account_balance_rounded,
                    label: 'Правила',
                    index: 2,
                    current: _current,
                    onTap: _onTap),
                _NavItem(
                    icon: Icons.shield_rounded,
                    label: 'Лига',
                    index: 3,
                    current: _current,
                    onTap: _onTap),
                _NavItem(
                    icon: Icons.person_rounded,
                    label: 'Профиль',
                    index: 4,
                    current: _current,
                    onTap: _onTap),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _onTap(int index) => setState(() => _current = index);
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int index;
  final int current;
  final void Function(int) onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.index,
    required this.current,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = index == current;

    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 7),
          decoration: const BoxDecoration(color: Colors.transparent),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon,
                  color: isActive ? AppColors.pistachio : AppColors.textLight,
                  size: 26),
              const SizedBox(height: 3),
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 10,
                  fontWeight: FontWeight.w900,
                  color:
                      isActive ? AppColors.pistachioDark : AppColors.textGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
