import 'package:sprout/api/api.dart';
import 'package:timeago/timeago.dart' as timeago;

extension APIConfigSyncExtension on APIConfig {
  /// Returns the formatted relative time of the last sync
  String get lastSyncTimeFormatted {
    final time = lastSchedulerRun?.time;
    if (time != null) {
      return timeago.format(time.toLocal());
    }
    return "N/A";
  }

  /// Returns the full status string (Time + Result) for the UI
  String get syncStatusString {
    final time = lastSyncTimeFormatted;
    final run = lastSchedulerRun;

    if (run == null) return "$time - N/A";

    if (run.status == ModelSyncStatusEnum.failed) {
      return "$time - failed: ${run.failureReason ?? 'unknown'}";
    }

    return "$time - success";
  }
}
