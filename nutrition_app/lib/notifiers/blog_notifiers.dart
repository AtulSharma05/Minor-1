import '../core/app_export.dart';

class BlogNotifier extends ChangeNotifier {
  final BlogRepository _blogRepository = BlogRepository();
  List<Blog_Item> _blogs = [];
  bool _isLoading = false;
  String? _username;
  List<Blog_Item> get blogs => _blogs;
  bool get isLoading => _isLoading;
  String? get username => _username;
  
  _getUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('username');
  }

  Future<void> fetchBlogs() async {

    _isLoading = true;
    _username = await _getUsername();
    notifyListeners();
    print("in fetch blogs");  
    print(username);
    try {
      if(_username == null) {
        return;
      } 
      _blogs = await _blogRepository.fetchBlogs(_username);
    } catch (e) {
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addBlog(Blog_Item blog) async {
    try {
      await _blogRepository.addBlog(blog);
      fetchBlogs(); // Refresh the blog list
    } catch (e) {
      print(e);
    }
  }

  Future<void> deleteBlog(Blog_Item blog) async {
    try {
      await _blogRepository.deleteBlog(blog);
      fetchBlogs(); // Refresh the blog list
    } catch (e) {
      print(e);
    }
  }
}
