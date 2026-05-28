import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/charts/header.dart';
import 'package:sprout/shared/widgets/charts/trend_chart.dart';

/// Renders a trend chart for cash flow utilizing the generic SproutTrendChart.
class CashFlowTrendChart extends ConsumerWidget {
  /// Whether the legend is visible
  final bool showLegend;

  /// How many bars to show data for from the backend
  final int barCount;

  const CashFlowTrendChart({
    super.key,
    required this.barCount,
    this.showLegend = true,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final trendAsync = ref.watch(cashFlowTrendProvider(barCount));
    final formatter = ref.watch(currencyFormatterProvider);

    return trendAsync.when(
      loading: () => const Center(
        child: CircularProgressIndicator(),
      ),
      error: (err, _) => Center(
        child: Text("Error loading chart: $err"),
      ),
      data: (statsList) {
        if (statsList == null || statsList.isEmpty) {
          return const Center(
            child: Text("No data available"),
          );
        }

        return SproutTrendChart(
          data: statsList,
          header: ChartHeader(
            title: "Cash Flow Trend",
          ),
          showLegend: showLegend,
          topColor: Colors.green,
          bottomColor: theme.colorScheme.error,
          trendLineColor: theme.colorScheme.onSurface,
          formatValue: (value) => formatter.format(value, compact: true),
        );
      },
    );
  }
}
