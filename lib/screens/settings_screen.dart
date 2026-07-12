import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../services/app_state.dart';
import '../utils/colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Настройки',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const _SectionLabel('Язык'),
          const _SettingsTile(
            icon: Icons.language_rounded,
            label: 'Язык приложения',
            color: AppColors.pistachio,
            trailing: Text('Русский',
                style: TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textGrey)),
          ),
          const SizedBox(height: 12),
          const _SectionLabel('Аудио'),
          _SettingsTile(
            icon: Icons.volume_up_rounded,
            label: 'Аудио Корана',
            color: AppColors.pistachio,
            trailing: Switch(
                value: state.soundEnabled,
                onChanged: state.setSoundEnabled,
                activeThumbColor: AppColors.pistachio),
          ),
          const SizedBox(height: 12),
          const _SectionLabel('Аккаунт'),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Помощь',
            color: AppColors.textGrey,
            onTap: () => Navigator.pushNamed(context, '/help'),
          ),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            label: 'Удалить аккаунт',
            color: AppColors.error,
            onTap: () => _confirmDelete(context),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Удалить аккаунт?',
            style:
                TextStyle(fontFamily: 'Nunito', fontWeight: FontWeight.w800)),
        content: const Text(
            'Весь прогресс будет потерян. Это действие нельзя отменить.',
            style: TextStyle(fontFamily: 'Nunito')),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Отмена',
                  style: TextStyle(
                      fontFamily: 'Nunito', color: AppColors.pistachio))),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final state = context.read<AppState>();
              final deleted = await state.deleteAccount();
              if (context.mounted && deleted) {
                Navigator.pushReplacementNamed(context, '/carousel');
              } else if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(state.error ?? 'Не удалось удалить аккаунт'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            child: const Text('Удалить',
                style: TextStyle(fontFamily: 'Nunito', color: AppColors.error)),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(text,
          style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.textGrey)),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile(
      {required this.icon,
      required this.label,
      required this.color,
      this.trailing,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.border)),
      child: ListTile(
        onTap: onTap,
        leading: Container(
          width: 38,
          height: 38,
          decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10)),
          child: Icon(icon, color: color, size: 20),
        ),
        title: Text(label,
            style: const TextStyle(
                fontFamily: 'Nunito',
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark)),
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right_rounded,
                    color: AppColors.textGrey)
                : null),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
    );
  }
}

class HelpScreen extends StatelessWidget {
  const HelpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final faqs = [
      {
        'q': 'Как начать учёбу?',
        'a':
            'Нажми на любой урок на главном экране и следуй шагам. Каждый урок занимает 3-7 минут.'
      },
      {
        'q': 'Как работают жизни?',
        'a':
            'У тебя 5 жизней. Каждая ошибка забирает одну. Без жизней нужно ждать восстановления или купить muslingo+.'
      },
      {
        'q': 'Что такое страйк?',
        'a':
            'Страйк — дни учёбы подряд. Если ты занимаешься каждый день, страйк растёт. Не забывай заниматься!'
      },
      {
        'q': 'Как получить XP?',
        'a':
            'XP начисляется за уроки (+25), правильные ответы (+5) и повторение аятов (+2).'
      },
      {
        'q': 'Когда появится muslingo+?',
        'a':
            'Подписка откроется после подключения безопасной оплаты через App Store и Google Play.'
      },
    ];

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        title: const Text('Помощь',
            style: TextStyle(
                fontFamily: 'Nunito',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark)),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...faqs.map((f) => _FaqTile(question: f['q']!, answer: f['a']!)),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.pistachioLight.withValues(alpha: 0.4),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.pistachioLight),
            ),
            child: Column(
              children: [
                const Text('Не нашёл ответа?',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark)),
                const SizedBox(height: 8),
                const Text('Напиши нам — ответим в течение 24 часов',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 13,
                        color: AppColors.textGrey),
                    textAlign: TextAlign.center),
                const SizedBox(height: 12),
                ElevatedButton.icon(
                  onPressed: () async {
                    final uri = Uri(
                      scheme: 'mailto',
                      path: 'support@muslingo.app',
                      queryParameters: {'subject': 'Поддержка Muslingo'},
                    );
                    final opened = await launchUrl(uri);
                    if (!opened && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content:
                              Text('Не удалось открыть почтовое приложение'),
                          backgroundColor: AppColors.error,
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.email_outlined, size: 18),
                  label: const Text('Написать в поддержку',
                      style: TextStyle(
                          fontFamily: 'Nunito',
                          fontWeight: FontWeight.w700,
                          fontSize: 14)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.pistachio,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
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
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
            color: _open ? AppColors.pistachio : AppColors.border,
            width: _open ? 1.5 : 1),
      ),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: () => setState(() => _open = !_open),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  const Icon(Icons.help_outline_rounded,
                      color: AppColors.pistachio, size: 20),
                  const SizedBox(width: 10),
                  Expanded(
                      child: Text(widget.question,
                          style: const TextStyle(
                              fontFamily: 'Nunito',
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
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
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
              child: Text(widget.answer,
                  style: const TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 14,
                      color: AppColors.textGrey,
                      height: 1.5)),
            ),
        ],
      ),
    );
  }
}
