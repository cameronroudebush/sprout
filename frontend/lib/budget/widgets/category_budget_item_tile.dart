import 'package:material_ui/material_ui.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/budget/widgets/budget_edit_dialog.dart';
import 'package:sprout/category/widgets/category_icon.dart';

class CategoryBudgetItemTile extends StatelessWidget {
  final CategoryBudgetOverviewItem item;
  final int depth;

  const CategoryBudgetItemTile({super.key, required this.item, this.depth = 0});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final currencyFormatter = NumberFormat.simpleCurrency();

    final budgeted = item.budgetedAmount;
    final spent = item.actualSpent;
    final remaining = item.remaining;
    final percentage = item.percentageUsed;
    final hasBudget = item.budgetId != null || budgeted > 0;
    final isOver = hasBudget && item.isOverBudget;

    Color progressColor;
    if (isOver) {
      progressColor = theme.colorScheme.error;
    } else if (percentage > 85) {
      progressColor = Colors.orange;
    } else {
      progressColor = theme.colorScheme.primary;
    }

    final double progressValue =
        hasBudget ? (percentage / 100.0).clamp(0.0, 1.0) : 0.0;

    return InkWell(
      onTap: () => showBudgetEditDialog(context: context, item: item),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16 + depth * 16, 8, 16, 8),
        child: Row(
          spacing: 8,
          children: [
            CategoryIcon(item.category, avatarSize: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                spacing: 4,
                children: [
                  Text(
                    item.category.name,
                    style: theme.textTheme.titleSmall
                        ?.copyWith(fontWeight: FontWeight.w600),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    hasBudget
                        ? (isOver
                            ? '${currencyFormatter.format(remaining.abs())} over limit'
                            : '${currencyFormatter.format(remaining)} left')
                        : 'No limit set · Tap to add one',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isOver
                          ? theme.colorScheme.error
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  if (hasBudget) ...[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progressValue,
                        minHeight: 4,
                        backgroundColor:
                            theme.colorScheme.surfaceContainerHighest,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(progressColor),
                      ),
                    ),
                  ],
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  currencyFormatter.format(spent),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isOver
                        ? theme.colorScheme.error
                        : theme.colorScheme.onSurface,
                  ),
                ),
                Text(
                  hasBudget
                      ? 'of ${currencyFormatter.format(budgeted)}'
                      : 'spent',
                  style: theme.textTheme.bodySmall
                      ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                ),
              ],
            ),
            Icon(Icons.chevron_right,
                size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }
}
