import 'package:http/http.dart' as http;
import '../core/app_export.dart';
// Add this import for basename

class BlogDataSource {
  final String _baseUrl = dotenv.env['BASE_URL'] ?? '';

  Future<http.Response> addBlog(Map<String, dynamic> data) async {
    print(data);
    final url = Uri.parse('$_baseUrl/nutripal_blog/add_blog');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return response;
  }

  Future<http.Response> deleteBlog(
      {required Map<String, dynamic> data}) async {
    print(data);
    final url =Uri.parse('$_baseUrl/nutripal_blog/delete_blog');
    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    return response;
  }

  Future<http.Response> fetchBlogs(Map<String, dynamic> data) async {
    final url = Uri.parse('$_baseUrl/nutripal_blog/fetch_blogs');
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