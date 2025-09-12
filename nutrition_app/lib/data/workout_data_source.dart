import 'package:http/http.dart' as http;
import '../core/app_export.dart';
// Add this import for basename

class WorkoutDataSource {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<http.Response> searchWorkout(Map<String, dynamic> data) async {
    print(data);
    final url = Uri.parse('$_baseUrl/workout_logging/workout_search');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return response;
  }

  Future<http.Response> logWorkout(
      {required Map<String, dynamic> data}) async {
    print(data);
    final url =Uri.parse('$_baseUrl/workout_logging/log_workout_info');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return response;
  }

  Future<http.Response> fetchWorkoutInfo({
    required Map<String, dynamic> data,
    XFile? imageFile,
  }) async {
    final url = Uri.parse('$_baseUrl/workout_logging/fetch_workout_info');
    final dynamic response;

    // For non-image requests, send JSON data directly
    response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response;
  }
}