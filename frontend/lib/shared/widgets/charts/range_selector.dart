import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/widgets/charts/models/chart_range.dart';
import 'package:sprout/user/user_config_provider.dart';

/// Allows for selection of chart range times that is shared across all chart widgets
class ChartRangeSelector extends ConsumerWidget {
  final ValueChanged<ChartRangeEnum>? onRangeSelected;

  const ChartRangeSelector({super.key, this.onRangeSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userConfig = ref.watch(userConfigProvider);
    final selectedRange = userConfig.value?.netWorthRange ?? ChartRangeEnum.oneMonth;

    final filteredRanges = ChartRangeEnum.values.toList();
    final isSelectedList = filteredRanges.map((range) => range == selectedRange).toList();

    return Center(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return ToggleButtons(
            isSelected: isSelectedList,
            onPressed: (int index) async {
              final newRange = filteredRanges[index];
              await ref.read(userConfigProvider.notifier).updateChartRange(newRange);
              if (onRangeSelected != null) {
                onRangeSelected!(newRange);
              }
            },
            borderRadius: BorderRadius.circular(8.0),
            selectedColor: colorScheme.onPrimary,
            fillColor: colorScheme.primary,
            color: colorScheme.primary,
            borderColor: colorScheme.primary.withOpacity(0.5),
            selectedBorderColor: colorScheme.primary,
            // Adjusting constraints to ensure it fits the layout
            constraints: BoxConstraints(minHeight: 36.0, minWidth: (constraints.maxWidth - 32) / filteredRanges.length),
            children: filteredRanges
                .map(
                  (range) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: Text(
                      ChartRangeUtility.asPretty(range),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                  ),
                )
                .toList(),
          );
        },
      ),
    );
  }
}
