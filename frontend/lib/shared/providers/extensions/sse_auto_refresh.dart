import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/providers/sse_provider.dart';

extension SseAutoRefresh on Ref {
  /// Automatically listens for SSE provider updates for forceUpdate and then invalidates this provider to refresh data
  void refreshOnForceUpdate() {
    listen(sseProvider, (prev, next) {
      if (next.latestData?.event == SSEDataEventEnum.forceUpdate) {
        invalidateSelf();
      }
    });
  }
}
