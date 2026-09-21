import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sprout/budget/provider/budget_provider.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';

/// A dashboard widget providing a snapshot of the current month's budget status.
class DashboardBudgetCard extends ConsumerWidget {
  const DashboardBudgetCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.simpleCurrency();
    final now = DateTime.now();
    final monthName = DateFormat('MMMM yyyy').format(now);

    final overviewAsync = ref.watch(budgetOverviewProvider((year: now.year, month: now.month)));

    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.pie_chart_rounded,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Monthly Budget',
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                IconButton(
                  icon: const Icon(Icons.arrow_forward_rounded, size: 20),
                  tooltip: 'View Budget Details',
                  onPressed: () => context.go('/budget'),
                ),
              ],
            ),
            const SizedBox(height: 8),

            overviewAsync.whenDefault(
              data: (overview) {
                if (overview == null) {
                  return const SizedBox.shrink();
                }

                final totalBudgeted = overview.totalBudgeted.toDouble();
                final totalSpent = overview.totalSpent.toDouble();
                final totalRemaining = overview.totalRemaining.toDouble();
                final isOver = overview.isOverBudget;
                final totalOverAmount = overview.totalOverBudgetAmount.toDouble();
                final progress = totalBudgeted > 0 ? (totalSpent / totalBudgeted).clamp(0.0, 1.0) : 1.0;

                final budgetedItems = overview.items.where((i) => i.budgetedAmount > 0).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          monthName,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                          decoration: BoxDecoration(
                            color: isOver ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            isOver ? 'Over Budget' : 'On Track',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: isOver ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Metrics Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Budgeted',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currencyFormatter.format(totalBudgeted),
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Spent',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currencyFormatter.format(totalSpent),
                                style: theme.textTheme.bodyMedium?.copyWith(
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
                                isOver ? 'Over By' : 'Remaining',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                isOver ? currencyFormatter.format(totalOverAmount) : currencyFormatter.format(totalRemaining),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isOver ? theme.colorScheme.error : theme.colorScheme.primary,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Overall Progress Bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: theme.colorScheme.surfaceContainerHighest,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          isOver ? theme.colorScheme.error : theme.colorScheme.primary,
                        ),
                      ),
                    ),

                    if (budgetedItems.isEmpty) ...[
                      const SizedBox(height: 12),
                      Center(
                        child: TextButton.icon(
                          onPressed: () => context.go('/budget'),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Set up category budgets'),
                        ),
                      ),
                    ] else ...[
                      const SizedBox(height: 12),
                      // Top 2 Category Budget Items
                      ...budgetedItems.take(2).map((item) {
                        final itemProgress = (item.percentageUsed / 100.0).clamp(0.0, 1.0);
                        return Padding(
                          padding: const EdgeInsets.only(top: 8.0),
                          child: Row(
                            children: [
                              CategoryIcon(item.category, avatarSize: 14),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 3,
                                child: Text(
                                  item.category.name,
                                  style: theme.textTheme.labelSmall?.copyWith(fontWeight: FontWeight.w600),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                flex: 4,
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(3),
                                  child: LinearProgressIndicator(
                                    value: itemProgress,
                                    minHeight: 6,
                                    backgroundColor: theme.colorScheme.surfaceContainerHighest,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      item.isOverBudget
                                          ? theme.colorScheme.error
                                          : (item.percentageUsed > 85 ? Colors.orange : theme.colorScheme.primary),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                '${currencyFormatter.format(item.actualSpent)} / ${currencyFormatter.format(item.budgetedAmount)}',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontSize: 10,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
