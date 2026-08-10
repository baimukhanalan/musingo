import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/leaderboard.dart';
import '../services/app_state.dart';
import '../services/backend_service.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';

class LeagueScreen extends StatefulWidget {
  const LeagueScreen({super.key});

  @override
  State<LeagueScreen> createState() => _LeagueScreenState();
}

class _LeagueScreenState extends State<LeagueScreen> {
  BackendService? _backend;
  List<LeaderboardEntry> _entries = const [];
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (context.read<AppState>().isBackendUser) _load();
  }

  @override
  void dispose() {
    _backend?.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_loading) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      _backend ??= await BackendService.create();
      final entries = await _backend!.getLeaderboard();
      if (!mounted) return;
      setState(() => _entries = entries);
    } catch (error) {
      if (!mounted) return;
      setState(() => _error = readableBackendError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final canLoad = state.isBackendUser;
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            children: [
              _Header(refreshing: _loading, onRefresh: canLoad ? _load : null),
              Expanded(
                child: RefreshIndicator(
                  onRefresh: canLoad ? _load : () async {},
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
                    children: [
                      const _LeagueSummary(),
                      const SizedBox(height: 14),
                      if (!canLoad)
                        const _AccountRequired()
                      else if (_loading && _entries.isEmpty)
                        const _LoadingCard()
                      else if (_error != null && _entries.isEmpty)
                        _ErrorCard(message: _error!, onRetry: _load)
                      else if (_entries.isEmpty)
                        const _EmptyLeague()
                      else
                        ..._entries.map((entry) => Padding(
                              padding: const EdgeInsets.only(bottom: 9),
                              child: _LeaderboardRow(entry: entry),
                            )),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  final bool refreshing;
  final VoidCallback? onRefresh;

  const _Header({required this.refreshing, required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
      child: Row(
        children: [
          IconButton(
            tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
            onPressed: () => Navigator.maybePop(context),
            icon: const Icon(Icons.arrow_back_rounded),
          ),
          Expanded(
            child: Text(
              state.tr(
                ru: 'Недельная лига',
                kk: 'Апталық лига',
                en: 'Weekly league',
              ),
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 22,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark,
              ),
            ),
          ),
          IconButton(
            tooltip: state.tr(ru: 'Обновить', kk: 'Жаңарту', en: 'Refresh'),
            onPressed: refreshing ? null : onRefresh,
            icon: refreshing
                ? const SizedBox.square(
                    dimension: 20,
                    child: CircularProgressIndicator(strokeWidth: 2.5),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
    );
  }
}

class _LeagueSummary extends StatelessWidget {
  const _LeagueSummary();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navyDark, AppColors.navy],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.emoji_events_rounded,
              color: AppColors.gold, size: 48),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  state.tr(
                    ru: 'Учись регулярно, а не напоказ',
                    kk: 'Көрсету үшін емес, тұрақты оқы',
                    en: 'Learn consistently, not for show',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  state.tr(
                    ru: 'Учитывается только XP этой недели. Новый сезон начинается в понедельник.',
                    kk: 'Тек осы аптаның XP-і есептеледі. Жаңа маусым дүйсенбіде басталады.',
                    en: 'Only this week\'s XP counts. A new season starts Monday.',
                  ),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white70,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AccountRequired extends StatelessWidget {
  const _AccountRequired();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      radius: 8,
      child: Column(
        children: [
          const Icon(Icons.lock_outline_rounded,
              color: AppColors.navy, size: 42),
          const SizedBox(height: 12),
          Text(
            state.tr(
              ru: 'Войди, чтобы участвовать',
              kk: 'Қатысу үшін кір',
              en: 'Sign in to participate',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 18,
              fontWeight: FontWeight.w900,
              color: AppColors.navyDark,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            state.tr(
              ru: 'Лига показывает только имя и недельный XP. Записи голоса и личный прогресс остаются приватными.',
              kk: 'Лига тек ат пен апталық XP-ді көрсетеді. Дауыс жазбалары мен жеке прогресс құпия қалады.',
              en: 'The league shows only your name and weekly XP. Voice recordings and private progress stay private.',
            ),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13.5,
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 18),
          PremiumButton(
            label: state.tr(
              ru: 'Войти или создать аккаунт',
              kk: 'Кіру немесе аккаунт жасау',
              en: 'Sign in or create account',
            ),
            icon: Icons.login_rounded,
            onPressed: () => Navigator.pushNamed(context, '/login'),
          ),
        ],
      ),
    );
  }
}

class _LoadingCard extends StatelessWidget {
  const _LoadingCard();

  @override
  Widget build(BuildContext context) => const PremiumCard(
        radius: 8,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 30),
          child: Center(child: CircularProgressIndicator()),
        ),
      );
}

class _ErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      radius: 8,
      child: Column(
        children: [
          const Icon(Icons.cloud_off_rounded, color: AppColors.error, size: 40),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
          const SizedBox(height: 16),
          PremiumButton(
            label: state.tr(ru: 'Повторить', kk: 'Қайталау', en: 'Try again'),
            icon: Icons.refresh_rounded,
            onPressed: onRetry,
          ),
        ],
      ),
    );
  }
}

class _EmptyLeague extends StatelessWidget {
  const _EmptyLeague();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      radius: 8,
      child: Text(
        state.tr(
          ru: 'В этой неделе пока нет участников. Заверши урок и стань первым.',
          kk: 'Бұл аптада әзірге қатысушылар жоқ. Сабақты аяқтап, бірінші бол.',
          en: 'No participants yet this week. Finish a lesson and be first.',
        ),
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontFamily: 'Nunito',
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: AppColors.textGrey,
        ),
      ),
    );
  }
}

class _LeaderboardRow extends StatelessWidget {
  final LeaderboardEntry entry;

  const _LeaderboardRow({required this.entry});

  @override
  Widget build(BuildContext context) {
    final medal = switch (entry.position) {
      1 => AppColors.gold,
      2 => const Color(0xFF8EA3B3),
      3 => const Color(0xFFB87A4B),
      _ => AppColors.sky,
    };
    return PremiumCard(
      radius: 8,
      color: entry.isCurrentUser ? AppColors.skyLight : null,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          SizedBox(
            width: 34,
            child: Text(
              '${entry.position}',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 17,
                fontWeight: FontWeight.w900,
                color: medal,
              ),
            ),
          ),
          const SizedBox(width: 10),
          CircleAvatar(
            radius: 21,
            backgroundColor: medal.withValues(alpha: 0.16),
            child: Text(
              entry.name.characters.firstOrNull?.toUpperCase() ?? '?',
              style: TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                color: medal,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              entry.name,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.navyDark,
              ),
            ),
          ),
          Text(
            '${entry.xp} XP',
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.navy,
            ),
          ),
        ],
      ),
    );
  }
}
