import 'dart:math';

import '../core/app_export.dart';

class SearchWorkoutNotifier extends ChangeNotifier {
  final WorkoutRepository _WorkoutRepository = WorkoutRepository();
  List<Workout_Item> _WorkoutItems = [];
  String? selectedWorkout;
  String? details;

  List<dynamic> get WorkoutItems => _WorkoutItems;

  Future<void> searchWorkout(String itemQuery) async {
    try {
      _WorkoutItems = [];
      Workout_Item item =
          await Workout_Item.createWithStoredUsername(itemQuery: itemQuery);
      
      List<dynamic> dynamicWorkoutItems = await _WorkoutRepository.searchWorkout(item);
      print('reached');
      _WorkoutItems = dynamicWorkoutItems.map((dynamic Workout) {
        return Workout_Item(
          itemName: Workout['name']?.toString() ?? '', 
          calories_per_hour: _parseToDouble(Workout['calories_per_hour']),
          total_calories: _parseToDouble(Workout['total_calories']),
          duration_min: Workout['duration_minutes']?.toString() ?? '',
          username: item.username,
        );
      }).toList();

      notifyListeners();
    } catch (error) {
      
      print("Error fetching Workout items: $error");
    }
  }

  double _parseToDouble(dynamic value) {
    if (value == null) {
      return 0.0; 
    }
    if (value is double) {
      return value;
    }
    if (value is int) {
      return value.toDouble();
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0; 
    }
    return 0.0; 
  }

  void clearWorkoutItems() {
    WorkoutItems.clear(); 
    notifyListeners(); 
  }
}

class LogWorkoutNotifier extends ChangeNotifier {
  final WorkoutRepository _WorkoutRepository = WorkoutRepository();
  String? details;
  bool isLoading = false;

  
  Future<void> logWorkout(
      String itemName, String WorkoutLogNotes,String effortLevel,String durationMin,String energyBurned,String diaryGroup,String date, String time, ) async {
    isLoading = true; 
    notifyListeners(); 
    
    DateTime parsedDate = DateFormat('yyyy-MM-dd')
        .parse(date); 
    DateTime parsedTime = DateFormat('h:mm a')
        .parse(time);

    String formattedDate = DateFormat('dd-MM-yyyy').format(parsedDate);
    String formattedTime = DateFormat('HH:mm:ss').format(parsedTime);

    try {
      
      Workout_Item Workout = await Workout_Item.createWithStoredUsername(
          itemName: itemName,
          notes: WorkoutLogNotes,
          date: formattedDate,
          effort_level: effortLevel,
          duration_min: durationMin,
          energy_burned: energyBurned,
          time: formattedTime,
          diary_group: diaryGroup); 
      print(Workout.toJson());
      await _WorkoutRepository.logWorkout(Workout);
      details = "Workout item logged successfully";
    } catch (error) {
      details = "Failed to log Workout item: $error";
    } finally {
      isLoading = false; 
      notifyListeners(); 
    }
  }

  
}

class WorkoutInfoNotifier extends ChangeNotifier {
  final WorkoutRepository _WorkoutRepository = WorkoutRepository();
  final Map<String, dynamic> _workoutData = {}; 
  bool isLoading = false;
  String? details;

  Map<String, dynamic> get workoutData => _workoutData;

  Future<void> fetchWorkoutInfo(String itemName) async {
    isLoading = true;
    notifyListeners();

    try {
      Workout_Item Workout =
          await Workout_Item.createWithStoredUsername(itemName: itemName);
      Map<String, dynamic> WorkoutInfo =
          await _WorkoutRepository.fetchWorkoutInfo(Workout);

      _workoutData['energy_burned'] =
          _parseToDouble(WorkoutInfo['energy_burned']);
      _workoutData['duration_min'] = WorkoutInfo['duration_min'];

      details = "workout info fetched successfully";
    } catch (error) {
      details = "Failed to fetch workout info: $error";
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  double _parseToDouble(dynamic value) {
    if (value == null) {
      return 0.0; 
    }
    if (value is double) {
      return value;
    }
    if (value is String) {
      return double.tryParse(value) ?? 0.0; 
    }
    return 0.0; 
  }
}