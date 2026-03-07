import 'package:sprout/api/api.dart';

/// Helper functions for the specific data points
extension HistoricalDataPointExtensions on HistoricalDataPoint {
  /// Converts the given history into a map for chart display
  static Map<DateTime, num> toMap(List<HistoricalDataPoint> history) {
    return {for (var item in history) item.date: item.value};
  }
}
