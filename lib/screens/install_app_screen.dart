import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_install_service.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';
import '../widgets/premium_card.dart';
import '../widgets/section_label.dart';

class InstallAppScreen extends StatefulWidget {
  const InstallAppScreen({super.key});

  @override
  State<InstallAppScreen> createState() => _InstallAppScreenState();
}

class _InstallAppScreenState extends State<InstallAppScreen> {
  bool _installing = false;
  bool _showIosInstructions = false;

  Future<void> _install() async {
    setState(() => _installing = true);
    final result = await AppInstallService.install();
    if (!mounted) return;
    setState(() {
      _installing = false;
      _showIosInstructions =
          result == AppInstallResult.instructionsRequired;
    });

    final state = context.read<AppState>();
    if (result == AppInstallResult.installed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.tr(
              ru: 'Muslingo добавлен на устройство',
              kk: 'Muslingo құрылғыға қосылды',
              en: 'Muslingo added to your device')),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (result == AppInstallResult.unavailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            state.tr(
                ru: 'Открой меню браузера и выбери «Установить приложение» или «На экран Домой».',
                kk: 'Браузер мәзірін ашып, «Қолданбаны орнату» немесе «Негізгі экранға» дегенді таңда.',
                en: 'Open the browser menu and choose "Install app" or "Add to Home Screen".'),
          ),
          backgroundColor: AppColors.navy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final installed = AppInstallService.isInstalled;
    final iosInstructions =
        _showIosInstructions || AppInstallService.needsIosInstructions;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _TopBar(
                onBack: () => Navigator.pop(context),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.fromLTRB(20, 6, 20, 28),
                  children: [
                    // Маскот в мягком круге-глоу.
                    Center(
                      child: Container(
                        width: 168,
                        height: 168,
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              Color(0x3362C5EE),
                              Color(0x0062C5EE),
                            ],
                          ),
                        ),
                        alignment: Alignment.center,
                        child: const CatCharacter(
                          mood: CatMood.greet,
                          size: 138,
                        ),
                      ),
                    ),
                    const SizedBox(height: 14),
                    Center(
                      child: SectionLabel(
                          text: state.tr(
                              ru: 'Приложение на устройстве',
                              kk: 'Құрылғыдағы қолданба',
                              en: 'App on your device')),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      installed
                          ? state.tr(
                              ru: 'Muslingo уже установлен',
                              kk: 'Muslingo орнатылған',
                              en: 'Muslingo is already installed')
                          : state.tr(
                              ru: 'Учись как в обычном приложении',
                              kk: 'Кәдімгі қолданбадай үйрен',
                              en: 'Learn like in a regular app'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 27,
                        fontWeight: FontWeight.w900,
                        height: 1.15,
                        color: AppColors.navyDark,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      state.tr(
                          ru: 'Иконка появится на главном экране. Прогресс останется на устройстве, а уроки будут открываться без панели браузера.',
                          kk: 'Белгіше негізгі экранда пайда болады. Прогресс құрылғыда сақталады, ал сабақтар браузер панелінсіз ашылады.',
                          en: 'The icon will appear on your home screen. Your progress stays on the device, and lessons open without the browser bar.'),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        height: 1.5,
                        color: AppColors.textGrey,
                      ),
                    ),
                    const SizedBox(height: 22),
                    PremiumCard(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SectionLabel(
                              text: state.tr(
                                  ru: 'Почему стоит установить',
                                  kk: 'Неге орнатқан жөн',
                                  en: 'Why install it')),
                          const SizedBox(height: 16),
                          _Benefit(
                            icon: Icons.phone_iphone_rounded,
                            title: state.tr(
                                ru: 'Иконка на экране',
                                kk: 'Экрандағы белгіше',
                                en: 'Icon on your screen'),
                            subtitle: state.tr(
                                ru: 'Muslingo запускается одним нажатием.',
                                kk: 'Muslingo бір рет басқанда ашылады.',
                                en: 'Muslingo launches with a single tap.'),
                          ),
                          _Benefit(
                            icon: Icons.fullscreen_rounded,
                            title: state.tr(
                                ru: 'Полноэкранный режим',
                                kk: 'Толық экран режимі',
                                en: 'Full-screen mode'),
                            subtitle: state.tr(
                                ru: 'Ничего не отвлекает от ежедневного урока.',
                                kk: 'Күнделікті сабақтан ештеңе алаңдатпайды.',
                                en: 'Nothing distracts you from the daily lesson.'),
                          ),
                          _Benefit(
                            icon: Icons.offline_bolt_rounded,
                            title: state.tr(
                                ru: 'Быстрый запуск',
                                kk: 'Жылдам іске қосу',
                                en: 'Fast launch'),
                            subtitle: state.tr(
                                ru: 'Основные файлы приложения сохраняются на устройстве.',
                                kk: 'Қолданбаның негізгі файлдары құрылғыда сақталады.',
                                en: "The app's core files are stored on the device."),
                            last: true,
                          ),
                        ],
                      ),
                    ),
                    if (iosInstructions) ...[
                      const SizedBox(height: 14),
                      PremiumCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SectionLabel(
                                text: state.tr(
                                    ru: 'На iPhone и iPad',
                                    kk: 'iPhone және iPad-та',
                                    en: 'On iPhone and iPad')),
                            const SizedBox(height: 12),
                            _iosStep(
                              1,
                              state.tr(
                                  ru: 'Открой ссылку в Safari.',
                                  kk: 'Сілтемені Safari-де аш.',
                                  en: 'Open the link in Safari.'),
                            ),
                            _iosStep(
                              2,
                              state.tr(
                                  ru: 'Нажми «Поделиться».',
                                  kk: '«Бөлісу» түймесін бас.',
                                  en: 'Tap "Share".'),
                            ),
                            _iosStep(
                              3,
                              state.tr(
                                  ru: 'Выбери «На экран Домой».',
                                  kk: '«Негізгі экранға» дегенді таңда.',
                                  en: 'Choose "Add to Home Screen".'),
                            ),
                            _iosStep(
                              4,
                              state.tr(
                                  ru: 'Нажми «Добавить».',
                                  kk: '«Қосу» түймесін бас.',
                                  en: 'Tap "Add".'),
                              last: true,
                            ),
                          ],
                        ),
                      ),
                    ],
                    const SizedBox(height: 26),
                    if (!installed)
                      PremiumButton(
                        label: _installing
                            ? state.tr(
                                ru: 'Подготовка...',
                                kk: 'Дайындалуда...',
                                en: 'Preparing...')
                            : state.tr(
                                ru: 'Установить приложение',
                                kk: 'Қолданбаны орнату',
                                en: 'Install app'),
                        icon: Icons.download_rounded,
                        onPressed: _installing ? null : _install,
                      ),
                    if (installed)
                      PremiumButton(
                        label: state.tr(
                            ru: 'Готово', kk: 'Дайын', en: 'Done'),
                        icon: Icons.check_rounded,
                        onPressed: () => Navigator.pop(context),
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

  static Widget _iosStep(int number, String text, {bool last = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: AppColors.navyDark,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$number',
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.white,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(top: 3),
              child: Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 14.5,
                  fontWeight: FontWeight.w600,
                  height: 1.35,
                  color: AppColors.textDark,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _TopBar extends StatelessWidget {
  final VoidCallback onBack;

  const _TopBar({required this.onBack});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 20, 4),
      child: Row(
        children: [
          _CircleIconButton(
            icon: Icons.arrow_back_rounded,
            onTap: onBack,
            tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              state.tr(
                  ru: 'Установить Muslingo',
                  kk: 'Muslingo орнату',
                  en: 'Install Muslingo'),
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 19,
                fontWeight: FontWeight.w900,
                color: AppColors.navyDark,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String tooltip;

  const _CircleIconButton({
    required this.icon,
    required this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.white,
      shape: const CircleBorder(),
      elevation: 0,
      shadowColor: AppColors.navyDark.withValues(alpha: 0.12),
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: Tooltip(
          message: tooltip,
          child: SizedBox(
            width: 42,
            height: 42,
            child: Icon(icon, size: 22, color: AppColors.navyDark),
          ),
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool last;

  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
    this.last = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: last ? 12 : 18),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.skyLight,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(icon, color: AppColors.navy),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15.5,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    height: 1.3,
                    color: AppColors.textGrey,
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
