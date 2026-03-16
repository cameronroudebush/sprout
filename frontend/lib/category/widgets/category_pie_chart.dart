import 'package:flex_color_scheme/flex_color_scheme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/pie_chart.dart';

/// This renders a pie chart for the transaction category mapping
class CategoryPieChart extends ConsumerWidget {
  final bool showLegend;
  final double height;
  final DateTime selectedDate;
  final CashFlowView view;
  final bool showSubheader;

  const CategoryPieChart(
    this.selectedDate, {
    super.key,
    this.showLegend = true,
    required this.height,
    this.view = CashFlowView.monthly,
    this.showSubheader = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = selectedDate.year;
    final month = view == CashFlowView.monthly ? selectedDate.month : null;
    final statsAsync = ref.watch(categoryStatsProvider(year: year, month: month));

    return statsAsync.when(
      loading: () => SproutCard(
        child: SizedBox(
          height: height + 50,
          child: const Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (err, _) => SproutCard(
        height: height + 50,
        child: Center(child: Text("Error loading category stats: $err")),
      ),
      data: (data) {
        final categoryCount = data?.categoryCount;

        if (categoryCount == null || categoryCount.isEmpty) {
          return SproutCard(
            height: height,
            child: Center(child: Text(CashFlowViewFormatter.getNoDataText(view, selectedDate))),
          );
        }

        final periodText = CashFlowViewFormatter.getPeriodText(view, selectedDate);

        return SproutCard(
          applySizedBox: false,
          child: SproutPieChart(
            data: categoryCount,
            colorMapping: data!.colorMapping.map((a, b) => MapEntry(a, b.toColor)),
            header: "Categories",
            subheader: showSubheader ? periodText : null,
            showLegend: showLegend,
            showPieTitle: false,
            height: height,
            onSliceTap: (slice, val) {
              NavigationProvider.redirectToCatFilter(ref, slice);
            },
          ),
        );
      },
    );
  }
}
