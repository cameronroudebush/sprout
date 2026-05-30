import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/widgets/charts/header.dart';
import 'package:sprout/shared/widgets/charts/models/chart_range.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';

// A record to hold the calculated min and max Y-axis values.
typedef _YAxisBounds = ({double minY, double maxY});

/// A line chart that displays data using the unified SproutChartSeries structure
class SproutLineChart extends StatelessWidget {
  final ChartHeader? header;
  final List<SproutChartSeries> series;
  final ChartRangeEnum chartRange;

  final bool showYAxis;
  final bool showXAxis;
  final bool showGrid;
  final bool drawVerticalGrid;
  final bool showLegend;
  final bool showZeroLine;
  final bool showDateInTooltip;
  final bool showBorder;
  final EdgeInsets padding;

  final String Function(num value)? formatValue;
  final String Function(num value)? formatYAxis;

  SproutLineChart(
      {super.key,
      required this.series,
      required this.chartRange,
      this.header,
      this.formatValue,
      this.formatYAxis,
      this.showYAxis = false,
      this.showXAxis = false,
      this.showGrid = false,
      this.drawVerticalGrid = true,
      this.showLegend = true,
      this.showZeroLine = true,
      this.showDateInTooltip = true,
      this.showBorder = true,
      EdgeInsets? padding})
      : padding = padding ?? EdgeInsets.symmetric(horizontal: showXAxis ? 24 : 8);

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty || series.every((s) => s.data.spots.isEmpty)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (header != null) header!,
        const SizedBox(height: 16),
        Expanded(
          child: Padding(
            padding: padding,
            child: LineChart(
              _buildLineChartData(theme),
              duration: Duration.zero,
            ),
          ),
        ),
        if (showLegend && series.length > 1) ...[
          _buildLegend(theme),
          const SizedBox(height: 8),
        ],
      ],
    );
  }

  Widget _buildLegend(ThemeData theme) {
    return Wrap(
      alignment: WrapAlignment.center,
      spacing: 16,
      runSpacing: 8,
      children: series.map((s) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: s.config.color ?? theme.colorScheme.primary,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(s.label, style: theme.textTheme.bodySmall),
          ],
        );
      }).toList(),
    );
  }

  /// Builds the top-level LineChartData model configurations by passing individual series styles.
  LineChartData _buildLineChartData(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final allSpots = series.expand((s) => s.data.spots).toList();
    final yAxisBounds = _calculateYAxisBounds(allSpots);
    final maxPoints = series.fold<int>(0, (maxLen, s) => math.max(maxLen, s.data.spots.length));
    final List<LineChartBarData> lines = [];

    final bool isAllPositive = yAxisBounds.minY >= 0;
    final bool isAllNegative = yAxisBounds.maxY <= 0;
    final bool crossesZero = !isAllPositive && !isAllNegative;

    for (final s in series) {
      final bool isSplitColor = s.config.usePositiveNegativeColors;

      final Color baseColor = s.config.color ?? colorScheme.primary;
      final Color posColor = isSplitColor ? Colors.green : baseColor;
      final Color negColor = isSplitColor ? colorScheme.error : baseColor;
      final double areaOpacity = isSplitColor ? 0.20 : 0.25;

      Color? lineColor;
      LinearGradient? lineGradient;

      if (isSplitColor && crossesZero) {
        final double totalRange = yAxisBounds.maxY - yAxisBounds.minY;
        final double zeroFraction = (yAxisBounds.maxY / totalRange).clamp(0.0, 1.0);

        lineGradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [posColor, posColor, negColor, negColor],
          stops: [0.0, zeroFraction, zeroFraction, 1.0],
        );
      } else {
        lineColor = (isSplitColor && isAllNegative) ? negColor : posColor;
      }

      BarAreaData? belowBar;
      BarAreaData? aboveBar;

      if (isAllPositive) {
        belowBar = BarAreaData(
          show: s.config.showArea,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [posColor.withOpacity(areaOpacity), posColor.withOpacity(0.00)],
          ),
        );
      } else if (isAllNegative) {
        aboveBar = BarAreaData(
          show: s.config.showArea,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [negColor.withOpacity(0), negColor.withOpacity(areaOpacity)],
          ),
        );
      } else {
        belowBar = BarAreaData(
          show: s.config.showArea,
          cutOffY: 0,
          applyCutOffY: true,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [posColor.withOpacity(areaOpacity), posColor.withOpacity(0.00)],
          ),
        );

        aboveBar = BarAreaData(
          show: s.config.showArea,
          cutOffY: 0,
          applyCutOffY: true,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [negColor.withOpacity(areaOpacity), negColor.withOpacity(0.00)],
          ),
        );
      }

      lines.add(LineChartBarData(
        spots: s.data.spots,
        isCurved: true,
        preventCurveOverShooting: true,
        barWidth: s.config.width,
        dashArray: s.config.isDashed ? [6, 4] : null,
        dotData: const FlDotData(show: false),
        color: lineColor,
        gradient: lineGradient,
        belowBarData: belowBar,
        aboveBarData: aboveBar,
      ));
    }

    return LineChartData(
      lineTouchData: _buildTouchData(theme),
      minY: yAxisBounds.minY,
      maxY: yAxisBounds.maxY,
      minX: 0,
      maxX: maxPoints > 0 ? (maxPoints - 1).toDouble() : 0,
      titlesData: _buildTitlesData(theme, yAxisBounds),
      borderData: FlBorderData(
        show: showBorder,
        border: Border.all(
          color: theme.colorScheme.outline.withOpacity(0.15),
          width: 1,
        ),
      ),
      gridData: FlGridData(
        show: showGrid,
        drawVerticalLine: drawVerticalGrid,
        getDrawingHorizontalLine: (_) => FlLine(
          color: colorScheme.outline.withOpacity(0.15),
          strokeWidth: 1,
          dashArray: [4, 4],
        ),
      ),
      lineBarsData: lines,
      extraLinesData: !showZeroLine
          ? null
          : ExtraLinesData(
              horizontalLines: [
                HorizontalLine(
                  y: 0,
                  color: colorScheme.secondary.withOpacity(0.6),
                  strokeWidth: 1.5,
                  dashArray: [5, 5],
                ),
              ],
            ),
    );
  }

  FlTitlesData _buildTitlesData(ThemeData theme, _YAxisBounds yAxisBounds) {
    // Read labels off the first series safely as a structural baseline
    final baseChartData = series.first.data;
    final spots = baseChartData.spots;
    final double yRange = yAxisBounds.maxY - yAxisBounds.minY;
    final double yInterval = yRange > 0 ? yRange / 4 : 1.0;
    final double xInterval = math.max(1.0, (spots.length / 5).floorToDouble());

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
            if (index < 0 || index >= baseChartData.sortedEntries.length) {
              return const SizedBox.shrink();
            }

            final date = baseChartData.sortedEntries[index].key;
            String format = ChartRangeUtility.getDateFormat(chartRange);

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

  LineTouchData _buildTouchData(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    return LineTouchData(
      handleBuiltInTouches: true,
      getTouchedSpotIndicator: (LineChartBarData barData, List<int> spotIndices) {
        final int seriesIndex = series.indexWhere((s) => s.data.spots == barData.spots);
        final currentSeries = seriesIndex != -1 ? series[seriesIndex] : series.first;

        final bool shouldShowBubble = currentSeries.config.showInTooltip;

        return spotIndices.map((index) {
          return TouchedSpotIndicatorData(
            FlLine(
              color: shouldShowBubble ? colorScheme.outline : Colors.transparent,
              strokeWidth: shouldShowBubble ? 1 : 0,
            ),
            FlDotData(
              show: shouldShowBubble,
              getDotPainter: (spot, percent, barData, index) {
                final Color activeHoverColor;
                if (currentSeries.config.usePositiveNegativeColors) {
                  final double baselineValue = 0.0;
                  activeHoverColor = spot.y >= baselineValue ? Colors.green : theme.colorScheme.error;
                } else {
                  activeHoverColor = barData.color ?? theme.colorScheme.primary;
                }
                return FlDotCirclePainter(
                  radius: 5,
                  color: activeHoverColor,
                  strokeWidth: 2,
                  strokeColor: theme.scaffoldBackgroundColor,
                );
              },
            ),
          );
        }).toList();
      },
      touchTooltipData: LineTouchTooltipData(
        fitInsideHorizontally: true,
        fitInsideVertically: true,
        getTooltipColor: (LineBarSpot touchedSpot) {
          return theme.primaryColorDark;
        },
        getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
          // Sort spots by barIndex to keep the tooltip layout rendering cleanly
          final sortedSpots = List<LineBarSpot>.from(touchedBarSpots)..sort((a, b) => a.barIndex.compareTo(b.barIndex));

          // Track displayed series to avoid duplicate entries when crossing the zero boundary
          final Set<String> seenLabels = {};

          return sortedSpots.map((barSpot) {
            final currentSeries = series.firstWhereOrNull((s) {
                  if (s.config.usePositiveNegativeColors) {
                    // If it's a split line, the bar color will match either Green or the Error theme color
                    return barSpot.bar.color == Colors.green || barSpot.bar.color == theme.colorScheme.error;
                  }
                  // For standard lines, match the explicit configuration color
                  return (s.config.color ?? theme.colorScheme.primary) == barSpot.bar.color;
                }) ??
                (barSpot.barIndex < series.length ? series[barSpot.barIndex] : series.first);

            if (currentSeries.config.showInTooltip == false || seenLabels.contains(currentSeries.label)) {
              return const LineTooltipItem(
                '',
                TextStyle(fontSize: 0, color: Colors.transparent),
              );
            }
            seenLabels.add(currentSeries.label);

            final chartData = currentSeries.data;

            if (barSpot.x.toInt() < chartData.sortedEntries.length) {
              final date = chartData.sortedEntries[barSpot.x.toInt()].key;
              final Color lineColor;
              if (currentSeries.config.usePositiveNegativeColors) {
                lineColor = barSpot.y >= 0 ? Colors.green : theme.colorScheme.error;
              } else {
                lineColor = currentSeries.config.color ?? theme.colorScheme.primary;
              }
              final dateHeader = !showDateInTooltip
                  ? ""
                  : barSpot == sortedSpots.first
                      ? '${DateFormat('MMM dd').format(date)}\n'
                      : '';

              final seriesLabel = '${currentSeries.label}: ';
              final formattedValue = formatValue != null ? formatValue!(barSpot.y) : barSpot.y.toString();

              final tooltipTextStyle = theme.textTheme.labelLarge?.copyWith(
                color: Colors.white,
              );

              return LineTooltipItem(
                dateHeader,
                tooltipTextStyle!,
                children: [
                  TextSpan(
                    text: seriesLabel,
                    style: tooltipTextStyle,
                  ),
                  TextSpan(
                    text: formattedValue,
                    style: tooltipTextStyle.copyWith(
                      color: lineColor,
                      fontWeight: FontWeight.bold,
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

  _YAxisBounds _calculateYAxisBounds(List<FlSpot> spots) {
    if (spots.isEmpty) return (minY: 0.0, maxY: 1.0);

    final double actualMinY = spots.map((spot) => spot.y).reduce((a, b) => a < b ? a : b);
    final double actualMaxY = spots.map((spot) => spot.y).reduce((a, b) => a > b ? a : b);

    if (actualMinY == actualMaxY) {
      final value = actualMinY;
      final padding = (value == 0) ? 1.0 : value.abs() * 0.5;
      return (minY: value - padding, maxY: value + padding);
    }

    final double range = actualMaxY - actualMinY;
    final double padding = range * 0.1;

    double paddedMinY = actualMinY - padding;
    double paddedMaxY = actualMaxY + padding;

    if (actualMinY >= 0) paddedMinY = math.max(0, paddedMinY);
    if (actualMaxY <= 0) paddedMaxY = math.min(0, paddedMaxY);
    return (minY: paddedMinY, maxY: paddedMaxY);
  }
}
