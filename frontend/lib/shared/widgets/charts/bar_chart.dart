import 'package:collection/collection.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/charts/models/color.dart';
import 'package:sprout/shared/widgets/charts/models/legend_position.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';
import 'package:sprout/shared/widgets/charts/util/layout.dart';

/// A reusable bar chart for use across sprout
class SproutBarChart extends StatefulWidget {
  final Map<String, num>? data;
  final SproutChartHeader? header;
  final SproutChartLegendPosition legendPosition;

  /// If the individual bar should have it's title
  final bool showBarTitle;
  final Map<String, Color>? colorMapping;
  final String Function(num value)? formatValue;
  final void Function(String barLabel, double value)? onBarTap;

  const SproutBarChart({
    super.key,
    required this.data,
    this.header,
    this.legendPosition = SproutChartLegendPosition.right,
    this.showBarTitle = true,
    this.colorMapping,
    this.formatValue,
    this.onBarTap,
  });

  @override
  State<SproutBarChart> createState() => _SproutBarChartState();
}

class _SproutBarChartState extends State<SproutBarChart> {
  int touchedIndex = -1;
  late SproutChartColorResolver _colorResolver;

  @override
  void initState() {
    super.initState();
    _colorResolver = SproutChartColorResolver(colorMapping: widget.colorMapping);
  }

  @override
  void didUpdateWidget(covariant SproutBarChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.colorMapping != widget.colorMapping) {
      _colorResolver = SproutChartColorResolver(colorMapping: widget.colorMapping);
    }
  }

  @override
  Widget build(BuildContext context) {
    final chartData = widget.data ?? {};
    if (chartData.isEmpty) {
      return const Center(child: Text("No chart data available"));
    }

    final sortedEntries = chartData.entries.where((e) => e.value > 0).sortedBy((e) => -e.value).toList();

    return SproutChartLayoutFrame(
      header: widget.header,
      data: chartData,
      legendPosition: widget.legendPosition,
      colorResolver: _colorResolver,
      chartArea: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceEvenly,
          maxY: sortedEntries.isEmpty ? 10 : sortedEntries.map((e) => e.value.toDouble()).max * 1.15,
          barTouchData: BarTouchData(
            touchTooltipData: BarTouchTooltipData(
              getTooltipColor: (group) => Colors.blueGrey.shade800,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                final entry = sortedEntries[groupIndex];
                final displayValue = widget.formatValue?.call(entry.value) ?? entry.value.toString();
                return BarTooltipItem(
                  '${entry.key}\n$displayValue',
                  const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                );
              },
            ),
            touchCallback: (FlTouchEvent event, barTouchResponse) {
              setState(() {
                if (!event.isInterestedForInteractions || barTouchResponse?.toString() == null) {
                  touchedIndex = -1;
                  return;
                }
                touchedIndex = barTouchResponse?.spot?.touchedBarGroupIndex ?? -1;
              });

              if (event is FlTapUpEvent && barTouchResponse != null && barTouchResponse.spot != null) {
                if (touchedIndex >= 0 && touchedIndex < sortedEntries.length) {
                  final entry = sortedEntries[touchedIndex];
                  widget.onBarTap?.call(entry.key, entry.value.toDouble());
                }
              }
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 40,
                getTitlesWidget: (value, meta) => SideTitleWidget(
                  meta: meta,
                  child: Text(
                    widget.formatValue?.call(value) ?? value.toStringAsFixed(0),
                    style: const TextStyle(fontSize: 9, color: Colors.grey),
                  ),
                ),
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: widget.showBarTitle,
                getTitlesWidget: (value, meta) {
                  final int idx = value.toInt();
                  if (idx < 0 || idx >= sortedEntries.length) return const SizedBox();
                  return SideTitleWidget(
                    meta: meta,
                    child: Text(
                      sortedEntries[idx].key,
                      style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  );
                },
              ),
            ),
          ),
          gridData: const FlGridData(show: true, drawVerticalLine: false),
          borderData: FlBorderData(show: false),
          barGroups: sortedEntries.mapIndexed((index, entry) {
            final isTouched = index == touchedIndex;
            return BarChartGroupData(
              x: index,
              barRods: [
                BarChartRodData(
                  toY: entry.value.toDouble(),
                  color: _colorResolver.resolve(entry.key),
                  width: isTouched ? 22 : 16,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                  backDrawRodData: BackgroundBarChartRodData(
                    show: true,
                    toY: sortedEntries.map((e) => e.value.toDouble()).max * 1.15,
                    color: Colors.grey.withOpacity(0.08),
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}
