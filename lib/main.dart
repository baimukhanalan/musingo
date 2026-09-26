import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'services/app_state.dart';
import 'services/home_widget_service.dart';
import 'utils/theme.dart';
import 'utils/colors.dart';
import 'screens/carousel_screen.dart';
import 'screens/login_screen.dart';
import 'screens/main_tab_screen.dart';
import 'screens/lesson_screen.dart';
import 'screens/lesson_review_screen.dart';
import 'screens/friends_screen.dart';
import 'screens/league_screen.dart';
import 'screens/achievements_screen.dart';
import 'screens/streak_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/progress_portability_screen.dart';
import 'screens/change_password_screen.dart';
import 'screens/email_account_screen.dart';
import 'screens/install_app_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/coach_screen.dart';
import 'screens/mentor_memory_screen.dart';
import 'screens/rules_screen.dart';
import 'screens/academy_modes_screen.dart';
import 'screens/continuous_audio_screen.dart';
import 'screens/curriculum_library_screen.dart';
import 'screens/curriculum_module_screen.dart';
import 'models/lesson.dart';
import 'models/curriculum_module.dart';
import 'widgets/cat_character.dart';
import 'widgets/daily_ayah.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  final HomeWidgetService _homeWidget = HomeWidgetService();
  StreamSubscription<Uri?>? _widgetClickSubscription;
  String? _pendingExternalRoute;
  bool _externalRouteScheduled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _appState.addListener(_flushExternalRoute);
    _appState.setNotificationOpenHandler(_queueExternalRoute);
    if (_homeWidget.isSupported) {
      _widgetClickSubscription =
          _homeWidget.widgetClicked.listen(_onWidgetClick);
      unawaited(
          _homeWidget.initiallyLaunchedFromHomeWidget().then(_onWidgetClick));
    }
  }

  void _onWidgetClick(Uri? uri) {
    if (uri?.path == '/daily-ayah') _queueExternalRoute('/daily-ayah');
  }

  void _queueExternalRoute(String route) {
    if (route != '/daily-plan' && route != '/daily-ayah') return;
    _pendingExternalRoute = route;
    _flushExternalRoute();
  }

  void _flushExternalRoute() {
    if (!mounted ||
        !_appState.isInitialized ||
        _pendingExternalRoute == null ||
        _externalRouteScheduled) {
      return;
    }
    _externalRouteScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _externalRouteScheduled = false;
      if (!mounted || !_appState.isInitialized) return;
      final route = _pendingExternalRoute;
      final navigator = _navigatorKey.currentState;
      if (route == null || navigator == null) return;
      _pendingExternalRoute = null;
      if (route == '/daily-plan' && _appState.recommendedLesson != null) {
        navigator.pushNamedAndRemoveUntil('/lesson', (_) => false,
            arguments: _appState.recommendedLesson);
      } else {
        navigator.pushNamedAndRemoveUntil(
            route == '/daily-ayah' ? '/daily-ayah' : '/home', (_) => false);
      }
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    // Мягкий лок жизней (M4): если жизни кончились при открытом приложении, они
    // раньше восстанавливались только после перезапуска. При возврате на
    // передний план пересчитываем накопившуюся по времени регенерацию.
    if (state == AppLifecycleState.resumed) {
      _appState.refreshHearts();
      _appState.refreshHomeWidget();
      _appState.refreshNativeReminders();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _widgetClickSubscription?.cancel();
    _appState.removeListener(_flushExternalRoute);
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
          navigatorKey: _navigatorKey,
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
            Locale('ar'),
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
    final uri = Uri.tryParse(settings.name ?? '/') ?? Uri(path: '/');

    switch (uri.path) {
      case '/':
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
        page = LoginScreen(
          startInRegisterMode: _appState.isLoggedIn && !_appState.isBackendUser,
          initialName: _appState.user?.name ?? '',
          initialEmail: _appState.user?.email ?? '',
        );
        break;
      case '/forgot-password':
        page = ForgotPasswordScreen(
          initialEmail:
              settings.arguments is String ? settings.arguments as String : '',
        );
        break;
      case '/reset-password':
        page = ResetPasswordScreen(token: uri.queryParameters['token'] ?? '');
        break;
      case '/verify-email':
        page = VerifyEmailScreen(token: uri.queryParameters['token'] ?? '');
        break;
      case '/home':
        page = const MainTabScreen();
        break;
      case '/daily-ayah':
        page = const _DailyAyahScreen();
        break;
      case '/quran':
        page = const MainTabScreen(initialIndex: 1);
        break;
      case '/hafiz':
        page = const MainTabScreen(initialIndex: 3);
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
        page = const AcademyModesScreen();
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
      case '/progress-portability':
        page = const ProgressPortabilityScreen();
        break;
      case '/change-password':
        page = _appState.canChangePassword
            ? const ChangePasswordScreen()
            : LoginScreen(
                startInRegisterMode: true,
                initialName: _appState.user?.name ?? '',
                initialEmail: _appState.user?.email ?? '',
              );
        break;
      case '/install':
        page = const InstallAppScreen();
        break;
      case '/coach':
        page = const CoachScreen(showBackButton: true);
        break;
      case '/mentor-memory':
        page = const MentorMemoryScreen();
        break;
      case '/rules':
        page = const RulesScreen();
        break;
      case '/academy':
        page = const AcademyModesScreen();
        break;
      case '/curriculum':
        page = const CurriculumLibraryScreen();
        break;
      case '/curriculum-module':
        final arguments = settings.arguments;
        page = arguments is CurriculumModule
            ? CurriculumModuleScreen(module: arguments)
            : const CurriculumLibraryScreen();
        break;
      case '/audio-session':
        page = ContinuousAudioScreen(
          startModule: settings.arguments is CurriculumModule
              ? settings.arguments as CurriculumModule
              : null,
        );
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
      transitionsBuilder: (context, animation, __, child) {
        if (MediaQuery.disableAnimationsOf(context)) return child;
        final eased = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        return FadeTransition(
          opacity: eased,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0.035, 0),
              end: Offset.zero,
            ).animate(eased),
            child: child,
          ),
        );
      },
      transitionDuration: const Duration(milliseconds: 320),
      reverseTransitionDuration: const Duration(milliseconds: 240),
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

class _DailyAyahScreen extends StatelessWidget {
  const _DailyAyahScreen();

  @override
  Widget build(BuildContext context) {
    final title = switch (context.watch<AppState>().locale.code) {
      'kk' => 'Күн аяты',
      'en' => 'Ayah of the day',
      'ar' => 'آية اليوم',
      _ => 'Аят дня',
    };
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(title),
        backgroundColor: AppColors.background,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => Navigator.of(context)
              .pushNamedAndRemoveUntil('/home', (_) => false),
        ),
      ),
      body: const SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(20),
          child: DailyAyahCard(),
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
    _scale = Tween<double>(begin: 0.96, end: 1.0)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = Tween<double>(begin: 0, end: 1)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _ctrl.forward();
    _navigationTimer = Timer(const Duration(milliseconds: 1600), _navigate);
  }

  void _navigate() {
    // A notification may already be pushing a lesson. Removed routes stay
    // mounted until its transition finishes; the splash must not replace it.
    if (!mounted || ModalRoute.of(context)?.isCurrent != true) {
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
                  const CatCharacter(mood: CatMood.greet, size: 190),
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
