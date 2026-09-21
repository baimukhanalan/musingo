import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:muslingo/screens/coach_screen.dart';
import 'package:muslingo/screens/friends_screen.dart';
import 'package:muslingo/screens/home_screen.dart';
import 'package:muslingo/screens/lesson_screen.dart';
import 'package:muslingo/models/lesson.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:muslingo/screens/profile_screen.dart';
import 'package:muslingo/widgets/language_pills.dart';
import 'package:muslingo/widgets/mentor_tip_card.dart';
import 'package:muslingo/widgets/daily_ayah.dart';
import 'package:muslingo/screens/install_app_screen.dart';
import 'package:muslingo/screens/league_screen.dart';
import 'package:muslingo/screens/main_tab_screen.dart';
import 'package:muslingo/screens/quran_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/widgets/cat_character.dart';
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

  testWidgets('language remains available in Profile on compact screens',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = await guestState(tester);
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context)
              .copyWith(textScaler: const TextScaler.linear(1.5)),
          child: child!,
        ),
        home: const ProfileScreen(),
      ),
    ));
    await tester.pump();
    expect(find.byType(LanguagePills), findsOneWidget);
    await tester.tap(find.text('KZ'));
    await tester.pump();
    expect(state.locale.code, 'kk');
    expect(state.nativeLanguage, NativeLanguage.kazakh);
    expect(tester.takeException(), isNull);
    await teardown(tester);
  });

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
    expect(find.byType(CustomScrollView), findsOneWidget);
    expect(find.byType(LanguagePills), findsNothing);
    expect(find.byKey(const ValueKey('learning-path-panel')), findsNothing);
    // Виден премиум-хедер с приветствием (стабильно при любом гейтинге секций).
    expect(find.textContaining('Ассаляму алейкум'), findsOneWidget);
    // Три компактные карточки статистики и голубой daily plan из референса.
    expect(find.text('серия'), findsOneWidget);
    expect(find.text('XP'), findsOneWidget);
    expect(find.text('жизни'), findsOneWidget);
    expect(find.text('Начать урок'), findsOneWidget);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is CatCharacter &&
            widget.mood == CatMood.greet &&
            widget.size == 108,
      ),
      findsOneWidget,
    );

    await teardown(tester);
  });

  testWidgets('course buttons open four immersive worlds with occasional Ayn',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = await guestState(tester);
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: state, child: const MaterialApp(home: HomeScreen())));
    await tester.pump();
    expect(find.byKey(const ValueKey('learning-path-panel-expanded')),
        findsNothing);
    final modes = {
      'quran': 'quran',
      'arabic': 'arabic',
      'basics': 'rules',
      'tajwid': 'tajwid'
    };
    for (final entry in modes.entries) {
      final button = find.byKey(ValueKey('course-mode-${entry.key}'));
      await tester.scrollUntilVisible(button, 200,
          scrollable: find.byType(Scrollable).first);
      await Scrollable.ensureVisible(tester.element(button), alignment: 0.3);
      await tester.pump();
      await tester.tap(button);
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('course-fullscreen')), findsOneWidget);
      expect(find.byKey(PageStorageKey('course-path-${entry.value}')),
          findsOneWidget);
      expect(
          find.byKey(ValueKey('learning-world-${entry.key}')), findsOneWidget);
      expect(find.byKey(const ValueKey('course-mode-quran')), findsNothing);
      expect(
          find.byKey(const ValueKey('choose-native-language')), findsNothing);
      expect(find.byKey(const ValueKey('course-fullscreen-title')),
          findsOneWidget);
      final path = tester
          .widget<CustomScrollView>(
              find.byKey(PageStorageKey('course-path-${entry.value}')))
          .controller!;
      final world = find.byKey(ValueKey('learning-world-${entry.key}'));
      final start = tester.getTopLeft(world);
      path.jumpTo(380);
      await tester.pump();
      expect(find.byKey(const ValueKey('course-ayn-3')), findsOneWidget);
      path.jumpTo(path.position.maxScrollExtent);
      await tester.pump();
      expect(tester.getTopLeft(world).dy, greaterThan(start.dy));
      await tester.tap(find.byKey(const ValueKey('collapse-learning-path')));
      await tester.pump();
      await tester.pumpAndSettle();
      expect(find.byKey(const ValueKey('course-fullscreen')), findsNothing);
      expect(tester.takeException(), isNull);
    }
    await teardown(tester);
  });

  testWidgets('daily ayah precedes course picker and personalized tip follows',
      (tester) async {
    final state = await guestState(tester);
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: state, child: const MaterialApp(home: HomeScreen())));
    await tester.pump();
    final scroll =
        tester.widget<CustomScrollView>(find.byType(CustomScrollView));
    final cards = scroll.slivers
        .whereType<SliverToBoxAdapter>()
        .map((s) => s.child)
        .toList();
    final ayah = cards.indexWhere((w) => w is DailyAyahCard);
    final mentor = cards.indexWhere((w) => w is MentorTipCard);
    expect(ayah, greaterThanOrEqualTo(0));
    expect(mentor, greaterThan(ayah));
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

  testWidgets('fullscreen hides dock, back restores home and course offset',
      (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = await guestState(tester);
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: state, child: const MaterialApp(home: MainTabScreen())));
    await tester.pump();
    final button = find.byKey(const ValueKey('course-mode-quran'));
    await tester.scrollUntilVisible(button, 200,
        scrollable: find.byType(Scrollable).first);
    await Scrollable.ensureVisible(tester.element(button), alignment: 0.3);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bottom-nav-0')), findsNothing);
    expect(find.byKey(const ValueKey('course-mode-basics')), findsNothing);
    final path = tester
        .widget<CustomScrollView>(
            find.byKey(const PageStorageKey('course-path-quran')))
        .controller!;
    path.jumpTo(750);
    await tester.pump();
    await tester.binding.handlePopRoute();
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('bottom-nav-0')), findsOneWidget);
    await Scrollable.ensureVisible(tester.element(button), alignment: 0.3);
    await tester.pump();
    await tester.tap(button);
    await tester.pump();
    await tester.pumpAndSettle();
    expect(path.offset, 750);
    await tester.tap(find.byKey(const ValueKey('collapse-learning-path')));
    await tester.pump();
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('course-fullscreen')), findsNothing);
    expect(find.byKey(const ValueKey('bottom-nav-4')), findsOneWidget);
    expect(tester.takeException(), isNull);
    await teardown(tester);
  });

  testWidgets('lesson opens above immersive course and exits back to its map',
      (tester) async {
    final state = await guestState(tester);
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
            home: const MainTabScreen(),
            onGenerateRoute: (settings) => MaterialPageRoute<void>(
                settings: settings,
                builder: (_) => LessonScreen(
                      lesson: settings.arguments! as Lesson,
                      audioPlaybackSimulator: (_) async {},
                    )))));
    await tester.pump();
    final button = find.byKey(const ValueKey('course-mode-quran'));
    await tester.scrollUntilVisible(button, 200,
        scrollable: find.byType(Scrollable).first);
    await Scrollable.ensureVisible(tester.element(button), alignment: 0.3);
    await tester.pumpAndSettle();
    await tester.tap(button);
    await tester.pumpAndSettle();
    final title = state.getCourse(CourseType.quran)!.lessons.first.title;
    await tester.tap(find.text(title));
    await tester.pumpAndSettle();
    expect(find.byType(LessonScreen), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-0')), findsNothing);
    expect(find.text('Сложный религиозный вопрос?'), findsNothing);
    await tester.tap(find.byIcon(Icons.close_rounded));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Выйти'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('course-fullscreen')), findsOneWidget);
    expect(find.byKey(const ValueKey('bottom-nav-0')), findsNothing);
    expect(tester.takeException(), isNull);
    await teardown(tester);
  });

  testWidgets(
      'all fullscreen courses fit RU KK EN at 320 390 430 with large text',
      (tester) async {
    final state = await guestState(tester);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    for (final locale in AppLocale.values) {
      await state.setLocale(locale);
      for (final width in [320.0, 390.0, 430.0]) {
        tester.view.physicalSize = Size(width, 844);
        await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
            value: state,
            child: MaterialApp(
                builder: (context, child) => MediaQuery(
                    data: MediaQuery.of(context)
                        .copyWith(textScaler: const TextScaler.linear(1.6)),
                    child: child!),
                home: const HomeScreen())));
        await tester.pump();
        for (final mode in ['quran', 'arabic', 'basics', 'tajwid']) {
          final button = find.byKey(ValueKey('course-mode-$mode'));
          await tester.scrollUntilVisible(button, 180,
              scrollable: find.byType(Scrollable).first);
          await Scrollable.ensureVisible(tester.element(button),
              alignment: 0.3);
          await tester.pumpAndSettle();
          await tester.tap(button);
          await tester.pumpAndSettle();
          final exit = find.byKey(const ValueKey('collapse-learning-path'));
          expect(exit.hitTestable(), findsOneWidget);
          expect(find.byKey(const ValueKey('course-fullscreen-title')),
              findsOneWidget);
          for (final mascot in find.byType(CatCharacter).evaluate()) {
            final rect = tester.getRect(find.byWidget(mascot.widget));
            expect(rect.left, greaterThanOrEqualTo(0));
            expect(rect.right, lessThanOrEqualTo(width));
          }
          expect(tester.takeException(), isNull,
              reason: '$mode ${locale.code} $width');
          await tester.tap(exit);
          await tester.pumpAndSettle();
        }
        await tester.pumpWidget(const SizedBox.shrink());
      }
    }
    state.dispose();
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
    expect(find.text('Сложный религиозный вопрос?'), findsNothing);
    expect(find.text('знает твой прогресс · отвечает по источникам'),
        findsNothing);
    await teardown(tester);
  });

  testWidgets('локальная подсказка не выдаётся за AI и доступна для проверки',
      (tester) async {
    final state = await guestState(tester);
    await tester.pumpWidget(
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: const MaterialApp(home: CoachScreen()),
      ),
    );
    await tester.pump();

    await tester.tap(find.text('Что повторить сегодня?'));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(find.text('Учебная подсказка · без ИИ'), findsOneWidget);
    expect(find.text('AI-объяснение'), findsNothing);
    expect(find.text('Сообщить о неточности'), findsOneWidget);

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
