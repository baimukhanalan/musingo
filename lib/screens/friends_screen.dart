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

/// Экран «Друзья» — соревнование с реальными людьми взамен убранной лиги
/// с ботами. Для backend-пользователя это настоящая фича поверх сервера:
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

  /// Локальный аналог серверного кода: та же детерминированная функция (base32
  /// Crockford от первых 40 бит id), поэтому оффлайн-фолбэк совпадает с тем, что
  /// вернёт сервер. Арифметика через % и ~/ (не битовые операции) — чтобы
  /// значение шире 32 бит корректно считалось и в вебе.
  String _localFriendCode(String userId) {
    const alphabet = '0123456789ABCDEFGHJKMNPQRSTVWXYZ';
    final hex = userId.replaceAll('-', '').toLowerCase();
    if (hex.length < 10) return '';
    final parsed = int.tryParse(hex.substring(0, 10), radix: 16);
    if (parsed == null) return '';
    var value = parsed;
    final digits = List<String>.filled(8, '0');
    for (var i = 7; i >= 0; i -= 1) {
      digits[i] = alphabet[value % 32];
      value = value ~/ 32;
    }
    return digits.join();
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
      final friend = await (_backend ??= await BackendService.create()).addFriend(code);
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
      await (_backend ??= await BackendService.create()).removeFriend(friend.code);
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
    final isGuest = state.isGuest || user == null;
    final isBackend = state.isBackendUser && user != null;
    // Реальный код с сервера, а до/вместо него — детерминированный локальный.
    final code = isGuest ? '' : (_serverCode ?? _localFriendCode(user.id));

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
              const SizedBox(height: 16),
              if (isGuest)
                _GuestPrompt(onTap: () => Navigator.pushNamed(context, '/login'))
              else ...[
                _InviteCard(code: code, name: user.name),
                if (isBackend) ...[
                  const SizedBox(height: 12),
                  _AddFriendField(
                    controller: _codeController,
                    busy: _adding,
                    onSubmit: _addFriend,
                  ),
                ],
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

/// Шапка экрана: крупный navy-заголовок «Друзья» + языковые пилюли справа.
class _FriendsHeader extends StatelessWidget {
  const _FriendsHeader();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Text(state.tr(ru: 'Друзья', kk: 'Достар', en: 'Friends'),
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 30,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark)),
        ),
        const SizedBox(width: 12),
        const LanguagePills(),
      ],
    );
  }
}

/// Акцентная navy-градиентная карточка-приглашение к совместной учёбе.
class _HeroCard extends StatelessWidget {
  const _HeroCard();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.navyDark, AppColors.navy, AppColors.navyDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: AppColors.navy.withValues(alpha: 0.28),
            blurRadius: 26,
            offset: const Offset(0, 12),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 54,
            height: 54,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.groups_rounded,
                color: Colors.white, size: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                    state.tr(
                        ru: 'Учитесь вместе',
                        kk: 'Бірге үйреніңіз',
                        en: 'Learn together'),
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 19,
                        fontWeight: FontWeight.w900,
                        color: Colors.white)),
                const SizedBox(height: 5),
                Text(
                    state.tr(
                        ru: 'Пригласи друзей и соревнуйтесь по XP и страйку',
                        kk: 'Достарыңды шақырып, XP мен страйк бойынша жарысыңдар',
                        en: 'Invite friends and compete on XP and streak'),
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13.5,
                        fontWeight: FontWeight.w600,
                        color: Colors.white70,
                        height: 1.35)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GuestPrompt extends StatelessWidget {
  final VoidCallback onTap;
  const _GuestPrompt({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.sky.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.emoji_events_rounded,
                color: AppColors.navy, size: 30),
          ),
          const SizedBox(height: 14),
          Text(
              state.tr(
                  ru: 'Соревнование доступно с аккаунтом',
                  kk: 'Жарыс аккаунтпен қолжетімді',
                  en: 'Competition is available with an account'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark)),
          const SizedBox(height: 8),
          Text(
              state.tr(
                  ru: 'Создай аккаунт, чтобы получить код-приглашение, добавлять друзей '
                      'и сравнивать прогресс на любом устройстве.',
                  kk: 'Шақыру кодын алу, дос қосу және кез келген құрылғыда '
                      'прогресті салыстыру үшін аккаунт жаса.',
                  en: 'Create an account to get an invite code, add friends '
                      'and compare progress on any device.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                  height: 1.45)),
          const SizedBox(height: 18),
          PremiumButton(
            label: state.tr(
                ru: 'Создать аккаунт',
                kk: 'Аккаунт жасау',
                en: 'Create account'),
            icon: Icons.person_add_alt_1_rounded,
            onPressed: onTap,
          ),
        ],
      ),
    );
  }
}

