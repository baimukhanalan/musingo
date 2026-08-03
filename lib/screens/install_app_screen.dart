import 'package:flutter/material.dart';

import '../services/app_install_service.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/custom_button.dart';

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

    if (result == AppInstallResult.installed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Muslingo добавлен на устройство'),
          backgroundColor: AppColors.success,
        ),
      );
    } else if (result == AppInstallResult.unavailable) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Открой меню браузера и выбери «Установить приложение» или «На экран Домой».',
          ),
          backgroundColor: AppColors.navy,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final installed = AppInstallService.isInstalled;
    final iosInstructions =
        _showIosInstructions || AppInstallService.needsIosInstructions;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text(
          'Установить Muslingo',
          style: TextStyle(
            fontFamily: 'Nunito',
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 18, 24, 32),
          children: [
            const CatCharacter(mood: CatMood.greet, size: 150),
            const SizedBox(height: 12),
            Text(
              installed
                  ? 'Muslingo уже установлен'
                  : 'Учись как в обычном приложении',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 25,
                fontWeight: FontWeight.w900,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Иконка появится на главном экране. Прогресс останется на устройстве, а уроки будут открываться без панели браузера.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                height: 1.45,
                color: AppColors.textGrey,
              ),
            ),
            const SizedBox(height: 24),
            const _Benefit(
              icon: Icons.phone_iphone_rounded,
              title: 'Иконка на экране',
              subtitle: 'Muslingo запускается одним нажатием.',
            ),
            const _Benefit(
              icon: Icons.fullscreen_rounded,
              title: 'Полноэкранный режим',
              subtitle: 'Ничего не отвлекает от ежедневного урока.',
            ),
            const _Benefit(
              icon: Icons.offline_bolt_rounded,
              title: 'Быстрый запуск',
              subtitle: 'Основные файлы приложения сохраняются на устройстве.',
            ),
            if (iosInstructions) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.skyLight,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.sky),
                ),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'На iPhone и iPad',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navy,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '1. Открой ссылку в Safari.\n2. Нажми «Поделиться».\n3. Выбери «На экран Домой».\n4. Нажми «Добавить».',
                      style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 14,
                        height: 1.5,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 24),
            if (!installed)
              CustomButton(
                text: _installing ? 'Подготовка...' : 'Установить приложение',
                onPressed: _installing ? null : _install,
              ),
            if (installed)
              CustomButton(
                text: 'Готово',
                onPressed: () => Navigator.pop(context),
              ),
          ],
        ),
      ),
    );
  }
}

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const _Benefit({
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: AppColors.skyLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: AppColors.navy),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textDark,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 13,
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
