import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/providers/secure_storage_provider.dart';

part 'sse_provider.g.dart';

/// Defines an SSE riverpod that tracks our current SSE info
@Riverpod(keepAlive: true)
class Sse extends _$Sse {
  // Connection state tracking
  bool _isConnected = false;
  bool _isConnecting = false;
  final Map<SSEDataEventEnum, ({SSEData data, DateTime timestamp})> _lastEvents = {};

  // Back-off variables
  int _reconnectAttempts = 0;
  final Duration _initialReconnectDelay = const Duration(seconds: 2);
  final Duration _maxReconnectDelay = const Duration(seconds: 60);
  Timer? _reconnectTimer;

  // UI info
  bool get isConnected => _isConnected;
  bool get isConnecting => _isConnecting;
  Map<SSEDataEventEnum, ({SSEData data, DateTime timestamp})> get lastEvents => _lastEvents;

  @override
  Stream<SSEData> build() {
    // Watch Auth. If user logs out, this stream provider is disposed.
    // If they log in, it starts fresh.
    final authState = ref.watch(authProvider);
    final user = authState.value;

    if (user == null) {
      _stopSSE();
      return const Stream.empty();
    }

    // Setup the stream controller
    final controller = StreamController<SSEData>.broadcast();
    // Start the connection logic
    _startSSE(controller);
    //  Cleanup when the provider is disposed (e.g. on logout)
    ref.onDispose(() {
      _stopSSE();
      controller.close();
    });

    return controller.stream;
  }

  /// Starts the SSE connection to the backend
  Future<void> _startSSE(StreamController<SSEData> controller) async {
    if (_isConnecting || _isConnected) return;

    _isConnecting = true;
    _reconnectTimer?.cancel();

    try {
      final client = await ref.read(baseApiClientProvider.future);
      final idToken = await SecureStorageProvider.getValue(SecureStorageProvider.idToken);

      final url = Uri.parse('${client.basePath}/sse');
      final request = http.Request('GET', url);

      // Setup Headers
      request.headers.addAll({'Accept': 'text/event-stream', 'Cache-Control': 'no-cache'});
      if (idToken != null) {
        request.headers['Authorization'] = 'Bearer $idToken';
      }

      final response = await client.client.send(request);

      if (response.statusCode == 200) {
        _isConnected = true;
        _isConnecting = false;
        _reconnectAttempts = 0;

        await for (var line in response.stream.transform(utf8.decoder).transform(const LineSplitter())) {
          if (line.startsWith('data: ') && line.length > 6) {
            final rawData = line.substring(6);
            final jsonMap = json.decode(rawData);
            final sseData = SSEData.fromJson(jsonMap);

            if (sseData != null) {
              _lastEvents[sseData.event] = (data: sseData, timestamp: DateTime.now());
              controller.add(sseData);
            }
          }
        }
      } else {
        throw Exception('Status: ${response.statusCode}');
      }
    } catch (e) {
      _handleRetry(controller);
    }
  }

  /// Handles what to do when we lose connection and want to attempt to reconnect.
  void _handleRetry(StreamController<SSEData> controller) {
    _isConnected = false;
    _isConnecting = false;

    _reconnectAttempts++;
    int delay = (_initialReconnectDelay.inSeconds * (1 << (_reconnectAttempts - 1)));
    if (delay > _maxReconnectDelay.inSeconds) delay = _maxReconnectDelay.inSeconds;

    _reconnectTimer = Timer(Duration(seconds: delay), () => _startSSE(controller));
  }

  /// Stops and disconnects the SSE
  void _stopSSE() {
    _reconnectTimer?.cancel();
    _isConnected = false;
    _isConnecting = false;
    _reconnectAttempts = 0;
  }
}
