import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/models/chart_range.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/processors/line_chart_processor.dart';

// A record to hold the calculated min and max Y-axis values.
typedef _YAxisBounds = ({double minY, double maxY});

/// A line chart that displays the given data in a line chart format
class SproutLineChart extends StatelessWidget {
  /// The main title of the chart
  final String? header;

  /// Optional text displayed below the title
  final String? subheader;

  /// If we should wrap the chart and titles in a SproutCard
  final bool showCard;

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
    this.header,
    this.subheader,
    this.showCard = false,
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
    this.drawVerticalGrid = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (data == null || data!.isEmpty) {
      return const SizedBox.shrink();
    }

    final filteredHistoricalData = LineChartDataProcessor.filterHistoricalData(data, chartRange);
    final preparedData = LineChartDataProcessor.prepareChartData(filteredHistoricalData);

    Widget chartContent = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null || subheader != null) _buildHeader(theme),
        if (header != null || subheader != null) const SizedBox(height: 24),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: LineChart(_buildLineChartData(preparedData, chartRange, theme), duration: Duration.zero),
          ),
        ),
      ],
    );

    if (showCard) {
      return SproutCard(
        applySizedBox: false,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SizedBox(height: height, child: chartContent),
        ),
      );
    }

    return SizedBox(height: height, child: chartContent);
  }

  /// Builds the header with Title and Subheader matching the other visual components
  Widget _buildHeader(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (header != null)
          Text(
            header!,
            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        if (subheader != null) ...[
          const SizedBox(height: 4),
          Text(
            subheader!,
            style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
          ),
        ],
      ],
    );
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
        drawHorizontalLine: true,
        getDrawingHorizontalLine: (_) => FlLine(
          color: colorScheme.outline.withOpacity(0.15),
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
        getDrawingVerticalLine: (_) => FlLine(
          color: colorScheme.outline.withOpacity(0.15),
          strokeWidth: 1,
        ),
      ),
      borderData: FlBorderData(
        show: showBorder,
        border: Border.all(color: colorScheme.outline.withOpacity(0.3), width: 1),
      ),
      lineBarsData: [
        // GREEN LINE (Positive)
        LineChartBarData(
          spots: segments.green,
          color: positiveColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          belowBarData: BarAreaData(
            show: true,
            color: positiveColor.withOpacity(0.2),
            cutOffY: 0,
            applyCutOffY: true,
          ),
        ),
        // RED LINE (Negative)
        LineChartBarData(
          spots: segments.red,
          color: negativeColor,
          barWidth: 3,
          isStrokeCapRound: true,
          dotData: const FlDotData(show: false),
          aboveBarData: BarAreaData(
            show: true,
            color: negativeColor.withOpacity(0.2),
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
                  color: colorScheme.outline.withOpacity(0.6),
                  strokeWidth: 1.5,
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

    final double yRange = yAxisBounds.maxY - yAxisBounds.minY;
    final double yInterval = yRange > 0 ? yRange / 4 : 1.0;

    final double xInterval = max(1.0, (spots.length / 5).floorToDouble());

    return FlTitlesData(
      show: true,
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showXAxis,
          reservedSize: 32,
          interval: xInterval,
          getTitlesWidget: (value, meta) {
            final int index = value.toInt();
            if (index < 0 || index >= chartData.sortedEntries.length) {
              return const SizedBox.shrink();
            }

            final date = chartData.sortedEntries[index].key;
            String format = ChartRangeUtility.getDateFormat(selectedChartRange);

            return SideTitleWidget(
              meta: meta,
              space: 8,
              child: Text(
                DateFormat(format).format(date),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 10),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: showYAxis,
          reservedSize: 40,
          interval: yInterval,
          getTitlesWidget: (value, meta) {
            if (value == meta.max || value == meta.min) {
              return const SizedBox.shrink();
            }

            return SideTitleWidget(
              meta: meta,
              space: 8,
              child: Text(
                formatYAxis != null
                    ? formatYAxis!(value)
                    : formatValue != null
                        ? formatValue!(value)
                        : value.toStringAsFixed(0),
                style: theme.textTheme.bodySmall?.copyWith(color: theme.hintColor, fontSize: 10),
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.visible,
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
                theme.textTheme.labelLarge!,
                children: [
                  TextSpan(
                    text: formatValue != null ? formatValue!(flSpot.y) : flSpot.y.toString(),
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: flSpot.y >= 0 ? positiveColor : negativeColor,
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
