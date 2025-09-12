
class Blog_Item {
  String? title;
  String? imageUrl;
  String? content;
  String? author;
  String? tags;
  String? publishedDate;
  String? username;

  Blog_Item({
    this.title,
    this.imageUrl,
    this.content,
    this.author,
    this.tags,
    this.publishedDate,
    this.username,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {};
    if (title != null) data['title'] = title;
    if (imageUrl != null) data['image_url'] = imageUrl;
    if (content != null) data['content'] = content;
    if (author != null) data['author'] = author;
    if (tags != null) data['tags'] = tags;
    if (publishedDate != null) data['published_date'] = publishedDate;
    data['username'] = username;
    return data;
  }

  factory Blog_Item.fromJson(Map<String, dynamic> json) {
    return Blog_Item(
      title: json['title'],
      imageUrl: json['image_url'],
      content: json['content'],
      author: json['author'],
      tags: json['tags'],
      publishedDate: json['published_date'],
      username: "nutripal_admin", // Set username from environment variable
    );
  }
}
