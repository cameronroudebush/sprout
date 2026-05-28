import 'dart:math' as math;
import 'dart:ui';

import 'package:fl_chart/fl_chart.dart';

/// Represents the configuration for displaying data for a line chart
class LineSeriesConfig {
  final Color? color;
  final bool isDashed;
  final double width;

  /// If this series should appear in the tooltip
  final bool showInTooltip;

  /// If we should ignore our default [color] and instead use green/red for positive and negative values
  final bool usePositiveNegativeColors;

  const LineSeriesConfig(
      {this.color,
      this.isDashed = false,
      this.width = 3.0,
      this.usePositiveNegativeColors = false,
      this.showInTooltip = true});
}

/// Contains the data to render alongside other configuration for a line
class SproutChartSeries {
  final SproutLineChartData data;
  final String label;
  final LineSeriesConfig config;

  SproutChartSeries({
    required this.data,
    required this.label,
    required this.config,
  });
}

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
