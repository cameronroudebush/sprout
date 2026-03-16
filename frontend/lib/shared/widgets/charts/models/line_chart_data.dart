import 'dart:math' as math;

import 'package:fl_chart/fl_chart.dart';

/// Helper class for holding chart data that was separated and calculated by the data processor
class SproutLineChartData {
  final List<FlSpot> spots;
  final List<MapEntry<DateTime, num>> sortedEntries;

  SproutLineChartData({required this.spots, required this.sortedEntries});

  /// Returns the minimum Y value from the dataset.
  /// Returns 0.0 if the list is empty to prevent errors.
  double get minY {
    if (spots.isEmpty) return 0.0;
    return spots.map((spot) => spot.y).reduce(math.min);
  }

  /// Returns the maximum Y value from the dataset.
  /// Returns 0.0 if the list is empty to prevent errors.
  double get maxY {
    if (spots.isEmpty) return 0.0;
    return spots.map((spot) => spot.y).reduce(math.max);
  }
}
