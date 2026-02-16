import 'package:sprout/api/api.dart';

/// Helper functions for the specific data points
extension HistoricalDataPointExtensions on HistoricalDataPoint {
  /// Converts the given history into a map for chart display
  static Map<DateTime, num> toMap(List<HistoricalDataPoint> history) {
    return {for (var item in history) item.date: item.value};
  }

  // /// Returns the historical data filtered from 'Now' going back
  // /// by the duration defined in the specific ChartRangeEnum.
  // static Map<DateTime, num> getHistorical(EntityHistory history, ChartRangeEnum frame) {
  //   final point = history.getValueByFrame(frame);
  //   final cutoffDate = point.start;
  //   return {
  //     for (var item in historicalData.where((entry) {
  //       return entry.date.isAfter(cutoffDate) || entry.date.isAtSameMomentAs(cutoffDate);
  //     }))
  //       item.date: item.value,
  //   };
  // }
}
