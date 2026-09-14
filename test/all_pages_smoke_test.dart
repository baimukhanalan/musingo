import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:muslingo/screens/academy_screen.dart';
import 'package:muslingo/screens/achievements_screen.dart';
import 'package:muslingo/screens/coach_screen.dart';
import 'package:muslingo/screens/friends_screen.dart';
import 'package:muslingo/screens/home_screen.dart';
import 'package:muslingo/screens/install_app_screen.dart';
import 'package:muslingo/screens/league_screen.dart';
import 'package:muslingo/screens/main_tab_screen.dart';
import 'package:muslingo/screens/mentor_memory_screen.dart';
import 'package:muslingo/screens/premium_screen.dart';
import 'package:muslingo/screens/profile_screen.dart';
import 'package:muslingo/screens/quran_screen.dart';
import 'package:muslingo/screens/rules_screen.dart';
import 'package:muslingo/screens/settings_screen.dart';
import 'package:muslingo/screens/streak_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('every customer-facing page renders on a phone viewport',
      (tester) async {
    tester.view.physicalSize = const Size(402, 874);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    SharedPreferences.resetStatic();
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      final deadline = DateTime.now().add(const Duration(seconds: 5));
      while (!state.isInitialized && DateTime.now().isBefore(deadline)) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
    });
    expect(state.isInitialized, isTrue);

    final pages = <String, Widget>{
      'main tabs': const MainTabScreen(),
      'home': const HomeScreen(),
      'quran': const QuranScreen(),
      'coach': const CoachScreen(),
      'mentor memory': const MentorMemoryScreen(),
      'profile': const ProfileScreen(),
      'streak': const StreakScreen(),
      'league': const LeagueScreen(),
      'achievements': const AchievementsScreen(),
      'islam foundations': const RulesScreen(),
      'academy': const AcademyScreen(),
      'install': const InstallAppScreen(),
      'premium': const PremiumScreen(),
      'friends': const FriendsScreen(),
      'settings': const SettingsScreen(),
      'help': const HelpScreen(),
    };

    for (final entry in pages.entries) {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: MaterialApp(
            home: entry.value,
            onGenerateRoute: (settings) => MaterialPageRoute<void>(
              settings: settings,
              builder: (_) => const Scaffold(body: Text('route-target')),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 80));
      expect(tester.takeException(), isNull, reason: entry.key);
    }

    await tester.pumpWidget(const SizedBox.shrink());
    await tester.pump(const Duration(milliseconds: 100));
  });
}
