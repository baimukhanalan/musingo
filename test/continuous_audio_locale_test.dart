import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/curriculum_module.dart';
import 'package:muslingo/screens/continuous_audio_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/curriculum_repository.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/services/speech_synthesizer.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _RecordingSpeech implements SpeechSynthesizer {
  final languages = <String>[];
  final spoken = <String>[];
  int? immediateResult;
  Completer<int>? _completion;
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
    if (immediateResult != null) return Future.value(immediateResult);
    _completion = Completer<int>();
    return _completion!.future;
  }

  @override
  Future<void> stop() async {
    if (_completion?.isCompleted == false) _completion!.complete(0);
  }
}

void main() {
  testWidgets('continuous audio switches both module text and voice language',
      (tester) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    late final CurriculumModule module;
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 10));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      module = (await CurriculumRepository.load()).first;
    });
    expect(state.isInitialized, isTrue);
    await state.loginAsGuest();
    await state.setLocale(AppLocale.kk);
    final speech = _RecordingSpeech();
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
      value: state,
      child: MaterialApp(
        home: ContinuousAudioScreen(
          modulesFuture: Future.value([module]),
          speechSynthesizer: speech,
        ),
      ),
    ));
    await tester.pump();
    final kk = LessonContentLocalization.localizeModule(module, 'kk');
    expect(find.text(kk.title), findsOneWidget);
    final toggle = find.byKey(const ValueKey('continuous-audio-toggle'));
    await tester.ensureVisible(toggle);
    await tester.pump();
    await tester.tap(toggle);
    await tester.pump();
    expect(speech.languages.last, 'kk-KZ');
    expect(speech.spoken.last, contains(kk.objective));

    await state.setLocale(AppLocale.en);
    await tester.pump();
    await tester.pump();
    final en = LessonContentLocalization.localizeModule(module, 'en');
    expect(find.text(en.title), findsOneWidget);
    expect(speech.languages.last, 'en-US');
    expect(speech.spoken.last, contains(en.objective));
    expect(speech.spoken, hasLength(2));

    // User pause cancels the pending utterance with result 0, without an error
    // or a stale completion advancing the playlist.
    await tester.ensureVisible(toggle);
    await tester.tap(toggle);
    await tester.pump();
    expect(speech.spoken, hasLength(2));
    expect(find.textContaining('Не удалось'), findsNothing);
    expect(find.textContaining('could not'), findsNothing);

    // A genuine no-start result must not silently move to the next module.
    speech.immediateResult = 0;
    await tester.tap(toggle);
    await tester.pump();
    await tester.pump(const Duration(seconds: 3));
    expect(speech.spoken, hasLength(3));
    expect(find.text(en.title), findsOneWidget);
    expect(find.textContaining('Playback could not continue'), findsOneWidget);
    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump();
    expect(tester.takeException(), isNull);
    state.dispose();
  });
}
