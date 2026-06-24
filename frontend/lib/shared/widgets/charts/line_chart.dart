import 'dart:math' as math;

import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/widgets/charts/models/chart_range.dart';
import 'package:sprout/shared/widgets/charts/models/color.dart';
import 'package:sprout/shared/widgets/charts/models/legend_position.dart';
import 'package:sprout/shared/widgets/charts/models/line_chart_data.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';
import 'package:sprout/shared/widgets/charts/util/layout.dart';

// A record to hold the calculated min and max Y-axis values.
typedef _YAxisBounds = ({double minY, double maxY});

/// A line chart that displays data using the unified SproutChartSeries structure
class SproutLineChart extends StatelessWidget {
  final SproutChartHeader? header;
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
      : padding = padding ?? EdgeInsets.symmetric(horizontal: showXAxis ? 12 : 8);

  Color _resolveSpotColor(double y, SproutChartSeries s, ThemeData theme) {
    if (!s.config.usePositiveNegativeColors) {
      return s.config.color ?? theme.colorScheme.primary;
    }
    if (y == 0) return Colors.white;
    return y > 0 ? Colors.green : theme.colorScheme.error;
  }

  @override
  Widget build(BuildContext context) {
    if (series.isEmpty || series.every((s) => s.data.spots.isEmpty)) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);

    final Map<String, num> dummyData = {
      for (final s in series) s.label: s.data.spots.isNotEmpty ? s.data.spots.first.y : 0
    };

    final Map<String, Color> dummyMapping = {
      for (final s in series)
        if (s.config.color != null) s.label: s.config.color!
    };

