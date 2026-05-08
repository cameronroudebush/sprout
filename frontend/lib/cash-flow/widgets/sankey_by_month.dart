import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/cash-flow/models/cash_flow_view.dart';
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/providers/currency_provider.dart';
import 'package:sprout/shared/widgets/charts/sankey/sankey.dart';
import 'package:sprout/shared/widgets/layout.dart';

/// Renders the Sankey diagram with month consideration integrated
class SankeyByMonth extends ConsumerStatefulWidget {
  // Changed to StatefulWidget to hold controller
  final DateTime selectedDate;
  final CashFlowView view;

  const SankeyByMonth(this.selectedDate, {super.key, required this.view});

  @override
  ConsumerState<SankeyByMonth> createState() => _SankeyByMonthState();
}

class _SankeyByMonthState extends ConsumerState<SankeyByMonth> {
  late TransformationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = TransformationController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateZoom(double scaleFactor) {
    final Matrix4 current = _controller.value;
    final double currentScale = current.getMaxScaleOnAxis();
    final double newScale = (currentScale * scaleFactor).clamp(0.5, 3.0);
    final translation = current.getTranslation();
    setState(() {
      _controller.value = Matrix4.identity()
        ..translate(translation.x, translation.y)
        ..scale(newScale);
    });
  }

  void _resetZoom() {
    setState(() {
      _controller.value = Matrix4.identity();
    });
  }

  @override
  Widget build(BuildContext context) {
    final year = widget.selectedDate.year;
    final month = widget.view == CashFlowView.monthly ? widget.selectedDate.month : null;
    final formatter = ref.watch(currencyFormatterProvider);
    final sankeyAsync = ref.watch(sankeyDataProvider(year: year, month: month));

    return SproutLayoutBuilder((isDesktop, context, constraints) {
      return sankeyAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text("Error: $err")),
        data: (data) {
          if (data.links.isEmpty) return Center(child: Text("No data available"));

          // Dynamic height to prevent clipping
          final dynamicHeight = (data.nodes.length * 70.0).clamp(600.0, 3000.0);

          return Stack(
            children: [
              InteractiveViewer(
                transformationController: _controller,
                constrained: false,
                scaleEnabled: false,
                panEnabled: true,
                minScale: 0.1,
                maxScale: 5.0,
                child: SizedBox(
                  width: constraints.maxWidth * 1.5,
                  height: dynamicHeight,
                  child: SankeyChart(
                    sankeyData: data,
                    formatter: (val) => formatter.format(val),
                    onNodeTap: (node, value) => NavigationProvider.redirectToCatFilter(ref, node),
                  ),
                ),
              ),

              // Zoom Controls Overlay
              Positioned(
                right: 16,
                bottom: 16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    FloatingActionButton.small(
                      heroTag: null,
                      onPressed: () => _updateZoom(1.1),
                      child: Icon(Icons.add),
                    ),
                    FloatingActionButton.small(
                      heroTag: null,
                      onPressed: () => _updateZoom(0.9),
                      child: Icon(Icons.remove),
                    )
                  ],
                ),
              ),
            ],
          );
        },
      );
    });
  }
}
