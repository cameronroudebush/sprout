import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/budget/provider/budget_provider.dart';
import 'package:sprout/budget/widgets/budget_edit_dialog.dart';
import 'package:sprout/budget/widgets/budget_history_chart.dart';
import 'package:sprout/budget/widgets/budget_summary_card.dart';
import 'package:sprout/budget/widgets/category_budget_item_tile.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/speed_dial.dart';

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _previousMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month - 1, 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedDate = DateTime(_selectedDate.year, _selectedDate.month + 1, 1);
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final year = _selectedDate.year;
    final month = _selectedDate.month;

    final overviewAsync = ref.watch(budgetOverviewProvider((year: year, month: month)));
    final historyAsync = ref.watch(budgetHistoryProvider((months: 6, categoryId: null)));

    final monthLabel = DateFormat('MMMM yyyy').format(_selectedDate);

    return Scaffold(
      floatingActionButton: SproutSpeedDial(
        actions: [
          FABAction(
            icon: Icons.add_chart_rounded,
            label: 'Add Budget Target',
            onTap: (ctx) => showBudgetEditDialog(context: ctx),
          ),
        ],
      ),
      body: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: SproutRouteWrapper(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Month Selector Bar
              SproutCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.chevron_left),
                        onPressed: _previousMonth,
                        tooltip: 'Previous Month',
                      ),
                      Text(
                        monthLabel,
                        style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                      ),
                      IconButton(
                        icon: const Icon(Icons.chevron_right),
                        onPressed: _nextMonth,
                        tooltip: 'Next Month',
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Overview Summary
              overviewAsync.whenDefault(
                data: (overview) {
                  if (overview == null) return const SizedBox.shrink();
                  return Column(
                    children: [
                      BudgetSummaryCard(overview: overview),
                      const SizedBox(height: 16),

                      // Historical Chart
                      historyAsync.whenDefault(
                        data: (history) {
                          if (history == null || history.history.isEmpty) return const SizedBox.shrink();
                          return Column(
                            children: [
                              BudgetHistoryChart(historyDto: history),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),

                      // Category Breakdown Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Category Budgets',
                            style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          Text(
                            '${overview.items.length} categories',
                            style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Category Budget List
                      if (overview.items.isEmpty)
                        SproutCard(
                          child: Padding(
                            padding: const EdgeInsets.all(24.0),
                            child: Center(
                              child: Text(
                                'No budgets set for this month. Tap "+" to add a target.',
                                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
                              ),
                            ),
                          ),
                        )
                      else
                        Column(
                          children: overview.items
                              .map(
                                (item) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: CategoryBudgetItemTile(item: item),
                                ),
                              )
                              .toList(),
                        ),
                    ],
                  );
                },
              ),

              const SizedBox(height: 80), // FAB padding
            ],
          ),
        ),
      ),
    );
  }
}
