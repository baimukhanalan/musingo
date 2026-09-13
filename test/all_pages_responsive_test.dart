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
import 'package:muslingo/screens/premium_screen.dart';
import 'package:muslingo/screens/profile_screen.dart';
import 'package:muslingo/screens/progress_portability_screen.dart';
import 'package:muslingo/screens/quran_screen.dart';
import 'package:muslingo/screens/rules_screen.dart';
import 'package:muslingo/screens/settings_screen.dart';
import 'package:muslingo/screens/streak_screen.dart';
import 'package:muslingo/services/app_state.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('all major pages survive compact and large-text viewports',
      (tester) async {
    SharedPreferences.setMockInitialValues({});
    final state = AppState();
    await tester.runAsync(() async {
      while (!state.isInitialized) {
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }
      await state.loginAsGuest();
    });

    final pages = <String, Widget>{
      'main tabs': const MainTabScreen(),
      'home': const HomeScreen(),
      'quran': const QuranScreen(),
      'coach': const CoachScreen(),
      'profile': const ProfileScreen(),
      'streak': const StreakScreen(),
      'league': const LeagueScreen(),
      'achievements': const AchievementsScreen(),
      'rules': const RulesScreen(),
      'academy': const AcademyScreen(),
      'install': const InstallAppScreen(),
      'premium': const PremiumScreen(),
      'friends': const FriendsScreen(),
      'settings': const SettingsScreen(),
      'help': const HelpScreen(),
      'portability': const ProgressPortabilityScreen(),
    };
    const configurations = <({Size size, double textScale})>[
      (size: Size(320, 568), textScale: 1),
      (size: Size(390, 844), textScale: 1.5),
      (size: Size(844, 390), textScale: 1),
    ];

    for (final configuration in configurations) {
      tester.view.physicalSize = configuration.size;
      tester.view.devicePixelRatio = 1;
      for (final entry in pages.entries) {
        await tester.pumpWidget(
          ChangeNotifierProvider<AppState>.value(
            value: state,
            child: MaterialApp(
              builder: (context, child) => MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  textScaler: TextScaler.linear(configuration.textScale),
                ),
                child: child!,
              ),
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
        final exception = tester.takeException();
        expect(
          exception,
          isNull,
          reason:
              '${entry.key} at ${configuration.size} x${configuration.textScale}',
        );
      }
    }

    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    state.dispose();
  });
}