class _InviteCard extends StatelessWidget {
  final String code;
  final String name;
  const _InviteCard({required this.code, required this.name});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionLabel(
              text: state.tr(
                  ru: 'Твой код-приглашение',
                  kk: 'Сенің шақыру кодың',
                  en: 'Your invite code')),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: AppColors.skyLight.withValues(alpha: 0.55),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.sky.withValues(alpha: 0.4)),
            ),
            child: Text(code,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 26,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 4,
                    color: AppColors.navyDark)),
          ),
          const SizedBox(height: 16),
          Builder(
            builder: (ctx) => PremiumButton(
              label: state.tr(
                  ru: 'Поделиться приглашением',
                  kk: 'Шақыруды бөлісу',
                  en: 'Share invitation'),
              icon: Icons.share_rounded,
              variant: PremiumButtonVariant.gold,
              onPressed: () async {
                await Clipboard.setData(ClipboardData(
                  text: state.tr(
                      ru: 'Учу Коран в Muslingo — присоединяйся и посоревнуемся! '
                          'Мой код-приглашение: $code',
                      kk: 'Muslingo-да Құран үйреніп жүрмін — қосыл, жарысайық! '
                          'Менің шақыру кодым: $code',
                      en: "I'm learning Quran on Muslingo — join and let's compete! "
                          'My invite code: $code'),
                ));
                if (!ctx.mounted) return;
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(
                      content: Text(state.tr(
                          ru: 'Приглашение скопировано — отправь другу',
                          kk: 'Шақыру көшірілді — досыңа жібер',
                          en: 'Invitation copied — send it to a friend'))),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

/// Поле ввода кода друга + кнопка «Добавить» (только для backend-пользователя).
class _AddFriendField extends StatelessWidget {
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSubmit;

  const _AddFriendField({
    required this.controller,
    required this.busy,
    required this.onSubmit,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: controller,
              textCapitalization: TextCapitalization.characters,
              maxLength: 12,
              onSubmitted: (_) => onSubmit(),
              decoration: InputDecoration(
                counterText: '',
                hintText: state.tr(
                    ru: 'Код друга',
                    kk: 'Достың коды',
                    en: "Friend's code"),
                hintStyle: const TextStyle(
                    fontFamily: 'Nunito', color: AppColors.textLight),
                border: InputBorder.none,
                isDense: true,
              ),
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                  color: AppColors.textDark),
            ),
          ),
          const SizedBox(width: 10),
          _AddButton(busy: busy, onSubmit: onSubmit),
        ],
      ),
    );
  }
}

/// Объёмная sky-кнопка «Добавить» с состоянием загрузки — под премиум-подачу,
/// но с busy-спиннером, которого нет у общего [PremiumButton].
class _AddButton extends StatelessWidget {
  final bool busy;
  final VoidCallback onSubmit;

