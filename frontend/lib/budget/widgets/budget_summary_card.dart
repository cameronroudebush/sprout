import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/shared/widgets/card.dart';

class BudgetSummaryCard extends StatelessWidget {
  final BudgetOverviewResponseDto overview;

  const BudgetSummaryCard({super.key, required this.overview});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.simpleCurrency();

    final date = DateTime(overview.year.toInt(), overview.month.toInt());
    final monthName = DateFormat('MMMM yyyy').format(date);

    final totalBudgeted = overview.totalBudgeted.toDouble();
    final totalSpent = overview.totalSpent.toDouble();
    final totalRemaining = overview.totalRemaining.toDouble();
    final isOver = overview.isOverBudget;
    final totalOverAmount = overview.totalOverBudgetAmount.toDouble();

    final double progress = totalBudgeted > 0 ? (totalSpent / totalBudgeted).clamp(0.0, 1.0) : 1.0;

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  monthName,
                  style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isOver ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    isOver ? 'Over Budget' : 'On Track',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: isOver ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Budgeted',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(totalBudgeted),
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Total Spent',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        currencyFormatter.format(totalSpent),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOver ? theme.colorScheme.error : theme.colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isOver ? 'Over Budget By' : 'Total Remaining',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isOver ? currencyFormatter.format(totalOverAmount) : currencyFormatter.format(totalRemaining),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOver ? theme.colorScheme.error : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LinearProgressIndicator(
                value: progress,
                minHeight: 10,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
                valueColor: AlwaysStoppedAnimation<Color>(
                  isOver ? theme.colorScheme.error : theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
