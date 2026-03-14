import 'package:sprout/api/api.dart';

/// Defines the SSE state utilized within the SSE Provider
class SseConnectionState {
  final bool isConnected;
  final bool isConnecting;
  final Map<SSEDataEventEnum, ({SSEData data, DateTime timestamp})> lastEvents;
  final SSEData? latestData;

  SseConnectionState({
    this.isConnected = false,
    this.isConnecting = false,
    this.lastEvents = const {},
    this.latestData,
  });

  SseConnectionState copyWith({
    bool? isConnected,
    bool? isConnecting,
    Map<SSEDataEventEnum, ({SSEData data, DateTime timestamp})>? lastEvents,
    SSEData? latestData,
  }) {
    return SseConnectionState(
      isConnected: isConnected ?? this.isConnected,
      isConnecting: isConnecting ?? this.isConnecting,
      lastEvents: lastEvents ?? this.lastEvents,
      latestData: latestData ?? this.latestData,
    );
  }
}