  const _AddButton({required this.busy, required this.onSubmit});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return DecoratedBox(
      decoration: BoxDecoration(
        color: busy
            ? Color.lerp(AppColors.buttonDisabled, Colors.black, 0.18)
            : AppColors.navyDark.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
        boxShadow: busy
            ? null
            : [
                BoxShadow(
                  color: AppColors.sky.withValues(alpha: 0.4),
                  blurRadius: 18,
                  offset: const Offset(0, 8),
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.only(bottom: 3),
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: busy ? null : onSubmit,
            borderRadius: BorderRadius.circular(14),
            child: Ink(
              height: 46,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: busy
                      ? const [
                          AppColors.buttonDisabled,
                          AppColors.buttonDisabled
                        ]
                      : const [Color(0xFF5FC3EE), Color(0xFF3FA9DC)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  child: busy
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(
                          state.tr(ru: 'Добавить', kk: 'Қосу', en: 'Add'),
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: Colors.white)),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Карточка друга: аватар-инициал, имя, его XP и страйк, кнопка удалить.
class _FriendTile extends StatelessWidget {
  final Friend friend;
  final VoidCallback onRemove;

  const _FriendTile({required this.friend, required this.onRemove});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final trimmed = friend.displayName.trim();
    final initial = trimmed.isEmpty ? '?' : trimmed.substring(0, 1).toUpperCase();
    return PremiumCard(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      radius: 18,
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.skyLight,
                  AppColors.sky.withValues(alpha: 0.35),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Text(initial,
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 19,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark)),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(friend.displayName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark)),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _StatChip(
                      icon: Icons.bolt_rounded,
                      label: '${friend.xp} XP',
                      color: AppColors.gold,
                    ),
                    const SizedBox(width: 8),
                    _StatChip(
                      icon: Icons.local_fire_department_rounded,
                      label: '${friend.streak}',
                      color: AppColors.coral,
                    ),
                  ],
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRemove,
            icon: const Icon(Icons.person_remove_alt_1_rounded,
                color: AppColors.textLight, size: 22),
            tooltip: state.tr(
                ru: 'Удалить из друзей',
                kk: 'Достардан өшіру',
                en: 'Remove from friends'),
          ),
        ],
      ),
    );
  }
}

/// Маленький «пилюльный» чип статы друга (XP/страйк).
class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 4),
          Text(label,
              style: TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w800,
                  color: Color.lerp(color, AppColors.navyDark, 0.35))),
        ],
      ),
    );
  }
}

/// Ошибка загрузки списка друзей (обычно оффлайн). Код-приглашение при этом
/// всё равно показан из локального фолбэка, а список можно перезапросить.
class _LoadErrorCard extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _LoadErrorCard({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.textLight.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.cloud_off_rounded,
                color: AppColors.textGrey, size: 28),
          ),
          const SizedBox(height: 12),
          Text(message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                  height: 1.45)),
          const SizedBox(height: 14),
          TextButton(
            onPressed: onRetry,
            child: Text(
                state.tr(ru: 'Повторить', kk: 'Қайталау', en: 'Retry'),
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navy)),
          ),
        ],
      ),
    );
  }
}

class _EmptyFriends extends StatelessWidget {
  const _EmptyFriends();

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 20),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.sky.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.person_add_alt_1_rounded,
                color: AppColors.navy, size: 32),
          ),
          const SizedBox(height: 14),
          Text(
              state.tr(
                  ru: 'Пока никого', kk: 'Әзірге ешкім жоқ', en: 'No one yet'),
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 17,
                  fontWeight: FontWeight.w900,
                  color: AppColors.navyDark)),
          const SizedBox(height: 8),
          Text(
              state.tr(
                  ru: 'Пригласи друзей по коду выше. Когда они присоединятся, здесь '
                      'появится их прогресс, и вы сможете соревноваться.',
                  kk: 'Жоғарыдағы код арқылы достарыңды шақыр. Олар қосылғанда, '
                      'осында олардың прогресі пайда болып, жарыса аласыңдар.',
                  en: 'Invite friends with the code above. When they join, their '
                      'progress will appear here and you can compete.'),
              textAlign: TextAlign.center,
              style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 13.5,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textGrey,
                  height: 1.45)),
        ],
      ),
    );
  }
}
