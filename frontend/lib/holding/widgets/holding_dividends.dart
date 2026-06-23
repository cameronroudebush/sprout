import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/holding/holding_provider.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/charts/bar_chart.dart';
import 'package:sprout/shared/widgets/charts/models/legend_position.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';

/// Renders a bar chart displaying the aggregated dividend generation profile across ALL investment accounts.
class HoldingDividendsWidget extends ConsumerWidget {
  final List<Account> investmentAccounts;
  final int? topN;
  final bool isDesktop;

  const HoldingDividendsWidget({
    super.key,
    required this.investmentAccounts,
    required this.isDesktop,
    this.topN,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final formatter = ref.watch(currencyFormatterProvider);
    final chartDataAsync = ref.watch(
      aggregatedAccountDividendsProvider(
        investmentAccounts: investmentAccounts,
        topN: topN,
      ),
    );

    return chartDataAsync.whenDefault(
      emptyWidget: const Text("No dividend income found to calculate distribution metrics."),
      data: (finalChartData) {
        final double totalEstimatedDividendIncome = finalChartData.values.fold(0.0, (sum, val) => sum + val);
        final String formattedTotal = formatter.format(totalEstimatedDividendIncome);

        return SizedBox(
          height: 300,
          child: SproutBarChart(
            data: finalChartData,
            legendPosition: isDesktop ? SproutChartLegendPosition.none : SproutChartLegendPosition.bottom,
            showBarTitle: isDesktop,
            header: SproutChartHeader(
              title: "Dividend Income",
              subheader: "Estimated Annual Yield: $formattedTotal",
            ),
            formatValue: (val) => formatter.format(val, compact: true),
          ),
        );
      },
    );
  }
}
