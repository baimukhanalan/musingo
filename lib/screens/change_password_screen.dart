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
    setState(() => _submitting = true);
    final state = context.read<AppState>();
    final changed = await state.changePassword(
      _currentController.text,
      _newController.text,
    );
    if (!mounted) return;
    setState(() => _submitting = false);
    if (!changed) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(state.error ??
              state.tr(
                ru: 'Не удалось изменить пароль.',
                kk: 'Құпиясөзді өзгерту мүмкін болмады.',
                en: 'Could not change the password.',
              )),
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
                        validator: (value) => value != _newController.text
                            ? state.tr(
                                ru: 'Пароли не совпадают',
                                kk: 'Құпиясөздер сәйкес емес',
                                en: 'Passwords do not match',
                              )
                            : null,
                      ),
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

  const _PasswordField({
    required this.controller,
    required this.label,
    required this.visible,
    required this.onToggle,
    required this.autofillHints,
    required this.validator,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: !visible,
      autocorrect: false,
      enableSuggestions: false,
      keyboardType: TextInputType.visiblePassword,
      textInputAction: TextInputAction.next,
      autofillHints: autofillHints,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.lock_outline_rounded),
        suffixIcon: IconButton(
          tooltip: visible ? 'Hide password' : 'Show password',
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
