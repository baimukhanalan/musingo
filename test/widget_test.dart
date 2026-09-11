import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:muslingo/main.dart';
import 'package:muslingo/models/learning_profile.dart';
import 'package:muslingo/screens/login_screen.dart';
import 'package:muslingo/screens/onboarding_screen.dart';
import 'package:muslingo/screens/premium_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  setUp(() {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
  });

  testWidgets('Muslingo app starts with splash screen',
      (WidgetTester tester) async {
    await tester.pumpWidget(const MuslingoApp());

    expect(find.text('muslingo'), findsOneWidget);
    expect(find.byIcon(Icons.add), findsNothing);

    await _teardown(tester);
  });

  testWidgets('Премиум-интро помещается в эталонный viewport 402x874',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState();
    await tester.runAsync(() => _waitUntilInitialized(state));
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: const OnboardingScreen(),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Твой путь к Корану'), findsOneWidget);
    expect(find.text('Начать — 2 минуты'), findsOneWidget);
    expect(find.byKey(const ValueKey('premium-intro-mascot')), findsOneWidget);

    await tester.tap(find.text('EN'));
    await tester.pump();
    expect(find.text('Your path to the Quran'), findsOneWidget);
    expect(state.locale.code, 'en');

    await _teardown(tester);
  });

  testWidgets('Экран Muslingo+ показывает тарифы и действие на 402x874',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState();
    await tester.runAsync(() => _waitUntilInitialized(state));
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: PremiumScreen()),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('19 990 ₸'), findsOneWidget);
    expect(find.text('2 990 ₸'), findsOneWidget);
    expect(find.text('Muslingo+ скоро'), findsOneWidget);

    await _teardown(tester);
  });

  // Раньше на этом месте был тест, читавший login_screen.dart как ТЕКСТ и
  // искавший в нём подстроки. Он не проверял поведение: экран мог быть сломан,
  // а тест проходил — и наоборот, любое переименование его роняло.
  testWidgets('Экран логина предлагает вход и путь без аккаунта',
      (WidgetTester tester) async {
    final state = AppState();
    await tester.runAsync(() => _waitUntilInitialized(state));

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: const LoginScreen(),
          // Экран после входа сюда не тащим — достаточно, чтобы переход
          // состоялся и не упал на неизвестном маршруте.
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Нет аккаунта? Зарегистрироваться'), findsOneWidget);
    expect(find.text('Продолжить без аккаунта'), findsOneWidget);
    expect(find.byType(TextField), findsWidgets);

    await _teardown(tester);
  });

  testWidgets('сохранение локального профиля сразу открывает регистрацию',
      (WidgetTester tester) async {
    final state = AppState();
    await tester.runAsync(() => _waitUntilInitialized(state));

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(
          home: LoginScreen(
            startInRegisterMode: true,
            initialName: 'Alan',
            initialEmail: 'alan@example.test',
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Создай аккаунт'), findsOneWidget);
    expect(find.text('Создать аккаунт'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'Alan'), findsOneWidget);
    expect(find.widgetWithText(TextField, 'alan@example.test'), findsOneWidget);

    await _teardown(tester);
  });

  testWidgets('Вход без аккаунта заводит гостевой профиль',
      (WidgetTester tester) async {
    final state = AppState();
    await tester.runAsync(() => _waitUntilInitialized(state));
    expect(state.isLoggedIn, isFalse);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: const LoginScreen(),
          // Экран после входа сюда не тащим — достаточно, чтобы переход
          // состоялся и не упал на неизвестном маршруте.
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();

    // Премиум-редизайн логина сделал форму выше тестового вьюпорта (600px):
    // прокручиваем кнопку в зону видимости, иначе tap бьёт мимо off-screen цели.
    final guestBtn = find.text('Продолжить без аккаунта');
    await tester.ensureVisible(guestBtn);
    await tester.pump();
    await tester.tap(guestBtn);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));

    expect(state.isLoggedIn, isTrue);
    expect(state.user, isNotNull);

    await _teardown(tester);
  });

  testWidgets('Диагностика запускает рекомендованный первый урок',
      (WidgetTester tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final state = AppState();
    await tester.runAsync(() => _waitUntilInitialized(state));

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: const OnboardingScreen(),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => Scaffold(
              body: Text(
                  settings.name == '/lesson' ? 'lesson-route' : 'home-route'),
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Начать — 2 минуты'));
    await tester.pump();
    await tester.tap(find.text('Читать арабский текст'));
    await tester.pump();
    for (final answer in <String>[
      'ح',
      'ба',
      'أَحَدٌ',
      'Во имя Аллаха, Милостивого, Милосердного',
      'Удвоение согласного звука',
    ]) {
      await tester.tap(find.text(answer));
      await tester.pump();
    }

    expect(
      find.textContaining('У тебя уверенная база'),
      findsOneWidget,
    );
    expect(find.textContaining('Начни с арабских букв'), findsNothing);
    expect(find.text('Начать первый урок'), findsOneWidget);
    await tester.tap(find.text('Начать первый урок'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.text('lesson-route'), findsOneWidget);
    expect(state.isGuest, isTrue);
    expect(state.learningGoal, LearningGoal.arabicReading);
    expect(state.learningSkillProfile?.overallScore, 100);

    await _teardown(tester);
  });
}

/// AppState грузится асинхронно и не отдаёт future готовности — ждём флаг.
/// Вызывать только внутри tester.runAsync: в фейковом времени testWidgets
/// Future.delayed не двигается без pump и ожидание зависает навсегда.
Future<void> _waitUntilInitialized(AppState state) async {
  final deadline = DateTime.now().add(const Duration(seconds: 2));
  while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 10));
  }
  expect(state.isInitialized, isTrue);
}

/// Гасит анимации и снимает дерево. Без прокрутки реального интервала
/// flutter_animate оставляет живой Future.delayed, и тест падает на
/// «A Timer is still pending». В tearDown это делать поздно — проверка
/// таймеров срабатывает раньше него.
Future<void> _teardown(WidgetTester tester) async {
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pumpWidget(const SizedBox.shrink());
  await tester.pump(const Duration(milliseconds: 50));
}
