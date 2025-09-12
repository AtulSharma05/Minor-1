
import 'package:nutrition_app/core/app_export.dart';

import '../data/workout_data_source.dart';

class WorkoutRepository {
  final WorkoutDataSource _WorkoutDataSource = WorkoutDataSource();

  Future<List<dynamic>> searchWorkout(Workout_Item Workout) async {
    final response = await _WorkoutDataSource.searchWorkout(Workout.toJson());
    final responseJson = jsonDecode(response.body);
    if (responseJson['result'] == 'STATUS_OK') {
      return responseJson['workout_search_results'];
    } else {
      throw Exception('Failed to fetch Workout results');
    }
  }

  Future<void> logWorkout(Workout_Item Workout) async {
    print(Workout.toJson()); 
    final response = await _WorkoutDataSource.logWorkout(data: Workout.toJson());
    final responseJson = jsonDecode(response.body);
    print(responseJson);
    if (responseJson['result'] != 'STATUS_OK') {
      throw Exception('Failed to save Workout item');
    }
  }


  Future<Map<String, dynamic>> fetchWorkoutInfo(Workout_Item Workout) async {
    print(Workout.toJson());
    final response =
        await _WorkoutDataSource.fetchWorkoutInfo(data: Workout.toJson());
    final responseJson = jsonDecode(response.body);
    print(responseJson);
    if (responseJson['result'] == 'STATUS_OK') {
      return responseJson['workout_info'];
    } else {
      throw Exception(
          'Failed to fetch Workout info: ${responseJson['result']}');
    }
  }
}
