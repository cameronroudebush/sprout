import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/account/models/extensions/account_list_extensions.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/providers/currency_provider.dart';

/// This widget renders the total Assets vs Debts across a progress bar and helps display
///   the value of each specific account type.
class TotalSummary extends ConsumerWidget {
  /// The accounts to render
  final List<Account> accounts;

  const TotalSummary({super.key, required this.accounts});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);

    final totalAssets = accounts.totalAssets;
    final totalDebts = accounts.totalDebts;
    final visualTotal = totalAssets + totalDebts;

    return Column(
      spacing: 12,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            _SummaryLabel(label: "Assets", amount: totalAssets, color: Colors.teal),
            _SummaryLabel(
              label: "Debts",
              amount: totalDebts,
              color: Colors.redAccent,
              isEnd: true,
            ),
          ],
        ),
        if (accounts.isNotEmpty) _buildProgressBar(theme, visualTotal, formatter),
      ],
    );
  }

  /// Builds the multi-segmented progress bar
  Widget _buildProgressBar(ThemeData theme, num total, CurrencyFormatter formatter) {
    final visibleSegments = AccountExtensions.groupConfig.entries
        .map((entry) => (entry: entry, amount: accounts.sumByType(entry.key)))
        .where((data) => data.amount > 0)
        .toList();

    return Padding(
      padding: const EdgeInsetsGeometry.symmetric(horizontal: 0),
      child: Container(
          height: 10,
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(5),
          ),
          child: Row(
            spacing: 4,
            children: visibleSegments.map((data) {
              return _barSegment(data.amount, total, data.entry.value.color);
            }).toList(),
          )),
    );
  }

  /// Constructs an individual segment with flex proportional to its value
  Widget _barSegment(num value, num total, Color color) {
    // Define a minimum weight to ensure the segment is always visible
    const int minFlex = 20;

    if (value <= 0 || total <= 0) return const SizedBox.shrink();

    // Calculate proportional flex, but ensure it never falls below minFlex
    int calculatedFlex = (value / total * 1000).toInt();
    int finalFlex = calculatedFlex < minFlex ? minFlex : calculatedFlex;

    return Expanded(
      flex: finalFlex,
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8.0),
        ),
      ),
    );
  }
}

/// This class is used to provide the overall summary label for above the progress bar
class _SummaryLabel extends ConsumerWidget {
  final String label;
  final num amount;
  final Color color;
  final bool isEnd;

  const _SummaryLabel({
    required this.label,
    required this.amount,
    required this.color,
    this.isEnd = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final formatter = ref.watch(currencyFormatterProvider);
    return Column(
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(formatter.format(amount), style: theme.textTheme.headlineSmall?.copyWith(color: color, fontSize: 18)),
      ],
    );
  }
}
