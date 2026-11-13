import 'dart:async';
import 'dart:convert';

import 'package:web_socket_channel/web_socket_channel.dart';

import 'server_config.dart';

class RealtimeEvent {
  final String type;
  final dynamic data;

  const RealtimeEvent(this.type, [this.data]);
}

class RealtimeService {
  final StreamController<RealtimeEvent> _controller =
      StreamController<RealtimeEvent>.broadcast();

  WebSocketChannel? _channel;
  StreamSubscription<dynamic>? _subscription;
  Timer? _reconnectTimer;
  Timer? _pingTimer;

  String? _token;
  bool _closedByUser = true;
  bool _connecting = false;
  bool _connected = false;
  int _attempt = 0;

  Stream<RealtimeEvent> get events => _controller.stream;
  bool get isConnected => _connected;

  Future<void> connect(String token) async {
    _token = token;
    _closedByUser = false;
    if (_connected || _connecting) return;
    await _open();
  }

  Future<void> _open() async {
    final token = _token;
    if (token == null || token.isEmpty || _closedByUser || _connecting) return;

    _connecting = true;
    try {
      final base = ServerConfig.wsBaseUrl;
      if (base == null) throw StateError('No server configured');

      final uri = Uri.parse(
        '$base/ws',
      ).replace(queryParameters: {'token': token});
      final channel = WebSocketChannel.connect(uri);
      await channel.ready.timeout(const Duration(seconds: 6));

      if (_closedByUser || _token != token) {
        await channel.sink.close();
        return;
      }

      _channel = channel;
      _connected = true;
      _attempt = 0;
      _controller.add(const RealtimeEvent('connected'));

      _subscription = channel.stream.listen(
        _handleMessage,
        onDone: _handleDisconnect,
        onError: (_) => _handleDisconnect(),
        cancelOnError: true,
      );
      _startPing();
    } catch (_) {
      _connected = false;
      _scheduleReconnect();
    } finally {
      _connecting = false;
    }
  }

  void _handleMessage(dynamic message) {
    if (message is! String) return;
    try {
      final decoded = jsonDecode(message);
      if (decoded is Map<String, dynamic> && decoded['type'] is String) {
        _controller.add(
          RealtimeEvent(decoded['type'] as String, decoded['data']),
        );
      }
    } catch (_) {
      // Ignore malformed realtime messages.
    }
  }

  void _handleDisconnect() {
    _connected = false;
    _subscription?.cancel();
    _subscription = null;
    _channel = null;
    _stopPing();
    if (!_closedByUser) _scheduleReconnect();
  }

  void _scheduleReconnect() {
    _reconnectTimer?.cancel();
    if (_closedByUser) return;

    _attempt += 1;
    if (_attempt == 3) {
      _controller.add(const RealtimeEvent('reconnectFailed'));
    }

    final delay = Duration(seconds: _attempt >= 6 ? 15 : 3);
    _reconnectTimer = Timer(delay, _open);
  }

  void _startPing() {
    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(const Duration(seconds: 20), (_) {
      try {
        _channel?.sink.add(jsonEncode({'type': 'ping'}));
      } catch (_) {
        // The stream error handler reconnects.
      }
    });
  }

  void _stopPing() {
    _pingTimer?.cancel();
    _pingTimer = null;
  }

  Future<void> disconnect() async {
    _closedByUser = true;
    _reconnectTimer?.cancel();
    _reconnectTimer = null;
    _stopPing();

    final subscription = _subscription;
    _subscription = null;
    await subscription?.cancel();

    final channel = _channel;
    _channel = null;
    _connected = false;
    try {
      await channel?.sink.close();
    } catch (_) {
      // The socket may already be closed.
    }
  }

  Future<void> dispose() async {
    await disconnect();
    await _controller.close();
  }
}
