import 'package:http/http.dart' as http;
import '../core/app_export.dart';
import 'package:path/path.dart'; // Add this import for basename

class FoodDataSource {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<http.Response> searchFood(Map<String, dynamic> data) async {
    print(data);
    final url = Uri.parse('$_baseUrl/text_food_logging/food_search');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return response;
  }

  Future<http.Response> logFood(
      {required Map<String, dynamic> data, bool? fromImage}) async {
    print(data);
    final url = fromImage != null
        ? Uri.parse('$_baseUrl/img_food_logging/log_nutrition_info')
        : Uri.parse('$_baseUrl/text_food_logging/log_nutrition_info');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return response;
  }

  Future<http.Response> fetchNutritionInfo({
    required Map<String, dynamic> data,
    XFile? imageFile,
  }) async {
    final url = imageFile != null
        ? Uri.parse('$_baseUrl/img_food_logging/img_fetch_nutrition_info')
        : Uri.parse('$_baseUrl/text_food_logging/fetch_nutrition_info');
    final dynamic response;

    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      final fileName = basename(imageFile.path);

      var request = http.MultipartRequest('POST', url)
        ..fields['username'] = data['username']
        ..files.add(
          http.MultipartFile.fromBytes(
            'file', // Must match the server field name
            bytes,
            filename: fileName,
            contentType: MediaType('image', 'jpeg'), // Adjust if needed
          ),
        );

      final streamedResponse = await request.send();
      response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 200) {
        print('Response body: ${response.body}');
      } else {
        print('Failed to upload file. Status code: ${response.statusCode}');
      }
    } else {
      // For non-image requests, send JSON data directly
      response = await http.post(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json',
        },
        body: jsonEncode(data),
      );
    }
    return response;
  }

  Future<http.Response> fetchCaloriesConsumed(Map<String, dynamic> data) async {
    print(data);
    final url = Uri.parse('$_baseUrl/dashboard/get_calories_consumed');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return response;
  }

  Future<http.Response> fetchFoodConsumedToday(Map<String, dynamic> data) async {
    print(data);
    final url = Uri.parse('$_baseUrl/dashboard/food_consumed_today');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return response;
  }
}
