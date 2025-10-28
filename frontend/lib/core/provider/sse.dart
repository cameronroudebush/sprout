import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:sprout/account/account_provider.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/provider/base.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/provider/storage.dart';
import 'package:sprout/user/user_provider.dart';

/// This provider handles setup for creating a listener for a stream of Server Sent Events
class SSEProvider extends BaseProvider<CoreApi> {
  StreamSubscription<Map<String, dynamic>>? _sseSubscription;
  bool _isConnecting = false;
  bool _isConnected = false;
  Timer? _reconnectTimer; // Timer for delayed reconnect attempts
  /// Subscription for incoming events
  StreamSubscription<SSEData>? _sub;

  // Holds what to call when messages come in
  final StreamController<SSEData> _eventController = StreamController.broadcast();
  Stream<SSEData> get onEvent => _eventController.stream;

  // Back-off strategy variables
  int _reconnectAttempts = 0;
  final Duration _initialReconnectDelay = const Duration(seconds: 2);
  final Duration _maxReconnectDelay = const Duration(seconds: 60);

  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;

  SSEProvider(super.api);

  @override
  Future<void> onInit() async {
    _sub = onEvent.listen((data) async {
      if (data.event == SSEDataEventEnum.sync_) {
        // TODO
        // await BaseProvider.updateAllData(showSnackbar: true);
        // Update manual tracking incase that's what this was from
        final accountProvider = ServiceLocator.get<AccountProvider>();
        accountProvider.manualSyncIsRunning = false;
        accountProvider.notifyListeners();
      } else if (data.event == SSEDataEventEnum.forceUpdate) {
        // TODO
        // await BaseProvider.updateAllData(showSnackbar: false);
      }
    });
    await super.onInit();
  }

  /// Builds the SSE stream to the backend and returns it. You can then listen to the return of JSON on that stream.
  Stream<Map<String, dynamic>> _buildSse() async* {
    // We have to manually implement this because the openapi client doesn't give us sse capability with the stream.
    final client = api.apiClient.client;
    final url = Uri.parse('${api.apiClient.basePath}/sse');
    final request = http.Request('GET', url);

    final currentJwt = await SecureStorageProvider.getValue(SecureStorageProvider.jwtKey);
    if (currentJwt != null) request.headers.addAll({'Authorization': 'Bearer $currentJwt'});
    request.headers.addAll({'Accept': 'text/event-stream', 'Cache-Control': 'no-cache'});

    final response = await client.send(request);

    if (response.statusCode == 200) {
      try {
        await for (var line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (line.startsWith('data: ') && line.length > 6) {
            final data = line.substring(6);
            yield json.decode(data);
          }
        }
      } catch (e) {
        throw Exception('SSE stream disconnected: $e');
      }
    } else {
      throw Exception('Failed to connect to SSE endpoint: ${response.statusCode}');
    }
  }

  /// Starts the SSE connection.
  /// [forceReconnect] will cancel any existing connection and attempt a new one.
  Future<void> _startSSE({bool forceReconnect = false}) async {
    final userProvider = ServiceLocator.get<UserProvider>();
    if (!userProvider.isLoggedIn) {
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
      final Stream<Map<String, dynamic>> sseStream = _buildSse();
      _isConnected = true;
      _reconnectAttempts = 0;
      notifyListeners();

      _sseSubscription = sseStream.listen(
        (event) {
          final outEvent = SSEData.fromJson(event)!;
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
      _handleConnectionLost(e, forceReconnect: false);
    }
  }

  /// Unified handler for when the SSE connection is lost (error or done).
  void _handleConnectionLost(dynamic e, {bool forceReconnect = true}) {
    if (e != null && e.message != null && e.message.contains('403')) {
      final userProvider = ServiceLocator.get<UserProvider>();
      userProvider.logout(forced: true);
      return;
    }
    _isConnected = false;
    _isConnecting = false; // Mark connection attempt as finished for now
    notifyListeners(); // Notify UI about disconnection

    _cancelSubscription(); // Ensure subscription is definitively cancelled

    // If we are not forcing a reconnect, just stop here.
    if (!forceReconnect) {
      return;
    }

    // Implement exponential back-off for reconnect attempts
    _reconnectAttempts++;
    double delaySeconds = (_initialReconnectDelay.inSeconds * (1 << (_reconnectAttempts - 1))).toDouble();
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
