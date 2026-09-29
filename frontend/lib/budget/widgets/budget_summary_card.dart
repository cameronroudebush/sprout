import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/budget/provider/budget_provider.dart';
import 'package:sprout/shared/widgets/card.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetSummary summary;
  final double? monthlyIncome;

  const BudgetSummaryCard({
    super.key,
    required this.summary,
    this.monthlyIncome,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.simpleCurrency();

    final hasLimits = summary.hasLimits;
    final isOver = summary.isOverBudget;

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          spacing: 8,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Your month at a glance',
                  style: theme.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: !hasLimits
                        ? theme.colorScheme.surfaceContainerHighest
                        : (isOver
                            ? theme.colorScheme.errorContainer
                            : theme.colorScheme.primaryContainer),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    !hasLimits
                        ? 'No limits yet'
                        : (isOver ? 'Over limit' : 'On track'),
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: !hasLimits
                          ? theme.colorScheme.onSurfaceVariant
                          : (isOver
                              ? theme.colorScheme.onErrorContainer
                              : theme.colorScheme.onPrimaryContainer),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        'Spent this month',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        currencyFormatter.format(summary.totalSpent),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        'Monthly limits',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        currencyFormatter.format(summary.totalBudgeted),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    spacing: 8,
                    children: [
                      Text(
                        hasLimits
                            ? (isOver ? 'Over limits by' : 'Still available')
                            : 'Next step',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        hasLimits
                            ? currencyFormatter.format(isOver
                                ? summary.totalOverBudgetAmount
                                : summary.totalRemaining)
                            : 'Set a limit',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: !hasLimits
                              ? theme.colorScheme.primary
                              : (isOver
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (hasLimits)
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: summary.progress,
                  minHeight: 10,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    isOver
                        ? theme.colorScheme.error
                        : theme.colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
