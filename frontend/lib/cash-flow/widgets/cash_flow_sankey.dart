import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/sankey.dart';

/// This renders an interactive Sankey diagram showing cash flow distributions.
class CashFlowSankeyChart extends ConsumerWidget {
  final double height;
  final String title;
  final String? subheader;
  final DateTime selectedDate;
  final CashFlowView view;

  const CashFlowSankeyChart({
    super.key,
    required this.height,
    required this.selectedDate,
    required this.view,
    this.title = "Cash Flow Distribution",
    this.subheader,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = selectedDate.year;
    final month = view == CashFlowView.monthly ? selectedDate.month : null;
    final sankeyAsync = ref.watch(sankeyDataProvider(year: year, month: month));
    final formatter = ref.watch(currencyFormatterProvider);

    return sankeyAsync.when(
      loading: () => SproutCard(
        child: SizedBox(
          height: height + 50,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => SproutCard(
        child: SizedBox(
          height: height + 50,
          child: Center(child: Text("Error loading chart: $err")),
        ),
      ),
      data: (sankeyData) {
        if (sankeyData.nodes.isEmpty) {
          return SproutCard(
            child: SizedBox(
              height: height + 50,
              child: const Center(child: Text("No flow data available")),
            ),
          );
        }

        return SproutCard(
          applySizedBox: false,
          child: Padding(
              padding: EdgeInsetsGeometry.all(12),
              child: SproutSankeyChart(
                data: sankeyData,
                height: height,
                formatter: formatter.format,
              )),
        );
      },
    );
  }
}
