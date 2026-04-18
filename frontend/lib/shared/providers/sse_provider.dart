import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/auth/auth_provider.dart';
import 'package:sprout/shared/api/base_api.dart';
import 'package:sprout/shared/models/sse_state.dart';

part 'sse_provider.g.dart';

/// Defines an SSE riverpod that tracks our current SSE info
@Riverpod(keepAlive: true)
class Sse extends _$Sse {
  Timer? _reconnectTimer;
  int _reconnectAttempts = 0;
  http.Client? _httpClient;

  @override
  SseConnectionState build() {
    ref.listen(authProvider, (previous, next) {
      if (next.value != null && previous?.value == null) {
        // User just logged in
        _startSSE();
      } else if (next.value == null) {
        // User logged out
        _stopSSE();
      }
    });

    final currentAuth = ref.read(authProvider).value;
    if (currentAuth != null) {
      Future.microtask(() => _startSSE());
    }

    // Cleanup on logout or disposal
    ref.onDispose(() {
      Future.microtask(() => _stopSSE());
    });

    return SseConnectionState();
  }

  /// Starts the SSE connection to the backend
  Future<void> _startSSE() async {
    if (state.isConnecting || state.isConnected) return;

    state = state.copyWith(isConnecting: true);
    _reconnectTimer?.cancel();

    try {
      final client = await ref.read(baseAuthenticatedClientProvider.future);

      final url = Uri.parse('${client.basePath}/sse');
      final request = http.Request('GET', url);
      request.headers.addAll({
        'Accept': 'text/event-stream',
        'Cache-Control': 'no-cache',
      });

      _httpClient = client.client;
      final response = await _httpClient!.send(request);

      if (response.statusCode == 200) {
        _reconnectAttempts = 0;
        state = state.copyWith(isConnected: true, isConnecting: false);

        final stream = response.stream.transform(utf8.decoder).transform(const LineSplitter());

        await for (var line in stream) {
          if (line.startsWith('data: ') && line.length > 6) {
            final sseData = SSEData.fromJson(json.decode(line.substring(6)));
            if (sseData != null) {
              // Update state reactively
              final newEvents = Map<SSEDataEventEnum, ({SSEData data, DateTime timestamp})>.from(state.lastEvents);
              newEvents[sseData.event] = (data: sseData, timestamp: DateTime.now());

              state = state.copyWith(latestData: sseData, lastEvents: newEvents);
            }
          }
        }
      } else {
        throw Exception('Status: ${response.statusCode}');
      }
    } catch (e) {
      _handleRetry();
    }
  }

  /// Handles what to do when we lose connection and want to attempt to reconnect.
  void _handleRetry() {
    state = state.copyWith(isConnected: false, isConnecting: false);
    _reconnectAttempts++;

    final delay = (2 * (1 << (_reconnectAttempts - 1))).clamp(2, 60);
    _reconnectTimer = Timer(Duration(seconds: delay), () => _startSSE());
  }

  /// Stops and disconnects the SSE
  void _stopSSE() {
    if (!ref.mounted) return;
    _reconnectTimer?.cancel();
    _httpClient?.close();
    state = SseConnectionState();
  }
}
