import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/charts/header.dart';
import 'package:sprout/shared/widgets/charts/pie_chart.dart';

/// Renders a pie chart displaying the aggregated asset allocation across ALL investment accounts.
class HoldingPieChart extends ConsumerWidget {
  final List<Account> investmentAccounts;
  final int? topN;

  const HoldingPieChart({
    super.key,
    required this.investmentAccounts,
    this.topN,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(currencyFormatterProvider);
    final Map<String, double> aggregatedHoldings = {};

    for (var account in investmentAccounts) {
      final holdingsState = ref.watch(accountHoldingsProvider(account.id));
      final list = holdingsState.value ?? [];

      for (var holding in list) {
        final symbol = (holding.symbol).toUpperCase().trim();
        if (symbol.isNotEmpty && holding.marketValue > 0) {
          aggregatedHoldings[symbol] = (aggregatedHoldings[symbol] ?? 0.0) + holding.marketValue;
        }
      }
    }

    if (aggregatedHoldings.isEmpty) {
      return Center(child: Text("No valuation data found to calculate portfolio weights."));
    }

    final sortedEntries = aggregatedHoldings.entries.toList()..sort((a, b) => b.value.compareTo(a.value));
    final Map<String, num> finalChartData = {};
    if (topN != null && sortedEntries.length > topN!) {
      final topPositions = sortedEntries.take(topN!);
      final overflowPositions = sortedEntries.skip(topN!);
      final double overflowSum = overflowPositions.fold(0.0, (sum, item) => sum + item.value);
      for (var pos in topPositions) {
        finalChartData[pos.key] = pos.value;
      }
      if (overflowSum > 0) {
        final label = "+${overflowPositions.length} other positions";
        finalChartData[label] = overflowSum;
      }
    } else {
      for (var pos in sortedEntries) {
        finalChartData[pos.key] = pos.value;
      }
    }

    return SproutPieChart(
        data: finalChartData,
        legendPosition: PieLegendPosition.bottom,
        showPieTitle: false,
        header: const ChartHeader(title: "Holding Allocation"),
        formatValue: formatter.format);
  }
}
