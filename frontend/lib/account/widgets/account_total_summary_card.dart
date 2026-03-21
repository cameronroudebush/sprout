import 'package:flutter/material.dart';
import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/account/models/extensions/account_list_extensions.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/models/extensions/currency_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';

/// This widget renders the total Assets vs Debts across a progress bar and helps display
///   the value of each specific account type.
class TotalSummary extends StatelessWidget {
  /// The accounts to render
  final List<Account> accounts;

  /// If the user is in private mode
  final bool isPrivate;

  const TotalSummary({super.key, required this.accounts, required this.isPrivate});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final totalAssets = accounts.totalAssets;
    final totalDebts = accounts.totalDebts;
    final visualTotal = totalAssets + totalDebts;

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          spacing: 12,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _SummaryLabel(label: "Assets", amount: totalAssets, color: Colors.teal, isPrivate: isPrivate),
                _SummaryLabel(
                  label: "Debts",
                  amount: totalDebts,
                  color: Colors.redAccent,
                  isPrivate: isPrivate,
                  isEnd: true,
                ),
              ],
            ),
            _buildProgressBar(theme, visualTotal),
          ],
        ),
      ),
    );
  }

  /// Builds the multi-segmented progress bar
  Widget _buildProgressBar(ThemeData theme, double total) {
    return Container(
      height: 10,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(5),
      ),
      child: Row(
        children: AccountExtensions.groupConfig.entries.map((entry) {
          // Call the extension method for each segment
          final amount = accounts.sumByType(entry.key);
          return _barSegment(amount, total, entry.value.color);
        }).toList(),
      ),
    );
  }

  /// Constructs an individual segment with flex proportional to its value
  Widget _barSegment(double value, double total, Color color) {
    if (value <= 0 || total <= 0) return const SizedBox.shrink();
    return Expanded(
      flex: (value / total * 1000).toInt().clamp(1, 1000),
      child: Container(color: color),
    );
  }
}

/// This class is used to provide the overall summary label for above the progress bar
class _SummaryLabel extends StatelessWidget {
  final String label;
  final double amount;
  final Color color;
  final bool isEnd;

  /// If the user is in private mode
  final bool isPrivate;

  const _SummaryLabel({
    required this.label,
    required this.amount,
    required this.color,
    required this.isPrivate,
    this.isEnd = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(amount.toCurrency(isPrivate), style: theme.textTheme.headlineSmall?.copyWith(color: color, fontSize: 18)),
      ],
    );
  }
}
