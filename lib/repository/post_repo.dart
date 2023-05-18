import 'dart:convert';

import 'package:blog_frontend/models/post.dart';
import 'package:http/http.dart';
import '../app_settings.dart';

class PostRepository {
  String endpoint = '${AppSettings.baseUrl}/api/posts/';

  Future<List<Post>> fetchPosts() async {
    Response response = await get(Uri.parse(endpoint));
    if (response.statusCode == 200) {
      final List result = jsonDecode(response.body);
      return result.map((e) => Post.fromJson(e)).toList();
    } else {
      throw Exception(response.reasonPhrase);
    }
  }
}
