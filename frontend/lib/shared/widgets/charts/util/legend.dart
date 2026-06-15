import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:sprout/shared/widgets/charts/models/color.dart';
import 'package:sprout/shared/widgets/charts/models/legend_position.dart';

/// A reusable legend to apply to our charts
class SproutChartLegend extends StatelessWidget {
  final Map<String, num> data;
  final SproutChartLegendPosition position;
  final SproutChartColorResolver colorResolver;

  const SproutChartLegend({
    super.key,
    required this.data,
    required this.position,
    required this.colorResolver,
  });

  @override
  Widget build(BuildContext context) {
    if (position == SproutChartLegendPosition.none) return const SizedBox();

    final entries = data.entries.sorted((a, b) {
      if (a.key.startsWith("+")) return 1;
      if (b.key.startsWith("+")) return -1;
      return b.value.compareTo(a.value);
    });

    final legendItems = entries.map((entry) {
      final isOthers = entry.key.startsWith("+");

      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: BoxDecoration(
                color: colorResolver.resolve(entry.key),
                shape: isOthers ? BoxShape.rectangle : BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(entry.key, style: const TextStyle(fontSize: 11), overflow: TextOverflow.ellipsis),
          ],
        ),
      );
    }).toList();

    if (position == SproutChartLegendPosition.bottom) {
      return Wrap(alignment: WrapAlignment.center, spacing: 12, runSpacing: 6, children: legendItems);
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: legendItems);
  }
}
