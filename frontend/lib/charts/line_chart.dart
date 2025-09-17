import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/charts/models/line_chart_data.dart';
import 'package:sprout/charts/processors/line_chart_processor.dart';

// A record to hold the calculated min and max Y-axis values.
typedef _YAxisBounds = ({double minY, double maxY});

// A record to hold the calculated gradients for the line and the area below it.
typedef _ChartGradients = ({LinearGradient line, LinearGradient belowBar});

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
  final ChartRange chartRange;

  /// The data to render in this line chart
  final Map<DateTime, double>? data;

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
  LineChartData _buildLineChartData(SproutLineChartData chartData, ChartRange selectedChartRange, ThemeData theme) {
    final spots = chartData.spots;
    final colorScheme = theme.colorScheme;

    final positiveColor = applyPosNegColors ? Colors.green : colorScheme.primary;
    final negativeColor = applyPosNegColors ? colorScheme.error : colorScheme.primary;

    // 1. Calculate Y-axis boundaries
    final yAxisBounds = _calculateYAxisBounds(spots);

    // 2. Create color gradients based on the data
    final gradients = _buildLineGradients(theme, yAxisBounds.minY, yAxisBounds.maxY, positiveColor, negativeColor);

    // 3. Configure the titles (axis labels)
    final titlesData = _buildTitlesData(theme, chartData, selectedChartRange, yAxisBounds);

    // 4. Configure the interactive tooltip
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
        getDrawingHorizontalLine: (value) => FlLine(color: colorScheme.outline.withAlpha(50), strokeWidth: 0.5),
        getDrawingVerticalLine: (value) => FlLine(color: colorScheme.outline.withAlpha(50), strokeWidth: 0.5),
      ),
      borderData: FlBorderData(
        show: showBorder,
        border: Border.all(color: colorScheme.outline, width: 1),
      ),
      lineBarsData: [
        LineChartBarData(
          spots: spots,
          isCurved: ChartRangeUtility.shouldBeCurved(selectedChartRange),
          gradient: gradients.line,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(show: true, gradient: gradients.belowBar),
        ),
      ],
      extraLinesData: !showZeroLine
          ? null
          : ExtraLinesData(
              horizontalLines: [
                HorizontalLine(y: 0, color: colorScheme.outline.withOpacity(0.5), strokeWidth: 1, dashArray: [5, 5]),
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

    // If the original max value was negative, ensure the padded max value
    // does not cross the zero line and become positive.
    if (actualMaxY <= 0) {
      paddedMaxY = min(0, paddedMaxY);
    }
    return (minY: paddedMinY, maxY: paddedMaxY);
  }

  /// Creates the LinearGradients for the line and the area below it.
  _ChartGradients _buildLineGradients(
    ThemeData theme,
    double minY,
    double maxY,
    Color positiveColor,
    Color negativeColor,
  ) {
    List<Color> lineGradientColors;
    List<double>? lineGradientStops;

    if (minY >= 0) {
      lineGradientColors = [positiveColor, positiveColor];
      lineGradientStops = null;
    } else if (maxY <= 0) {
      lineGradientColors = [negativeColor, negativeColor];
      lineGradientStops = null;
    } else {
      final zeroStop = (-minY / (maxY - minY)).clamp(0.0, 1.0);
      lineGradientColors = [negativeColor, negativeColor, positiveColor, positiveColor];
      lineGradientStops = [0.0, zeroStop, zeroStop, 1.0];
    }

    final lineGradient = LinearGradient(
      colors: lineGradientColors,
      stops: lineGradientStops,
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    final belowBarGradient = LinearGradient(
      colors: lineGradientColors.map((color) => color.withOpacity(0.3)).toList(),
      stops: lineGradientStops,
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );

    return (line: lineGradient, belowBar: belowBarGradient);
  }

  /// Configures the titles (labels) for the X and Y axes.
  FlTitlesData _buildTitlesData(
    ThemeData theme,
    SproutLineChartData chartData,
    ChartRange selectedChartRange,
    _YAxisBounds yAxisBounds,
  ) {
    final spots = chartData.spots;

    int numDigits = max(
      yAxisBounds.maxY.abs().toInt().toString().length,
      yAxisBounds.minY.abs().toInt().toString().length,
    );
    final yReservedSize = yAxisSize ?? 60 + (numDigits - 3).clamp(0, 4) * 10;

    // Calculate the interval that fl_chart will use for the labels.
    final appliedInterval = LineChartDataProcessor.getChartValueInterval(yAxisBounds.minY, yAxisBounds.maxY);
    // Define a "collision zone" as a fraction of the interval. Any label within 40% of the interval from the min/max will be hidden.
    final collisionThreshold = appliedInterval * 0.4;

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
          interval: ChartRangeUtility.getChartInterval(selectedChartRange, spots.length),
          getTitlesWidget: (value, meta) {
            if (value.toInt() < chartData.sortedEntries.length) {
              final date = chartData.sortedEntries[value.toInt()].key;
              String format = ChartRangeUtility.getDateFormat(selectedChartRange);
              return SideTitleWidget(
                meta: meta,
                fitInside: SideTitleFitInsideData.fromTitleMeta(meta, enabled: true, distanceFromEdge: 0),
                child: Text(DateFormat(format).format(date), style: theme.textTheme.bodySmall),
              );
            }
            return const Text('');
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          minIncluded: showMinMax,
          maxIncluded: showMinMax,
          showTitles: showYAxis,
          reservedSize: yReservedSize.toDouble(),
          interval: appliedInterval,
          getTitlesWidget: (value, meta) {
            // If we're not showing min/max, no collision is possible.
            if (!showMinMax) {
              // Standard label drawing
            } else {
              // If the current label is the min or max, always show it.
              if (value == meta.min || value == meta.max) {
                // Standard label drawing
              }
              // If it's a regular interval label, check if it's too close to the edges.
              else if ((value - meta.min).abs() < collisionThreshold || (meta.max - value).abs() < collisionThreshold) {
                // If it's in the "collision zone", draw nothing to prevent overlap.
                return const Text('');
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
          return touchedBarSpots.map((barSpot) {
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
