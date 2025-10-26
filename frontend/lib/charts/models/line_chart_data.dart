import 'package:fl_chart/fl_chart.dart';

/// Helper class for holding chart data that was separated and calculated by the data processor
class SproutLineChartData {
  final List<FlSpot> spots;
  final List<MapEntry<DateTime, num>> sortedEntries;

  SproutLineChartData({required this.spots, required this.sortedEntries});
}
