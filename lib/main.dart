import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'utils/theme.dart';
import 'utils/colors.dart';
import 'screens/carousel_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_tab_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/lesson_review_screen.dart';
import 'screens/premium_screen.dart';
import 'screens/leaderboard_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/streak_screen.dart';
import 'screens/settings_screen.dart';
import 'models/lesson.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
  ));
  runApp(const MuslingoApp());
}

class MuslingoApp extends StatelessWidget {
  const MuslingoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'muslingo',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light,
        builder: (context, child) => ColoredBox(
          color: AppColors.backgroundGrey,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: child ?? const SizedBox.shrink(),
            ),
          ),
        ),
        initialRoute: '/splash',
        onGenerateRoute: _generateRoute,
      ),
    );
  }

  Route<dynamic>? _generateRoute(RouteSettings settings) {
    Widget page;

    switch (settings.name) {
      case '/splash':
        page = const _SplashScreen();
        break;
      case '/carousel':
        page = const CarouselScreen();
        break;
      case '/login':
        page = const LoginScreen();
        break;
      case '/home':
        page = const MainTabScreen();
        break;
      case '/lesson':
        final lesson = settings.arguments as Lesson;
        page = LessonScreen(lesson: lesson);
        break;
      case '/lesson_review':
        final result = settings.arguments as Map<String, dynamic>;
        page = LessonReviewScreen(result: result);
        break;
      case '/premium':
        page = const PremiumScreen();
        break;
      case '/leaderboard':
        page = const LeaderboardScreen();
        break;
      case '/achievements':
        page = const AchievementsScreen();
        break;
      case '/streak':
        page = const StreakScreen();
        break;
      case '/settings':
        page = const SettingsScreen();
        break;
      case '/help':
        page = const HelpScreen();
        break;
      default:
        page = const CarouselScreen();
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (_, __, ___) => page,
      transitionsBuilder: (_, animation, __, child) {
        return FadeTransition(
          opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 280),
    );
  }
}

class _SplashScreen extends StatefulWidget {
  const _SplashScreen();

  @override
  State<_SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<_SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scale;
  late Animation<double> _fade;
  Timer? _navigationTimer;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    _scale = Tween<double>(begin: 0.5, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 1600), _navigate);
  }

  void _navigate() {
    if (!mounted) {
      return;
    }
    final state = context.read<AppState>();
    if (!state.isInitialized) {
      _navigationTimer = Timer(const Duration(milliseconds: 150), _navigate);
      return;
    }
    Navigator.pushReplacementNamed(
      context,
      state.isLoggedIn ? '/home' : '/carousel',
    );
  }

  @override
  void dispose() {
    _navigationTimer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.sky,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: const Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image(
                    image: AssetImage('assets/images/muslingo_cat.png'),
                    width: 190,
                    height: 190,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(height: 18),
                  Text(
                    'muslingo',
                    style: TextStyle(
                      fontFamily: 'Nunito',
                      fontSize: 42,
                      fontWeight: FontWeight.w800,
                      color: Colors.white,
                      letterSpacing: -0.5,
                    ),
                  ),
                  Text(
                    'Коран и ислам шаг за шагом',
                    style: TextStyle(
                        fontFamily: 'Nunito',
                        fontSize: 16,
                        color: Colors.white70),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
