import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../services/app_state.dart';
import '../utils/colors.dart';
import '../widgets/premium_background.dart';
import '../widgets/premium_button.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _showCurrent = false;
  bool _showNew = false;
  bool _showConfirm = false;
  bool _submitting = false;
  String? _submitError;

  bool get _hasMinimumLength => _newController.text.length >= 8;
  bool get _withinMaximumLength => _newController.text.length <= 128;
  bool get _isDifferent =>
      _newController.text.isNotEmpty &&
      _newController.text != _currentController.text;
  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() {
      _submitting = true;
      _submitError = null;
    });
    final state = context.read<AppState>();
    final changed = await state.changePassword(
      _currentController.text,
      _newController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!changed) {
      final message = state.error ??
          state.tr(
            ru: 'Не удалось изменить пароль.',
            kk: 'Құпиясөзді өзгерту мүмкін болмады.',
            en: 'Could not change the password.',
          );
      if (!state.isLoggedIn) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message), backgroundColor: AppColors.error),
        );
        Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
        return;
      }
      setState(() => _submitError = message);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(state.tr(
          ru: 'Пароль изменён. Остальные сессии завершены.',
          kk: 'Құпиясөз өзгертілді. Басқа сессиялар аяқталды.',
          en: 'Password changed. Other sessions were signed out.',
        )),
        backgroundColor: AppColors.success,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: PremiumBackground(
        child: SafeArea(
          child: ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
            children: [
              Row(
                children: [
                  IconButton(
                    tooltip: state.tr(ru: 'Назад', kk: 'Артқа', en: 'Back'),
                    onPressed:
                        _submitting ? null : () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded),
                    color: AppColors.navyDark,
                  ),
                  Expanded(
                    child: Text(
                      state.tr(
                        ru: 'Изменить пароль',
                        kk: 'Құпиясөзді өзгерту',
                        en: 'Change password',
                      ),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.navyDark,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.border),
                ),
                child: AutofillGroup(
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          state.tr(
                            ru: 'Защити свой прогресс',
                            kk: 'Прогресіңді қорға',
                            en: 'Protect your progress',
                          ),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: AppColors.navyDark,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          state.tr(
                            ru: 'После смены пароля вход на других устройствах будет завершён.',
                            kk: 'Құпиясөз өзгергеннен кейін басқа құрылғылардағы сессиялар аяқталады.',
                            en: 'Changing your password signs out other devices.',
                          ),
                          style: const TextStyle(
                            fontFamily: 'Nunito',
                            fontSize: 14,
                            height: 1.4,
                            color: AppColors.textGrey,
                          ),
                        ),
                        const SizedBox(height: 22),
                        _PasswordField(
                          controller: _currentController,
                          label: state.tr(
                            ru: 'Текущий пароль',
                            kk: 'Ағымдағы құпиясөз',
                            en: 'Current password',
                          ),
                          visible: _showCurrent,
                          onToggle: () =>
                              setState(() => _showCurrent = !_showCurrent),
                          autofillHints: const [AutofillHints.password],
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() => _submitError = null),
                          showPasswordLabel: state.tr(
                            ru: 'Показать пароль',
                            kk: 'Құпиясөзді көрсету',
                            en: 'Show password',
                          ),
                          hidePasswordLabel: state.tr(
                            ru: 'Скрыть пароль',
                            kk: 'Құпиясөзді жасыру',
                            en: 'Hide password',
                          ),
                          validator: (value) => (value?.isEmpty ?? true)
                              ? state.tr(
                                  ru: 'Введи текущий пароль',
                                  kk: 'Ағымдағы құпиясөзді енгіз',
                                  en: 'Enter your current password',
                                )
                              : null,
                        ),
                        const SizedBox(height: 14),
                        _PasswordField(
                          controller: _newController,
                          label: state.tr(
                            ru: 'Новый пароль',
                            kk: 'Жаңа құпиясөз',
                            en: 'New password',
                          ),
                          visible: _showNew,
                          onToggle: () => setState(() => _showNew = !_showNew),
                          autofillHints: const [AutofillHints.newPassword],
                          textInputAction: TextInputAction.next,
                          onChanged: (_) => setState(() => _submitError = null),
                          showPasswordLabel: state.tr(
                            ru: 'Показать пароль',
                            kk: 'Құпиясөзді көрсету',
                            en: 'Show password',
                          ),
                          hidePasswordLabel: state.tr(
                            ru: 'Скрыть пароль',
                            kk: 'Құпиясөзді жасыру',
                            en: 'Hide password',
                          ),
                          validator: (value) {
                            if ((value?.length ?? 0) < 8) {
                              return state.tr(
                                ru: 'Минимум 8 символов',
                                kk: 'Кемінде 8 таңба',
                                en: 'Use at least 8 characters',
                              );
                            }
                            if (value!.length > 128) {
                              return state.tr(
                                ru: 'Не больше 128 символов',
                                kk: '128 таңбадан аспауы керек',
                                en: 'Use no more than 128 characters',
                              );
                            }
                            if (value == _currentController.text) {
                              return state.tr(
                                ru: 'Новый пароль должен отличаться',
                                kk: 'Жаңа құпиясөз өзгеше болуы керек',
                                en: 'Choose a different password',
                              );
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        _PasswordRequirements(
                          minimumLength: _hasMinimumLength,
                          withinMaximumLength: _withinMaximumLength,
                          different: _isDifferent,
                        ),
                        const SizedBox(height: 14),
                        _PasswordField(
                          controller: _confirmController,
                          label: state.tr(
                            ru: 'Повтори новый пароль',
                            kk: 'Жаңа құпиясөзді қайтала',
                            en: 'Confirm new password',
                          ),
                          visible: _showConfirm,
                          onToggle: () =>
                              setState(() => _showConfirm = !_showConfirm),
                          autofillHints: const [AutofillHints.newPassword],
                          textInputAction: TextInputAction.done,
                          onFieldSubmitted: (_) {
                            if (!_submitting) _submit();
                          },
                          onChanged: (_) => setState(() => _submitError = null),
                          showPasswordLabel: state.tr(
                            ru: 'Показать пароль',
                            kk: 'Құпиясөзді көрсету',
                            en: 'Show password',
                          ),
                          hidePasswordLabel: state.tr(
                            ru: 'Скрыть пароль',
                            kk: 'Құпиясөзді жасыру',
                            en: 'Hide password',
                          ),
                          validator: (value) => value != _newController.text
                              ? state.tr(
                                  ru: 'Пароли не совпадают',
                                  kk: 'Құпиясөздер сәйкес емес',
                                  en: 'Passwords do not match',
                                )
                              : null,
                        ),
                        if (_submitError != null) ...[
                          const SizedBox(height: 14),
                          Semantics(
                            liveRegion: true,
                            child: Container(
                              key: const ValueKey('password-submit-error'),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.error.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color:
                                      AppColors.error.withValues(alpha: 0.35),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Icon(Icons.error_outline_rounded,
                                      color: AppColors.error, size: 20),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _submitError!,
                                      style: const TextStyle(
                                        fontFamily: 'Nunito',
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: AppColors.error,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        PremiumButton(
                          label: _submitting
                              ? state.tr(
                                  ru: 'Сохраняем...',
                                  kk: 'Сақталуда...',
                                  en: 'Saving...')
                              : state.tr(
                                  ru: 'Сохранить пароль',
                                  kk: 'Құпиясөзді сақтау',
                                  en: 'Save password'),
                          icon: Icons.lock_reset_rounded,
                          onPressed: _submitting ? null : _submit,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PasswordField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final bool visible;
  final VoidCallback onToggle;
  final Iterable<String> autofillHints;
  final String? Function(String?) validator;
  final TextInputAction textInputAction;
  final ValueChanged<String>? onFieldSubmitted;
  final ValueChanged<String>? onChanged;
  final String showPasswordLabel;
  final String hidePasswordLabel;

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.visible,
    required this.onToggle,
    required this.autofillHints,
    required this.validator,
    required this.textInputAction,
    this.onFieldSubmitted,
    this.onChanged,
    required this.showPasswordLabel,
    required this.hidePasswordLabel,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: textInputAction,
      autofillHints: autofillHints,
      validator: validator,
      onFieldSubmitted: onFieldSubmitted,
      onChanged: onChanged,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: visible ? hidePasswordLabel : showPasswordLabel,
          onPressed: onToggle,
          icon: Icon(visible
              ? Icons.visibility_off_rounded
              : Icons.visibility_rounded),
        ),
        filled: true,
        fillColor: AppColors.backgroundGrey,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.border),
        ),
      ),
    );
  }
}

class _PasswordRequirements extends StatelessWidget {
  final bool minimumLength;
  final bool withinMaximumLength;
  final bool different;

  const _PasswordRequirements({
    required this.minimumLength,
    required this.withinMaximumLength,
    required this.different,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _RequirementLine(
          met: minimumLength && withinMaximumLength,
          text: state.tr(
            ru: 'От 8 до 128 символов',
            kk: '8-ден 128 таңбаға дейін',
            en: '8 to 128 characters',
          ),
        ),
        const SizedBox(height: 4),
        _RequirementLine(
          met: different,
          text: state.tr(
            ru: 'Отличается от текущего пароля',
            kk: 'Ағымдағы құпиясөзден өзгеше',
            en: 'Different from the current password',
          ),
        ),
      ],
    );
  }
}

class _RequirementLine extends StatelessWidget {
  final bool met;
  final String text;

  const _RequirementLine({required this.met, required this.text});

  @override
  Widget build(BuildContext context) {
    final color = met ? AppColors.success : AppColors.textGrey;
    return Row(
      children: [
        Icon(
          met ? Icons.check_circle_rounded : Icons.circle_outlined,
          size: 16,
          color: color,
        ),
        const SizedBox(width: 7),
        Expanded(
          child: Text(
            text,
            style: TextStyle(
              fontFamily: 'Nunito',
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
