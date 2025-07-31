import 'package:fl_chart/fl_chart.dart';
import 'package:sprout/net-worth/models/chart_data.dart';
import 'package:sprout/net-worth/models/chart_range.dart';

/// This class provides the functionality for building the complex chart display.
class NetWorthChartDataProcessor {
  /// Filters a raw map of historical net worth data based on a selected time range
  ///
  /// @historicalData The data to process and filter
  /// @selectedChartRange The chart range we want to keep the data within
  static Map<DateTime, double> filterHistoricalData(
    Map<DateTime, double>? historicalData,
    ChartRange selectedChartRange,
  ) {
    if (historicalData == null) {
      return {};
    }
    final cutoffDate = DateTime.now().subtract(ChartRangeUtility.getDurationForRange(selectedChartRange));
    return historicalData.entries
        .where((entry) => entry.key.isAfter(cutoffDate) || entry.key.isAtSameMomentAs(cutoffDate))
        .map((entry) => MapEntry(entry.key, entry.value))
        .toList()
        .cast<MapEntry<DateTime, double>>()
        .fold<Map<DateTime, double>>({}, (map, entry) {
          map[entry.key] = entry.value;
          return map;
        });
  }

  /// Takes the filtered historical data from @filterHistoricalData and converts it
  ///   into the expected type for the fl_chart library
  static ChartData prepareChartData(Map<DateTime, double> filteredHistoricalData) {
    final sortedChartEntries = filteredHistoricalData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final chartSpots = sortedChartEntries
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value))
        .toList();
    return ChartData(spots: chartSpots, sortedEntries: sortedChartEntries);
  }

  /// Calculates how many chart intervals to display based on the difference in given y values
  static double getChartValueInterval(double minY, double maxY) {
    final double diff = (maxY - minY).abs();
    if (diff <= 10) return 2;
    if (diff <= 50) return 10;
    if (diff <= 100) return 20;
    if (diff <= 500) return 100;
    if (diff <= 1000) return 200;
    if (diff <= 5000) return 1000;
    if (diff <= 10000) return 2000;
    if (diff <= 25000) return 5000;
    if (diff <= 50000) return 10000;
    if (diff <= 100000) return 20000;
    if (diff <= 250000) return 50000;
    if (diff <= 500000) return 100000;
    if (diff <= 1000000) return 200000;
    return 500000;
  }
}
