import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/charts/sankey/models/data.dart';
import 'package:sprout/charts/sankey/sankey.dart';
import 'package:sprout/core/provider/navigator.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/utils/formatters.dart';
import 'package:sprout/core/widgets/layout.dart';

/// Renders the Sankey diagram with month consideration integrated so it can customize how it displays
class SankeyFlowByMonth extends StatelessWidget {
  final DateTime selectedDate;
  final CashFlowView view;

  const SankeyFlowByMonth(this.selectedDate, {super.key, required this.view});

  /// Returns sankey data if available based on the current requirements
  SankeyData? _getSankeyData() {
    final provider = ServiceLocator.get<CashFlowProvider>();
    final month = view == CashFlowView.monthly ? selectedDate.month : null;
    return provider.getSankeyData(selectedDate.year, month);
  }

  @override
  Widget build(BuildContext context) {
    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return Consumer<CashFlowProvider>(
        builder: (context, provider, child) {
          final data = _getSankeyData();
          if (data == null) {
            return const Center(child: Text("Failed to load Cash Flow data."));
          }
          if (data.links.isEmpty) {
            return Center(child: Text(CashFlowViewFormatter.getNoDataText(view, selectedDate)));
          }
          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: ClipRect(
              child: InteractiveViewer(
                scaleEnabled: !isDesktop,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.1,
                maxScale: 5.0,
                child: SizedBox(
                  height: constraints.maxHeight,
                  // We need a min width for mobile else we'll overlap very easily
                  width: !kIsWeb ? 760 : constraints.maxWidth,
                  child: Center(
                    child: SankeyChart(
                      sankeyData: data,
                      formatter: (val) => getFormattedCurrency(val),
                      onNodeTap: (node, value) {
                        SproutNavigator.redirectToCatFilter(node);
                      },
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
