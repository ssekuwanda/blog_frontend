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
      debugShowCheckedModeBanner: false,
      title: 'BDO PRIME',
      theme: ThemeData(
        primarySwatch: Colors.red,
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
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();

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
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;
      final token = await _authService.login(username, password);
      if (token != null) {
        setState(() {
          _isLoggedIn = true;
        });
        navigateToPostsPage();
      }
    }
  }

  Future<void> signup() async {
    if (_formKey.currentState!.validate()) {
      final username = _usernameController.text;
      final password = _passwordController.text;
      final token = await _authService.signup(username, password);
      if (token != null) {
        setState(() {
          _isLoggedIn = true;
        });
        navigateToPostsPage(); // Redirect to posts page
      }
    }
  }

  void navigateToPostsPage() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BlogHome()),
    );
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
        title: const Text('BDO PRIME'),
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
              Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.logout),
                    title: const Text('Logout'),
                    onTap: logout,
                  ),
                  ListTile(
                    leading: const Icon(Icons.add_reaction),
                    title: const Text('SignUp'),
                    onTap: logout,
                  )
                ],
              )
            else
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Login'),
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: const Text('Login'),
                        content: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              TextFormField(
                                controller: _usernameController,
                                decoration: const InputDecoration(
                                  labelText: 'Username',
                                ),
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your username';
                                  }
                                  return null;
                                },
                              ),
                              TextFormField(
                                controller: _passwordController,
                                decoration: const InputDecoration(
                                  labelText: 'Password',
                                ),
                                obscureText: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Please enter your password';
                                  }
                                  return null;
                                },
                              ),
                            ],
                          ),
                        ),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text('Cancel'),
                          ),
                          ElevatedButton(
                            onPressed: login,
                            child: const Text('Login'),
                          ),
                        ],
                      );
                    },
                  );
                },
              ),
          ],
        ),
      ),
    );
  }
}
