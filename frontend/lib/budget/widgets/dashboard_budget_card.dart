import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:sprout/budget/provider/budget_provider.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/user/user_config_provider.dart';

class DashboardBudgetCard extends ConsumerWidget {
  final bool mobile;

  const DashboardBudgetCard({super.key, this.mobile = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userConfig = ref.watch(userConfigProvider).value;
    if (userConfig?.enableBudgeting == false) {
      return const SizedBox.shrink();
    }

    final now = DateTime.now();
    final overviewAsync = ref.watch(budgetOverviewProvider((year: now.year, month: now.month)));

    return overviewAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (overview) {
        if (overview == null || (overview.totalBudgeted == 0 && overview.items.isEmpty)) {
          return const SizedBox.shrink();
        }

        final theme = Theme.of(context);
        final currencyFormatter = NumberFormat.simpleCurrency();

        final totalBudgeted = overview.totalBudgeted.toDouble();
        final totalSpent = overview.totalSpent.toDouble();
        final totalRemaining = overview.totalRemaining.toDouble();
        final isOver = overview.isOverBudget;
        final totalOverAmount = overview.totalOverBudgetAmount.toDouble();

        final double progress = totalBudgeted > 0 ? (totalSpent / totalBudgeted).clamp(0.0, 1.0) : 1.0;

        return InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => context.go('/budget'),
          child: SproutCard(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.pie_chart_rounded, color: theme.colorScheme.primary, size: 20),
                          const SizedBox(width: 8),
                          Text(
                            'Monthly Budget',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      Row(
                        children: [
                          if (isOver)
                            Container(
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Text(
                                'Over Budget',
                                style: theme.textTheme.labelSmall?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          Icon(Icons.chevron_right, color: theme.colorScheme.onSurfaceVariant),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
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
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Spent: ${currencyFormatter.format(totalSpent)} / ${currencyFormatter.format(totalBudgeted)}',
                        style: theme.textTheme.bodySmall?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                      ),
                      Text(
                        isOver ? '${currencyFormatter.format(totalOverAmount)} over' : '${currencyFormatter.format(totalRemaining)} left',
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isOver ? theme.colorScheme.error : theme.colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
