import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
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

    return sankeyAsync.whenDefault(
      emptyCondition: (sankeyData) => sankeyData.nodes.isEmpty,
      data: (sankeyData) {
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
