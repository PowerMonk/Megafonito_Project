import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  // Base URL of your backend server - change this to your actual backend URL
  // static const String baseUrl = 'http://localhost:8000';
  static const String baseUrl = 'http://10.0.2.2:8000';

  // Store JWT token
  static String? _token;
  static String? _userRole;

  static String? get token => _token;
  static String? get userRole => _userRole;

  // Login method
  static Future<Map<String, dynamic>> login(String username) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'username': username}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _userRole = data['role'];
        return data;
      } else {
        throw Exception(
            'Failed to login: ${response.statusCode} - ${response.body}');
      }
    } catch (e) {
      print('Login error: $e');
      rethrow;
    }
  }

  // Method to make authenticated requests
  static Future<http.Response> authenticatedRequest(
    String endpoint,
    String method, {
    Map<String, dynamic>? body,
  }) async {
    if (_token == null) {
      throw Exception('No authentication token available');
    }

    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $_token',
    };

    try {
      switch (method) {
        case 'GET':
          return await http.get(uri, headers: headers);
        case 'POST':
          return await http.post(uri, headers: headers, body: jsonEncode(body));
        case 'PUT':
          return await http.put(uri, headers: headers, body: jsonEncode(body));
        case 'DELETE':
          return await http.delete(uri, headers: headers);
        default:
          throw Exception('Unsupported HTTP method');
      }
    } catch (e) {
      print('Request error: $e');
      rethrow;
    }
  }
}
