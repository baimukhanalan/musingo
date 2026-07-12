import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/leaderboard.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/custom_button.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  Future<List<LeaderboardEntry>>? _entries;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _entries ??= context.read<AppState>().fetchLeaderboard();
  }

  void _refresh() {
    setState(() {
      _entries = context.read<AppState>().fetchLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Таблица лидеров',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
      ),
      body: !state.isBackendUser
          ? _GuestLeaderboard(onLogin: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                '/login',
                (route) => false,
              );
            })
          : Column(
              children: [
                _WeeklyBanner(),
                Expanded(
                  child: FutureBuilder<List<LeaderboardEntry>>(
                    future: _entries,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: AppColors.pistachio,
                          ),
                        );
                      }
                      if (snapshot.hasError) {
                        return _LeaderboardError(onRetry: _refresh);
                      }
                      final entries = snapshot.data ?? const [];
                      if (entries.isEmpty) {
                        return const Center(child: Text('Пока нет участников'));
                      }
                      return RefreshIndicator(
                        onRefresh: () async => _refresh(),
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: entries.length,
                          itemBuilder: (context, index) =>
                              _LeaderboardTile(entry: entries[index]),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}

class _GuestLeaderboard extends StatelessWidget {
  final VoidCallback onLogin;

  const _GuestLeaderboard({required this.onLogin});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.leaderboard_rounded,
                size: 64, color: AppColors.pistachio),
            const SizedBox(height: 16),
            const Text(
              'Войди в аккаунт, чтобы участвовать в рейтинге',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 20),
            CustomButton(text: 'Войти', onPressed: onLogin),
          ],
        ),
      ),
    );
  }
}

class _LeaderboardError extends StatelessWidget {
  final VoidCallback onRetry;

  const _LeaderboardError({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Не удалось загрузить рейтинг',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 16),
            CustomButton(
              text: 'Повторить',
              icon: Icons.refresh_rounded,
              onPressed: onRetry,
            ),
          ],
        ),
      ),
    );
  }
}

class _WeeklyBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.sky, AppColors.navy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Row(
        children: [
          Icon(Icons.leaderboard_rounded, color: Colors.white, size: 36),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Общий рейтинг',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                Text('XP обновляется после каждого урока',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 12,
                        color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  const _LeaderboardTile({required this.entry});

  @override
  Widget build(BuildContext context) {
    Color? cardColor;
    Widget? medal;

    if (entry.position == 1) {
      cardColor = AppColors.goldLight;
      medal =
          const Icon(Icons.looks_one_rounded, color: AppColors.gold, size: 30);
    } else if (entry.position == 2) {
      cardColor = AppColors.backgroundGrey;
      medal = const Icon(Icons.looks_two_rounded,
          color: AppColors.textGrey, size: 30);
    } else if (entry.position == 3) {
      cardColor = AppColors.errorLight;
      medal =
          const Icon(Icons.looks_3_rounded, color: AppColors.coral, size: 30);
    } else if (entry.isCurrentUser) {
      cardColor = AppColors.pistachioLight.withValues(alpha: 0.4);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: cardColor ?? AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: entry.isCurrentUser ? AppColors.pistachio : AppColors.border,
          width: entry.isCurrentUser ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          medal ??
              Container(
                width: 32,
                height: 32,
                decoration: const BoxDecoration(
                    color: AppColors.backgroundGrey, shape: BoxShape.circle),
                child: Center(
                    child: Text('${entry.position}',
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textGrey))),
              ),
          const SizedBox(width: 14),
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: entry.isCurrentUser
                  ? AppColors.pistachio
                  : AppColors.pistachioLight,
              shape: BoxShape.circle,
            ),
            child: Center(
                child: Text(entry.name[0],
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: entry.isCurrentUser
                            ? Colors.white
                            : AppColors.pistachioDark))),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                        entry.isCurrentUser ? '${entry.name} (ты)' : entry.name,
                        style: TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: entry.isCurrentUser
                              ? AppColors.pistachioDark
                              : AppColors.textDark,
                        )),
                  ],
                ),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: entry.xp / 1500,
                    minHeight: 5,
                    backgroundColor: AppColors.pistachioLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        entry.position == 1
                            ? AppColors.gold
                            : AppColors.pistachio),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text('${entry.xp}',
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.pistachioDark)),
              const Text('XP',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 11,
                      color: AppColors.textGrey)),
            ],
          ),
        ],
      ),
    );
  }
}
