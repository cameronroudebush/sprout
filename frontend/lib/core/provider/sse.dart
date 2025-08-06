import 'dart:async';

import 'package:sprout/auth/provider.dart';
import 'package:sprout/core/api/sse.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/model/rest.request.dart';

/// This provider handles setup for creating a listener for a stream of Server Sent Events
class SSEProvider extends BaseProvider<SSEAPI> {
  StreamSubscription<Map<String, dynamic>>? _sseSubscription;
  bool _isConnecting = false;
  bool _isConnected = false;
  Timer? _reconnectTimer; // Timer for delayed reconnect attempts
  /// Subscription for incoming events
  StreamSubscription<SSEBody<dynamic>>? _sub;

  // Holds what to call when messages come in
  final StreamController<SSEBody> _eventController = StreamController.broadcast();
  Stream<SSEBody> get onEvent => _eventController.stream;

  // Back-off strategy variables
  int _reconnectAttempts = 0;
  final Duration _initialReconnectDelay = const Duration(seconds: 2);
  final Duration _maxReconnectDelay = const Duration(seconds: 60);

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  SSEProvider(super.api);

  @override
  Future<void> onInit() async {
    _sub = onEvent.listen((data) {
      if (data.queue == "sync") {
        BaseProvider.updateAllData(showSnackbar: true);
      }
    });
  }

  /// Starts the SSE connection.
  /// [forceReconnect] will cancel any existing connection and attempt a new one.
  Future<void> _startSSE({bool forceReconnect = false}) async {
    final authProvider = ServiceLocator.get<AuthProvider>();
    if (!authProvider.isLoggedIn) {
      _handleConnectionLost(null);
    }
    // If a connection is already active and we are not forcing a reconnect, just return.
    if (_sseSubscription != null && !_sseSubscription!.isPaused && !forceReconnect) {
      return;
    }
    // If we're already in the process of connecting, don't start another one
    if (_isConnecting && !forceReconnect) {
      return;
    }

    // Cancel any pending reconnect timer
    _reconnectTimer?.cancel();
    _reconnectTimer = null;

    _isConnecting = true;
    _isConnected = false;
    notifyListeners();

    // Ensure any previous subscription is cancelled before creating a new one
    await _cancelSubscription();

    try {
      final Stream<Map<String, dynamic>> sseStream = api.buildSSE();
      _isConnected = true;
      _reconnectAttempts = 0;
      notifyListeners();

      _sseSubscription = sseStream.listen(
        (event) {
          final outEvent = SSEBody.fromJson(event);
          _eventController.add(outEvent);
        },
        onError: (error) {
          _handleConnectionLost(error);
        },
        onDone: () {
          _handleConnectionLost(null);
        },
        cancelOnError: true,
      );
    } catch (e) {
      _handleConnectionLost(e);
    }
  }

  /// Unified handler for when the SSE connection is lost (error or done).
  void _handleConnectionLost(dynamic e) {
    if (e != null && e.message != null && e.message.contains('403')) {
      final authProvider = ServiceLocator.get<AuthProvider>();
      authProvider.logout(forced: true);
      return;
    }
    _isConnected = false;
    _isConnecting = false; // Mark connection attempt as finished for now
    notifyListeners(); // Notify UI about disconnection

    _cancelSubscription(); // Ensure subscription is definitively cancelled

    // Implement exponential back-off for reconnect attempts
    _reconnectAttempts++;
    double delaySeconds = (_initialReconnectDelay.inSeconds * (1 << (_reconnectAttempts - 1))) as double;
    if (delaySeconds > _maxReconnectDelay.inSeconds) {
      delaySeconds = _maxReconnectDelay.inSeconds.toDouble();
    }

    final Duration nextDelay = Duration(seconds: delaySeconds.toInt());

    _reconnectTimer?.cancel(); // Cancel any existing timer before setting a new one
    _reconnectTimer = Timer(nextDelay, () {
      _startSSE(); // Attempt to reconnect after the calculated delay
    });
  }

  Future<void> _stopSSE() async {
    _reconnectTimer?.cancel(); // Cancel any pending reconnect timer
    _reconnectTimer = null;

    await _cancelSubscription();
    _isConnected = false;
    _isConnecting = false;
    _reconnectAttempts = 0; // Reset attempts on explicit stop
    notifyListeners();
  }

  Future<void> _cancelSubscription() async {
    if (_sseSubscription != null) {
      await _sseSubscription!.cancel();
      _sseSubscription = null;
    }
  }

  @override
  void dispose() {
    _reconnectTimer?.cancel(); // Clean up timer
    _cancelSubscription(); // Ensure subscription is cancelled
    cleanupData();
    super.dispose();
  }

  @override
  Future<void> updateData() async {
    _startSSE();
  }

  @override
  Future<void> cleanupData() async {
    _stopSSE();
    _sub?.cancel();
  }
}
