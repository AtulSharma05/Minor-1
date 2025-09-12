import '../../core/app_export.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NutritionBlogsPage extends StatefulWidget {
  const NutritionBlogsPage({super.key});

  @override
  _NutritionBlogsPageState createState() => _NutritionBlogsPageState();
}

class _NutritionBlogsPageState extends State<NutritionBlogsPage> {
  String? username;
  String? adminUser;

  @override
  void initState() {
    super.initState();
    _loadUsername();
    adminUser = dotenv.env['ADMIN_USER'];
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      username = prefs.getString('username');

    });
  }

  @override
  Widget build(BuildContext context) {
    print("username check");
    print(adminUser);
    return ChangeNotifierProvider(
      create: (_) => BlogNotifier()..fetchBlogs(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Nutrition Blogs'),
        ),
        body: Consumer<BlogNotifier>(
          builder: (context, blogNotifier, child) {
            if (blogNotifier.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return ListView.builder(
              itemCount: blogNotifier.blogs.length,
              itemBuilder: (context, index) {
                Blog_Item blog = blogNotifier.blogs[index];
                return Dismissible(
                  key: Key(blog.title ?? ''),
                  direction: username == adminUser ? DismissDirection.endToStart : DismissDirection.none,
                  onDismissed: (direction) async {
                    await Provider.of<BlogNotifier>(context, listen: false).deleteBlog(blog);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Blog deleted successfully')),
                    );
                  },
                  background: Container(
                    color: Colors.red,
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  child: BlogCard(blog: blog),
                );
              },
            );
          },
        ),
        floatingActionButton: username == adminUser
            ? Positioned(
                bottom: 16,
                right: 16,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: FloatingActionButton(
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    foregroundColor: Theme.of(context).colorScheme.onSecondary,
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => AddBlogPage()),
                      );
                      Provider.of<BlogNotifier>(context, listen: false).fetchBlogs();
                    },
                    child: const Icon(Icons.add),
                  ),
                ),
              )
            : null,
      ),
    );
  }
}
