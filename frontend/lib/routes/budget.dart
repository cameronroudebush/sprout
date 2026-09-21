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
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/speed_dial.dart';

enum BudgetTab { overview, categories }

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  late DateTime _selectedDate;
  BudgetTab _currentTab = BudgetTab.overview;

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
      body: SproutLayoutBuilder((isDesktop, context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SproutRouteWrapper(
            size: isDesktop ? SproutRouteSize.large : SproutRouteSize.auto,
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

                overviewAsync.whenDefault(
                  data: (overview) {
                    if (overview == null) return const SizedBox.shrink();

                    if (isDesktop) {
                      // Desktop: Side-by-side layout
                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Left Column: Overview Summary & Historical Performance
                          Expanded(
                            flex: 5,
                            child: Column(
                              children: [
                                BudgetSummaryCard(overview: overview),
                                const SizedBox(height: 16),
                                historyAsync.whenDefault(
                                  data: (history) {
                                    if (history == null || history.history.isEmpty) return const SizedBox.shrink();
                                    return BudgetHistoryChart(historyDto: history);
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 16),

                          // Right Column: Category Budgets List
                          Expanded(
                            flex: 6,
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
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
                            ),
                          ),
                        ],
                      );
                    }

                    // Mobile View: Segmented Button with Tabs
                    return Column(
                      children: [
                        SegmentedButton<BudgetTab>(
                          style: SegmentedButton.styleFrom(visualDensity: VisualDensity.compact),
                          segments: const [
                            ButtonSegment(value: BudgetTab.overview, label: Text('Overview'), icon: Icon(Icons.pie_chart_outline)),
                            ButtonSegment(value: BudgetTab.categories, label: Text('Budgets'), icon: Icon(Icons.list_alt_rounded)),
                          ],
                          selected: {_currentTab},
                          onSelectionChanged: (Set<BudgetTab> newSelection) {
                            setState(() {
                              _currentTab = newSelection.first;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        if (_currentTab == BudgetTab.overview) ...[
                          BudgetSummaryCard(overview: overview),
                          const SizedBox(height: 16),
                          historyAsync.whenDefault(
                            data: (history) {
                              if (history == null || history.history.isEmpty) return const SizedBox.shrink();
                              return BudgetHistoryChart(historyDto: history);
                            },
                          ),
                        ] else ...[
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
                      ],
                    );
                  },
                ),

                const SizedBox(height: 80), // FAB padding
              ],
            ),
          ),
        );
      }),
    );
  }
}
