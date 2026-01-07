import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/core/utils/formatters.dart';

class ComboChart extends StatelessWidget {
  final String? title;
  final CashFlowSpending spendingData;
  final Color lineColor;

  const ComboChart(this.spendingData, {super.key, this.lineColor = Colors.red, this.title});

  @override
  Widget build(BuildContext context) {
    if (spendingData.data.isEmpty) return const SizedBox();

    final maxValue = spendingData.data.map((e) => e.totalSpending).reduce(max);
    double maxY = (maxValue.roundToDouble());
    double yInterval = (maxValue / 4).roundToDouble();
    maxY = maxY + yInterval - (yInterval / 1.5);

    // Line Chart Constraints
    final double minX = -0.5;
    final double maxX = spendingData.data.length - 0.5;

    return Padding(
      padding: EdgeInsetsGeometry.all(12),
      child: Column(
        spacing: 4,
        children: [
          if (title != null) Text(title!, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),

          Expanded(
            child: Stack(
              children: [
                // Line Chart Layer (Visual Only)
                IgnorePointer(
                  child: LineChart(
                    LineChartData(
                      minY: 0,
                      maxY: maxY,
                      minX: minX,
                      maxX: maxX,
                      lineTouchData: const LineTouchData(enabled: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _getLineSpots(),
                          isCurved: false,
                          color: lineColor,
                          barWidth: 3,
                          dotData: const FlDotData(show: true),
                        ),
                      ],
                      titlesData: _getSharedTitlesData(yInterval, isVisibleLayer: false),
                      gridData: const FlGridData(show: false),
                      borderData: FlBorderData(show: false),
                    ),
                  ),
                ),

                // Bar Chart Layer
                BarChart(
                  BarChartData(
                    alignment: BarChartAlignment.spaceAround,
                    maxY: maxY,
                    minY: 0,
                    barGroups: _getBarGroups(),
                    titlesData: _getSharedTitlesData(yInterval, isVisibleLayer: true),
                    gridData: FlGridData(show: true, drawVerticalLine: false, horizontalInterval: yInterval),
                    borderData: FlBorderData(show: false),
                    barTouchData: BarTouchData(
                      enabled: true,
                      touchTooltipData: BarTouchTooltipData(
                        getTooltipColor: (group) => Colors.blueGrey,
                        getTooltipItem: (group, groupIndex, rod, rodIndex) {
                          // Get the category data for this bar
                          final cat = spendingData.data[groupIndex].categories[rodIndex];
                          final categoryName = cat.name;
                          final barValue = rod.toY;

                          // Get the Total (Line) data for this month
                          final totalValue = spendingData.data[groupIndex].totalSpending;

                          return BarTooltipItem(
                            '$categoryName\n',
                            TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            children: <TextSpan>[
                              TextSpan(
                                text: '${getFormattedCurrency(barValue)}\n',
                                style: TextStyle(color: Colors.red[200], fontSize: 12, fontWeight: FontWeight.w500),
                              ),

                              // Footer: Show the Total from the line chart
                              TextSpan(
                                text: 'Total: ${getFormattedCurrency(totalValue)}',
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 10,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Legend
          _buildLegend(),
        ],
      ),
    );
  }

  List<BarChartGroupData> _getBarGroups() {
    return List.generate(spendingData.data.length, (index) {
      final point = spendingData.data[index];
      return BarChartGroupData(
        x: index,
        barsSpace: 4,
        barRods: List.generate(point.categories.length, (barIndex) {
          return BarChartRodData(
            toY: point.categories[barIndex].amount.toDouble(),
            color: point.categories[barIndex].color.toColor,
            width: 12,
            borderRadius: BorderRadius.zero,
          );
        }),
      );
    });
  }

  List<FlSpot> _getLineSpots() {
    return List.generate(spendingData.data.length, (index) {
      return FlSpot(index.toDouble(), spendingData.data[index].totalSpending.toDouble());
    });
  }

  /// Generates titles data.
  /// [isVisibleLayer] determines if we draw visible text or transparent text (spacer).
  FlTitlesData _getSharedTitlesData(double yInterval, {required bool isVisibleLayer}) {
    return FlTitlesData(
      bottomTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true, // Always true to reserve space!
          reservedSize: 32,
          getTitlesWidget: (value, meta) {
            final index = value.toInt();

            if (index < 0 || index >= spendingData.data.length) return const SizedBox();

            final textColor = isVisibleLayer ? null : Colors.transparent;

            return SideTitleWidget(
              meta: meta,
              child: Text(
                spendingData.data[index].monthLabel,
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: textColor),
              ),
            );
          },
        ),
      ),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          maxIncluded: false,
          reservedSize: 60,
          interval: yInterval,
          getTitlesWidget: (value, meta) {
            final textColor = isVisibleLayer ? null : Colors.transparent;
            return Text(getFormattedCurrency(value), style: TextStyle(fontSize: 10, color: textColor));
          },
        ),
      ),
      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
    );
  }

  Widget _buildLegend() {
    List<MonthlyCategoryData> categories = spendingData.data
        .map((e) => e.categories)
        .firstWhere((cats) => cats.isNotEmpty, orElse: () => []);
    return Wrap(
      spacing: 16,
      runSpacing: 10,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(lineColor, 'Total Spending', isLine: true),
        ...categories.map((cat) => _legendItem(cat.color.toColor, cat.name)),
      ],
    );
  }

  Widget _legendItem(Color color, String label, {bool isLine = false}) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      spacing: 6,
      children: [
        Container(
          width: isLine ? 16 : 12,
          height: isLine ? 3 : 12,
          decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
        ),
        Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
