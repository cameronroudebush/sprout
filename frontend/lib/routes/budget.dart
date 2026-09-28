import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:sprout/api/api.dart';
import 'package:sprout/budget/provider/budget_provider.dart';
import 'package:sprout/budget/widgets/budget_chat_card.dart';
import 'package:sprout/budget/widgets/budget_edit_dialog.dart';
import 'package:sprout/budget/widgets/budget_history_chart.dart';
import 'package:sprout/budget/widgets/budget_summary_card.dart';
import 'package:sprout/budget/widgets/category_budget_item_tile.dart';
import 'package:sprout/cash-flow/cash_flow_provider.dart';
import 'package:sprout/category/category_provider.dart';
import 'package:sprout/category/widgets/category_icon.dart';
import 'package:sprout/chat/chat_provider.dart';
import 'package:sprout/routes/util/main_route_wrapper.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/month_selector.dart';
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

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now();
  }

  void _selectMonth(DateTime month) {
    if (!mounted) return;
    setState(() => _selectedDate = DateTime(month.year, month.month));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChatEnabled = ref.watch(chatEnabledProvider);
    final year = _selectedDate.year;
    final month = _selectedDate.month;

    final overviewAsync =
        ref.watch(budgetOverviewProvider((year: year, month: month)));
    final budgetSummary =
        ref.watch(budgetSummaryProvider((year: year, month: month)));
    final historyAsync = ref.watch(budgetHistoryProvider(
        (months: 6, categoryId: null, year: year, month: month)));
    final cashFlowAsync =
        ref.watch(cashFlowStatsProvider(year: year, month: month));
    final categories =
        ref.watch(categoriesProvider).value ?? const <Category>[];

    final monthlyIncome = cashFlowAsync.maybeWhen(
      data: (stats) => stats?.totalIncome.toDouble(),
      orElse: () => null,
    );

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
        padding: const EdgeInsets.only(bottom: 80),
        child: SproutRouteWrapper(
          size: SproutRouteSize.large,
          child: SproutLayoutBuilder(
            (isDesktop, context, constraints) {
              return overviewAsync.whenDefault(
                data: (overview) {
                  if (overview == null || budgetSummary == null) {
                    return const SizedBox.shrink();
                  }
                  final visibleItems = _visibleItems(overview);

                  if (isDesktop) {
                    return Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Left Column: Month Selector, Summary, and History Chart
                        Expanded(
                          flex: 5,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              MonthSelector(
                                selectedMonth: _selectedDate,
                                onMonthChanged: _selectMonth,
                              ),
                              BudgetSummaryCard(
                                summary: budgetSummary,
                                monthlyIncome: monthlyIncome,
                              ),
                              _buildHistorySection(
                                historyAsync: historyAsync,
                                year: year,
                                month: month,
                                isChatEnabled: isChatEnabled,
                                onMonthSelected: _selectMonth,
                              ),
                            ],
                          ),
                        ),
                        // Right Column: Category Budgets Header & Grid
                        Expanded(
                          flex: 7,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              _buildOverviewSection(
                                theme: theme,
                                visibleItems: visibleItems,
                                categories: categories,
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }

                  // Mobile View
                  return Column(
                    children: [
                      Padding(
                          padding: EdgeInsetsGeometry.all(8),
                          child: SizedBox(
                            width: double.infinity,
                            child: SegmentedButton<MobileBudgetTab>(
                              style: SegmentedButton.styleFrom(
                                visualDensity: VisualDensity.compact,
                              ),
                              segments: const [
                                ButtonSegment(
                                  value: MobileBudgetTab.current,
                                  label: Text('Overview'),
                                  icon: Icon(Icons.pie_chart_outline),
                                ),
                                ButtonSegment(
                                  value: MobileBudgetTab.history,
                                  label: Text('History'),
                                  icon: Icon(Icons.show_chart),
                                ),
                              ],
                              selected: {_currentTab},
                              onSelectionChanged:
                                  (Set<MobileBudgetTab> newSelection) {
                                setState(() {
                                  _currentTab = newSelection.first;
                                });
                              },
                            ),
                          )),
                      Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (_currentTab == MobileBudgetTab.current) ...[
                              MonthSelector(
                                selectedMonth: _selectedDate,
                                onMonthChanged: _selectMonth,
                              ),
                              BudgetSummaryCard(
                                summary: budgetSummary,
                                monthlyIncome: monthlyIncome,
                              ),
                              _buildOverviewSection(
                                theme: theme,
                                visibleItems: visibleItems,
                                categories: categories,
                              ),
                            ] else
                              _buildHistorySection(
                                historyAsync: historyAsync,
                                year: year,
                                month: month,
                                isChatEnabled: isChatEnabled,
                                onMonthSelected: _selectMonth,
                                theme: theme,
                              ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }

  List<CategoryBudgetOverviewItem> _visibleItems(
          BudgetOverviewResponseDto overview) =>
      overview.items
          .where((item) =>
              item.budgetId != null ||
              item.budgetedAmount > 0 ||
              item.actualSpent > 0)
          .toList();

  bool _hasUnbudgetedSpending(List<CategoryBudgetOverviewItem> items) =>
      items.any((item) => item.budgetedAmount <= 0 && item.actualSpent > 0);

  Widget _buildOverviewSection({
    required ThemeData theme,
    required List<CategoryBudgetOverviewItem> visibleItems,
    required List<Category> categories,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildCategoryHeader(
          theme,
          visibleItems.length,
          showLimitHint: _hasUnbudgetedSpending(visibleItems),
        ),
        if (visibleItems.isEmpty && categories.isEmpty)
          _buildEmptyBudgetsCard(theme),
        if (visibleItems.isNotEmpty || categories.isNotEmpty)
          _buildCategoryList(visibleItems, categories),
      ],
    );
  }

  Widget _buildHistorySection({
    required AsyncValue<BudgetHistoryResponseDto?> historyAsync,
    required int year,
    required int month,
    required bool isChatEnabled,
    required ValueChanged<DateTime> onMonthSelected,
    ThemeData? theme,
  }) {
    return historyAsync.whenDefault(
      data: (history) {
        final hasHistory = history != null && history.history.isNotEmpty;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (hasHistory)
              BudgetHistoryChart(
                historyDto: history,
                onMonthSelected: onMonthSelected,
              )
            else if (theme != null)
              SproutCard(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Center(
                    child: Text(
                      'No historical data available.',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            if (isChatEnabled) BudgetChatCard(year: year, month: month),
          ],
        );
      },
    );
  }

  Widget _buildCategoryList(
    List<CategoryBudgetOverviewItem> items,
    List<Category> categories,
  ) {
    final itemsByCategoryId = {
      for (final item in items) item.category.id: item
    };
    final categoriesById = {
      for (final category in categories) category.id: category
    };
    for (final item in items) {
      categoriesById[item.category.id] = item.category;
    }

    final includedCategoryIds = itemsByCategoryId.keys.toSet();
    for (final item in items) {
      var parentId = item.category.parentCategoryId;
      final ancestors = <String>{item.category.id};
      while (parentId != null && ancestors.add(parentId)) {
        final parent = categoriesById[parentId];
        if (parent == null) break;
        includedCategoryIds.add(parent.id);
        parentId = parent.parentCategoryId;
      }
    }

    final childrenByParentId = <String?, List<Category>>{};
    for (final category in categoriesById.values) {
      childrenByParentId
          .putIfAbsent(category.parentCategoryId, () => [])
          .add(category);
    }
    for (final children in childrenByParentId.values) {
      children.sort((a, b) => a.name.compareTo(b.name));
    }
    includedCategoryIds.addAll(
        childrenByParentId[null]?.map((category) => category.id) ??
            const <String>[]);

    final rows = <({Widget child, int depth})>[];
    final renderedCategoryIds = <String>{};
    void appendCategory(Category category, int depth) {
      if (!includedCategoryIds.contains(category.id) ||
          !renderedCategoryIds.add(category.id)) {
        return;
      }

      final item = itemsByCategoryId[category.id];
      rows.add((
        child: item == null
            ? _buildCategoryGroupHeader(category, depth)
            : CategoryBudgetItemTile(item: item, depth: depth),
        depth: depth,
      ));

      for (final child
          in childrenByParentId[category.id] ?? const <Category>[]) {
        appendCategory(child, depth + 1);
      }
    }

    final roots = childrenByParentId[null] ?? const <Category>[];
    for (final category in roots) {
      appendCategory(category, 0);
    }
    for (final item in items) {
      if (!renderedCategoryIds.contains(item.category.id)) {
        appendCategory(item.category, 0);
      }
    }

    return SproutCard(
      child: Column(
        children: [
          for (var index = 0; index < rows.length; index++) ...[
            if (index > 0)
              Divider(
                height: 1,
                indent: 16 + rows[index].depth * 16,
                endIndent: 16,
              ),
            rows[index].child,
          ],
        ],
      ),
    );
  }

  Widget _buildCategoryGroupHeader(Category category, int depth) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => showBudgetEditDialog(context: context, category: category),
      child: Padding(
        padding: EdgeInsetsDirectional.fromSTEB(16 + depth * 16, 8, 16, 8),
        child: Row(
          spacing: 8,
          children: [
            CategoryIcon(category, avatarSize: 12),
            Expanded(
              child: Text(
                category.name,
                style: theme.textTheme.titleSmall
                    ?.copyWith(fontWeight: FontWeight.w600),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Icon(Icons.add,
                size: 18, color: theme.colorScheme.onSurfaceVariant),
          ],
        ),
      ),
    );
  }

  Widget _buildCategoryHeader(
    ThemeData theme,
    int categoryCount, {
    required bool showLimitHint,
  }) {
    return SproutCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          spacing: 4,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SproutChartHeader(
              title: "Spending by Category",
            ),
            if (showLimitHint)
              Row(
                spacing: 4,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: theme.colorScheme.primary, size: 20),
                  Expanded(
                    child: Text(
                      'Set monthly limits to keep spending on track.',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                  TextButton.icon(
                    onPressed: () => showBudgetEditDialog(context: context),
                    icon: const Icon(Icons.add, size: 18),
                    label: const Text('Add limit'),
                  ),
                ],
              ),
          ],
        ),
      ),
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
                'No spending or limits yet. Create a monthly limit to start tracking a category.',
                style: theme.textTheme.bodyMedium
                    ?.copyWith(color: theme.colorScheme.onSurfaceVariant),
              ),
              FilledButton.icon(
                onPressed: () => showBudgetEditDialog(context: context),
                icon: const Icon(Icons.add, size: 18),
                label: const Text('Create a limit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
