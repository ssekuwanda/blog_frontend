import 'package:blog_frontend/postform.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'auth_service.dart';

void main() {
  runApp(BlogApp());
}

class BlogApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Blog App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: BlogHome(),
    );
  }
}

class BlogHome extends StatefulWidget {
  @override
  _BlogHomeState createState() => _BlogHomeState();
}

class _BlogHomeState extends State<BlogHome> {
  List<dynamic> posts = [];
  AuthService _authService = AuthService();
  bool _isLoggedIn = false;

  Future<void> fetchPosts() async {
    final response =
        await http.get(Uri.parse('http://localhost:8000/api/posts/'));
    if (response.statusCode == 200) {
      setState(() {
        posts = json.decode(response.body);
      });
    } else {
      print('Failed to fetch posts: ${response.statusCode}');
    }
  }

  @override
  void initState() {
    super.initState();
    checkLoginStatus();
    fetchPosts();
  }

  Future<void> checkLoginStatus() async {
    final token = await _authService.getToken();
    setState(() {
      _isLoggedIn = token != null;
    });
  }

  Future<void> login() async {
    final token = await _authService.login('your_username', 'your_password');
    if (token != null) {
      setState(() {
        _isLoggedIn = true;
      });
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    setState(() {
      _isLoggedIn = false;
    });
  }

  void navigateToPostForm() {
    Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => PostForm(onPostCreated: fetchPosts)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Blog App'),
      ),
      body: ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          return ListTile(
            title: Text(post['title']),
            subtitle: Text(post['content']),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: navigateToPostForm,
        child: const Icon(Icons.add),
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            if (_isLoggedIn)
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Logout'),
                onTap: logout,
              )
            else
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                onTap: login,
              ),
          ],
        ),
      ),
    );
  }
}
