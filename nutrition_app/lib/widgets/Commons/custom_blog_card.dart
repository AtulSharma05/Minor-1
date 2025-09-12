import '../../core/app_export.dart';
class BlogCard extends StatefulWidget {
  final Blog_Item blog;

  const BlogCard({super.key, required this.blog});

  @override
  _BlogCardState createState() => _BlogCardState();
}

class _BlogCardState extends State<BlogCard> {
  bool _isExpanded = false;

@override
Widget build(BuildContext context) {
  return Card(
    child: Container(
      width: double.infinity,
      constraints: BoxConstraints(maxHeight: _isExpanded ? 400 : 200),
      child: SingleChildScrollView( // Allow scrolling when content exceeds space
        child: Column(
          children: [
            ListTile(
              leading: Image.asset(
                'assets/icons/glogin.png',
                width: 50,
                height: 50,
                fit: BoxFit.cover,
              ),
              title: Text(widget.blog.title ?? ''),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Author: ${widget.blog.author ?? ''}'),
                  Text('Date: ${widget.blog.publishedDate ?? ''}'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(_isExpanded ? Icons.expand_less : Icons.expand_more),
                onPressed: () {
                  setState(() {
                    _isExpanded = !_isExpanded;
                  });
                },
              ),
            ),
            if (_isExpanded)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  children: [
                    Image.asset(
                      'assets/icons/glogin.png',
                      width: double.infinity,
                      height: 150,
                      fit: BoxFit.cover,
                    ),
                    const SizedBox(height: 8.0),
                    Text(widget.blog.content ?? ''),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

}
