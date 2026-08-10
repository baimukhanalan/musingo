import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
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
import 'screens/friends_screen.dart';
import 'screens/league_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/streak_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/install_app_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/academy_screen.dart';
import 'screens/tajwid_review_screen.dart';
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

class MuslingoApp extends StatefulWidget {
  const MuslingoApp({super.key});

  @override
  State<MuslingoApp> createState() => _MuslingoAppState();
}

class _MuslingoAppState extends State<MuslingoApp> with WidgetsBindingObserver {
  // Держим единственный AppState на всё время жизни приложения и сами им владеем
  // (ChangeNotifierProvider.value не диспоузит), чтобы навесить на него
  // наблюдатель жизненного цикла.
  final AppState _appState = AppState();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Мягкий лок жизней (M4): если жизни кончились при открытом приложении, они
    // раньше восстанавливались только после перезапуска. При возврате на
    // передний план пересчитываем накопившуюся по времени регенерацию.
    if (state == AppLifecycleState.resumed) {
      _appState.refreshHearts();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _appState.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AppState>.value(
      value: _appState,
      // Подписываемся на AppState, чтобы MaterialApp пересобирался при смене
      // языка интерфейса (locale) и подхватывал новый Locale.
      child: Consumer<AppState>(
        builder: (context, appState, _) => MaterialApp(
          title: 'Muslingo',
          debugShowCheckedModeBanner: false,
          theme: AppTheme.light,
          locale: appState.locale.toLocale(),
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: const [
            Locale('ru'),
            Locale('kk'),
            Locale('en'),
          ],
          builder: (context, child) => ColoredBox(
            color: AppColors.backgroundGrey,
            child: Center(
              child: ConstrainedBox(
                // The premium reference is a 402pt mobile composition. Keep a
                // phone-like canvas on desktop while still filling real phones.
                constraints: const BoxConstraints(maxWidth: 430),
                child: child ?? const SizedBox.shrink(),
              ),
            ),
          ),
          initialRoute: '/splash',
          onGenerateRoute: _generateRoute,
        ),
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
      case '/onboarding':
        page = const OnboardingScreen();
        break;
      case '/login':
        page = const LoginScreen();
        break;
      case '/home':
        page = const MainTabScreen();
        break;
      case '/lesson':
        final arguments = settings.arguments;
        page = arguments is Lesson
            ? LessonScreen(lesson: arguments)
            : const _RouteFallbackScreen(
                titleRu: 'Урок не найден',
                titleKk: 'Сабақ табылмады',
                titleEn: 'Lesson not found',
                messageRu:
                    'Открой урок с главного экрана, чтобы начать заново.',
                messageKk: 'Қайта бастау үшін басты экраннан сабақты аш.',
                messageEn: 'Open a lesson from the home screen to start again.',
              );
        break;
      case '/lesson_review':
        final arguments = settings.arguments;
        page = arguments is Map<String, dynamic>
            ? LessonReviewScreen(result: arguments)
            : const _RouteFallbackScreen(
                titleRu: 'Итог урока недоступен',
                titleKk: 'Сабақ қорытындысы қолжетімсіз',
                titleEn: 'Lesson summary unavailable',
                messageRu:
                    'Результат урока не был передан. Вернись к обучению.',
                messageKk: 'Сабақ нәтижесі берілмеді. Оқуға оралыңыз.',
                messageEn:
                    'The lesson result was not provided. Return to learning.',
              );
        break;
      case '/premium':
        page = const PremiumScreen();
        break;
      case '/friends':
        page = const FriendsScreen();
        break;
      case '/league':
        page = const LeagueScreen();
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
      case '/install':
        page = const InstallAppScreen();
        break;
      case '/coach':
        page = const CoachScreen();
        break;
      case '/rules':
        page = const RulesScreen();
        break;
      case '/academy':
        page = const AcademyScreen();
        break;
      // Черновик таджвида для ревью специалистом. Достижим только при сборке с
      // MUSLINGO_DRAFT_CONTENT=true (вход показан в профиле под тем же флагом).
      case '/review/tajwid':
        page = const TajwidReviewScreen();
        break;
      case '/help':
        page = const HelpScreen();
        break;
      default:
        page = const _RouteFallbackScreen(
          titleRu: 'Страница не найдена',
          titleKk: 'Бет табылмады',
          titleEn: 'Page not found',
          messageRu: 'Такого раздела нет. Можно вернуться к урокам.',
          messageKk: 'Мұндай бөлім жоқ. Сабақтарға оралуға болады.',
          messageEn: 'There is no such section. You can return to the lessons.',
        );
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

class _RouteFallbackScreen extends StatelessWidget {
  final String titleRu;
  final String? titleKk;
  final String? titleEn;
  final String messageRu;
  final String? messageKk;
  final String? messageEn;

  const _RouteFallbackScreen({
    required this.titleRu,
    this.titleKk,
    this.titleEn,
    required this.messageRu,
    this.messageKk,
    this.messageEn,
  });

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final title = state.tr(ru: titleRu, kk: titleKk, en: titleEn);
    final message = state.tr(ru: messageRu, kk: messageKk, en: messageEn);
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: const BoxDecoration(
                  color: AppColors.skyLight,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.route_rounded,
                  color: AppColors.navy,
                  size: 36,
                ),
              ),
              const SizedBox(height: 18),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontFamily: 'Nunito',
                  fontSize: 15,
                  height: 1.4,
                  color: AppColors.textGrey,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => Navigator.pushNamedAndRemoveUntil(
                    context,
                    '/home',
                    (route) => false,
                  ),
                  icon: const Icon(Icons.school_rounded),
                  label: Text(state.tr(
                    ru: 'К урокам',
                    kk: 'Сабақтарға',
                    en: 'To lessons',
                  )),
                  style: FilledButton.styleFrom(
                    backgroundColor: AppColors.navy,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
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
      state.isLoggedIn ? '/home' : '/onboarding',
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
    // M12: сплэш-кот (900x900 PNG) показывается 190x190. Декодируем растр под
    // экранный размер, домноженный на devicePixelRatio, а не в исходном
    // разрешении. Картинка квадратная, поэтому cacheWidth == cacheHeight без
    // искажения пропорций.
    final catCache = (190 * MediaQuery.of(context).devicePixelRatio).round();
    final state = context.watch<AppState>();
    return Scaffold(
      backgroundColor: AppColors.sky,
      body: Center(
        child: AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => FadeTransition(
            opacity: _fade,
            child: ScaleTransition(
              scale: _scale,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/muslingo_cat.png',
                    width: 190,
                    height: 190,
                    fit: BoxFit.contain,
                    cacheWidth: catCache,
                    cacheHeight: catCache,
                  ),
                  const SizedBox(height: 18),
                  const Text(
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
                    state.tr(
                      ru: 'Коран и ислам шаг за шагом',
                      kk: 'Құран мен ислам қадам-қадам',
                      en: 'The Quran and Islam step by step',
                    ),
                    style: const TextStyle(
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
