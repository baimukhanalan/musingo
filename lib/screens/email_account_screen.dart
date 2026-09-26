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
    final state = context.read<AppState>();
    if (!_email.text.contains('@')) {
      setState(() => _message = state.tr(
            ru: 'Укажи корректный email.',
            kk: 'Дұрыс email мекенжайын енгізіңіз.',
            en: 'Enter a valid email address.',
          ));
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      final result = await state.requestPasswordReset(_email.text);
      if (!mounted) return;
      setState(() {
        _message = result.canDeliver
            ? state.tr(
                ru: 'Если аккаунт существует и email подтверждён, ссылка уже отправлена.',
                kk: 'Аккаунт бар және email расталған болса, сілтеме жіберілді.',
                en: 'If the account exists and its email is verified, a link has been sent.',
              )
            : state.tr(
                ru: 'Запрос принят, но отправка писем пока не настроена администратором.',
                kk: 'Сұрау қабылданды, бірақ хат жіберуді әкімші әлі баптамаған.',
                en: 'The request was accepted, but email delivery is not configured yet.',
              );
      });
    } catch (error) {
      if (mounted) {
        setState(() => _message =
            readableBackendError(error, localeCode: state.locale.code));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return _EmailActionScaffold(
      title: state.tr(
          ru: 'Восстановить пароль',
          kk: 'Құпиясөзді қалпына келтіру',
          en: 'Reset password'),
      subtitle: state.tr(
        ru: 'Мы отправим одноразовую ссылку только на подтверждённый email.',
        kk: 'Бір реттік сілтемені тек расталған email мекенжайына жібереміз.',
        en: 'We will send a one-time link only to a verified email address.',
      ),
      children: [
        TextField(
          key: const Key('forgot-email-field'),
          controller: _email,
          keyboardType: TextInputType.emailAddress,
          textDirection: TextDirection.ltr,
          autofillHints: const [AutofillHints.email],
          decoration: InputDecoration(
            labelText: state.tr(ru: 'Email', kk: 'Email', en: 'Email'),
            prefixIcon: const Icon(Icons.email_outlined),
          ),
        ),
        const SizedBox(height: 18),
        PremiumButton(
          label: state.tr(
              ru: 'Отправить ссылку', kk: 'Сілтемені жіберу', en: 'Send link'),
          onPressed: _loading ? null : _send,
        ),
        if (_message != null) ...[
          const SizedBox(height: 16),
          Text(_message!, key: const Key('forgot-result-message')),
        ],
      ],
    );
  }
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
    final state = context.read<AppState>();
    if (widget.token.length < 40) {
      setState(() => _message = state.tr(
            ru: 'Ссылка неполная или повреждена.',
            kk: 'Сілтеме толық емес немесе бүлінген.',
            en: 'The link is incomplete or damaged.',
          ));
      return;
    }
    if (_password.text.length < 8 || _password.text != _confirmation.text) {
      setState(() => _message = state.tr(
            ru: 'Пароли должны совпадать и содержать не менее 8 символов.',
            kk: 'Құпиясөздер бірдей және кемінде 8 таңбадан тұруы керек.',
            en: 'Passwords must match and contain at least 8 characters.',
          ));
      return;
    }
    setState(() {
      _loading = true;
      _message = null;
    });
    try {
      await state.resetPassword(widget.token, _password.text);
      if (!mounted) return;
      setState(() => _message = state.tr(
            ru: 'Пароль изменён. Теперь можно войти.',
            kk: 'Құпиясөз өзгертілді. Енді кіре аласыз.',
            en: 'Password changed. You can sign in now.',
          ));
    } catch (error) {
      if (mounted) {
        setState(() => _message =
            readableBackendError(error, localeCode: state.locale.code));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return _EmailActionScaffold(
      title:
          state.tr(ru: 'Новый пароль', kk: 'Жаңа құпиясөз', en: 'New password'),
      subtitle: state.tr(
        ru: 'Ссылка одноразовая. После смены пароля старые сессии завершатся.',
        kk: 'Сілтеме бір реттік. Құпиясөз өзгергенде ескі сессиялар аяқталады.',
        en: 'This link works once. Changing the password ends earlier sessions.',
      ),
      children: [
        TextField(
          key: const Key('reset-password-field'),
          controller: _password,
          obscureText: true,
          autofillHints: const [AutofillHints.newPassword],
          decoration: InputDecoration(
              labelText: state.tr(
                  ru: 'Новый пароль', kk: 'Жаңа құпиясөз', en: 'New password')),
        ),
        const SizedBox(height: 12),
        TextField(
          key: const Key('reset-confirm-field'),
          controller: _confirmation,
          obscureText: true,
          decoration: InputDecoration(
              labelText: state.tr(
                  ru: 'Повтори пароль',
                  kk: 'Құпиясөзді қайталаңыз',
                  en: 'Confirm new password')),
        ),
        const SizedBox(height: 18),
        PremiumButton(
          label: state.tr(
              ru: 'Изменить пароль',
              kk: 'Құпиясөзді өзгерту',
              en: 'Change password'),
          onPressed: _loading ? null : _reset,
        ),
        if (_message != null) ...[
          const SizedBox(height: 16),
          Text(_message!, key: const Key('reset-result-message')),
        ],
        const SizedBox(height: 8),
        TextButton(
          onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
          child: Text(state.tr(
              ru: 'Перейти ко входу',
              kk: 'Кіру бетіне өту',
              en: 'Go to login')),
        ),
      ],
    );
  }
}

class VerifyEmailScreen extends StatefulWidget {
  final String token;

  const VerifyEmailScreen({super.key, required this.token});

  @override
  State<VerifyEmailScreen> createState() => _VerifyEmailScreenState();
}

class _VerifyEmailScreenState extends State<VerifyEmailScreen> {
  bool _loading = true;
  bool _confirmed = false;
  bool _invalidLink = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _confirm());
  }

  Future<void> _confirm() async {
    final state = context.read<AppState>();
    if (widget.token.length < 40) {
      setState(() {
        _loading = false;
        _invalidLink = true;
      });
      return;
    }
    try {
      await state.confirmEmailVerification(widget.token);
      if (!mounted) return;
      setState(() {
        _loading = false;
        _confirmed = true;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _invalidLink = error is BackendException &&
            error.code == 'invalid_or_expired_token';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final message = _loading
        ? state.tr(
            ru: 'Подтверждаем email...',
            kk: 'Email расталып жатыр...',
            en: 'Verifying your email...',
          )
        : _confirmed
            ? state.tr(
                ru: 'Email подтверждён. Аккаунт защищён.',
                kk: 'Email расталды. Аккаунт қорғалған.',
                en: 'Email verified. Your account is protected.',
              )
            : _invalidLink
                ? state.tr(
                    ru: 'Ссылка недействительна, просрочена или уже использована.',
                    kk: 'Сілтеме жарамсыз, мерзімі өткен немесе бұрын қолданылған.',
                    en: 'This link is invalid, expired, or has already been used.',
                  )
                : state.tr(
                    ru: 'Не удалось подтвердить email. Попробуй ещё раз позже.',
                    kk: 'Email растау мүмкін болмады. Кейінірек қайталап көріңіз.',
                    en: 'Could not verify your email. Please try again later.',
                  );
    final canContinueHome = _confirmed && state.isBackendUser;

    return _EmailActionScaffold(
      title: state.tr(
        ru: 'Подтверждение email',
        kk: 'Email растау',
        en: 'Email verification',
      ),
      subtitle: state.tr(
        ru: 'Одноразовая проверка принадлежности адреса.',
        kk: 'Email мекенжайын бір реттік тексеру.',
        en: 'A one-time check that this email belongs to you.',
      ),
      backTooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
      children: [
        if (_loading) const Center(child: CircularProgressIndicator()),
        Text(message, key: const Key('verification-result-message')),
        if (!_loading) ...[
          const SizedBox(height: 16),
          PremiumButton(
            label: canContinueHome
                ? state.tr(ru: 'Продолжить', kk: 'Жалғастыру', en: 'Continue')
                : state.tr(
                    ru: 'Перейти ко входу',
                    kk: 'Кіру бетіне өту',
                    en: 'Go to login',
                  ),
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              canContinueHome ? '/home' : '/login',
              (route) => false,
            ),
          ),
        ],
      ],
    );
  }
}

class _EmailActionScaffold extends StatelessWidget {
  final String title;
  final String subtitle;
  final List<Widget> children;
  final String? backTooltip;

  const _EmailActionScaffold({
    required this.title,
    required this.subtitle,
    required this.children,
    this.backTooltip,
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
                  alignment: AlignmentDirectional.centerStart,
                  child: IconButton(
                    tooltip: backTooltip ??
                        context
                            .watch<AppState>()
                            .tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
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
