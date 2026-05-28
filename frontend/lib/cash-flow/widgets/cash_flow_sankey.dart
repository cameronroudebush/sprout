import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/sankey.dart';

/// This renders an interactive Sankey diagram showing cash flow distributions.
class CashFlowSankeyChart extends ConsumerWidget {
  final DateTime selectedDate;
  final CashFlowView view;

  const CashFlowSankeyChart({
    super.key,
    required this.selectedDate,
    required this.view,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = selectedDate.year;
    final month = view == CashFlowView.monthly ? selectedDate.month : null;
    final sankeyAsync = ref.watch(sankeyDataProvider(year: year, month: month));
    final formatter = ref.watch(currencyFormatterProvider);

    return sankeyAsync.when(
      loading: () => const SizedBox(
        height: 200,
        child: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      error: (err, _) => SproutCard(
        child: SizedBox(
          height: 100,
          child: Center(child: Text("Error loading chart: $err")),
        ),
      ),
      data: (sankeyData) {
        if (sankeyData.nodes.isEmpty) {
          return SproutCard(
            child: const SizedBox(
              height: 100,
              child: Center(child: Text("No flow data available")),
            ),
          );
        }

        return Padding(
          padding: const EdgeInsets.all(12),
          child: SproutSankeyChart(
            data: sankeyData,
            formatter: formatter.format,
          ),
        );
      },
    );
  }
}
