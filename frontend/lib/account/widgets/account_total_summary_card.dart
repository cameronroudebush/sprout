import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/account/models/extensions/account_extensions.dart';
import 'package:sprout/account/models/extensions/account_list_extensions.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/providers/currency_provider.dart';

/// This widget renders the total Assets vs Debts across a progress bar and helps display
/// the value of each specific account type.
class TotalSummary extends ConsumerWidget {
  /// The accounts to render
  final List<Account> accounts;

  /// Whether to show the percentage label inside each bar segment
  final bool showPercentages;

  const TotalSummary({
    super.key,
    required this.accounts,
    this.showPercentages = false,
  });

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
            _SummaryLabel(
                label: "Assets", amount: totalAssets, color: Colors.teal),
            _SummaryLabel(
              label: "Debts",
              amount: totalDebts,
              color: Colors.redAccent,
              isEnd: true,
            ),
          ],
        ),
        if (accounts.isNotEmpty)
          _buildProgressBar(theme, visualTotal, formatter),
      ],
    );
  }

  /// Builds the multi-segmented progress bar
  Widget _buildProgressBar(
      ThemeData theme, num total, CurrencyFormatter formatter) {
    final visibleSegments = AccountExtensions.groupConfig.entries
        .map((entry) => (entry: entry, amount: accounts.sumByType(entry.key)))
        .where((data) => data.amount > 0)
        .toList();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: SizedBox(
        height: 24,
        child: Row(
          spacing: 2,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: visibleSegments.asMap().entries.map((entry) {
            final index = entry.key;
            final data = entry.value;

            return _barSegment(
              data.amount,
              total,
              data.entry.value.color,
              data.entry.value.title,
              theme,
              isFirst: index == 0,
              isLast: index == visibleSegments.length - 1,
            );
          }).toList(),
        ),
      ),
    );
  }

  /// Constructs an individual segment wrapped in a Tooltip
  Widget _barSegment(
      num value, num total, Color color, String title, ThemeData theme,
      {required bool isFirst, required bool isLast}) {
    const int minFlex = 20;

    if (value <= 0 || total <= 0) return const SizedBox.shrink();

    final double percentage = (value / total) * 100;
    int calculatedFlex = (value / total * 1000).toInt();
    int finalFlex = calculatedFlex < minFlex ? minFlex : calculatedFlex;
    final String tooltipPercent = percentage.toStringAsFixed(1);

    return Expanded(
      flex: finalFlex,
      child: _HoverableBarSegment(
        color: color,
        title: title,
        tooltipPercent: tooltipPercent,
        percentage: percentage,
        showPercentages: showPercentages,
        theme: theme,
        isFirst: isFirst,
        isLast: isLast,
      ),
    );
  }
}

class _HoverableBarSegment extends StatefulWidget {
  final Color color;
  final String title;
  final String tooltipPercent;
  final double percentage;
  final bool showPercentages;
  final ThemeData theme;
  final bool isFirst;
  final bool isLast;

  const _HoverableBarSegment({
    required this.color,
    required this.title,
    required this.tooltipPercent,
    required this.percentage,
    required this.showPercentages,
    required this.theme,
    this.isFirst = false,
    this.isLast = false,
  });

  @override
  State<_HoverableBarSegment> createState() => _HoverableBarSegmentState();
}

class _HoverableBarSegmentState extends State<_HoverableBarSegment> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: "${widget.title}: ${widget.tooltipPercent}%",
      waitDuration: const Duration(milliseconds: 10),
      preferBelow: false,
      verticalOffset: 16,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: Center(
          child: AnimatedContainer(
            width: double.infinity,
            height: _isHovered ? 22 : 16,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(widget.isFirst ? 8 : 2),
                bottomLeft: Radius.circular(widget.isFirst ? 8 : 2),
                topRight: Radius.circular(widget.isLast ? 8 : 2),
                bottomRight: Radius.circular(widget.isLast ? 8 : 2),
              ),
            ),
            alignment: Alignment.center,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final bool canFitText =
                    widget.showPercentages && constraints.maxWidth > 28;

                return canFitText
                    ? Text(
                        "${widget.percentage.toStringAsFixed(0)}%",
                        style: widget.theme.textTheme.bodySmall?.copyWith(
                          color: Colors.white,
                          fontSize: 9,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    : const SizedBox.shrink();
              },
            ),
          ),
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
      crossAxisAlignment:
          isEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        Text(formatter.format(amount),
            style: theme.textTheme.headlineSmall
                ?.copyWith(color: color, fontSize: 18)),
      ],
    );
  }
}
