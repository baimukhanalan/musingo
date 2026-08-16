import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:muslingo/screens/coach_screen.dart';
import 'package:muslingo/screens/friends_screen.dart';
import 'package:muslingo/screens/home_screen.dart';
import 'package:muslingo/screens/install_app_screen.dart';
import 'package:muslingo/screens/league_screen.dart';
import 'package:muslingo/screens/main_tab_screen.dart';
import 'package:muslingo/screens/quran_screen.dart';
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
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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
    expect(find.byType(CustomScrollView), findsNWidgets(2));
    // Виден премиум-хедер с приветствием (стабильно при любом гейтинге секций).
    expect(find.textContaining('Ассаляму алейкум'), findsOneWidget);
    // Три компактные карточки статистики и голубой daily plan из референса.
    expect(find.text('ДНЕЙ ПОДРЯД'), findsOneWidget);
    expect(find.text('XP'), findsOneWidget);
    expect(find.text('ЖИЗНИ'), findsOneWidget);
    expect(find.text('Начать урок'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                'assets/images/cat_learning_real.webp',
      ),
      findsOneWidget,
    );

    await teardown(tester);
  });

  testWidgets(
      'Курсы прокручиваются внутри панели и переключаются без блокирующего окна',
      (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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

    final outerScroll = find.byType(CustomScrollView).first;
    for (var i = 0; i < 4; i++) {
      await tester.drag(outerScroll, const Offset(0, -420));
      await tester.pump(const Duration(milliseconds: 120));
      if (find
          .byKey(const ValueKey('learning-path-panel'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }

    expect(find.byKey(const ValueKey('learning-path-panel')), findsOneWidget);
    expect(find.byKey(const ValueKey('course-path-quran')), findsOneWidget);
    expect(find.byType(CustomScrollView), findsNWidgets(2));
    expect(find.text('68 уроков'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('course-mode-arabic')));
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.byKey(const ValueKey('course-path-quran')), findsNothing);
    expect(find.byKey(const ValueKey('course-path-arabic')), findsOneWidget);
    expect(find.text('22 урока'), findsOneWidget);
    expect(find.text('Выбрать язык объяснений'), findsOneWidget);
    expect(find.text('Выбери родной язык'), findsNothing);
    expect(tester.takeException(), isNull);

    // Академия стоит сразу после фиксированной панели, а не после 68 узлов.
    await tester.drag(outerScroll, const Offset(0, -440));
    await tester.pump(const Duration(milliseconds: 150));
    expect(find.text('Академия'), findsOneWidget);

    await teardown(tester);
  });

  testWidgets('Нижняя навигация: Instagram-паттерн без подписей',
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
    // Подписи остаются в semantics/tooltip, но не занимают место на экране.
    expect(find.text('Главная'), findsNothing);
    expect(find.bySemanticsLabel('Главная'), findsOneWidget);
    expect(find.bySemanticsLabel('Коран'), findsWidgets);
    expect(find.text('Hafiz'), findsNothing);
    expect(find.bySemanticsLabel('Hafiz'), findsOneWidget);
    expect(find.text('Профиль'), findsNothing);
    expect(find.bySemanticsLabel('Профиль'), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-4')), findsOneWidget);
    // Лига доступна отдельной страницей из «Друзей», но не перегружает таббар;
    // «Основы» переехали во внутреннюю вкладку на главной; «Уроки» → «Главная».
    expect(find.text('Лига'), findsNothing);
    expect(find.text('Уроки'), findsNothing);

    await teardown(tester);
  });

  testWidgets('каждая кнопка нижнего меню открывает свою вкладку',
      (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = await guestState(tester);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: MainTabScreen()),
      ),
    );
    await tester.pump();

    int selectedIndex() =>
        tester.widget<IndexedStack>(find.byType(IndexedStack)).index ?? 0;

    expect(selectedIndex(), 0);
    for (var index = 1; index < 5; index++) {
      await tester.tap(find.byKey(ValueKey('bottom-nav-$index')));
      await tester.pump(const Duration(milliseconds: 220));
      expect(selectedIndex(), index);
      expect(tester.takeException(), isNull);
    }

    await tester.tap(find.byKey(const ValueKey('bottom-nav-0')));
    await tester.pump(const Duration(milliseconds: 220));
    expect(selectedIndex(), 0);

    await teardown(tester);
  });

  testWidgets('развёрнутый путь сохраняет нижнее меню и переключение курсов',
      (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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

    final outerScroll = find.byType(CustomScrollView).first;
    for (var i = 0; i < 4; i++) {
      await tester.drag(outerScroll, const Offset(0, -420));
      await tester.pump(const Duration(milliseconds: 120));
      if (find
          .byKey(const ValueKey('expand-learning-path'))
          .evaluate()
          .isNotEmpty) {
        break;
      }
    }
    await tester.tap(find.byKey(const ValueKey('expand-learning-path')));
    await tester.pump(const Duration(milliseconds: 250));

    expect(find.byKey(const ValueKey('learning-path-panel-expanded')),
        findsOneWidget);
    expect(
        find.byKey(const ValueKey('collapse-learning-path')), findsOneWidget);
    expect(find.bySemanticsLabel('Главная'), findsOneWidget);
    expect(find.bySemanticsLabel('Hafiz'), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('course-mode-basics')));
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.byKey(const ValueKey('course-path-rules')), findsOneWidget);

    await tester.tap(find.byKey(const ValueKey('collapse-learning-path')));
    await tester.pump(const Duration(milliseconds: 220));
    expect(find.byKey(const ValueKey('learning-path-panel')), findsOneWidget);
    expect(tester.takeException(), isNull);

    await teardown(tester);
  });

  testWidgets('вкладки Quran Reader вызывают реальные разделы', (tester) async {
    final state = await guestState(tester);
    QuranSection? selected;

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          home: Scaffold(
            body: QuranSectionTabs(
              selected: QuranSection.surahs,
              onSelected: (value) => selected = value,
            ),
          ),
        ),
      ),
    );

    await tester.tap(find.byKey(const ValueKey('quran-tab-juz')));
    expect(selected, QuranSection.juz);

    await tester.tap(find.byKey(const ValueKey('quran-tab-hafiz')));
    expect(selected, QuranSection.hafiz);
    expect(quranJuzStarts, hasLength(30));
    expect(quranJuzStarts.first.surahNumber, 1);
    expect(quranJuzStarts.last.surahNumber, 78);

    await teardown(tester);
  });

  testWidgets('отдельный AI Coach показывает кнопку возврата', (tester) async {
    final state = await guestState(tester);
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => state,
        child: const MaterialApp(home: CoachScreen(showBackButton: true)),
      ),
    );
    await tester.pump();

    expect(find.byKey(const Key('coach-back-button')), findsOneWidget);
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
    expect(find.byKey(const Key('friends-back-button')), findsOneWidget);
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
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
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

  testWidgets('Экран установки помещается на мобильном viewport',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = await guestState(tester);

    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: InstallAppScreen()),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Установить Muslingo'), findsOneWidget);
    // В VM используется native-stub: экран честно считает приложение уже
    // установленным; web-ветку с двумя кнопками проверяет production smoke.
    expect(find.text('Muslingo уже установлен'), findsOneWidget);

    await teardown(tester);
  });
}
