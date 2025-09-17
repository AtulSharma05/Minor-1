import '../core/app_export.dart';
import '../services/data_service.dart';

class SearchWorkoutNotifier extends ChangeNotifier {
  List<Map<String, dynamic>> _workoutItems = [];
  String? selectedWorkout;
  String? details;

  List<Map<String, dynamic>> get workoutItems => _workoutItems;

  Future<void> searchWorkout(String itemQuery) async {
    try {
      _workoutItems = [];
      
      if (itemQuery.trim().isNotEmpty) {
        _workoutItems = await DataService.searchWorkouts(itemQuery);
      }
      
      notifyListeners();
    } catch (error) {
      print("Error searching workouts: $error");
      details = "Failed to search workouts: $error";
      notifyListeners();
    }
  }

  void clearWorkoutItems() {
    _workoutItems.clear();
    notifyListeners();
  }
}

class LogWorkoutNotifier extends ChangeNotifier {
  String? details;
  bool isLoading = false;

  Future<void> logWorkout(
    String itemName,
    String workoutNotes,
    String effortLevel,
    String durationMin,
    String energyBurned,
    String diaryGroup,
    String date,
    String time,
  ) async {
    isLoading = true;
    notifyListeners();

    try {
      // Parse input values
      final duration = int.tryParse(durationMin) ?? 0;
      final calories = int.tryParse(energyBurned) ?? 0;
      
      // Create a basic exercise from the logged data
      final exercise = {
        'name': itemName,
        'sets': 1,
        'reps': 1,
        'duration': duration * 60, // Convert minutes to seconds
        'notes': 'Effort: $effortLevel, Diary Group: $diaryGroup',
      };

      // Log the workout using DataService
      final result = await DataService.logWorkout(
        name: itemName.isNotEmpty ? itemName : 'Workout',
        description: 'Effort: $effortLevel, Diary Group: $diaryGroup',
        duration: duration,
        calories: calories,
        category: diaryGroup.isNotEmpty ? diaryGroup : 'General',
        exercises: [exercise],
        notes: 'Date: $date, Time: $time',
      );

      if (result['success'] == true) {
        details = "Workout logged successfully";
      } else {
        details = "Failed to log workout";
      }
    } catch (error) {
      details = "Failed to log workout: $error";
      print("Workout logging error: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}

class WorkoutInfoNotifier extends ChangeNotifier {
  final Map<String, dynamic> _workoutData = {};
  bool isLoading = false;
  String? details;

  Map<String, dynamic> get workoutData => _workoutData;

  Future<void> fetchWorkoutInfo(String itemName) async {
    isLoading = true;
    notifyListeners();

    try {
      // Search for workout details
      final workouts = await DataService.searchWorkouts(itemName);
      
      if (workouts.isNotEmpty) {
        final workout = workouts.first;
        _workoutData['energy_burned'] = workout['calories'] ?? 0;
        _workoutData['duration_min'] = workout['duration'] ?? 0;
        details = "Workout info fetched successfully";
      } else {
        _workoutData.clear();
        details = "No workout information found";
      }
    } catch (error) {
      details = "Failed to fetch workout info: $error";
      print("Workout info error: $error");
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
