import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/charts/models/line_chart_data.dart';
import 'package:sprout/charts/processors/line_chart_processor.dart';

// A record to hold the calculated min and max Y-axis values.
typedef _YAxisBounds = ({double minY, double maxY});

/// A line chart that displays the given data in a line chart format
class SproutLineChart extends StatelessWidget {
  /// If the y axis number should be shown
  final bool showYAxis;

  /// If the x axis dates should be shown
  final bool showXAxis;

  /// If the grid should be shown as a background to this chart
  final bool showGrid;
  final bool drawVerticalGrid;

  /// If we want a border around the chart
  final bool showBorder;

  /// The chart range to render of
  final ChartRangeEnum chartRange;

  /// The data to render in this line chart
  final Map<DateTime, num>? data;

  /// An optional function to format the value displayed in the line chart
  final String Function(num value)? formatValue;

  /// An optional function to format the yAxis value. Takes precedence over [formatValue]
  final String Function(num value)? formatYAxis;
  final int? yAxisSize;

  final double height;

  /// If we should apply red for negative and green for positive colors instead of the usual scheme
  final bool applyPosNegColors;

  /// If we should show min/max values on the line chart
  final bool showMinMax;

  /// If we should show a dotted line at 0
  final bool showZeroLine;

  const SproutLineChart({
    super.key,
    required this.data,
    required this.chartRange,
    this.formatValue,
    this.showYAxis = false,
    this.showXAxis = false,
    this.showGrid = false,
    this.showBorder = false,
    this.height = 250,
    this.applyPosNegColors = true,
    this.showMinMax = true,
    this.showZeroLine = true,
    this.formatYAxis,
    this.yAxisSize,
    this.drawVerticalGrid = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (data == null || data!.isEmpty) {
      return const SizedBox.shrink();
    } else {
      final filteredHistoricalData = LineChartDataProcessor.filterHistoricalData(data, chartRange);
      final preparedData = LineChartDataProcessor.prepareChartData(filteredHistoricalData);
      return SizedBox(
        height: height,
        child: LineChart(_buildLineChartData(preparedData, chartRange, theme), duration: Duration.zero),
      );
    }
  }

  /// Builds the widget for our necessary line chart by coordinating helper functions.
  LineChartData _buildLineChartData(SproutLineChartData chartData, ChartRangeEnum selectedChartRange, ThemeData theme) {
    final spots = chartData.spots;
    final colorScheme = theme.colorScheme;
    final positiveColor = applyPosNegColors ? Colors.green : colorScheme.primary;
    final negativeColor = applyPosNegColors ? colorScheme.error : colorScheme.primary;
    final yAxisBounds = _calculateYAxisBounds(spots);
    final segments = _splitDataIntoSegments(spots);
    final titlesData = _buildTitlesData(theme, chartData, selectedChartRange, yAxisBounds);
    final touchData = _buildLineTouchData(theme, chartData, positiveColor, negativeColor);

    return LineChartData(
      minY: yAxisBounds.minY,
      maxY: yAxisBounds.maxY,
      minX: 0,
      maxX: (spots.length - 1).toDouble(),
      titlesData: titlesData,
      lineTouchData: touchData,
      gridData: FlGridData(
        show: showGrid,
        drawVerticalLine: drawVerticalGrid,
        getDrawingHorizontalLine: (_) => FlLine(color: colorScheme.outline.withAlpha(50), strokeWidth: 0.5),
        getDrawingVerticalLine: (_) => FlLine(color: colorScheme.outline.withAlpha(50), strokeWidth: 0.5),
      ),
      borderData: FlBorderData(
        show: showBorder,
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      lineBarsData: [
        // GREEN LINE (Positive)
        LineChartBarData(
          spots: segments.green,
          color: positiveColor, // Solid Green
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: positiveColor.withValues(alpha: .3),
            cutOffY: 0, // Stop filling at Y=0
            applyCutOffY: true,
          ),
        ),
        // RED LINE (Negative)
        LineChartBarData(
          spots: segments.red,
          color: negativeColor, // Solid Red
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          aboveBarData: BarAreaData(
            show: true,
            color: negativeColor.withValues(alpha: .3),
            cutOffY: 0,
            applyCutOffY: true,
          ),
        ),
      ],
      extraLinesData: !showZeroLine
          ? null
          : ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 0,
                  color: colorScheme.outline.withValues(alpha: .5),
                  strokeWidth: 1,
                  dashArray: [5, 5],
                ),
              ],
            ),
    );
  }

  /// Calculates the min and max Y values with appropriate padding.
  _YAxisBounds _calculateYAxisBounds(List<FlSpot> spots) {
    final double actualMinY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final double actualMaxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    if (actualMinY == actualMaxY) {
      final value = actualMinY;
      // If the value is 0, create a small default range. Otherwise, pad by 50%.
      final padding = (value == 0) ? 1.0 : value.abs() * 0.5;
      return (minY: value - padding, maxY: value + padding);
    }

    final double range = actualMaxY - actualMinY;
    final double padding = range * 0.1;

    double paddedMinY = actualMinY - padding;
    double paddedMaxY = actualMaxY + padding;

    // If the original min value was positive, ensure the padded min value does not cross the zero line and become negative.
    if (actualMinY >= 0) {
      paddedMinY = max(0, paddedMinY);
    }

    // If the original max value was negative, ensure the padded max value does not cross the zero line and become positive.
    if (actualMaxY <= 0) {
      paddedMaxY = min(0, paddedMaxY);
    }
    return (minY: paddedMinY, maxY: paddedMaxY);
  }

  /// Splits a list of spots into two lists: one for positive values (Green)
  /// and one for negative values (Red).
  /// Automatically calculates intersection points at Y=0 to ensure seamless connections.
  ({List<FlSpot> green, List<FlSpot> red}) _splitDataIntoSegments(List<FlSpot> spots) {
    if (spots.isEmpty) return (green: [], red: []);

    final List<FlSpot> greenSpots = [];
    final List<FlSpot> redSpots = [];

    for (int i = 0; i < spots.length - 1; i++) {
      final p1 = spots[i];
      final p2 = spots[i + 1];

      // Both points are Positive (or Zero)
      if (p1.y >= 0 && p2.y >= 0) {
        greenSpots.add(p1);
        greenSpots.add(p2);
        // Add null to break the other line so it doesn't connect disparate segments
        redSpots.add(FlSpot.nullSpot);
      }
      // Both points are Negative
      else if (p1.y < 0 && p2.y < 0) {
        redSpots.add(p1);
        redSpots.add(p2);
        greenSpots.add(FlSpot.nullSpot);
      }
      // Line crosses Zero (Positive to Negative)
      else if (p1.y >= 0 && p2.y < 0) {
        // Calculate the exact X where Y=0
        final t = p1.y / (p1.y - p2.y);
        final xZero = p1.x + (p2.x - p1.x) * t;
        final zeroPoint = FlSpot(xZero, 0);

        // Finish Green Segment
        greenSpots.add(p1);
        greenSpots.add(zeroPoint);
        greenSpots.add(FlSpot.nullSpot); // End Green line here

        // Start Red Segment
        redSpots.add(FlSpot.nullSpot); // Start Red line here
        redSpots.add(zeroPoint);
        redSpots.add(p2);
      }
      // Line crosses Zero (Negative to Positive)
      else if (p1.y < 0 && p2.y >= 0) {
        final t = p1.y / (p1.y - p2.y); // p1.y is negative, this math still works
        final xZero = p1.x + (p2.x - p1.x) * t;
        final zeroPoint = FlSpot(xZero, 0);

        // Finish Red Segment
        redSpots.add(p1);
        redSpots.add(zeroPoint);
        redSpots.add(FlSpot.nullSpot);

        // Start Green Segment
        greenSpots.add(FlSpot.nullSpot);
        greenSpots.add(zeroPoint);
        greenSpots.add(p2);
      }
    }

    return (green: greenSpots, red: redSpots);
  }

  /// Configures the titles (labels) for the X and Y axes.
  FlTitlesData _buildTitlesData(
    ThemeData theme,
    SproutLineChartData chartData,
    ChartRangeEnum selectedChartRange,
    _YAxisBounds yAxisBounds,
  ) {
    final spots = chartData.spots;

    int numDigits = max(
      yAxisBounds.maxY.abs().toInt().toString().length,
      yAxisBounds.minY.abs().toInt().toString().length,
    );
    final yReservedSize = yAxisSize ?? 60 + (numDigits - 3).clamp(0, 4) * 10;

    // Calculate the interval that fl_chart will use for the Y-axis labels.
    final yAppliedInterval = LineChartDataProcessor.getChartValueInterval(yAxisBounds.minY, yAxisBounds.maxY);
    // Define a "collision zone" for Y-axis. Any label within 40% of the interval from the min/max will be hidden.
    final yCollisionThreshold = yAppliedInterval * 0.4;
    // Calculate the interval for the X-axis labels.
    final xAppliedInterval = ChartRangeUtility.getChartInterval(selectedChartRange, spots.length);

    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          minIncluded: showMinMax,
          maxIncluded: showMinMax,
          showTitles: showXAxis,
          reservedSize: 30,
          interval: xAppliedInterval,
          getTitlesWidget: (value, meta) {
            final int index = value.toInt();
            final int totalEntries = chartData.sortedEntries.length;
            final int showEveryNth = (totalEntries / 4).ceil();
            bool isStart = index == 0;
            bool isEnd = index == totalEntries - 1;
            bool isIntermediate = index % showEveryNth == 0;
            bool isTooCloseToEdge = index < (totalEntries * 0.15) || index > (totalEntries * 0.85);

            if (isStart || isEnd || (isIntermediate && !isTooCloseToEdge)) {
              final date = chartData.sortedEntries[index].key;
              String format = ChartRangeUtility.getDateFormat(selectedChartRange);

              return SideTitleWidget(
                meta: meta,
                space: 8,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta, enabled: true, distanceFromEdge: 0),
                child: Text(DateFormat(format).format(date), style: theme.textTheme.bodySmall),
              );
            }

            // Return an empty box for everything else
            return const SizedBox.shrink();
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          minIncluded: showMinMax,
          maxIncluded: showMinMax,
          showTitles: showYAxis,
          reservedSize: yReservedSize.toDouble(),
          interval: yAppliedInterval,
          getTitlesWidget: (value, meta) {
            // If we're not showing min/max, no collision is possible.
            if (showMinMax) {
              // If the current label is the min or max, always show it.
              if (value != meta.min && value != meta.max) {
                // If it's a regular interval label, check if it's too close to the edges.
                if ((value - meta.min).abs() < yCollisionThreshold || (meta.max - value).abs() < yCollisionThreshold) {
                  // If it's in the "collision zone", draw nothing to prevent overlap.
                  return const Text('');
                }
              }
            }

            // If we've gotten this far, it's safe to draw the label.
            return SideTitleWidget(
              meta: meta,
              child: Text(
                formatYAxis != null
                    ? formatYAxis!(value)
                    : formatValue != null
                    ? formatValue!(value)
                    : value.toStringAsFixed(2),
                style: theme.textTheme.bodySmall,
              ),
            );
          },
        ),
      ),
    );
  }

  /// Configures the data displayed when the user touches the chart.
  LineTouchData _buildLineTouchData(
    ThemeData theme,
    SproutLineChartData chartData,
    Color positiveColor,
    Color negativeColor,
  ) {
    final colorScheme = theme.colorScheme;

    return LineTouchData(
      handleBuiltInTouches: true,
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          return touchedBarSpots.asMap().entries.map((entry) {
            final index = entry.key;
            final barSpot = entry.value;

            // Only show the tooltip for the very first touched spot
            if (index != 0) return null;

            final flSpot = barSpot.bar.spots[barSpot.spotIndex];
            if (flSpot.x.toInt() < chartData.sortedEntries.length) {
              final date = chartData.sortedEntries[flSpot.x.toInt()].key;

              return LineTooltipItem(
                '${DateFormat('MMM dd, yyyy').format(date)}\n',
                TextStyle(color: colorScheme.onSurfaceVariant, fontWeight: FontWeight.bold),
                children: [
                  TextSpan(
                    text: formatValue != null ? formatValue!(flSpot.y) : flSpot.y.toString(),
                    style: TextStyle(
                      color: flSpot.y >= 0 ? positiveColor : negativeColor,
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
    );
  }
}
