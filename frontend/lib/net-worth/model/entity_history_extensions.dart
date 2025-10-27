import 'package:sprout/api/api.dart';

/// Helper functions for entity history
extension EntityHistoryExtensions on EntityHistory {
  /// Returns the value by the given time frame as supported in the above properties
  EntityHistoryDataPoint getValueByFrame(ChartRangeEnum frame) {
    switch (frame) {
      case ChartRangeEnum.oneDay:
        return last1Day;
      case ChartRangeEnum.sevenDays:
        return last7Days;
      case ChartRangeEnum.oneMonth:
        return lastMonth;
      case ChartRangeEnum.threeMonths:
        return lastThreeMonths;
      case ChartRangeEnum.sixMonths:
        return lastSixMonths;
      case ChartRangeEnum.oneYear:
        return lastYear;
      case ChartRangeEnum.allTime:
      default:
        return allTime;
    }
  }

  /// Returns the history as a Map<DateTime, num>
  Map<DateTime, num> get historicalDataDate {
    return historicalData.map((key, value) {
      final ms = int.parse(key);
      final date = DateTime.fromMillisecondsSinceEpoch(ms);
      return MapEntry(date, value);
    });
  }
}

/// Helper functions for the specific data points
extension EntityHistoryDataPointExtensions on EntityHistoryDataPoint {
  /// Returns the history as a Map<DateTime, num>
  Map<DateTime, num> get historyDate {
    return history.map((key, value) {
      final ms = int.parse(key);
      final date = DateTime.fromMillisecondsSinceEpoch(ms);
      return MapEntry(date, value);
    });
  }
}
