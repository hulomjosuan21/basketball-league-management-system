import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:flutter_dotenv/flutter_dotenv.dart';

enum SocketEvent {
  connectError,
  error,
  disconnect,
  register,
  echo,
  echoResponse,
  privateMessage,
  notification,
}

extension SocketEventExtension on SocketEvent {
  String get value {
    switch (this) {
      case SocketEvent.connectError:
        return 'connect_error';
      case SocketEvent.error:
        return 'error';
      case SocketEvent.disconnect:
        return 'disconnect';
      case SocketEvent.register:
        return 'register';
      case SocketEvent.echo:
        return 'echo';
      case SocketEvent.echoResponse:
        return 'echo_response';
      case SocketEvent.privateMessage:
        return 'private_message';
      case SocketEvent.notification:
        return 'notification';
    }
  }
}

class SocketService {
  static final SocketService _instance = SocketService._internal();
  factory SocketService() => _instance;

  late IO.Socket _socket;
  bool _isInitialized = false;
  bool _hasErrorListeners = false;

  SocketService._internal();

  void init({required String userId}) {
    if (_isInitialized) return;

    _socket = IO.io(
      dotenv.env['API_BASE_URL'] ?? 'http://localhost:5000',
      <String, dynamic>{
        'transports': ['websocket'],
        'autoConnect': false,
      },
    );

    _socket.connect();

    _socket.onConnect((_) {
      print("✅ Connected: ${_socket.id}");
      _socket.emit('register', {'user_id': userId});
    });

    if (!_hasErrorListeners) {
      _hasErrorListeners = true;

      _socket.on('connect_error', (payload) {
        print("❌ connect_error: $payload");
      });

      _socket.on('error', (payload) {
        print("⚠️ error: $payload");
      });

      _socket.on('disconnect', (_) {
        print("🔌 disconnected");
      });
    }

    _isInitialized = true;
  }

  void emit(SocketEvent event, dynamic payload) {
    _socket.emit(event.value, payload);
  }

  void on(SocketEvent event, Function(dynamic) handler) {
    _socket.on(event.value, handler);
  }

  void off(SocketEvent event) {
    _socket.off(event.value);
  }

  void dispose() {
    _socket.dispose();
    _isInitialized = false;
    _hasErrorListeners = false;
  }
}
