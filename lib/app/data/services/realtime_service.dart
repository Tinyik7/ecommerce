import 'dart:async';
import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class RealtimeService {
  RealtimeService._();
  static final RealtimeService instance = RealtimeService._();

  static const bool _useAndroidEmulatorHost =
      bool.fromEnvironment('USE_ANDROID_EMULATOR_HOST', defaultValue: false);

  final StreamController<Map<String, dynamic>> _eventsController =
      StreamController<Map<String, dynamic>>.broadcast();

  Stream<Map<String, dynamic>> get events => _eventsController.stream;

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  bool _manuallyClosed = false;

  String get _wsUrl {
    const String webOrDesktop = 'ws://localhost:8080/ws/products';
    if (kIsWeb) return webOrDesktop;

    try {
      if (Platform.isAndroid && _useAndroidEmulatorHost) {
        return 'ws://10.0.2.2:8080/ws/products';
      }
    } on UnsupportedError {
      return webOrDesktop;
    }

    return webOrDesktop;
  }

  void connect() {
    _manuallyClosed = false;
    _reconnectTimer?.cancel();
    _openSocket();
  }

  void disconnect() {
    _manuallyClosed = true;
    _reconnectTimer?.cancel();
    _channel?.sink.close();
    _channel = null;
  }

  void _openSocket() {
    try {
      _channel = WebSocketChannel.connect(Uri.parse(_wsUrl));
      _channel!.stream.listen(
        _onMessage,
        onDone: _scheduleReconnect,
        onError: (_) => _scheduleReconnect(),
        cancelOnError: true,
      );
    } catch (_) {
      _scheduleReconnect();
    }
  }

  void _onMessage(dynamic raw) {
    if (raw is! String || raw.isEmpty) return;
    try {
      final dynamic decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) {
        _eventsController.add(decoded);
      }
    } catch (_) {
      // Ignore malformed events to keep stream alive.
    }
  }

  void _scheduleReconnect() {
    if (_manuallyClosed) return;
    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(const Duration(seconds: 5), _openSocket);
  }
}
