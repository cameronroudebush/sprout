import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/charts/models/line_chart_data.dart';
import 'package:sprout/charts/processors/line_chart_processor.dart';

/// A line chart that displays the given data in a line chart format
class SproutLineChart extends StatelessWidget {
  /// If the y axis number should be shown
  final bool showYAxis;

  /// If the x axis dates should be shown
  final bool showXAxis;

  /// If the grid should be shown as a background to this chart
  final bool showGrid;

  /// If we want a border around the chart
  final bool showBorder;

  /// The chart range to render of
  final ChartRange chartRange;

  /// The data to render in this line chart
  final Map<DateTime, double>? data;

  /// An optional function to format the value displayed in the line chart
  final String Function(num value)? formatValue;

  final double height;

  const SproutLineChart({
    super.key,
    required this.data,
    required this.chartRange,
    this.formatValue,
    this.showYAxis = false,
    this.showXAxis = false,
    this.showGrid = false,
    this.showBorder = false,
    this.height = 150,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data == null || data!.isEmpty) {
      return SizedBox.shrink();
    } else {
      final filteredHistoricalData = LineChartDataProcessor.filterHistoricalData(data, chartRange);
      final preparedData = LineChartDataProcessor.prepareChartData(filteredHistoricalData);
      return SizedBox(
        height: height,
        child: LineChart(_buildLineChartData(preparedData, chartRange, theme), duration: Duration.zero),
      );
    }
  }

  /// Builds the widget for our necessary line chart
  LineChartData _buildLineChartData(SproutLineChartData data, ChartRange selectedChartRange, ThemeData theme) {
    final spots = data.spots;

    double minY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    double maxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    // Dynamically adjust font size for X-axis labels
    double xLabelFontSize = 10.0;

    // Determine the Y axis text size
    double yReservedSize = 60; // Default size
    if (maxY == 0 && minY == 0) {
      yReservedSize = 0;
    } else {
      int numDigits = max(maxY.abs().toInt().toString().length, minY.abs().toInt().toString().length);
      yReservedSize = 60 + (numDigits - 3).clamp(0, 4) * 10;
    }

    /// Styling/theme
    final colorScheme = theme.colorScheme;
    final lineColor = colorScheme.primary.withValues(alpha: .3);
    final showCurve = ChartRangeUtility.shouldBeCurved(selectedChartRange);

    return LineChartData(
      gridData: FlGridData(
        show: showGrid,
        drawVerticalLine: true,
        getDrawingHorizontalLine: (value) => FlLine(color: lineColor, strokeWidth: 0.5),
        getDrawingVerticalLine: (value) => FlLine(color: lineColor, strokeWidth: 0.5),
      ),
      titlesData: FlTitlesData(
        show: true,
        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
        bottomTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: showXAxis,
            maxIncluded: false,
            minIncluded: false,
            reservedSize: 30,
            getTitlesWidget: (value, metaTitle) {
              if (value.toInt() < data.sortedEntries.length) {
                final date = data.sortedEntries[value.toInt()].key;
                String format = ChartRangeUtility.getDateFormat(selectedChartRange);
                return SideTitleWidget(
                  fitInside: SideTitleFitInsideData.fromTitleMeta(metaTitle),
                  meta: metaTitle,
                  child: Text(
                    DateFormat(format).format(date),
                    style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface, fontSize: xLabelFontSize),
                  ),
                );
              }
              return const Text('');
            },
            interval: ChartRangeUtility.getChartInterval(selectedChartRange, spots.length),
          ),
        ),
        leftTitles: AxisTitles(
          sideTitles: SideTitles(
            showTitles: showYAxis,
            reservedSize: yReservedSize,
            // minIncluded: false,
            // maxIncluded: false,
            getTitlesWidget: (value, metaTitle) {
              return SideTitleWidget(
                fitInside: SideTitleFitInsideData.fromTitleMeta(metaTitle),
                meta: metaTitle,
                child: Text(
                  formatValue != null ? formatValue!(value) : value.toString(),
                  style: theme.textTheme.bodySmall?.copyWith(color: colorScheme.onSurface),
                ),
              );
            },
            interval: LineChartDataProcessor.getChartValueInterval(minY, maxY),
          ),
        ),
      ),
      borderData: FlBorderData(
        show: showBorder,
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      minY: minY,
      maxY: maxY,
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: showCurve,
          color: colorScheme.primary,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: colorScheme.primary.withValues(alpha: 0.3)),
        ),
      ],
      lineTouchData: LineTouchData(
        handleBuiltInTouches: true,
        touchTooltipData: LineTouchTooltipData(
          fitInsideHorizontally: true,
          fitInsideVertically: true,
          getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
            return touchedBarSpots.map((barSpot) {
              final flSpot = barSpot.bar.spots[barSpot.spotIndex];
              if (flSpot.x.toInt() < data.sortedEntries.length) {
                final date = data.sortedEntries[flSpot.x.toInt()].key;
                return LineTooltipItem(
                  '${DateFormat('MMM dd, yyyy').format(date)}\n',
                  TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                  children: [
                    TextSpan(
                      text: formatValue != null ? formatValue!(flSpot.y) : flSpot.y.toString(),
                      style: TextStyle(
                        color: flSpot.y >= 0 ? colorScheme.primary : colorScheme.error,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                );
              }
              return null;
            }).toList();
          },
        ),
      ),
    );
  }
}
