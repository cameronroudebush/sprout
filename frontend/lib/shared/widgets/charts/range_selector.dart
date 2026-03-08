import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/widgets/charts/models/chart_range.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A compact, reusable selector for chart ranges across the Sprout app.
class ChartRangeSelector extends ConsumerWidget {
  final ValueChanged<ChartRangeEnum>? onRangeSelected;

  const ChartRangeSelector({super.key, this.onRangeSelected});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final userConfig = ref.watch(userConfigProvider);
    final selectedRange = userConfig.value?.netWorthRange ?? ChartRangeEnum.oneMonth;

    return PopupMenuButton<ChartRangeEnum>(
      initialValue: selectedRange,
      tooltip: 'Select Range',
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: colorScheme.outlineVariant.withValues(alpha: 0.5), width: 1),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              ChartRangeUtility.asPretty(selectedRange),
              style: theme.textTheme.labelMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.onSecondaryContainer,
                fontSize: 11,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: colorScheme.onSecondaryContainer),
          ],
        ),
      ),
      onSelected: (ChartRangeEnum newRange) async {
        await ref.read(userConfigProvider.notifier).updateChartRange(newRange);

        if (onRangeSelected != null) {
          onRangeSelected!(newRange);
        }
      },
      itemBuilder: (context) => ChartRangeEnum.values.map((range) {
        final isSelected = range == selectedRange;
        return PopupMenuItem(
          value: range,
          child: Row(
            spacing: 12,
            children: [
              if (isSelected) Icon(Icons.check, size: 16, color: colorScheme.primary) else const SizedBox(width: 16),
              Text(
                ChartRangeUtility.asPretty(range),
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
