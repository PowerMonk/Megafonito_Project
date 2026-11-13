import '../models/user_model.dart';
import 'api_client.dart';

class AuthService {
  Future<User> login(String username, String password) async {
    final response = await ApiClient.post('/api/login', {
      'username': username.trim(),
      'password': password,
    });

    if (response is! Map<String, dynamic>) {
      throw const ApiException(500, 'Respuesta inesperada del servidor.');
    }

    final token = response['token'];
    final user = response['user'];
    if (token is! String || user is! Map<String, dynamic>) {
      throw const ApiException(500, 'Respuesta inesperada del servidor.');
    }

    ApiClient.setToken(token);
    return User.fromJson(user);
  }

  Future<void> logout() async {
    try {
      await ApiClient.post('/api/logout');
    } catch (_) {
      // The local session is cleared even if the server is unreachable.
    } finally {
      ApiClient.setToken(null);
    }
  }
}
