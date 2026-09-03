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

part 'settings/settings_components.dart';
part 'settings/help_screen.dart';

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
                    text:
                        state.tr(ru: 'Приложение', kk: 'Қолданба', en: 'App')),
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
                    onTap: () {
                      ScaffoldMessenger.of(context).clearSnackBars();
                      Navigator.pushNamed(context, '/install');
                    },
                  ),
                ]),
                const SizedBox(height: 22),
              ],
              SectionLabel(
                  text: state.tr(
                      ru: 'Напоминания', kk: 'Еске салулар', en: 'Reminders')),
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
                if (state.nativeNotificationSurfacesSupported)
                  _SettingsRow(
                    icon: Icons.auto_awesome_rounded,
                    label: state.tr(
                        ru: 'Аят дня', kk: 'Күн аяты', en: 'Ayah of the day'),
                    subtitle: state.dailyAyahNotificationsEnabled
                        ? state.tr(
                            ru:
                                'Каждое утро в ${_formatTime(state.dailyAyahHour, state.dailyAyahMinute)}',
                            kk:
                                'Күн сайын таңертең ${_formatTime(state.dailyAyahHour, state.dailyAyahMinute)}',
                            en:
                                'Every morning at ${_formatTime(state.dailyAyahHour, state.dailyAyahMinute)}')
                        : state.tr(
                            ru: 'Отдельное уведомление с аятом и переводом',
                            kk: 'Аят пен аудармасы бар бөлек хабарлама',
                            en: 'A separate notification with an ayah'),
                    color: AppColors.pistachio,
                    trailing: Switch(
                      value: state.dailyAyahNotificationsEnabled,
                      onChanged: (enabled) =>
                          _toggleDailyAyahNotifications(context, enabled),
                      activeThumbColor: AppColors.pistachio,
                    ),
                  ),
                if (state.nativeNotificationSurfacesSupported &&
                    state.dailyAyahNotificationsEnabled)
                  _SettingsRow(
                    icon: Icons.wb_sunny_outlined,
                    label: state.tr(
                        ru: 'Время аята дня',
                        kk: 'Күн аятының уақыты',
                        en: 'Ayah notification time'),
                    subtitle: state.tr(
                        ru: 'По местному времени устройства',
                        kk: 'Құрылғының жергілікті уақытымен',
                        en: 'Uses the device local time'),
                    color: AppColors.gold,
                    trailing: Text(
                      _formatTime(state.dailyAyahHour, state.dailyAyahMinute),
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.textDark,
                      ),
                    ),
                    onTap: () => _pickDailyAyahTime(context),
                  ),
                if (state.nativeNotificationSurfacesSupported)
                  _SettingsRow(
                    icon: Icons.lock_outline_rounded,
                    label: state.tr(
                        ru: 'Текст на экране блокировки',
                        kk: 'Құлып экранындағы мәтін',
                        en: 'Lock screen preview'),
                    subtitle: state.tr(
                        ru: 'Показывать аят и детали напоминаний',
                        kk: 'Аят пен еске салу мәліметтерін көрсету',
                        en: 'Show the ayah and reminder details'),
                    color: AppColors.navy,
                    trailing: Switch(
                      value: state.lockScreenPreviewEnabled,
                      onChanged: state.notificationsEnabled
                          ? state.setLockScreenPreviewEnabled
                          : null,
                      activeThumbColor: AppColors.navy,
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
              if (state.homeWidgetSupported) ...[
                SectionLabel(
                    text: state.tr(
                        ru: 'Виджет', kk: 'Виджет', en: 'Home widget')),
                const SizedBox(height: 10),
                _SettingsCard(children: [
                  _SettingsRow(
                    icon: Icons.widgets_outlined,
                    label: state.tr(
                        ru: 'Аят дня на главном экране',
                        kk: 'Басты экрандағы күн аяты',
                        en: 'Ayah on the home screen'),
                    subtitle: state.homeWidgetEnabled
                        ? state.tr(
                            ru: 'Меняется автоматически каждый день',
                            kk: 'Күн сайын автоматты түрде өзгереді',
                            en: 'Updates automatically every day')
                        : state.tr(
                            ru: 'Хранит данные только на устройстве',
                            kk: 'Деректер тек құрылғыда сақталады',
                            en: 'Keeps its data only on this device'),
                    color: AppColors.sky,
                    trailing: Switch(
                      value: state.homeWidgetEnabled,
                      onChanged: (enabled) =>
                          _toggleHomeWidget(context, enabled),
                      activeThumbColor: AppColors.sky,
                    ),
                  ),
                  _SettingsRow(
                    icon: Icons.add_to_home_screen_rounded,
                    label: state.tr(
                        ru: 'Добавить виджет',
                        kk: 'Виджетті қосу',
                        en: 'Add widget'),
                    subtitle: state.tr(
                        ru: 'Закрепить через системное меню телефона',
                        kk: 'Телефонның жүйелік мәзірі арқылы бекіту',
                        en: 'Pin it from your phone widget menu'),
                    color: AppColors.pistachio,
                    onTap: () => _addHomeWidget(context),
                  ),
                ]),
                const SizedBox(height: 22),
              ],
              SectionLabel(
                  text: state.tr(ru: 'Аккаунт', kk: 'Аккаунт', en: 'Account')),
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
                  label: state.isGuest
                      ? state.tr(
                          ru: 'Сбросить прогресс',
                          kk: 'Прогресті өшіру',
                          en: 'Reset progress')
                      : state.tr(
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

  Future<void> _toggleNotifications(BuildContext context, bool enabled) async {
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

  Future<void> _toggleDailyAyahNotifications(
    BuildContext context,
    bool enabled,
  ) async {
    final state = context.read<AppState>();
    final success = await state.setDailyAyahNotificationsEnabled(enabled);
    if (!context.mounted || success || !enabled) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.tr(
          ru: 'Разреши уведомления, чтобы получать аят дня.',
          kk: 'Күн аятын алу үшін хабарламаларға рұқсат бер.',
          en: 'Allow notifications to receive the ayah of the day.',
        )),
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

  Future<void> _pickDailyAyahTime(BuildContext context) async {
    final state = context.read<AppState>();
    final selected = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(
        hour: state.dailyAyahHour,
        minute: state.dailyAyahMinute,
      ),
      helpText: state.tr(
          ru: 'Когда показать аят дня?',
          kk: 'Күн аятын қашан көрсету керек?',
          en: 'When should the daily ayah appear?'),
      cancelText: state.tr(ru: 'Отмена', kk: 'Болдырмау', en: 'Cancel'),
      confirmText: state.tr(ru: 'Сохранить', kk: 'Сақтау', en: 'Save'),
    );
    if (selected == null || !context.mounted) return;
    await context
        .read<AppState>()
        .setDailyAyahTime(selected.hour, selected.minute);
  }

  Future<void> _toggleHomeWidget(
    BuildContext context,
    bool enabled,
  ) async {
    final state = context.read<AppState>();
    final success = await state.setHomeWidgetEnabled(enabled);
    if (!context.mounted || success) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.tr(
          ru: 'Не удалось обновить системный виджет.',
          kk: 'Жүйелік виджетті жаңарту мүмкін болмады.',
          en: 'Could not update the system widget.',
        )),
        backgroundColor: AppColors.error,
      ),
    );
  }

  Future<void> _addHomeWidget(BuildContext context) async {
    final state = context.read<AppState>();
    final pinned = await state.requestHomeWidget();
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(pinned
            ? state.tr(
                ru: 'Открыт системный запрос на добавление виджета.',
                kk: 'Виджетті қосуға арналған жүйелік сұрау ашылды.',
                en: 'The system request to add the widget is open.')
            : state.tr(
                ru: 'Данные готовы. Зажми пустое место на главном экране, открой «Виджеты» и выбери Muslingo.',
                kk: 'Деректер дайын. Басты экрандағы бос орынды басып тұрып, «Виджеттер» бөлімінен Muslingo таңда.',
                en: 'The widget is ready. Touch and hold the home screen, open Widgets, and choose Muslingo.')),
        backgroundColor: pinned ? AppColors.success : AppColors.navy,
      ),
    );
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
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
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
    final isGuest = state.isGuest;
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
        title: Text(
            isGuest
                ? state.tr(
                    ru: 'Сбросить прогресс?',
                    kk: 'Прогресті өшіру керек пе?',
                    en: 'Reset progress?')
                : state.tr(
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
                ru: isGuest
                    ? 'Локальный прогресс на этом устройстве будет удалён. Это действие нельзя отменить.'
                    : 'Аккаунт и весь прогресс будут удалены. Это действие нельзя отменить.',
                kk: isGuest
                    ? 'Осы құрылғыдағы жергілікті прогресс өшіріледі. Бұл әрекетті кері қайтару мүмкін емес.'
                    : 'Аккаунт пен барлық прогресс өшіріледі. Бұл әрекетті кері қайтару мүмкін емес.',
                en: isGuest
                    ? 'Local progress on this device will be removed. This action cannot be undone.'
                    : 'The account and all progress will be deleted. This action cannot be undone.'),
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 14.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textGrey,
                height: 1.4)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: Text(state.tr(ru: 'Отмена', kk: 'Болдырмау', en: 'Cancel'),
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
                isGuest
                    ? state.tr(ru: 'Сбросить', kk: 'Өшіру', en: 'Reset')
                    : state.tr(ru: 'Удалить', kk: 'Жою', en: 'Delete'),
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
