import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/widgets/charts/models/chart_range.dart';
import 'package:sprout/user/user_config_provider.dart';

/// A compact, reusable selector for chart ranges across the Sprout app.
class ChartRangeSelector extends ConsumerWidget {
  final ValueChanged<ChartRangeEnum>? onRangeSelected;

  /// If we want to render the large version of this
  final bool large;

  const ChartRangeSelector({super.key, this.onRangeSelected, this.large = false});

  /// Centralized handler for range updates to keep providers and callbacks in sync
  void _handleRangeChange(WidgetRef ref, ChartRangeEnum range) async {
    await ref.read(userConfigProvider.notifier).updateChartRange(range);
    if (onRangeSelected != null) {
      onRangeSelected!(range);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userConfig = ref.watch(userConfigProvider);
    final selectedRange = userConfig.value?.netWorthRange ?? ChartRangeEnum.oneMonth;

    if (large) return _buildLargeVersion(context, ref, selectedRange);
    return _buildCompactVersion(context, ref, selectedRange);
  }

  /// The compact popup menu version
  Widget _buildCompactVersion(BuildContext context, WidgetRef ref, ChartRangeEnum selectedRange) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

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
                color: colorScheme.onSecondaryContainer,
              ),
            ),
            const SizedBox(width: 4),
            Icon(Icons.keyboard_arrow_down_rounded, size: 14, color: colorScheme.onSecondaryContainer),
          ],
        ),
      ),
      onSelected: (range) => _handleRangeChange(ref, range),
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
                  color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Builds a large version of the selection range that acts as a row using SegmentedButton
  Widget _buildLargeVersion(BuildContext context, WidgetRef ref, ChartRangeEnum selectedRange) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<ChartRangeEnum>(
        showSelectedIcon: false,
        segments: ChartRangeEnum.values.map((range) {
          return ButtonSegment<ChartRangeEnum>(
            value: range,
            label: Text(ChartRangeUtility.asPretty(range), style: const TextStyle(fontSize: 12)),
          );
        }).toList(),
        selected: {selectedRange},
        onSelectionChanged: (Set<ChartRangeEnum> newSelection) {
          _handleRangeChange(ref, newSelection.first);
        },
        style: SegmentedButton.styleFrom(
          visualDensity: VisualDensity.compact,
          selectedForegroundColor: theme.colorScheme.onPrimary,
          selectedBackgroundColor: theme.colorScheme.primary,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        ),
      ),
    );
  }
}
