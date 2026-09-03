import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:muslingo/widgets/daily_ayah.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const pool = <AyahOfDay>[
    AyahOfDay(
      globalAyahNumber: 1,
      arabic: 'one',
      transliteration: 'one',
      translation: 'one',
    ),
    AyahOfDay(
      globalAyahNumber: 2,
      arabic: 'two',
      transliteration: 'two',
      translation: 'two',
    ),
    AyahOfDay(
      globalAyahNumber: 3,
      arabic: 'three',
      transliteration: 'three',
      translation: 'three',
    ),
  ];

  group('DailyAyahData', () {
    test('keeps the same ayah throughout one local calendar day', () {
      final morning = DailyAyahData.ofDay(
        DateTime(2026, 8, 25, 0, 1),
        pool: pool,
      );
      final evening = DailyAyahData.ofDay(
        DateTime(2026, 8, 25, 23, 59),
        pool: pool,
      );

      expect(evening?.globalAyahNumber, morning?.globalAyahNumber);
    });

    test('changes on every adjacent calendar day, including New Year', () {
      final dates = <DateTime>[
        DateTime(2026, 8, 25),
        DateTime(2026, 8, 26),
        DateTime(2026, 12, 31),
        DateTime(2027, 1, 1),
      ];

      for (var index = 0; index < dates.length; index += 2) {
        final first = DailyAyahData.ofDay(dates[index], pool: pool);
        final next = DailyAyahData.ofDay(dates[index + 1], pool: pool);
        expect(next?.globalAyahNumber, isNot(first?.globalAyahNumber));
      }
    });

    test('uses a complete verified pool and handles an empty pool', () {
      final realPool = DailyAyahData.buildPool();

      expect(realPool.length, greaterThan(30));
      expect(realPool.map((ayah) => ayah.globalAyahNumber).toSet().length,
          realPool.length);
      expect(
          DailyAyahData.ofDay(DateTime(2026, 8, 25), pool: const []), isNull);
    });

    test('calculates the exact delay until the next local day', () {
      expect(
        DailyAyahData.untilNextLocalDay(DateTime(2026, 8, 25, 23, 59, 30)),
        const Duration(seconds: 30),
      );
    });

    test('builds 28 dated lock-screen messages with changing ayahs', () {
      final messages = DailyAyahData.notificationMessages(
        start: DateTime(2026, 9, 5, 8, 15),
        count: 28,
        locale: AppLocale.ru,
      );

      expect(messages, hasLength(28));
      expect(messages.every((message) => message.title.startsWith('Аят дня')),
          isTrue);
      expect(messages.every((message) => message.body.contains('\n')), isTrue);
      expect(messages[0].body, isNot(messages[1].body));
    });
  });

  testWidgets('card refreshes when its supplied calendar date changes',
      (tester) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
    });
    await state.loginAsGuest();

    Widget appFor(DateTime date) => ChangeNotifierProvider<AppState>.value(
          value: state,
          child: MaterialApp(
            home: Scaffold(body: DailyAyahCard(date: date)),
          ),
        );

    await tester.pumpWidget(appFor(DateTime(2026, 8, 25)));
    final firstNumber = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? '')
        .firstWhere((text) => text.startsWith('аят №'));

    await tester.pumpWidget(appFor(DateTime(2026, 8, 26)));
    await tester.pump();
    final nextNumber = tester
        .widgetList<Text>(find.byType(Text))
        .map((text) => text.data ?? '')
        .firstWhere((text) => text.startsWith('аят №'));

    expect(nextNumber, isNot(firstNumber));
    expect(tester.takeException(), isNull);

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
  });
}
