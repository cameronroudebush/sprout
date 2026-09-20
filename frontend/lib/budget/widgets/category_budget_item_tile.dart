import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/budget/widgets/budget_edit_dialog.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/shared/widgets/card.dart';

class CategoryBudgetItemTile extends StatelessWidget {
  final CategoryBudgetOverviewItem item;

  const CategoryBudgetItemTile({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.simpleCurrency();

    final budgeted = item.budgetedAmount;
    final spent = item.actualSpent;
    final remaining = item.remaining;
    final percentage = item.percentageUsed;
    final isOver = item.isOverBudget;
    final hasBudget = budgeted > 0;

    Color progressColor;
    if (isOver) {
      progressColor = theme.colorScheme.error;
    } else if (percentage > 85) {
      progressColor = Colors.orange;
    } else {
      progressColor = theme.colorScheme.primary;
    }

    final double progressValue = hasBudget ? (percentage / 100.0).clamp(0.0, 1.0) : 1.0;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () => showBudgetEditDialog(context: context, item: item),
      child: SproutCard(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CategoryIcon(item.category, avatarSize: 20),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      item.category.name,
                      style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (isOver)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.warning_amber_rounded, size: 14, color: theme.colorScheme.onErrorContainer),
                          const SizedBox(width: 4),
                          Text(
                            'Over budget',
                            style: theme.textTheme.labelSmall?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (!hasBudget)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Unbudgeted',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progressValue,
                  minHeight: 8,
                  backgroundColor: theme.colorScheme.surfaceContainerHighest,
                  valueColor: AlwaysStoppedAnimation<Color>(progressColor),
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    hasBudget
                        ? '${currencyFormatter.format(spent)} of ${currencyFormatter.format(budgeted)}'
                        : '${currencyFormatter.format(spent)} spent',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    hasBudget
                        ? (isOver
                            ? '${currencyFormatter.format(remaining.abs())} over'
                            : '${currencyFormatter.format(remaining)} left')
                        : '',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isOver ? theme.colorScheme.error : theme.colorScheme.onSurface,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
