import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthService {
  final String apiUrl = 'http://localhost:8000/api';
  final String tokenKey = 'token';

  Future<String?> login(String username, String password) async {
    final response = await http.post(
      Uri.parse('$apiUrl/token/'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'username': username,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final responseData = json.decode(response.body);
      final token = responseData['access'];
      await _saveToken(token);
      return token;
    } else {
      print('Login failed: ${response.statusCode}');
      return null;
    }
  }

  Future<String?> signup(String username, String password) async {
    // Make a POST request to your signup endpoint and handle the response accordingly
    try {
      final response = await http.post(
        Uri.parse('$apiUrl/signup'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username, 'password': password}),
      );

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data['token'];
      } else {
        // Handle signup failure or other errors
        return null;
      }
    } catch (e) {
      // Handle network errors
      return null;
    }
  }

  Future<void> logout() async {
    await _removeToken();
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
  }

  Future<void> _removeToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
  }
}
