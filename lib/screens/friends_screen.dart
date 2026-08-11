import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../models/friend.dart';
import '../services/app_state.dart';
import '../services/backend_service.dart';
import '../utils/colors.dart';
import '../widgets/language_pills.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_label.dart';

part 'friends/friends_header.dart';
part 'friends/friends_actions.dart';
part 'friends/friends_list.dart';

/// Экран «Друзья» — соревнование с реальными людьми и вход в недельную лигу.
/// Для backend-пользователя это настоящая фича поверх сервера:
/// код-приглашение с сервера, добавление друга по коду и живой список с их
/// XP/страйком. Для гостя — предложение создать аккаунт.
class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final TextEditingController _codeController = TextEditingController();

  BackendService? _backend;
  String? _serverCode;
  List<Friend> _friends = const [];
  bool _loading = false;
  bool _adding = false;
  String? _loadError;

  @override
  void initState() {
    super.initState();
    // Сеть — только для backend-пользователя. Гость и локальный аккаунт
    // рендерятся синхронно, без обращения к серверу.
    final state = context.read<AppState>();
    if (state.isBackendUser) {
      _loadFriends();
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    _backend?.dispose();
    super.dispose();
  }

  Future<void> _loadFriends() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    try {
      _backend ??= await BackendService.create();
      final code = await _backend!.myFriendCode();
      final friends = await _backend!.listFriends();
      if (!mounted) return;
      setState(() {
        _serverCode = code.code.isEmpty ? null : code.code;
        _friends = friends;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;
      // Фолбэк на локальный код — экран остаётся рабочим и оффлайн.
      setState(() {
        _loadError = readableBackendError(error);
        _loading = false;
      });
    }
  }

  Future<void> _addFriend() async {
    final code = _codeController.text.trim();
    if (code.isEmpty || _adding) return;
    final state = context.read<AppState>();
    FocusScope.of(context).unfocus();
    setState(() => _adding = true);
    try {
      final friend =
          await (_backend ??= await BackendService.create()).addFriend(code);
      _codeController.clear();
      await _loadFriends();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(state.tr(
                ru: '${friend.displayName} добавлен в друзья',
                kk: '${friend.displayName} досқа қосылды',
                en: '${friend.displayName} added to friends'))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(readableBackendError(error))),
      );
    } finally {
      if (mounted) setState(() => _adding = false);
    }
  }

  Future<void> _removeFriend(Friend friend) async {
    final state = context.read<AppState>();
    try {
      await (_backend ??= await BackendService.create())
          .removeFriend(friend.code);
      await _loadFriends();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(state.tr(
                ru: '${friend.displayName} удалён из друзей',
                kk: '${friend.displayName} достардан өшірілді',
                en: '${friend.displayName} removed from friends'))),
      );
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(readableBackendError(error))),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.user;
    final isBackend = state.isBackendUser && user != null;
    final code = _serverCode ?? '';

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PremiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
            children: [
              const _FriendsHeader(),
              const SizedBox(height: 18),
              const _HeroCard(),
              const SizedBox(height: 12),
              _LeagueEntry(
                onTap: () => Navigator.pushNamed(context, '/league'),
              ),
              const SizedBox(height: 16),
              if (!isBackend)
                _GuestPrompt(
                    onTap: () => Navigator.pushNamed(context, '/login'))
              else ...[
                _InviteCard(code: code, name: user.name),
                const SizedBox(height: 12),
                _AddFriendField(
                  controller: _codeController,
                  busy: _adding,
                  onSubmit: _addFriend,
                ),
              ],
              const SizedBox(height: 24),
              Text(
                  state.tr(
                      ru: 'Мои друзья', kk: 'Менің достарым', en: 'My friends'),
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 21,
                      fontWeight: FontWeight.w900,
                      color: AppColors.navyDark)),
              const SizedBox(height: 12),
              ..._buildFriendsSection(isBackend),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildFriendsSection(bool isBackend) {
    if (isBackend && _loading && _friends.isEmpty) {
      return const [
        Padding(
          padding: EdgeInsets.symmetric(vertical: 40),
          child: Center(child: CircularProgressIndicator()),
        ),
      ];
    }
    if (isBackend && _loadError != null && _friends.isEmpty) {
      return [_LoadErrorCard(message: _loadError!, onRetry: _loadFriends)];
    }
    if (_friends.isEmpty) {
      return const [_EmptyFriends()];
    }
    return _friends
        .map((friend) => Padding(
              padding: const EdgeInsets.only(bottom: 10),
              child: _FriendTile(
                friend: friend,
                onRemove: () => _removeFriend(friend),
              ),
            ))
        .toList(growable: false);
  }
}
