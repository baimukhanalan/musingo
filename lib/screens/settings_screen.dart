import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_state.dart';
import '../services/app_install_service.dart';
import '../services/notification_service.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_label.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final showInstall = AppInstallService.isWebInstallExperience;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _ScreenHeader(
                  title: state.tr(
                      ru: 'Настройки', kk: 'Баптаулар', en: 'Settings')),
              const SizedBox(height: 20),

              SectionLabel(
                  text: state.tr(ru: 'Язык', kk: 'Тіл', en: 'Language')),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                _SettingsRow(
                  icon: Icons.language_rounded,
                  label: state.tr(
                      ru: 'Язык приложения',
                      kk: 'Қолданба тілі',
                      en: 'App language'),
                  color: AppColors.pistachio,
                  trailing: Text(state.nativeLanguage?.label ?? 'Русский',
                      style: const TextStyle(
                          fontFamily: 'Nunito',
                          fontSize: 14,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textGrey)),
                  onTap: () => _showLanguagePicker(context),
                ),
              ]),
              const SizedBox(height: 22),

              SectionLabel(
                  text: state.tr(ru: 'Аудио', kk: 'Аудио', en: 'Audio')),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                _SettingsRow(
                  icon: Icons.volume_up_rounded,
                  label: state.tr(
                      ru: 'Аудио Корана',
                      kk: 'Құран аудиосы',
                      en: 'Quran audio'),
                  color: AppColors.pistachio,
                  trailing: Switch(
                      value: state.soundEnabled,
                      onChanged: state.setSoundEnabled,
                      activeThumbColor: AppColors.pistachio),
                ),
              ]),
              const SizedBox(height: 22),

              if (showInstall) ...[
                SectionLabel(
                    text: state.tr(
                        ru: 'Приложение', kk: 'Қолданба', en: 'App')),
                const SizedBox(height: 10),
                _SettingsCard(children: [
                  _SettingsRow(
                    icon: Icons.install_mobile_rounded,
                    label: AppInstallService.isInstalled
                        ? state.tr(
                            ru: 'Приложение установлено',
                            kk: 'Қолданба орнатылды',
                            en: 'App installed')
                        : state.tr(
                            ru: 'Установить на устройство',
                            kk: 'Құрылғыға орнату',
                            en: 'Install on device'),
                    subtitle: AppInstallService.isInstalled
                        ? state.tr(
                            ru: 'Muslingo работает в полноэкранном режиме',
                            kk: 'Muslingo толық экран режимінде жұмыс істейді',
                            en: 'Muslingo runs in fullscreen mode')
                        : state.tr(
                            ru: 'Добавить иконку на главный экран',
                            kk: 'Негізгі экранға белгіше қосу',
                            en: 'Add an icon to your home screen'),
                    color: AppColors.navy,
                    onTap: () => Navigator.pushNamed(context, '/install'),
                  ),
                ]),
                const SizedBox(height: 22),
              ],

              SectionLabel(
                  text: state.tr(
                      ru: 'Напоминания',
                      kk: 'Еске салулар',
                      en: 'Reminders')),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                _SettingsRow(
                  icon: Icons.notifications_active_rounded,
                  label: state.tr(
                      ru: 'Ежедневный урок',
                      kk: 'Күнделікті сабақ',
                      en: 'Daily lesson'),
                  subtitle: _notificationSubtitle(state),
                  color: AppColors.coral,
                  trailing: Switch(
                    value: state.notificationsEnabled,
                    onChanged: (enabled) =>
                        _toggleNotifications(context, enabled),
                    activeThumbColor: AppColors.coral,
                  ),
                ),
                _SettingsRow(
                  icon: Icons.schedule_rounded,
                  label: state.tr(
                      ru: 'Время напоминания',
                      kk: 'Еске салу уақыты',
                      en: 'Reminder time'),
                  subtitle: state.tr(
                      ru: 'Каждый день по местному времени',
                      kk: 'Күн сайын жергілікті уақыт бойынша',
                      en: 'Every day in local time'),
                  color: AppColors.gold,
                  trailing: Text(
                    _formatTime(state.reminderHour, state.reminderMinute),
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: AppColors.textDark,
                    ),
                  ),
                  onTap: () => _pickReminderTime(context),
                ),
                _SettingsRow(
                  icon: Icons.mark_email_read_rounded,
                  label: state.tr(
                      ru: 'Проверить уведомление',
                      kk: 'Хабарламаны тексеру',
                      en: 'Test notification'),
                  subtitle: state.tr(
                      ru: 'Отправить тест прямо сейчас',
                      kk: 'Тестті қазір жіберу',
                      en: 'Send a test right now'),
                  color: AppColors.sky,
                  onTap: () => _sendTestNotification(context),
                ),
              ]),
              const SizedBox(height: 22),

              SectionLabel(
                  text: state.tr(
                      ru: 'Аккаунт', kk: 'Аккаунт', en: 'Account')),
              const SizedBox(height: 10),
              _SettingsCard(children: [
                _SettingsRow(
                  icon: Icons.help_outline_rounded,
                  label: state.tr(ru: 'Помощь', kk: 'Көмек', en: 'Help'),
                  color: AppColors.textGrey,
                  onTap: () => Navigator.pushNamed(context, '/help'),
                ),
                _SettingsRow(
                  icon: Icons.privacy_tip_outlined,
                  label: state.tr(
                      ru: 'Политика конфиденциальности',
                      kk: 'Құпиялылық саясаты',
                      en: 'Privacy Policy'),
                  color: AppColors.navy,
                  onTap: () => _openPrivacyPolicy(context),
                ),
                _SettingsRow(
                  icon: Icons.delete_outline_rounded,
                  label: state.tr(
                      ru: 'Удалить аккаунт',
                      kk: 'Аккаунтты жою',
                      en: 'Delete account'),
                  color: AppColors.error,
                  danger: true,
                  onTap: () => _confirmDelete(context),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  String _notificationSubtitle(AppState state) {
    if (state.notificationPermission == NotificationPermissionState.denied) {
      return state.tr(
          ru: 'Разрешение отключено в настройках устройства',
          kk: 'Рұқсат құрылғы баптауларында өшірілген',
          en: 'Permission is turned off in device settings');
    }
    if (!state.notificationsEnabled) {
      return state.tr(ru: 'Выключены', kk: 'Өшірулі', en: 'Off');
    }
    return state.notificationsRunInBackground
        ? state.tr(
            ru: 'Работают даже когда приложение закрыто',
            kk: 'Қолданба жабық кезде де жұмыс істейді',
            en: 'Work even when the app is closed')
        : state.tr(
            ru: 'Работают пока web-приложение открыто',
            kk: 'Веб-қолданба ашық тұрғанда жұмыс істейді',
            en: 'Work while the web app is open');
  }

  String _formatTime(int hour, int minute) =>
      '${hour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')}';

  Future<void> _toggleNotifications(
      BuildContext context, bool enabled) async {
    final state = context.read<AppState>();
    final success = await state.setNotificationsEnabled(enabled);
    if (!context.mounted || success || !enabled) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          state.tr(
              ru: 'Разреши уведомления в настройках браузера или телефона.',
              kk: 'Браузер немесе телефон баптауларында хабарламаларға рұқсат бер.',
              en: 'Allow notifications in your browser or phone settings.'),
        ),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _pickReminderTime(BuildContext context) async {
    final state = context.read<AppState>();
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: state.reminderHour,
        minute: state.reminderMinute,
      ),
      helpText: state.tr(
          ru: 'Когда напомнить об уроке?',
          kk: 'Сабақ туралы қашан еске салайын?',
          en: 'When should we remind you about the lesson?'),
      cancelText: state.tr(ru: 'Отмена', kk: 'Болдырмау', en: 'Cancel'),
      confirmText: state.tr(ru: 'Сохранить', kk: 'Сақтау', en: 'Save'),
    );
    if (selected == null || !context.mounted) return;
    await context
        .read<AppState>()
        .setReminderTime(selected.hour, selected.minute);
  }

  Future<void> _sendTestNotification(BuildContext context) async {
    final state = context.read<AppState>();
    final sent = await state.sendTestNotification();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(sent
            ? state.tr(
                ru: 'Тестовое уведомление отправлено.',
                kk: 'Тесттік хабарлама жіберілді.',
                en: 'Test notification sent.')
            : state.tr(
                ru: 'Не удалось показать уведомление. Проверь разрешение.',
                kk: 'Хабарламаны көрсету мүмкін болмады. Рұқсатты тексер.',
                en: 'Could not show the notification. Check the permission.')),
        backgroundColor: sent ? AppColors.success : AppColors.error,
      ),
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final state = context.read<AppState>();
    final uri = Uri.parse('https://muslingo-mobile.vercel.app/privacy');
    final opened =
        await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr(
              ru: 'Не удалось открыть политику конфиденциальности',
              kk: 'Құпиялылық саясатын ашу мүмкін болмады',
              en: 'Could not open the privacy policy')),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  void _confirmDelete(BuildContext context) {
    final state = context.read<AppState>();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
            state.tr(
                ru: 'Удалить аккаунт?',
                kk: 'Аккаунтты жою керек пе?',
                en: 'Delete account?'),
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontWeight: FontWeight.w900,
                fontSize: 20,
                color: AppColors.navyDark)),
        content: Text(
            state.tr(
                ru: 'Весь прогресс будет потерян. Это действие нельзя отменить.',
                kk: 'Барлық прогресс жоғалады. Бұл әрекетті кері қайтару мүмкін емес.',
                en: 'All progress will be lost. This action cannot be undone.'),
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
                height: 1.4)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(
                  state.tr(ru: 'Отмена', kk: 'Болдырмау', en: 'Cancel'),
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontWeight: FontWeight.w800,
                      color: AppColors.pistachio))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final deleted = await state.deleteAccount();
              if (context.mounted && deleted) {
                Navigator.pushReplacementNamed(context, '/onboarding');
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error ??
                        state.tr(
                            ru: 'Не удалось удалить аккаунт',
                            kk: 'Аккаунтты жою мүмкін болмады',
                            en: 'Could not delete the account')),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: Text(
                state.tr(ru: 'Удалить', kk: 'Жою', en: 'Delete'),
                style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontWeight: FontWeight.w800,
                    color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  Future<void> _showLanguagePicker(BuildContext context) async {
    final state = context.read<AppState>();
    final selected = await showModalBottomSheet<NativeLanguage>(
      context: context,
      backgroundColor: AppColors.white,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 4, 16),
                child: Text(
                    state.tr(
                        ru: 'Выбери язык подсказок',
                        kk: 'Көмекші тілін таңда',
                        en: 'Choose the hint language'),
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 20,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyDark)),
              ),
              _SettingsCard(
                children: [
                  for (final language in NativeLanguage.values)
                    _SettingsRow(
                      icon: language == state.nativeLanguage
                          ? Icons.check_circle_rounded
                          : Icons.language_rounded,
                      label: language.label,
                      color: language == state.nativeLanguage
                          ? AppColors.pistachio
                          : AppColors.textGrey,
                      trailing: language == state.nativeLanguage
                          ? const Icon(Icons.check_rounded,
                              color: AppColors.pistachio, size: 22)
                          : const SizedBox.shrink(),
                      onTap: () => Navigator.pop(sheetContext, language),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (selected == null || !context.mounted) return;
    await context.read<AppState>().setNativeLanguage(selected);
  }
}

/// Back button + large navy heading, matching the premium screen signature.
class _ScreenHeader extends StatelessWidget {
  final String title;
  const _ScreenHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (Navigator.of(context).canPop())
          _CircleIconButton(
            icon: Icons.arrow_back_ios_new_rounded,
            onTap: () => Navigator.of(context).maybePop(),
          ),
        if (Navigator.of(context).canPop()) const SizedBox(height: 14),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 30,
            fontWeight: FontWeight.w900,
            color: AppColors.navyDark,
          ),
        ),
      ],
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _CircleIconButton({required this.icon, required this.onTap});

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
        child: Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.navyDark.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Icon(icon, size: 18, color: AppColors.navyDark),
        ),
      ),
    );
  }
}

