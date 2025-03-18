import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'api_service.dart';

class AuthService {
  // Store user information
  static User? _currentUser;

  // Getters
  static User? get currentUser => _currentUser;
  static String? get token => ApiService.token;
  static String? get userRole => ApiService.userRole;
  static bool get isAdmin => userRole == 'admin';

  // Login method
  static Future<User> login(BuildContext context, String username) async {
    try {
      final result = await ApiService.login(username);

      // If login is successful, create user object
      _currentUser = User(
        name: username,
        email: username, // Using username as email for now
        role: result['role'],
        id: result['userId'],
      );

      return _currentUser!;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de inicio de sesión: $e')),
      );
      rethrow;
    }
  }

  // Register method
  static Future<User> register(
      BuildContext context, String name, String email, String password) async {
    try {
      // Call registration API
      final result = await ApiService.authenticatedRequest(
        '/register',
        'POST',
        body: {
          'username': name,
          'email': email,
          'password': password,
        },
      );

      // Check response
      if (result.statusCode != 201) {
        throw Exception('Failed to register user');
      }

      // Return user
      return User(name: name, email: email);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al registrar usuario: $e')),
      );
      rethrow;
    }
  }

  // Logout method
  static void logout() {
    _currentUser = null;
    ApiService.clearToken();
  }
}
