import 'package:fl_chart/fl_chart.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/charts/models/line_chart_data.dart';

/// This class provides the functionality for building the complex chart display.
class LineChartDataProcessor {
  /// Filters a raw map of historical data based on a selected time range
  ///
  /// @historicalData The data to process and filter
  /// @selectedChartRange The chart range we want to keep the data within
  static Map<DateTime, num> filterHistoricalData(
    Map<DateTime, num>? historicalData,
    ChartRangeEnum selectedChartRange,
  ) {
    if (historicalData == null) {
      return {};
    }
    final cutoffDate = DateTime.now().subtract(ChartRangeUtility.getDurationForRange(selectedChartRange));
    return historicalData.entries
        .where((entry) => entry.key.isAfter(cutoffDate) || entry.key.isAtSameMomentAs(cutoffDate))
        .map((entry) => MapEntry(entry.key, entry.value))
        .toList()
        .cast<MapEntry<DateTime, num>>()
        .fold<Map<DateTime, num>>({}, (map, entry) {
          map[entry.key] = double.parse(entry.value.toStringAsFixed(2));
          return map;
        });
  }

  /// Takes the filtered historical data from @filterHistoricalData and converts it
  ///   into the expected type for the fl_chart library
  static SproutLineChartData prepareChartData(Map<DateTime, num> filteredHistoricalData) {
    final sortedChartEntries = filteredHistoricalData.entries.toList()..sort((a, b) => a.key.compareTo(b.key));
    final chartSpots = sortedChartEntries
        .asMap()
        .entries
        .map((entry) => FlSpot(entry.key.toDouble(), entry.value.value.toDouble()))
        .toList();
    return SproutLineChartData(spots: chartSpots, sortedEntries: sortedChartEntries);
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
