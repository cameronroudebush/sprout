import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:sprout/api/api.dart';
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

enum MobileBudgetTab { current, history }

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  late DateTime _selectedDate;
  MobileBudgetTab _currentTab = MobileBudgetTab.current;

  final ScrollController _mobileScrollController = ScrollController();
  final ScrollController _desktopScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  @override
  void dispose() {
    _mobileScrollController.dispose();
    _desktopScrollController.dispose();
    super.dispose();
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
      body: SproutLayoutBuilder(
        (isDesktop, context, constraints) {
          if (isDesktop) {
            return SproutRouteWrapper(
              size: SproutRouteSize.large,
              child: SingleChildScrollView(
                controller: _desktopScrollController,
                child: overviewAsync.whenDefault(
                  data: (overview) {
                    if (overview == null) return const SizedBox.shrink();
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Month Selector, Summary, and History Chart
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildMonthSelector(theme, monthLabel),
                              const SizedBox(height: 16),
                              BudgetSummaryCard(overview: overview),
                              const SizedBox(height: 16),
                              historyAsync.whenDefault(
                                data: (history) {
                                  if (history == null || history.history.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  return BudgetHistoryChart(historyDto: history);
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 20),

                        // Right Column: Category Budgets Header & Grid
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildCategoryHeader(theme, overview, isDesktop: true),
                              const SizedBox(height: 12),
                              if (overview.items.isEmpty)
                                _buildEmptyBudgetsCard(theme)
                              else
                                GridView.builder(
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                    crossAxisCount: 2,
                                    mainAxisExtent: 110,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: overview.items.length,
                                  itemBuilder: (context, index) {
                                    return CategoryBudgetItemTile(item: overview.items[index]);
                                  },
                                ),
                            ],
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            );
          }

          // Mobile View
          return SproutRouteWrapper(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    controller: _mobileScrollController,
                    child: overviewAsync.whenDefault(
                      data: (overview) {
                        if (overview == null) return const SizedBox.shrink();
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_currentTab == MobileBudgetTab.current) ...[
                              _buildMonthSelector(theme, monthLabel),
                              const SizedBox(height: 16),
                              BudgetSummaryCard(overview: overview),
                              const SizedBox(height: 16),
                              _buildCategoryHeader(theme, overview, isDesktop: false),
                              const SizedBox(height: 12),
                              if (overview.items.isEmpty)
                                _buildEmptyBudgetsCard(theme)
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
                            ] else ...[
                              historyAsync.whenDefault(
                                data: (history) {
                                  if (history == null || history.history.isEmpty) {
                                    return SproutCard(
                                      child: Padding(
                                        padding: const EdgeInsets.all(24.0),
                                        child: Center(
                                          child: Text(
                                            'No historical data available.',
                                            style: theme.textTheme.bodyMedium?.copyWith(
                                              color: theme.colorScheme.onSurfaceVariant,
                                            ),
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                  return BudgetHistoryChart(historyDto: history);
                                },
                              ),
                            ],
                            const SizedBox(height: 80), // FAB spacing
                          ],
                        );
                      },
                    ),
                  ),
                ),

                // Mobile Navigation Segmented Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
                  child: SizedBox(
                    width: double.infinity,
                    child: SegmentedButton<MobileBudgetTab>(
                      style: SegmentedButton.styleFrom(
                        visualDensity: VisualDensity.compact,
                      ),
                      segments: const [
                        ButtonSegment(
                          value: MobileBudgetTab.current,
                          label: Text('Current Month'),
                          icon: Icon(Icons.pie_chart_outline),
                        ),
                        ButtonSegment(
                          value: MobileBudgetTab.history,
                          label: Text('History'),
                          icon: Icon(Icons.show_chart),
                        ),
                      ],
                      selected: {_currentTab},
                      onSelectionChanged: (Set<MobileBudgetTab> newSelection) {
                        setState(() {
                          _currentTab = newSelection.first;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildMonthSelector(ThemeData theme, String monthLabel) {
    return SproutCard(
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
    );
  }

  Widget _buildCategoryHeader(ThemeData theme, BudgetOverviewResponseDto overview, {required bool isDesktop}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Category Budgets',
          style: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        Row(
          children: [
            Text(
              '${overview.items.length} categories',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            if (isDesktop) ...[
              const SizedBox(width: 12),
              FilledButton.icon(
                onPressed: () => showBudgetEditDialog(context: context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Target'),
              ),
            ],
          ],
        ),
      ],
    );
  }

  Widget _buildEmptyBudgetsCard(ThemeData theme) {
    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Center(
          child: Column(
            children: [
              Text(
                'No budgets set for this month. Tap "+" to add a target.',
                style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                onPressed: () => showBudgetEditDialog(context: context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Add Budget Target'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
