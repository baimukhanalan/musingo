import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/curriculum_audio.dart';
import 'package:muslingo/models/curriculum_module.dart';
import 'package:muslingo/screens/continuous_audio_screen.dart';
import 'package:muslingo/screens/curriculum_library_screen.dart';
import 'package:muslingo/screens/curriculum_module_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/curriculum_progress_service.dart';
import 'package:muslingo/services/curriculum_repository.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/services/speech_synthesizer.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _Speech implements SpeechSynthesizer {
  final spoken = <String>[];
  final languages = <String>[];
  Completer<int>? _pending;
  int stops = 0;
  Object? stopError;
  Completer<void>? stopGate;

  void finish() => _pending?.complete(1);
  @override
  void setCompletionHandler(void Function() handler) {}
  @override
  void setErrorHandler(void Function(String) handler) {}
  @override
  Future<void> setLanguage(String value) async => languages.add(value);
  @override
  Future<void> setSpeechRate(double value) async {}
  @override
  Future<void> setPitch(double value) async {}
  @override
  Future<void> setVolume(double value) async {}
  @override
  Future<void> awaitSpeakCompletion(bool value) async {}
  @override
  Future<int> speak(String text) {
    spoken.add(text);
    _pending = Completer<int>();
    return _pending!.future;
  }

  @override
  Future<void> stop() async {
    stops++;
    if (stopError case final error?) throw error;
    if (stopGate case final gate?) await gate.future;
    if (_pending?.isCompleted == false) _pending!.complete(0);
  }
}

Future<AppState> _guest(WidgetTester tester,
    [AppLocale locale = AppLocale.ru]) async {
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
  await state.setLocale(locale);
  return state;
}

Future<void> _show(WidgetTester tester, AppState state, Widget screen,
    {double scale = 1}) async {
  await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
    value: state,
    child: MaterialApp(
      builder: (context, child) => MediaQuery(
        data: MediaQuery.of(context)
            .copyWith(textScaler: TextScaler.linear(scale)),
        child: Directionality(
          textDirection:
              state.locale.code == 'ar' ? TextDirection.rtl : TextDirection.ltr,
          child: child!,
        ),
      ),
      home: screen,
    ),
  ));
  await tester.pumpAndSettle();
}

