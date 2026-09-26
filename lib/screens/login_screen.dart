import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/app_state.dart';
import '../services/backend_service.dart';
import '../utils/colors.dart';
import '../widgets/cat_character.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';

class LoginScreen extends StatefulWidget {
  final bool startInRegisterMode;
  final String initialName;
  final String initialEmail;

  const LoginScreen({
    super.key,
    this.startInRegisterMode = false,
    this.initialName = '',
    this.initialEmail = '',
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late bool _showRegister;
  bool _isLoading = false;

  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  bool _passVisible = false;
  bool _needsVerification = false;

  String _t({required String ru, required String kk, required String en}) =>
      context.read<AppState>().tr(ru: ru, kk: kk, en: en);

  @override
  void initState() {
    super.initState();
    _showRegister = widget.startInRegisterMode;
    _nameCtrl.text = widget.initialName;
    _emailCtrl.text = widget.initialEmail;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (_nameCtrl.text.trim().isEmpty ||
        !_emailCtrl.text.contains('@') ||
        _passCtrl.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(_t(
              ru: 'Укажи имя, корректный email и пароль от 8 символов',
              kk: 'Атыңды, дұрыс email және кемінде 8 таңбалы құпиясөзді енгіз',
              en: 'Enter your name, a valid email, and an 8-character password',
            )),
            backgroundColor: AppColors.error),
      );
      return;
    }
    setState(() => _isLoading = true);
    final state = context.read<AppState>();
    final success = await state.registerWithEmail(
      _nameCtrl.text.trim(),
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      final delivery = state.lastEmailDelivery;
      if (delivery != null) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text(delivery == 'provider_configured'
              ? _t(
                  ru: 'Аккаунт создан. Если письмо доставлено, подтверди email по одноразовой ссылке.',
                  kk: 'Аккаунт құрылды. Хат келсе, бір реттік сілтеме арқылы email-ды раста.',
                  en: 'Account created. If the email arrives, confirm it using the one-time link.',
                )
              : _t(
                  ru: 'Аккаунт создан. Отправка письма подтверждения пока не настроена.',
                  kk: 'Аккаунт құрылды. Растау хатын жіберу әзірге бапталмаған.',
                  en: 'Account created. Verification email delivery is not configured yet.',
                )),
          backgroundColor: delivery == 'provider_configured'
              ? AppColors.navy
              : AppColors.gold,
        ));
      }
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() =>
          _needsVerification = (state.error ?? '').contains('Подтверди email'));
      if ((state.error ?? '').contains('уже есть')) {
        setState(() => _showRegister = false);
      }
      _showError(state.error);
    }
  }

  Future<void> _login() async {
    if (!_emailCtrl.text.contains('@') || _passCtrl.text.isEmpty) {
      _showError(_t(
        ru: 'Введи email и пароль',
        kk: 'Email мен құпиясөзді енгіз',
        en: 'Enter your email and password',
      ));
      return;
    }
    setState(() => _isLoading = true);
    final state = context.read<AppState>();
    final success = await state.loginWithPassword(
      _emailCtrl.text.trim(),
      _passCtrl.text,
    );
    if (!mounted) return;
    setState(() => _isLoading = false);
    if (success) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      setState(() =>
          _needsVerification = (state.error ?? '').contains('Подтверди email'));
      _showError(state.error);
    }
  }

  Future<void> _continueLocally() async {
    setState(() => _isLoading = true);
    await context.read<AppState>().loginAsGuest();
    if (!mounted) return;
    setState(() => _isLoading = false);
    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
  }

  void _showError(String? message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message ??
            _t(
              ru: 'Не удалось войти',
              kk: 'Кіру мүмкін болмады',
              en: 'Could not sign in',
            )),
        backgroundColor: AppColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              children: [
                const SizedBox(height: 20),
                const _LoginHeader(),
                const SizedBox(height: 12),
                const CatCharacter(mood: CatMood.greet, size: 132),
                const SizedBox(height: 18),
                Text(
                  _showRegister
                      ? state.tr(
                          ru: 'Создай аккаунт',
                          kk: 'Аккаунт құр',
                          en: 'Create an account')
                      : state.tr(
                          ru: 'Добро пожаловать!',
                          kk: 'Қош келдің!',
                          en: 'Welcome!'),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppColors.navyDark,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 6),
                Text(
                  _showRegister
                      ? state.tr(
                          ru: 'Начни учиться прямо сейчас',
                          kk: 'Оқуды дәл қазір баста',
                          en: 'Start learning right now')
                      : state.tr(
                          ru: 'Коран и ислам шаг за шагом',
                          kk: 'Құран мен исламды қадамдап үйрен',
                          en: 'Quran and Islam, step by step'),
                  style: const TextStyle(
                    fontFamily: 'Nunito',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textGrey,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 28),
                ..._authForm(),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _authForm() {
    final state = context.watch<AppState>();
    return [
      if (_showRegister) ...[
        _Field(
            controller: _nameCtrl,
            label: state.tr(ru: 'Твоё имя', kk: 'Атың', en: 'Your name'),
            icon: Icons.person_outline),
        const SizedBox(height: 12),
      ],
      _Field(
          controller: _emailCtrl,
          label: state.tr(ru: 'Email', kk: 'Email', en: 'Email'),
          icon: Icons.email_outlined,
          type: TextInputType.emailAddress),
      const SizedBox(height: 12),
      _Field(
        controller: _passCtrl,
        label: state.tr(ru: 'Пароль', kk: 'Құпиясөз', en: 'Password'),
        icon: Icons.lock_outline,
        obscure: !_passVisible,
        suffix: IconButton(
          icon: Icon(_passVisible ? Icons.visibility_off : Icons.visibility,
              color: AppColors.textGrey),
          onPressed: () => setState(() => _passVisible = !_passVisible),
        ),
      ),
      const SizedBox(height: 22),
      Stack(
        alignment: Alignment.center,
        children: [
          PremiumButton(
            label: _showRegister
                ? state.tr(
                    ru: 'Создать аккаунт',
                    kk: 'Аккаунт құру',
                    en: 'Create account')
                : state.tr(ru: 'Войти', kk: 'Кіру', en: 'Sign in'),
            onPressed: _isLoading ? null : (_showRegister ? _register : _login),
          ),
          if (_isLoading)
            const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.6,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.white),
              ),
            ),
        ],
      ),
      const SizedBox(height: 14),
      if (!_showRegister)
        TextButton(
          key: const Key('forgot-password-button'),
          onPressed: _isLoading
              ? null
              : () => Navigator.pushNamed(
                    context,
                    '/forgot-password',
                    arguments: _emailCtrl.text.trim(),
                  ),
          child: Text(
            state.tr(
                ru: 'Забыли пароль?',
                kk: 'Құпиясөзді ұмыттың ба?',
                en: 'Forgot password?'),
            style: const TextStyle(
              fontFamily: 'Nunito',
              fontSize: 14,
              fontWeight: FontWeight.w800,
              color: AppColors.navy,
            ),
          ),
        ),
      if (!_showRegister && _needsVerification)
        TextButton.icon(
          key: const Key('resend-verification-button'),
          onPressed: _isLoading ? null : _resendVerification,
          icon: const Icon(Icons.mark_email_read_outlined),
          label: Text(state.tr(
            ru: 'Отправить подтверждение ещё раз',
            kk: 'Растауды қайта жіберу',
            en: 'Resend verification',
          )),
        ),
      TextButton(
        onPressed: _isLoading
            ? null
            : () => setState(() => _showRegister = !_showRegister),
        child: Text(
          _showRegister
              ? state.tr(
                  ru: 'Уже есть аккаунт? Войти',
                  kk: 'Аккаунтың бар ма? Кіру',
                  en: 'Already have an account? Sign in')
              : state.tr(
                  ru: 'Нет аккаунта? Зарегистрироваться',
                  kk: 'Аккаунтың жоқ па? Тіркелу',
                  en: 'No account? Register'),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.navy,
          ),
        ),
      ),
      const SizedBox(height: 2),
      TextButton.icon(
        onPressed: _isLoading ? null : _continueLocally,
        icon: const Icon(Icons.phone_iphone_rounded,
            size: 18, color: AppColors.textGrey),
        label: Text(
          state.tr(
            ru: 'Продолжить без аккаунта',
            kk: 'Аккаунтсыз жалғастыру',
            en: 'Continue without an account',
          ),
          style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: AppColors.textGrey,
          ),
        ),
      ),
    ];
  }

  Future<void> _resendVerification() async {
    if (!_emailCtrl.text.contains('@')) {
      _showError(_t(
        ru: 'Укажи email для подтверждения',
        kk: 'Растау үшін email енгіз',
        en: 'Enter an email to verify',
      ));
      return;
    }
    setState(() => _isLoading = true);
    try {
      final result = await context
          .read<AppState>()
          .requestEmailVerification(_emailCtrl.text.trim());
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(result.canDeliver
            ? _t(
                ru: 'Если аккаунт ожидает подтверждения, новая ссылка отправлена.',
                kk: 'Аккаунт растауды күтіп тұрса, жаңа сілтеме жіберілді.',
                en: 'If the account is awaiting verification, a new link was sent.',
              )
            : _t(
                ru: 'Отправка писем пока не настроена администратором.',
                kk: 'Хат жіберуді әкімші әлі баптамаған.',
                en: 'Email delivery has not been configured by the administrator.',
              )),
        backgroundColor: result.canDeliver ? AppColors.navy : AppColors.gold,
      ));
    } catch (error) {
      if (mounted) {
        _showError(readableBackendError(error,
            localeCode: context.read<AppState>().locale.code));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}

class _LoginHeader extends StatelessWidget {
  const _LoginHeader();

  @override
  Widget build(BuildContext context) {
    final canPop = Navigator.canPop(context);
    final state = context.watch<AppState>();
    return SizedBox(
      height: 42,
      child: Stack(
        alignment: Alignment.center,
        children: [
          const _Wordmark(),
          if (canPop)
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                key: const Key('login-back-button'),
                tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
                onPressed: () => Navigator.maybePop(context),
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                color: AppColors.navyDark,
              ),
            ),
        ],
      ),
    );
  }
}

