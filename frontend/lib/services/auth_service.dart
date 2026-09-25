import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import 'api_service.dart';

class AuthService {
  final ApiService _apiService = ApiService();

  Future<User> register(String name, String email, String password) async {
    final response = await _apiService.post(
      '/auth/register',
      {
        'name': name.trim(),
        'email': email.trim().toLowerCase(),
        'password': password,
      },
      withAuth: false,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200 || response.statusCode == 201) {
      final token = data['token'];
      final user = User(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        token: token,
      );

      await _saveSession(user, token);
      return user;
    } else {
      throw Exception(data['message'] ?? 'Registration failed');
    }
  }

  Future<User> login(String email, String password) async {
    final response = await _apiService.post(
      '/auth/login',
      {
        'email': email.trim().toLowerCase(),
        'password': password,
      },
      withAuth: false,
    );

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      final token = data['token'];
      final user = User(
        id: data['id'],
        name: data['name'],
        email: data['email'],
        token: token,
      );

      await _saveSession(user, token);
      return user;
    } else {
      throw Exception(data['message'] ?? 'Invalid email or password');
    }
  }

  Future<void> _saveSession(User user, String token) async {
    _apiService.setToken(token);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
    await prefs.setInt('user_id', user.id);
    await prefs.setString('user_name', user.name);
    await prefs.setString('user_email', user.email);
  }

  Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    final id = prefs.getInt('user_id');
    final name = prefs.getString('user_name');
    final email = prefs.getString('user_email');

    if (token != null && id != null && name != null && email != null) {
      _apiService.setToken(token);
      return User(id: id, name: name, email: email, token: token);
    }
    return null;
  }

  Future<void> logout() async {
    _apiService.setToken(null);
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_email');
  }

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token');
    return token != null && token.isNotEmpty;
  }
}
