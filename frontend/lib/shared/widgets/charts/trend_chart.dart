import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/charts/header.dart'; // Added line chart header path dependency

/// A generic, configurable trend chart that displays stacked bars and a trend line.
class SproutTrendChart extends StatefulWidget {
  const SproutTrendChart({
    super.key,
    required this.data,
    this.header,
    this.showLegend = true,
    this.topColor = Colors.green,
    this.bottomColor = Colors.red,
    this.trendLineColor,
    this.formatValue,
  });

  /// The structured data to display
  final List<CashFlowTrendStats>? data;

  /// The main header module configuration option
  final ChartHeader? header;

  /// Whether to render the legend below the chart
  final bool showLegend;

  /// Color for the top stacked bar
  final Color topColor;

  /// Color for the bottom stacked bar
  final Color bottomColor;

  /// Color for the line chart trend line. Defaults to theme onSurface.
  final Color? trendLineColor;

  /// Optional formatter for currency/number displays on axis and tooltips
  final String Function(num value)? formatValue;

  @override
  State<SproutTrendChart> createState() => _SproutTrendChartState();
}

class _SproutTrendChartState extends State<SproutTrendChart> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (widget.data == null || widget.data!.isEmpty) {
      return const Center(
        child: Text("No data available"),
      );
    }

    final maxY = _calculateMaxY();
    final minY = _calculateMinY();
    final lineThemeColor = widget.trendLineColor ?? theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.header != null) widget.header!,
          if (widget.header != null) const SizedBox(height: 12),
          Expanded(
            child: Stack(
              children: [
                _buildBarChart(theme, maxY, minY),
                _buildLineChart(lineThemeColor, maxY, minY),
              ],
            ),
          ),
          if (widget.showLegend) ...[
            const SizedBox(height: 16),
            _buildLegend(lineThemeColor),
          ],
        ],
      ),
    );
  }

  /// Calculates the dynamic upper bound for the Y-axis.
  double _calculateMaxY() {
    double maxVal = widget.data!.fold(0.0, (prev, e) => max(prev, max(e.topValue.toDouble(), e.trendValue.toDouble())));
    return maxVal == 0 ? 100 : maxVal * 1.2;
  }

  /// Calculates the dynamic lower bound for the Y-axis.
  double _calculateMinY() {
    double minVal =
        widget.data!.fold(0.0, (prev, e) => min(prev, min(-e.bottomValue.toDouble(), e.trendValue.toDouble())));
    return minVal == 0 ? -100 : minVal * 1.2;
  }

  /// Generates the shared titles configuration to ensure alignment between charts.
  FlTitlesData _getSharedTitlesData(ThemeData theme, {required bool isOverlay}) {
    return FlTitlesData(
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 50,
          getTitlesWidget: (value, meta) {
            if (isOverlay) return const SizedBox.shrink();
            if (value == meta.max || value == meta.min) {
              return const SizedBox.shrink();
            }
            final formatted = widget.formatValue?.call(value) ?? value.toStringAsFixed(0);
            return SideTitleWidget(
              meta: meta,
              child: Text(formatted, style: TextStyle(fontSize: 10, color: theme.hintColor)),
            );
          },
        ),
      ),
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 30,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();
            if (index < 0 || index >= widget.data!.length) return const SizedBox();
            if (isOverlay) return Text('', style: TextStyle(fontSize: 10, color: theme.hintColor));

            return SideTitleWidget(
              meta: meta,
              child: Text(widget.data![index].label, style: TextStyle(fontSize: 10, color: theme.hintColor)),
            );
          },
        ),
      ),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  /// Builds the background bar chart layer.
  Widget _buildBarChart(ThemeData theme, double maxY, double minY) {
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY,
        minY: minY,
        barTouchData: BarTouchData(enabled: false),
        gridData: FlGridData(
          show: true,
          drawVerticalLine: false,
          getDrawingHorizontalLine: (value) => FlLine(
            color: value == 0 ? theme.dividerColor : theme.dividerColor.withOpacity(0.1),
            strokeWidth: value == 0 ? 1.5 : 1,
          ),
        ),
        titlesData: _getSharedTitlesData(theme, isOverlay: false),
        borderData: FlBorderData(show: false),
        barGroups: widget.data!.asMap().entries.map((entry) {
          final i = entry.key;
          final d = entry.value;
          return BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: d.topValue.toDouble(),
                fromY: -d.bottomValue.toDouble(),
                width: 16,
                borderRadius: BorderRadius.circular(2),
                rodStackItems: [
                  BarChartRodStackItem(-d.bottomValue.toDouble(), 0, widget.bottomColor.withOpacity(0.8)),
                  BarChartRodStackItem(0, d.topValue.toDouble(), widget.topColor.withOpacity(0.8)),
                ],
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  /// Builds the overlaying line chart layer.
  Widget _buildLineChart(Color lineColor, double maxY, double minY) {
    return LineChart(
      LineChartData(
        maxY: maxY,
        minY: minY,
        minX: -0.5,
        maxX: widget.data!.length - 0.5,
        lineTouchData: _buildLineTouchData(),
        gridData: const FlGridData(show: false),
        titlesData: _getSharedTitlesData(Theme.of(context), isOverlay: true),
        borderData: FlBorderData(show: false),
        lineBarsData: [
          LineChartBarData(
            spots: widget.data!.asMap().entries.map((entry) {
              return FlSpot(entry.key.toDouble(), entry.value.trendValue.toDouble());
            }).toList(),
            isCurved: false,
            color: lineColor,
            barWidth: 2,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: 3,
                color: lineColor,
                strokeColor: Theme.of(context).colorScheme.surface,
                strokeWidth: 2,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Configures the interactive tooltip triggered by tapping bars.
  LineTouchData _buildLineTouchData() {
    final theme = Theme.of(context);
    return LineTouchData(
      enabled: true,
      touchTooltipData: LineTouchTooltipData(
        fitInsideVertically: true,
        fitInsideHorizontally: true,
        getTooltipColor: (spot) => theme.primaryColorDark,
        tooltipPadding: const EdgeInsets.all(8),
        getTooltipItems: (List<LineBarSpot> touchedSpots) {
          if (touchedSpots.isEmpty) return [];

          // We only have one line, so grab the first spot
          final spot = touchedSpots.first;
          final d = widget.data![spot.spotIndex];
          final format = widget.formatValue ?? (num val) => val.toString();

          return [
            LineTooltipItem(
              "${d.label}\n",
              const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              children: [
                TextSpan(
                  text: "${format(d.topValue)}\n",
                  style: TextStyle(color: widget.topColor),
                ),
                TextSpan(
                  text: "${format(d.bottomValue)}\n",
                  style: TextStyle(color: widget.bottomColor),
                ),
                TextSpan(
                  text: "Net: ${format(d.trendValue)}",
                  style: TextStyle(color: d.trendValue.toBalanceColor(theme), fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ];
        },
      ),
    );
  }

  /// Renders the visual legend map beneath the chart.
  Widget _buildLegend(Color lineColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _legendItem("Income", widget.topColor),
        const SizedBox(width: 16),
        _legendItem("Expense", widget.bottomColor),
        const SizedBox(width: 16),
        _legendItem("Net Cash Flow", lineColor, isLine: true),
      ],
    );
  }

  /// Helper to generate individual legend items.
  Widget _legendItem(String label, Color color, {bool isLine = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: isLine ? 2 : 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(isLine ? 0 : 2),
          ),
        ),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
