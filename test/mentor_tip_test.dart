import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/learning_profile.dart';
import 'package:muslingo/models/mentor_profile.dart';
import 'package:muslingo/models/mentor_tip.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:muslingo/widgets/cat_character.dart';
import 'package:muslingo/widgets/mentor_tip_card.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  final morning = DateTime.utc(2026, 9, 21, 6);
  MentorTip tip(
          {DateTime? now,
          AppLocale locale = AppLocale.ru,
          MentorProfile profile = const MentorProfile(),
          int due = 0,
          int progress = 0,
          DateTime? lastStudy}) =>
      MentorTip.build(
        now: now ?? morning,
        locale: locale,
        profile: profile,
        learnerName: 'Алан',
        goal: LearningGoal.arabicReading,
        dueReviews: due,
        todayProgress: progress,
        dailyGoal: 3,
        lastStudyDate: lastStudy,
      );

  test('same 12-hour window is stable across reopening and changes at expiry',
      () {
    final first = tip();
    final reopened = tip(now: morning.add(const Duration(hours: 5)));
    final refreshed = tip(now: morning.add(const Duration(hours: 6)));
    expect(reopened.id, first.id);
    expect(reopened.text, first.text);
    expect(refreshed.id, isNot(first.id));
    expect(refreshed.text, isNot(first.text));
    expect(first.refreshAt, DateTime.utc(2026, 9, 21, 12));
    expect(refreshed.refreshAt.difference(first.refreshAt), MentorTip.cadence);
  });

  test('uses saved name, session duration and explicit current focus', () {
    final result = tip(
        profile: const MentorProfile(
            preferredName: 'Айша',
            currentFocus: 'Таджвид',
            preferredSessionMinutes: 12));
    expect(result.text, contains('Айша'));
    expect(result.text, contains('Таджвид'));
    expect(result.text, contains('12 минут'));
  });

  test('disabled personalization does not surface personal profile details',
      () {
    for (final profile in const [
      MentorProfile(
          memoryEnabled: false,
          preferredName: 'СЕКРЕТ',
          currentFocus: 'ЛИЧНОЕ',
          birthdayMonth: 9,
          birthdayDay: 21),
      MentorProfile(
          personalizedRemindersEnabled: false,
          preferredName: 'СЕКРЕТ',
          currentFocus: 'ЛИЧНОЕ',
          birthdayMonth: 9,
          birthdayDay: 21),
    ]) {
      final result = tip(profile: profile);
      expect(result.text, isNot(contains('СЕКРЕТ')));
      expect(result.text, isNot(contains('ЛИЧНОЕ')));
      expect(result.text, isNot(contains('Алан')));
      expect(result.text, isNot(contains('рождения')));
    }
  });

  test('raw memories never leak onto the home tip', () {
    final result = tip(
        profile: MentorProfile(memories: [
      MentorMemory(id: '1', text: 'secret phone 12345', createdAt: morning),
    ]));
    expect(result.text, isNot(contains('secret')));
  });

  test('real progress and review counts select matching emotion', () {
    expect(tip(due: 7).text, contains('7'));
    expect(tip(due: 7).mood, MentorTipMood.focus);
    expect(tip(progress: 3).text, contains('3/3'));
    expect(tip(progress: 3).mood, MentorTipMood.celebrate);
    expect(tip(lastStudy: morning.subtract(const Duration(days: 5))).mood,
        MentorTipMood.encourage);
  });

  test('birthday is optional and only on the saved date', () {
    const profile = MentorProfile(birthdayMonth: 9, birthdayDay: 21);
    expect(tip(profile: profile).text, contains('с днём рождения'));
    expect(tip(profile: profile).mood, MentorTipMood.celebrate);
    expect(
        tip(profile: profile.copyWith(birthdayCelebrationsEnabled: false)).text,
        isNot(contains('рождения')));
    expect(
        tip(now: morning.add(const Duration(days: 1)), profile: profile).text,
        isNot(contains('рождения')));
  });

  test('all three languages and each priority rotate after 12 hours', () {
    for (final locale in AppLocale.values) {
      for (final values in [(0, 0), (7, 0), (0, 3)]) {
        final a = tip(locale: locale, due: values.$1, progress: values.$2);
        final b = tip(
            locale: locale,
            due: values.$1,
            progress: values.$2,
            now: morning.add(const Duration(hours: 12)));
        expect(a.text, isNot(b.text));
        if (locale != AppLocale.ru) {
          expect(a.text, isNot(contains('следующий шаг')));
        }
      }
    }
  });

  Future<AppState> guest(WidgetTester tester) async {
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

  testWidgets('perfect placement does not invent a weak skill', (tester) async {
    final state = await guest(tester);
    await state.completePlacement(
      goal: LearningGoal.shortSurahs,
      level: 8,
      recommendation: 'Placement complete',
      skillProfile: LearningSkillProfile(
          {for (final skill in LearningSkill.values) skill: 100}),
    );
    final result = state.mentorTipAt(morning);
    expect(result.text, contains('Выучить короткие суры'));
    expect(result.text, isNot(contains('укрепим навык')));
    state.dispose();
  });

  testWidgets('visible tip refreshes at boundary and after background resume',
      (tester) async {
    final state = await guest(tester);
    var now = DateTime.utc(2026, 9, 21, 11, 59, 59, 980);
    await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
        value: state,
        child: MaterialApp(
            home:
                Scaffold(body: MentorTipCard(now: () => now, onTap: () {})))));
    String message() => tester
        .widget<Text>(find.byKey(const ValueKey('mentor-tip-message')))
        .data!;
    final first = message();
    now = now.add(const Duration(milliseconds: 20));
    await tester.pump(const Duration(milliseconds: 21));
    expect(message(), isNot(first));
    now = now.add(const Duration(hours: 12));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(message(), first);
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });

  testWidgets('tip fits compact large text and shows the matching 2D emotion',
      (tester) async {
    tester.view.physicalSize = const Size(320, 568);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    final state = await guest(tester);
    await state.updateMentorProfile(const MentorProfile(
        birthdayMonth: 9, birthdayDay: 21, preferredName: 'Айша'));
    for (final locale in AppLocale.values) {
      await state.setLocale(locale);
      await tester.pumpWidget(ChangeNotifierProvider<AppState>.value(
          value: state,
          child: MaterialApp(
              builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(context)
                      .copyWith(textScaler: const TextScaler.linear(1.6)),
                  child: child!),
              home: Scaffold(
                  body: SingleChildScrollView(
                      child:
                          MentorTipCard(now: () => morning, onTap: () {}))))));
      await tester.pump();
      expect(tester.widget<CatCharacter>(find.byType(CatCharacter)).mood,
          CatMood.praise);
      expect(tester.takeException(), isNull);
    }
    await tester.pumpWidget(const SizedBox.shrink());
    state.dispose();
  });
}
