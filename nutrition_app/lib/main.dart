import 'core/app_export.dart';

void main() async {
  await dotenv.load(fileName: ".env");
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => AuthNotifier()), // Provide AuthNotifier
        ChangeNotifierProvider(create: (_) => SearchFoodNotifier()),
        ChangeNotifierProvider(create: (_) => NutritionInfoNotifier()),
        ChangeNotifierProvider(create: (_) => LogFoodNotifier()),
        ChangeNotifierProvider(create: (_) => FoodConsumedNotifier()),
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
      title: 'Nutrition App',
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/signin': (context) => const SigninPage(),
        '/currentPage': (context) => const CurrentPage(),
        '/signup': (context) => const SignupPage(),
        '/dashboard': (context) => const DashboardPage(),
        '/features': (context) => const FeaturesPage(),
      },
    );
  }
}
