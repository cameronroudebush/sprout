import 'package:flutter/material.dart';
import 'package:sprout/charts/models/chart_range.dart';
import 'package:sprout/core/widgets/text.dart';

class ChartRangeSelector extends StatelessWidget {
  final ChartRange selectedChartRange;
  final ValueChanged<ChartRange>? onRangeSelected;

  const ChartRangeSelector({super.key, required this.selectedChartRange, required this.onRangeSelected});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Filter out ranges we don't want to show
    final filteredRanges = ChartRange.values.toList();

    final isSelectedList = filteredRanges.map((range) => range == selectedChartRange).toList();

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ToggleButtons(
            isSelected: isSelectedList,
            onPressed: (int index) {
              if (onRangeSelected != null) {
                onRangeSelected!(filteredRanges[index]);
              }
            },
            borderRadius: BorderRadius.circular(8.0),
            selectedColor: colorScheme.onPrimary,
            fillColor: colorScheme.primary,
            color: colorScheme.primary,
            borderColor: colorScheme.primary.withValues(alpha: 0.5),
            selectedBorderColor: colorScheme.primary,
            constraints: BoxConstraints(minHeight: 36.0, minWidth: constraints.maxWidth / (filteredRanges.length + 1)),
            children: filteredRanges.map((range) => TextWidget(text: ChartRangeUtility.asPretty(range))).toList(),
          );
        },
      ),
    );
  }
}