Future<void> _reveal(
    WidgetTester tester, Finder target, String scrollKey) async {
  final scrollable = find
      .descendant(
        of: find.byKey(ValueKey(scrollKey)),
        matching: find.byType(Scrollable),
      )
      .first;
  await tester.scrollUntilVisible(target, 240,
      scrollable: scrollable, maxScrolls: 20);
  await tester.pump();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late List<CurriculumModule> modules;
  setUpAll(() async {
    await LessonContentLocalization.load();
    modules = await CurriculumRepository.load();
  });

  test('570 selectable topics split into complete course queues', () {
    expect(CurriculumAudioCatalog.queue(modules), hasLength(570));
    for (final entry in {
      'Quran': 150,
      'Arabic': 170,
      'Tajwid': 70,
      'Foundations/Academy': 180
    }.entries) {
      final queue = CurriculumAudioCatalog.queue(modules, track: entry.key);
      expect(queue, hasLength(entry.value));
      expect(queue.every((module) => module.track == entry.key), isTrue);
    }
    for (final locale in ['ru', 'kk', 'en', 'ar']) {
      final exact = CurriculumAudioCatalog.search(modules,
          query: 'fnd-180', locale: locale);
      expect(exact.single.id, 'FND-180');
      final localized =
          LessonContentLocalization.localizeModule(modules[50], locale);
      expect(
          CurriculumAudioCatalog.search(modules,
                  query: localized.title, locale: locale)
              .map((module) => module.id),
          contains(modules[50].id));
    }
  });

  test(
      'outlines use existing module facts and never synthesize Arabic recitation',
      () {
    for (final locale in ['ru', 'kk', 'en']) {
      for (final module in modules) {
        final outline = CurriculumAudioOutline.fromModule(module, locale);
        expect(outline.sections, hasLength(4), reason: '${module.id}/$locale');
        expect(outline.sections.first, contains(module.id));
        expect(outline.sections.every((section) => section.isNotEmpty), isTrue);
        final joined = outline.sections.join(' ');
        expect(joined, isNot(contains('https://')));
        expect(RegExp(r'[\u0600-\u06ff]').hasMatch(joined), isFalse,
            reason: '${module.id}/$locale');
      }
    }
  });

  testWidgets(
      'search selects the last topic and does not award lesson progress',
      (tester) async {
    final state = await _guest(tester);
    final speech = _Speech();
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await _show(
        tester,
        state,
        ContinuousAudioScreen(
            modulesFuture: Future.value(modules), speechSynthesizer: speech));
    final search = find.byKey(const ValueKey('audio-library-search'));
    await _reveal(tester, search, 'continuous-audio-scroll');
    await tester.enterText(search, 'FND-180');
    await tester.pump();
    final topic = find.byKey(const ValueKey('audio-topic-FND-180'));
    await _reveal(tester, topic, 'continuous-audio-scroll');
    await tester.tap(topic);
    await tester.pumpAndSettle();
    expect(find.text('570 / 570 · FND-180'), findsOneWidget);
    expect(
        tester
            .widget<IconButton>(
                find.byKey(const ValueKey('continuous-audio-next')))
            .onPressed,
        isNull);
    expect(speech.spoken, isEmpty);
    expect(
        (await CurriculumProgressService.load(state.user!.id)).completedCount,
        0);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('audio advances through four sections and stops after last topic',
      (tester) async {
    final state = await _guest(tester);
    final speech = _Speech();
    await _show(
        tester,
        state,
        ContinuousAudioScreen(
            modulesFuture: Future.value(modules.take(2).toList()),
            speechSynthesizer: speech));
    final toggle = find.byKey(const ValueKey('continuous-audio-toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();
    expect(speech.spoken, hasLength(1));
    for (var section = 0; section < 4; section++) {
      speech.finish();
      await tester.pump();
      await tester.pump(Duration(milliseconds: section == 3 ? 2100 : 750));
    }
    expect(speech.spoken, hasLength(5));
    expect(speech.spoken.last, contains(modules[1].id));
    for (var section = 0; section < 4; section++) {
      speech.finish();
      await tester.pump();
      await tester.pump(Duration(milliseconds: section == 3 ? 2100 : 750));
    }
    expect(speech.spoken, hasLength(8));
    expect(find.byKey(const ValueKey('continuous-audio-stop')), findsNothing);
    expect(
        (await CurriculumProgressService.load(state.user!.id)).completedCount,
        0);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('pause resumes same section and next invalidates pending speech',
      (tester) async {
    final state = await _guest(tester);
    final speech = _Speech();
    await _show(
        tester,
        state,
        ContinuousAudioScreen(
            modulesFuture: Future.value(modules.take(2).toList()),
            speechSynthesizer: speech));
    final toggle = find.byKey(const ValueKey('continuous-audio-toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();
    speech.finish();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 750));
    final preparation = speech.spoken.last;
    await tester.tap(toggle);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(speech.spoken, hasLength(2));
    await tester.tap(toggle);
    await tester.pump();
    expect(speech.spoken.last, preparation);
    await tester.tap(find.byKey(const ValueKey('continuous-audio-next')));
    await tester.pump();
    expect(speech.spoken.last, contains(modules[1].id));
    final count = speech.spoken.length;
    await tester.tap(find.byKey(const ValueKey('continuous-audio-stop')));
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(speech.spoken, hasLength(count));
    expect(find.textContaining('Не удалось'), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('session timer stops a long pending utterance', (tester) async {
    final state = await _guest(tester);
    final speech = _Speech();
    await _show(
        tester,
        state,
        ContinuousAudioScreen(
            modulesFuture: Future.value(modules.take(2).toList()),
            speechSynthesizer: speech));
    await tester.tap(find.byKey(const ValueKey('audio-duration-5')));
    final toggle = find.byKey(const ValueKey('continuous-audio-toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();
    await tester.pump(const Duration(minutes: 5, seconds: 1));
    expect(speech.stops, greaterThan(0));
    expect(speech.spoken, hasLength(1));
    expect(find.byKey(const ValueKey('continuous-audio-stop')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('rapid resume waits for native stop and remains cancellable',
      (tester) async {
    final state = await _guest(tester);
    final speech = _Speech();
    await _show(
        tester,
        state,
        ContinuousAudioScreen(
          modulesFuture: Future.value(modules.take(2).toList()),
          speechSynthesizer: speech,
        ));
    final toggle = find.byKey(const ValueKey('continuous-audio-toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();
    final firstSection = speech.spoken.single;
    speech.stopGate = Completer<void>();
    await tester.tap(toggle);
    await tester.pump();
    await tester.tap(toggle);
    await tester.pump();
    expect(speech.stops, 1,
        reason: 'One native stop is shared by both actions');
    expect(speech.spoken, hasLength(1),
        reason: 'Do not speak until the previous native utterance is stopped');
    speech.stopGate!.complete();
    await tester.pump();
    expect(speech.spoken, [firstSection, firstSection]);

    speech.stopGate = Completer<void>();
    await tester.tap(toggle);
    await tester.pump();
    await tester.tap(toggle);
    await tester.pump();
    await tester.tap(find.byKey(const ValueKey('continuous-audio-stop')));
    await tester.pump();
    speech.stopGate!.complete();
    await tester.pump();
    expect(speech.stops, 2);
    expect(speech.spoken, hasLength(2),
        reason: 'Explicit stop cancels the queued resume');
    expect(find.byKey(const ValueKey('continuous-audio-stop')), findsNothing);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
    state.dispose();
  });

  testWidgets('leaving an unplayed library never calls the speech plugin',
      (tester) async {
    final state = await _guest(tester);
    final speech = _Speech()
      ..stopError = MissingPluginException('No speech engine');
    await _show(
        tester,
        state,
        ContinuousAudioScreen(
          modulesFuture: Future.value(modules.take(2).toList()),
          speechSynthesizer: speech,
        ));
    expect(speech.spoken, isEmpty);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(speech.stops, 0);
    expect(tester.takeException(), isNull);
    state.dispose();
  });

  testWidgets('stop failures are visible and retry cannot overlap speech',
      (tester) async {
    final state = await _guest(tester);
    final speech = _Speech();
    await _show(
        tester,
        state,
        ContinuousAudioScreen(
          modulesFuture: Future.value(modules.take(2).toList()),
          speechSynthesizer: speech,
        ));
    final toggle = find.byKey(const ValueKey('continuous-audio-toggle'));
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();
    expect(speech.spoken, hasLength(1));
    final firstSection = speech.spoken.single;
    speech.stopError = MissingPluginException('Speech engine disconnected');
    await tester.tap(toggle);
    await tester.pump();
    expect(find.textContaining('Не удалось продолжить воспроизведение'),
        findsOneWidget);
    await tester.tap(toggle);
    await tester.pump();
    expect(speech.spoken, hasLength(1),
        reason: 'Never start over a failed stop');
    speech.stopError = null;
    await tester.tap(toggle);
    await tester.pump();
    expect(speech.spoken, [firstSection, firstSection]);
    expect(find.textContaining('Не удалось'), findsNothing);
    speech.stopError = MissingPluginException('Speech engine disconnected');
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
    state.dispose();
  });

  testWidgets('about and source disclosures render ink above decorated cards',
      (tester) async {
    final state = await _guest(tester);
    await _show(
        tester,
        state,
        ContinuousAudioScreen(
          modulesFuture: Future.value(modules.take(2).toList()),
          speechSynthesizer: _Speech(),
        ));
    for (final key in ['audio-library-about', 'audio-outline-sources']) {
      final disclosure = find.byKey(ValueKey(key));
      await _reveal(tester, disclosure, 'continuous-audio-scroll');
      final tile =
          find.descendant(of: disclosure, matching: find.byType(ListTile));
      await tester.ensureVisible(tile);
      await tester.tap(tile);
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
      if (key == 'audio-library-about') {
        expect(find.textContaining('Это не полная лекция'), findsOneWidget);
      } else {
        expect(find.text(modules.first.sourceLocator), findsOneWidget);
      }
    }
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    state.dispose();
  });

  for (final locale in AppLocale.values) {
    testWidgets(
        '${locale.code}: audio library filter fits a 320px phone with large text',
        (tester) async {
      final state = await _guest(tester, locale);
      final speech = _Speech();
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      await _show(
          tester,
          state,
          ContinuousAudioScreen(
              modulesFuture: Future.value(modules), speechSynthesizer: speech),
          scale: 1.4);
      final filter = find.byKey(const ValueKey('audio-track-Quran'));
      await _reveal(tester, filter, 'continuous-audio-scroll');
      await tester.tap(filter);
      await tester.pumpAndSettle();
      expect(find.textContaining('150'), findsWidgets);
      expect(tester.takeException(), isNull);
      await tester.pumpWidget(const SizedBox.shrink());
      state.dispose();
    });
  }

  testWidgets(
      'a fresh learner can open the final Academy module without prerequisites',
      (tester) async {
    final state = await _guest(tester);
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        home: CurriculumLibraryScreen(modulesFuture: Future.value(modules)),
        onGenerateRoute: (settings) => MaterialPageRoute<void>(
          builder: (_) => CurriculumModuleScreen(
              module: settings.arguments! as CurriculumModule,
              modulesFuture: Future.value(modules)),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final search = find.byKey(const ValueKey('curriculum-search'));
    await tester.ensureVisible(search);
    await tester.enterText(search, 'FND-180');
    await tester.pumpAndSettle();
    final target = find.byKey(const ValueKey('curriculum-module-FND-180'));
    await _reveal(tester, target, 'curriculum-scroll');
    await tester.tap(target);
    await tester.pumpAndSettle();
    expect(find.text('Этап 1 из 5'), findsOneWidget);
    expect(
        (await CurriculumProgressService.load(state.user!.id)).completedCount,
        0);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
