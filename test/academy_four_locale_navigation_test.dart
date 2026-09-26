import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/curriculum_module.dart';
import 'package:muslingo/screens/academy_modes_screen.dart';
import 'package:muslingo/screens/curriculum_module_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/curriculum_repository.dart';
import 'package:muslingo/services/lesson_content_localization.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'support/localization_host.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late List<CurriculumModule> modules;
  setUpAll(() async {
    await LessonContentLocalization.load();
  });

  for (final locale in AppLocale.values) {
    testWidgets('${locale.code}: find last module, open, return, and listen',
        (tester) async {
      SharedPreferences.resetStatic();
      SharedPreferences.setMockInitialValues({});
      CurriculumRepository.clearCacheForTesting();
      final state = AppState();
      await tester.runAsync(() async {
        final deadline = DateTime.now().add(const Duration(seconds: 10));
        while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
          await Future<void>.delayed(const Duration(milliseconds: 10));
        }
        await state.loginAsGuest();
        await state.setLocale(locale);
        modules = await CurriculumRepository.load();
      });
      expect(state.isInitialized, isTrue);
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
          locale: locale.toLocale(),
          supportedLocales: testSupportedLocales,
          localizationsDelegates: testLocalizationDelegates,
          home: AcademyModesScreen(modulesFuture: Future.value(modules)),
          onGenerateRoute: (settings) {
            if (settings.name != '/curriculum-module') return null;
            return MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => CurriculumModuleScreen(
                module: settings.arguments! as CurriculumModule,
                modulesFuture: Future.value(modules),
              ),
            );
          },
        ),
      ));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('academy-learn-mode')), findsOneWidget);
      expect(find.byKey(const ValueKey('curriculum-scroll')), findsOneWidget,
          reason: find
              .byType(Text)
              .evaluate()
              .map((element) => (element.widget as Text).data)
              .whereType<String>()
              .join(' | '));
      expect(
          find.text(
              state.tr(ru: 'Учиться', kk: 'Оқу', en: 'Learn', ar: 'تعلّم')),
          findsOneWidget);
      expect(Directionality.of(tester.element(find.byType(AcademyModesScreen))),
          locale.isRtl ? TextDirection.rtl : TextDirection.ltr);

      final foundations = find.text(state.tr(
          ru: 'Основы · 180', kk: 'Негіздер · 180', en: 'Foundations · 180'));
      await tester.ensureVisible(foundations);
      await tester.tap(foundations);
      await tester.pump();
      expect(
          find.text(state.tr(
              ru: 'Найдено: 180', kk: 'Табылды: 180', en: 'Found: 180')),
          findsOneWidget);

      final search = find.byKey(const ValueKey('curriculum-search'));
      await tester.scrollUntilVisible(search, -200,
          scrollable: find
              .descendant(
                of: find.byKey(const ValueKey('curriculum-scroll')),
                matching: find.byType(Scrollable),
              )
              .first,
          maxScrolls: 20);
      await tester.enterText(search, 'FND-180');
      await tester.pump();
      final lastCard = find.byKey(const ValueKey('curriculum-module-FND-180'));
      expect(lastCard, findsOneWidget);
      await tester.ensureVisible(lastCard);
      await tester.tap(lastCard);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      final last = modules.singleWhere((module) => module.id == 'FND-180');
      final localized =
          LessonContentLocalization.localizeModule(last, locale.code);
      expect(find.text(localized.title), findsOneWidget);
      expect(find.byKey(const ValueKey('curriculum-stage-0')), findsOneWidget);
      await tester.tap(find.byKey(const ValueKey('curriculum-close')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(lastCard, findsOneWidget);
      expect(find.text(localized.title), findsOneWidget);

      await tester.tap(find.byKey(const ValueKey('academy-mode-1')));
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.byKey(const ValueKey('academy-listen-mode')), findsOneWidget);
      final audioSearch = find.byKey(const ValueKey('audio-library-search'));
      await tester.scrollUntilVisible(audioSearch, 220,
          scrollable: find
              .descendant(
                of: find.byKey(const ValueKey('continuous-audio-scroll')),
                matching: find.byType(Scrollable),
              )
              .first,
          maxScrolls: 20);
      await tester.enterText(audioSearch, 'FND-180');
      await tester.pump();
      final topic = find.byKey(const ValueKey('audio-topic-FND-180'));
      expect(topic, findsOneWidget);
      await tester.ensureVisible(topic);
      await tester.tap(topic);
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));
      expect(find.textContaining(localized.title), findsWidgets);
      expect(tester.takeException(), isNull);

      await tester.pumpWidget(const SizedBox.shrink());
      await tester.pump();
      state.dispose();
    });
  }
}