    return SproutChartLayoutFrame(
      header: header,
      data: dummyData,
      legendPosition:
          showLegend && series.length > 1 ? SproutChartLegendPosition.bottom : SproutChartLegendPosition.none,
      colorResolver: SproutChartColorResolver(colorMapping: dummyMapping),
      chartArea: Padding(
        padding: padding,
        child: LineChart(
          _buildLineChartData(theme),
          duration: Duration.zero,
        ),
      ),
    );
  }

  /// Builds the top-level LineChartData model configurations by passing individual series styles.
  LineChartData _buildLineChartData(ThemeData theme) {
    final colorScheme = theme.colorScheme;
    final allSpots = series.expand((s) => s.data.spots).toList();
    final yAxisBounds = _calculateYAxisBounds(allSpots);
    final maxPoints = series.fold<int>(0, (maxLen, s) => math.max(maxLen, s.data.spots.length));

    final double yRange = yAxisBounds.maxY - yAxisBounds.minY;
    final double safeYInterval = yRange > 0.001 ? math.max(0.01, yRange / 4) : 1.0;
    final double safeXInterval = math.max(1.0, (maxPoints / 5).floorToDouble());

    final baseChartData = series.reduce((a, b) => a.data.spots.length > b.data.spots.length ? a : b).data;

    final List<LineChartBarData> lines = [];
    final bool isAllPositive = yAxisBounds.minY >= 0;
    final bool isAllNegative = yAxisBounds.maxY < 0;

    for (final s in series) {
      final bool isSplitColor = s.config.usePositiveNegativeColors;
      final double lineMaxY = s.data.spots.isEmpty ? 0 : s.data.spots.map((e) => e.y).reduce(math.max);
      final double lineMinY = s.data.spots.isEmpty ? 0 : s.data.spots.map((e) => e.y).reduce(math.min);
      final bool isSeriesFlatZero = s.data.spots.isNotEmpty && lineMaxY == 0 && lineMinY == 0;

      final Color baseColor = s.config.color ?? colorScheme.primary;
      final Color posColor = isSplitColor ? Colors.green : baseColor;
      final Color negColor = isSplitColor ? colorScheme.error : baseColor;
      final double areaOpacity = isSplitColor ? 0.20 : 0.25;
      final double bottomRange = 0.01;

      Color? lineColor;
      LinearGradient? lineGradient;

      if (isSplitColor) {
        if (isSeriesFlatZero) {
          lineColor = Colors.white;
          lineGradient = null;
        } else if (lineMinY >= 0) {
          if (lineMinY == 0) {
            final double totalRange = lineMaxY - lineMinY;
            final double zeroFraction = (lineMaxY / totalRange).clamp(0.0, 1.0);
            lineGradient = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.green, Colors.green, Colors.white],
              stops: [0.0, (zeroFraction - 0.02).clamp(0.0, 1.0), 1.0],
            );
          } else {
            lineColor = Colors.green;
            lineGradient = null;
          }
        } else if (lineMaxY <= 0) {
          if (lineMaxY == 0) {
            lineGradient = LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white, theme.colorScheme.error, theme.colorScheme.error],
              stops: [0.0, 0.05, 1.0],
            );
          } else {
            lineColor = theme.colorScheme.error;
            lineGradient = null;
          }
        } else {
          final double totalRange = lineMaxY - lineMinY;
          final double zeroFraction = (lineMaxY / totalRange).clamp(0.0, 1.0);

          lineGradient = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.green,
              Colors.green,
              Colors.white,
              Colors.white,
              theme.colorScheme.error,
              theme.colorScheme.error,
            ],
            stops: [
              0.0,
              (zeroFraction - 0.01).clamp(0.0, 1.0),
              (zeroFraction - 0.01).clamp(0.0, 1.0),
              (zeroFraction + 0.01).clamp(0.0, 1.0),
              (zeroFraction + 0.01).clamp(0.0, 1.0),
              1.0,
            ],
          );
        }
      } else {
        lineColor = baseColor;
      }

      BarAreaData? belowBar;
      BarAreaData? aboveBar;

      if (isAllPositive) {
        belowBar = BarAreaData(
          show: s.config.showArea,
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [posColor.withOpacity(areaOpacity), posColor.withOpacity(bottomRange)],
          ),
        );
      } else if (isAllNegative) {
        aboveBar = BarAreaData(
          show: s.config.showArea,
          gradient: LinearGradient(
            begin: Alignment.bottomCenter,
            end: Alignment.topCenter,
            colors: [negColor.withOpacity(bottomRange), negColor.withOpacity(areaOpacity)],
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
            colors: [posColor.withOpacity(areaOpacity), posColor.withOpacity(bottomRange)],
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
      maxX: maxPoints > 1 ? (maxPoints - 1).toDouble() : 1.0,
      titlesData: _buildTitlesData(theme, safeYInterval, safeXInterval, baseChartData),
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
        horizontalInterval: safeYInterval,
        verticalInterval: safeXInterval,
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

  FlTitlesData _buildTitlesData(
      ThemeData theme, double yInterval, double xInterval, SproutLineChartData baseChartData) {
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
            if (yInterval != 1.0 && (value == meta.max || value == meta.min)) {
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
                final Color activeHoverColor = _resolveSpotColor(spot.y, currentSeries, theme);
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
        maxContentWidth: 200,
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
              final Color lineColor = _resolveSpotColor(barSpot.y, currentSeries, theme);
              final dateHeader = !showDateInTooltip
                  ? ""
                  : barSpot == sortedSpots.first
                      ? '${DateFormat('MMM dd').format(date)}\n'
                      : '';

              final seriesLabel = '${currentSeries.label}: ';
              final rawValue = formatValue != null ? formatValue!(barSpot.y) : barSpot.y.toString();
              final formattedValue = rawValue.replaceAll('-', '\u2011').replaceAll(' ', '\u00A0');
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

    if (actualMinY == 0 && actualMaxY == 0) {
      return (minY: 0.0, maxY: 1.0);
    }

    if (actualMinY == actualMaxY) {
      final value = actualMinY;
      final double padding = math.max(1.0, (value.abs() * 0.2).ceilToDouble());
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
