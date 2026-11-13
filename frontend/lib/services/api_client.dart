import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import 'server_config.dart';

class ApiException implements Exception {
  final int statusCode;
  final String message;

  const ApiException(this.statusCode, this.message);

  @override
  String toString() => message;
}

class UnauthorizedException extends ApiException {
  const UnauthorizedException([
    String message = 'Tu sesión expiró. Inicia sesión de nuevo.',
  ]) : super(401, message);
}

class ApiClient {
  static String? token;
  static const Duration _timeout = Duration(seconds: 10);

  static void setToken(String? value) => token = value;

  static Uri _uri(String path, {Map<String, String>? query}) {
    final base = ServerConfig.baseUrl;
    if (base == null) {
      throw const ApiException(
        0,
        'Primero conecta la app al servidor de la demo.',
      );
    }
    final uri = Uri.parse('$base$path');
    if (query == null || query.isEmpty) return uri;
    return uri.replace(queryParameters: query);
  }

  static Map<String, String> _headers({bool withBody = false}) {
    return {
      'Accept': 'application/json',
      if (withBody) 'Content-Type': 'application/json',
      if (token != null && token!.isNotEmpty) 'Authorization': 'Bearer $token',
    };
  }

  static Future<dynamic> get(
    String path, {
    Map<String, String>? query,
  }) {
    return _send(
      http.get(_uri(path, query: query), headers: _headers()),
    );
  }

  static Future<dynamic> post(String path, [Object? body]) {
    return _send(
      http.post(
        _uri(path),
        headers: _headers(withBody: true),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
    );
  }

  static Future<dynamic> put(String path, [Object? body]) {
    return _send(
      http.put(
        _uri(path),
        headers: _headers(withBody: true),
        body: jsonEncode(body ?? const <String, dynamic>{}),
      ),
    );
  }

  static Future<dynamic> delete(String path) {
    return _send(http.delete(_uri(path), headers: _headers()));
  }

  static Future<dynamic> _send(Future<http.Response> request) async {
    late http.Response response;
    try {
      response = await request.timeout(_timeout);
    } on TimeoutException {
      throw const ApiException(
        0,
        'El servidor tardó demasiado en responder.',
      );
    } catch (_) {
      throw const ApiException(
        0,
        'No se pudo conectar con el servidor. Revisa la red e intenta de nuevo.',
      );
    }

    final text = utf8.decode(response.bodyBytes);
    dynamic decoded;
    if (text.isNotEmpty) {
      try {
        decoded = jsonDecode(text);
      } catch (_) {
        decoded = null;
      }
    }

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return decoded;
    }

    final message = decoded is Map && decoded['error'] is String
        ? decoded['error'] as String
        : 'Error del servidor (${response.statusCode}).';
    if (response.statusCode == 401) {
      throw UnauthorizedException(message);
    }
    throw ApiException(response.statusCode, message);
  }
}
