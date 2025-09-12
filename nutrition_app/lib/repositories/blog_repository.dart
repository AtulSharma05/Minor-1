
import 'package:nutrition_app/core/app_export.dart';

import '../data/blog_data_source.dart';

class BlogRepository {
  final BlogDataSource _BlogDataSource = BlogDataSource();

  Future<void> addBlog(Blog_Item Blog) async {
    final response = await _BlogDataSource.addBlog(Blog.toJson());
    final responseJson = jsonDecode(response.body);
    if (responseJson['result'] != 'STATUS_OK') {
      throw Exception('Failed to add Blog: ${responseJson['message']}');
    }
  }

  Future<void> deleteBlog(Blog_Item Blog) async {
    final response = await _BlogDataSource.deleteBlog(data: Blog.toJson());
    final responseJson = jsonDecode(response.body);
    if (responseJson['result'] != 'STATUS_OK') {
      throw Exception('Failed to delete Blog: ${responseJson['message']}');
    }
  }

  Future<List<Blog_Item>> fetchBlogs(String? username) async {
    final response = await _BlogDataSource.fetchBlogs({'username': username});
    final responseJson = jsonDecode(response.body);
    if (responseJson['result'] == 'STATUS_OK') {
      List<dynamic> blogsJson = responseJson['blogs_list'];
      return blogsJson.map((json) => Blog_Item.fromJson(json)).toList();
    } else {
      throw Exception('Failed to fetch Blog info: ${responseJson['result']}');
    }
  }
}
