import 'package:flutter/material.dart';
import '../models/user_model.dart';
import 'api_service.dart';

/// Mock authentication service with no real backend connections
/// Uses in-memory storage for temporary user data
class AuthService {
  // Mock user information
  static User? _currentUser;

  // Getters
  static User? get currentUser => _currentUser;
  static String? get token => ApiService.token;
  static String? get userRole => ApiService.userRole;
  static bool get isAdmin => true; // Always admin in development mode

  // Mock login that always succeeds
  static Future<User> login(BuildContext context, String username) async {
    try {
      await Future.delayed(
          Duration(milliseconds: 800)); // Simulate network delay

      // Create a mock user
      _currentUser = User(
        name: username,
        email: '$username@example.com',
        role: 'Admin',
        id: 1,
      );

      return _currentUser!;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mock login error: $e')),
      );
      rethrow;
    }
  }

  // Mock registration that always succeeds
  static Future<User> register(
      BuildContext context, String name, String email, String password) async {
    try {
      await Future.delayed(
          Duration(milliseconds: 800)); // Simulate network delay

      // Create a mock user
      final user = User(
        name: name,
        email: email,
        role: 'Student',
        id: 2,
      );

      return user;
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Mock registration error: $e')),
      );
      rethrow;
    }
  }

  // Mock logout
  static void logout() {
    _currentUser = null;
    ApiService.clearToken();
  }
}
