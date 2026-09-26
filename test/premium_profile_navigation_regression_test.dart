import 'dart:ui' show SemanticsAction;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/achievements_screen.dart';
import 'package:muslingo/screens/main_tab_screen.dart';
import 'package:muslingo/screens/profile_screen.dart';
import 'package:muslingo/screens/streak_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localization_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  Future<AppState> guestState(WidgetTester tester) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    expect(state.isInitialized, isTrue);
    await state.loginAsGuest();
    return state;
  }

  Widget host(AppState state, Widget page,
          {double scale = 1,
          bool reducedMotion = false,
          double keyboard = 0}) =>
      ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          locale: state.locale.toLocale(),
          supportedLocales: testSupportedLocales,
          localizationsDelegates: testLocalizationDelegates,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(scale),
              disableAnimations: reducedMotion,
              viewInsets: EdgeInsets.only(bottom: keyboard),
            ),
            child: child!,
          ),
          home: page,
          onGenerateRoute: (settings) => MaterialPageRoute<void>(
            settings: settings,
            builder: (_) => Scaffold(body: Text('opened:${settings.name}')),
          ),
        ),
      );

  testWidgets('profile and all achievement categories reflow in RU KK EN',
      (tester) async {
    final state = await guestState(tester);
    addTearDown(state.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    for (final locale in AppLocale.values) {
      await state.setLocale(locale);
      for (final width in [320.0, 390.0, 430.0]) {
        for (final scale in [1.0, 1.6]) {
          tester.view.physicalSize = Size(width, 844);
          await tester
              .pumpWidget(host(state, const ProfileScreen(), scale: scale));
          await tester.pump();
          expect(tester.takeException(), isNull,
              reason: 'profile ${locale.code} $width x$scale');
          await tester.pumpWidget(const SizedBox.shrink());
          await tester
              .pumpWidget(host(state, const StreakScreen(), scale: scale));
          await tester.pump();
          expect(tester.takeException(), isNull,
              reason: 'streak ${locale.code} $width x$scale');
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pumpWidget(
              host(state, const AchievementsScreen(), scale: scale));
          await tester.pump();
          expect(state.locale, locale);
          expect(
              find.text(switch (locale) {
                AppLocale.ru => '10 уроков',
                AppLocale.kk => '10 сабақ',
                AppLocale.en => '10 lessons',
                AppLocale.ar => '10 دروس',
              }),
              findsOneWidget,
              reason: 'localized title ${locale.code} $width x$scale');
          expect(find.byIcon(Icons.school_rounded), findsOneWidget);
          for (var category = 0; category < 4; category++) {
            final tabs = find.byType(Tab);
            await tester.ensureVisible(tabs.at(category));
            await tester.tap(tabs.at(category));
            await tester.pump();
            await tester.pump(const Duration(milliseconds: 350));
            expect(tester.takeException(), isNull,
                reason: 'achievements $category ${locale.code} $width x$scale');
          }
          await tester.pumpWidget(const SizedBox.shrink());
          await tester.pump();
        }
      }
    }
  });

  testWidgets('week has visible state icons and accessible explanation',
      (tester) async {
    final state = await guestState(tester);
    addTearDown(state.dispose);
    await tester.pumpWidget(host(state, const ProfileScreen()));
    await tester.pump();
    for (var day = 0; day < 7; day++) {
      final item = find.byKey(ValueKey('profile-week-day-$day'));
      expect(item, findsOneWidget);
      expect(find.descendant(of: item, matching: find.byType(Icon)),
          findsOneWidget);
    }
    final calendar = find.byKey(const ValueKey('profile-week-details'));
    await tester.ensureVisible(calendar);
    await tester.tap(calendar);
    await tester.pumpAndSettle();
    expect(find.text('opened:/streak'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'guest reset warns of data removal and cancellation preserves user',
      (tester) async {
    final state = await guestState(tester);
    addTearDown(state.dispose);
    await tester.pumpWidget(host(state, const ProfileScreen()));
    await tester.pump();
    final reset = find.text('Начать заново');
    await tester.ensureVisible(reset);
    await tester.tap(reset);
    await tester.pumpAndSettle();
    expect(find.text('Сбросить прогресс?'), findsOneWidget);
    expect(find.textContaining('будут удалены'), findsOneWidget);
    expect(find.text('Твой прогресс сохранится'), findsNothing);
    await tester.tap(find.text('Отмена'));
    await tester.pumpAndSettle();
    expect(state.isGuest, isTrue);
    expect(state.user, isNotNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'floating navigation has safe targets, a moving pill and no bounce',
      (tester) async {
    final semantics = tester.ensureSemantics();
    final state = await guestState(tester);
    addTearDown(state.dispose);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(320, 844);
    await tester.pumpWidget(
        host(state, const MainTabScreen(), scale: 1.6, reducedMotion: true));
    await tester.pump();
    final capsule = find.byKey(const ValueKey('floating-navigation-capsule'));
    final capsuleRect = tester.getRect(capsule);
    expect(capsuleRect.left, greaterThanOrEqualTo(12));
    expect(capsuleRect.right, lessThanOrEqualTo(308));
    final homeSemantics = tester.getSemantics(find.bySemanticsLabel('Главная'));
    expect(homeSemantics.getSemanticsData().hasAction(SemanticsAction.tap),
        isTrue);
    for (var tab = 0; tab < 5; tab++) {
      final control = find.byKey(ValueKey('bottom-nav-$tab'));
      expect(tester.getSize(control).width, greaterThanOrEqualTo(48));
      expect(tester.getSize(control).height, greaterThanOrEqualTo(48));
      await tester.tap(control);
      await tester.pump();
      final pill = find.byKey(const ValueKey('bottom-nav-selected-pill'));
      expect(
          tester.getCenter(pill).dx, closeTo(tester.getCenter(control).dx, 1));
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(host(state, const MainTabScreen(initialIndex: 2),
        keyboard: 300, reducedMotion: true));
    await tester.pump();
    expect(capsule, findsNothing,
        reason: 'keyboard should have space for the coach composer');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    semantics.dispose();
  });

  testWidgets(
      'streak calendar aligns dates to Monday without fabricated history',
      (tester) async {
    final state = await guestState(tester);
    addTearDown(state.dispose);
    await tester.pumpWidget(host(state, const StreakScreen()));
    await tester.pump();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final firstDay = today.subtract(Duration(days: today.weekday - 1 + 14));
    expect(firstDay.weekday, DateTime.monday);
    for (var index = 0; index < 21; index++) {
      final day = firstDay.add(Duration(days: index));
      final key =
          ValueKey('streak-calendar-${day.toIso8601String().substring(0, 10)}');
      final cell = find.byKey(key);
      expect(cell, findsOneWidget);
      expect(find.descendant(of: cell, matching: find.byType(Icon)),
          findsOneWidget);
      expect(
          find.descendant(
              of: cell,
              matching: find.byIcon(Icons.local_fire_department_rounded)),
          findsNothing,
          reason: 'a new profile must not receive study days in advance');
    }
    await tester.pumpWidget(const SizedBox.shrink());
  });
}
