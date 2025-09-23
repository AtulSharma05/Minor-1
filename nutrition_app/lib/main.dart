import 'core/app_export.dart';
import 'services/local_storage_service.dart';
import 'services/local_auth_service.dart';
import 'services/data_service.dart';
import 'widgets/workout_route_guard.dart';
import 'pages/auth_debug_page.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment configuration
  await dotenv.load(fileName: ".env");
  
  // Initialize local storage
  await LocalStorageService.initialize();
  
  // Initialize local authentication service
  await LocalAuthService.initialize();
  
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthNotifier()), // Provide AuthNotifier
        ChangeNotifierProvider(create: (_) => ChatbotNotifier()),
        ChangeNotifierProvider(create: (_) => DashboardNotifier()),
        ChangeNotifierProvider(create: (_) => SearchWorkoutNotifier()),
        ChangeNotifierProvider(create: (_) => WorkoutInfoNotifier()),
        ChangeNotifierProvider(create: (_) => LogWorkoutNotifier()),
        ChangeNotifierProvider(create: (_) => BlogNotifier()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    // Trigger background sync when app starts
    WidgetsBinding.instance.addPostFrameCallback((_) {
      DataService.backgroundSync();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);
    
    // Trigger background sync when app resumes
    if (state == AppLifecycleState.resumed) {
      DataService.backgroundSync();
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: AppTheme.theme,
      title: 'Workout Tracker App',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/signin': (context) => const SigninPage(),
        '/currentPage': (context) => const CurrentPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/features': (context) => const FeaturesPage(),
        '/workout-logging': (context) => const WorkoutRouteGuard(),
        '/workout_logging': (context) => const WorkoutRouteGuard(),
        '/workout-history': (context) => const WorkoutHistoryPage(),
        '/streak-details': (context) => const StreakDetailsPage(),
        '/rewards': (context) => const RewardsPage(),
        '/pose_detection': (context) => const PoseDetectionPage(),
        '/metronome_settings': (context) => const MetronomeSettingsPage(),
        '/auth-debug': (context) => const AuthDebugPage(),
      },
    );
  }
}
