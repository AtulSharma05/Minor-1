import '../../core/app_export.dart';


class AddBlogPage extends StatefulWidget {
  const AddBlogPage({super.key});

  @override
  _AddBlogPageState createState() => _AddBlogPageState();
}

class _AddBlogPageState extends State<AddBlogPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _contentController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  final TextEditingController _tagsController = TextEditingController();
  String? username;

  @override
  void initState() {
    super.initState();
    _loadUsername();
  }

  Future<void> _loadUsername() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      // username = prefs.getString('username');
      username = "nutripal_admin";
    });
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => BlogNotifier(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Add Blog'),
          actions: [
            IconButton(
              icon: const Icon(Icons.save),
              onPressed: () async {
                if (_formKey.currentState!.validate()) {
                  Blog_Item newBlog = Blog_Item(
                    username: username,
                    title: _titleController.text,
                    content: _contentController.text,
                    imageUrl: _imageUrlController.text,
                    author: username,
                    tags: _tagsController.text,
                    publishedDate: DateTime.now().toString(),
                  );
                  await Provider.of<BlogNotifier>(context, listen: false).addBlog(newBlog);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Blog added successfully')),
                  );
                  Navigator.pop(context);
                }
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _titleController,
                  decoration: const InputDecoration(labelText: 'Title'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a title';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: _imageUrlController,
                  decoration: const InputDecoration(labelText: 'Image URL'),
                ),
                TextFormField(
                  controller: _tagsController,
                  decoration: const InputDecoration(labelText: 'Tags'),
                ),
                Expanded(
                  child: TextFormField(
                    controller: _contentController,
                    decoration: const InputDecoration(labelText: 'Content'),
                    maxLines: null,
                    expands: true,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter content';
                      }
                      return null;
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
