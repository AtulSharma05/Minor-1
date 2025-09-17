import 'core/app_export.dart';
import 'services/local_storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment configuration
  await dotenv.load(fileName: ".env");
  
  // Initialize local storage
  await LocalStorageService.initialize();
  
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

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        '/workout-logging': (context) => const WorkoutLoggingPage(),
        '/workout_logging': (context) => const WorkoutLoggingPage(),
        '/workout-history': (context) => const WorkoutHistoryPage(),
        '/streak-details': (context) => const StreakDetailsPage(),
        '/rewards': (context) => const RewardsPage(),
        '/pose_detection': (context) => const PoseDetectionPage(),
        '/metronome_settings': (context) => const MetronomeSettingsPage(),
      },
    );
  }
}
