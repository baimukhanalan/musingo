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
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Таблица лидеров',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
      ),
      body: Column(
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
                  onRefresh: () async {
                    _refresh();
                  },
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: entries.length + 1,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _LeagueRulesCard(entries: entries);
                      }
                      return _LeaderboardTile(
                        entry: entries[index - 1],
                        totalEntries: entries.length,
                      );
                    },
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
    final remaining = _remainingInSeason(DateTime.now());
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
      child: Row(
        children: [
          const Icon(Icons.leaderboard_rounded, color: Colors.white, size: 36),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Еженедельная лига',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white)),
                Text('До конца сезона: $remaining',
                    style: const TextStyle(
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

  String _remainingInSeason(DateTime now) {
    final daysUntilMonday = (DateTime.monday - now.weekday) % 7;
    final nextMonday = DateTime(now.year, now.month, now.day)
        .add(Duration(days: daysUntilMonday == 0 ? 7 : daysUntilMonday));
    final diff = nextMonday.difference(now);
    final days = diff.inDays;
    final hours = diff.inHours % 24;
    if (days <= 0) return '$hours ч.';
    return '$days д. $hours ч.';
  }
}

class _LeaderboardTile extends StatelessWidget {
  final LeaderboardEntry entry;
  final int totalEntries;
  const _LeaderboardTile({required this.entry, required this.totalEntries});

  @override
  Widget build(BuildContext context) {
    final trimmedName = entry.name.trim();
    final initial = trimmedName.isEmpty
        ? '?'
        : String.fromCharCodes([trimmedName.runes.first]);
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
    final zone = _zoneFor(entry.position, totalEntries);

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
                child: Text(initial,
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
                    value: (entry.xp / 1500).clamp(0.0, 1.0),
                    minHeight: 5,
                    backgroundColor: AppColors.pistachioLight,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        entry.position == 1
                            ? AppColors.gold
                            : AppColors.pistachio),
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(zone.icon, color: zone.color, size: 14),
                    const SizedBox(width: 4),
                    Text(zone.label,
                        style: TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            color: zone.color)),
                  ],
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

  _LeagueZone _zoneFor(int position, int total) {
    if (position <= 2) {
      return const _LeagueZone(
        label: 'Повышение',
        icon: Icons.arrow_upward_rounded,
        color: AppColors.success,
      );
    }
    if (total >= 5 && position == total) {
      return const _LeagueZone(
        label: 'Понижение',
        icon: Icons.arrow_downward_rounded,
        color: AppColors.error,
      );
    }
    return const _LeagueZone(
      label: 'Удержание',
      icon: Icons.shield_rounded,
      color: AppColors.textGrey,
    );
  }
}

class _LeagueRulesCard extends StatelessWidget {
  final List<LeaderboardEntry> entries;

  const _LeagueRulesCard({required this.entries});

  @override
  Widget build(BuildContext context) {
    final current = _firstWhereOrNull(
      entries,
      (entry) => entry.isCurrentUser,
    );
    final nextXp = _nextTargetXp(current, entries);
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.workspace_premium_rounded,
                  color: AppColors.gold, size: 22),
              SizedBox(width: 8),
              Text('Правила сезона',
                  style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark)),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            nextXp == null
                ? 'Ты сейчас в зоне повышения. Удерживай место до понедельника.'
                : 'До следующего места нужно $nextXp XP. Топ-2 переходят выше, последнее место понижается.',
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 13,
                height: 1.35,
                color: AppColors.textGrey),
          ),
        ],
      ),
    );
  }

  int? _nextTargetXp(LeaderboardEntry? current, List<LeaderboardEntry> entries) {
    if (current == null || current.position <= 1) return null;
    final above = _firstWhereOrNull(
      entries,
      (entry) => entry.position == current.position - 1,
    );
    if (above == null) return null;
    return (above.xp - current.xp + 1).clamp(1, 9999).toInt();
  }

  LeaderboardEntry? _firstWhereOrNull(
    List<LeaderboardEntry> entries,
    bool Function(LeaderboardEntry entry) test,
  ) {
    for (final entry in entries) {
      if (test(entry)) return entry;
    }
    return null;
  }
}

class _LeagueZone {
  final String label;
  final IconData icon;
  final Color color;

  const _LeagueZone({
    required this.label,
    required this.icon,
    required this.color,
  });
}
