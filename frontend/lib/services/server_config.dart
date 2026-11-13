import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ServerConfig {
  static const String _prefsKey = 'megafonito_server_url';
  static String? _baseUrl;

  static String? get baseUrl => _baseUrl;
  static bool get isConfigured => _baseUrl != null;

  static String? get wsBaseUrl {
    final base = _baseUrl;
    if (base == null) return null;
    if (base.startsWith('https://')) {
      return base.replaceFirst('https://', 'wss://');
    }
    return base.replaceFirst('http://', 'ws://');
  }

  static Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_prefsKey);
    if (saved == null || saved.trim().isEmpty) return;
    _baseUrl = normalize(saved);
  }

  static Future<void> save(String input) async {
    final normalized = normalize(input);
    if (normalized == null) {
      throw const FormatException('La dirección del servidor no es válida.');
    }
    _baseUrl = normalized;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsKey, normalized);
  }

  static Future<void> clear() async {
    _baseUrl = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_prefsKey);
  }

  static String? normalize(String input) {
    var value = input.trim();
    if (value.isEmpty) return null;

    if (value.startsWith('megafonito://')) {
      value = value.substring('megafonito://'.length);
    }
    if (!value.contains('://')) {
      value = 'http://$value';
    }

    final uri = Uri.tryParse(value);
    if (uri == null || uri.host.isEmpty) return null;
    if (uri.scheme != 'http' && uri.scheme != 'https') return null;

    final port = uri.hasPort
        ? uri.port
        : (uri.scheme == 'https' ? 443 : 80);
    final normalized = Uri(
      scheme: uri.scheme,
      host: uri.host,
      port: port,
    ).toString();
    return normalized.endsWith('/')
        ? normalized.substring(0, normalized.length - 1)
        : normalized;
  }

  static Future<bool> checkHealth({
    Duration timeout = const Duration(seconds: 4),
  }) {
    final base = _baseUrl;
    if (base == null) return Future.value(false);
    return probe(base, timeout: timeout);
  }

  static Future<bool> probe(
    String input, {
    Duration timeout = const Duration(seconds: 4),
  }) async {
    final normalized = normalize(input);
    if (normalized == null) return false;

    try {
      final response = await http
          .get(Uri.parse('$normalized/api/health'))
          .timeout(timeout);
      if (response.statusCode != 200) return false;
      final decoded = jsonDecode(utf8.decode(response.bodyBytes));
      if (decoded is! Map) return false;
      return decoded['ok'] == true || decoded['app'] == 'megafonito';
    } catch (_) {
      return false;
    }
  }
}
