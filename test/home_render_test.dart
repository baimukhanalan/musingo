import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:muslingo/screens/friends_screen.dart';
import 'package:muslingo/screens/home_screen.dart';
import 'package:muslingo/screens/league_screen.dart';
import 'package:muslingo/screens/main_tab_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Регрессия на «пустой экран уроков»: pinned SliverPersistentHeader на главной
/// заявлял высоту 58, а контент (StatsRow) рисовался на ~47 → SliverGeometry
/// invalid (layoutExtent > paintExtent), и весь CustomScrollView падал на
/// верстке. Существующие тесты главную не рендерили, поэтому баг проскочил.
/// Этот тест именно РЕНДЕРИТ главную и проверяет, что исключений верстки нет.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppState> guestState(WidgetTester tester) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    expect(state.isInitialized, isTrue);
    await state.loginAsGuest();
    return state;
  }

  Future<void> teardown(WidgetTester tester) async {
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 50));
  }

  testWidgets('Главная рендерится без ошибок верстки и показывает уроки',
      (tester) async {
    final state = await guestState(tester);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: const HomeScreen(),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();

    // Главное: верстка не бросила исключение (SliverGeometry invalid,
    // переполнение узла урока и т.п.) — раньше из-за этого экран был пустым.
    expect(tester.takeException(), isNull);
    // И скролл-вью уроков реально построился, а не пустой экран.
    expect(find.byType(CustomScrollView), findsOneWidget);
    // Виден премиум-хедер с приветствием (стабильно при любом гейтинге секций).
    expect(find.textContaining('Ассаляму алейкум'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('Нижняя навигация: премиум-таббар без Лиги/Основ',
      (tester) async {
    final state = await guestState(tester);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: const MainTabScreen(),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    // Новый таббар прототипа: Главная · Коран · Coach · Hafiz · Профиль.
    expect(find.text('Главная'), findsOneWidget);
    expect(find.text('Коран'), findsOneWidget);
    expect(find.text('Hafiz'), findsOneWidget);
    expect(find.text('Профиль'), findsOneWidget);
    // Лига доступна отдельной страницей из «Друзей», но не перегружает таббар;
    // «Основы» переехали разделом на главную; «Уроки» → «Главная».
    expect(find.text('Лига'), findsNothing);
    expect(find.text('Основы'), findsNothing);
    expect(find.text('Уроки'), findsNothing);

    await teardown(tester);
  });

  testWidgets('Экран «Друзья» рендерится (гость → предложение аккаунта)',
      (tester) async {
    final state = await guestState(tester);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: const FriendsScreen(),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Друзья'), findsOneWidget);
    expect(find.text('Учитесь вместе'), findsOneWidget);
    expect(find.text('Недельная лига'), findsOneWidget);
    // Гость видит предложение создать аккаунт, а не выдуманных соперников.
    expect(find.text('Соревнование доступно с аккаунтом'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('Пока никого'), 240);
    expect(find.text('Пока никого'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('Лига рендерится и честно требует аккаунт у гостя',
      (tester) async {
    final state = await guestState(tester);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: const LeagueScreen(),
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => const SizedBox.shrink(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Недельная лига'), findsWidgets);
    expect(find.text('Войди, чтобы участвовать'), findsOneWidget);
    expect(find.text('Войти или создать аккаунт'), findsOneWidget);

    await teardown(tester);
  });
}
