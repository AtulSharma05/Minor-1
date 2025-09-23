import 'package:flutter/material.dart';
import '../services/data_service.dart';
import '../pages/workout_logging.dart';

class WorkoutRouteGuard extends StatefulWidget {
  const WorkoutRouteGuard({Key? key}) : super(key: key);

  @override
  _WorkoutRouteGuardState createState() => _WorkoutRouteGuardState();
}

class _WorkoutRouteGuardState extends State<WorkoutRouteGuard> {
  @override
  void initState() {
    super.initState();
    _checkAccess();
  }

  Future<void> _checkAccess() async {
    // Get route arguments
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      final difficulty = args?['difficulty'] ?? 'Beginner';

      // Check if workout is unlocked
      final unlockStatus = await DataService.getWorkoutUnlockStatus();
      bool isUnlocked = false;
      
      switch (difficulty) {
        case 'Beginner':
          isUnlocked = true;
          break;
        case 'Intermediate':
          isUnlocked = unlockStatus['totalWorkouts'] >= 3;
          break;
        case 'Advanced':
          isUnlocked = unlockStatus['totalWorkouts'] >= 10 && unlockStatus['currentStreak'] >= 3;
          break;
        case 'Elite':
          isUnlocked = unlockStatus['totalWorkouts'] >= 20 && unlockStatus['currentStreak'] >= 7;
          break;
        default:
          isUnlocked = true;
      }

      if (!isUnlocked) {
        // Show lock message and navigate back
        String lockMessage = 'This $difficulty workout is locked. ';
        switch (difficulty) {
          case 'Intermediate':
            lockMessage += 'Complete 3 total workouts to unlock.';
            break;
          case 'Advanced':
            lockMessage += 'Complete 10 total workouts and maintain a 3-day streak to unlock.';
            break;
          case 'Elite':
            lockMessage += 'Complete 20 total workouts and maintain a 7-day streak to unlock.';
            break;
        }
        
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(lockMessage),
            backgroundColor: Colors.orange,
            duration: const Duration(seconds: 4),
          ),
        );
        
        Navigator.pop(context);
        return;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // If we reach here, the workout should be accessible
    return const WorkoutLoggingPage();
  }
}