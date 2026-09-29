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
import 'package:sprout/routes/util/navigation_provider.dart';
import 'package:sprout/shared/models/extensions/async_value_extensions.dart';
import 'package:sprout/shared/widgets/card.dart';
import 'package:sprout/shared/widgets/charts/util/header.dart';
import 'package:sprout/shared/widgets/layout.dart';
import 'package:sprout/shared/widgets/month_selector.dart';
import 'package:sprout/shared/widgets/speed_dial.dart';
import 'package:sprout/shared/widgets/tab_selector.dart';

/// Budget page sections synchronized with the `tab` query parameter.
enum BudgetTab { overview, history }

class BudgetPage extends ConsumerStatefulWidget {
  const BudgetPage({super.key});

  @override
  ConsumerState<BudgetPage> createState() => _BudgetPageState();
}

class _BudgetPageState extends ConsumerState<BudgetPage> {
  void _selectMonth(DateTime month) {
    NavigationProvider.updateQueryParameters(context, {
      'year': month.year.toString(),
      'month': month.month.toString(),
    });
  }

  DateTime _selectedMonthFromRoute(BuildContext context) {
    final now = DateTime.now();
    final year = int.tryParse(
            NavigationProvider.queryParameter(context, 'year') ?? '') ??
        now.year;
    final month = int.tryParse(
            NavigationProvider.queryParameter(context, 'month') ?? '') ??
        now.month;
    if (month < 1 || month > 12) return DateTime(now.year, now.month);
    return DateTime(year, month);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isChatEnabled = ref.watch(chatEnabledProvider);
    final selectedDate = _selectedMonthFromRoute(context);
    final year = selectedDate.year;
    final month = selectedDate.month;
    final currentTab = NavigationProvider.queryParameter(context, 'tab') ==
            BudgetTab.history.name
        ? BudgetTab.history
        : BudgetTab.overview;

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
      body: SproutTabbedLayout(
        mobileNavigation: SproutTabSelector<BudgetTab>(
          compact: true,
          options: const [
            SproutTabOption(value: BudgetTab.overview, label: 'Overview'),
            SproutTabOption(value: BudgetTab.history, label: 'History'),
          ],
          selected: currentTab,
          onSelected: (tab) => NavigationProvider.updateQueryParameters(
            context,
            {'tab': tab.name},
          ),
        ),
        child: SproutLayoutBuilder(
          (isDesktop, context, constraints) => SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 16),
            child: SproutRouteWrapper(
              size: SproutRouteSize.large,
              child: overviewAsync.whenDefault(
                data: (overview) {
                  if (overview == null || budgetSummary == null) {
                    return const SizedBox.shrink();
                  }
                  final visibleItems = _visibleItems(overview);

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: isDesktop
                        ? Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 5,
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    MonthSelector(
                                      selectedMonth: selectedDate,
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
                                      theme: theme,
                                    ),
                                  ],
                                ),
                              ),
                              Expanded(
                                flex: 7,
                                child: _buildOverviewSection(
                                  theme: theme,
                                  visibleItems: visibleItems,
                                  categories: categories,
                                ),
                              ),
                            ],
                          )
                        : currentTab == BudgetTab.history
                            ? _buildHistorySection(
                                historyAsync: historyAsync,
                                year: year,
                                month: month,
                                isChatEnabled: isChatEnabled,
                                onMonthSelected: _selectMonth,
                                theme: theme,
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  MonthSelector(
                                    selectedMonth: selectedDate,
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
                                ],
                              ),
                  );
                },
              ),
            ),
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

  Widget _buildCategoryHeader(ThemeData theme, int categoryCount) {
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
