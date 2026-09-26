import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/models/daily_ayah.dart';
import 'package:muslingo/models/learning_profile.dart';
import 'package:muslingo/models/mentor_profile.dart';
import 'package:muslingo/models/mentor_tip.dart';
import 'package:muslingo/models/notification_copy.dart';
import 'package:muslingo/models/reminder_message.dart';
import 'package:muslingo/screens/main_tab_screen.dart';
import 'package:muslingo/screens/settings_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:muslingo/services/learning_recommendation_localization.dart';
import 'package:muslingo/utils/app_locale.dart';
import 'package:muslingo/widgets/language_pills.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final arabic = RegExp(r'[\u0600-\u06ff]');
  final cyrillic = RegExp(r'[\u0400-\u04ff]');

  test('Arabic round trips as a distinct right-to-left locale', () {
    expect(AppLocale.fromCode('ar'), AppLocale.ar);
    expect(AppLocale.fromLabel('العربية'), AppLocale.ar);
    expect(AppLocale.ar.toLocale(), const Locale('ar'));
    expect(AppLocale.ar.isRtl, isTrue);
    expect(AppLocale.en.isRtl, isFalse);
    expect(NativeLanguage.fromCode('ar'), NativeLanguage.arabic);
    for (final goal in LearningGoal.values) {
      expect(goal.titleFor(AppLocale.ar), matches(arabic));
      expect(goal.dailyFocusFor(AppLocale.ar), isNot(matches(cyrillic)));
    }
    for (final skill in LearningSkill.values) {
      expect(skill.titleFor(AppLocale.ar), matches(arabic));
    }
    expect(
        LearningRecommendationLocalization.localize(
            'Start with the Arabic letters and their sounds. The first lesson helps you see the differences and train your ear right away.',
            'ar'),
        matches(arabic));
  });

  test('Arabic mentor memory rejects sensitive details, even with diacritics',
      () {
    for (final value in [
      'كلمة مروري هي secret',
      'كَلِمَةُ مُرُورِي هي secret',
      'رمز التحقق هو 123456',
      'رقم بطاقتي ٤١١١١١١١١١١١١١١١',
      'عنواني شارع الاختبار',
      'أسكن في شارع الاختبار',
      'تشخيصي الطبي سري',
      'أعاني من مرض مزمن',
      'علاقتي الحميمية خاصة',
      'بريدي user@example.test',
      'my password is secret',
      'мой пароль секрет',
    ]) {
      expect(MentorMemory.isSensitiveText(value), isTrue, reason: value);
    }
    for (final value in [
      'أفضل الدراسة صباحًا',
      'هدفي حفظ السور القصيرة',
      'أريد مراجعة القرآن لمدة 7 دقائق يوميًا',
    ]) {
      expect(MentorMemory.isSensitiveText(value), isFalse, reason: value);
    }
  });

  test('Arabic daily ayah preserves source without Russian secondary text', () {
    const source = 'بِسْمِ اللَّهِ الرَّحْمَنِ الرَّحِيمِ';
    const ayah = AyahOfDay(
        globalAyahNumber: 1,
        arabic: source,
        transliteration: 'Бисмиллях',
        translation: 'Во имя Аллаха');
    expect(ayah.arabic, source);
    expect(ayah.translationFor(AppLocale.ar), isNull);
    expect(ayah.transliterationFor(AppLocale.ar), isEmpty);
    expect(ayah.secondaryTextFor(AppLocale.ar), isEmpty);
    const copy = NotificationCopy('ar');
    expect(copy.open, 'بدء الدرس');
    expect(copy.later, 'لاحقًا');
    expect(copy.channelDescription, matches(arabic));
    expect(copy.visibleTitle('Private name', false), 'Muslingo');
    expect(copy.visibleBody('Private goal', false), isNot(contains('Private')));
    expect(copy.visibleBody('Private goal', false), matches(arabic));
  });

  test('all reminder contexts rotate in Arabic and fill their placeholders',
      () {
    for (var day = 1; day <= 8; day++) {
      for (final streak in [0, 2, 3, 7]) {
        final messages = buildReminders(
          name: 'علي',
          streak: streak,
          dueCount: 5,
          locale: AppLocale.ar,
          now: DateTime(2026, 9, day),
          isBirthday: true,
          nextLessonTitle: 'الفاتحة',
          currentFocus: 'القراءة',
          tone: 'focused',
        );
        for (final message in messages) {
          expect(message.title, matches(arabic));
          expect(message.body, matches(arabic));
          expect('${message.title} ${message.body}', isNot(matches(cyrillic)));
          expect('${message.title} ${message.body}', isNot(contains('{')));
        }
      }
    }
    final streak =
        buildStreakReminder(name: 'Guest', streak: 2, locale: AppLocale.ar);
    expect('${streak.title} ${streak.body}', isNot(contains('Guest')));
    expect(streak.body, matches(arabic));
  });

  test('Ayn tips support Arabic across every priority and both 12-hour windows',
      () {
    final now = DateTime.utc(2026, 9, 21, 6);
    for (final offset in [0, 12]) {
      for (final context in [
        'birthday',
        'complete',
        'review',
        'return',
        'skill',
        'next',
        'focused'
      ]) {
        final tip = MentorTip.build(
          now: now.add(Duration(hours: offset)),
          locale: AppLocale.ar,
          profile: MentorProfile(
            preferredName: 'علي',
            birthdayMonth: context == 'birthday' ? 9 : null,
            birthdayDay: context == 'birthday' ? 21 : null,
            tone: context == 'focused' ? MentorTone.focused : MentorTone.gentle,
          ),
          goal: LearningGoal.quranMeaning,
          todayProgress: context == 'complete' ? 3 : 0,
          dueReviews: context == 'review' ? 5 : 0,
          weakItems: context == 'skill' ? 1 : 0,
          weakestSkill: context == 'skill' ? LearningSkill.tajwid : null,
          lastStudyDate: context == 'return'
              ? now.subtract(const Duration(days: 5))
              : null,
        );
        expect(tip.id, contains('-ar-'));
        expect(tip.text, startsWith('علي، '));
        expect(tip.text, matches(arabic));
        expect(tip.text, isNot(matches(cyrillic)));
        expect(tip.text, isNot(contains('your')));
      }
    }
    final private = MentorTip.build(
        now: now,
        locale: AppLocale.ar,
        profile: const MentorProfile(
            memoryEnabled: false,
            preferredName: 'PRIVATE',
            currentFocus: 'SECRET'));
    expect(private.text, isNot(contains('PRIVATE')));
    expect(private.text, isNot(contains('SECRET')));
  });

  Future<AppState> guest(WidgetTester tester) async {
    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    addTearDown(state.dispose);
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 15));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
    });
    expect(state.isInitialized, isTrue);
    return state;
  }

  Widget host(AppState state, Widget child) => ChangeNotifierProvider.value(
      value: state,
      child: Consumer<AppState>(
          builder: (_, state, __) => MaterialApp(
                locale: state.locale.toLocale(),
                supportedLocales:
                    AppLocale.values.map((locale) => locale.toLocale()),
                localizationsDelegates: const [
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                home: child,
              )));

  testWidgets('direct remember call cannot bypass the Arabic privacy guard',
      (tester) async {
    final state = await guest(tester);
    expect(await state.rememberForCoach('كلمة مروري secret'), isFalse);
    expect(state.mentorProfile.memories, isEmpty);
    expect(await state.rememberForCoach('أفضل الدراسة صباحًا'), isTrue);
    expect(state.mentorProfile.memories.single.text, 'أفضل الدراسة صباحًا');
  });

  testWidgets('Settings selects Arabic, persists it and updates inherited RTL',
      (tester) async {
    final state = await guest(tester);
    await tester.pumpWidget(host(state, const SettingsScreen()));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const ValueKey('settings-app-language')));
    await tester.pumpAndSettle();
    final option = find.byKey(const ValueKey('settings-app-locale-ar'));
    await tester.ensureVisible(option);
    await tester.tap(option);
    await tester.pumpAndSettle();
    expect(state.locale, AppLocale.ar);
    expect(state.nativeLanguage, NativeLanguage.arabic);
    expect((await SharedPreferences.getInstance()).getString('locale'), 'ar');
    expect(Directionality.of(tester.element(find.byType(SettingsScreen))),
        TextDirection.rtl);
    expect(state.tr(ru: 'Ru', en: 'En', ar: 'اختبار'), 'اختبار');
    expect(state.tr(ru: 'Настройки', en: 'Settings'), matches(arabic));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('Arabic navigation selection follows mirrored tabs',
      (tester) async {
    final state = await guest(tester);
    await tester.runAsync(() => state.setLocale(AppLocale.ar));
    await tester.pumpWidget(host(state, const MainTabScreen()));
    await tester.pump();
    final home = find.byKey(const ValueKey('bottom-nav-0'));
    final profile = find.byKey(const ValueKey('bottom-nav-4'));
    final pill = find.byKey(const ValueKey('bottom-nav-selected-pill'));
    expect(
        tester.getCenter(home).dx, greaterThan(tester.getCenter(profile).dx));
    expect(tester.getCenter(pill).dx, closeTo(tester.getCenter(home).dx, 1));
    await tester.tap(profile);
    // The first frame rebuilds AnimatedAlign and starts its controller.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 400));
    expect(tester.getCenter(pill).dx, closeTo(tester.getCenter(profile).dx, 1));
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
  });

  testWidgets('initial language pills wrap instead of overflowing with Arabic',
      (tester) async {
    await tester.pumpWidget(const MaterialApp(
        home: Scaffold(
            body: Center(
      child: SizedBox(width: 190, child: LanguagePills(selected: 'العربية')),
    ))));
    expect(find.text('العربية'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
