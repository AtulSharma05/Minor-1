import '../../core/app_export.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WorkoutBlogsPage extends StatefulWidget {
  const WorkoutBlogsPage({super.key});

  @override
  _WorkoutBlogsPageState createState() => _WorkoutBlogsPageState();
}

class _WorkoutBlogsPageState extends State<WorkoutBlogsPage> {
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
          title: const Text('Workout Blogs'),
        ),
        body: Consumer<BlogNotifier>(
          builder: (context, blogNotifier, child) {
            if (blogNotifier.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            // Show "Coming Soon" message first
            return Column(
              children: [
                // Coming Soon Banner
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Colors.orange.shade300,
                        Colors.orange.shade600,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.orange.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.construction,
                        size: 50,
                        color: Colors.white,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Coming Soon!',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Workout Blogs feature is under development.\nStay tuned for exciting fitness content!',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Existing blogs (if any)
                if (blogNotifier.blogs.isNotEmpty)
                  Expanded(
                    child: ListView.builder(
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
                    ),
                  )
                else
                  Expanded(
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.article_outlined,
                            size: 80,
                            color: Colors.grey.shade400,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'No blogs available yet',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.grey.shade600,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Check back soon for fitness tips and workout guides!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey.shade500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
