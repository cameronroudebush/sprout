import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/charts/sankey/sankey.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Renders the Sankey diagram with month consideration integrated
class SankeyByMonth extends ConsumerWidget {
  final DateTime selectedDate;
  final CashFlowView view;

  const SankeyByMonth(this.selectedDate, {super.key, required this.view});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final year = selectedDate.year;
    final month = view == CashFlowView.monthly ? selectedDate.month : null;
    final privateMode = ref.watch(userConfigProvider).value?.privateMode ?? false;

    // Watch the specific Sankey data slice for this timeframe
    final sankeyAsync = ref.watch(sankeyDataProvider(year: year, month: month));

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return sankeyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error loading Sankey: $err")),
        data: (data) {
          if (data.links.isEmpty) {
            return Center(child: Text(CashFlowViewFormatter.getNoDataText(view, selectedDate)));
          }

          final initialScale = 0.7;
          final TransformationController controller = TransformationController(
            Matrix4.diagonal3Values(initialScale, initialScale, 1.0),
          );

          return SizedBox(
            height: constraints.maxHeight,
            width: constraints.maxWidth,
            child: ClipRect(
              child: InteractiveViewer(
                transformationController: controller,
                scaleEnabled: !isDesktop,
                constrained: false,
                boundaryMargin: const EdgeInsets.all(20),
                minScale: 0.1,
                maxScale: 5.0,

                child: SizedBox(
                  height: 1024,
                  width: !kIsWeb ? 760 : constraints.maxWidth,
                  child: Center(
                    child: SankeyChart(
                      sankeyData: data,
                      formatter: (val) => val.toCurrency(privateMode),
                      onNodeTap: (node, value) {
                        NavigationProvider.redirectToCatFilter(ref, node);
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
