import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../services/backend_service.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';

class ForgotPasswordScreen extends StatefulWidget {
  final String initialEmail;

  const ForgotPasswordScreen({super.key, this.initialEmail = ''});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  late final TextEditingController _email;
  bool _loading = false;
  String? _message;

  @override
  void initState() {
    super.initState();
    _email = TextEditingController(text: widget.initialEmail);
  }

  @override
  void dispose() {
    _email.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (!_email.text.contains('@')) {
      setState(() => _message = 'Укажи корректный email.');
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final result =
          await context.read<AppState>().requestPasswordReset(_email.text);
      if (!mounted) return;
      setState(() {
        _message = result.canDeliver
            ? 'Если аккаунт существует и email подтверждён, ссылка уже отправлена.'
            : 'Запрос принят, но отправка писем пока не настроена администратором.';
      });
    } catch (error) {
      if (mounted) setState(() => _message = readableBackendError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _EmailActionScaffold(
        title: 'Восстановить пароль',
        subtitle:
            'Мы отправим одноразовую ссылку только на подтверждённый email.',
        children: [
          TextField(
            key: const Key('forgot-email-field'),
            controller: _email,
            keyboardType: TextInputType.emailAddress,
            autofillHints: const [AutofillHints.email],
            decoration: const InputDecoration(
              labelText: 'Email',
              prefixIcon: Icon(Icons.email_outlined),
            ),
          ),
          const SizedBox(height: 18),
          PremiumButton(
            label: 'Отправить ссылку',
            onPressed: _loading ? null : _send,
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!, key: const Key('forgot-result-message')),
          ],
        ],
      );
}

class ResetPasswordScreen extends StatefulWidget {
  final String token;

  const ResetPasswordScreen({super.key, required this.token});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _password = TextEditingController();
  final _confirmation = TextEditingController();
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _password.dispose();
    _confirmation.dispose();
    super.dispose();
  }

  Future<void> _reset() async {
    if (widget.token.length < 40) {
      setState(() => _message = 'Ссылка неполная или повреждена.');
      return;
    }
    if (_password.text.length < 8 || _password.text != _confirmation.text) {
      setState(() => _message =
          'Пароли должны совпадать и содержать не менее 8 символов.');
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await context
          .read<AppState>()
          .resetPassword(widget.token, _password.text);
      if (!mounted) return;
      setState(() => _message = 'Пароль изменён. Теперь можно войти.');
    } catch (error) {
      if (mounted) setState(() => _message = readableBackendError(error));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => _EmailActionScaffold(
        title: 'Новый пароль',
        subtitle:
            'Ссылка одноразовая. После смены пароля старые сессии завершатся.',
        children: [
          TextField(
            key: const Key('reset-password-field'),
            controller: _password,
            obscureText: true,
            autofillHints: const [AutofillHints.newPassword],
            decoration: const InputDecoration(labelText: 'Новый пароль'),
          ),
          const SizedBox(height: 12),
          TextField(
            key: const Key('reset-confirm-field'),
            controller: _confirmation,
            obscureText: true,
            decoration: const InputDecoration(labelText: 'Повтори пароль'),
          ),
          const SizedBox(height: 18),
          PremiumButton(
            label: 'Изменить пароль',
            onPressed: _loading ? null : _reset,
          ),
          if (_message != null) ...[
            const SizedBox(height: 16),
            Text(_message!, key: const Key('reset-result-message')),
          ],
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
            child: const Text('Перейти ко входу'),
          ),
        ],
      );
}

class VerifyEmailScreen extends StatefulWidget {
  final String token;

  const VerifyEmailScreen({super.key, required this.token});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _loading = true;
  String _message = 'Подтверждаем email...';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _confirm());
  }

  Future<void> _confirm() async {
    if (widget.token.length < 40) {
      setState(() {
        _loading = false;
        _message = 'Ссылка неполная или повреждена.';
      });
      return;
    }
    try {
      await context.read<AppState>().confirmEmailVerification(widget.token);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = 'Email подтверждён. Аккаунт защищён.';
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _message = readableBackendError(error);
      });
    }
  }

  @override
  Widget build(BuildContext context) => _EmailActionScaffold(
        title: 'Подтверждение email',
        subtitle: 'Одноразовая проверка принадлежности адреса.',
        children: [
          if (_loading) const Center(child: CircularProgressIndicator()),
          Text(_message, key: const Key('verification-result-message')),
          if (!_loading) ...[
            const SizedBox(height: 16),
            PremiumButton(
              label: 'Продолжить',
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                '/home',
                (route) => false,
              ),
            ),
          ],
        ],
      );
}

class _EmailActionScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;

  const _EmailActionScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
  });

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        body: PremiumBackground(
          child: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 36),
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    tooltip: 'Назад',
                    onPressed: () => Navigator.maybePop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  ),
                ),
                const SizedBox(height: 26),
                const Icon(Icons.lock_reset_rounded,
                    size: 58, color: AppColors.sky),
                const SizedBox(height: 20),
                Text(
                  title,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 14,
                    height: 1.4,
                    color: AppColors.textGrey,
                  ),
                ),
                const SizedBox(height: 28),
                ...children,
              ],
            ),
          ),
        ),
      );
}
