import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';
class ChatbotDataSource {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<http.Response> sendQuery(Map<String, dynamic> body) async {
    final url = Uri.parse('$_baseUrl/nutripal_bot/nutribot_query');
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );
    print(response.body);

    if (response.statusCode == 200 && response.headers['content-type']?.contains('application/json') == true) {
      print("Response received: ${response.body}");
      return response;
    } else {
      print("Unexpected response format: ${response.body}");
      throw FormatException('Unexpected response format', response.body);
    }
  }
}
