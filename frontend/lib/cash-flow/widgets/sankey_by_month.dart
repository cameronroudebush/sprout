import 'dart:math';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/widgets/overview.dart';
import 'package:sprout/charts/sankey/models/data.dart';
import 'package:sprout/charts/sankey/sankey.dart';
import 'package:sprout/core/provider/service.locator.dart';
import 'package:sprout/core/theme.dart';
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
          if (provider.isLoading) {
            return const Center(
              child: Padding(padding: EdgeInsetsGeometry.all(12), child: CircularProgressIndicator()),
            );
          }
          if (data == null) {
            return const Center(child: Text("Failed to load Cash Flow data."));
          }
          if (data.links.isEmpty) {
            final period = view == CashFlowView.monthly
                ? DateFormat('MMMM yyyy').format(selectedDate)
                : selectedDate.year.toString();
            return Center(child: Text("No cash flow data for $period."));
          }
          final linkCount = data.links.length;
          // Height scales based on the number of links
          double height = min(linkCount * 40.0, isDesktop ? 700 : 600);
          return SizedBox(
            height: height,
            child: InteractiveViewer(
              scaleEnabled: !isDesktop,
              constrained: false,
              minScale: 0.1,
              maxScale: 5.0,
              child: SizedBox(
                height: height,
                width: !isDesktop ? 640 : (AppTheme.maxDesktopSize * .85),
                child: Center(
                  child: SankeyChart(sankeyData: data, formatter: (val) => getFormattedCurrency(val)),
                ),
              ),
            ),
          );
        },
      );
    });
  }
}
