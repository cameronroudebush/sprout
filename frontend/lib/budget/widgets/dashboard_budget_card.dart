import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/budget/provider/budget_provider.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';

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
    final summary = ref.watch(budgetSummaryProvider((year: now.year, month: now.month)));

    return SproutCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        spacing: 8,
        children: [
          SproutChartHeader(
            title: 'Budget',
            subheader: monthName,
            left: const SizedBox.shrink(),
            right: summary == null ? null : _buildStatusBadge(theme, summary),
          ),
          overviewAsync.whenDefault(
            data: (overview) {
              if (overview == null || summary == null) {
                return const SizedBox.shrink();
              }
              final isOver = summary.isOverBudget;
              final budgetedItems = overview.items.where((i) => i.budgetedAmount > 0).toList();
              return Padding(
                padding: EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Metrics Row
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Budgeted',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currencyFormatter.format(summary.totalBudgeted),
                                style: theme.textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                'Spent',
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                currencyFormatter.format(summary.totalSpent),
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
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Text(
                                !summary.hasLimits ? 'Next step' : (isOver ? 'Over By' : 'Remaining'),
                                style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                !summary.hasLimits
                                    ? 'Set a limit'
                                    : currencyFormatter
                                        .format(isOver ? summary.totalOverBudgetAmount : summary.totalRemaining),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: !summary.hasLimits
                                      ? theme.colorScheme.primary
                                      : (isOver ? theme.colorScheme.error : theme.colorScheme.primary),
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
                        value: summary.progress,
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
                          child: Text(
                        'Set category limits to track your monthly spending here.',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      )),
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
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(ThemeData theme, BudgetSummary summary) {
    final backgroundColor = !summary.hasLimits
        ? theme.colorScheme.surfaceContainerHighest
        : (summary.isOverBudget ? theme.colorScheme.errorContainer : theme.colorScheme.primaryContainer);
    final foregroundColor = !summary.hasLimits
        ? theme.colorScheme.onSurfaceVariant
        : (summary.isOverBudget ? theme.colorScheme.onErrorContainer : theme.colorScheme.onPrimaryContainer);
    final label = !summary.hasLimits ? 'No limits yet' : (summary.isOverBudget ? 'Over limit' : 'On track');

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: foregroundColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
