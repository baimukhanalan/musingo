import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/quran_audio_player.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:muslingo/widgets/daily_ayah.dart';

class _TestAudioPlayer implements QuranAudioPlayer {
  final events = StreamController<QuranAudioPlaybackState>.broadcast();
  Completer<void>? startGate;
  bool failToStart = false;
  final sources = <String>[];
  int starts = 0;
  int stops = 0;

  @override
  Stream<QuranAudioPlaybackState> get playbackStateStream => events.stream;
  @override
  Future<void> setUrl(String url) async => sources.add(url);
  @override
  Future<void> setFile(String path) => setUrl(path);
  @override
  Future<void> play() async {
    starts++;
    if (failToStart) throw StateError('test network detail');
    await startGate?.future;
  }

  @override
  Future<void> playUrl(String url) async {
    await setUrl(url);
    await play();
  }

  @override
  Future<void> playFile(String path) => playUrl(path);
  @override
  Future<void> pause() async {}
  @override
  Future<void> stop() async => stops++;
  @override
  void dispose() => events.close();
}

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

    test('does not label Russian translations as Kazakh or English', () {
      const ayah = AyahOfDay(
        globalAyahNumber: 1,
        arabic: 'arabic',
        transliteration: 'transliteration',
        translation: 'russian-only',
      );
      expect(ayah.secondaryTextFor(AppLocale.ru), 'russian-only');
      expect(ayah.secondaryTextFor(AppLocale.kk), 'transliteration');
      expect(ayah.secondaryTextFor(AppLocale.en), 'transliteration');
      expect(ayah.translationFor(AppLocale.kk), isNull);
    });

    test('every daily ayah has localized text for cards and reminders',
        () async {
      await LessonContentLocalization.load();
      for (final ayah in DailyAyahData.buildPool()) {
        for (final locale in [AppLocale.kk, AppLocale.en]) {
          final translation = ayah.translationFor(locale);
          expect(translation, isNotNull,
              reason: '${ayah.globalAyahNumber} ${locale.code}');
          expect(translation, isNot(ayah.translation));
          expect(ayah.secondaryTextFor(locale), translation);
        }
        expect(ayah.transliterationFor(AppLocale.en),
            isNot(matches(RegExp('[А-Яа-яЁё]'))));
      }
    });

    test('missing English translation falls back to Latin phonetics', () {
      const ayah = AyahOfDay(
        globalAyahNumber: 1,
        arabic: 'arabic',
        transliteration: 'Бисмиллях',
        translation: 'not-in-bundled-dictionary',
      );
      expect(ayah.translationFor(AppLocale.en), isNull);
      expect(ayah.secondaryTextFor(AppLocale.en), 'Bismillyakh');
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

  Future<AppState> mountPlayer(
      WidgetTester tester, _TestAudioPlayer player) async {
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
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        home: Scaffold(
          body: DailyAyahCard(
            date: DateTime(2026, 8, 25),
            audioPlayerFactory: () => player,
          ),
        ),
      ),
    ));
    await tester.pump();
    return state;
  }

  testWidgets('preloads one ayah without autoplay and keeps stop until ended',
      (tester) async {
    final player = _TestAudioPlayer();
    await mountPlayer(tester, player);
    expect(player.sources, hasLength(1));
    expect(player.starts, 0);

    await tester.tap(find.text('Прослушать'));
    await tester.pump();
    expect(player.sources, hasLength(1));
    expect(player.starts, 1);
    expect(find.text('Остановить'), findsOneWidget);

    player.events
        .add(const QuranAudioPlaybackState(playing: false, completed: true));
    await tester.pump();
    expect(find.text('Прослушать'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'card switches translation, phonetics and disclosure with language',
      (tester) async {
    final player = _TestAudioPlayer();
    final state = await mountPlayer(tester, player);
    final ayah = DailyAyahData.ofDay(DateTime(2026, 8, 25))!;
    await state.setLocale(AppLocale.en);
    await tester.pump();
    expect(find.text(ayah.translationFor(AppLocale.en)!), findsOneWidget);
    expect(find.text(ayah.transliterationFor(AppLocale.en)), findsOneWidget);
    expect(find.text('Automatic translation · editorial review pending'),
        findsOneWidget);
    await state.setLocale(AppLocale.kk);
    await tester.pump();
    expect(find.text(ayah.translationFor(AppLocale.kk)!), findsOneWidget);
    expect(find.text('Автоматты аударма · редактор тексеруі қажет'),
        findsOneWidget);
    expect(player.sources, hasLength(1));
    expect(player.starts, 0);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets(
      'shows immediate loading feedback and cancellation stays cancelled',
      (tester) async {
    final player = _TestAudioPlayer()..startGate = Completer<void>();
    await mountPlayer(tester, player);
    await tester.tap(find.text('Прослушать'));
    await tester.pump();
    expect(find.text('Загрузка · отменить'), findsOneWidget);
    expect(find.byType(CircularProgressIndicator), findsOneWidget);

    await tester.tap(find.text('Загрузка · отменить'));
    await tester.pump();
    expect(player.stops, 1);
    expect(find.text('Прослушать'), findsOneWidget);
    player.startGate!.complete();
    await tester.pump();
    expect(find.text('Остановить'), findsNothing);
    expect(player.starts, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('failed playback restores retry and does not expose raw errors',
      (tester) async {
    final player = _TestAudioPlayer()..failToStart = true;
    await mountPlayer(tester, player);
    await tester.tap(find.text('Прослушать'));
    await tester.pump();
    expect(find.text('Прослушать'), findsOneWidget);
    expect(find.textContaining('Проверьте соединение'), findsOneWidget);
    expect(find.textContaining('test network detail'), findsNothing);
    player.failToStart = false;
    await tester.tap(find.text('Прослушать'));
    await tester.pump();
    expect(find.text('Остановить'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('a day change invalidates an old pending start', (tester) async {
    final player = _TestAudioPlayer()..startGate = Completer<void>();
    final state = await mountPlayer(tester, player);
    await tester.tap(find.text('Прослушать'));
    await tester.pump();
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        home: Scaffold(
          body: DailyAyahCard(
            date: DateTime(2026, 8, 26),
            audioPlayerFactory: () => player,
          ),
        ),
      ),
    ));
    await tester.pump();
    expect(player.sources, hasLength(2));
    expect(player.sources[0], isNot(player.sources[1]));
    player.startGate!.complete();
    await tester.pump();
    expect(find.text('Прослушать'), findsOneWidget);
    expect(find.text('Остановить'), findsNothing);
    expect(player.starts, 1);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('disposing during loading does not update a removed card',
      (tester) async {
    final player = _TestAudioPlayer()..startGate = Completer<void>();
    await mountPlayer(tester, player);
    await tester.tap(find.text('Прослушать'));
    await tester.pump();
    await tester.pumpWidget(const SizedBox.shrink());
    player.startGate!.complete();
    await tester.pump();
    expect(tester.takeException(), isNull);
    expect(player.starts, 1);
  });
}
