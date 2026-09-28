import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';

class BudgetHistoryChart extends StatelessWidget {
  final BudgetHistoryResponseDto historyDto;
  final ValueChanged<DateTime> onMonthSelected;

  const BudgetHistoryChart({
    super.key,
    required this.historyDto,
    required this.onMonthSelected,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final history = historyDto.history;

    if (history.isEmpty) {
      return const SizedBox.shrink();
    }

    final currencyFormatter = NumberFormat.compactSimpleCurrency();
    final latestMonth = history.last;
    final maxValue = history
        .expand((item) =>
            [item.budgetedAmount.toDouble(), item.actualSpent.toDouble()])
        .reduce((first, second) => first > second ? first : second);
    final chartMaxY = maxValue > 0 ? maxValue * 1.2 : 1.0;

    return SproutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SproutChartHeader(
            title: 'Historical Performance',
            subheaderWidget: Column(
              spacing: 4,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Through ${DateFormat('MMMM yyyy').format(DateTime(latestMonth.year.toInt(), latestMonth.month.toInt()))}',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  spacing: 12,
                  children: [
                    _buildLegendItem(
                      theme,
                      'Current limit',
                      theme.colorScheme.primary.withValues(alpha: 0.3),
                    ),
                    _buildLegendItem(theme, 'Spent', theme.colorScheme.primary),
                    _buildLegendItem(
                      theme,
                      'Over budget',
                      theme.colorScheme.error,
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Padding(
            padding: EdgeInsetsGeometry.fromLTRB(8, 0, 8, 8),
            child: SizedBox(
              height: 180,
              child: BarChart(
                BarChartData(
                  alignment: BarChartAlignment.spaceAround,
                  maxY: chartMaxY,
                  barTouchData: BarTouchData(
                    touchCallback: (event, response) {
                      final spot = response?.spot;
                      if (event is FlTapUpEvent && spot != null) {
                        final index = spot.touchedBarGroupIndex;
                        if (index >= 0 && index < history.length) {
                          final selected = history[index];
                          onMonthSelected(DateTime(
                            selected.year.toInt(),
                            selected.month.toInt(),
                          ));
                        }
                      }
                    },
                    touchTooltipData: BarTouchTooltipData(
                      getTooltipItem: (group, groupIndex, rod, rodIndex) {
                        final item = history[groupIndex];
                        final monthLabel = DateFormat('MMM yyyy').format(
                            DateTime(item.year.toInt(), item.month.toInt()));
                        final label = rodIndex == 0 ? 'Current limit' : 'Spent';
                        final val = rodIndex == 0
                            ? item.budgetedAmount
                            : item.actualSpent;
                        return BarTooltipItem(
                          '$monthLabel\n$label: ${NumberFormat.simpleCurrency().format(val)}',
                          theme.textTheme.bodySmall
                                  ?.copyWith(color: Colors.white) ??
                              const TextStyle(),
                        );
                      },
                    ),
                  ),
                  titlesData: FlTitlesData(
                    show: true,
                    topTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    rightTitles: const AxisTitles(
                        sideTitles: SideTitles(showTitles: false)),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 40,
                        getTitlesWidget: (value, meta) => Text(
                          currencyFormatter.format(value),
                          style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        getTitlesWidget: (value, meta) {
                          final idx = value.toInt();
                          if (idx < 0 || idx >= history.length) {
                            return const SizedBox.shrink();
                          }
                          final item = history[idx];
                          final label = DateFormat('MMM').format(
                              DateTime(item.year.toInt(), item.month.toInt()));
                          return Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              label,
                              style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  gridData: const FlGridData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: List.generate(history.length, (index) {
                    final item = history[index];
                    final isOver = item.isOverBudget;
                    return BarChartGroupData(
                      x: index,
                      barRods: [
                        BarChartRodData(
                          toY: item.budgetedAmount.toDouble(),
                          color:
                              theme.colorScheme.primary.withValues(alpha: 0.3),
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        BarChartRodData(
                          toY: item.actualSpent.toDouble(),
                          color: isOver
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          width: 12,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLegendItem(ThemeData theme, String label, Color color) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: theme.textTheme.bodySmall
              ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
        ),
      ],
    );
  }
}
