import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../config/api.dart';
import 'secure_storage.dart';

enum WebSocketEvent {
  connected,
  disconnected,
  authSuccess,
  authFailed,
  stockUpdate,
  stockChanged,
  purchaseCreated,
  exportCreated,
  conversionCreated,
  paymentCreated,
  dashboardRefresh,
  error,
}

class WebSocketMessage {
  final WebSocketEvent event;
  final Map<String, dynamic>? data;
  final String? message;

  WebSocketMessage({
    required this.event,
    this.data,
    this.message,
  });
}

class WebSocketService {
  static final WebSocketService _instance = WebSocketService._internal();
  factory WebSocketService() => _instance;
  WebSocketService._internal();

  WebSocketChannel? _channel;
  Timer? _reconnectTimer;
  Timer? _heartbeatTimer;
  StreamController<WebSocketMessage>? _messageController;

  bool _isConnecting = false;
  bool _isConnected = false;
  String? _currentToken;

  static const Duration _reconnectDelay = Duration(seconds: 3);
  static const Duration _heartbeatInterval = Duration(seconds: 25);

  Stream<WebSocketMessage>? get messages => _messageController?.stream;
  bool get isConnected => _isConnected;

  Future<void> connect() async {
    if (_isConnecting || _isConnected) return;

    final token = await SecureStorage.getToken();
    if (token == null) return;

    await _connectWithToken(token);
  }

  Future<void> connectWithCompany(int companyId) async {
    if (_isConnecting) return;

    final token = await SecureStorage.getToken();
    if (token == null) return;

    _currentToken = token;

    await _doConnect();

    _authenticate(companyId, token);
  }

  Future<void> _connectWithToken(String token) async {
    _currentToken = token;
    await _doConnect();
  }

  Future<void> _doConnect() async {
    if (_isConnecting) return;
    _isConnecting = true;

    try {
      final wsUrl = Api.baseUrl.replaceFirst('http', 'ws');
      final uri = Uri.parse('$wsUrl/ws');

      _channel = WebSocketChannel.connect(uri);

      _messageController ??= StreamController<WebSocketMessage>.broadcast();

      _channel!.stream.listen(
        _onMessage,
        onError: (error) {
          _isConnected = false;
          _isConnecting = false;
          _scheduleReconnect();
        },
        onDone: () {
          _isConnected = false;
          _isConnecting = false;
          _scheduleReconnect();
        },
        cancelOnError: false,
      );

      _startHeartbeat();
    } catch (e) {
      _isConnecting = false;
      _scheduleReconnect();
    }
  }

  void _authenticate(int companyId, String token) {
    final authMessage = jsonEncode({
      'type': 'auth',
      'companyId': companyId,
      'token': token,
    });

    _channel?.sink.add(authMessage);
  }

  void _onMessage(dynamic data) {
    try {
      final message = jsonDecode(data as String) as Map<String, dynamic>;
      final type = message['type'] as String?;

      WebSocketEvent event;
      Map<String, dynamic>? eventData;

      switch (type) {
        case 'auth_success':
          event = WebSocketEvent.authSuccess;
          _isConnected = true;
          _isConnecting = false;
          _messageController?.add(WebSocketMessage(
              event: event, message: 'Connected successfully'));
          break;

        case 'error':
          event = WebSocketEvent.authFailed;
          _messageController?.add(WebSocketMessage(
            event: event,
            message: message['message'] as String?,
          ));
          break;

        case 'stock_update':
          event = WebSocketEvent.stockUpdate;
          eventData = message['data'] as Map<String, dynamic>?;
          _messageController
              ?.add(WebSocketMessage(event: event, data: eventData));
          break;

        case 'purchase_created':
          event = WebSocketEvent.purchaseCreated;
          eventData = message['data'] as Map<String, dynamic>?;
          _messageController
              ?.add(WebSocketMessage(event: event, data: eventData));
          break;

        case 'export_created':
          event = WebSocketEvent.exportCreated;
          eventData = message['data'] as Map<String, dynamic>?;
          _messageController
              ?.add(WebSocketMessage(event: event, data: eventData));
          break;

        case 'conversion_created':
          event = WebSocketEvent.conversionCreated;
          eventData = message['data'] as Map<String, dynamic>?;
          _messageController
              ?.add(WebSocketMessage(event: event, data: eventData));
          break;

        case 'payment_created':
          event = WebSocketEvent.paymentCreated;
          eventData = message['data'] as Map<String, dynamic>?;
          _messageController
              ?.add(WebSocketMessage(event: event, data: eventData));
          break;

        case 'stock_changed':
          event = WebSocketEvent.stockChanged;
          eventData = message['data'] as Map<String, dynamic>?;
          _messageController
              ?.add(WebSocketMessage(event: event, data: eventData));
          break;

        case 'dashboard_refresh':
          event = WebSocketEvent.dashboardRefresh;
          eventData = message['data'] as Map<String, dynamic>?;
          _messageController
              ?.add(WebSocketMessage(event: event, data: eventData));
          break;

        default:
          return;
      }
    } catch (e) {
      // Silently ignore parse errors
    }
  }

  void _onError(dynamic error) {
    _isConnected = false;
    _isConnecting = false;
  }

  void _onDone() {
    _isConnected = false;
    _isConnecting = false;
  }

  void _startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(_heartbeatInterval, (_) {
      if (_isConnected && _channel != null) {
        try {
          _channel!.sink.add(jsonEncode({'type': 'ping'}));
        } catch (e) {
          disconnect();
        }
      }
    });
  }

  void _scheduleReconnect() {
    if (_reconnectTimer?.isActive == true) return;
    if (_currentToken == null) return;

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(_reconnectDelay, () {
      if (_currentToken != null) {
        _doConnect();
      }
    });
  }

  void disconnect() {
    _reconnectTimer?.cancel();
    _heartbeatTimer?.cancel();
    _isConnected = false;
    _isConnecting = false;

    _channel?.sink.close();
    _channel = null;

    _messageController
        ?.add(WebSocketMessage(event: WebSocketEvent.disconnected));
  }

  void disconnectAndClear() {
    disconnect();
    _currentToken = null;
    _messageController?.close();
    _messageController = null;
  }

  void dispose() {
    disconnectAndClear();
  }
}
