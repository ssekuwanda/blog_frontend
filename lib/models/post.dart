class Post {
  int id;
  String title;
  String content;
  int category;

  Post({
    required this.id,
    required this.title,
    required this.content,
    required this.category,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['id'],
      title: json['title'],
      content: json['content'],
      category: json['category'],
    );
  }
}
