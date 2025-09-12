import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class DietPlanDataSource {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<http.Response> submitDetails(Map<String, String> userDetails) {
    return http.post(
      Uri.parse('$_baseUrl/nutripal_dietplan/enter_user_details'),
      body: jsonEncode(userDetails),
      headers: {'Content-Type': 'application/json'},
    );
  }

  Future<http.Response> fetchDietPlan(Map<String, String> username) {
    print(jsonEncode(username));
    return http.post(
      Uri.parse('$_baseUrl/nutripal_dietplan/get_diet_plan'),
      body: jsonEncode(username),
      headers: {'Content-Type': 'application/json'},
    );
  }
}
