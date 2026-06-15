import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/charts/models/color.dart';
import 'package:sprout/shared/widgets/charts/models/legend_position.dart';
import 'package:sprout/shared/widgets/charts/util/legend.dart';

/// Reusable frame for orienting our chart content
class SproutChartLayoutFrame extends StatelessWidget {
  final Widget? header;
  final Map<String, num> data;
  final SproutChartLegendPosition legendPosition;
  final SproutChartColorResolver colorResolver;
  final Widget chartArea;

  const SproutChartLayoutFrame({
    super.key,
    required this.header,
    required this.data,
    required this.legendPosition,
    required this.colorResolver,
    required this.chartArea,
  });

  @override
  Widget build(BuildContext context) {
    final legendWidget = SproutChartLegend(
      data: data,
      position: legendPosition,
      colorResolver: colorResolver,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (header != null) header!,
          const SizedBox(height: 12),
          Expanded(
            child: legendPosition == SproutChartLegendPosition.bottom
                ? Column(
                    children: [
                      Expanded(child: chartArea),
                      const SizedBox(height: 12),
                      legendWidget,
                    ],
                  )
                : Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      if (legendPosition == SproutChartLegendPosition.left)
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(right: 24),
                            child: legendWidget,
                          ),
                        ),
                      Expanded(child: chartArea),
                      if (legendPosition == SproutChartLegendPosition.right)
                        SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: Padding(
                            padding: const EdgeInsets.only(left: 24),
                            child: legendWidget,
                          ),
                        ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
