import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/email_account_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/backend_service.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() => SharedPreferences.setMockInitialValues({}));

  testWidgets('forgot-password screen keeps the entered email', (tester) async {
    final state = AppState();
    await tester.runAsync(() => _waitUntilInitialized(state));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(
          home: ForgotPasswordScreen(initialEmail: 'alan@example.test'),
        ),
      ),
    );
    await tester.pump();
    expect(find.text('Восстановить пароль'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'alan@example.test'), findsOneWidget);
    state.dispose();
  });

  testWidgets('reset screen rejects a damaged link before a network request',
      (tester) async {
    final state = AppState();
    await tester.runAsync(() => _waitUntilInitialized(state));
    await tester.pumpWidget(
      ChangeNotifierProvider.value(
        value: state,
        child: const MaterialApp(home: ResetPasswordScreen(token: 'short')),
      ),
    );
    await tester.enterText(
      find.byKey(const Key('reset-password-field')),
      'Password123!',
    );
    await tester.enterText(
      find.byKey(const Key('reset-confirm-field')),
      'Password123!',
    );
    await tester.tap(find.text('Изменить пароль'));
    await tester.pump();
    expect(find.text('Ссылка неполная или повреждена.'), findsOneWidget);
    state.dispose();
  });

  for (final testCase in <({
    AppLocale locale,
    String title,
    String message,
    String action,
    String back,
  })>[
    (
      locale: AppLocale.ru,
      title: 'Подтверждение email',
      message: 'Ссылка недействительна, просрочена или уже использована.',
      action: 'Перейти ко входу',
      back: 'Назад',
    ),
    (
      locale: AppLocale.kk,
      title: 'Email растау',
      message: 'Сілтеме жарамсыз, мерзімі өткен немесе бұрын қолданылған.',
      action: 'Кіру бетіне өту',
      back: 'Артқа',
    ),
    (
      locale: AppLocale.en,
      title: 'Email verification',
      message: 'This link is invalid, expired, or has already been used.',
      action: 'Go to login',
      back: 'Back',
    ),
  ]) {
    testWidgets(
        'invalid verification link is localized for ${testCase.locale.code} and opens login',
        (tester) async {
      final state = AppState();
      await tester.runAsync(() => _waitUntilInitialized(state));
      await state.setLocale(testCase.locale);
      await tester.pumpWidget(_verificationHarness(
        state: state,
        screen: const VerifyEmailScreen(token: 'short'),
      ));
      await tester.pump();

      expect(find.text(testCase.title), findsOneWidget);
      expect(find.text(testCase.message), findsOneWidget);
      expect(find.text(testCase.action), findsOneWidget);
      expect(find.byTooltip(testCase.back), findsOneWidget);

      await tester.tap(find.text(testCase.action));
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('login-destination')), findsOneWidget);
      expect(find.byKey(const Key('home-destination')), findsNothing);
      state.dispose();
    });
  }

  testWidgets('successful verification without a session opens login',
      (tester) async {
    final state = _VerificationAppState();
    await tester.runAsync(() => _waitUntilInitialized(state));
    await tester.pumpWidget(_verificationHarness(
      state: state,
      screen: VerifyEmailScreen(token: 'v' * 40),
    ));
    await tester.pump();
    await tester.pump();

    expect(find.text('Email подтверждён. Аккаунт защищён.'), findsOneWidget);
    expect(find.text('Перейти ко входу'), findsOneWidget);
    await tester.tap(find.text('Перейти ко входу'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-destination')), findsOneWidget);
    expect(find.byKey(const Key('home-destination')), findsNothing);
    state.dispose();
  });

  testWidgets('failed verification never opens home', (tester) async {
    final state = _VerificationAppState(
      confirmError: const BackendException(
        503,
        'network_error',
        'Server unavailable',
      ),
    );
    await tester.runAsync(() => _waitUntilInitialized(state));
    await tester.pumpWidget(_verificationHarness(
      state: state,
      screen: VerifyEmailScreen(token: 'v' * 40),
    ));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Не удалось подтвердить email. Попробуй ещё раз позже.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Перейти ко входу'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-destination')), findsOneWidget);
    expect(find.byKey(const Key('home-destination')), findsNothing);
    state.dispose();
  });

  testWidgets('expired verification link never opens home', (tester) async {
    final state = _VerificationAppState(
      confirmError: const BackendException(
        400,
        'invalid_or_expired_token',
        'Expired token',
      ),
    );
    await tester.runAsync(() => _waitUntilInitialized(state));
    await tester.pumpWidget(_verificationHarness(
      state: state,
      screen: VerifyEmailScreen(token: 'v' * 40),
    ));
    await tester.pump();
    await tester.pump();

    expect(
      find.text('Ссылка недействительна, просрочена или уже использована.'),
      findsOneWidget,
    );
    await tester.tap(find.text('Перейти ко входу'));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('login-destination')), findsOneWidget);
    expect(find.byKey(const Key('home-destination')), findsNothing);
    state.dispose();
  });
}

class _VerificationAppState extends AppState {
  final Object? confirmError;

  _VerificationAppState({this.confirmError});

  @override
  Future<void> confirmEmailVerification(String token) async {
    if (confirmError case final error?) throw error;
  }
}

Widget _verificationHarness({
  required AppState state,
  required VerifyEmailScreen screen,
}) =>
    ChangeNotifierProvider.value(
      value: state,
      child: MaterialApp(
        home: screen,
        routes: {
          '/login': (_) => const Scaffold(
                body: SizedBox(key: Key('login-destination')),
              ),
          '/home': (_) => const Scaffold(
                body: SizedBox(key: Key('home-destination')),
              ),
        },
      ),
    );

Future<void> _waitUntilInitialized(AppState state) async {
  for (var i = 0; i < 200 && !state.isInitialized; i++) {
    await Future<void>.delayed(const Duration(milliseconds: 5));
  }
  expect(state.isInitialized, isTrue);
}
