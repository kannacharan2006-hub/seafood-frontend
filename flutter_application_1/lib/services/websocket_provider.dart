import 'dart:async';
import 'package:flutter/foundation.dart';
import 'websocket_service.dart';

class WebSocketProvider extends ChangeNotifier {
  final WebSocketService _wsService = WebSocketService();
  StreamSubscription<WebSocketMessage>? _subscription;

  bool _isConnected = false;
  String? _lastMessage;
  Map<String, dynamic>? _lastData;

  bool get isConnected => _isConnected;
  String? get lastMessage => _lastMessage;
  Map<String, dynamic>? get lastData => _lastData;

  WebSocketProvider() {
    _init();
  }

  void _init() {
    _subscription = _wsService.messages?.listen(_onMessage);
  }

  void _onMessage(WebSocketMessage message) {
    switch (message.event) {
      case WebSocketEvent.connected:
      case WebSocketEvent.authSuccess:
        _isConnected = true;
        break;
      case WebSocketEvent.disconnected:
      case WebSocketEvent.authFailed:
        _isConnected = false;
        break;
      case WebSocketEvent.stockUpdate:
      case WebSocketEvent.stockChanged:
      case WebSocketEvent.purchaseCreated:
      case WebSocketEvent.exportCreated:
      case WebSocketEvent.conversionCreated:
      case WebSocketEvent.paymentCreated:
      case WebSocketEvent.dashboardRefresh:
        _lastData = message.data;
        break;
      case WebSocketEvent.error:
        _lastMessage = message.message;
        break;
    }
    notifyListeners();
  }

  Future<void> connect(int companyId) async {
    await _wsService.connectWithCompany(companyId);
  }

  void disconnect() {
    _wsService.disconnect();
  }

  void disconnectAndClear() {
    _wsService.disconnectAndClear();
  }

  @override
  void dispose() {
    _subscription?.cancel();
    _wsService.dispose();
    super.dispose();
  }
}
