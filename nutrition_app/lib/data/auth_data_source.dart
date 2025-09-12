import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AuthDataSource {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<http.Response> signup(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/auth_user/signup_user');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    print(response);
    return response;
  }

  Future<http.Response> login(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/auth_user/client_login');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );
    return response;
  }

  Future<http.Response> logout(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/auth_user/client_logout');
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