/// Вордмарк «muslingo.» — navy w900, точка sky.
class _Wordmark extends StatelessWidget {
  const _Wordmark();

  @override
  Widget build(BuildContext context) {
    return const Text.rich(
      TextSpan(
        style: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: -0.5,
          color: AppColors.navyDark,
        ),
        children: [
          TextSpan(text: 'muslingo'),
          TextSpan(text: '.', style: TextStyle(color: AppColors.sky)),
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? type;
  final bool obscure;
  final Widget? suffix;

  const _Field({
    required this.controller,
    required this.label,
    required this.icon,
    this.type,
    this.obscure = false,
    this.suffix,
  });

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          // Мягкая premium-тень как у малых карточек.
          BoxShadow(
            color: AppColors.navyDark.withValues(alpha: 0.06),
            blurRadius: 14,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        keyboardType: type,
        obscureText: obscure,
        style: const TextStyle(
            fontFamily: 'Nunito',
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textDark),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
              fontFamily: 'Nunito',
              fontWeight: FontWeight.w600,
              color: AppColors.textGrey),
          prefixIcon: Icon(icon, color: AppColors.sky),
          suffixIcon: suffix,
          filled: true,
          fillColor: AppColors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.border, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: AppColors.sky, width: 2),
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        ),
      ),
    );
  }
}