/// White premium card that hosts a vertical list of [_SettingsRow]s,
/// separated by soft inset dividers.
class _SettingsCard extends StatelessWidget {
  final List<Widget> children;
  const _SettingsCard({required this.children});

  @override
  Widget build(BuildContext context) {
    final rows = <Widget>[];
    for (var i = 0; i < children.length; i++) {
      rows.add(children[i]);
      if (i != children.length - 1) {
        rows.add(const Padding(
          padding: EdgeInsets.only(left: 62),
          child: Divider(height: 1, thickness: 1, color: AppColors.border),
        ));
      }
    }
    return PremiumCard(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Column(children: rows),
    );
  }
}

class _SettingsRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool danger;

  const _SettingsRow({
    required this.icon,
    required this.label,
    this.subtitle,
    required this.color,
    this.trailing,
    this.onTap,
    this.danger = false,
  });

  @override
  Widget build(BuildContext context) {
    final row = Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w800,
                    color: danger ? AppColors.error : AppColors.textDark,
                  ),
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 3),
                  Text(
                    subtitle!,
                    style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 12.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textGrey,
                      height: 1.3,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(width: 10),
          trailing ??
              (onTap != null
                  ? const Icon(Icons.chevron_right_rounded,
                      color: AppColors.textLight, size: 24)
                  : const SizedBox.shrink()),
        ],
      ),
    );

    if (onTap == null) return row;

    return Material(
      type: MaterialType.transparency,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: row,
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final faqs = [
      {
        'q': state.tr(
            ru: 'Как начать учёбу?',
            kk: 'Оқуды қалай бастаймын?',
            en: 'How do I start learning?'),
        'a': state.tr(
            ru: 'Нажми на любой урок на главном экране и следуй шагам. Каждый урок занимает 3-7 минут.',
            kk: 'Негізгі экрандағы кез келген сабақты басып, қадамдарды орында. Әр сабақ 3-7 минут алады.',
            en: 'Tap any lesson on the home screen and follow the steps. Each lesson takes 3-7 minutes.')
      },
      {
        'q': state.tr(
            ru: 'Как работают жизни?',
            kk: 'Жандар қалай жұмыс істейді?',
            en: 'How do lives work?'),
        'a': state.tr(
            ru: 'У тебя 5 жизней. Каждая ошибка забирает одну. Без жизней нужно ждать восстановления или купить muslingo+.',
            kk: 'Сенде 5 жан бар. Әр қате біреуін алады. Жансыз қалғанда қалпына келуін күту немесе muslingo+ сатып алу керек.',
            en: 'You have 5 lives. Each mistake takes one. With no lives, wait for them to recover or get muslingo+.')
      },
      {
        'q': state.tr(
            ru: 'Что такое страйк?',
            kk: 'Страйк дегеніміз не?',
            en: 'What is a streak?'),
        'a': state.tr(
            ru: 'Страйк — дни учёбы подряд. Если ты занимаешься каждый день, страйк растёт. Не забывай заниматься!',
            kk: 'Страйк — қатарынан оқыған күндер. Күн сайын оқысаң, страйк өседі. Оқуды ұмытпа!',
            en: 'A streak is your run of consecutive study days. Study every day and it grows. Do not forget to practice!')
      },
      {
        'q': state.tr(
            ru: 'Как получить XP?',
            kk: 'XP-ны қалай аламын?',
            en: 'How do I earn XP?'),
        'a': state.tr(
            ru: 'XP начисляется за уроки (+25), правильные ответы (+5) и повторение аятов (+2).',
            kk: 'XP сабақтар (+25), дұрыс жауаптар (+5) және аяттарды қайталау (+2) үшін беріледі.',
            en: 'XP is awarded for lessons (+25), correct answers (+5), and reviewing ayahs (+2).')
      },
      {
        'q': state.tr(
            ru: 'Когда появится muslingo+?',
            kk: 'muslingo+ қашан шығады?',
            en: 'When will muslingo+ arrive?'),
        'a': state.tr(
            ru: 'Подписка откроется после подключения безопасной оплаты через App Store и Google Play.',
            kk: 'Жазылым App Store және Google Play арқылы қауіпсіз төлем қосылғаннан кейін ашылады.',
            en: 'The subscription will open once secure payments through the App Store and Google Play are connected.')
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
            children: [
              _ScreenHeader(
                  title: state.tr(ru: 'Помощь', kk: 'Көмек', en: 'Help')),
              const SizedBox(height: 20),
              ...faqs.map((f) => _FaqTile(question: f['q']!, answer: f['a']!)),
              const SizedBox(height: 12),
              PremiumCard(
                color: AppColors.skyLight.withValues(alpha: 0.55),
                child: Column(
                  children: [
                    Text(
                        state.tr(
                            ru: 'Не нашёл ответа?',
                            kk: 'Жауап таппадың ба?',
                            en: 'Did not find an answer?'),
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 17,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navyDark)),
                    const SizedBox(height: 8),
                    Text(
                        state.tr(
                            ru: 'Напиши нам — ответим в течение 24 часов',
                            kk: 'Бізге жаз — 24 сағат ішінде жауап береміз',
                            en: 'Write to us — we reply within 24 hours'),
                        style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 13.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textGrey,
                            height: 1.35),
                        textAlign: TextAlign.center),
                    const SizedBox(height: 16),
                    _SupportButton(
                      onPressed: () async {
                        final uri = Uri(
                          scheme: 'mailto',
                          path: 'support@muslingo.app',
                          queryParameters: {'subject': 'Поддержка Muslingo'},
                        );
                        final opened = await launchUrl(uri);
                        if (!opened && context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(state.tr(
                                  ru: 'Не удалось открыть почтовое приложение',
                                  kk: 'Пошта қолданбасын ашу мүмкін болмады',
                                  en: 'Could not open the mail app')),
                              backgroundColor: AppColors.error,
                            ),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Volumetric sky support button (self-contained so it can carry the async
/// mailto handler as an onPressed callback).
class _SupportButton extends StatelessWidget {
  final VoidCallback onPressed;
  const _SupportButton({required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return SizedBox(
      width: double.infinity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: AppColors.navyDark.withValues(alpha: 0.55),
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: AppColors.sky.withValues(alpha: 0.4),
              blurRadius: 26,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              borderRadius: BorderRadius.circular(14),
              child: Ink(
                height: 52,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF5FC3EE), Color(0xFF3FA9DC)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.email_outlined,
                          size: 19, color: AppColors.white),
                      const SizedBox(width: 8),
                      Text(
                          state.tr(
                              ru: 'Написать в поддержку',
                              kk: 'Қолдау қызметіне жазу',
                              en: 'Contact support'),
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontWeight: FontWeight.w900,
                              fontSize: 15,
                              color: AppColors.white)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _FaqTile extends StatefulWidget {
  final String question;
  final String answer;

  const _FaqTile({required this.question, required this.answer});

  @override
  State<_FaqTile> createState() => _FaqTileState();
}

class _FaqTileState extends State<_FaqTile> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.05),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
        border: _open
            ? Border.all(color: AppColors.pistachio, width: 1.5)
            : null,
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(18),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: AppColors.pistachio.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.help_outline_rounded,
                        color: AppColors.pistachio, size: 19),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                      child: Text(widget.question,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark))),
                  Icon(
                      _open
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      color: AppColors.pistachio),
                ],
              ),
            ),
          ),
          if (_open)
            Padding(
              padding: const EdgeInsets.fromLTRB(62, 0, 16, 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(widget.answer,
                    style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textGrey,
                        height: 1.5)),
              ),
            ),
        ],
      ),
    );
  }
}
